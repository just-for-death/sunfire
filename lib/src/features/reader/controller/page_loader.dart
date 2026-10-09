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

import '../../../core/engine/content_resolver_service.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/engine/javascript/m_client.dart';
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
  final String sourceName;

  /// Manga ID for cache keys.
  final int mangaId;

  /// Chapter target ID (server ID or local ID).
  final int chapterTargetId;

  /// Maximum memory for cached images (bytes).
  final int maxMemoryBytes;

  /// Maximum concurrent image loads.
  final int maxConcurrentLoads;

  /// Timeout for individual image loads.
  final Duration loadTimeout;

  // LRU cache for image bytes.
  final _cache = _LruCache<String, Uint8List>(maxSize: 200);

  // In-flight requests deduplication.
  final Map<String, Completer<PageLoadResult>> _inFlight = {};

  // Pending requests queue, ordered by priority.
  final _Queue<_PageLoadRequest> _pending = _Queue();

  // Active load count.
  int _activeLoads = 0;

  // Closed flag.
  bool _disposed = false;

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
  }) {
    if (_disposed) {
      return Future.value(PageLoadResult(error: 'PageLoader disposed'));
    }

    // Check cache first
    final cached = _cache.get(url);
    if (cached != null) {
      return Future.value(PageLoadResult(bytes: cached, fromCache: true));
    }

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
      index: 0, // index not used in loader
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
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
  }

  /// Dispose all resources.
  void dispose() {
    _disposed = true;
    cancelAll();
    _cache.clear();
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
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
      request.completer.complete(PageLoadResult(error: 'Disposed'));
      _inFlight.remove(request.url);
      _processQueue();
      return;
    }

    _activeLoads++;
    unawaited(_loadAndComplete(request));
  }

  Future<void> _loadAndComplete(_PageLoadRequest request) async {
    try {
      final result = await _loadImage(request.url, request.sourceName, request.headers);
      _cache.put(request.url, result.bytes!);
      request.completer.complete(result);
    } catch (e) {
      request.completer.complete(PageLoadResult(error: e.toString()));
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
      }
      return result;
    } catch (e) {
      return PageLoadResult(error: e.toString());
    }
  }

  Future<PageLoadResult> _loadImage(String url, String? sourceName, Map<String, String>? extraHeaders) async {
    if (_disposed) return PageLoadResult(error: 'Disposed');

    // Build headers
    final baseHeaders = QuickJsService.getImageHeaders(sourceName ?? this.sourceName, url);
    final cookieHeaders = MClient.getCookiesPref(url);
    final headers = {
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
      ...?extraHeaders,
    };

    // Desktop: try curl-impersonate fallback
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      try {
        final bytes = await _downloadViaCurl(url, headers);
        if (bytes != null) {
          return PageLoadResult(bytes: bytes);
        }
      } catch (e) {
        debugPrint('[PageLoader] curl failed for $url: $e, falling back to HTTP');
      }
    }

    // Standard HTTP
    final client = MClient.init(showCloudFlareError: false);
    final response = await client.get(Uri.parse(url), headers: headers).timeout(loadTimeout);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (_isValidImageBytes(bytes)) {
        return PageLoadResult(bytes: bytes);
      }
      return PageLoadResult(error: 'Invalid image bytes');
    } else {
      return PageLoadResult(error: 'HTTP ${response.statusCode}');
    }
  }

  Future<Uint8List?> _downloadViaCurl(String url, Map<String, String> headers) async {
    // Use safe_curl's download capability
    final result = await runCurlWithSemaphore(
      url: url,
      maxTimeSeconds: loadTimeout.inSeconds,
      headers: headers,
    );
    return result;
  }

  bool _isValidImageBytes(Uint8List bytes) {
    if (bytes.length < 2) return false;
    // Check magic bytes for common image formats
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true; // JPEG
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true; // PNG
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true; // GIF
    if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) return true; // WEBP
    return false;
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