/// Milestone list provider for managing milestone state.
/// Handles fetching, filtering, and CRUD operations for milestones.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/milestone_repository.dart';
import '../domain/milestone_model.dart';

/// Milestone list state model
class MilestoneListState {
  final List<Milestone> milestones;
  final bool isLoading;
  final bool hasError;
  final String? error;
  final MilestoneType? selectedFilter;

  const MilestoneListState({
    this.milestones = const [],
    this.isLoading = false,
    this.hasError = false,
    this.error,
    this.selectedFilter,
  });

  MilestoneListState copyWith({
    List<Milestone>? milestones,
    bool? isLoading,
    bool? hasError,
    String? error,
    MilestoneType? selectedFilter,
    bool clearFilter = false,
  }) {
    return MilestoneListState(
      milestones: milestones ?? this.milestones,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      error: error,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }
}

/// Milestone list state notifier
class MilestoneListNotifier extends StateNotifier<MilestoneListState> {
  final MilestoneRepository _milestoneRepository;

  MilestoneListNotifier(this._milestoneRepository)
      : super(const MilestoneListState());

  /// Loads all milestones for the user
  /// Optionally filters by milestone type
  Future<void> loadMilestones({MilestoneType? type}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      error: null,
      selectedFilter: type,
    );

    try {
      final response = await _milestoneRepository.fetchMilestones(
        type: type,
        confirmed: true, // Only show confirmed milestones
      );

      state = state.copyWith(
        milestones: response.milestones,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        error: e.toString(),
      );
    }
  }

  /// Refreshes milestone list (pull-to-refresh)
  /// Maintains current filter if set
  Future<void> refreshMilestones() async {
    await loadMilestones(type: state.selectedFilter);
  }

  /// Filters milestones by type
  /// Pass null to clear filter and show all milestones
  Future<void> filterByType(MilestoneType? type) async {
    await loadMilestones(type: type);
  }

  /// Clears filter and shows all milestones
  Future<void> clearFilter() async {
    await loadMilestones();
  }

  /// Creates a new milestone
  /// Adds it to the beginning of the list after creation
  Future<Milestone> createMilestone({
    required MilestoneType type,
    required String name,
    required DateTime achievedDate,
    String? notes,
    List<String>? photoUrls,
  }) async {
    try {
      final milestone = await _milestoneRepository.createMilestone(
        type: type,
        name: name,
        achievedDate: achievedDate,
        notes: notes,
        photoUrls: photoUrls,
      );

      // Add new milestone to the beginning of the list
      state = state.copyWith(
        milestones: [milestone, ...state.milestones],
      );

      return milestone;
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Updates an existing milestone
  /// Updates it in the list after successful update
  Future<Milestone> updateMilestone(
    String id, {
    String? name,
    DateTime? achievedDate,
    String? notes,
  }) async {
    try {
      final updatedMilestone = await _milestoneRepository.updateMilestone(
        id,
        name: name,
        achievedDate: achievedDate,
        notes: notes,
      );

      // Update milestone in the list
      state = state.copyWith(
        milestones: state.milestones.map((milestone) {
          if (milestone.id == id) {
            return updatedMilestone;
          }
          return milestone;
        }).toList(),
      );

      return updatedMilestone;
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Deletes a milestone by ID
  /// Removes it from the list after successful deletion
  Future<void> deleteMilestone(String milestoneId) async {
    try {
      await _milestoneRepository.deleteMilestone(milestoneId);

      // Remove milestone from state
      state = state.copyWith(
        milestones:
            state.milestones.where((m) => m.id != milestoneId).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        hasError: true,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Groups milestones by month for timeline view
  /// Returns a map of "Month Year" => List<Milestone>
  Map<String, List<Milestone>> getMilestonesGroupedByMonth() {
    final Map<String, List<Milestone>> grouped = {};

    for (final milestone in state.milestones) {
      // Format: "January 2025"
      final monthYear =
          '${_getMonthName(milestone.achievedDate.month)} ${milestone.achievedDate.year}';

      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(milestone);
    }

    return grouped;
  }

  /// Helper method to get month name from month number
  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}

/// Provider for milestone list state
final milestoneListProvider =
    StateNotifierProvider<MilestoneListNotifier, MilestoneListState>((ref) {
  return MilestoneListNotifier(ref.watch(milestoneRepositoryProvider));
});
