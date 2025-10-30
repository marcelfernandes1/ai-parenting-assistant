/// Photo list provider for managing photo gallery state.
/// Handles fetching, pagination, and deletion of photos.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/photo_repository.dart';
import '../domain/photo_model.dart';
import 'photo_provider.dart';

/// Photo list state model
class PhotoListState {
  final List<Photo> photos;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const PhotoListState({
    this.photos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  PhotoListState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return PhotoListState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Photo list state notifier
class PhotoListNotifier extends StateNotifier<PhotoListState> {
  final PhotoRepository _photoRepository;

  static const int _pageSize = 20;

  PhotoListNotifier(this._photoRepository) : super(const PhotoListState());

  /// Loads initial page of photos
  Future<void> loadPhotos() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _photoRepository.listPhotos(
        limit: _pageSize,
        offset: 0,
      );

      state = state.copyWith(
        photos: response.photos,
        isLoading: false,
        hasMore: response.pagination.hasMore,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads next page of photos (for infinite scroll)
  Future<void> loadMorePhotos() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _photoRepository.listPhotos(
        limit: _pageSize,
        offset: state.currentPage * _pageSize,
      );

      state = state.copyWith(
        photos: [...state.photos, ...response.photos],
        isLoadingMore: false,
        hasMore: response.pagination.hasMore,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refreshes photo list (pull-to-refresh)
  Future<void> refreshPhotos() async {
    state = const PhotoListState();
    await loadPhotos();
  }

  /// Deletes a photo by ID
  Future<void> deletePhoto(String photoId) async {
    try {
      await _photoRepository.deletePhoto(photoId);

      // Remove photo from state
      state = state.copyWith(
        photos: state.photos.where((photo) => photo.id != photoId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Adds a newly uploaded photo to the list (at the beginning)
  void addPhoto(Photo photo) {
    state = state.copyWith(
      photos: [photo, ...state.photos],
    );
  }

  /// Adds multiple newly uploaded photos to the list
  void addPhotos(List<Photo> newPhotos) {
    state = state.copyWith(
      photos: [...newPhotos, ...state.photos],
    );
  }
}

/// Provider for photo list state
final photoListProvider =
    StateNotifierProvider<PhotoListNotifier, PhotoListState>((ref) {
  return PhotoListNotifier(ref.watch(photoRepositoryProvider));
});
