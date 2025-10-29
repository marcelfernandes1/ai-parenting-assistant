/// Main application router using go_router package.
/// Handles navigation between authentication, onboarding, and main app flows.
///
/// Navigation Logic:
/// - Unauthenticated users → Login/Register screens
/// - Authenticated users without profile → Onboarding flow
/// - Authenticated users with profile → Main app
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/current_stage_screen.dart';
import '../features/onboarding/presentation/timeline_input_screen.dart';
import '../features/onboarding/presentation/baby_info_screen.dart';
import '../features/onboarding/presentation/parenting_philosophy_screen.dart';
import '../features/onboarding/presentation/religious_background_screen.dart';
import '../features/onboarding/presentation/cultural_background_screen.dart';
import '../features/onboarding/presentation/concerns_screen.dart';
import '../features/onboarding/presentation/notification_preferences_screen.dart';
import '../features/onboarding/presentation/usage_limits_explanation_screen.dart';
import '../features/chat/presentation/chat_screen.dart';

/// ChangeNotifier that listens to auth state changes and notifies GoRouter.
/// This makes the router reactive to authentication state changes.
class GoRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  GoRouterNotifier(this._ref) {
    // Listen to auth provider changes and notify listeners (GoRouter)
    _ref.listen(
      authProvider,
      (previous, next) {
        // Notify GoRouter to re-run redirect logic when auth state changes
        notifyListeners();
      },
    );
  }
}

/// Provider for GoRouterNotifier instance
final goRouterNotifierProvider = Provider<GoRouterNotifier>((ref) {
  return GoRouterNotifier(ref);
});

/// Provider for GoRouter instance
/// Watches auth state to determine route redirection
final routerProvider = Provider<GoRouter>((ref) {
  // Get the notifier that listens to auth changes
  final notifier = ref.watch(goRouterNotifierProvider);
  return GoRouter(
    // Initial route when app launches
    initialLocation: '/login',

    // Listen to auth state changes to re-run redirect logic
    refreshListenable: notifier,

    // Redirect logic based on authentication state
    // This runs before every navigation to ensure users are on correct screens
    redirect: (context, state) {
      // Read current auth state (use read instead of watch to avoid rebuilding router)
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is AuthStateAuthenticated;
      final hasCompletedOnboarding = isAuthenticated &&
          (authState as AuthStateAuthenticated).user.onboardingComplete;

      // Debug logging
      print('🔍 Router Debug:');
      print('  Location: ${state.matchedLocation}');
      print('  isAuthenticated: $isAuthenticated');
      print('  hasCompletedOnboarding: $hasCompletedOnboarding');
      if (isAuthenticated) {
        final user = (authState as AuthStateAuthenticated).user;
        print('  User: ${user.email}, onboardingComplete: ${user.onboardingComplete}');
      }

      // Get current location
      final isOnAuthScreen = state.matchedLocation.startsWith('/login') ||
                             state.matchedLocation.startsWith('/register');
      final isOnOnboardingScreen = state.matchedLocation.startsWith('/onboarding');
      final isOnMainScreen = state.matchedLocation == '/home';

      // Redirect logic:
      // 1. If not authenticated and not on auth screen → redirect to login
      if (!isAuthenticated && !isOnAuthScreen) {
        return '/login';
      }

      // 2. If authenticated but on auth screen → redirect to appropriate flow
      if (isAuthenticated && isOnAuthScreen) {
        if (!hasCompletedOnboarding) {
          return '/onboarding/welcome';
        }
        return '/home';
      }

      // 3. If authenticated but hasn't completed onboarding and trying to access main app → redirect to onboarding
      if (isAuthenticated && !hasCompletedOnboarding && isOnMainScreen) {
        return '/onboarding/welcome';
      }

      // 4. If authenticated with completed onboarding but on onboarding screens → redirect to home
      if (isAuthenticated && hasCompletedOnboarding && isOnOnboardingScreen) {
        return '/home';
      }

      // No redirect needed, allow navigation
      return null;
    },

    // Define all routes
    routes: [
      // ===== Authentication Routes =====

      /// Login screen route
      /// Path: /login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// Register screen route
      /// Path: /register
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ===== Onboarding Routes =====

      /// Onboarding flow - multi-step user profile setup
      /// Base path: /onboarding
      /// Shows welcome screen by default (no redirect to avoid conflicts)
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          /// Welcome screen - introduces app features and benefits
          /// Path: /onboarding/welcome
          GoRoute(
            path: 'welcome',
            name: 'onboarding-welcome',
            builder: (context, state) => const WelcomeScreen(),
          ),

          /// Current stage screen - pregnancy vs parent selection
          /// Path: /onboarding/current-stage
          GoRoute(
            path: 'current-stage',
            name: 'onboarding-current-stage',
            builder: (context, state) => const CurrentStageScreen(),
          ),

          /// Timeline input screen - due date or birth date entry
          /// Path: /onboarding/timeline-input
          GoRoute(
            path: 'timeline-input',
            name: 'onboarding-timeline-input',
            builder: (context, state) => const TimelineInputScreen(),
          ),

          /// Baby info screen - baby name, gender, etc.
          /// Path: /onboarding/baby-info
          GoRoute(
            path: 'baby-info',
            name: 'onboarding-baby-info',
            builder: (context, state) => const BabyInfoScreen(),
          ),

          /// Parenting philosophy screen - parenting style preferences
          /// Path: /onboarding/parenting-philosophy
          GoRoute(
            path: 'parenting-philosophy',
            name: 'onboarding-parenting-philosophy',
            builder: (context, state) => const ParentingPhilosophyScreen(),
          ),

          /// Religious background screen - religious views and preferences
          /// Path: /onboarding/religious-background
          GoRoute(
            path: 'religious-background',
            name: 'onboarding-religious-background',
            builder: (context, state) => const ReligiousBackgroundScreen(),
          ),

          /// Cultural background screen - cultural traditions and values
          /// Path: /onboarding/cultural-background
          GoRoute(
            path: 'cultural-background',
            name: 'onboarding-cultural-background',
            builder: (context, state) => const CulturalBackgroundScreen(),
          ),

          /// Concerns screen - primary parenting concerns and topics
          /// Path: /onboarding/concerns
          GoRoute(
            path: 'concerns',
            name: 'onboarding-concerns',
            builder: (context, state) => const ConcernsScreen(),
          ),

          /// Notification preferences screen - push notification settings
          /// Path: /onboarding/notification-preferences
          GoRoute(
            path: 'notification-preferences',
            name: 'onboarding-notification-preferences',
            builder: (context, state) => const NotificationPreferencesScreen(),
          ),

          /// Usage limits explanation screen - explain free tier limits
          /// Path: /onboarding/usage-limits
          GoRoute(
            path: 'usage-limits',
            name: 'onboarding-usage-limits',
            builder: (context, state) => const UsageLimitsExplanationScreen(),
          ),
        ],
      ),

      // ===== Main App Routes =====

      /// Home screen - AI chat interface
      /// Path: /home
      /// Main chat screen with message history and AI responses
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const ChatScreen(),
      ),
    ],

    // Error handling - shown when route doesn't exist
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.path,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});
