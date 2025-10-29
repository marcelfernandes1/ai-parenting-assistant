/// Voice recorder provider for recording audio messages.
/// Manages recording state, permissions, and file handling.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// Voice recording state
enum RecordingState {
  /// No recording is active
  idle,

  /// Recording is in progress
  recording,

  /// Recording has stopped, audio file is available
  stopped,

  /// Error occurred during recording
  error,
}

/// Voice recorder data model
class VoiceRecorderState {
  final RecordingState state;
  final String? filePath;
  final Duration duration;
  final String? errorMessage;

  const VoiceRecorderState({
    required this.state,
    this.filePath,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  /// Create initial state
  const VoiceRecorderState.initial()
      : state = RecordingState.idle,
        filePath = null,
        duration = Duration.zero,
        errorMessage = null;

  /// Copy with method for state updates
  VoiceRecorderState copyWith({
    RecordingState? state,
    String? filePath,
    Duration? duration,
    String? errorMessage,
  }) {
    return VoiceRecorderState(
      state: state ?? this.state,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Voice recorder notifier for managing audio recording
class VoiceRecorderNotifier extends StateNotifier<VoiceRecorderState> {
  final AudioRecorder _recorder;
  Timer? _durationTimer;

  VoiceRecorderNotifier(this._recorder) : super(const VoiceRecorderState.initial());

  @override
  void dispose() {
    // Clean up timer when disposed
    _durationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  /// Check and request microphone permission
  /// Returns true if permission is granted
  Future<bool> checkPermission() async {
    try {
      final status = await Permission.microphone.status;

      if (status.isGranted) {
        return true;
      }

      // Request permission if not granted
      final result = await Permission.microphone.request();
      return result.isGranted;
    } catch (e) {
      state = state.copyWith(
        state: RecordingState.error,
        errorMessage: 'Failed to check microphone permission: $e',
      );
      return false;
    }
  }

  /// Start recording audio
  /// Returns true if recording started successfully
  Future<bool> startRecording() async {
    try {
      // Check permission first
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        state = state.copyWith(
          state: RecordingState.error,
          errorMessage: 'Microphone permission denied',
        );
        return false;
      }

      // Check if already recording
      if (state.state == RecordingState.recording) {
        return false;
      }

      // Get temporary directory for audio file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/voice_${timestamp}.m4a';

      // Start recording with m4a format (compatible with iOS and Android)
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC-LC codec for m4a format
          bitRate: 128000, // 128 kbps for good quality
          sampleRate: 44100, // 44.1 kHz sample rate
        ),
        path: filePath,
      );

      // Update state to recording
      state = state.copyWith(
        state: RecordingState.recording,
        filePath: filePath,
        duration: Duration.zero,
        errorMessage: null,
      );

      // Start duration timer (updates every second)
      _startDurationTimer();

      return true;
    } catch (e) {
      state = state.copyWith(
        state: RecordingState.error,
        errorMessage: 'Failed to start recording: $e',
      );
      return false;
    }
  }

  /// Stop recording and return the audio file path
  /// Returns audio file path if successful, null otherwise
  Future<String?> stopRecording() async {
    try {
      // Cancel duration timer
      _durationTimer?.cancel();
      _durationTimer = null;

      // Stop recording
      final path = await _recorder.stop();

      if (path != null && await File(path).exists()) {
        // Update state to stopped
        state = state.copyWith(
          state: RecordingState.stopped,
          filePath: path,
        );
        return path;
      } else {
        state = state.copyWith(
          state: RecordingState.error,
          errorMessage: 'Recording file not found',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        state: RecordingState.error,
        errorMessage: 'Failed to stop recording: $e',
      );
      return null;
    }
  }

  /// Cancel recording and delete the audio file
  Future<void> cancelRecording() async {
    try {
      // Stop recording
      final path = await _recorder.stop();

      // Cancel timer
      _durationTimer?.cancel();
      _durationTimer = null;

      // Delete the file if it exists
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Reset state to idle
      state = const VoiceRecorderState.initial();
    } catch (e) {
      state = state.copyWith(
        state: RecordingState.error,
        errorMessage: 'Failed to cancel recording: $e',
      );
    }
  }

  /// Start a timer that updates recording duration every second
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update duration
      state = state.copyWith(
        duration: Duration(seconds: timer.tick),
      );

      // Auto-stop after 2 minutes (120 seconds)
      if (timer.tick >= 120) {
        stopRecording();
      }
    });
  }

  /// Reset to initial state (after sending or canceling)
  void reset() {
    _durationTimer?.cancel();
    _durationTimer = null;
    state = const VoiceRecorderState.initial();
  }
}

/// Provider for voice recorder
/// Creates a new AudioRecorder instance for each session
final voiceRecorderProvider = StateNotifierProvider.autoDispose<VoiceRecorderNotifier, VoiceRecorderState>((ref) {
  // Create recorder instance
  final recorder = AudioRecorder();

  // Create notifier with recorder
  final notifier = VoiceRecorderNotifier(recorder);

  // Clean up when disposed
  ref.onDispose(() {
    recorder.dispose();
  });

  return notifier;
});
