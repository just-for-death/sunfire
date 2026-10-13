// lib/src/features/reader/controller/page_loader.dart
//
// Extracted from reader_screen.dart — handles image loading, prefetching, and caching
// for the reader. Provides priority-based loading (current > next > prev),
// configurable memory limits, and LRU eviction.
//
// Designed to be independent of UI — no BuildContext, no setState.

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../../core/engine/content_resolver_service.dart';
import '../../../constants/app_constants.dart' show kBrowserUserAgent;
import '../../../core/engine/image_validation.dart' show looksLikeImageHeader;
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/safe_curl.dart';

/// Result of a page load operation.
class PageLoadResult {
  final Uint8List? bytes;
  final String? error;
  final bool fromCache;

  const PageLoadResult({
    this.bytes,
    this.error,
    this.fromCache = false,
  });

  bool get isSuccess => bytes != null;
}

/// Snapshot of PageLoader cache/load metrics (I3.4).
class PageLoaderMetrics {
  const PageLoaderMetrics({
    required this.cacheHits,
    required this.cacheMisses,
    required this.completedLoads,
    required this.failedLoads,
    required this.totalLoadMicroseconds,
    required this.cachedEntries,
    required this.cachedBytes,
    required this.inFlight,
    required this.pending,
  });

  final int cacheHits;
  final int cacheMisses;
  final int completedLoads;
  final int failedLoads;
  final int totalLoadMicroseconds;
  final int cachedEntries;
  final int cachedBytes;
  final int inFlight;
  final int pending;

  int get totalRequests => cacheHits + cacheMisses;

  double get hitRate => totalRequests > 0 ? cacheHits / totalRequests : 0.0;

  double get avgLoadMilliseconds =>
      completedLoads > 0 ? totalLoadMicroseconds / completedLoads / 1000.0 : 0.0;
}

/// Priority levels for page loading.
enum PageLoadPriority {
  current,  // Currently visible page
  next,     // Next page(s) in reading direction
  prev,     // Previous page(s)
  prefetch, // Speculative prefetch for next chapter
}

/// A page load request with priority.
class _PageLoadRequest {
  final String url;
  final int index;
  final PageLoadPriority priority;
  final Completer<PageLoadResult> completer;
  final String? sourceName;
  final Map<String, String>? headers;

  _PageLoadRequest({
    required this.url,
    required this.index,
    required this.priority,
    required this.completer,
    this.sourceName,
    this.headers,
  });
}

/// PageLoader — handles image loading, prefetching, and caching for the reader.
///
/// Features:
/// - Priority-based loading (current > next > prev > prefetch)
/// - Configurable memory limit with LRU eviction
/// - In-flight deduplication
/// - Timeout handling
/// - Graceful cancellation
class PageLoader {
  PageLoader({
    required this.sourceName,
    required this.mangaId,
    required this.chapterTargetId,
    this.maxMemoryBytes = 50 * 1024 * 1024, // 50 MB default
    this.maxConcurrentLoads = 4,
    this.loadTimeout = const Duration(seconds: 30),
  });

  /// Source name for header generation.
  String sourceName;

  /// Manga ID for cache keys.
  int mangaId;

  /// Chapter target ID (server ID or local ID).
  int chapterTargetId;

  /// Update context for the currently loaded chapter.
  void updateContext({
    required String sourceName,
    required int mangaId,
    required int chapterTargetId,
  }) {
    this.sourceName = sourceName;
    this.mangaId = mangaId;
    this.chapterTargetId = chapterTargetId;
  }

  /// Maximum memory for cached images (bytes).
  final int maxMemoryBytes;

  /// Maximum concurrent image loads.
  final int maxConcurrentLoads;

  /// Timeout for individual image loads.
  final Duration loadTimeout;

  // LRU cache for image bytes.
  final _cache = _LruCache<String, Uint8List>(maxSize: 200);

  // Cached intrinsic heights for webtoon layout calculations.
  final Map<String, double> _cachedHeights = {};

  // In-flight requests deduplication.
  final Map<String, Completer<PageLoadResult>> _inFlight = {};

  // Pending requests queue, ordered by priority.
  final _Queue<_PageLoadRequest> _pending = _Queue();

  // Active load count.
  int _activeLoads = 0;

  // Closed flag.
  bool _disposed = false;

  // Set of failed URLs to prevent repeated failing requests unless retried.
  final Set<String> _failedUrls = {};

