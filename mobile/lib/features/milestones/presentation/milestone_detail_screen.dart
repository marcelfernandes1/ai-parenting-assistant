/// Milestone detail screen showing full milestone information.
/// Displays milestone name, type, date, notes, and photo carousel.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../domain/milestone_model.dart';
import '../providers/milestone_list_provider.dart';
import 'edit_milestone_screen.dart';

/// Full-screen milestone detail view
class MilestoneDetailScreen extends ConsumerStatefulWidget {
  final Milestone milestone;

  const MilestoneDetailScreen({
    super.key,
    required this.milestone,
  });

  @override
  ConsumerState<MilestoneDetailScreen> createState() =>
      _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState
    extends ConsumerState<MilestoneDetailScreen> {
  bool _isDeleting = false;

  /// Navigates to edit screen
  void _navigateToEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditMilestoneScreen(milestone: widget.milestone),
      ),
    );
  }

  /// Handles delete with confirmation
  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Milestone'),
        content: Text(
          'Are you sure you want to delete "${widget.milestone.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref
          .read(milestoneListProvider.notifier)
          .deleteMilestone(widget.milestone.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Milestone deleted'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to milestones list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone Details'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            onPressed: _isDeleting ? null : _navigateToEdit,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit milestone',
          ),
          // Delete button
          IconButton(
            onPressed: _isDeleting ? null : _handleDelete,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            tooltip: 'Delete milestone',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type header banner
            _buildTypeHeader(theme),

            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Milestone name
                  Text(
                    widget.milestone.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date achieved
                  _buildInfoRow(
                    theme,
                    icon: Icons.calendar_today,
                    label: 'Achieved',
                    value: DateFormat('MMMM d, yyyy')
                        .format(widget.milestone.achievedDate),
                  ),
                  const SizedBox(height: 12),

                  // Created date
                  _buildInfoRow(
                    theme,
                    icon: Icons.access_time,
                    label: 'Recorded',
                    value:
                        DateFormat('MMM d, yyyy').format(widget.milestone.createdAt),
                  ),
                  const SizedBox(height: 12),

                  // AI suggested badge
                  if (widget.milestone.aiSuggested)
                    _buildInfoRow(
                      theme,
                      icon: Icons.auto_awesome,
                      label: 'Suggested by AI',
                      value: '',
                      isSpecial: true,
                    ),

                  // Notes section
                  if (widget.milestone.notes != null &&
                      widget.milestone.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.milestone.notes!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],

                  // Photos section
                  if (widget.milestone.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Photos (${widget.milestone.photoUrls.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoCarousel(theme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the colored type header banner
  Widget _buildTypeHeader(ThemeData theme) {
    final typeColor = _getTypeColor(widget.milestone.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: typeColor.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(widget.milestone.type),
              size: 28,
              color: typeColor,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Milestone Type',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.milestone.type.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an info row with icon and label
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    bool isSpecial = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSpecial
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds horizontal scrollable photo carousel
  Widget _buildPhotoCarousel(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.milestone.photoUrls.length,
        itemBuilder: (context, index) {
          final photoUrl = widget.milestone.photoUrls[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < widget.milestone.photoUrls.length - 1 ? 12 : 0,
            ),
            child: _buildPhotoCard(theme, photoUrl, index),
          );
        },
      ),
    );
  }

  /// Builds individual photo card
  Widget _buildPhotoCard(ThemeData theme, String photoUrl, int index) {
    return GestureDetector(
      onTap: () => _openPhotoViewer(index),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.errorContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onErrorContainer,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens photo viewer in full-screen
  void _openPhotoViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoViewerScreen(
          photoUrls: widget.milestone.photoUrls,
          initialIndex: initialIndex,
          milestoneName: widget.milestone.name,
        ),
      ),
    );
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

/// Simple photo viewer for milestone photos
class _PhotoViewerScreen extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String milestoneName;

  const _PhotoViewerScreen({
    required this.photoUrls,
    required this.initialIndex,
    required this.milestoneName,
  });

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.milestoneName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_currentIndex + 1} of ${widget.photoUrls.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
