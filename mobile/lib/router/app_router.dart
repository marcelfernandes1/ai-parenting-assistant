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
import '../features/photos/presentation/photos_screen.dart';
import '../features/milestones/presentation/milestones_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/subscription/presentation/premium_screen.dart';

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

      // Handle loading/initial states - don't redirect while auth check is in progress
      // This prevents premature redirects before we know the user's auth status
      if (authState is AuthStateInitial || authState is AuthStateLoading) {
        print('🔍 Router Debug: Auth state is ${authState.runtimeType}, staying at ${state.matchedLocation}');
        // Stay where we are until auth check completes
        return null;
      }

      final isAuthenticated = authState is AuthStateAuthenticated;
      final hasCompletedOnboarding = isAuthenticated &&
          (authState as AuthStateAuthenticated).user.onboardingComplete;

      // Debug logging
      print('🔍 Router Debug:');
      print('  Auth State: ${authState.runtimeType}');
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
        print('🔍 Router: Not authenticated and not on auth screen → redirecting to /login');
        return '/login';
      }

      // 2. If authenticated but on auth screen → redirect to appropriate flow
      if (isAuthenticated && isOnAuthScreen) {
        if (!hasCompletedOnboarding) {
          print('🔍 Router: Authenticated but onboarding incomplete → redirecting to /onboarding/welcome');
          return '/onboarding/welcome';
        }
        print('🔍 Router: Authenticated and onboarding complete → redirecting to /home');
        return '/home';
      }

      // 3. If authenticated but hasn't completed onboarding and trying to access main app → redirect to onboarding
      if (isAuthenticated && !hasCompletedOnboarding && isOnMainScreen) {
        print('🔍 Router: Trying to access main app without completing onboarding → redirecting to /onboarding/welcome');
        return '/onboarding/welcome';
      }

      // 4. If authenticated with completed onboarding but on onboarding screens → redirect to home
      if (isAuthenticated && hasCompletedOnboarding && isOnOnboardingScreen) {
        print('🔍 Router: Onboarding complete but on onboarding screen → redirecting to /home');
        return '/home';
      }

      // No redirect needed, allow navigation
      print('🔍 Router: No redirect needed, staying at ${state.matchedLocation}');
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

      /// Home screen - Chat interface (main screen)
      /// Path: /home
      /// AI-powered parenting chat with access to all features via drawer menu
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const ChatScreen(),
      ),

      /// Photos screen - Baby photo gallery
      /// Path: /photos
      /// View and manage baby photos, upload new photos, and get AI analysis
      GoRoute(
        path: '/photos',
        name: 'photos',
        builder: (context, state) => const PhotosScreen(),
      ),

      /// Milestones screen - Development milestone tracking
      /// Path: /milestones
      /// Track baby's developmental milestones and achievements
      GoRoute(
        path: '/milestones',
        name: 'milestones',
        builder: (context, state) => const MilestonesScreen(),
      ),

      /// Profile screen - Edit user information
      /// Path: /profile
      /// Allows users to update their profile, baby info, and preferences
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      /// Settings screen - App preferences and configuration
      /// Path: /settings
      /// Manage notifications, appearance, privacy, and account settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      /// Premium screen - Subscription management and upgrade
      /// Path: /premium
      /// View premium features, manage subscription, or upgrade from free tier
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
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
