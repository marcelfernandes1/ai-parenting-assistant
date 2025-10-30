/// Error boundary widget for catching and displaying errors gracefully.
/// Provides user-friendly error screens with retry functionality.
library;

import 'package:flutter/material.dart';
import '../services/error_handler_service.dart';

/// Error boundary widget that catches errors in its child widget tree
/// Shows a friendly error screen instead of crashing the app
class ErrorBoundary extends StatefulWidget {
  /// Child widget to wrap with error boundary
  final Widget child;

  /// Callback when error occurs (optional, for logging/analytics)
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// Custom error widget builder (optional)
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  /// Current error, if any
  Object? _error;

  /// Stack trace of current error
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _error = null;
    _stackTrace = null;
  }

  /// Resets error state and rebuilds child
  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If there's an error, show error screen
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      return ErrorScreen(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _retry,
      );
    }

    // Otherwise, show child wrapped in ErrorWidget.builder override
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      // Capture error
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });

      // Call error callback
      widget.onError?.call(details.exception, details.stack ?? StackTrace.current);

      // Return error screen
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(details.exception, _retry);
      }
      return ErrorScreen(
        error: details.exception,
        stackTrace: details.stack,
        onRetry: _retry,
      );
    } as Widget;

    return widget.child;
  }
}

/// Default error screen shown when an error occurs
/// Displays friendly error message with retry button
class ErrorScreen extends StatelessWidget {
  /// Error that occurred
  final Object error;

  /// Stack trace (optional)
  final StackTrace? stackTrace;

  /// Callback when user taps retry
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friendlyMessage = ErrorHandlerService.formatUserFriendlyError(error);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Oops! Something Went Wrong',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Error message
              Text(
                friendlyMessage,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Retry button
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),

              // Debug info in debug mode
              if (stackTrace != null) ...[
                const SizedBox(height: 24),
                ExpansionTile(
                  title: const Text(
                    'Error Details (Debug)',
                    style: TextStyle(fontSize: 12),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          'Error: $error\n\nStack Trace:\n$stackTrace',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature-level error boundary for specific feature modules
/// Shows inline error display instead of full-screen error
class FeatureErrorBoundary extends StatelessWidget {
  /// Child widget to wrap
  final Widget child;

  /// Callback when error occurs
  final void Function(Object error, StackTrace stackTrace)? onError;

  const FeatureErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: onError,
      errorBuilder: (error, retry) {
        return InlineErrorDisplay(
          error: error,
          onRetry: retry,
        );
      },
      child: child,
    );
  }
}

/// Inline error display for feature-level errors
/// Shows compact error message instead of full screen
class InlineErrorDisplay extends StatelessWidget {
  /// Error that occurred
  final Object error;

  /// Callback when user taps retry
  final VoidCallback onRetry;

  const InlineErrorDisplay({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friendlyMessage = ErrorHandlerService.formatUserFriendlyError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              friendlyMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
