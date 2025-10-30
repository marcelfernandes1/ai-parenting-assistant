/// Photos screen displaying user's photo gallery in a grid layout.
/// Supports infinite scroll, pull-to-refresh, and photo viewing.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/photo_list_provider.dart';
import '../domain/photo_model.dart';
import 'photo_viewer_screen.dart';

/// Main photos gallery screen
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load photos on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoListProvider.notifier).loadPhotos();
    });

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events for infinite loading
  void _onScroll() {
    // Check if scrolled near bottom (within 200px)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more photos
      ref.read(photoListProvider.notifier).loadMorePhotos();
    }
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    await ref.read(photoListProvider.notifier).refreshPhotos();
  }

  /// Opens photo viewer in full-screen modal
  void _openPhotoViewer(BuildContext context, List<Photo> photos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoState = ref.watch(photoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Photo count badge
          if (photoState.photos.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${photoState.photos.length} photo${photoState.photos.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: photoState.isLoading && photoState.photos.isEmpty
            ? _buildLoadingState(theme)
            : photoState.error != null && photoState.photos.isEmpty
                ? _buildErrorState(theme, photoState.error!)
                : photoState.photos.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildPhotoGrid(theme, photoState),
      ),
    );
  }

  /// Builds loading state with shimmer effect
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
            'Loading photos...',
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
              'Failed to load photos',
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
              onPressed: () => ref.read(photoListProvider.notifier).loadPhotos(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state when no photos exist
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No photos yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos in chat to see them here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate back to chat screen
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.chat),
              label: const Text('Go to Chat'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds photo grid with 3 columns
  Widget _buildPhotoGrid(ThemeData theme, PhotoListState photoState) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemCount: photoState.photos.length + (photoState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end when loading more
        if (index == photoState.photos.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final photo = photoState.photos[index];
        return _buildPhotoThumbnail(theme, photo, index, photoState.photos);
      },
    );
  }

  /// Builds individual photo thumbnail
  Widget _buildPhotoThumbnail(
    ThemeData theme,
    Photo photo,
    int index,
    List<Photo> allPhotos,
  ) {
    return GestureDetector(
      onTap: () => _openPhotoViewer(context, allPhotos, index),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CachedNetworkImage(
            imageUrl: photo.url,
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
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
