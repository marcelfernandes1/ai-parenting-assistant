/// User model with Freezed for immutability and JSON serialization.
/// Represents the authenticated user's data from the backend.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

// Generated file import (will be created by build_runner)
part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Immutable user data model using Freezed.
/// Contains all user information received from authentication endpoints.
@freezed
class User with _$User {
  const factory User({
    /// Unique user identifier from database
    required String id,

    /// User's email address (used for login) - optional as profile endpoint doesn't return it
    String? email,

    /// Optional user display name
    String? name,

    /// User's subscription tier (FREE or PREMIUM)
    @Default('FREE') String subscriptionTier,

    /// Whether user has completed onboarding
    @Default(false) bool onboardingComplete,

    /// User profile mode (PREGNANCY or PARENT)
    String? mode,

    /// Baby's name (if provided during onboarding)
    String? babyName,

    /// Baby's birth date or due date (ISO string)
    String? babyBirthDate,

    /// User's parenting philosophy preferences
    String? parentingPhilosophy,

    /// User's religious/cultural background
    String? religiousViews,

    /// User's primary concerns as a parent
    List<String>? primaryConcerns,

    /// Profile creation timestamp
    DateTime? createdAt,

    /// Last profile update timestamp
    DateTime? updatedAt,
  }) = _User;

  /// Factory constructor for creating User from JSON
  /// Used when deserializing API responses
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
