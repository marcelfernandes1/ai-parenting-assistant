/// Non-intrusive upgrade banner for encouraging free users to upgrade.
/// Shown based on usage patterns and limit proximity.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../domain/subscription_status.dart';
import 'paywall_modal.dart';

/// Upgrade banner widget that shows at appropriate times
/// Non-intrusive and easily dismissable
class UpgradeBanner extends ConsumerStatefulWidget {
  const UpgradeBanner({super.key});

  @override
  ConsumerState<UpgradeBanner> createState() => _UpgradeBannerState();
}

class _UpgradeBannerState extends ConsumerState<UpgradeBanner> {
  /// Whether the banner is dismissed
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    // Don't show if dismissed or subscription is loading/error
    if (_isDismissed) return const SizedBox.shrink();

    return subscriptionAsync.when(
      data: (subscription) {
        // Don't show for premium users
        if (subscription.isPremium) {
          return const SizedBox.shrink();
        }

        // Check if we should show the banner
        final usage = subscription.usage;
        if (usage == null) return const SizedBox.shrink();

        // Calculate usage percentage for messages
        final messagePercentage = usage.messageUsagePercentage;

        // Show banner when user hits 80% of daily limit
        if (messagePercentage >= 0.8) {
          return _buildLimitWarningBanner(context, theme, usage);
        }

        // TODO: Add logic for "loving the app" banner after 10 days
        // This would require tracking daily usage in shared preferences
        // For now, we'll just show the limit warning banner

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Builds the limit warning banner (shown at 80% usage)
  Widget _buildLimitWarningBanner(
    BuildContext context,
    ThemeData theme,
    UsageStats usage,
  ) {
    final messagesRemaining = usage.messagesRemaining;
    final isAtLimit = usage.messageLimitReached;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Open paywall when tapped
            showPaywallModal(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAtLimit ? Icons.warning_rounded : Icons.info_outline,
                    color: Colors.orange.shade800,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAtLimit
                            ? 'Daily limit reached'
                            : '$messagesRemaining ${messagesRemaining == 1 ? "message" : "messages"} left today',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAtLimit
                            ? 'Upgrade for unlimited access'
                            : 'Upgrade for unlimited messages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Upgrade button
                TextButton(
                  onPressed: () {
                    showPaywallModal(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Dismiss button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isDismissed = true;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Provider-based upgrade prompt that shows snackbars
/// Can be called from anywhere in the app
class UpgradePrompter {
  /// Shows a gentle upgrade reminder as a snackbar
  /// Non-intrusive and auto-dismisses
  static void showGentleReminder(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Upgrade',
          textColor: Colors.white,
          onPressed: () {
            showPaywallModal(context);
          },
        ),
      ),
    );
  }

  /// Shows upgrade reminder when user has been active for many days
  /// "Loving the app? Upgrade for unlimited access"
  static void showLovingTheAppReminder(BuildContext context) {
    showGentleReminder(
      context,
      message: 'Loving the app? Upgrade for unlimited access',
    );
  }

  /// Shows upgrade reminder when approaching limit
  /// "2 messages left today. Upgrade for unlimited"
  static void showApproachingLimitReminder(
    BuildContext context,
    int messagesRemaining,
  ) {
    showGentleReminder(
      context,
      message: '$messagesRemaining ${messagesRemaining == 1 ? "message" : "messages"} left today. Upgrade for unlimited',
    );
  }
}
