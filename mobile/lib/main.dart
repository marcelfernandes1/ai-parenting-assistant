/// Main entry point for the AI Parenting Assistant Flutter app.
/// Initializes Riverpod providers and sets up Material 3 theme with go_router.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'router/app_router.dart';

/// Main function - entry point of the app
void main() {
  // Wrap app with ProviderScope to enable Riverpod state management
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of the application
/// Configures Material 3 theme and go_router navigation
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get router instance from provider
    // Router watches auth state and handles navigation automatically
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AI Parenting Assistant',
      debugShowCheckedModeBanner: false,

      // Apply Material 3 theme with warm, parent-friendly colors
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme preference

      // Use go_router for declarative navigation with auth guards
      routerConfig: router,
    );
  }
}
