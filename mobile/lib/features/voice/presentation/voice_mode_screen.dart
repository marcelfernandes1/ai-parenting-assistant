import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/voice_mode_provider.dart';
import '../../chat/providers/voice_recorder_provider.dart';

/// Voice Mode Screen
///
/// Full-screen real-time voice conversation interface with AI assistant.
/// Features pulsing animation, live transcription, and session timer.

/// Voice Mode Screen - full-screen voice conversation UI
class VoiceModeScreen extends ConsumerStatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  ConsumerState<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends ConsumerState<VoiceModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup pulsing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Connect to voice mode on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectAndStartSession();
    });
  }

  /// Connect to Socket.io and start voice session
  Future<void> _connectAndStartSession() async {
    try {
      final voiceMode = ref.read(voiceModeProvider.notifier);

      // Connect to WebSocket
      await voiceMode.connect();

      // Wait a moment for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));

      // Start voice session
      voiceMode.startSession();
    } catch (e) {
      print('Error starting voice mode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start voice mode: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Disconnect from voice mode when leaving screen
    ref.read(voiceModeProvider.notifier).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceModeState = ref.watch(voiceModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with timer and close button
            _buildHeader(context, voiceModeState, theme),

            // Main content area with pulsing animation
            Expanded(
              child: _buildMainContent(context, voiceModeState, theme),
            ),

            // Bottom controls
            _buildBottomControls(context, voiceModeState, theme),
          ],
        ),
      ),
    );
  }

  /// Build header with timer and close button
  Widget _buildHeader(
    BuildContext context,
    VoiceModeData state,
    ThemeData theme,
  ) {
    final minutes = state.elapsedSeconds ~/ 60;
    final seconds = state.elapsedSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    String remainingText = '';
    if (state.minutesRemaining != null && state.minutesRemaining! > 0) {
      remainingText = ' • ${state.minutesRemaining} min remaining';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer
          Text(
            timeText + remainingText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _endSessionAndClose(context);
            },
          ),
        ],
      ),
    );
  }

  /// Build main content area with pulsing animation and transcription
  Widget _buildMainContent(
    BuildContext context,
    VoiceModeData state,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing animation circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getCircleColor(state.state, theme),
                    boxShadow: [
                      BoxShadow(
                        color: _getCircleColor(state.state, theme).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getIconForState(state.state),
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // State text
          Text(
            _getStateText(state.state),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          // Transcription or AI response
          if (state.currentTranscription != null ||
              state.currentAiResponse != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.currentTranscription != null) ...[
                    Text(
                      'You said:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.currentTranscription!,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (state.currentAiResponse != null) const SizedBox(height: 16),
                  ],
                  if (state.currentAiResponse != null) ...[
                    Text(
                      'AI Response:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.currentAiResponse!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),

          // Error message
          if (state.errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Build bottom controls (record button, end conversation)
  Widget _buildBottomControls(
    BuildContext context,
    VoiceModeData state,
    ThemeData theme,
  ) {
    final canRecord = state.state == VoiceModeState.sessionStarted ||
        state.state == VoiceModeState.listening;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recording instructions
          if (canRecord)
            Text(
              'Tap and hold to speak',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 16),

          // Record button (tap and hold)
          GestureDetector(
            onTapDown: canRecord ? (_) => _startRecording() : null,
            onTapUp: canRecord ? (_) => _stopRecording() : null,
            onTapCancel: canRecord ? () => _stopRecording() : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.state == VoiceModeState.listening
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (state.state == VoiceModeState.listening
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                state.state == VoiceModeState.listening
                    ? Icons.stop
                    : Icons.mic,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // End conversation button
          OutlinedButton.icon(
            onPressed: () => _endSessionAndClose(context),
            icon: const Icon(Icons.call_end),
            label: const Text('End Conversation'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Get circle color based on state
  Color _getCircleColor(VoiceModeState state, ThemeData theme) {
    switch (state) {
      case VoiceModeState.listening:
        return theme.colorScheme.error;
      case VoiceModeState.processing:
        return theme.colorScheme.tertiary;
      case VoiceModeState.speaking:
        return theme.colorScheme.secondary;
      case VoiceModeState.error:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Get icon based on state
  IconData _getIconForState(VoiceModeState state) {
    switch (state) {
      case VoiceModeState.listening:
        return Icons.mic;
      case VoiceModeState.processing:
        return Icons.psychology;
      case VoiceModeState.speaking:
        return Icons.volume_up;
      case VoiceModeState.error:
        return Icons.error_outline;
      default:
        return Icons.mic_none;
    }
  }

  /// Get state text for display
  String _getStateText(VoiceModeState state) {
    switch (state) {
      case VoiceModeState.connecting:
        return 'Connecting...';
      case VoiceModeState.connected:
        return 'Connected';
      case VoiceModeState.sessionStarted:
        return 'Ready to listen';
      case VoiceModeState.listening:
        return 'Listening...';
      case VoiceModeState.processing:
        return 'Processing...';
      case VoiceModeState.speaking:
        return 'AI Speaking';
      case VoiceModeState.error:
        return 'Error';
      default:
        return 'Disconnected';
    }
  }

  /// Start recording audio
  void _startRecording() async {
    try {
      final recorder = ref.read(voiceRecorderProvider.notifier);
      await recorder.startRecording();
      print('🎙️ Started recording for voice mode');
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  /// Stop recording and send audio to server via WebSocket
  void _stopRecording() async {
    try {
      final recorder = ref.read(voiceRecorderProvider.notifier);
      final filePath = await recorder.stopRecording();

      if (filePath != null) {
        print('🎙️ Stopped recording, sending to server: $filePath');
        await _sendAudioFileInChunks(filePath);
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
    }
  }

  /// Send audio file to server in chunks via WebSocket
  /// Splits file into manageable chunks and streams them
  Future<void> _sendAudioFileInChunks(String filePath) async {
    try {
      // Read audio file
      final file = File(filePath);
      final audioBytes = await file.readAsBytes();

      print('🎙️ Audio file size: ${audioBytes.length} bytes');

      // Define chunk size (e.g., 64KB per chunk for efficient streaming)
      const chunkSize = 64 * 1024; // 64KB chunks

      final totalChunks = (audioBytes.length / chunkSize).ceil();
      print('🎙️ Sending audio in $totalChunks chunks');

      // Send audio data in chunks
      for (var i = 0; i < audioBytes.length; i += chunkSize) {
        final end = (i + chunkSize < audioBytes.length)
            ? i + chunkSize
            : audioBytes.length;

        final chunk = Uint8List.sublistView(audioBytes, i, end);
        final isLast = end >= audioBytes.length;

        // Send chunk via WebSocket
        ref.read(voiceModeProvider.notifier).sendAudioChunk(
          chunk,
          isLast: isLast,
        );

        // Small delay between chunks to avoid overwhelming the connection
        if (!isLast) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        print('🎙️ Sent chunk ${(i ~/ chunkSize) + 1}/$totalChunks (${chunk.length} bytes, last: $isLast)');
      }

      // Clean up temporary audio file after sending
      try {
        await file.delete();
      } catch (error) {
        print('Failed to delete temp file: $error');
      }

      print('🎙️ Audio streaming complete, waiting for transcription');
    } catch (e) {
      print('Error sending audio chunks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send audio: $e')),
        );
      }
    }
  }

  /// End voice session and close screen
  void _endSessionAndClose(BuildContext context) {
    final voiceMode = ref.read(voiceModeProvider.notifier);
    voiceMode.endSession();
    Navigator.of(context).pop();
  }
}
