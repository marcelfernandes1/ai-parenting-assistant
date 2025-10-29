/// API configuration constants for the backend service.
/// Contains base URLs, endpoints, and timeout values.
library;

/// API configuration class with constants for backend communication
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Base URL for the backend API
  /// TODO: Replace with your actual backend URL
  /// For local development: 'http://localhost:3000'
  /// For iOS simulator: 'http://127.0.0.1:3000'
  /// For Android emulator: 'http://10.0.2.2:3000'
  /// For production: 'https://api.aiparenting.app'
  static const String baseUrl = 'http://localhost:3000';

  /// Timeout duration for API requests (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  /// API endpoint paths
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  /// User profile endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String updateProfileEndpoint = '/user/profile';

  /// Onboarding endpoints
  /// Uses the same endpoint as updateProfile since onboarding is just a profile update
  static const String completeOnboardingEndpoint = '/user/profile';

  /// Chat endpoints
  static const String chatMessagesEndpoint = '/chat/history';
  static const String sendMessageEndpoint = '/chat/message';

  /// Photo endpoints
  static const String uploadPhotoEndpoint = '/photos/upload';
  static const String getPhotosEndpoint = '/photos';
  static const String analyzePhotoEndpoint = '/photos/analyze';

  /// Subscription endpoints
  static const String subscriptionsEndpoint = '/subscriptions';
  static const String createSubscriptionEndpoint = '/subscriptions/create';
  static const String cancelSubscriptionEndpoint = '/subscriptions/cancel';

  /// Usage tracking endpoints
  static const String usageEndpoint = '/usage';

  /// WebSocket endpoint for voice chat
  static const String voiceSocketEndpoint = '/voice';

  /// API version header
  static const String apiVersion = 'v1';

  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Version': apiVersion,
      };
}
