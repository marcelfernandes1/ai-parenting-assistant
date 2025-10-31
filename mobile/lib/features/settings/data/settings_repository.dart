/// Settings repository for handling all settings-related API calls.
/// Provides methods for changing email, password, toggling mode, and data management.
library;

import 'package:dio/dio.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_config.dart';
import '../../auth/domain/user_model.dart';

/// Repository class handling settings API calls.
/// Uses ApiClient for network requests.
class SettingsRepository {
  final ApiClient _apiClient;

  /// Constructor accepts ApiClient dependency for testing and flexibility
  SettingsRepository(this._apiClient);

  /// Changes user's email address.
  /// Requires current password for verification.
  /// Throws DioException on network errors.
  /// Throws Exception on validation errors.
  Future<void> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      // Call change email endpoint
      final response = await _apiClient.put(
        ApiConfig.changeEmailEndpoint,
        data: {
          'newEmail': newEmail,
          'password': password,
        },
      );

      // Check if successful
      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to change email');
      }
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Changes user's password.
  /// Requires current password for verification.
  /// Throws DioException on network errors.
  /// Throws Exception on validation errors.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Call change password endpoint
      final response = await _apiClient.put(
        ApiConfig.changePasswordEndpoint,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      // Check if successful
      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Toggles user mode from PREGNANCY to PARENTING.
  /// This is a one-way operation and cannot be reversed.
  /// Returns updated UserProfile.
  /// Throws DioException on network errors.
  /// Throws Exception on validation errors.
  Future<User> toggleMode({
    required String babyName,
    required String babyGender,
    required DateTime babyBirthDate,
  }) async {
    try {
      // Call toggle mode endpoint
      final response = await _apiClient.post(
        ApiConfig.toggleModeEndpoint,
        data: {
          'babyName': babyName,
          'babyGender': babyGender,
          'babyBirthDate': babyBirthDate.toIso8601String(),
        },
      );

      // Check if successful
      if (response.statusCode == 200) {
        // Parse profile from response
        final profileData = response.data['profile'] as Map<String, dynamic>;

        // Convert profile data to User model format
        // The backend returns a profile, but we need to return a User object
        // We'll construct a minimal User object with the profile data
        return User(
          id: profileData['userId'] as String,
          email: '', // Email not included in profile response, will be filled by refreshUser
          subscriptionTier: 'FREE',
          onboardingComplete: true,
          mode: profileData['mode'] as String?,
          babyName: profileData['babyName'] as String?,
          babyBirthDate: profileData['babyBirthDate'] as String?,
          createdAt: profileData['createdAt'] != null
              ? DateTime.parse(profileData['createdAt'] as String)
              : DateTime.now(),
          updatedAt: profileData['updatedAt'] != null
              ? DateTime.parse(profileData['updatedAt'] as String)
              : DateTime.now(),
        );
      }

      // Handle non-200 responses
      throw Exception(response.data['error'] ?? 'Failed to toggle mode');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Deletes user account and all associated data.
  /// Requires password for verification.
  /// This action is irreversible.
  /// Throws DioException on network errors.
  /// Throws Exception on validation errors.
  Future<void> deleteAccount({
    required String password,
  }) async {
    try {
      // Call delete account endpoint
      final response = await _apiClient.delete(
        ApiConfig.deleteAccountEndpoint,
        data: {
          'password': password,
        },
      );

      // Check if successful
      if (response.statusCode != 200) {
        throw Exception(response.data['error'] ?? 'Failed to delete account');
      }
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Exports all user data in JSON format (GDPR compliance).
  /// Returns a Map containing all user data including profile, messages, milestones, and photos.
  /// Throws DioException on network errors.
  /// Throws Exception on other errors.
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      // Call export data endpoint
      final response = await _apiClient.get(
        ApiConfig.exportDataEndpoint,
      );

      // Check if successful
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      // Handle non-200 responses
      throw Exception(response.data['error'] ?? 'Failed to export data');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Handles DioException and converts to user-friendly error message
  Exception _handleDioError(DioException e) {
    // Check for response error (4xx, 5xx)
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final errorMessage = e.response!.data['error'] ?? 'Unknown error';

      // Handle specific error codes
      switch (statusCode) {
        case 400:
          return Exception(errorMessage);
        case 401:
          return Exception('Invalid credentials');
        case 403:
          return Exception('Access denied');
        case 404:
          return Exception('Resource not found');
        case 409:
          return Exception(errorMessage);
        case 500:
          return Exception('Server error. Please try again later.');
        default:
          return Exception(errorMessage);
      }
    }

    // Handle network errors (no response)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return Exception('Cannot connect to server. Please check your internet connection.');
    }

    // Default error message
    return Exception('Network error. Please try again.');
  }
}
