/// Photo provider using Riverpod for dependency injection.
/// Provides access to PhotoRepository for photo upload and management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/service_providers.dart';
import '../data/photo_repository.dart';

/// Provider for PhotoRepository singleton
/// Used for all photo-related API operations
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(
    ref.watch(apiClientProvider),
  );
});
