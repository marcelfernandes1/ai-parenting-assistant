/// Subscription Management screen for managing subscriptions and viewing usage.
/// Displays current plan, usage stats, and subscription actions.
/// Available from Settings tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../data/purchase_service.dart';
import '../domain/subscription_status.dart';
import 'paywall_modal.dart';

/// Subscription Management screen
/// Shows current subscription status, usage stats, and management options
class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  /// Whether a cancel operation is in progress
  bool _isCancelling = false;

  /// Whether restore purchases is in progress
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        actions: [
          // Refresh button to reload subscription status
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(subscriptionProvider.notifier).refresh();
            },
            tooltip: 'Refresh subscription status',
          ),
        ],
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildContent(context, theme, subscription),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load subscription',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(subscriptionProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main content based on subscription status
  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    SubscriptionStatus subscription,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(subscriptionProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current plan card
            _buildCurrentPlanCard(context, theme, subscription),

            const SizedBox(height: 24),

            // Usage statistics (shown for both free and premium)
            if (subscription.usage != null) ...[
              _buildUsageSection(context, theme, subscription.usage!),
              const SizedBox(height: 24),
            ],

            // Actions based on subscription status
            if (subscription.isPremium) ...[
              _buildPremiumActions(context, theme, subscription),
            ] else ...[
              _buildFreeActions(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the current plan card showing subscription tier and status
  Widget _buildCurrentPlanCard(
    BuildContext context,
    ThemeData theme,
    SubscriptionStatus subscription,
  ) {
    final isPremium = subscription.isPremium;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.stars : Icons.account_circle_outlined,
                  size: 32,
                  color: isPremium ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? 'Premium Plan' : 'Free Plan',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium
                            ? 'Unlimited access to all features'
                            : 'Limited to 10 messages & 10 voice minutes per day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show subscription details for premium users
            if (isPremium && subscription.subscriptionExpiresAt != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Renewal Date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    _formatDate(subscription.subscriptionExpiresAt!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(subscription, theme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(subscription, theme).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(subscription),
                      style: TextStyle(
                        color: _getStatusColor(subscription, theme),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the usage statistics section
  Widget _buildUsageSection(
    BuildContext context,
    ThemeData theme,
    UsageStats usage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Usage',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Messages usage
        _buildUsageCard(
          context,
          theme,
          Icons.chat_bubble,
          'Messages',
          usage.messagesUsed,
          usage.messageLimit,
        ),

        const SizedBox(height: 12),

        // Voice minutes usage
        _buildUsageCard(
          context,
          theme,
          Icons.mic,
          'Voice Minutes',
          usage.voiceMinutesUsed,
          usage.voiceLimit,
        ),

        const SizedBox(height: 12),

        // Photos stored
        _buildUsageCard(
          context,
          theme,
          Icons.photo,
          'Photos Stored',
          usage.photosStored,
          usage.photoLimit,
        ),

        if (usage.resetTime != null) ...[
          const SizedBox(height: 12),
          Text(
            'Daily limits reset at midnight UTC',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Builds a single usage stat card with progress indicator
  Widget _buildUsageCard(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String label,
    int used,
    int? limit,
  ) {
    final hasLimit = limit != null && limit > 0;
    final percentage = hasLimit ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isLimitReached = hasLimit && used >= limit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  hasLimit ? '$used / $limit' : '$used',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isLimitReached
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: 8),
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
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Unlimited',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds action buttons for premium users
  Widget _buildPremiumActions(
    BuildContext context,
    ThemeData theme,
    SubscriptionStatus subscription,
  ) {
    final isCancelled = subscription.subscriptionStatus == 'CANCELLED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Subscription Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        if (!isCancelled) ...[
          // Cancel subscription button
          OutlinedButton.icon(
            onPressed: _isCancelling ? null : _handleCancelSubscription,
            icon: _isCancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Subscription'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),
        ] else ...[
          // Resubscribe button for cancelled subscriptions
          FilledButton.icon(
            onPressed: () {
              // Show paywall to restart subscription
              showPaywallModal(context);
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Resubscribe'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Restore purchases button
        TextButton.icon(
          onPressed: _isRestoring ? null : _handleRestorePurchases,
          icon: _isRestoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore),
          label: Text(_isRestoring ? 'Restoring...' : 'Restore Purchases'),
        ),
      ],
    );
  }

  /// Builds action buttons for free users
  Widget _buildFreeActions(
    BuildContext context,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upgrade to premium button
        FilledButton.icon(
          onPressed: () {
            showPaywallModal(context).then((upgraded) {
              if (upgraded == true) {
                // Refresh subscription status after successful upgrade
                ref.read(subscriptionProvider.notifier).refresh();
              }
            });
          },
          icon: const Icon(Icons.upgrade),
          label: const Text('Upgrade to Premium'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 12),

        // Restore purchases button
        TextButton.icon(
          onPressed: _isRestoring ? null : _handleRestorePurchases,
          icon: _isRestoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.restore),
          label: Text(_isRestoring ? 'Restoring...' : 'Restore Purchases'),
        ),
      ],
    );
  }

  /// Handles subscription cancellation
  Future<void> _handleCancelSubscription() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Your Premium access will continue until the end of your current billing period. '
          'After that, you\'ll be moved to the Free plan.\n\n'
          'Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Premium'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      // Call purchase service to cancel subscription
      final purchaseService = ref.read(purchaseServiceProvider);
      final cancelDate = await purchaseService.cancelSubscription();

      // Refresh subscription status
      await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cancelDate != null
                  ? 'Subscription cancelled. Access until ${_formatDate(cancelDate)}'
                  : 'Subscription cancelled successfully',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  /// Handles restore purchases
  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isRestoring = true;
    });

    try {
      // Call purchase service to restore purchases
      final purchaseService = ref.read(purchaseServiceProvider);
      final hasActiveSub = await purchaseService.restorePurchases();

      // Refresh subscription status
      await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hasActiveSub
                  ? '✅ Premium subscription restored!'
                  : 'No active subscriptions found',
            ),
            backgroundColor: hasActiveSub ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  /// Formats a date as a readable string
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Gets the status text based on subscription status
  String _getStatusText(SubscriptionStatus subscription) {
    switch (subscription.subscriptionStatus) {
      case 'ACTIVE':
        return 'Active';
      case 'TRIALING':
        return 'Trial';
      case 'CANCELLED':
        return 'Cancelled';
      case 'EXPIRED':
        return 'Expired';
      default:
        return subscription.subscriptionStatus;
    }
  }

  /// Gets the status color based on subscription status
  Color _getStatusColor(SubscriptionStatus subscription, ThemeData theme) {
    switch (subscription.subscriptionStatus) {
      case 'ACTIVE':
      case 'TRIALING':
        return Colors.green;
      case 'CANCELLED':
        return Colors.orange;
      case 'EXPIRED':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}
