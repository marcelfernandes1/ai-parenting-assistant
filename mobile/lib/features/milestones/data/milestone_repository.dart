/// Repository for milestone-related API operations.
/// Handles fetching, creating, updating, and deleting milestones via backend API.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_config.dart';
import '../domain/milestone_model.dart';

/// Provider for MilestoneRepository.
/// Makes repository available throughout the app via Riverpod.
final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MilestoneRepository(apiClient);
});

/// Repository class for milestone operations.
/// Encapsulates all milestone-related API calls.
class MilestoneRepository {
  final ApiClient _apiClient;

  MilestoneRepository(this._apiClient);

  /// Fetches all milestones for the authenticated user.
  ///
  /// Optional filters:
  /// - [type]: Filter by milestone type (PHYSICAL, FEEDING, etc.)
  /// - [confirmed]: Filter by confirmation status
  ///
  /// Returns [MilestoneListResponse] with array of milestones.
  /// Throws exception on API error.
  Future<MilestoneListResponse> fetchMilestones({
    MilestoneType? type,
    bool? confirmed,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      if (type != null) {
        queryParams['type'] = type.name.toUpperCase();
      }

      if (confirmed != null) {
        queryParams['confirmed'] = confirmed.toString();
      }

      // Make GET request to /milestones endpoint
      final response = await _apiClient.get(
        ApiConfig.milestonesListEndpoint,
        queryParameters: queryParams,
      );

      // Parse response and return milestone list
      return MilestoneListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch milestones: $e');
    }
  }

  /// Creates a new milestone.
  ///
  /// Required fields:
  /// - [type]: Milestone type
  /// - [name]: Milestone name
  /// - [achievedDate]: Date achieved
  ///
  /// Optional fields:
  /// - [notes]: Additional notes
  /// - [photoUrls]: Array of photo S3 keys
  /// - [confirmed]: Confirmation status (defaults to true)
  ///
  /// Returns created [Milestone] with generated ID.
  /// Throws exception on API error or validation failure.
  Future<Milestone> createMilestone({
    required MilestoneType type,
    required String name,
    required DateTime achievedDate,
    String? notes,
    List<String>? photoUrls,
    bool confirmed = true,
  }) async {
    try {
      // Build request body
      final requestBody = {
        'type': type.name.toUpperCase(),
        'name': name,
        'achievedDate': achievedDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (photoUrls != null && photoUrls.isNotEmpty) 'photoUrls': photoUrls,
        'confirmed': confirmed,
      };

      // Make POST request to /milestones endpoint
      final response = await _apiClient.post(
        ApiConfig.milestonesCreateEndpoint,
        data: requestBody,
      );

      // Parse response and return created milestone
      final milestoneData = response.data['milestone'] as Map<String, dynamic>;
      return Milestone.fromJson(milestoneData);
    } catch (e) {
      throw Exception('Failed to create milestone: $e');
    }
  }

  /// Updates an existing milestone.
  ///
  /// [id]: Milestone ID to update
  ///
  /// Optional fields (only provided fields will be updated):
  /// - [name]: New milestone name
  /// - [achievedDate]: New achieved date
  /// - [notes]: New notes
  ///
  /// Returns updated [Milestone].
  /// Throws exception on API error or if milestone not found.
  Future<Milestone> updateMilestone(
    String id, {
    String? name,
    DateTime? achievedDate,
    String? notes,
  }) async {
    try {
      // Build request body with only provided fields
      final requestBody = <String, dynamic>{};

      if (name != null) {
        requestBody['name'] = name;
      }

      if (achievedDate != null) {
        requestBody['achievedDate'] = achievedDate.toIso8601String();
      }

      if (notes != null) {
        requestBody['notes'] = notes;
      }

      // Make PUT request to /milestones/:id endpoint
      final response = await _apiClient.put(
        '${ApiConfig.milestonesUpdateEndpoint}/$id',
        data: requestBody,
      );

      // Parse response and return updated milestone
      final milestoneData = response.data['milestone'] as Map<String, dynamic>;
      return Milestone.fromJson(milestoneData);
    } catch (e) {
      throw Exception('Failed to update milestone: $e');
    }
  }

  /// Deletes a milestone.
  ///
  /// [id]: Milestone ID to delete
  ///
  /// Returns true if deletion successful.
  /// Throws exception on API error or if milestone not found.
  Future<bool> deleteMilestone(String id) async {
    try {
      // Make DELETE request to /milestones/:id endpoint
      final response = await _apiClient.delete(
        '${ApiConfig.milestonesDeleteEndpoint}/$id',
      );

      // Check if deletion was successful
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete milestone: $e');
    }
  }

  /// Fetches age-appropriate milestone suggestions from AI.
  ///
  /// Returns [MilestoneSuggestionsResponse] with array of suggestions.
  /// Suggestions are based on baby's age from user profile.
  /// Already-confirmed milestones are filtered out.
  ///
  /// Throws exception on API error or if baby birth date not set.
  Future<MilestoneSuggestionsResponse> fetchMilestoneSuggestions() async {
    try {
      // Make GET request to /milestones/suggestions endpoint
      final response = await _apiClient.get(
        ApiConfig.milestonesSuggestionsEndpoint,
      );

      // Parse response and return suggestions
      return MilestoneSuggestionsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch milestone suggestions: $e');
    }
  }
}
