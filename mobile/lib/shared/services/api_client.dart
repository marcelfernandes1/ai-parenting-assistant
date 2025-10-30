/// HTTP API client using Dio with automatic token refresh interceptor.
/// Handles all communication with the backend API including authentication,
/// error handling, and request/response logging.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import 'secure_storage_service.dart';

/// Main API client for making HTTP requests to the backend.
/// Includes automatic JWT token injection and refresh on 401 errors.
class ApiClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  /// Constructor accepts Dio instance and SecureStorageService for dependency injection
  ApiClient(this._dio, this._secureStorage) {
    _setupInterceptors();
  }

  /// Factory constructor that creates instance with default Dio configuration
  factory ApiClient.create(SecureStorageService secureStorage) {
    // Create Dio instance with base configuration
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConfig.receiveTimeout),
        sendTimeout: Duration(seconds: ApiConfig.sendTimeout),
        headers: ApiConfig.defaultHeaders,
        validateStatus: (status) {
          // Accept all status codes for custom error handling
          return status != null && status < 500;
        },
      ),
    );

    return ApiClient(dio, secureStorage);
  }

  /// Sets up Dio interceptors for logging, auth, error handling, and retry logic
  void _setupInterceptors() {
    // Add logging interceptor in debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    // Add retry interceptor for transient errors (before auth interceptor)
    _dio.interceptors.add(_createRetryInterceptor());

    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Inject access token before each request
        onRequest: (options, handler) async {
          // Skip token injection for login/register/refresh endpoints
          final skipAuthPaths = [
            ApiConfig.loginEndpoint,
            ApiConfig.registerEndpoint,
            ApiConfig.refreshTokenEndpoint,
          ];

          if (!skipAuthPaths.contains(options.path)) {
            // Get access token from secure storage
            final accessToken = await _secureStorage.getAccessToken();
            if (accessToken != null) {
              // Add Bearer token to Authorization header
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          // Continue with request
          handler.next(options);
        },

        // Handle response errors
        onError: (error, handler) async {
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // Attempt to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry original request with new token
              try {
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                // If retry fails, pass error to caller
                return handler.next(error);
              }
            } else {
              // Refresh failed, user needs to login again
              await _secureStorage.clearAuthSession();
              // TODO: Navigate to login screen
              return handler.next(error);
            }
          }

          // Handle 429 Too Many Requests - usage limit reached
          if (error.response?.statusCode == 429) {
            debugPrint('Usage limit reached: ${error.response?.data}');
            // Let the caller handle this (show paywall)
          }

          // Pass error to caller
          handler.next(error);
        },
      ),
    );
  }

  /// Creates retry interceptor with exponential backoff for transient errors
  /// Automatically retries failed requests for server errors (500, 502, 503) and timeouts
  InterceptorsWrapper _createRetryInterceptor() {
    // Maximum number of retry attempts
    const maxRetries = 3;

    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Check if error is retryable
        if (!_shouldRetry(error)) {
          // Not retryable, pass to next interceptor
          return handler.next(error);
        }

        // Get current retry count from request options extra data
        final retries = error.requestOptions.extra['retries'] as int? ?? 0;

        // Check if we've exceeded max retries
        if (retries >= maxRetries) {
          debugPrint('Max retries ($maxRetries) exceeded for ${error.requestOptions.path}');
          return handler.next(error);
        }

        // Calculate delay using exponential backoff: 1s, 2s, 4s
        final delayMs = (1000 * (1 << retries)); // 2^retries seconds in milliseconds
        debugPrint('Retrying request (attempt ${retries + 1}/$maxRetries) after ${delayMs}ms delay...');

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delayMs));

        // Increment retry count
        error.requestOptions.extra['retries'] = retries + 1;

        // Retry the request
        try {
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          // Retry failed, pass error to next interceptor
          return handler.next(e);
        }
      },
    );
  }

  /// Determines if an error should be retried
  /// Returns true for server errors (500, 502, 503) and timeout errors
  /// Returns false for client errors (4xx) and other errors
  bool _shouldRetry(DioException error) {
    // Don't retry if response is null (likely connection error, let it fail immediately)
    if (error.response == null) {
      // Retry on timeout errors
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return true;
      }
      // Don't retry other connection errors (no internet, etc.)
      return false;
    }

    final statusCode = error.response!.statusCode;

    // Retry on server errors (500, 502, 503)
    if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return true;
    }

    // Don't retry on client errors (4xx) - these indicate problems with the request
    // Note: 401 is handled separately by auth interceptor
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return false;
    }

    // Don't retry other errors
    return false;
  }

  /// Attempts to refresh the access token using the refresh token
  /// Returns true if successful, false otherwise
  Future<bool> _refreshToken() async {
    try {
      // Get refresh token from storage
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }

      // Call refresh endpoint
      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      // Check if refresh was successful
      if (response.statusCode == 200) {
        // Extract new tokens from response
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        // Save new tokens to secure storage
        await _secureStorage.saveAccessToken(newAccessToken);
        await _secureStorage.saveRefreshToken(newRefreshToken);

        debugPrint('Token refreshed successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  /// Retries a failed request with new access token
  Future<Response> _retry(RequestOptions requestOptions) async {
    // Get new access token
    final newAccessToken = await _secureStorage.getAccessToken();

    // Create new options with updated token
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
    );

    // Retry the request
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// GET request helper method
  /// Throws DioException on network errors
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request helper method
  /// Throws DioException on network errors
  /// Optional onSendProgress callback for tracking upload progress
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
    );
  }

  /// PUT request helper method
  /// Throws DioException on network errors
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request helper method
  /// Throws DioException on network errors
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request helper method
  /// Throws DioException on network errors
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file using multipart form data
  /// Used for photo uploads
  Future<Response> uploadFile(
    String path,
    String filePath,
    String fieldName, {
    Map<String, dynamic>? additionalData,
  }) async {
    // Create multipart form data
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (additionalData != null) ...additionalData,
    });

    return await post(path, data: formData);
  }

  /// Downloads file from URL
  /// Saves to specified file path with progress callback
  Future<Response> downloadFile(
    String url,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    return await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
    );
  }
}