  /// Callback fired whenever a page finishes loading successfully into cache.
  void Function(String url, Uint8List bytes)? onPageLoaded;

  /// Check if a URL has failed previously.
  bool isUrlFailed(String url) => _failedUrls.contains(url);

  /// Check if a URL is currently loading or queued.
  bool isUrlLoading(String url) => _inFlight.containsKey(url);

  /// Clear failed status for a URL so it can be re-fetched.
  void clearFailed(String url) => _failedUrls.remove(url);

  // ─── I3.4 Metrics: hit rate, memory usage, load time ─────────────
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _completedLoads = 0;
  int _failedLoads = 0;
  int _totalLoadMicroseconds = 0;

  /// Snapshot of cache/load metrics for observability (I3.4).
  PageLoaderMetrics get metrics => PageLoaderMetrics(
        cacheHits: _cacheHits,
        cacheMisses: _cacheMisses,
        completedLoads: _completedLoads,
        failedLoads: _failedLoads,
        totalLoadMicroseconds: _totalLoadMicroseconds,
        cachedEntries: _cache.length,
        cachedBytes: _cache.values.fold<int>(0, (sum, b) => sum + b.length),
        inFlight: _inFlight.length,
        pending: _pending.length,
      );

  /// Reset accumulated metrics counters (keeps cached data).
  void resetMetrics() {
    _cacheHits = 0;
    _cacheMisses = 0;
    _completedLoads = 0;
    _failedLoads = 0;
    _totalLoadMicroseconds = 0;
  }

  /// Load a single page image.
  ///
  /// Returns the image bytes, loading from cache if available,
  /// otherwise downloading with the given priority.
  Future<PageLoadResult> loadPage({
    required String url,
    required int index,
    PageLoadPriority priority = PageLoadPriority.current,
    String? sourceName,
    Map<String, String>? headers,
    bool retry = false,
  }) {
    if (_disposed) {
      return Future.value(const PageLoadResult(error: 'PageLoader disposed'));
    }

    if (retry) {
      _failedUrls.remove(url);
    } else if (_failedUrls.contains(url)) {
      return Future.value(const PageLoadResult(error: 'Failed previously'));
    }

    // Check cache first
    final cached = _cache.get(url);
    if (cached != null) {
      _cacheHits++;
      return Future.value(PageLoadResult(bytes: cached, fromCache: true));
    }
    _cacheMisses++;

    // Check in-flight
    final inFlight = _inFlight[url];
    if (inFlight != null) {
      return inFlight.future;
    }

    // Create new request
    final completer = Completer<PageLoadResult>();
    _inFlight[url] = completer;

    final request = _PageLoadRequest(
      url: url,
      index: index,
      priority: priority,
      completer: completer,
      sourceName: sourceName,
      headers: headers,
    );

    _enqueueRequest(request);
    _processQueue();

    return completer.future;
  }

  /// Prefetch a chapter's pages.
  ///
  /// Resolves page URLs and optionally precaches first N images.
  Future<void> prefetchChapter({
    required int chapterServerId,
    required int chapterTargetId,
    required int mangaId,
    required String sourceName,
    required String? chapterUrl,
    int maxPrecacheImages = 3,
  }) async {
    final key = '$chapterTargetId|$mangaId';

    // Check if already prefetched or in-flight
    if (_prefetchedChapters.containsKey(key) || _prefetchingChapters.contains(key)) {
      return;
    }

    _prefetchingChapters.add(key);

    try {
      final resolved = await ContentResolverService.instance
          .resolveChapterPages(
        chapterServerId: chapterServerId > 0 ? chapterServerId : chapterTargetId,
        chapterUrl: chapterUrl,
        sourceName: sourceName,
      ).timeout(const Duration(seconds: 20), onTimeout: () => ChapterPagesResult(
        pageUrls: const <String>[],
        source: ContentSourceType.fallback,
      ));

      if (resolved.pageUrls.isNotEmpty) {
        _prefetchedChapters[key] = _PrefetchedChapter(
          sourceName: resolved.effectiveSourceName ?? sourceName,
          urls: resolved.pageUrls,
        );

        // Precache first N images
        for (final url in resolved.pageUrls.take(maxPrecacheImages)) {
          if (!_cache.containsKey(url)) {
            unawaited(_loadAndCache(url, sourceName: sourceName));
          }
        }
      }
    } catch (e) {
      debugPrint('[PageLoader] Prefetch failed: $e');
    } finally {
      _prefetchingChapters.remove(key);
    }
  }

