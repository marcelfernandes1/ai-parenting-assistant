/// Settings provider using Riverpod.
/// Provides access to SettingsRepository for managing app settings and account operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/service_providers.dart';
import '../data/settings_repository.dart';

/// Provider for SettingsRepository singleton
/// Provides access to all settings-related operations like changing email,
/// password, toggling mode, and data export/deletion.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(apiClientProvider),
  );
});
