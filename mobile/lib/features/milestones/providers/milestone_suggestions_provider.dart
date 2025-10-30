/// Milestone suggestions provider for AI-generated milestone recommendations.
/// Handles fetching and caching age-appropriate milestone suggestions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/milestone_repository.dart';
import '../domain/milestone_model.dart';

/// Milestone suggestions state model
class MilestoneSuggestionsState {
  final List<MilestoneSuggestion> suggestions;
  final bool isLoading;
  final bool hasError;
  final String? error;

  const MilestoneSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.hasError = false,
    this.error,
  });

  MilestoneSuggestionsState copyWith({
    List<MilestoneSuggestion>? suggestions,
    bool? isLoading,
    bool? hasError,
    String? error,
  }) {
    return MilestoneSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      error: error,
    );
  }
}

/// Milestone suggestions state notifier
class MilestoneSuggestionsNotifier
    extends StateNotifier<MilestoneSuggestionsState> {
  final MilestoneRepository _milestoneRepository;

  MilestoneSuggestionsNotifier(this._milestoneRepository)
      : super(const MilestoneSuggestionsState());

  /// Loads AI-generated milestone suggestions based on baby's age.
  /// Backend automatically calculates baby age from profile and returns
  /// age-appropriate suggestions filtered by already-confirmed milestones.
  Future<void> loadSuggestions() async {
    // Prevent multiple simultaneous loads
    if (state.isLoading) return;

    // Set loading state
    state = state.copyWith(
      isLoading: true,
      hasError: false,
      error: null,
    );

    try {
      // Fetch suggestions from backend AI service
      final response = await _milestoneRepository.fetchMilestoneSuggestions();

      // Update state with fetched suggestions
      state = state.copyWith(
        suggestions: response.suggestions,
        isLoading: false,
      );
    } catch (e) {
      // Handle errors (network failures, API errors, etc.)
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        error: e.toString(),
      );
    }
  }

  /// Refreshes suggestions (pull-to-refresh or manual refresh).
  /// Clears existing suggestions and fetches new ones from backend.
  Future<void> refreshSuggestions() async {
    // Clear existing suggestions before refreshing
    state = state.copyWith(suggestions: []);
    await loadSuggestions();
  }

  /// Removes a suggestion from the list after user confirms it.
  /// Call this after successfully creating a milestone from a suggestion
  /// to prevent showing the same suggestion again.
  void removeSuggestion(MilestoneSuggestion suggestion) {
    state = state.copyWith(
      suggestions: state.suggestions
          .where((s) => s.name != suggestion.name || s.type != suggestion.type)
          .toList(),
    );
  }

  /// Gets suggestions filtered by a specific milestone type.
  /// Returns a new list containing only suggestions of the specified type.
  List<MilestoneSuggestion> getSuggestionsByType(MilestoneType type) {
    return state.suggestions.where((s) => s.type == type).toList();
  }
}

/// Provider for milestone suggestions state
final milestoneSuggestionsProvider = StateNotifierProvider<
    MilestoneSuggestionsNotifier, MilestoneSuggestionsState>((ref) {
  return MilestoneSuggestionsNotifier(ref.watch(milestoneRepositoryProvider));
});
