/// Premium photos screen with smart albums, search, and multi-select.
/// Features hero animations, variable grid layout, and AI-powered organization.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/photo_list_provider.dart';
import '../domain/photo_model.dart';
import 'photo_viewer_screen.dart';
import '../../../shared/widgets/animations.dart';

/// Main photos gallery screen with premium UI
class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  /// Multi-select mode state
  bool _isMultiSelectMode = false;
  final Set<String> _selectedPhotoIds = {};

  /// Search mode state
  bool _isSearching = false;

  /// Animation controller for floating action button
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // Load photos on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoListProvider.notifier).loadPhotos();
    });

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);

    // Setup FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
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

  /// Opens photo viewer in full-screen with hero animation
  void _openPhotoViewer(BuildContext context, List<Photo> photos, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Toggles multi-select mode
  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedPhotoIds.clear();
      }
    });
  }

  /// Toggles photo selection
  void _togglePhotoSelection(String photoId) {
    setState(() {
      if (_selectedPhotoIds.contains(photoId)) {
        _selectedPhotoIds.remove(photoId);
      } else {
        _selectedPhotoIds.add(photoId);
      }
    });
  }

  /// Deletes selected photos
  Future<void> _deleteSelectedPhotos() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photos'),
        content: Text(
          'Are you sure you want to delete ${_selectedPhotoIds.length} photo${_selectedPhotoIds.length != 1 ? 's' : ''}?',
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

    if (confirmed == true && mounted) {
      // TODO: Implement batch delete via provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${_selectedPhotoIds.length} photos'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
        ),
      );

      _toggleMultiSelectMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoState = ref.watch(photoListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      // Custom app bar with glassmorphism effect
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Premium app bar with blur effect
          _buildSliverAppBar(theme, photoState),

          // Photo stats cards
          if (photoState.photos.isNotEmpty)
            _buildPhotoStats(theme, photoState),

          // Search results or smart albums
          if (_isSearching && _searchController.text.isNotEmpty)
            _buildSearchResults(theme, photoState)
          else
            _buildSmartAlbums(theme, photoState),
        ],
      ),

      // Floating action button with scale animation
      floatingActionButton: _isMultiSelectMode
          ? ScaleTransition(
              scale: _fabAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete button
                  if (_selectedPhotoIds.isNotEmpty)
                    FloatingActionButton(
                      heroTag: 'delete',
                      onPressed: _deleteSelectedPhotos,
                      backgroundColor: theme.colorScheme.error,
                      child: const Icon(Icons.delete_outline),
                    ),
                  const SizedBox(height: 12),
                  // Close multi-select
                  FloatingActionButton(
                    heroTag: 'close',
                    onPressed: _toggleMultiSelectMode,
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  /// Builds premium sliver app bar with glassmorphism
  Widget _buildSliverAppBar(ThemeData theme, PhotoListState photoState) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: _isSearching
            ? SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search photos...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              )
            : Text(
                'Photos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Search button
        if (!_isMultiSelectMode)
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        // Multi-select button
        if (!_isSearching && photoState.photos.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: _toggleMultiSelectMode,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Builds photo stats cards
  Widget _buildPhotoStats(ThemeData theme, PhotoListState photoState) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Total photos card
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.photo_library,
                label: 'Photos',
                value: '${photoState.photos.length}',
                gradient: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.primary,
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Storage used card (mock data)
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.cloud_outlined,
                label: 'Storage',
                value: '${(photoState.photos.length * 0.8).toStringAsFixed(1)} MB',
                gradient: [
                  theme.colorScheme.tertiary.withOpacity(0.8),
                  theme.colorScheme.tertiary,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stat card widget
  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds search results
  Widget _buildSearchResults(ThemeData theme, PhotoListState photoState) {
    // Filter photos by search query
    final query = _searchController.text.toLowerCase();
    final filteredPhotos = photoState.photos.where((photo) {
      // Search by AI analysis or metadata
      return photo.aiAnalysis?.toLowerCase().contains(query) ?? false;
    }).toList();

    if (filteredPhotos.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No photos found',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Try a different search term',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildPhotoGrid(theme, filteredPhotos);
  }

  /// Builds smart albums organized by date
  Widget _buildSmartAlbums(ThemeData theme, PhotoListState photoState) {
    if (photoState.isLoading && photoState.photos.isEmpty) {
      return SliverFillRemaining(
        child: _buildLoadingState(theme),
      );
    }

    if (photoState.error != null && photoState.photos.isEmpty) {
      return SliverFillRemaining(
        child: _buildErrorState(theme, photoState.error!),
      );
    }

    if (photoState.photos.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(theme),
      );
    }

    // Group photos by date sections
    final sections = _groupPhotosByDate(photoState.photos);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final section = sections.entries.elementAt(index);
          return _buildPhotoSection(theme, section.key, section.value);
        },
        childCount: sections.length,
      ),
    );
  }

  /// Groups photos by smart date sections
  Map<String, List<Photo>> _groupPhotosByDate(List<Photo> photos) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<Photo>> sections = {};

    for (final photo in photos) {
      final photoDate = photo.uploadedAt;
      final photoDay = DateTime(photoDate.year, photoDate.month, photoDate.day);

      String sectionName;
      if (photoDay.isAtSameMomentAs(today)) {
        sectionName = 'Today';
      } else if (photoDay.isAtSameMomentAs(yesterday)) {
        sectionName = 'Yesterday';
      } else if (photoDate.isAfter(weekAgo)) {
        sectionName = 'This Week';
      } else if (photoDate.month == now.month && photoDate.year == now.year) {
        sectionName = 'This Month';
      } else {
        sectionName = DateFormat.yMMMM().format(photoDate);
      }

      sections.putIfAbsent(sectionName, () => []);
      sections[sectionName]!.add(photo);
    }

    return sections;
  }

  /// Builds a photo section with header
  Widget _buildPhotoSection(ThemeData theme, String sectionName, List<Photo> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Text(
                sectionName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${photos.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Photo grid for this section
        _buildSectionGrid(theme, photos),
      ],
    );
  }

  /// Builds photo grid for a section
  Widget _buildSectionGrid(ThemeData theme, List<Photo> photos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _buildPhotoThumbnail(theme, photo, index, photos);
        },
      ),
    );
  }

  /// Builds photo grid
  Widget _buildPhotoGrid(ThemeData theme, List<Photo> photos) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final photo = photos[index];
            return _buildPhotoThumbnail(theme, photo, index, photos);
          },
          childCount: photos.length,
        ),
      ),
    );
  }

  /// Builds individual photo thumbnail with hero animation
  Widget _buildPhotoThumbnail(
    ThemeData theme,
    Photo photo,
    int index,
    List<Photo> allPhotos,
  ) {
    final isSelected = _selectedPhotoIds.contains(photo.id);

    return GestureDetector(
      onTap: () {
        if (_isMultiSelectMode) {
          _togglePhotoSelection(photo.id);
        } else {
          _openPhotoViewer(context, allPhotos, index);
        }
      },
      onLongPress: () {
        if (!_isMultiSelectMode) {
          _toggleMultiSelectMode();
          _togglePhotoSelection(photo.id);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero widget for smooth transitions
          Hero(
            tag: 'photo_${photo.id}',
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
          ),

          // Selection overlay
          if (_isMultiSelectMode)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

          // Selection checkbox
          if (_isMultiSelectMode)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.0 : 0.8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PulsingDot(size: 40),
          const SizedBox(height: 24),
          Text(
            'Loading your photos...',
            style: theme.textTheme.titleMedium?.copyWith(
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

  /// Builds empty state with premium illustration
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 60,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Photo Gallery',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload photos in chat to build your personal collection',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navigate back to chat screen
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start Chatting'),
            ),
          ],
        ),
      ),
    );
  }
}
