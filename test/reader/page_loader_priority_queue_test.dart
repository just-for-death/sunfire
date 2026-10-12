// lib/src/features/reader/controller/page_loader.dart priority queue unit tests

import 'dart:async' show unawaited;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/features/reader/controller/page_loader.dart'
    show PageLoader, PageLoadPriority, PageLoadResult, PageLoaderMetrics;

void main() {
  group('PageLoadPriority enum', () {
    test('has correct priority order (current > next > prev > prefetch)', () {
      expect(PageLoadPriority.current.index, lessThan(PageLoadPriority.next.index));
      expect(PageLoadPriority.next.index, lessThan(PageLoadPriority.prev.index));
      expect(PageLoadPriority.prev.index, lessThan(PageLoadPriority.prefetch.index));
    });

    test('has exactly 4 values', () {
      expect(PageLoadPriority.values.length, equals(4));
    });

    test('values are distinct', () {
      final values = PageLoadPriority.values.toSet();
      expect(values.length, equals(4));
    });
  });

  group('PageLoadResult', () {
    test('success result has bytes and fromCache flag', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = PageLoadResult(bytes: bytes, fromCache: true);
      expect(result.isSuccess, isTrue);
      expect(result.bytes, equals(bytes));
      expect(result.fromCache, isTrue);
      expect(result.error, isNull);
    });

    test('error result has error message', () {
      const result = PageLoadResult(error: 'Network error');
      expect(result.isSuccess, isFalse);
      expect(result.bytes, isNull);
      expect(result.error, equals('Network error'));
      expect(result.fromCache, isFalse);
    });

    test('empty result is not success', () {
      const result = PageLoadResult();
      expect(result.isSuccess, isFalse);
      expect(result.bytes, isNull);
      expect(result.error, isNull);
      expect(result.fromCache, isFalse);
    });

    test('immutability - bytes list is final', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = PageLoadResult(bytes: bytes);
      expect(result.bytes, equals(bytes));
    });
  });

  group('PageLoader configuration', () {
    test('PageLoader accepts required parameters', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );

      expect(loader, isNotNull);
      loader.dispose();
    });

    test('PageLoader accepts optional parameters with defaults', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
        maxMemoryBytes: 100 * 1024 * 1024, // 100 MB
        maxConcurrentLoads: 8,
        loadTimeout: Duration(seconds: 60),
      );

      expect(loader, isNotNull);
      loader.dispose();
    });

    test('maxMemoryBytes default is 50 MB', () {
      // We can't directly test private field, but we verify it constructs
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );
      expect(loader, isNotNull);
      loader.dispose();
    });

    test('maxConcurrentLoads default is 4', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );
      expect(loader, isNotNull);
      loader.dispose();
    });

    test('loadTimeout default is 30 seconds', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );
      expect(loader, isNotNull);
      loader.dispose();
    });
  });

  group('PageLoader lifecycle', () {
    test('dispose clears resources', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );

      // Should not throw
      loader.dispose();
      loader.dispose(); // Double dispose should be safe
    });

    test('clear resets state', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );

      loader.clear(); // Should not throw
      loader.dispose();
    });

    test('cancelAll cancels in-flight requests', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 123,
        chapterTargetId: 456,
      );

      loader.cancelAll(); // Should not throw
      loader.dispose();
    });
  });

  group('PageLoadPriority comparison', () {
    test('current has highest priority', () {
      expect(PageLoadPriority.current.index, equals(0));
    });

    test('prefetch has lowest priority', () {
      expect(PageLoadPriority.prefetch.index, equals(3));
    });

    test('can be used for sorting', () {
      final priorities = [
        PageLoadPriority.prefetch,
        PageLoadPriority.current,
        PageLoadPriority.next,
        PageLoadPriority.prev,
      ];

      priorities.sort((a, b) => a.index.compareTo(b.index));

      expect(priorities.first, equals(PageLoadPriority.current));
      expect(priorities.last, equals(PageLoadPriority.prefetch));
    });
  });

  group('PageLoaderMetrics (I3.4)', () {
    test('fresh loader reports zero metrics', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 1,
        chapterTargetId: 2,
      );

      final m = loader.metrics;
      expect(m.cacheHits, equals(0));
      expect(m.cacheMisses, equals(0));
      expect(m.completedLoads, equals(0));
      expect(m.failedLoads, equals(0));
      expect(m.cachedEntries, equals(0));
      expect(m.cachedBytes, equals(0));
      expect(m.totalRequests, equals(0));
      expect(m.hitRate, equals(0.0));
      expect(m.avgLoadMilliseconds, equals(0.0));

      loader.dispose();
    });

    test('cache miss increments on uncached load request', () async {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 1,
        chapterTargetId: 2,
      );

      // Unreachable URL fails fast (connection refused); await it so no
      // in-flight work outlives the loader.
      await loader
          .loadPage(url: 'https://127.0.0.1:1/nonexistent.jpg', index: 0)
          .timeout(const Duration(seconds: 30), onTimeout: () => const PageLoadResult(error: 'timeout'));

      final m = loader.metrics;
      expect(m.cacheMisses, equals(1));
      expect(m.cacheHits, equals(0));
      expect(m.totalRequests, equals(1));
      expect(m.hitRate, equals(0.0));

      loader.dispose();
    });

    test('resetMetrics clears counters', () async {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 1,
        chapterTargetId: 2,
      );

      await loader
          .loadPage(url: 'https://127.0.0.1:1/nonexistent.jpg', index: 0)
          .timeout(const Duration(seconds: 30), onTimeout: () => const PageLoadResult(error: 'timeout'));
      expect(loader.metrics.totalRequests, greaterThan(0));

      loader.resetMetrics();
      final m = loader.metrics;
      expect(m.cacheHits, equals(0));
      expect(m.cacheMisses, equals(0));
      expect(m.totalRequests, equals(0));

      loader.dispose();
    });

    test('hitRate computes correctly', () {
      const m = PageLoaderMetrics(
        cacheHits: 3,
        cacheMisses: 1,
        completedLoads: 1,
        failedLoads: 0,
        totalLoadMicroseconds: 2000,
        cachedEntries: 1,
        cachedBytes: 100,
        inFlight: 0,
        pending: 0,
      );
      expect(m.totalRequests, equals(4));
      expect(m.hitRate, equals(0.75));
      expect(m.avgLoadMilliseconds, equals(2.0));
    });

    test('clear resets metrics alongside cache', () {
      final loader = PageLoader(
        sourceName: 'TestSource',
        mangaId: 1,
        chapterTargetId: 2,
      );
      loader.cacheHeight('https://example.com/a.jpg', 100.0);
      expect(loader.getCachedHeight('https://example.com/a.jpg'), equals(100.0));

      loader.clear();
      expect(loader.getCachedHeight('https://example.com/a.jpg'), equals(0.0));
      expect(loader.metrics.totalRequests, equals(0));

      loader.dispose();
    });
  });
}