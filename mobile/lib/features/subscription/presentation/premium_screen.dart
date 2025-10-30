/// Premium Screen - Full-page subscription upgrade screen
/// Displays premium features, pricing, and subscription management
/// Similar to paywall modal but as a navigable screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_provider.dart';
import '../data/purchase_service.dart';
import '../domain/subscription_status.dart';

/// Full-page premium screen for subscription management
/// Shows features, pricing, and allows upgrade/management
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: subscriptionAsync.when(
        data: (subscription) {
          final isPremium = subscription.isPremium;
          final usage = subscription.usage;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium status banner
                _buildStatusBanner(theme, isPremium),

                // Current usage display (for free users)
                if (!isPremium && usage != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildUsageCard(theme, usage),
                  ),
                ],

                // Premium features list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? 'Your Premium Features' : 'Unlock Premium Features',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                    ],
                  ),
                ),

                // Pricing and subscribe section (only for free users)
                if (!isPremium) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
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
                ],

                // Subscription management section (only for premium users)
                if (isPremium) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Subscription',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text('Subscription Settings'),
                          subtitle: const Text('Manage your subscription'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Navigate to subscription management
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Subscription management coming soon'),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.receipt),
                          title: const Text('Billing History'),
                          subtitle: const Text('View your invoices'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Navigate to billing history
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Billing history coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                  'Error loading subscription',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ref.invalidate(subscriptionProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build premium status banner
  Widget _buildStatusBanner(ThemeData theme, bool isPremium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ]
              : [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPremium ? Icons.star : Icons.star_outline,
            size: 64,
            color: isPremium
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            isPremium ? 'Premium Active' : 'Upgrade to Premium',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPremium
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPremium
                ? 'You have full access to all features'
                : 'Get unlimited access to all features',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isPremium
                  ? theme.colorScheme.onPrimary.withOpacity(0.9)
                  : theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds a card displaying current usage stats
  Widget _buildUsageCard(ThemeData theme, UsageStats usage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Current Usage (Free Tier)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUsageRow(
            theme,
            Icons.chat_bubble,
            'Messages',
            usage.messagesUsed,
            usage.messageLimit ?? 0,
          ),
          const SizedBox(height: 8),
          _buildUsageRow(
            theme,
            Icons.mic,
            'Voice Minutes',
            usage.voiceMinutesUsed,
            usage.voiceLimit ?? 0,
          ),
          const SizedBox(height: 8),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              limit > 0 ? '$used / $limit' : '$used',
              style: theme.textTheme.bodyLarge?.copyWith(
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
            borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 28,
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '/ month',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '7-day free trial',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cancel anytime',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the subscribe button tap
  Future<void> _handleSubscribe() async {
    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      await purchaseService.purchaseSubscription(
        priceId: PurchaseService.monthlyPriceId,
      );

      await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome to Premium!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        if (errorMessage.contains('Stripe') || errorMessage.contains('publishable')) {
          _errorMessage =
              'Stripe payment not set up yet. Please configure Stripe in main.dart.';
        } else {
          _errorMessage = errorMessage;
        }
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
  Future<void> _handleRestore() async {
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final hasActiveSub = await purchaseService.restorePurchases();
      await ref.read(subscriptionProvider.notifier).refresh();

      if (mounted) {
        if (hasActiveSub) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Premium subscription restored!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active subscriptions found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
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
