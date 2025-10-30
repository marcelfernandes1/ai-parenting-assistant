/// Message bubble widget for displaying chat messages.
/// Styled differently for user vs assistant messages.
/// Displays photo thumbnails if message has media URLs.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/chat_message.dart';

/// Widget that displays a single chat message in a bubble.
/// User messages appear on the right in blue.
/// Assistant messages appear on the left in gray.
/// Shows timestamp below message content.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Check if message is from user or assistant
    final isUser = message.role == MessageRole.user;

    // Get color scheme from Material 3 theme
    final colorScheme = Theme.of(context).colorScheme;

    // Format timestamp as "3:45 PM" or "Yesterday 3:45 PM"
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        // User messages align right, assistant messages align left
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Add assistant avatar on left for assistant messages
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_outlined,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message bubble with content
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                // User: primary color, Assistant: surface variant
                color: isUser
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  // Tail on bottom right for user, bottom left for assistant
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content text
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isUser
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                  ),

                  // Photo grid (if message has media URLs)
                  if (message.mediaUrls.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildPhotoGrid(context, message.mediaUrls),
                  ],

                  const SizedBox(height: 4),

                  // Timestamp with small text
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isUser
                              ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Add user avatar on right for user messages
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.person_outline,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a grid of photo thumbnails from media URLs.
  /// Layout: single photo takes full width, 2-3 photos in horizontal grid.
  Widget _buildPhotoGrid(BuildContext context, List<String> photoUrls) {
    final photoCount = photoUrls.length;

    // Single photo - full width
    if (photoCount == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: photoUrls[0],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      );
    }

    // Multiple photos - horizontal grid (2-3 photos side by side)
    return SizedBox(
      height: 150,
      child: Row(
        children: photoUrls.map((url) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Typing indicator widget shown while AI is generating response.
/// Displays animated dots to indicate processing.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Create repeating animation for dots
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Assistant avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.smart_toy_outlined,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),

          // Typing bubble with animated dots
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Three animated dots
                _buildDot(0, colorScheme),
                const SizedBox(width: 4),
                _buildDot(1, colorScheme),
                const SizedBox(width: 4),
                _buildDot(2, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single animated dot with staggered animation delay
  Widget _buildDot(int index, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate opacity with staggered delay for each dot
        final delay = index * 0.2;
        final value = (_controller.value + delay) % 1.0;
        final opacity = (value < 0.5)
            ? value * 2 // Fade in
            : (1.0 - value) * 2; // Fade out

        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
