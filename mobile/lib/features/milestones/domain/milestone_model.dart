/// Milestone domain models with Freezed for immutability and JSON serialization.
/// Represents milestone data from backend API responses for baby development tracking.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

// Generated file imports (will be created by build_runner)
part 'milestone_model.freezed.dart';
part 'milestone_model.g.dart';

/// Milestone type categories for baby development tracking.
/// Matches backend MilestoneType enum.
enum MilestoneType {
  /// Physical development (rolling over, crawling, walking, etc.)
  @JsonValue('PHYSICAL')
  physical,

  /// Feeding milestones (first solid food, self-feeding, etc.)
  @JsonValue('FEEDING')
  feeding,

  /// Sleep milestones (sleeping through night, nap schedule, etc.)
  @JsonValue('SLEEP')
  sleep,

  /// Social development (smiling, waving, playing, etc.)
  @JsonValue('SOCIAL')
  social,

  /// Health milestones (vaccinations, checkups, etc.)
  @JsonValue('HEALTH')
  health,
}

/// Extension for display names and icons for milestone types.
extension MilestoneTypeExtension on MilestoneType {
  /// User-friendly display name for the milestone type
  String get displayName {
    switch (this) {
      case MilestoneType.physical:
        return 'Physical';
      case MilestoneType.feeding:
        return 'Feeding';
      case MilestoneType.sleep:
        return 'Sleep';
      case MilestoneType.social:
        return 'Social';
      case MilestoneType.health:
        return 'Health';
    }
  }

  /// Icon name for the milestone type (Material Icons)
  String get iconName {
    switch (this) {
      case MilestoneType.physical:
        return 'directions_run'; // Running figure for physical
      case MilestoneType.feeding:
        return 'restaurant'; // Fork/knife for feeding
      case MilestoneType.sleep:
        return 'bedtime'; // Moon/bed for sleep
      case MilestoneType.social:
        return 'people'; // People for social
      case MilestoneType.health:
        return 'local_hospital'; // Medical cross for health
    }
  }
}

/// Immutable milestone data model using Freezed.
/// Represents a single milestone with achievement details.
@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    /// Unique milestone identifier from database
    required String id,

    /// Type of milestone (physical, feeding, sleep, social, health)
    required MilestoneType type,

    /// Name/title of the milestone
    required String name,

    /// Date the milestone was achieved
    required DateTime achievedDate,

    /// Optional notes from parent about the milestone
    String? notes,

    /// Array of photo URLs associated with this milestone
    @Default([]) List<String> photoUrls,

    /// Whether this milestone was suggested by AI
    @Default(false) bool aiSuggested,

    /// Whether user has confirmed this milestone
    @Default(true) bool confirmed,

    /// Timestamp when milestone was created
    required DateTime createdAt,

    /// Timestamp when milestone was last updated
    required DateTime updatedAt,
  }) = _Milestone;

  /// Factory constructor for creating Milestone from JSON
  /// Used when deserializing API responses
  factory Milestone.fromJson(Map<String, dynamic> json) =>
      _$MilestoneFromJson(json);
}

/// Response model for milestone list endpoint.
@freezed
class MilestoneListResponse with _$MilestoneListResponse {
  const factory MilestoneListResponse({
    /// List of milestones
    required List<Milestone> milestones,

    /// Total count of milestones for this query
    required int count,
  }) = _MilestoneListResponse;

  /// Factory constructor for creating MilestoneListResponse from JSON
  factory MilestoneListResponse.fromJson(Map<String, dynamic> json) =>
      _$MilestoneListResponseFromJson(json);
}

/// AI-generated milestone suggestion model.
/// Represents a suggested milestone that hasn't been saved yet.
@freezed
class MilestoneSuggestion with _$MilestoneSuggestion {
  const factory MilestoneSuggestion({
    /// Type of milestone (physical, feeding, sleep, social, health)
    required MilestoneType type,

    /// Name/title of the suggested milestone
    required String name,

    /// Description explaining what this milestone means
    required String description,

    /// Age range when this milestone typically occurs
    required AgeRange ageRangeMonths,

    /// Always true for suggestions
    @Default(true) bool aiSuggested,
  }) = _MilestoneSuggestion;

  /// Factory constructor for creating MilestoneSuggestion from JSON
  factory MilestoneSuggestion.fromJson(Map<String, dynamic> json) =>
      _$MilestoneSuggestionFromJson(json);
}

/// Age range for milestone suggestions.
@freezed
class AgeRange with _$AgeRange {
  const factory AgeRange({
    /// Minimum age in months when milestone typically occurs
    required int min,

    /// Maximum age in months when milestone typically occurs
    required int max,
  }) = _AgeRange;

  /// Factory constructor for creating AgeRange from JSON
  factory AgeRange.fromJson(Map<String, dynamic> json) =>
      _$AgeRangeFromJson(json);
}

/// Response model for milestone suggestions endpoint.
@freezed
class MilestoneSuggestionsResponse with _$MilestoneSuggestionsResponse {
  const factory MilestoneSuggestionsResponse({
    /// List of suggested milestones
    required List<MilestoneSuggestion> suggestions,

    /// Total count of suggestions
    required int count,
  }) = _MilestoneSuggestionsResponse;

  /// Factory constructor for creating MilestoneSuggestionsResponse from JSON
  factory MilestoneSuggestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$MilestoneSuggestionsResponseFromJson(json);
}
