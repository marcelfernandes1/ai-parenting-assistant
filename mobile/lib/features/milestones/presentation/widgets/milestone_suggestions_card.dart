/// Milestone suggestions card widget for displaying AI-powered recommendations.
/// Shows age-appropriate milestone suggestions with quick-add functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/milestone_model.dart';
import '../../providers/milestone_suggestions_provider.dart';
import '../../providers/milestone_list_provider.dart';
import '../add_milestone_screen.dart';

/// Card displaying AI-generated milestone suggestions
class MilestoneSuggestionsCard extends ConsumerStatefulWidget {
  const MilestoneSuggestionsCard({super.key});

  @override
  ConsumerState<MilestoneSuggestionsCard> createState() =>
      _MilestoneSuggestionsCardState();
}

class _MilestoneSuggestionsCardState
    extends ConsumerState<MilestoneSuggestionsCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Load suggestions when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(milestoneSuggestionsProvider.notifier).loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestionsState = ref.watch(milestoneSuggestionsProvider);

    // Don't show card if no suggestions
    if (suggestionsState.suggestions.isEmpty && !suggestionsState.isLoading) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with AI icon
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Milestone Suggestions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (suggestionsState.suggestions.isNotEmpty)
                          Text(
                            '${suggestionsState.suggestions.length} suggestions based on age',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            if (suggestionsState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (suggestionsState.hasError)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load suggestions: ${suggestionsState.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              )
            else
              ...suggestionsState.suggestions
                  .take(5)
                  .map((suggestion) => _buildSuggestionTile(
                        theme,
                        suggestion,
                      )),
          ],
        ],
      ),
    );
  }

  /// Builds individual suggestion tile
  Widget _buildSuggestionTile(
    ThemeData theme,
    MilestoneSuggestion suggestion,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTypeColor(suggestion.type).withOpacity(0.15),
        child: Icon(
          _getTypeIcon(suggestion.type),
          color: _getTypeColor(suggestion.type),
          size: 20,
        ),
      ),
      title: Text(
        suggestion.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            suggestion.description,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Typical age: ${suggestion.ageRangeMonths.min}-${suggestion.ageRangeMonths.max} months',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      trailing: FilledButton.tonalIcon(
        onPressed: () => _handleAddSuggestion(suggestion),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
        ),
      ),
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Handles adding a suggested milestone
  void _handleAddSuggestion(MilestoneSuggestion suggestion) {
    // Navigate to Add Milestone screen with pre-filled data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMilestoneScreen(
          // Pass suggestion data to pre-fill the form
          suggestedName: suggestion.name,
          suggestedType: suggestion.type,
        ),
      ),
    );

    // Remove this suggestion from the list after user navigates
    ref
        .read(milestoneSuggestionsProvider.notifier)
        .removeSuggestion(suggestion);
  }

  /// Gets icon for milestone type
  IconData _getTypeIcon(MilestoneType type) {
    switch (type) {
      case MilestoneType.physical:
        return Icons.directions_run;
      case MilestoneType.feeding:
        return Icons.restaurant;
      case MilestoneType.sleep:
        return Icons.bedtime;
      case MilestoneType.social:
        return Icons.people;
      case MilestoneType.health:
        return Icons.local_hospital;
    }
  }

  /// Gets color for milestone type
  Color _getTypeColor(MilestoneType type) {
    switch (type) {
      case MilestoneType.physical:
        return Colors.blue;
      case MilestoneType.feeding:
        return Colors.orange;
      case MilestoneType.sleep:
        return Colors.purple;
      case MilestoneType.social:
        return Colors.green;
      case MilestoneType.health:
        return Colors.red;
    }
  }
}
