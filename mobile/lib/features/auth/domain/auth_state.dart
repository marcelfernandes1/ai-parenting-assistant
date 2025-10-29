/// Authentication state model using Freezed union types.
/// Represents all possible authentication states in the app.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

// Generated file import
part 'auth_state.freezed.dart';

/// Sealed union type representing authentication state.
/// Uses Freezed to create immutable state with type-safe pattern matching.
@freezed
class AuthState with _$AuthState {
  /// Initial state before checking authentication status
  /// App shows splash screen during this state
  const factory AuthState.initial() = AuthStateInitial;

  /// Loading state during login/register/token refresh
  /// Shows loading indicators to user
  const factory AuthState.loading() = AuthStateLoading;

  /// Authenticated state with user data
  /// User has valid tokens and can access protected features
  const factory AuthState.authenticated({
    required User user,
  }) = AuthStateAuthenticated;

  /// Unauthenticated state - user needs to login
  /// No valid tokens found or user explicitly logged out
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// Error state with error message
  /// Authentication attempt failed (network error, invalid credentials, etc.)
  const factory AuthState.error({
    required String message,
  }) = AuthStateError;
}
