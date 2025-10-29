/// Riverpod providers for core services (storage, API client, etc.).
/// These providers are used throughout the app to access services
/// with proper dependency injection and lifecycle management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';
import '../services/api_client.dart';

/// Provider for SecureStorageService singleton instance.
/// This service handles all secure storage operations (JWT tokens, etc.).
/// Disposed automatically when no longer needed.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});

/// Provider for ApiClient singleton instance.
/// Depends on secureStorageProvider for token management.
/// Automatically configured with interceptors for auth and logging.
final apiClientProvider = Provider<ApiClient>((ref) {
  // Get secure storage service from provider
  final secureStorage = ref.watch(secureStorageProvider);

  // Create and return API client with storage dependency
  return ApiClient.create(secureStorage);
});
