/// Conversation list screen showing all past conversation sessions.
/// Users can view, select, or delete previous conversations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/conversation.dart';
import '../../../shared/providers/repositories.dart';
import 'chat_screen.dart';

/// Screen displaying a list of all user's conversation sessions.
/// Shows conversation previews with timestamps and message counts.
class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  /// Holds the list of conversations loaded from the backend
  List<Conversation> _conversations = [];

  /// Loading state indicator
  bool _isLoading = true;

  /// Error message if loading fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load conversations when screen initializes
    _loadConversations();
  }

  /// Loads conversation list from backend via repository
  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get chat repository from provider
      final chatRepository = ref.read(chatRepositoryProvider);

      // Fetch conversations from backend
      final conversations = await chatRepository.getConversations();

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load conversations: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Navigates to chat screen with the selected conversation
  void _openConversation(Conversation conversation) {
    // Close conversation list and navigate to chat
    // The chat provider will load the selected session
    Navigator.pop(context); // Close this screen
    // Note: We'll need to update the chat provider to support loading specific sessions
    // For now, just close this screen
  }

  /// Deletes a conversation after user confirmation
  Future<void> _deleteConversation(Conversation conversation) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation?'),
        content: const Text(
          'This will permanently delete all messages in this conversation. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Get chat repository from provider
        final chatRepository = ref.read(chatRepositoryProvider);

        // Delete the session
        await chatRepository.deleteSession(conversation.sessionId);

        // Reload conversations to reflect deletion
        await _loadConversations();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete conversation: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  /// Builds the main body content based on loading state
  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      // Show loading spinner
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      // Show error message with retry button
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadConversations,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      // Show empty state
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'No Conversations Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start a new conversation from the chat screen to see it here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show list of conversations
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationTile(conversation, theme);
        },
      ),
    );
  }

  /// Builds a single conversation list tile
  Widget _buildConversationTile(Conversation conversation, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      // Leading icon based on content type
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          conversation.previewType == 'VOICE'
              ? Icons.mic
              : conversation.previewType == 'IMAGE'
                  ? Icons.image
                  : Icons.chat_bubble,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      // Conversation preview text
      title: Text(
        conversation.preview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge,
      ),
      // Message count and timestamp
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(
              Icons.message,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${conversation.messageCount} messages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.schedule,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              conversation.formattedLastMessageTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      // Trailing delete button
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.error,
        ),
        tooltip: 'Delete conversation',
        onPressed: () => _deleteConversation(conversation),
      ),
      // Navigate to conversation on tap
      onTap: () => _openConversation(conversation),
    );
  }
}
