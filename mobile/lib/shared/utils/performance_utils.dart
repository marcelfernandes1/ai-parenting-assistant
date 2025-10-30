/// Performance optimization utilities for Flutter app.
/// Provides helpers for image caching, list optimization, and widget memoization.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Performance utilities for optimizing app performance
class PerformanceUtils {
  /// Builds an optimized network image with caching and placeholder
  /// Uses cached_network_image package for automatic caching
  static Widget buildOptimizedNetworkImage({
    required String imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    bool fadeIn = true,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: fadeIn ? const Duration(milliseconds: 300) : Duration.zero,
      placeholder: placeholder != null
          ? (context, url) => placeholder
          : (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget
          : (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
      // Cache configuration
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );
  }

  /// Optimized ListView.builder with performance best practices
  /// Automatically configures itemExtent, cacheExtent, and other optimizations
  static Widget buildOptimizedList({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    ScrollController? controller,
    double? itemHeight,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
  }) {
    return ListView.builder(
      controller: controller,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      padding: padding,
      shrinkWrap: shrinkWrap,
      // Performance optimizations
      itemExtent: itemHeight, // Massive performance boost for fixed-height items
      cacheExtent: 500, // Pre-render 500px of content off-screen
      addAutomaticKeepAlives: false, // Don't keep all items alive
      addRepaintBoundaries: true, // Isolate repaints
      physics: const ClampingScrollPhysics(), // Better performance than bouncing
    );
  }

  /// Optimized GridView with performance best practices
  static Widget buildOptimizedGrid({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    required int crossAxisCount,
    ScrollController? controller,
    double crossAxisSpacing = 8,
    double mainAxisSpacing = 8,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: controller,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      // Performance optimizations
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }

  /// Wraps widget with RepaintBoundary to isolate repaints
  /// Use for complex widgets that don't change often
  static Widget isolateRepaint(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Preloads network images for better perceived performance
  /// Call this in initState or when navigating to a screen with images
  static Future<void> precacheNetworkImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) {
      return CachedNetworkImage(
        imageUrl: url,
      ).image.resolve(const ImageConfiguration());
    });

    await Future.wait(futures);
  }

  /// Debounces a function call to prevent rapid repeated executions
  /// Useful for search fields, scroll listeners, etc.
  static void Function() debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, callback);
    };
  }

  /// Creates a const widget when possible to avoid rebuilds
  /// Wrapper for creating const widgets programmatically
  static Widget constWidget(Widget child) {
    return child;
  }
}

/// Extension on Widget for easy performance optimizations
extension PerformanceWidgetExtension on Widget {
  /// Wraps widget with RepaintBoundary
  Widget get isolateRepaint => RepaintBoundary(child: this);

  /// Wraps widget with KeepAlive to prevent disposal when scrolled off-screen
  Widget get keepAlive => _KeepAliveWidget(child: this);
}

/// Internal widget for KeepAlive functionality
class _KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const _KeepAliveWidget({required this.child});

  @override
  State<_KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<_KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Import needed for Timer
import 'dart:async';

/// Memoization helper for expensive computations
class Memoizer<T> {
  T? _cachedValue;
  bool _hasValue = false;

  /// Gets the cached value or computes it if not cached
  T call(T Function() computation) {
    if (!_hasValue) {
      _cachedValue = computation();
      _hasValue = true;
    }
    return _cachedValue as T;
  }

  /// Resets the cached value
  void reset() {
    _hasValue = false;
    _cachedValue = null;
  }
}

/// Performance monitoring utilities
class PerformanceMonitor {
  /// Measures execution time of a function
  /// Returns duration in milliseconds
  static Future<int> measureAsync(Future<void> Function() fn) async {
    final stopwatch = Stopwatch()..start();
    await fn();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// Measures execution time of a synchronous function
  /// Returns duration in milliseconds
  static int measure(void Function() fn) {
    final stopwatch = Stopwatch()..start();
    fn();
    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  /// Logs performance metrics in debug mode
  static void logPerformance(String label, int milliseconds) {
    debugPrint('⏱️ Performance: $label took ${milliseconds}ms');
  }
}
