/// Category filter widget for filtering milestones by type.
/// Displays horizontal scrollable chips for each milestone category.
library;

import 'package:flutter/material.dart';
import '../../domain/milestone_model.dart';

/// Horizontal scrollable filter for milestone categories
class CategoryFilter extends StatelessWidget {
  final MilestoneType? selectedCategory;
  final Function(MilestoneType?) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // "All" filter chip
          _buildFilterChip(
            context,
            label: 'All',
            icon: Icons.grid_view,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          // Physical category chip
          _buildFilterChip(
            context,
            label: MilestoneType.physical.displayName,
            icon: Icons.directions_run,
            isSelected: selectedCategory == MilestoneType.physical,
            onTap: () => onCategorySelected(MilestoneType.physical),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          // Feeding category chip
          _buildFilterChip(
            context,
            label: MilestoneType.feeding.displayName,
            icon: Icons.restaurant,
            isSelected: selectedCategory == MilestoneType.feeding,
            onTap: () => onCategorySelected(MilestoneType.feeding),
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          // Sleep category chip
          _buildFilterChip(
            context,
            label: MilestoneType.sleep.displayName,
            icon: Icons.bedtime,
            isSelected: selectedCategory == MilestoneType.sleep,
            onTap: () => onCategorySelected(MilestoneType.sleep),
            color: Colors.purple,
          ),
          const SizedBox(width: 8),
          // Social category chip
          _buildFilterChip(
            context,
            label: MilestoneType.social.displayName,
            icon: Icons.people,
            isSelected: selectedCategory == MilestoneType.social,
            onTap: () => onCategorySelected(MilestoneType.social),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          // Health category chip
          _buildFilterChip(
            context,
            label: MilestoneType.health.displayName,
            icon: Icons.local_hospital,
            isSelected: selectedCategory == MilestoneType.health,
            onTap: () => onCategorySelected(MilestoneType.health),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  /// Builds individual filter chip
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
