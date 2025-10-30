/// Chat screen for AI-powered parenting assistance.
/// Displays message history and allows sending text and voice messages.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_recorder_provider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/app_drawer.dart';
import '../domain/quick_actions_config.dart';
import '../../voice/presentation/voice_mode_screen.dart';
import '../../onboarding/providers/onboarding_provider.dart';

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

  // Image picker instance for photo selection
  final ImagePicker _imagePicker = ImagePicker();

  // List of selected photos (max 3)
  final List<XFile> _selectedPhotos = [];

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

  /// Shows action sheet to select photo source (camera or gallery)
  Future<void> _showPhotoPickerOptions() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Library'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Picks a photo from camera
  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          // Only allow max 3 photos
          if (_selectedPhotos.length < 3) {
            _selectedPhotos.add(photo);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum 3 photos allowed'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  /// Picks photos from gallery (allows multi-select up to 3 photos)
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photos.isNotEmpty && mounted) {
        setState(() {
          // Calculate how many more photos we can add (max 3 total)
          final remainingSlots = 3 - _selectedPhotos.length;
          final photosToAdd = photos.take(remainingSlots).toList();

          _selectedPhotos.addAll(photosToAdd);

          if (photos.length > remainingSlots) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Only added ${photosToAdd.length} photos (max 3 total)'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select photos: $e')),
        );
      }
    }
  }

  /// Removes a photo from selected photos list
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
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
      // Navigation drawer (swipe from left or tap hamburger menu)
      drawer: const AppDrawer(),

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

          // Quick action buttons (contextual suggestions)
          _buildQuickActions(),

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

          // Selected photos thumbnails (shown above input when photos are selected)
          if (_selectedPhotos.isNotEmpty)
            Container(
              height: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _selectedPhotos.length,
                itemBuilder: (context, index) {
                  final photo = _selectedPhotos[index];
                  return Stack(
                    children: [
                      // Photo thumbnail
                      Container(
                        width: 84,
                        height: 84,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(photo.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Remove button (X) in top-right corner
                      Positioned(
                        top: 0,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                  // Attachment button (paperclip icon)
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: chatState.isSendingMessage ||
                            voiceState.state == RecordingState.recording
                        ? null
                        : _showPhotoPickerOptions,
                    tooltip: 'Attach photo',
                  ),

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

  /// Builds quick action buttons based on user's parenting stage
  /// Shows contextual suggestions for pregnancy or baby age
  Widget _buildQuickActions() {
    // Watch onboarding data to get user mode and baby info
    final onboardingData = ref.watch(onboardingProvider);

    // Don't show quick actions if mode not set (user hasn't completed onboarding)
    if (onboardingData.mode == null) {
      return const SizedBox.shrink();
    }

    // Parse baby birth date if available
    DateTime? babyBirthDate;
    if (onboardingData.birthDate != null) {
      try {
        babyBirthDate = DateTime.parse(onboardingData.birthDate!);
      } catch (e) {
        // Invalid date format, ignore
      }
    }

    // Get appropriate quick actions based on user's stage
    final quickActions = QuickActionsConfig.getMixedActions(
      mode: onboardingData.mode!,
      babyBirthDate: babyBirthDate,
    );

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickActions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return QuickActionButton(
            icon: action.icon,
            label: action.label,
            onTap: () => _handleQuickActionTap(action.message),
          );
        },
      ),
    );
  }

  /// Handles quick action button tap
  /// Auto-fills message and sends to chat
  Future<void> _handleQuickActionTap(String message) async {
    // Set the message in the input field
    _messageController.text = message;

    // Optionally focus the input field (or just send immediately)
    // For better UX, let's send immediately
    await _sendMessage();

    // Scroll to bottom to show the new message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
}
