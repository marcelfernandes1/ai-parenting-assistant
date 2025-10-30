/// Riverpod provider for settings repository.
/// Provides dependency injection for settings operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/providers/api_client_provider.dart';
import '../data/settings_repository.dart';

/// Settings Repository provider
/// Provides access to settings repository with API client dependency
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient);
});
