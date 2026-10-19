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

import '../../../core/engine/content_resolver_service.dart' show ContentSourceType;
import '../../../core/engine/image_validation.dart';
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/safe_curl.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/bandwidth_policy.dart';
import '../../../core/utils/url_sanitizer.dart';

/// When true, PageLoader skips starting its periodic cleanup timer.
/// Set to true in test setUpAll and back to false in tearDownAll to avoid
/// "A Timer is still pending" failures in the test framework.
bool pageLoaderTestMode = false;

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
    this.maxMemoryBytes = defaultMaxMemoryBytes,
    this.maxConcurrentLoads = 4,
    this.loadTimeout = const Duration(seconds: 30),
    this.fetchOverride,
    String Function()? prefetchMode,
    Future<bool> Function()? isOnWifi,
    bool testMode = false,
  })  : _prefetchMode = prefetchMode ?? (() => SettingsService.instance.prefetchNextChapter),
        _isOnWifi = isOnWifi ??
            (() async => await BandwidthPolicy.instance.currentClass() == ConnectionClass.unmetered) {
    // Periodic cleanup of expired failed-URL entries to prevent unbounded growth.
    // Disabled in test mode to avoid pending timers in test framework.
    if (!testMode && !pageLoaderTestMode) {
      _failedUrlsCleanupTimer = Timer.periodic(failedUrlTtl, (_) => clearExpiredFailedUrls());
    }
  }

  // ISS-130: injected so the prefetch gate is testable.
  final String Function() _prefetchMode;
  final Future<bool> Function() _isOnWifi;

  /// ISS-130 gate for next-chapter and upcoming-page prefetch:
  /// off → never; wifiOnly → only on an unmetered connection; always → yes.
  Future<bool> isPrefetchAllowed() async {
    switch (_prefetchMode()) {
      case SettingsService.prefetchOff:
        return false;
      case SettingsService.prefetchWifiOnly:
        try {
          return await _isOnWifi();
        } catch (_) {
          return false;
        }
      default:
        return true;
    }
  }

  /// Per-instance test seam: replaces the network fetch (curl + 4-pass HTTP).
  final Future<PageLoadResult> Function(String url)? fetchOverride;

  /// Test seam for loaders the test cannot construct (e.g. inside
  /// ReaderScreen). Process-global: tests MUST reset it to null in tearDown.
  @visibleForTesting
  static Future<PageLoadResult> Function(String url)? debugDefaultFetchOverride;

  /// Test isolation (ISS-140).
  @visibleForTesting
  static void debugResetTestOverrides() => debugDefaultFetchOverride = null;

  /// Source name for header generation.
  String sourceName;

  /// Manga ID for cache keys.
  final int mangaId;

  /// Chapter target ID (server ID or local ID).
  final int chapterTargetId;

  /// IMP-008: default byte budget for the page-bytes LRU.
  static const int defaultMaxMemoryBytes = 50 * 1024 * 1024; // 50 MB

  /// Maximum memory for cached images (bytes). IMP-008: enforced by the LRU
  /// (it was declared but unused); the newest entry is always kept.
  final int maxMemoryBytes;

  /// Maximum concurrent image loads.
  final int maxConcurrentLoads;

  /// Timeout for individual image loads.
  final Duration loadTimeout;

  // LRU cache for image bytes.
  late final _cache = _ByteLruCache(maxSize: 200, maxBytes: maxMemoryBytes);

  /// IMP-008: bytes currently held by the page cache.
  int get cachedBytes => _cache.totalBytes;

  /// IMP-010: drop least-recently-used pages until at most [targetBytes]
  /// remain (memory pressure). Returns the number of bytes freed.
  int trimCacheTo(int targetBytes) => _cache.trimTo(targetBytes < 0 ? 0 : targetBytes);

  /// IMP-010: OS memory warning. Keep the most recent quarter of the budget
  /// (the visible window) and drop the rest; pages refetch on demand.
  /// Current-chapter pinning: pages of the chapter being read are evicted
  /// only after every other (prefetched) page, and an unpinned insert never
  /// evicts a pinned page. NavigationController sets this on chapter change.
  void setCurrentChapterPages(Iterable<String> urls) => _cache.setPinned(urls);

  @visibleForTesting
  bool isPinnedPage(String url) => _cache.isPinned(url);

  int handleMemoryPressure() {
    final freed = trimCacheTo(maxMemoryBytes ~/ 4);
    if (freed > 0) debugPrint('[PageLoader] memory pressure: freed $freed bytes');
    return freed;
  }

  // Cached intrinsic heights for webtoon layout calculations.
  final Map<String, double> _cachedHeights = {};

  // In-flight requests deduplication.
  final Map<String, Completer<PageLoadResult>> _inFlight = {};

  // Pending requests queue, ordered by priority.
  final _Queue<_PageLoadRequest> _pending = _Queue();

  // Active load count.
  int _activeLoads = 0;

  /// In-flight load count (ISS-129: must stay exact across cancelAll).
  @visibleForTesting
  int get debugActiveLoads => _activeLoads;

  // Closed flag.
  bool _disposed = false;

  // Periodic cleanup timer for expired failed-URL entries.
  Timer? _failedUrlsCleanupTimer;

  // Failed URLs tracking (avoid re-fetching known-bad URLs), with the time of
  // the failure. Entries expire: a brief network drop during prefetch used to
  // fail those pages instantly for the rest of the reading session.
  final Map<String, DateTime> _failedUrls = {};
  static const Duration failedUrlTtl = Duration(minutes: 2);

  bool _isKnownFailed(String url) {
    final at = _failedUrls[url];
    if (at == null) return false;
    if (DateTime.now().difference(at) < failedUrlTtl) return true;
    _failedUrls.remove(url);
    return false;
  }

  // Prefetch attempt times (epoch seconds) for failure cooldown.
  final Map<String, int> _prefetchAttemptTimes = {};

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
        cachedBytes: _cache.totalBytes,
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
  }) {
    if (_disposed) {
      return Future.value(PageLoadResult(error: 'PageLoader disposed'));
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

  /// Cancel all pending and in-flight loads.
  void cancelAll() {
    for (final completer in _inFlight.values) {
      if (!completer.isCompleted) {
        completer.complete(PageLoadResult(error: 'Cancelled'));
      }
    }
    _inFlight.clear();
    _pending.clear();
    // In-flight loads still decrement _activeLoads when they settle (review LOW).
  }

  /// Clear all caches and reset state.
  void clear() {
    cancelAll();
    _cache.clear();
    _cachedHeights.clear();
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
    _failedUrls.clear();
    _prefetchAttemptTimes.clear();
    resetMetrics();
  }

  /// Dispose all resources.
  void dispose() {
    _disposed = true;
    cancelAll();
    _failedUrlsCleanupTimer?.cancel();
    _failedUrlsCleanupTimer = null;
    _cache.clear();
    _cachedHeights.clear();
    _prefetchedChapters.clear();
    _prefetchingChapters.clear();
    _failedUrls.clear();
    _prefetchAttemptTimes.clear();
    recoveringUrls.clear();
    displayFailedUrls.clear();
    onDisplayChanged = null;
    resetMetrics();
  }

  /// Get cached intrinsic height for a URL (for webtoon layout).
  double getCachedHeight(String url) => _cachedHeights[url] ?? 0.0;

  /// Cache intrinsic height for a URL.
  void cacheHeight(String url, double height) {
    _cachedHeights[url] = height;
  }

  /// Drop all intrinsic heights (rotation/resize invalidates width-dependent
  /// layout estimates).
  void clearHeights() => _cachedHeights.clear();

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

  // ── Display-side page state (ISS-125). The single byte store is the LRU
  // above; the screen keeps no copy. Moved from ReaderScreen._recoverImage /
  // _prefetchUpcomingPages / _warmPagesViaLoader with the same semantics.

  /// URLs currently being fetched for display (spinner state).
  final Set<String> recoveringUrls = {};

  /// URLs whose automatic recovery failed; only a manual retry clears one.
  final Set<String> displayFailedUrls = {};

  int _displayGeneration = 0;

  /// Bumped by [resetDisplayState]; results from an older value are dropped.
  int get displayGeneration => _displayGeneration;

  /// Fired when display state changes (owner rebuilds).
  void Function()? onDisplayChanged;

  void _notifyDisplay() {
    if (!_disposed) onDisplayChanged?.call();
  }

  /// Chapter switch: drop in-flight display results and per-chapter state.
  void resetDisplayState() {
    _displayGeneration++;
    recoveringUrls.clear();
    displayFailedUrls.clear();
    _failedUrls.clear();
    // Queued loads for the old chapter would otherwise be served before the
    // new chapter's pages at equal priority. In-flight ones finish and fill
    // the cache.
    for (final request in _pending.drain()) {
      if (identical(_inFlight[request.url], request.completer)) _inFlight.remove(request.url);
      if (!request.completer.isCompleted) request.completer.complete(PageLoadResult(error: 'Cancelled'));
    }
  }

  /// Whether display bytes for [url] are in the LRU.
  bool hasDisplayBytes(String url) => peekCachedBytes(url) != null;

  /// ISS-124: cached bytes that failed to decode, or a local file that failed
  /// to open, render a Retry. A manual retry drops the bad bytes and refetches.
  Future<void> retryUndecodablePage(String url, int index) async {
    if (_disposed) return;
    _cache.remove(url);
    await recoverPage(url, index, manual: true);
  }

  /// Fetch one page for display (curl + 4-pass live in [_loadImage]).
  Future<void> recoverPage(String url, int index, {bool manual = false}) async {
    if (_disposed) return;
    final gen = _displayGeneration;
    if (manual) {
      displayFailedUrls.remove(url);
      clearFailedUrl(url);
    } else if (displayFailedUrls.contains(url)) {
      return;
    }
    if (recoveringUrls.contains(url) || hasDisplayBytes(url)) return;
    recoveringUrls.add(url);
    _notifyDisplay(); // show the spinner (ISS-131)
    try {
      final result = await loadPage(url: url, index: index, priority: PageLoadPriority.current, sourceName: sourceName);
      final bytes = result.bytes;
      if (bytes != null && bytes.isNotEmpty && looksLikeImageHeader(bytes)) {
        if (gen != _displayGeneration) return;
        cacheBytes(url, bytes);
        _notifyDisplay();
      } else {
        debugPrint('[PageLoader] Image failed ${sanitizeUrlForLog(url)}: ${result.error}');
      }
    } catch (e) {
      debugPrint('[PageLoader] Image fetch error for ${sanitizeUrlForLog(url)}: $e');
    } finally {
      recoveringUrls.remove(url);
      if (gen == _displayGeneration && !hasDisplayBytes(url)) {
        displayFailedUrls.add(url);
        _notifyDisplay(); // spinner -> Retry
      }
    }
  }

  /// Priority-warm current/next/prev around 1-based [page] of [urls].
  void warmAround(List<String> urls, int page) {
    if (_disposed || urls.isEmpty) return;
    final gen = _displayGeneration;
    void warm(int i, PageLoadPriority priority) {
      if (i < 0 || i >= urls.length) return;
      final url = urls[i];
      // Local files render via Image.file; only remote pages are warmed.
      if (!url.startsWith('http') || hasDisplayBytes(url)) return;
      unawaited(() async {
        final result = await loadPage(url: url, index: i, priority: priority, sourceName: sourceName);
        if (gen != _displayGeneration) return;
        final bytes = result.bytes;
        if (bytes == null || bytes.isEmpty || !looksLikeImageHeader(bytes)) return;
        cacheBytes(url, bytes);
        _notifyDisplay();
      }());
    }
    final idx = page - 1;
    warm(idx, PageLoadPriority.current);
    warm(idx + 1, PageLoadPriority.next);
    warm(idx - 1, PageLoadPriority.prev);
  }

  /// Look-ahead: fetch the next [count] remote pages after 0-based [currentIndex].
  void prefetchUpcoming(List<String> urls, int currentIndex, {int count = 4}) {
    if (_disposed) return;
    // ISS-130: 'always' keeps the synchronous path unchanged.
    final mode = _prefetchMode();
    if (mode == SettingsService.prefetchOff) return;
    if (mode == SettingsService.prefetchWifiOnly) {
      unawaited(isPrefetchAllowed().then((ok) {
        if (ok && !_disposed) _prefetchUpcomingNow(urls, currentIndex, count);
      }));
      return;
    }
    _prefetchUpcomingNow(urls, currentIndex, count);
  }

  void _prefetchUpcomingNow(List<String> urls, int currentIndex, int count) {
    for (int i = currentIndex + 1; i <= currentIndex + count && i < urls.length; i++) {
      final url = urls[i];
      if (hasDisplayBytes(url) || recoveringUrls.contains(url) || displayFailedUrls.contains(url)) continue;
      if (!(url.startsWith('http://') || url.startsWith('https://'))) continue;
      final priority = i == currentIndex + 1 ? PageLoadPriority.next : PageLoadPriority.prefetch;
      recoveringUrls.add(url);
      unawaited(_prefetchUpcomingOne(url, i, priority));
    }
  }

  Future<void> _prefetchUpcomingOne(String url, int index, PageLoadPriority priority) async {
    final gen = _displayGeneration;
    try {
      final result = await loadPage(url: url, index: index, priority: priority, sourceName: sourceName);
      if (gen != _displayGeneration) {
        recoveringUrls.remove(url);
        return;
      }
      final bytes = result.bytes;
      if (bytes != null && bytes.isNotEmpty && looksLikeImageHeader(bytes)) {
        cacheBytes(url, bytes);
        recoveringUrls.remove(url);
        _notifyDisplay();
        return;
      }
    } catch (e) {
      debugPrint('[PageLoader] prefetch failed for ${sanitizeUrlForLog(url)}: $e');
    }
    recoveringUrls.remove(url);
    if (!_disposed && gen == _displayGeneration) unawaited(recoverPage(url, index));
  }

  /// Update the source name (used when source is auto-detected after chapter load).
  void setSourceName(String name) {
    sourceName = name;
  }

  /// Check if a URL is known to have failed (avoid re-fetching).
  bool isUrlFailed(String url) => _isKnownFailed(url);

  /// Mark a URL as failed.
  void markUrlFailed(String url) => _failedUrls[url] = DateTime.now();

  /// Clear failed URL marker (e.g., on manual retry).
  void clearFailedUrl(String url) => _failedUrls.remove(url);

  /// Clear all expired failed-URL entries.
  void clearExpiredFailedUrls() {
    final now = DateTime.now();
    _failedUrls.removeWhere((_, at) => now.difference(at) >= failedUrlTtl);
  }

  /// Build standard headers for image requests.
  Map<String, String> buildHeaders(String url, {String? overrideSourceName}) {
    final baseHeaders = QuickJsService.getImageHeaders(overrideSourceName ?? sourceName, url);
    final cookieHeaders = MClient.getCookiesPref(url);
    return {
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
    };
  }

  // ─── Prefetch helpers (used by NavigationController) ────────────────

  /// Check if a chapter is already prefetched.
  bool isPrefetched(String key) => _prefetchedChapters.containsKey(key);

  /// Check if a chapter prefetch is in-flight.
  bool isPrefetching(String key) => _prefetchingChapters.contains(key);

  /// Get the last prefetch attempt time for a chapter (epoch seconds).
  int? getPrefetchAttemptTime(String key) => _prefetchAttemptTimes[key];

  /// Set the last prefetch attempt time for a chapter.
  void setPrefetchAttemptTime(String key, int epochSeconds) {
    _prefetchAttemptTimes[key] = epochSeconds;
  }

  /// Clear the prefetch attempt time for a chapter.
  void clearPrefetchAttemptTime(String key) {
    _prefetchAttemptTimes.remove(key);
  }

  /// Whether the loader is still alive (not disposed).
  bool get isAlive => !_disposed;

  /// Get the number of prefetched chapters.
  int getPrefetchCount() => _prefetchedChapters.length;

  /// Evict the oldest prefetched chapter.
  void evictOldestPrefetch() {
    if (_prefetchedChapters.isNotEmpty) {
      final oldestKey = _prefetchedChapters.keys.first;
      _prefetchedChapters.remove(oldestKey);
    }
  }

  /// Store a prefetched chapter.
  void setPrefetchedChapter(String key, String sourceName, List<String> urls,
      {ContentSourceType sourceType = ContentSourceType.localExtension}) {
    _prefetchedChapters[key] = _PrefetchedChapter(sourceName: sourceName, urls: urls, sourceType: sourceType);
  }

  /// IMP-012: read a prefetched chapter's page URLs without consuming it.
  List<String>? peekPrefetchedUrls(String key) => _prefetchedChapters[key]?.urls;

  /// Remove and return a prefetched chapter (consumed on chapter open).
  ({String sourceName, List<String> urls, ContentSourceType sourceType})? takePrefetchedChapter(String key) {
    final p = _prefetchedChapters.remove(key);
    return p == null ? null : (sourceName: p.sourceName, urls: p.urls, sourceType: p.sourceType);
  }

  /// Mark a chapter as being prefetched.
  void markPrefetching(String key) => _prefetchingChapters.add(key);

  /// Unmark a chapter as being prefetched.
  void unmarkPrefetching(String key) => _prefetchingChapters.remove(key);

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
        _cache.put(request.url, result.bytes!);
      } else {
        _failedLoads++;
      }
      _safeComplete(request, result);
    } catch (e) {
      _totalLoadMicroseconds += stopwatch.elapsedMicroseconds;
      _failedLoads++;
      _safeComplete(request, PageLoadResult(error: e.toString()));
    } finally {
      _inFlight.remove(request.url);
      _activeLoads--;
      _processQueue();
    }
  }

  Future<PageLoadResult> _loadImage(String url, String? sourceName, Map<String, String>? extraHeaders) async {
    if (_disposed) return PageLoadResult(error: 'Disposed');

    // Check failed URL cache first
    if (_isKnownFailed(url)) {
      return PageLoadResult(error: 'URL previously failed');
    }

    final override = fetchOverride ?? debugDefaultFetchOverride;
    if (override != null) {
      final r = await override(url);
      if (!r.isSuccess) _failedUrls[url] = DateTime.now();
      return r;
    }

    final effectiveSourceName = sourceName ?? this.sourceName;

    // Build base headers (Referer, etc.)
    final baseHeaders = QuickJsService.getImageHeaders(effectiveSourceName, url);
    final cookieHeaders = MClient.getCookiesPref(url);

    // 1. On Desktop: try curl-impersonate FIRST with clean baseHeaders (Referer only)
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      try {
        final bytes = await _downloadViaCurl(url, baseHeaders);
        if (bytes != null && bytes.length > 200 && _isValidImageBytes(bytes)) {
          return PageLoadResult(bytes: bytes);
        }
      } catch (e) {
        debugPrint('[PageLoader] curl failed for $url: $e, falling back to HTTP');
      }
    }

    // 2. Standard HTTP fetch fallback with multi-pass self-healing
    final initialHeaders = {...baseHeaders, ...cookieHeaders, 'User-Agent': MClient.userAgent, ...?extraHeaders};
    final client = MClient.init(showCloudFlareError: false);
    http.Response? res;

    try {
      final uri = Uri.tryParse(url) ?? Uri.tryParse(Uri.encodeFull(url));
      if (uri == null) return PageLoadResult(error: 'Invalid URL');

      // Pass 1: Standard fetch
      try {
        res = await client.get(uri, headers: initialHeaders).timeout(loadTimeout);
      } catch (e) {
        debugPrint('[PageLoader] HTTP fetch attempt 1 failed for ${sanitizeUrlForLog(url)}: $e');
      }

      // Pass 2: If failed and had Referer, retry with NO Referer (anti-hotlink bypass)
      if ((res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isValidImageBytes(res.bodyBytes)) && initialHeaders.containsKey('Referer')) {
        final noReferer = Map<String, String>.from(initialHeaders)..remove('Referer');
        try {
          res = await client.get(uri, headers: noReferer).timeout(loadTimeout);
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 2 (no referer) failed for ${sanitizeUrlForLog(url)}: $e');
        }
      }

      // Pass 3: If still failed, retry with Origin Referer (same-origin requirement bypass)
      if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isValidImageBytes(res.bodyBytes)) {
        try {
          final originReferer = Map<String, String>.from(initialHeaders)..['Referer'] = '${uri.origin}/';
          res = await client.get(uri, headers: originReferer).timeout(loadTimeout);
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 3 (origin referer) failed for ${sanitizeUrlForLog(url)}: $e');
        }
      }

      // Pass 4: Clean Browser User-Agent and Accept headers
      if (res == null || res.statusCode != 200 || res.bodyBytes.isEmpty || !_isValidImageBytes(res.bodyBytes)) {
        try {
          final browserHeaders = Map<String, String>.from(initialHeaders)
            ..['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
            ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
          res = await client.get(uri, headers: browserHeaders).timeout(loadTimeout);
        } catch (e) {
          debugPrint('[PageLoader] HTTP fetch attempt 4 (browser headers) failed for ${sanitizeUrlForLog(url)}: $e');
        }
      }

      if (res != null && res.statusCode == 200 && res.bodyBytes.isNotEmpty && _isValidImageBytes(res.bodyBytes)) {
        return PageLoadResult(bytes: res.bodyBytes);
      } else {
        debugPrint('[PageLoader] ❌ Image still failed ${sanitizeUrlForLog(url)} -> ${res?.statusCode}');
        _failedUrls[url] = DateTime.now();
        return PageLoadResult(error: 'HTTP ${res?.statusCode ?? 'error'}');
      }
    } finally {
      client.close();
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
/// IMP-008: LRU of page bytes bounded by entry count AND total bytes.
/// Pinned keys (the current chapter) are evicted only after all unpinned
/// ones, and an unpinned insert never pushes a pinned entry out.
class _ByteLruCache {
  final int maxSize;
  final int maxBytes;
  final LinkedHashMap<String, Uint8List> _map = LinkedHashMap();
  Set<String> _pinned = const {};
  int _bytes = 0;

  _ByteLruCache({required this.maxSize, required this.maxBytes});

  int get totalBytes => _bytes;

  void setPinned(Iterable<String> keys) {
    _pinned = keys.toSet();
    _evict(); // a shrunk pin set may leave us over budget
  }

  bool isPinned(String key) => _pinned.contains(key);

  Uint8List? get(String key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value; // Re-insert at end (most recent)
    }
    return value;
  }

  void put(String key, Uint8List value) {
    remove(key);
    _map[key] = value;
    _bytes += value.lengthInBytes;
    _evict(protect: key);
  }

  bool containsKey(String key) => _map.containsKey(key);

  Uint8List? remove(String key) {
    final v = _map.remove(key);
    if (v != null) _bytes -= v.lengthInBytes;
    return v;
  }

  void clear() {
    _map.clear();
    _bytes = 0;
  }

  int get length => _map.length;

  Iterable<Uint8List> get values => _map.values;

  bool _over() => _map.length > maxSize || _bytes > maxBytes;

  /// Oldest unpinned key other than [except], else null.
  String? _oldestUnpinned(String? except) {
    for (final k in _map.keys) {
      if (k != except && !_pinned.contains(k)) return k;
    }
    return null;
  }

  /// Evicts until [targetBytes] or less remain (may empty it): unpinned
  /// pages first, then the oldest pinned ones.
  int trimTo(int targetBytes) {
    final before = _bytes;
    while (_map.isNotEmpty && _bytes > targetBytes) {
      remove(_oldestUnpinned(null) ?? _map.keys.first);
    }
    return before - _bytes;
  }

  void _evict({String? protect}) {
    while (_over() && _map.length > 1) {
      final victim = _oldestUnpinned(protect);
      if (victim != null) {
        remove(victim);
        continue;
      }
      // Only pinned pages (plus maybe the new one) are left.
      if (protect != null && !_pinned.contains(protect)) {
        // An unpinned insert must never push out the current chapter.
        remove(protect);
        return;
      }
      // Over budget with pinned pages only: drop the oldest pinned page,
      // never the one just inserted.
      final oldest = _map.keys.firstWhere((k) => k != protect);
      remove(oldest);
    }
  }
}

/// Prefetched chapter data.
class _PrefetchedChapter {
  final String sourceName;
  final List<String> urls;
  final ContentSourceType sourceType;

  _PrefetchedChapter({required this.sourceName, required this.urls, required this.sourceType});
}

/// Priority queue for requests.
class _Queue<T> {
  final List<T> _items = [];

  void insert(int index, T item) => _items.insert(index, item);
  T removeFirst() => _items.removeAt(0);
  void clear() => _items.clear();
  List<T> drain() {
    final out = List<T>.of(_items);
    _items.clear();
    return out;
  }

  bool get isNotEmpty => _items.isNotEmpty;
  int get length => _items.length;
  T operator [](int index) => _items[index];
}