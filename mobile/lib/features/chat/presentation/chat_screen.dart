/// Chat screen for AI-powered parenting assistance.
/// Displays message history and allows sending text and voice messages.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_recorder_provider.dart';
import 'widgets/message_bubble.dart';
import '../../voice/presentation/voice_mode_screen.dart';

/// Main chat screen with message list and input area.
/// Uses Riverpod to watch chat state and usage statistics.
/// Automatically loads history on mount and scrolls to bottom.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // Text controller for message input field
  final TextEditingController _messageController = TextEditingController();

  // Scroll controller for message list (auto-scroll to bottom)
  final ScrollController _scrollController = ScrollController();

  // Focus node for input field
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listener to text controller to update UI when text changes
    _messageController.addListener(() {
      setState(() {
        // Rebuilds widget to update mic/send button visibility
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Scrolls to bottom of message list with animation
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Sends message to AI assistant
  /// Clears input field and scrolls to bottom after sending
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();

    // Ignore empty messages
    if (content.isEmpty) return;

    // Clear input field immediately for better UX
    _messageController.clear();

    // Send message via provider
    await ref.read(chatProvider.notifier).sendMessage(content);

    // Scroll to bottom to show new messages
    // Use post-frame callback to ensure messages are rendered first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// Starts a new conversation by clearing messages
  Future<void> _startNewConversation() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Conversation?'),
        content: const Text(
          'This will clear your current conversation history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start New'),
          ),
        ],
      ),
    );

    // If confirmed, clear conversation
    if (confirmed == true && mounted) {
      await ref.read(chatProvider.notifier).newConversation();
    }
  }

  /// Starts voice recording
  Future<void> _startVoiceRecording() async {
    final success = await ref.read(voiceRecorderProvider.notifier).startRecording();

    if (!success && mounted) {
      // Show error if recording failed to start
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start recording. Please check microphone permission.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Stops voice recording and sends the audio message
  Future<void> _stopAndSendVoiceRecording() async {
    final audioPath = await ref.read(voiceRecorderProvider.notifier).stopRecording();

    if (audioPath != null && mounted) {
      // Send voice message via chat provider
      await ref.read(chatProvider.notifier).sendVoiceMessage(audioPath);

      // Reset voice recorder state
      ref.read(voiceRecorderProvider.notifier).reset();

      // Scroll to bottom to show new messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else if (mounted) {
      // Show error if recording file not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Cancels voice recording without sending
  Future<void> _cancelVoiceRecording() async {
    await ref.read(voiceRecorderProvider.notifier).cancelRecording();
  }

  /// Opens voice mode screen for real-time conversation
  /// Checks usage limits before navigating
  Future<void> _openVoiceMode(UsageState usageState) async {
    // Check if user has reached voice minutes limit (free tier only)
    // Premium users have unlimited minutes (voiceMinutesUsed tracking still occurs)
    const freeVoiceMinutesLimit = 10;

    // For free tier users, check if limit is reached
    if (usageState.voiceMinutesUsed >= freeVoiceMinutesLimit) {
      // Show limit reached dialog with paywall
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Voice Minutes Limit Reached'),
            content: const Text(
              'You\'ve used all 10 free voice minutes for today. Upgrade to Premium for unlimited voice conversations!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to subscription screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription screen coming soon!'),
                    ),
                  );
                },
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Navigate to voice mode screen
    if (mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const VoiceModeScreen(),
        ),
      );

      // Refresh usage stats after returning from voice mode
      await ref.read(usageProvider.notifier).loadUsage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch chat state for messages and loading status
    final chatState = ref.watch(chatProvider);

    // Watch voice recorder state for recording status
    final voiceState = ref.watch(voiceRecorderProvider);

    // Determine if we should show microphone or send button
    final showMicButton = _messageController.text.isEmpty &&
        voiceState.state != RecordingState.recording;

    // Debug logging
    print('🎤 DEBUG: text isEmpty = ${_messageController.text.isEmpty}');
    print('🎤 DEBUG: voiceState = ${voiceState.state}');
    print('🎤 DEBUG: showMicButton = $showMicButton');

    // Watch usage state for usage counter
    final usageState = ref.watch(usageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Parenting Assistant'),
        actions: [
          // Usage counter badge
          if (!usageState.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${usageState.messagesUsed}/10 today',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),

          // Voice Mode button (distinct from microphone button)
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            tooltip: 'Voice Conversation Mode',
            onPressed: () => _openVoiceMode(usageState),
          ),

          // New conversation button
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Conversation',
            onPressed: _startNewConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Show error banner if there's an error
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Message list
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(chatProvider.notifier).loadHistory();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: chatState.messages.length +
                              (chatState.isSendingMessage ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show typing indicator as last item when sending
                            if (chatState.isSendingMessage &&
                                index == chatState.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: TypingIndicator(),
                              );
                            }

                            // Show message bubble
                            final message = chatState.messages[index];
                            return MessageBubble(message: message);
                          },
                        ),
                      ),
          ),

          // Medical disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Not a substitute for professional medical advice. Seek immediate help for emergencies.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // Recording duration indicator (shown when recording)
          if (voiceState.state == RecordingState.recording)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording icon with pulsing animation
                  Icon(
                    Icons.fiber_manual_record,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // Duration text
                  Text(
                    'Recording: ${_formatDuration(voiceState.duration)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  // Cancel button
                  TextButton(
                    onPressed: _cancelVoiceRecording,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Ask about parenting...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        // Disable input while sending or recording
                        enabled: !chatState.isSendingMessage &&
                            voiceState.state != RecordingState.recording,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Microphone or Send button (conditional)
                  if (showMicButton)
                    // Microphone button with long press to record
                    GestureDetector(
                      onLongPressStart: (_) => _startVoiceRecording(),
                      onLongPressEnd: (_) => _stopAndSendVoiceRecording(),
                      child: FilledButton(
                        onPressed: chatState.isSendingMessage
                            ? null
                            : () {
                                // Show tooltip on tap (not hold)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Hold the microphone button to record'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: voiceState.state ==
                                  RecordingState.recording
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        child: Icon(
                          voiceState.state == RecordingState.recording
                              ? Icons.stop
                              : Icons.mic,
                        ),
                      ),
                    )
                  else
                    // Send button
                    FilledButton(
                      onPressed:
                          chatState.isSendingMessage ? null : _sendMessage,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: chatState.isSendingMessage
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state UI shown when no messages exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),

            const SizedBox(height: 24),

            // Welcome text
            Text(
              'Welcome to AI Parenting Assistant',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Ask me anything about pregnancy, baby care, development, or parenting challenges. I\'m here to help!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Quick action suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickActionChip('Sleep tips'),
                _buildQuickActionChip('Feeding schedule'),
                _buildQuickActionChip('Development milestones'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a quick action chip that pre-fills a message
  Widget _buildQuickActionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _messageController.text = label;
        _inputFocusNode.requestFocus();
      },
    );
  }

  /// Formats duration as mm:ss (e.g., 01:23)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
