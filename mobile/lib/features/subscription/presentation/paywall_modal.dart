/// Paywall modal shown when users hit FREE tier limits.
/// Displays premium features, pricing, and upgrade options.
/// Includes subscription purchase and restore purchase functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';
import '../domain/subscription_status.dart';

/// Shows the paywall modal as a bottom sheet
/// Returns true if user upgraded, false if dismissed
Future<bool?> showPaywallModal(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true, // Allow full-height modal
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const PaywallModal(),
  );
}

/// Paywall modal widget displaying premium features and purchase options
class PaywallModal extends ConsumerStatefulWidget {
  const PaywallModal({super.key});

  @override
  ConsumerState<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends ConsumerState<PaywallModal> {
  /// Whether a purchase is currently in progress
  bool _isPurchasing = false;

  /// Whether restore purchases is in progress
  bool _isRestoring = false;

  /// Error message to display if purchase/restore fails
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    // Get current usage stats for display
    final usageStats = subscriptionAsync.when(
      data: (subscription) => subscription.usage,
      loading: () => null,
      error: (_, __) => null,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Current usage display (if available)
              if (usageStats != null) ...[
                _buildUsageCard(theme, usageStats),
                const SizedBox(height: 24),
              ],

              // Premium features list
              Text(
                'Unlock Premium Features',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              _buildFeatureItem(
                context,
                Icons.chat_bubble,
                'Unlimited Messages',
                'Send as many messages as you want, no daily limits',
              ),
              _buildFeatureItem(
                context,
                Icons.mic,
                'Unlimited Voice Messages',
                'Record unlimited voice messages and conversations',
              ),
              _buildFeatureItem(
                context,
                Icons.photo_library,
                'Unlimited Photo Storage',
                'Store unlimited baby photos and memories',
              ),
              _buildFeatureItem(
                context,
                Icons.access_time,
                'Priority Support',
                'Get faster responses and priority assistance',
              ),
              _buildFeatureItem(
                context,
                Icons.auto_awesome,
                'Early Access',
                'Be the first to try new features and improvements',
              ),

              const SizedBox(height: 24),

              // Pricing display
              _buildPricingCard(theme),

              const SizedBox(height: 24),

              // Error message display
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
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
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Subscribe button
              FilledButton(
                onPressed: _isPurchasing || _isRestoring ? null : _handleSubscribe,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPurchasing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Start Premium Trial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Restore purchases button
              OutlinedButton(
                onPressed: _isPurchasing || _isRestoring ? null : _handleRestore,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRestoring
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Restore Purchases'),
              ),

              const SizedBox(height: 16),

              // Terms and privacy
              Text(
                'By subscribing, you agree to our Terms of Service and Privacy Policy. '
                'Subscription automatically renews unless cancelled 24 hours before the end of the period.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card displaying current usage stats
  Widget _buildUsageCard(ThemeData theme, UsageStats usage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Current Usage',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildUsageRow(
            theme,
            Icons.chat_bubble,
            'Messages',
            usage.messagesUsed,
            usage.messageLimit ?? 0,
          ),
          _buildUsageRow(
            theme,
            Icons.mic,
            'Voice Minutes',
            usage.voiceMinutesUsed,
            usage.voiceLimit ?? 0,
          ),
          _buildUsageRow(
            theme,
            Icons.photo,
            'Photos',
            usage.photosStored,
            usage.photoLimit ?? 0,
          ),
        ],
      ),
    );
  }

  /// Builds a single usage stat row with progress bar
  Widget _buildUsageRow(
    ThemeData theme,
    IconData icon,
    String label,
    int used,
    int limit,
  ) {
    final percentage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isLimitReached = used >= limit && limit > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      limit > 0 ? '$used / $limit' : '$used',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLimitReached
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight:
                            isLimitReached ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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
                      minHeight: 6,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a feature list item with icon and description
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the pricing information card
  Widget _buildPricingCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$4.99',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '/ month',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '7-day free trial',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cancel anytime',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the subscribe button tap
  /// TODO: Integrate with in_app_purchase package
  Future<void> _handleSubscribe() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual in-app purchase flow
      // For now, just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Call backend to verify purchase and update subscription
      // await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase flow not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process purchase. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  /// Handles the restore purchases button tap
  /// TODO: Integrate with in_app_purchase package
  Future<void> _handleRestore() async {
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual restore purchases flow
      // For now, just simulate a delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Refresh subscription status from backend
      // await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore purchases flow not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to restore purchases. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }
}
