/// Unit tests for performance utilities
/// Tests image loading, list optimization, and memoization helpers
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ai_parenting_assistant/shared/utils/performance_utils.dart';

void main() {
  group('PerformanceUtils', () {
    group('Memoizer', () {
      test('should cache computed value', () {
        final memoizer = Memoizer<int>();
        int callCount = 0;

        // First call - should compute
        final result1 = memoizer(() {
          callCount++;
          return 42;
        });

        // Second call - should return cached value
        final result2 = memoizer(() {
          callCount++;
          return 42;
        });

        expect(result1, 42);
        expect(result2, 42);
        expect(callCount, 1); // Should only compute once
      });

      test('should reset cached value', () {
        final memoizer = Memoizer<int>();
        int callCount = 0;

        // First call
        memoizer(() {
          callCount++;
          return 42;
        });

        // Reset cache
        memoizer.reset();

        // Call again - should recompute
        memoizer(() {
          callCount++;
          return 42;
        });

        expect(callCount, 2); // Should compute twice after reset
      });

      test('should handle different types', () {
        final stringMemoizer = Memoizer<String>();
        final listMemoizer = Memoizer<List<int>>();

        final stringResult = stringMemoizer(() => 'Hello');
        final listResult = listMemoizer(() => [1, 2, 3]);

        expect(stringResult, 'Hello');
        expect(listResult, [1, 2, 3]);
      });
    });

    group('PerformanceMonitor', () {
      test('should measure sync function execution time', () {
        final milliseconds = PerformanceMonitor.measure(() {
          // Simulate some work
          for (int i = 0; i < 1000; i++) {
            final _ = i * 2;
          }
        });

        expect(milliseconds, greaterThanOrEqualTo(0));
      });

      test('should measure async function execution time', () async {
        final milliseconds = await PerformanceMonitor.measureAsync(() async {
          await Future.delayed(const Duration(milliseconds: 50));
        });

        // Should be close to 50ms (with some tolerance)
        expect(milliseconds, greaterThanOrEqualTo(40));
        expect(milliseconds, lessThanOrEqualTo(100));
      });
    });
  });
}