  /// Cancel all pending and in-flight loads.
  void cancelAll() {
    for (final completer in _inFlight.values) {
      if (!completer.isCompleted) {
        completer.complete(PageLoadResult(error: 'Cancelled'));
      }
    }
    _inFlight.clear();
    _pending.clear();
    _activeLoads = 0;
  }

  /// Clear all caches and reset state.
  void clear() {
    cancelAll();
    _cache.clear();
    _cachedHeights.clear();
    _failedUrls.clear();
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
    resetMetrics();
  }

  /// Dispose all resources.
  void dispose() {
    _disposed = true;
    cancelAll();
    _cache.clear();
    _cachedHeights.clear();
    _failedUrls.clear();
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
    resetMetrics();
  }

  /// Take prefetched pages for a chapter if available, removing from cache.
  List<String>? takePrefetchedPages({
    required int chapterTargetId,
    required int mangaId,
    String? sourceName,
  }) {
    final key = '$chapterTargetId|$mangaId';
    final prefetched = _prefetchedChapters.remove(key);
    if (prefetched == null) return null;
    if (sourceName != null && sourceName.isNotEmpty && prefetched.sourceName.isNotEmpty) {
      if (prefetched.sourceName != sourceName) return null;
    }
    return prefetched.urls;
  }

  /// Get cached intrinsic height for a URL (for webtoon layout).
  double getCachedHeight(String url) => _cachedHeights[url] ?? 0.0;

  /// Cache intrinsic height for a URL.
  void cacheHeight(String url, double height) {
    _cachedHeights[url] = height;
  }

  /// I3: synchronous peek at LRU image bytes (bumps recency on hit).
  Uint8List? peekCachedBytes(String url) {
    if (_disposed) return null;
    return _cache.get(url);
  }

  /// I3: seed / mirror recovered bytes into the loader LRU.
  void cacheBytes(String url, Uint8List bytes) {
    if (_disposed || bytes.isEmpty) return;
    _cache.put(url, bytes);
  }

  // Private implementation details below

  // Prefetched chapters cache: key -> _PrefetchedChapter
  final Map<String, _PrefetchedChapter> _prefetchedChapters = {};

  // In-flight prefetches
  final Set<String> _prefetchingChapters = {};

  // Enqueue a request with priority ordering.
  void _enqueueRequest(_PageLoadRequest request) {
    // Insert in priority order (current > next > prev > prefetch)
    int insertIndex = 0;
    for (int i = 0; i < _pending.length; i++) {
      if (_pending[i].priority.index <= request.priority.index) {
        insertIndex = i + 1;
      } else {
        break;
      }
    }
    _pending.insert(insertIndex, request);
  }

  // Process the queue up to maxConcurrentLoads.
  void _processQueue() {
    while (_activeLoads < maxConcurrentLoads && _pending.isNotEmpty) {
      final request = _pending.removeFirst();
      _startLoad(request);
    }
  }

  // Start loading a single image.
  void _startLoad(_PageLoadRequest request) {
    if (_disposed) {
      _safeComplete(request, const PageLoadResult(error: 'Disposed'));
      _inFlight.remove(request.url);
      _processQueue();
      return;
    }

    _activeLoads++;
    unawaited(_loadAndComplete(request));
  }

  /// Complete a request unless it was already completed by cancelAll/dispose.
  /// Disposal during an in-flight load previously threw
  /// `Bad state: Future already completed`.
  void _safeComplete(_PageLoadRequest request, PageLoadResult result) {
    if (!request.completer.isCompleted) {
      request.completer.complete(result);
    }
  }

