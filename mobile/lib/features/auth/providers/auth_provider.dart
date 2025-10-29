/// Authentication provider using Riverpod StateNotifier.
/// Manages global authentication state and provides login/logout methods.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/service_providers.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';
import '../domain/user_model.dart';

/// Provider for AuthRepository singleton
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

/// State notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    // Check for stored session on initialization
    _checkAuthStatus();
  }

  /// Checks if user has stored authentication session
  /// Called on app startup to restore session
  Future<void> _checkAuthStatus() async {
    try {
      // Check if valid session exists in secure storage
      final hasSession = await _authRepository.hasStoredSession();
      if (hasSession) {
        // Fetch current user from backend to verify token is still valid
        final user = await _authRepository.getCurrentUser();
        state = AuthState.authenticated(user: user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      // If session check fails, mark as unauthenticated
      state = const AuthState.unauthenticated();
    }
  }

  /// Logs in user with email and password
  /// Updates state to authenticated on success, error on failure
  Future<void> login(String email, String password) async {
    // Set loading state
    state = const AuthState.loading();

    try {
      // Attempt login
      final user = await _authRepository.login(email, password);

      // Update state with authenticated user
      state = AuthState.authenticated(user: user);
    } catch (e) {
      // Set error state with message
      state = AuthState.error(message: e.toString());

      // Reset to unauthenticated after brief delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AuthState.unauthenticated();
        }
      });
    }
  }

  /// Registers new user
  Future<void> register(String email, String password, String name) async {
    state = const AuthState.loading();

    try {
      final user = await _authRepository.register(email, password, name);
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(message: e.toString());

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = const AuthState.unauthenticated();
        }
      });
    }
  }

  /// Logs out current user
  /// Clears tokens and resets state to unauthenticated
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } finally {
      // Always set unauthenticated state, even if logout call fails
      state = const AuthState.unauthenticated();
    }
  }

  /// Updates user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    // Get current user from state
    final currentState = state;
    if (currentState is! AuthStateAuthenticated) return;

    state = const AuthState.loading();

    try {
      final updatedUser = await _authRepository.updateProfile(updates);
      state = AuthState.authenticated(user: updatedUser);
    } catch (e) {
      // Restore previous state on error
      state = currentState;
      rethrow;
    }
  }

  /// Completes onboarding
  Future<void> completeOnboarding(Map<String, dynamic> onboardingData) async {
    final currentState = state;
    if (currentState is! AuthStateAuthenticated) return;

    state = const AuthState.loading();

    try {
      final updatedUser = await _authRepository.completeOnboarding(onboardingData);
      state = AuthState.authenticated(user: updatedUser);
    } catch (e) {
      state = currentState;
      rethrow;
    }
  }

  /// Refreshes user data from backend
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AuthState.authenticated(user: user);
    } catch (e) {
      // If refresh fails and we get 401, logout
      state = const AuthState.unauthenticated();
    }
  }
}

/// Main authentication provider
/// Watch this provider to react to auth state changes
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthStateAuthenticated;
});

/// Convenience provider to get current user (or null if not authenticated)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    initial: () => null,
    loading: () => null,
    authenticated: (user) => user,
    unauthenticated: () => null,
    error: (_) => null,
  );
});
