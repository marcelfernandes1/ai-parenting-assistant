/// Full-screen photo viewer with swipe navigation, zoom, and actions.
/// Supports delete, AI analysis, and downloading photos.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../domain/photo_model.dart';
import '../providers/photo_list_provider.dart';
import '../providers/photo_provider.dart';
import '../data/photo_repository.dart';

/// Full-screen photo viewer with swipe gestures
class PhotoViewerScreen extends ConsumerStatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

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

  /// Toggles overlay visibility
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  /// Deletes current photo with confirmation
  Future<void> _deletePhoto() async {
    final photo = widget.photos[_currentIndex];

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text(
          'This photo will be permanently deleted. This action cannot be undone.',
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

    if (confirmed != true || !mounted) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting photo...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Delete photo
      await ref.read(photoListProvider.notifier).deletePhoto(photo.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted'),
            duration: Duration(seconds: 2),
          ),
        );

        // Close viewer if this was the last photo, otherwise move to next/previous
        if (widget.photos.length == 1) {
          Navigator.of(context).pop();
        } else {
          // Remove photo from local list
          widget.photos.removeAt(_currentIndex);

          // Adjust current index if needed
          if (_currentIndex >= widget.photos.length) {
            _currentIndex = widget.photos.length - 1;
          }

          // Update page controller
          if (widget.photos.isNotEmpty) {
            _pageController.jumpToPage(_currentIndex);
          }

          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Shows AI analysis dialog with medical disclaimer first
  Future<void> _analyzePhoto() async {
    if (!mounted) return;

    final photo = widget.photos[_currentIndex];

    // Show medical disclaimer first
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical Disclaimer'),
        content: const SingleChildScrollView(
          child: Text(
            'This AI analysis is for informational purposes only '
            'and should not be considered medical advice.\n\n'
            'Always consult with a qualified healthcare provider '
            'for medical concerns.\n\n'
            'Proceed with AI analysis?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analyzing photo...'),
                SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Download photo to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/analysis_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final response = await http.get(Uri.parse(photo.url));
      await tempFile.writeAsBytes(response.bodyBytes);

      // Call repository to analyze photo
      final repository = ref.read(photoRepositoryProvider);
      final result = await repository.analyzePhoto(tempFile.path);

      // Clean up temp file
      await tempFile.delete();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show analysis result
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI Photo Analysis'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis text
                  Text(
                    result.analysis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Disclaimer
                  Text(
                    result.disclaimer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showOverlay
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _deletePhoto,
                  tooltip: 'Delete photo',
                ),
                // AI Analysis button
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  onPressed: _analyzePhoto,
                  tooltip: 'Analyze with AI',
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _toggleOverlay,
        child: Stack(
          children: [
            // Photo PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                return _buildPhotoView(photo);
              },
            ),

            // Bottom overlay with photo details
            if (_showOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildPhotoDetails(theme, widget.photos[_currentIndex]),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds interactive photo view with zoom
  Widget _buildPhotoView(Photo photo) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: photo.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load photo',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds photo details overlay
  Widget _buildPhotoDetails(ThemeData theme, Photo photo) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload date
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(photo.uploadedAt),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            // AI Analysis indicator (if analyzed)
            if (photo.analysisResults != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Analyzed',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
