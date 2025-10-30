/// Milestones screen displaying baby's developmental milestones.
/// Supports two view modes: Timeline (chronological) and Categories (filtered by type).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/milestone_list_provider.dart';
import '../domain/milestone_model.dart';
import 'widgets/milestone_card.dart';
import 'widgets/category_filter.dart';
import 'add_milestone_screen.dart';
import 'milestone_detail_screen.dart';

/// View mode enum for toggle button
enum MilestoneViewMode {
  timeline,
  categories,
}

/// Main milestones screen with Timeline and Categories views
class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({super.key});

  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  /// Current view mode (Timeline or Categories)
  MilestoneViewMode _viewMode = MilestoneViewMode.timeline;

  /// Selected category filter (null = all categories)
  MilestoneType? _selectedCategory;

  @override
  void initState() {
    super.initState();

    // Load milestones on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(milestoneListProvider.notifier).loadMilestones();
    });
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await ref.read(milestoneListProvider.notifier).refreshMilestones();
  }

  /// Handles category filter selection
  void _onCategorySelected(MilestoneType? category) {
    setState(() {
      _selectedCategory = category;
    });
    // Load milestones with filter
    ref.read(milestoneListProvider.notifier).filterByType(category);
  }

  /// Navigates to Add Milestone screen
  void _navigateToAddMilestone() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMilestoneScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final milestoneState = ref.watch(milestoneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // View mode toggle button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<MilestoneViewMode>(
              segments: const [
                ButtonSegment(
                  value: MilestoneViewMode.timeline,
                  icon: Icon(Icons.timeline, size: 18),
                  label: Text('Timeline'),
                ),
                ButtonSegment(
                  value: MilestoneViewMode.categories,
                  icon: Icon(Icons.category, size: 18),
                  label: Text('Categories'),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (Set<MilestoneViewMode> newSelection) {
                setState(() {
                  _viewMode = newSelection.first;
                  // Reset filter when switching to timeline view
                  if (_viewMode == MilestoneViewMode.timeline) {
                    _selectedCategory = null;
                    ref.read(milestoneListProvider.notifier).clearFilter();
                  }
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: milestoneState.isLoading && milestoneState.milestones.isEmpty
            ? _buildLoadingState(theme)
            : milestoneState.hasError && milestoneState.milestones.isEmpty
                ? _buildErrorState(theme, milestoneState.error!)
                : milestoneState.milestones.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildContent(theme, milestoneState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddMilestone,
        icon: const Icon(Icons.add),
        label: const Text('Add Milestone'),
      ),
    );
  }

  /// Builds the main content based on view mode
  Widget _buildContent(ThemeData theme, MilestoneListState milestoneState) {
    if (_viewMode == MilestoneViewMode.timeline) {
      return _buildTimelineView(theme, milestoneState);
    } else {
      return _buildCategoriesView(theme, milestoneState);
    }
  }

  /// Builds Timeline view (grouped by month)
  Widget _buildTimelineView(ThemeData theme, MilestoneListState milestoneState) {
    // Get milestones grouped by month
    final groupedMilestones = ref
        .read(milestoneListProvider.notifier)
        .getMilestonesGroupedByMonth();

    // Sort month keys in descending order (newest first)
    final sortedMonths = groupedMilestones.keys.toList()
      ..sort((a, b) {
        // Parse "Month Year" format and compare
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88), // Space for FAB
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final monthYear = sortedMonths[index];
        final milestones = groupedMilestones[monthYear]!;

        return _buildTimelineGroup(theme, monthYear, milestones);
      },
    );
  }

  /// Builds a timeline group (month header + milestones)
  Widget _buildTimelineGroup(
    ThemeData theme,
    String monthYear,
    List<Milestone> milestones,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          child: Text(
            monthYear,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        // Milestones in this month
        ...milestones.map((milestone) => MilestoneCard(
              milestone: milestone,
              onTap: () => _navigateToMilestoneDetail(milestone),
            )),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds Categories view (with filter tabs)
  Widget _buildCategoriesView(
      ThemeData theme, MilestoneListState milestoneState) {
    return Column(
      children: [
        // Category filter tabs
        CategoryFilter(
          selectedCategory: _selectedCategory,
          onCategorySelected: _onCategorySelected,
        ),
        // Filtered milestones list
        Expanded(
          child: milestoneState.milestones.isEmpty
              ? _buildEmptyFilterState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88), // Space for FAB
                  itemCount: milestoneState.milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = milestoneState.milestones[index];
                    return MilestoneCard(
                      milestone: milestone,
                      onTap: () => _navigateToMilestoneDetail(milestone),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Builds loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading milestones...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Failed to load milestones',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(milestoneListProvider.notifier).loadMilestones(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state when no milestones exist
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No milestones yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your baby\'s developmental milestones',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _navigateToAddMilestone,
              icon: const Icon(Icons.add),
              label: const Text('Add First Milestone'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state when filter returns no results
  Widget _buildEmptyFilterState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No milestones in this category',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category or add a new milestone',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to milestone detail screen
  void _navigateToMilestoneDetail(Milestone milestone) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(milestone: milestone),
      ),
    );
  }
}
