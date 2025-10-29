/// Main entry point for the AI Parenting Assistant Flutter app.
/// Initializes Riverpod providers and sets up Material 3 theme.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/domain/auth_state.dart';

/// Main function - entry point of the app
void main() {
  // Wrap app with ProviderScope to enable Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Root widget of the application
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode (could add dark mode toggle later)
    // final themeMode = ref.watch(themeModeProvider); // TODO: Add theme provider

    return MaterialApp(
      title: 'AI Parenting Assistant',
      debugShowCheckedModeBanner: false,

      // Apply Material 3 theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme for now

      // For now, show a simple welcome screen
      // TODO: Replace with proper router and authentication flow
      home: const WelcomeScreen(),
    );
  }
}

/// Simple welcome screen for testing
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo/icon placeholder
              Icon(
                Icons.child_care,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // App title
              Text(
                'AI Parenting Assistant',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your AI-powered companion for parenting guidance',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Show auth state for debugging
              _buildAuthStateIndicator(context, authState),
              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to login screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login screen coming soon!')),
                  );
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  // TODO: Navigate to register screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Register screen coming soon!')),
                  );
                },
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 24),

              // Theme test cards
              Text(
                'Theme Components:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildThemeShowcase(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds auth state indicator for debugging
  Widget _buildAuthStateIndicator(BuildContext context, AuthState authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Auth State:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            authState.when(
              initial: () => const Text('Checking authentication...'),
              loading: () => const CircularProgressIndicator(),
              authenticated: (user) => Text('Logged in as: ${user.email}'),
              unauthenticated: () => const Text('Not logged in'),
              error: (message) => Text('Error: $message', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  /// Showcases theme colors and components
  Widget _buildThemeShowcase(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildColorChip(context, 'Primary', Theme.of(context).colorScheme.primary),
        _buildColorChip(context, 'Secondary', Theme.of(context).colorScheme.secondary),
        _buildColorChip(context, 'Tertiary', Theme.of(context).colorScheme.tertiary),
      ],
    );
  }

  /// Builds a colored chip to showcase theme colors
  Widget _buildColorChip(BuildContext context, String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      side: BorderSide(color: color),
    );
  }
}
