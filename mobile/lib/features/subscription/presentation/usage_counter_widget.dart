/// Usage counter widget that displays current usage stats and limits.
/// Shows remaining messages/voice minutes for FREE users, Premium badge for PREMIUM users.
/// Tappable to show detailed usage stats or upgrade options.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import 'paywall_modal.dart';

/// Compact usage counter widget for app bar
/// Displays usage stats or premium badge
class UsageCounterWidget extends ConsumerWidget {
  const UsageCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        // Show premium badge for premium users
        if (subscription.isPremium) {
          return _buildPremiumBadge(context, theme);
        }

        // Show usage counter for free users
        final usage = subscription.usage;
        if (usage == null) {
          return const SizedBox.shrink();
        }

        return _buildUsageCounter(context, theme, usage);
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Builds premium badge for premium users
  Widget _buildPremiumBadge(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () {
        // Show detailed usage info or subscription management
        _showUsageDetails(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              size: 16,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              'Premium',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds usage counter for free users
  Widget _buildUsageCounter(
    BuildContext context,
    ThemeData theme,
    usage,
  ) {
    final messagesRemaining = usage.messagesRemaining;
    final messageLimit = usage.messageLimit ?? 0;
    final messagesUsed = usage.messagesUsed;

    // Calculate percentage for color coding
    final percentage = messageLimit > 0 ? messagesUsed / messageLimit : 0.0;

    // Choose color based on usage
    Color badgeColor;
    if (percentage >= 0.9) {
      badgeColor = theme.colorScheme.error; // Red when almost at limit
    } else if (percentage >= 0.7) {
      badgeColor = Colors.orange; // Orange when getting close
    } else {
      badgeColor = theme.colorScheme.primary; // Normal color
    }

    return InkWell(
      onTap: () {
        // Show detailed usage info or paywall if close to limit
        if (percentage >= 0.8) {
          showPaywallModal(context);
        } else {
          _showUsageDetails(context);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.1),
          border: Border.all(
            color: badgeColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: badgeColor,
            ),
            const SizedBox(width: 4),
            Text(
              '$messagesRemaining/$messageLimit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows detailed usage statistics in a bottom sheet
  void _showUsageDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const UsageDetailsSheet(),
    );
  }
}

/// Detailed usage statistics sheet
class UsageDetailsSheet extends ConsumerWidget {
  const UsageDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: subscriptionAsync.when(
          data: (subscription) {
            final isPremium = subscription.isPremium;
            final usage = subscription.usage;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Usage',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Premium badge or tier info
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium Member',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Unlimited access to all features',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (usage != null)
                  ...[
                    _buildUsageRow(
                      context,
                      Icons.chat_bubble,
                      'Messages',
                      usage.messagesUsed,
                      usage.messageLimit ?? 0,
                    ),
                    const SizedBox(height: 12),
                    _buildUsageRow(
                      context,
                      Icons.mic,
                      'Voice Minutes',
                      usage.voiceMinutesUsed,
                      usage.voiceLimit ?? 0,
                    ),
                    const SizedBox(height: 12),
                    _buildUsageRow(
                      context,
                      Icons.photo,
                      'Photos',
                      usage.photosStored,
                      usage.photoLimit ?? 0,
                    ),
                    const SizedBox(height: 16),
                    if (usage.resetTime != null)
                      Text(
                        'Daily limits reset at midnight UTC',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],

                const SizedBox(height: 16),

                // Upgrade button for free users
                if (!isPremium)
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showPaywallModal(context);
                    },
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade to Premium'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Error loading usage: $error'),
          ),
        ),
      ),
    );
  }

  /// Builds a single usage stat row with progress bar
  Widget _buildUsageRow(
    BuildContext context,
    IconData icon,
    String label,
    int used,
    int limit,
  ) {
    final theme = Theme.of(context);
    final percentage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isLimitReached = used >= limit && limit > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                limit > 0 ? '$used / $limit' : '$used',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isLimitReached
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (limit > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLimitReached
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                minHeight: 8,
              ),
            ),
        ],
      ),
    );
  }
}
