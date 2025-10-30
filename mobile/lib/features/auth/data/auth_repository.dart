/// Authentication repository for handling all auth-related API calls.
/// Provides methods for login, register, logout, and session management.
library;

import 'package:dio/dio.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_config.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../domain/user_model.dart';

/// Repository class handling authentication API calls and session management.
/// Uses ApiClient for network requests and SecureStorageService for token storage.
class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  /// Constructor accepts dependencies for testing and flexibility
  AuthRepository(this._apiClient, this._secureStorage);

  /// Authenticates user with email and password.
  /// Returns User object on success.
  /// Throws DioException on network errors.
  /// Throws Exception on invalid credentials or other errors.
  Future<User> login(String email, String password) async {
    try {
      // Call login endpoint
      final response = await _apiClient.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      // Check if login was successful
      if (response.statusCode == 200) {
        // Extract tokens and user data from response
        final accessToken = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        // Parse user from JSON
        final user = User.fromJson(userData);

        // Save tokens and user data to secure storage
        await _secureStorage.saveAuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: user.id,
          email: user.email,
        );

        return user;
      }

      // Handle non-200 responses
      throw Exception(response.data['error'] ?? 'Login failed');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Registers new user with email and password.
  /// Returns User object on success.
  /// Throws Exception on validation errors or network issues.
  Future<User> register(String email, String password, String name) async {
    try {
      // Call register endpoint
      final response = await _apiClient.post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      // Check if registration was successful
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Extract tokens and user data
        final accessToken = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String;
        final userData = response.data['user'] as Map<String, dynamic>;

        // Parse user from JSON
        final user = User.fromJson(userData);

        // Save auth session
        await _secureStorage.saveAuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: user.id,
          email: user.email,
        );

        return user;
      }

      // Handle non-success responses
      throw Exception(response.data['error'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logs out current user.
  /// Clears tokens from storage and optionally calls backend logout endpoint.
  Future<void> logout() async {
    try {
      // Optionally notify backend of logout (invalidate refresh token)
      // This can fail silently if network is unavailable
      try {
        await _apiClient.post(ApiConfig.logoutEndpoint);
      } catch (e) {
        // Ignore logout endpoint errors - we'll clear local session anyway
      }

      // Clear all auth data from secure storage
      await _secureStorage.clearAuthSession();
    } catch (e) {
      // Ensure we clear session even if something fails
      await _secureStorage.clearAuthSession();
      rethrow;
    }
  }

  /// Fetches current user profile from backend.
  /// Requires valid authentication tokens.
  /// Returns updated User object.
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConfig.userProfileEndpoint);

      if (response.statusCode == 200) {
        // Backend returns {profile: {...}} so access the profile key
        final profileData = response.data['profile'] as Map<String, dynamic>;
        return User.fromJson(profileData);
      }

      throw Exception(response.data['error'] ?? 'Failed to fetch user');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates user profile data.
  /// Accepts partial user data updates.
  /// Returns updated User object.
  Future<User> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.updateProfileEndpoint,
        data: updates,
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }

      throw Exception(response.data['error'] ?? 'Failed to update profile');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Completes onboarding by updating user profile with onboarding data.
  /// Marks onboardingComplete as true in backend.
  Future<User> completeOnboarding(Map<String, dynamic> onboardingData) async {
    try {
      final response = await _apiClient.put(
        ApiConfig.completeOnboardingEndpoint,
        data: onboardingData,
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }

      throw Exception(response.data['error'] ?? 'Failed to complete onboarding');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Checks if user has stored authentication tokens.
  /// Returns true if valid session exists.
  Future<bool> hasStoredSession() async {
    return await _secureStorage.hasValidSession();
  }

  /// Converts DioException to user-friendly error message
  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please try again.');
    }

    // Extract error message from response
    final response = error.response;
    if (response != null && response.data is Map) {
      final errorMessage = response.data['error'] as String?;
      if (errorMessage != null) {
        return Exception(errorMessage);
      }
    }

    // Generic error message
    return Exception('An unexpected error occurred. Please try again.');
  }
}
