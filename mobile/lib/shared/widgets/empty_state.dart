/// Empty state widget for when there's no content to display.
/// Provides friendly messages and optional actions for empty screens.
library;

import 'package:flutter/material.dart';

/// Empty state widget that shows when there's no content
/// Displays an icon, title, message, and optional action button
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;
  
  /// Title text
  final String title;
  
  /// Description text
  final String message;
  
  /// Optional action button text
  final String? actionText;
  
  /// Optional action button callback
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button (optional)
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty state for chat
class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Start Your First Conversation',
      message:
          'Ask me anything about parenting, pregnancy, or your baby\'s development. I\'m here to help!',
    );
  }
}

/// Pre-configured empty state for milestones
class EmptyMilestonesState extends StatelessWidget {
  /// Optional callback when user taps add button
  final VoidCallback? onAdd;
  
  const EmptyMilestonesState({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.star_outline,
      title: 'No Milestones Yet',
      message:
          'Your milestone journey starts here! I\'ll help you track your baby\'s special moments and achievements.',
      actionText: onAdd != null ? 'Add First Milestone' : null,
      onAction: onAdd,
    );
  }
}

/// Pre-configured empty state for photos
class EmptyPhotosState extends StatelessWidget {
  /// Optional callback when user taps add button
  final VoidCallback? onAdd;
  
  const EmptyPhotosState({
    super.key,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.photo_outlined,
      title: 'No Photos Yet',
      message:
          'Add your first photo to start building precious memories of your baby!',
      actionText: onAdd != null ? 'Add Photo' : null,
      onAction: onAdd,
    );
  }
}

/// Pre-configured empty state for search results
class EmptySearchState extends StatelessWidget {
  /// Search query that returned no results
  final String query;
  
  const EmptySearchState({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'We couldn\'t find anything matching "$query". Try a different search term.',
    );
  }
}

/// Pre-configured empty state for network errors
class ErrorState extends StatelessWidget {
  /// Error message
  final String message;
  
  /// Optional retry callback
  final VoidCallback? onRetry;
  
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Oops!',
      message: message,
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}