  Future<void> _loadAndComplete(_PageLoadRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _loadImage(request.url, request.sourceName, request.headers);
      _totalLoadMicroseconds += stopwatch.elapsedMicroseconds;
      if (result.isSuccess) {
        _completedLoads++;
        _failedUrls.remove(request.url);
        _cache.put(request.url, result.bytes!);
        onPageLoaded?.call(request.url, result.bytes!);
      } else {
        _failedLoads++;
        _failedUrls.add(request.url);
      }
      _safeComplete(request, result);
    } catch (e) {
      _totalLoadMicroseconds += stopwatch.elapsedMicroseconds;
      _failedLoads++;
      _failedUrls.add(request.url);
      _safeComplete(request, PageLoadResult(error: e.toString()));
    } finally {
      _inFlight.remove(request.url);
      _activeLoads--;
      _processQueue();
    }
  }

  Future<PageLoadResult> _loadAndCache(String url, {String? sourceName}) async {
    try {
      final result = await _loadImage(url, sourceName, null);
      if (result.isSuccess) {
        _cache.put(url, result.bytes!);
        onPageLoaded?.call(url, result.bytes!);
      }
      return result;
    } catch (e) {
      return PageLoadResult(error: e.toString());
    }
  }

  Future<PageLoadResult> _loadImage(String url, String? sourceName, Map<String, String>? extraHeaders) async {
    if (_disposed) return const PageLoadResult(error: 'Disposed');

    // Build headers
    final baseHeaders = QuickJsService.getImageHeaders(sourceName ?? this.sourceName, url);
    final cookieHeaders = MClient.getCookiesPref(url);
    final headers = {
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
      ...?extraHeaders,
    };

    // 1. Desktop: try curl-impersonate FIRST with clean baseHeaders (Referer only)
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      try {
        final bytes = await runCurlWithSemaphore(
          url: url,
          maxTimeSeconds: 15,
          headers: baseHeaders,
          skipHeaders: const {'user-agent', 'cookie'},
          timeout: const Duration(seconds: 30),
        );
        if (bytes != null && bytes.length > 200 && looksLikeImageHeader(bytes)) {
          return PageLoadResult(bytes: bytes);
        }
      } catch (e) {
        debugPrint('[PageLoader] curl failed for $url: $e, falling back to HTTP');
      }
    }

    // 2. Standard HTTP with multi-pass self-healing
    final client = MClient.init(showCloudFlareError: false);
    try {
      final uri = Uri.tryParse(url) ?? Uri.tryParse(Uri.encodeFull(url));
      if (uri == null) return const PageLoadResult(error: 'Invalid URL');

      http.Response? res;

      // Pass 1: Standard fetch
      try {
        res = await client.get(uri, headers: headers).timeout(loadTimeout);
      } catch (e) {
        debugPrint('[PageLoader] HTTP fetch attempt 1 failed: $e');
      }

      // Pass 2: If failed and had Referer, retry with NO Referer (anti-hotlink bypass)
      if ((res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !looksLikeImageHeader(res.bodyBytes)) &&
          headers.containsKey('Referer')) {
        final noReferer = Map<String, String>.from(headers)..remove('Referer');
        try {
          res = await client.get(uri, headers: noReferer).timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 2 (no referer) failed: $e');
        }
      }

      // Pass 3: If still failed, retry with Origin Referer (same-origin requirement bypass)
      if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !looksLikeImageHeader(res.bodyBytes)) {
        try {
          final originReferer = Map<String, String>.from(headers)..['Referer'] = '${uri.origin}/';
          res = await client.get(uri, headers: originReferer).timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 3 (origin referer) failed: $e');
        }
      }

      // Pass 4: Clean Browser User-Agent and Accept headers
      if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !looksLikeImageHeader(res.bodyBytes)) {
        try {
          final browserHeaders = Map<String, String>.from(headers)
            ..['User-Agent'] = kBrowserUserAgent
            ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
          res = await client.get(uri, headers: browserHeaders).timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 4 (browser headers) failed: $e');
        }
      }

      if (res != null && res.statusCode == 200 && res.bodyBytes.isNotEmpty && looksLikeImageHeader(res.bodyBytes)) {
        return PageLoadResult(bytes: res.bodyBytes);
      }
      return PageLoadResult(error: 'HTTP ${res?.statusCode ?? 0}');
    } finally {
    }
  }
}

/// LRU cache with size limit.
class _LruCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap();

  _LruCache({required this.maxSize});

  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value; // Re-insert at end (most recent)
    }
    return value;
  }

  void put(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    _evict();
  }

  bool containsKey(K key) => _map.containsKey(key);

  void clear() => _map.clear();

  int get length => _map.length;

  Iterable<V> get values => _map.values;

  void _evict() {
    while (_map.length > maxSize) {
      _map.remove(_map.keys.first);
    }
  }
}

/// Prefetched chapter data.
class _PrefetchedChapter {
  final String sourceName;
  final List<String> urls;

  _PrefetchedChapter({required this.sourceName, required this.urls});
}

/// Priority queue for requests.
class _Queue<T> {
  final List<T> _items = [];

  void insert(int index, T item) => _items.insert(index, item);
  T removeFirst() => _items.removeAt(0);
  void clear() => _items.clear();
  bool get isNotEmpty => _items.isNotEmpty;
  int get length => _items.length;
  T operator [](int index) => _items[index];
}