/// Repository for user settings and account management operations.
/// Handles API calls for email changes, password updates, etc.
library;

import 'package:dio/dio.dart';
import '../../../shared/services/api_client.dart';

/// Settings repository
/// Manages user settings and account operations
class SettingsRepository {
  final ApiClient _apiClient;

  SettingsRepository(this._apiClient);

  /// Changes user's email address
  /// Requires current password for verification
  Future<void> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final response = await _apiClient.put(
        '/user/email',
        data: {
          'newEmail': newEmail,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data?['error'] ?? 'Failed to change email');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data?['error'] ?? 'Failed to change email');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Changes user's password
  /// Requires current password for verification
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.put(
        '/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data?['error'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data?['error'] ?? 'Failed to change password');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Toggles user mode from PREGNANCY to PARENTING
  /// Returns updated profile data
  Future<Map<String, dynamic>> toggleMode({
    required String babyName,
    required String babyGender,
    required DateTime babyBirthDate,
  }) async {
    try {
      final response = await _apiClient.post(
        '/user/toggle-mode',
        data: {
          'babyName': babyName,
          'babyGender': babyGender,
          'babyBirthDate': babyBirthDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception(response.data?['error'] ?? 'Failed to toggle mode');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data?['error'] ?? 'Failed to toggle mode');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Deletes user account and all associated data
  /// Requires password for verification
  Future<void> deleteAccount({required String password}) async {
    try {
      final response = await _apiClient.delete(
        '/user/account',
        data: {
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data?['error'] ?? 'Failed to delete account');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data?['error'] ?? 'Failed to delete account');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Exports all user data (GDPR compliance)
  /// Returns JSON data with user information
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final response = await _apiClient.get('/user/data-export');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception(response.data?['error'] ?? 'Failed to export data');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data?['error'] ?? 'Failed to export data');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
