/// Secure storage service for sensitive data like JWT tokens.
/// Uses flutter_secure_storage which stores data in iOS Keychain
/// and Android Keystore for encrypted persistence.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service class for securely storing sensitive data.
/// Provides methods to store and retrieve JWT tokens, user credentials,
/// and other sensitive information in encrypted storage.
class SecureStorageService {
  // Private instance of flutter_secure_storage
  final FlutterSecureStorage _storage;

  // Storage keys constants
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';

  /// Constructor accepts FlutterSecureStorage instance for dependency injection
  /// This allows for testing with mock storage
  SecureStorageService(this._storage);

  /// Factory constructor that creates instance with default configuration
  factory SecureStorageService.create() {
    // Configure storage options for iOS and Android
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        // Use encrypted shared preferences on Android
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        // Use most secure accessibility option on iOS (requires device unlock)
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    return SecureStorageService(storage);
  }

  /// Stores JWT access token in secure storage
  /// Used for authenticating API requests
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Retrieves JWT access token from secure storage
  /// Returns null if no token is stored
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  /// Stores JWT refresh token in secure storage
  /// Used for obtaining new access tokens when they expire
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Retrieves JWT refresh token from secure storage
  /// Returns null if no token is stored
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Stores user ID for quick access without parsing token
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Retrieves stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Stores user email for display purposes
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Retrieves stored user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Saves complete authentication session data
  /// Called after successful login or token refresh
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    // Use Future.wait to write all values in parallel for better performance
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(email),
    ]);
  }

  /// Checks if user has valid stored authentication tokens
  /// Returns true if both access and refresh tokens exist
  Future<bool> hasValidSession() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Clears all authentication data from secure storage
  /// Called on logout to remove all sensitive user data
  Future<void> clearAuthSession() async {
    // Delete all auth-related keys in parallel
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyUserEmail),
    ]);
  }

  /// Deletes ALL data from secure storage
  /// Use with caution - this cannot be undone
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Stores a custom key-value pair in secure storage
  /// Useful for storing other sensitive data like API keys
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Reads a custom key from secure storage
  /// Returns null if key doesn't exist
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Deletes a custom key from secure storage
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
