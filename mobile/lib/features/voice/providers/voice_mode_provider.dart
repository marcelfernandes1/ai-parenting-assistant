/// Voice Mode Provider
///
/// Manages real-time WebSocket voice conversation state using Socket.io.
/// Handles connection, audio streaming, transcription, and AI responses.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'dart:typed_data';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/api_client.dart';

/// Voice mode connection states
enum VoiceModeState {
  disconnected, // Not connected
  connecting, // Establishing connection
  connected, // Connected but not in session
  sessionStarted, // Session active, ready for audio
  listening, // Listening to user
  processing, // Processing audio/generating response
  speaking, // AI is speaking
  error, // Error state
}

/// Voice mode data model
class VoiceModeData {
  final VoiceModeState state;
  final String? voiceSessionId;
  final int? minutesRemaining; // -1 for unlimited (premium)
  final int elapsedSeconds;
  final String? currentTranscription;
  final String? currentAiResponse;
  final String? errorMessage;

  const VoiceModeData({
    this.state = VoiceModeState.disconnected,
    this.voiceSessionId,
    this.minutesRemaining,
    this.elapsedSeconds = 0,
    this.currentTranscription,
    this.currentAiResponse,
    this.errorMessage,
  });

  VoiceModeData copyWith({
    VoiceModeState? state,
    String? voiceSessionId,
    int? minutesRemaining,
    int? elapsedSeconds,
    String? currentTranscription,
    String? currentAiResponse,
    String? errorMessage,
  }) {
    return VoiceModeData(
      state: state ?? this.state,
      voiceSessionId: voiceSessionId ?? this.voiceSessionId,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      currentAiResponse: currentAiResponse ?? this.currentAiResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Voice mode notifier manages Socket.io connection and events
class VoiceModeNotifier extends StateNotifier<VoiceModeData> {
  final String accessToken;
  IO.Socket? _socket;
  Timer? _sessionTimer;

  VoiceModeNotifier(this.accessToken) : super(const VoiceModeData());

  /// Connect to Socket.io voice namespace
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      // Already connected
      return;
    }

    try {
      state = state.copyWith(state: VoiceModeState.connecting);

      // Get API URL from environment or default
      const String apiUrl = String.fromEnvironment(
        'API_URL',
        defaultValue: 'http://localhost:3000',
      );

      // Create Socket.io connection to /voice namespace
      _socket = IO.io(
        '$apiUrl/voice',
        IO.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport
            .enableAutoConnect()
            .enableReconnection()
            .setAuth({'token': 'Bearer $accessToken'}) // JWT authentication
            .build(),
      );

      // Connection established
      _socket!.onConnect((_) {
        print('🎙️ Voice mode connected');
        state = state.copyWith(state: VoiceModeState.connected);
      });

      // Connection error
      _socket!.onConnectError((error) {
        print('🎙️ Voice mode connection error: $error');
        state = state.copyWith(
          state: VoiceModeState.error,
          errorMessage: 'Connection failed: $error',
        );
      });

      // Disconnected
      _socket!.onDisconnect((_) {
        print('🎙️ Voice mode disconnected');
        _stopSessionTimer();
        state = state.copyWith(state: VoiceModeState.disconnected);
      });

      // Session started event
      _socket!.on('session_started', (data) {
        print('🎙️ Voice session started: $data');
        final sessionId = data['voiceSessionId'] as String?;
        final minutes = data['minutesRemaining'] as int?;

        state = state.copyWith(
          state: VoiceModeState.sessionStarted,
          voiceSessionId: sessionId,
          minutesRemaining: minutes,
          elapsedSeconds: 0,
        );

        // Start session timer
        _startSessionTimer();
      });

      // Limit reached event
      _socket!.on('limit_reached', (data) {
        print('🎙️ Voice limit reached: $data');
        state = state.copyWith(
          state: VoiceModeState.error,
          errorMessage: data['message'] as String? ?? 'Daily limit reached',
        );
        disconnect();
      });

      // Transcription received
      _socket!.on('transcription', (data) {
        print('🎙️ Transcription received: ${data['text']}');
        state = state.copyWith(
          state: VoiceModeState.processing,
          currentTranscription: data['text'] as String?,
        );
      });

      // AI response received
      _socket!.on('ai_response', (data) {
        print('🎙️ AI response received');
        state = state.copyWith(
          state: VoiceModeState.speaking,
          currentAiResponse: data['text'] as String?,
        );

        // After speaking, go back to listening state
        Future.delayed(const Duration(milliseconds: 500), () {
          if (state.state == VoiceModeState.speaking) {
            state = state.copyWith(state: VoiceModeState.sessionStarted);
          }
        });
      });

      // Session ended event
      _socket!.on('session_ended', (data) {
        print('🎙️ Voice session ended: $data');
        _stopSessionTimer();
        disconnect();
      });

      // Error event
      _socket!.on('error', (data) {
        print('🎙️ Voice mode error: $data');
        state = state.copyWith(
          state: VoiceModeState.error,
          errorMessage: data['message'] as String? ?? 'Unknown error',
        );
      });

      // Connect (auto-connects due to enableAutoConnect)
      _socket!.connect();
    } catch (e) {
      print('🎙️ Error connecting to voice mode: $e');
      state = state.copyWith(
        state: VoiceModeState.error,
        errorMessage: 'Failed to connect: $e',
      );
    }
  }

  /// Start a new voice session
  void startSession() {
    if (_socket == null || !_socket!.connected) {
      state = state.copyWith(
        state: VoiceModeState.error,
        errorMessage: 'Not connected to server',
      );
      return;
    }

    print('🎙️ Starting voice session');
    _socket!.emit('start_session');
  }

  /// Send audio chunk to server
  void sendAudioChunk(Uint8List audioData, {bool isLast = false}) {
    if (_socket == null || !_socket!.connected) {
      print('🎙️ Cannot send audio: not connected');
      return;
    }

    if (state.state != VoiceModeState.sessionStarted &&
        state.state != VoiceModeState.listening) {
      print('🎙️ Cannot send audio: session not started');
      return;
    }

    // Set state to listening when first chunk is sent
    if (state.state == VoiceModeState.sessionStarted) {
      state = state.copyWith(state: VoiceModeState.listening);
    }

    print('🎙️ Sending audio chunk (${audioData.length} bytes, last: $isLast)');
    _socket!.emit('audio_chunk', {
      'chunk': audioData,
      'isLast': isLast,
    });

    // If this is the last chunk, set state to processing
    if (isLast) {
      state = state.copyWith(state: VoiceModeState.processing);
    }
  }

  /// End the voice session
  void endSession() {
    if (_socket == null || !_socket!.connected) {
      disconnect();
      return;
    }

    print('🎙️ Ending voice session');
    _socket!.emit('end_session');
    _stopSessionTimer();
  }

  /// Disconnect from voice mode
  void disconnect() {
    print('🎙️ Disconnecting from voice mode');
    _stopSessionTimer();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    state = const VoiceModeData(state: VoiceModeState.disconnected);
  }

  /// Start session timer to track elapsed time
  void _startSessionTimer() {
    _stopSessionTimer();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);

      // Check if approaching limit (1 minute warning for free users)
      if (state.minutesRemaining != null &&
          state.minutesRemaining! > 0 &&
          state.elapsedSeconds >= (state.minutesRemaining! - 1) * 60) {
        // Approaching limit - could show warning
        print('🎙️ Approaching time limit');
      }

      // Auto-end session when limit reached
      if (state.minutesRemaining != null &&
          state.minutesRemaining! > 0 &&
          state.elapsedSeconds >= state.minutesRemaining! * 60) {
        print('🎙️ Time limit reached, ending session');
        endSession();
      }
    });
  }

  /// Stop session timer
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

/// Provider for voice mode state
final voiceModeProvider =
    StateNotifierProvider.autoDispose<VoiceModeNotifier, VoiceModeData>((ref) {
  // Get access token from auth provider
  final authState = ref.watch(authProvider);
  final accessToken = authState.accessToken ?? '';

  if (accessToken.isEmpty) {
    throw Exception('No access token available for voice mode');
  }

  return VoiceModeNotifier(accessToken);
});
