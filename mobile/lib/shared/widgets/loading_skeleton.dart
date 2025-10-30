/// Loading skeleton components for improved perceived performance.
/// Shows placeholder shimmer animations while content loads.
library;

import 'package:flutter/material.dart';

/// Skeleton loader widget that shows a shimmer animation
/// Used as a placeholder while actual content is loading
class SkeletonLoader extends StatefulWidget {
  /// Width of the skeleton (null for full width)
  final double? width;
  
  /// Height of the skeleton
  final double height;
  
  /// Border radius
  final double borderRadius;
  
  const SkeletonLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Create infinite shimmer animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainerHighest,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for a list tile (chat message, milestone, etc.)
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar/Icon placeholder
          const SkeletonLoader(
            width: 40,
            height: 40,
            borderRadius: 20,
          ),
          const SizedBox(width: 16),
          // Text content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 16,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a card (milestone, photo card, etc.)
class CardSkeleton extends StatelessWidget {
  /// Height of the card
  final double height;
  
  const CardSkeleton({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 20,
            ),
            const SizedBox(height: 12),
            // Content placeholder
            SkeletonLoader(
              width: double.infinity,
              height: height - 80,
            ),
            const SizedBox(height: 12),
            // Footer placeholder
            Row(
              children: [
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a photo grid item
class PhotoGridSkeleton extends StatelessWidget {
  const PhotoGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonLoader(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 12,
    );
  }
}

/// Skeleton for chat message bubbles
class ChatMessageSkeleton extends StatelessWidget {
  /// Whether this is a user message (right aligned) or AI message (left aligned)
  final bool isUser;
  
  const ChatMessageSkeleton({
    super.key,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 16,
              borderRadius: 16,
            ),
            const SizedBox(height: 4),
            SkeletonLoader(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 16,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a grid of photo skeletons
class PhotoGridSkeletonView extends StatelessWidget {
  /// Number of items to show
  final int itemCount;
  
  const PhotoGridSkeletonView({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const PhotoGridSkeleton(),
    );
  }
}

/// Shows a list of chat message skeletons
class ChatSkeletonView extends StatelessWidget {
  /// Number of messages to show
  final int messageCount;
  
  const ChatSkeletonView({
    super.key,
    this.messageCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: messageCount,
      itemBuilder: (context, index) => ChatMessageSkeleton(
        isUser: index % 2 == 0,
      ),
    );
  }
}

/// Shows a list of tile skeletons
class ListSkeletonView extends StatelessWidget {
  /// Number of items to show
  final int itemCount;
  
  const ListSkeletonView({
    super.key,
    this.itemCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const ListTileSkeleton(),
    );
  }
}
