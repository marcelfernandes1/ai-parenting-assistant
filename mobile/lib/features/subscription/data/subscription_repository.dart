/// Subscription repository for handling subscription-related API calls.
/// Provides methods for fetching subscription status and usage data.
library;

import 'package:dio/dio.dart';
import '../../../shared/services/api_client.dart';
import '../domain/subscription_status.dart';

/// Repository class handling subscription API calls.
/// Uses ApiClient for network requests to backend subscription endpoints.
class SubscriptionRepository {
  final ApiClient _apiClient;

  /// Constructor accepts ApiClient dependency for testing and flexibility
  SubscriptionRepository(this._apiClient);

  /// Fetches current subscription status and usage stats from backend.
  /// Returns SubscriptionStatus with tier, status, and usage information.
  /// Throws DioException on network errors.
  /// Throws Exception on other errors.
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      // Call backend subscription status endpoint
      final response = await _apiClient.get('/subscription/status');

      // Check if request was successful
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Parse usage stats if available
        UsageStats? usage;
        if (data.containsKey('usage')) {
          usage = UsageStats.fromJson(data['usage'] as Map<String, dynamic>);
        }

        // Create subscription status from response data
        return SubscriptionStatus(
          subscriptionTier: data['subscriptionTier'] as String,
          subscriptionStatus: data['subscriptionStatus'] as String,
          subscriptionExpiresAt: data['subscriptionExpiresAt'] != null
              ? DateTime.parse(data['subscriptionExpiresAt'] as String)
              : null,
          stripeCustomerId: data['stripeCustomerId'] as String?,
          stripeSubscriptionId: data['stripeSubscriptionId'] as String?,
          usage: usage,
        );
      }

      // Handle non-200 responses
      throw Exception(response.data?['error'] ?? 'Failed to fetch subscription status');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Creates a new subscription with Stripe payment method.
  ///
  /// Parameters:
  /// - paymentMethodId: Stripe payment method ID from flutter_stripe
  /// - priceId: Stripe price ID for the subscription tier
  ///
  /// Returns: Map containing subscription details
  /// Throws: Exception on creation errors
  Future<Map<String, dynamic>> createSubscription({
    required String paymentMethodId,
    required String priceId,
  }) async {
    try {
      // Call backend subscription create endpoint
      final response = await _apiClient.post(
        '/subscription/create',
        data: {
          'paymentMethodId': paymentMethodId,
          'priceId': priceId,
        },
      );

      // Check if request was successful
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      // Handle non-200 responses
      throw Exception(response.data?['error'] ?? 'Failed to create subscription');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Cancels the current active subscription.
  /// Subscription remains active until end of billing period.
  ///
  /// Returns: Map containing cancellation details and final access date
  /// Throws: Exception if no active subscription or cancellation fails
  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      // Call backend subscription cancel endpoint
      final response = await _apiClient.post('/subscription/cancel');

      // Check if request was successful
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      // Handle non-200 responses
      throw Exception(response.data?['error'] ?? 'Failed to cancel subscription');
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Helper method to convert DioException to user-friendly error message.
  /// Handles different HTTP status codes and network issues.
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      // Server responded with error
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['error'] ?? 'Request failed';

      switch (statusCode) {
        case 401:
          return Exception('Authentication required. Please log in again.');
        case 429:
          return Exception('Rate limit exceeded. Please try again later.');
        case 500:
          return Exception('Server error. Please try again later.');
        default:
          return Exception(message);
      }
    }

    // Network error (no response from server)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network.');
    }

    // Unknown error
    return Exception('Failed to fetch subscription status: ${error.message}');
  }
}
