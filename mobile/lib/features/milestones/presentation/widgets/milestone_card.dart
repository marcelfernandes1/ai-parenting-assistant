/// Milestone card widget for displaying individual milestones in lists.
/// Shows milestone name, type icon, date, and optional photo thumbnail.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/milestone_model.dart';

/// Card widget for displaying a milestone in list views
class MilestoneCard extends StatelessWidget {
  final Milestone milestone;
  final VoidCallback? onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Milestone type icon
              _buildTypeIcon(theme),
              const SizedBox(width: 12),
              // Milestone details (name, date, notes preview)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Milestone name
                    Text(
                      milestone.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date and type row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(milestone.achievedDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(theme).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            milestone.type.displayName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getTypeColor(theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Notes preview (if exists)
                    if (milestone.notes != null && milestone.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          milestone.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // AI suggested badge (if applicable)
                    if (milestone.aiSuggested)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Suggested',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Photo thumbnail (if photos exist)
              if (milestone.photoUrls.isNotEmpty) ...[
                const SizedBox(width: 12),
                _buildPhotoThumbnail(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the milestone type icon
  Widget _buildTypeIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTypeColor(theme).withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getTypeIcon(),
        size: 24,
        color: _getTypeColor(theme),
      ),
    );
  }

  /// Builds photo thumbnail (shows first photo if multiple)
  Widget _buildPhotoThumbnail(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: milestone.photoUrls.first,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: theme.colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: theme.colorScheme.onErrorContainer,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Gets the appropriate icon for the milestone type
  IconData _getTypeIcon() {
    switch (milestone.type) {
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

  /// Gets the theme color for the milestone type
  Color _getTypeColor(ThemeData theme) {
    switch (milestone.type) {
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
