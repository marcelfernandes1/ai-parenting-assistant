/// Subscription status model with Freezed for immutability and JSON serialization.
/// Represents the user's subscription data from the backend.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

// Generated file imports (will be created by build_runner)
part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

/// Immutable subscription status model using Freezed.
/// Contains subscription tier, status, and usage information from backend.
@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const SubscriptionStatus._();

  const factory SubscriptionStatus({
    /// User's subscription tier (FREE or PREMIUM)
    required String subscriptionTier,

    /// Current subscription status (ACTIVE, CANCELLED, EXPIRED, TRIALING)
    required String subscriptionStatus,

    /// When the subscription expires (null for FREE or unlimited)
    DateTime? subscriptionExpiresAt,

    /// Stripe customer ID (null for FREE users)
    String? stripeCustomerId,

    /// Stripe subscription ID (null for FREE users)
    String? stripeSubscriptionId,

    /// Usage statistics for the current period
    UsageStats? usage,
  }) = _SubscriptionStatus;

  /// Create SubscriptionStatus from JSON
  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);

  /// Check if user has premium/unlimited access
  bool get isPremium => subscriptionTier == 'PREMIUM';

  /// Check if user is on free tier
  bool get isFree => subscriptionTier == 'FREE';

  /// Check if subscription is active
  bool get isActive => subscriptionStatus == 'ACTIVE' || subscriptionStatus == 'TRIALING';

  /// Check if subscription is cancelled but still valid
  bool get isCancelled => subscriptionStatus == 'CANCELLED';

  /// Check if subscription has expired
  bool get isExpired => subscriptionStatus == 'EXPIRED';

  /// Get days remaining until subscription expires (null if FREE or unlimited)
  int? get daysRemaining {
    if (subscriptionExpiresAt == null) return null;
    final diff = subscriptionExpiresAt!.difference(DateTime.now());
    return diff.inDays;
  }
}

/// Usage statistics model for tracking daily usage.
/// Contains counters for messages, voice minutes, and photos.
@freezed
class UsageStats with _$UsageStats {
  const UsageStats._();

  const factory UsageStats({
    /// Number of messages used today
    @Default(0) int messagesUsed,

    /// Number of voice minutes used today
    @Default(0) int voiceMinutesUsed,

    /// Total number of photos stored
    @Default(0) int photosStored,

    /// Message limit for current tier (10 for FREE, null/unlimited for PREMIUM)
    int? messageLimit,

    /// Voice minutes limit for current tier (10 for FREE, null/unlimited for PREMIUM)
    int? voiceLimit,

    /// Photo storage limit for current tier (100 for FREE, null/unlimited for PREMIUM)
    int? photoLimit,

    /// When the daily usage counters reset (midnight UTC)
    DateTime? resetTime,
  }) = _UsageStats;

  /// Create UsageStats from JSON
  factory UsageStats.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsFromJson(json);

  /// Check if message limit has been reached
  bool get messageLimitReached {
    if (messageLimit == null) return false; // Unlimited
    return messagesUsed >= messageLimit!;
  }

  /// Check if voice limit has been reached
  bool get voiceLimitReached {
    if (voiceLimit == null) return false; // Unlimited
    return voiceMinutesUsed >= voiceLimit!;
  }

  /// Check if photo storage limit has been reached
  bool get photoLimitReached {
    if (photoLimit == null) return false; // Unlimited
    return photosStored >= photoLimit!;
  }

  /// Get remaining messages for today
  int get messagesRemaining {
    if (messageLimit == null) return -1; // Unlimited (-1 indicator)
    return (messageLimit! - messagesUsed).clamp(0, messageLimit!);
  }

  /// Get remaining voice minutes for today
  int get voiceMinutesRemaining {
    if (voiceLimit == null) return -1; // Unlimited (-1 indicator)
    return (voiceLimit! - voiceMinutesUsed).clamp(0, voiceLimit!);
  }

  /// Get remaining photo storage slots
  int get photosRemaining {
    if (photoLimit == null) return -1; // Unlimited (-1 indicator)
    return (photoLimit! - photosStored).clamp(0, photoLimit!);
  }

  /// Get usage percentage for messages (0.0 to 1.0)
  double get messageUsagePercentage {
    if (messageLimit == null) return 0.0; // Unlimited shows 0%
    return (messagesUsed / messageLimit!).clamp(0.0, 1.0);
  }

  /// Get usage percentage for voice (0.0 to 1.0)
  double get voiceUsagePercentage {
    if (voiceLimit == null) return 0.0; // Unlimited shows 0%
    return (voiceMinutesUsed / voiceLimit!).clamp(0.0, 1.0);
  }

  /// Get usage percentage for photos (0.0 to 1.0)
  double get photoUsagePercentage {
    if (photoLimit == null) return 0.0; // Unlimited shows 0%
    return (photosStored / photoLimit!).clamp(0.0, 1.0);
  }
}
