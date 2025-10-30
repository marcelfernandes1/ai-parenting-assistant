/// Global error handler service for catching and reporting app crashes.
/// Catches both framework errors and uncaught async errors.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for handling global errors and crashes
/// Sets up error handlers for both Flutter framework errors and async errors
class ErrorHandlerService {
  /// Callback for when an error occurs
  /// Can be used to report errors to analytics/crash reporting services
  final void Function(Object error, StackTrace stackTrace)? onError;

  ErrorHandlerService({this.onError});

  /// Initializes global error handling
  /// Should be called in main() before runApp()
  void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      // Report error
      onError?.call(details.exception, details.stack ?? StackTrace.current);
    };

    // Catch errors from the platform dispatcher (async errors outside Flutter)
    PlatformDispatcher.instance.onError = (error, stack) {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Platform error: $error\n$stack');
      }

      // Report error
      onError?.call(error, stack);

      // Return true to indicate error was handled
      return true;
    };
  }

  /// Runs app with error zone to catch async errors
  /// Wraps runApp() call in error-catching zone
  static Future<void> runWithErrorHandler({
    required Widget app,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    // Initialize error handler
    final errorHandler = ErrorHandlerService(onError: onError);
    errorHandler.initialize();

    // Run app in error zone to catch async errors
    runZonedGuarded(
      () {
        runApp(app);
      },
      (error, stackTrace) {
        // Log to console in debug mode
        if (kDebugMode) {
          debugPrint('Uncaught error: $error\n$stackTrace');
        }

        // Report error
        onError?.call(error, stackTrace);
      },
    );
  }

  /// Formats error message for display to users
  /// Removes technical details and provides friendly message
  static String formatUserFriendlyError(Object error) {
    final errorString = error.toString();

    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }

    // Check for common error types and provide friendly messages
    if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return 'Unable to connect. Please check your internet connection.';
    }

    if (errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('FormatException')) {
      return 'Invalid data format. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Session expired. Please log in again.';
    }

    if (errorString.contains('403') || errorString.contains('Forbidden')) {
      return 'Access denied. Please check your permissions.';
    }

    if (errorString.contains('404') || errorString.contains('Not found')) {
      return 'Resource not found.';
    }

    if (errorString.contains('429')) {
      return 'Too many requests. Please try again later.';
    }

    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'Server error. Please try again later.';
    }

    // Return original error message if no friendly alternative
    return errorString;
  }
}
