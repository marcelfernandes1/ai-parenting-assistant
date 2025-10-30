/// Subscription provider using Riverpod AsyncNotifier.
/// Manages subscription status and usage statistics.
/// Provides methods to fetch and refresh subscription data from backend.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/service_providers.dart';
import '../data/subscription_repository.dart';
import '../data/purchase_service.dart';
import '../domain/subscription_status.dart';

/// Provider for SubscriptionRepository singleton
/// Depends on ApiClient from shared service providers
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(
    ref.watch(apiClientProvider),
  );
});

/// Provider for PurchaseService singleton
/// Handles Stripe subscription purchases and management
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService(
    ref.watch(subscriptionRepositoryProvider),
  );
});

/// AsyncNotifier for managing subscription status
/// Handles fetching, caching, and refreshing subscription data
class SubscriptionNotifier extends AsyncNotifier<SubscriptionStatus> {
  /// Builds initial subscription status by fetching from backend
  /// Called automatically when provider is first accessed
  @override
  Future<SubscriptionStatus> build() async {
    // Fetch subscription status from repository
    return await _fetchSubscriptionStatus();
  }

  /// Private method to fetch subscription status from repository
  /// Handles errors and returns subscription data
  Future<SubscriptionStatus> _fetchSubscriptionStatus() async {
    final repository = ref.read(subscriptionRepositoryProvider);
    return await repository.getSubscriptionStatus();
  }

  /// Refreshes subscription status from backend
  /// Call this after purchases, cancellations, or when user returns to app
  /// Updates state with loading indicator during fetch
  Future<void> refresh() async {
    // Set loading state while fetching
    state = const AsyncValue.loading();

    // Fetch new data and update state
    state = await AsyncValue.guard(() async {
      return await _fetchSubscriptionStatus();
    });
  }

  /// Manually update subscription status (useful after in-app purchase)
  /// This allows immediate UI update without waiting for backend refresh
  void updateStatus(SubscriptionStatus newStatus) {
    state = AsyncValue.data(newStatus);
  }
}

/// Main subscription provider
/// Watch this to get current subscription status and usage statistics
/// Returns AsyncValue<SubscriptionStatus> with loading/error/data states
final subscriptionProvider =
    AsyncNotifierProvider<SubscriptionNotifier, SubscriptionStatus>(() {
  return SubscriptionNotifier();
});

/// Convenience provider to check if user has premium subscription
/// Returns true if PREMIUM tier, false otherwise
/// Handles loading/error states by returning false (safe default)
final isPremiumProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) => subscription.isPremium,
    loading: () => false, // Default to free during loading
    error: (_, __) => false, // Default to free on error
  );
});

/// Convenience provider to check if user is on free tier
/// Returns true if FREE tier, false otherwise
final isFreeProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) => subscription.isFree,
    loading: () => true, // Default to free during loading
    error: (_, __) => true, // Default to free on error
  );
});

/// Convenience provider to get usage statistics
/// Returns null during loading or error states
final usageStatsProvider = Provider<UsageStats?>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (subscription) => subscription.usage,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Convenience provider to check if message limit has been reached
/// Used to show paywall when user tries to send message
final messageLimitReachedProvider = Provider<bool>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return false; // No limit if no usage data
  return usage.messageLimitReached;
});

/// Convenience provider to check if voice limit has been reached
/// Used to show paywall when user tries to record voice message
final voiceLimitReachedProvider = Provider<bool>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return false; // No limit if no usage data
  return usage.voiceLimitReached;
});

/// Convenience provider to check if photo limit has been reached
/// Used to show paywall when user tries to upload photo
final photoLimitReachedProvider = Provider<bool>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return false; // No limit if no usage data
  return usage.photoLimitReached;
});

/// Convenience provider to get remaining messages for today
/// Returns -1 for unlimited, 0+ for remaining count
final messagesRemainingProvider = Provider<int>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return -1; // Unlimited if no usage data
  return usage.messagesRemaining;
});

/// Convenience provider to get remaining voice minutes for today
/// Returns -1 for unlimited, 0+ for remaining count
final voiceMinutesRemainingProvider = Provider<int>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return -1; // Unlimited if no usage data
  return usage.voiceMinutesRemaining;
});

/// Convenience provider to get remaining photo storage slots
/// Returns -1 for unlimited, 0+ for remaining count
final photosRemainingProvider = Provider<int>((ref) {
  final usage = ref.watch(usageStatsProvider);
  if (usage == null) return -1; // Unlimited if no usage data
  return usage.photosRemaining;
});
