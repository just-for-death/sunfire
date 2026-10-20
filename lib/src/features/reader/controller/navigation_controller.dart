import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/engine/content_resolver_service.dart'
    show ChapterPagesResult, ContentSourceType, ContentResolverService;
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/delete_after_read.dart';
import '../../../core/services/download_manager_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/live_activities_service.dart'
    show LiveActivitiesService, SiriShortcutsService;
import '../../../core/sync/widget_sync_service.dart';
import '../reader_chapter_navigation.dart' show findSiblingChapterIndex, siblingChapterAt, sortSiblingChapters;
import '../reader_chapter_resolve.dart';
import '../reader_download_ahead.dart';
import '../reader_prefetch.dart' show prefetchSourceMatches, readerPrefetchKey;
import 'page_loader.dart'
    show PageLoader, PageLoadPriority, PageLoadResult;
import 'position_manager.dart';

/// NavigationController — orchestrates chapter/page navigation, sibling management,
/// prefetching, and navigation debouncing.
///
/// Designed to be independent of UI — no BuildContext, no setState.
/// All state is passed in/out via callbacks.
class NavigationController {
  NavigationController({
    required this.isarService,
    required this.pageLoader,
    required this.positionManager,
    required this.settings,
    this.ownsSubControllers = true,
  });

  final IsarService isarService;
  final PageLoader pageLoader;
  final PositionManager positionManager;
  final SettingsService settings;

  /// Whether this controller owns the injected sub-controllers and should
  /// dispose them. Set to false when sub-controllers are injected from
  /// outside (e.g., tests, or ReaderController with _subControllersInjected).
  final bool ownsSubControllers;

  // Navigation debouncing (single copy; the screen reads/writes these).
  DateTime? lastNextChapterNavAt;
  DateTime? lastPrevChapterNavAt;

  // State getters (set by owner via callbacks)
  Chapter? _chapter;
  List<Chapter> _siblingChapters = [];
  Chapter? _nextChapter;
  Chapter? _prevChapter;
  List<String> _pageUrls = [];
  int _currentPage = 1;
  int _currentChapterId = 0;

  // Callbacks (set by owner)
  void Function(Chapter chapter, List<Chapter> siblings, Chapter? next, Chapter? prev)? onChapterLoaded;
  void Function(int page)? onPageChanged;
  void Function(bool loading)? onLoadingChanged;
  void Function(String url, int index)? onImageRecovered;
  void Function(Chapter chapter)? onNextChapterPrefetched;
  /// IMP-012: fires when a prefetched chapter's page URLs are cached and
  /// ready (unlike [onNextChapterPrefetched], which fires once `next` is known).
  void Function(Chapter chapter, List<String> urls)? onNextChapterPagesReady;

  // Getters for external state
  Chapter? get chapter => _chapter;
  List<Chapter> get siblingChapters => _siblingChapters;
  Chapter? get nextChapter => _nextChapter;
  Chapter? get prevChapter => _prevChapter;
  List<String> get pageUrls => _pageUrls;
  int get currentPage => _currentPage;
  int get currentChapterId => _currentChapterId;
  /// Effective source name of the loaded chapter (drives image headers).
  String? get sourceName => _sourceName;

  // Setters for external state (called by owner)
  void setChapter(Chapter? chapter) => _chapter = chapter;
  void setSiblingChapters(List<Chapter> chapters) => _siblingChapters = chapters;
  void setNextChapter(Chapter? chapter) => _nextChapter = chapter;
  void setPrevChapter(Chapter? chapter) => _prevChapter = chapter;
  void setPageUrls(List<String> urls) {
    _pageUrls = urls;
    pageLoader.setCurrentChapterPages(urls);
  }
  void setCurrentPage(int page) => _currentPage = page;
  void setCurrentChapterId(int id) => _currentChapterId = id;

  // Load a chapter and its pages, updating sibling chapters and next/prev.
  /// Timeouts for every await in the load path (review H/MED). Tests shrink them.
  static Duration ioTimeout = const Duration(seconds: 10);
  @visibleForTesting
  static Duration resolveTimeout = const Duration(seconds: 30);
  @visibleForTesting
  static Duration selfHealTimeout = const Duration(seconds: 20);
  @visibleForTesting
  static Duration prefetchTimeout = const Duration(seconds: 20);
  @visibleForTesting
  static Duration prefetchFailureCooldown = const Duration(minutes: 1);

  /// Test seam: replaces ContentResolverService.resolveChapterPages for both
  /// the main resolve and next-chapter prefetch.
  @visibleForTesting
  static Future<ChapterPagesResult> Function({
    required int chapterServerId,
    String? chapterUrl,
    String? sourceName,
  })? debugResolveOverride;

  static Future<ChapterPagesResult> _resolve({
    required int chapterServerId,
    String? chapterUrl,
    String? sourceName,
  }) =>
      (debugResolveOverride ?? ContentResolverService.instance.resolveChapterPages)(
        chapterServerId: chapterServerId,
        chapterUrl: chapterUrl,
        sourceName: sourceName,
      );

  @visibleForTesting
  static Future<SiblingChapterNav> Function(Chapter chapter)? debugSiblingNavOverride;
  @visibleForTesting
  static Future<Map<String, dynamic>> Function(String source, String url)? debugSelfHealFetchOverride;

  /// Restores every static timeout and test seam. Tests that touch any of
  /// them MUST call this in tearDown (they are process-global).
  @visibleForTesting
  static void debugResetTestOverrides() {
    ioTimeout = const Duration(seconds: 10);
    resolveTimeout = const Duration(seconds: 30);
    selfHealTimeout = const Duration(seconds: 20);
    prefetchTimeout = const Duration(seconds: 20);
    prefetchFailureCooldown = const Duration(minutes: 1);
    debugResolveOverride = null;
    debugSiblingNavOverride = null;
    debugSelfHealFetchOverride = null;
  }

  /// Whether [loadGen] is still the newest load.
  bool isCurrentLoad(int loadGen) => loadGen == _loadGeneration;
  int get loadGeneration => _loadGeneration;

  Future<Manga?> _mangaFor(int mangaId) async {
    try {
      return await IsarService.instance.getMangaByServerId(mangaId).timeout(ioTimeout);
    } catch (e) {
      debugPrint('[NavigationController] manga lookup failed: $e');
      return null;
    }
  }

  // Load a chapter and its pages, updating sibling chapters and next/prev.
  // Always ends with onLoadingChanged(false) for the current generation; a
  // superseded load emits nothing (the newer load owns the spinner).
  Completer<ChapterPagesResult>? _resolveCancel;

  /// Completes the in-flight resolve await of a superseded load.
  void _cancelInFlightResolve() {
    final c = _resolveCancel;
    _resolveCancel = null;
    if (c != null && !c.isCompleted) {
      c.complete(ChapterPagesResult(pageUrls: const <String>[], source: ContentSourceType.fallback));
    }
  }

  Future<void> loadChapterAndPages(int chapterId) async {
    _cancelInFlightResolve();
    cancelProgressDebounce(); // Cancel any pending progress write from previous chapter
    final loadGen = ++_loadGeneration;
    _currentChapterId = chapterId;
    onLoadingChanged?.call(true);
    try {
      await _loadChapterAndPagesInner(chapterId, loadGen);
    } catch (e) {
      debugPrint('[NavigationController] load failed: $e');
    } finally {
      if (loadGen == _loadGeneration) onLoadingChanged?.call(false);
    }
  }

  Future<void> _loadChapterAndPagesInner(int chapterId, int loadGen) async {
    // Flush pending progress write for outgoing chapter before tearing it down
    if (_chapter != null && _pageUrls.isNotEmpty) {
      try {
        await positionManager
            .updateProgress(
              chapterSnapshot: _chapter!,
              totalPages: _pageUrls.length,
              page: _currentPage,
              parentManga: _parentManga,
            )
            .timeout(ioTimeout);
      } catch (e) {
        debugPrint('[NavigationController] progress flush failed: $e');
      }
    }

    _clearChapterState();

    final loadedChapter = await _loadChapter(chapterId).timeout(ioTimeout);
    if (loadGen != _loadGeneration) return;
    _chapter = loadedChapter;
    if (_chapter == null) return;

    await _loadSiblingChapters(loadGen);
    if (loadGen != _loadGeneration) return;

    final pageUrls = await _resolveChapterPages(loadGen);
    if (loadGen != _loadGeneration) return;

    _pageUrls = pageUrls;
    pageLoader.setCurrentChapterPages(pageUrls);
    _currentPage = 1;
    final ch = _chapter!;
    if (pageUrls.isNotEmpty && ch.pageCount != pageUrls.length) {
      ch.pageCount = pageUrls.length;
      unawaited(IsarService.instance.saveChapter(ch));
    }

    onChapterLoaded?.call(_chapter!, _siblingChapters, _nextChapter, _prevChapter);

    if (_nextChapter != null) {
      unawaited(_prefetchNextChapter(_nextChapter!));
    }
  }

  int _loadGeneration = 0;
  Manga? _parentManga;

  void setParentManga(Manga? manga) => _parentManga = manga;
  Manga? get parentManga => _parentManga;

  // Clear chapter-related state (keep PageLoader)
  void _clearChapterState() {
    _pageUrls = [];
    pageLoader.setCurrentChapterPages(const []);
    _currentPage = 1;
    _nextChapter = null;
    _prevChapter = null;
    _siblingChapters = [];
  }

  // Load chapter from Isar (shared resolve with live ReaderScreen).
  Future<Chapter?> _loadChapter(int chapterId) =>
      resolveChapterRecord(IsarService.instance, chapterId);

  // Load sibling chapters and determine next/prev.
  Future<void> _loadSiblingChapters(int loadGen) async {
    if (_chapter == null) return;

    // ISS-121: bounded; a lookup that timed out is DISCARDED (its late result
    // can never set siblings/next/prev), the chapter opens without them.
    final SiblingChapterNav nav;
    try {
      nav = await (debugSiblingNavOverride?.call(_chapter!) ??
              resolveSiblingChapterNav(
                isar: IsarService.instance,
                chapter: _chapter!,
                parentManga: _parentManga,
              ))
          .timeout(ioTimeout);
    } catch (e) {
      debugPrint('[NavigationController] sibling lookup failed/timed out: $e');
      return;
    }
    if (loadGen != _loadGeneration) return;

    _siblingChapters = nav.siblings;
    _nextChapter = nav.next;
    _prevChapter = nav.prev;

    if (nav.next != null) {
      onNextChapterPrefetched?.call(nav.next!);
    }
  }

  Future<List<String>> _resolveChapterPages(int loadGen) async {
    if (_chapter == null) return <String>[];

    String? sourceName;
    if (_chapter != null) {
      final manga = await _mangaFor(_chapter!.mangaId);
      if (loadGen != _loadGeneration) return <String>[];
      sourceName = manga?.sourceName;
    }

    var chapterUrlToResolve = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true) ? _chapter!.realUrl : _chapter?.localPath);

    // On-demand self-healing: If chapter has empty/blank URL in DB, scrape parent manga details immediately!
    if ((chapterUrlToResolve == null || chapterUrlToResolve.isEmpty) && _chapter != null) {
      try {
        // Capture the chapter BEFORE the async call to avoid writing to the
        // wrong chapter if a newer load supersedes this one.
        final targetChapter = _chapter!;
        final manga = await _mangaFor(targetChapter.mangaId);
        final effectiveSource = sourceName ?? manga?.sourceName ?? '';
        if (manga != null && effectiveSource.isNotEmpty) {
          final String? resolvedUrl = await _selfHealChapterUrl(effectiveSource, targetChapter, loadGen);
          if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
            chapterUrlToResolve = resolvedUrl;
            // Write through the captured local, never the current `_chapter`.
            targetChapter.url = resolvedUrl;
            targetChapter.realUrl = resolvedUrl;
            await IsarService.instance.saveChapter(targetChapter).timeout(ioTimeout);
            // Re-check after the await: nothing below may act on a
            // generation that has already been superseded.
            if (loadGen != _loadGeneration) return <String>[];
          }
        }
      } catch (e) {
        debugPrint('[NavigationController] Chapter URL resolution error: $e');
      }
    }

    // Auto-detect source name from URL if missing
    if ((sourceName == null || sourceName.isEmpty) && chapterUrlToResolve != null && chapterUrlToResolve.isNotEmpty) {
      final installed = QuickJsService.instance.getInstalledExtensionNames();
      final urlLower = chapterUrlToResolve.toLowerCase();
      for (final name in installed) {
        final code = QuickJsService.instance.getExtensionCode(name);
        if (code != null) {
          final baseUrl = QuickJsService.instance.extractBaseUrl(code);
          if (baseUrl != null && baseUrl.isNotEmpty) {
            try {
              final host = Uri.parse(baseUrl).host.replaceAll('www.', '').toLowerCase();
              if (host.isNotEmpty && urlLower.contains(host)) {
                sourceName = name;
                break;
              }
            } catch (e) {
              debugPrint('[NavigationController] Source matching error: $e');
            }
          }
        }
      }
    }
    // Guarded, unlike every other write in this load path. `_sourceName` drives
    // the image Referer/auth headers via
    // `QuickJsService.getImageHeaders(_sourceName ?? '', url)`, so a stale value
    // left here by a superseded load makes EVERY image in the currently
    // displayed chapter 403 — the whole chapter renders as "Failed to Load"
    // until the user navigates away and back.
    if (loadGen != _loadGeneration) return <String>[];
    _sourceName = sourceName;

    // Pre-warm FlareSolverr session for this source immediately before resolving,
    // so cookies are ready when images start loading.
    if (chapterUrlToResolve != null && chapterUrlToResolve.startsWith('http')) {
      try {
        final uri = Uri.parse(chapterUrlToResolve);
        unawaited(MClient.prewarmSession('${uri.scheme}://${uri.host}'));
      } catch (e) {
        debugPrint('[NavigationController] Pre-warm session error: $e');
      }
    }

    // Use prefetched pages if available (instant next-chapter open), unless
    // the source changed since the prefetch (migration / corrected source).
    final prefetched = pageLoader.takePrefetchedChapter(_prefetchKey(_chapter!));
    ChapterPagesResult resolved;
    if (prefetched != null &&
        prefetched.urls.isNotEmpty &&
        prefetchSourceMatches(
          prefetchedSource: prefetched.sourceName,
          currentSource: (sourceName != null && sourceName.isNotEmpty) ? sourceName : _parentManga?.sourceName,
        )) {
      resolved = ChapterPagesResult(
        pageUrls: prefetched.urls,
        source: prefetched.sourceType,
        // Review MED: keep the source the prefetch resolved when ours is unknown.
        effectiveSourceName: prefetched.sourceName.isNotEmpty ? prefetched.sourceName : sourceName,
      );
    } else {
      try {
        // Resolve chapter pages via ContentResolverService
        // Low (review): a chapter change abandons this await immediately via
        // [_resolveCancel] instead of waiting out the resolver/timeout. (The
        // resolver itself has no cancel token, so its network work finishes
        // in the background and is discarded.)
        final cancel = _resolveCancel = Completer<ChapterPagesResult>();
        resolved = await Future.any([
          _resolve(
            chapterServerId: _chapter!.serverId > 0 ? _chapter!.serverId : _chapterTargetId(_chapter!),
            chapterUrl: chapterUrlToResolve,
            sourceName: _sourceName ?? '',
          ).timeout(resolveTimeout, onTimeout: () => ChapterPagesResult(
            pageUrls: const <String>[],
            source: ContentSourceType.fallback,
          )),
          cancel.future,
        ]);
      } catch (e) {
        debugPrint('[NavigationController] Resolution threw: $e');
        resolved = ChapterPagesResult(pageUrls: const <String>[], source: ContentSourceType.fallback);
      }
    }

    // Generation guard: a stale resolution (e.g. a 30s timeout fired after the
    // user moved on) must not clobber the CURRENT chapter's state. Checked
    // before ANY field write below.
    if (loadGen != _loadGeneration) return <String>[];

    _sourceName = resolved.effectiveSourceName ?? sourceName;
    final pageUrls = resolved.pageUrls;

    // Update PageLoader with the effective source name for headers
    pageLoader.setSourceName(_sourceName ?? '');

    // Proactively pre-fetch first 5 pages on desktop to bypass Cloudflare image CDN blocking immediately
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      for (int i = 0; i < pageUrls.length && i < 5; i++) {
        // Local files render via Image.file; only remote pages need warming.
        if (!pageUrls[i].startsWith('http')) continue;
        unawaited(pageLoader.loadPage(
          url: pageUrls[i],
          index: i,
          priority: PageLoadPriority.prefetch,
          sourceName: _sourceName,
        ));
      }
    }

    // Platform mirrors after parent manga is known (widget / Live Activities / Siri).
    if (_chapter != null && !settings.incognitoMode) {
      final manga = await _mangaFor(_chapter!.mangaId) ?? _parentManga;
      if (loadGen != _loadGeneration || _chapter == null) return pageUrls;
      final mangaTitle = _chapter!.mangaTitle.isNotEmpty
          ? _chapter!.mangaTitle
          : (manga?.title ?? 'Unknown');
      final chapterName = _chapter!.name;
      final mangaId = _chapter!.mangaId != 0
          ? _chapter!.mangaId
          : (manga?.canonicalKey ?? 0);
      final chapterId = _chapter!.serverId != 0 ? _chapter!.serverId : _chapter!.id;

      unawaited(WidgetSyncService.instance.updateContinueReading(
        mangaTitle: mangaTitle,
        chapterName: chapterName,
        mangaId: mangaId,
        chapterId: chapterId,
      ));

      unawaited(LiveActivitiesService.instance.startReading(
        mangaTitle: mangaTitle,
        chapterName: chapterName,
      ));

      if (mangaId != 0) {
        unawaited(SiriShortcutsService.instance.donateContinueReading(
          mangaTitle: mangaTitle,
          chapterName: chapterName,
          mangaId: mangaId,
        ));
      }
    }

    return pageUrls;
  }

  Future<String?> _selfHealChapterUrl(String effectiveSource, Chapter targetChapter, int loadGen) async {
    try {
      final details = await (debugSelfHealFetchOverride ?? QuickJsService.instance.fetchMangaDetailsLocal)(
        effectiveSource,
        targetChapter.url.isNotEmpty ? targetChapter.url : targetChapter.name,
      ).timeout(selfHealTimeout);
      if (loadGen != _loadGeneration) return null;
      final chList = (details['chapters'] ?? details['chapterList'] ?? details['epList']) as List<dynamic>?;
      if (chList != null && chList.isNotEmpty) {
        final match = chList.cast<dynamic>().where((c) {
          final cUrl = (c['url'] ?? c['link'] ?? '').toString().trim();
          final cNum = (c['chapterNumber'] as num?)?.toDouble();
          if (targetChapter.url.isNotEmpty) {
            final targetUrl = targetChapter.url.trim();
            return cUrl == targetUrl;
          }
          if (cNum != null && targetChapter.chapterNumber > 0) {
            return cNum == targetChapter.chapterNumber;
          }
          return false;
        }).firstOrNull;
        if (match != null) {
          final resolvedUrl = (match['url'] ?? match['link'] ?? '').toString().trim();
          if (resolvedUrl.isNotEmpty) {
            return resolvedUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('[NavigationController] Self-healing failed: $e');
    }
    return null;
  }

  String? _sourceName;

  void setSourceName(String? sourceName) => _sourceName = sourceName;

  int _chapterTargetId(Chapter ch) => targetIdOf(ch);

  /// Local chapters carry synthetic NEGATIVE serverIds, so `!= 0` (not `> 0`)
  /// is the discriminator.
  static int targetIdOf(Chapter ch) => ch.serverId != 0 ? ch.serverId : ch.id;

  // ── Reading session (moved from ReaderScreen; ISS-125) ───────────────

  Timer? _progressDebounceTimer;
  Future<void>? _progressDebounceFuture;

  /// Debounced progress write. Snapshots chapter + page count now so a rapid
  /// chapter switch never writes the page to the WRONG chapter.
  void debouncedUpdateProgress(int page) {
    final chapterSnapshot = _chapter;
    final totalPagesSnapshot = _pageUrls.length;
    if (chapterSnapshot == null) return;
    _progressDebounceTimer?.cancel();
    _progressDebounceFuture?.ignore();
    _progressDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _progressDebounceFuture = _updateProgressWithSnapshot(page, chapterSnapshot, totalPagesSnapshot);
    });
  }

  void cancelProgressDebounce() {
    _progressDebounceTimer?.cancel();
    _progressDebounceFuture?.ignore();
    _progressDebounceTimer = null;
    _progressDebounceFuture = null;
  }

  /// IMP-012: debounced progress for item [index] of a multi-chapter webtoon
  /// strip. Writes to the chapter that owns the item (never the chapter the
  /// reader was opened on), so crossing a chapterBoundary keeps per-chapter
  /// progress correct.
  void debouncedUpdateProgressForItem(List<ReaderItem> items, int index) {
    final target = PositionManager.progressTargetForItem(items, index);
    if (target == null) return;
    _progressDebounceTimer?.cancel();
    _progressDebounceFuture?.ignore();
    _progressDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _progressDebounceFuture = _updateProgressWithSnapshot(target.page, target.chapter, target.totalPages);
    });
  }

  /// Immediate progress write (exit / lifecycle).
  void updateProgressNow(int page) {
    final chapterSnapshot = _chapter;
    final totalPagesSnapshot = _pageUrls.length;
    if (chapterSnapshot == null || totalPagesSnapshot == 0) return;
    _updateProgressWithSnapshot(page, chapterSnapshot, totalPagesSnapshot).ignore();
  }

  Future<void> _updateProgressWithSnapshot(int page, Chapter chapterSnapshot, int totalPagesSnapshot) async {
    final result = await positionManager.updateProgress(
      chapterSnapshot: chapterSnapshot,
      totalPages: totalPagesSnapshot,
      page: page,
      parentManga: _parentManga,
    );
    if (!result.updated) return;
    if (identical(chapterSnapshot, _chapter) && result.totalPages > 0) {
      mirrorPlatformReadingSession(progress: result.clampedPage / result.totalPages);
    }
    if (result.becameComplete && settings.deleteFinishedChaptersWhileReading == 'Immediately') {
      _deleteAfterRead(chapterSnapshot);
    }
  }

  /// A7.4 / I8.3 / I8.4: mirror the session to home widget, Live Activities
  /// and Siri. Best-effort; skipped in incognito.
  void mirrorPlatformReadingSession({required double? progress}) {
    if (settings.incognitoMode) return;
    final chapter = _chapter;
    if (chapter == null) return;
    final manga = _parentManga;
    final mangaTitle = chapter.mangaTitle.isNotEmpty ? chapter.mangaTitle : (manga?.title ?? 'Unknown');
    final chapterName = chapter.name;
    final mangaId = chapter.mangaId != 0 ? chapter.mangaId : (manga?.canonicalKey ?? 0);
    final chapterId = chapter.serverId != 0 ? chapter.serverId : chapter.id;
    unawaited(WidgetSyncService.instance.updateContinueReading(
      mangaTitle: mangaTitle,
      chapterName: chapterName,
      mangaId: mangaId,
      chapterId: chapterId,
    ));
    if (progress == null) {
      unawaited(LiveActivitiesService.instance.startReading(mangaTitle: mangaTitle, chapterName: chapterName));
      if (mangaId != 0) {
        unawaited(SiriShortcutsService.instance.donateContinueReading(
          mangaTitle: mangaTitle,
          chapterName: chapterName,
          mangaId: mangaId,
        ));
      }
    } else {
      unawaited(LiveActivitiesService.instance.updateProgress(progress));
    }
  }

  /// Post-load housekeeping: download-ahead and "when next chapter opens"
  /// deletion of the previous read chapter.
  void runPostLoadHousekeeping() {
    if (settings.autoDownloadWhileReading) unawaited(triggerDownloadAhead());
    final prev = _prevChapter;
    if (settings.deleteFinishedChaptersWhileReading == 'When next chapter opens' && prev != null && prev.isRead) {
      _deleteAfterRead(prev);
    }
  }

  /// IMP-038: applies the offset ("keep N latest read") and the
  /// exclude-bookmarked option before deleting.
  void _deleteAfterRead(Chapter finished) {
    final target = chapterToDeleteAfterRead(
      finished: finished,
      sortedSiblings: sortSiblingChapters(_siblingChapters),
      offset: settings.deleteAfterReadOffset,
      excludeBookmarked: settings.deleteAfterReadExcludeBookmarked,
    );
    if (target == null) return;
    unawaited(DownloadManagerService.instance.deleteLocalDownload(targetIdOf(target)));
  }

  Future<void> triggerDownloadAhead() async {
    final count = settings.downloadAheadChapterCount;
    final current = _chapter;
    if (count <= 0 || current == null) return;
    final loadGen = _loadGeneration;
    final upcoming = downloadAheadCandidates(
      siblings: _siblingChapters,
      current: current,
      count: count,
      isDownloaded: (c) => DownloadManagerService.instance.isChapterDownloadedLocally(targetIdOf(c)),
    );
    if (upcoming.isEmpty) return;
    final manga = await _mangaFor(current.mangaId);
    final mangaTitle = manga?.title ?? 'Manga';
    if (loadGen != _loadGeneration) return;
    for (final ch in upcoming) {
      unawaited(DownloadManagerService.instance.enqueueLocalDownload(
        chapterId: targetIdOf(ch),
        mangaId: ch.mangaId,
        chapterName: ch.name,
        mangaTitle: mangaTitle,
        chapterNumber: ch.chapterNumber,
      ));
    }
  }

  // Navigation debouncing
  bool _canAdvanceToNextChapter() {
    if (_nextChapter == null) return false;
    final now = DateTime.now();
    if (lastNextChapterNavAt != null &&
        now.difference(lastNextChapterNavAt!) < const Duration(milliseconds: 700)) {
      return false;
    }
    return true;
  }

  bool _canGoToPrevChapterFromTop() {
    if (_prevChapter == null) return false;
    final now = DateTime.now();
    if (lastPrevChapterNavAt != null &&
        now.difference(lastPrevChapterNavAt!) < const Duration(milliseconds: 700)) {
      return false;
    }
    return true;
  }

  // Public accessors for GesturePipeline
  bool canAdvanceToNextChapter() => _canAdvanceToNextChapter();
  bool canGoToPrevChapterFromTop() => _canGoToPrevChapterFromTop();

  // Navigation actions
  void goToNextPage() {
    if (_pageUrls.isEmpty) return;
    if (_currentPage < _pageUrls.length) {
      lastNextChapterNavAt = DateTime.now();
      _currentPage++;
      onPageChanged?.call(_currentPage);
    } else if (_nextChapter != null && _canAdvanceToNextChapter()) {
      lastNextChapterNavAt = DateTime.now();
      unawaited(loadChapterAndPages(_chapterTargetId(_nextChapter!)));
    }
  }

  void goToPrevPage() {
    if (_pageUrls.isEmpty) return;
    if (_currentPage > 1) {
      lastPrevChapterNavAt = DateTime.now();
      _currentPage--;
      onPageChanged?.call(_currentPage);
    } else if (_prevChapter != null && _canGoToPrevChapterFromTop()) {
      lastPrevChapterNavAt = DateTime.now();
      unawaited(loadChapterAndPages(_chapterTargetId(_prevChapter!)));
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _pageUrls.length) {
      _currentPage = page;
      onPageChanged?.call(_currentPage);
    }
  }

  // Prefetch next chapter
  void prefetchNextChapter() {
    if (_nextChapter != null) {
      unawaited(_prefetchNextChapter(_nextChapter!));
    }
  }

  /// Source-free prefetch key shared by writer and reader (UIX-12).
  String _prefetchKey(Chapter chapter) =>
      readerPrefetchKey(chapterTargetId: _chapterTargetId(chapter), mangaId: chapter.mangaId);

  /// IMP-012: [chapter] was left by scrolling past its chapterBoundary.
  /// Writes its last page immediately through the SAME path as a normal end
  /// of chapter (mark read, delete-after-read, sync); PositionManager makes it
  /// a no-op in incognito. Immediate, because the single debounce timer would
  /// otherwise be replaced by the next chapter's page and lose this write.
  Future<void> completeChapterNow(Chapter chapter, int totalPages) async {
    if (totalPages <= 0) return;
    await _updateProgressWithSnapshot(totalPages, chapter, totalPages);
  }

  /// IMP-012: make [chapter] (already shown inline in the webtoon strip) the
  /// current chapter WITHOUT reloading: no resolve, no load generation bump,
  /// no onChapterLoaded (so the view does not restore/jump). next/prev come
  /// from the known siblings; if [chapter] is not among them, the previous
  /// current chapter becomes prev and next stays unknown.
  void adoptStripChapter(Chapter chapter, List<String> urls) {
    final old = _chapter;
    if (old != null && targetIdOf(old) == targetIdOf(chapter)) return;
    _chapter = chapter;
    _currentChapterId = targetIdOf(chapter);
    setPageUrls(urls);
    final sorted = sortSiblingChapters(_siblingChapters);
    final i = findSiblingChapterIndex(sorted, chapter);
    if (i >= 0) {
      _nextChapter = siblingChapterAt(sorted, i, 1);
      _prevChapter = siblingChapterAt(sorted, i, -1);
    } else {
      _prevChapter = old;
      _nextChapter = null;
    }
  }

  /// IMP-012: page URLs of [chapter] if its prefetch has finished, else null.
  /// Does not consume the cache entry (opening the chapter still takes it).
  List<String>? peekPrefetchedPages(Chapter chapter) {
    final urls = pageLoader.peekPrefetchedUrls(_prefetchKey(chapter));
    return (urls == null || urls.isEmpty) ? null : List.unmodifiable(urls);
  }

  /// Public entry for next-chapter prefetch (e.g. near the end of a chapter).
  Future<void> prefetchChapter(Chapter chapter) => _prefetchNextChapter(chapter);

  // Prefetch a specific chapter — mirrors reader_screen._prefetchChapter logic
  Future<void> _prefetchNextChapter(Chapter chapter) async {
    // Capture the generation BEFORE the first await.
    final loadGen = _loadGeneration;

    // Key first (cheap, synchronous in-flight guard), then read the manga for
    // its source inside the guarded section.
    final compositeKey = _prefetchKey(chapter);

    if (pageLoader.isPrefetched(compositeKey) || pageLoader.isPrefetching(compositeKey)) return;

    final lastAttempt = pageLoader.getPrefetchAttemptTime(compositeKey);
    final kPrefetchFailureCooldown = prefetchFailureCooldown;
    if (lastAttempt != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastAttempt * 1000)) < kPrefetchFailureCooldown) {
      return;
    }

    pageLoader.markPrefetching(compositeKey);
    try {
      // ISS-130: honour the "Prefetch next chapter" setting (off / Wi-Fi only).
      if (!await pageLoader.isPrefetchAllowed()) return;
      final manga = await _mangaFor(chapter.mangaId);
      final sourceName = manga?.sourceName ?? 'unknown';
      if (loadGen != _loadGeneration) return;
      final url = chapter.url.isNotEmpty ? chapter.url : chapter.realUrl;
      // Bounded, like the main resolve path.
      final resolved = await _resolve(
        chapterServerId: chapter.serverId > 0 ? chapter.serverId : _chapterTargetId(chapter),
        chapterUrl: url.isNotEmpty ? url : null,
        sourceName: sourceName,
      ).timeout(
        prefetchTimeout,
        onTimeout: () => ChapterPagesResult(
          pageUrls: const <String>[],
          source: ContentSourceType.fallback,
        ),
      );
      // Guard against stale prefetch: if generation changed, discard results
      if (loadGen != _loadGeneration) return;
      if (!pageLoader.isAlive) return;
      if (resolved.pageUrls.isEmpty) {
        // Nothing to cache, so this would otherwise re-fire on every frame.
        pageLoader.setPrefetchAttemptTime(compositeKey, DateTime.now().millisecondsSinceEpoch ~/ 1000);
        debugPrint('[NavigationController] Prefetch for chapter ${_chapterTargetId(chapter)} resolved to no pages; '
            'suppressing re-attempts for ${kPrefetchFailureCooldown.inSeconds}s');
      }
      if (resolved.pageUrls.isNotEmpty) {
        // Enforce max cache size: evict oldest if over limit
        while (pageLoader.getPrefetchCount() >= 3) {
          pageLoader.evictOldestPrefetch();
        }
        // Precache first 3 image bitmaps into Flutter memory cache for 0ms transition
        final effectiveSource = resolved.effectiveSourceName ?? sourceName;
        pageLoader.setPrefetchedChapter(compositeKey, effectiveSource, resolved.pageUrls, sourceType: resolved.source);
        // Succeeded — drop any prior failure mark so a later legitimate
        // re-prefetch is not suppressed.
        pageLoader.clearPrefetchAttemptTime(compositeKey);
        onNextChapterPagesReady?.call(chapter, List.unmodifiable(resolved.pageUrls));
        debugPrint('[NavigationController] Prefetched ${resolved.pageUrls.length} pages for next chapter '
            '${_chapterTargetId(chapter)} (key: $compositeKey)');
        for (final pUrl in resolved.pageUrls.take(3)) {
          if (pUrl.startsWith('http')) {
            try {
              final headers = QuickJsService.getImageHeaders(effectiveSource, pUrl);
              unawaited(pageLoader.loadPage(
                url: pUrl,
                index: 0,
                priority: PageLoadPriority.prefetch,
                sourceName: effectiveSource,
                headers: headers,
              ).catchError((Object e) {
                debugPrint('[NavigationController] Image precache error: $e');
                return PageLoadResult(error: e.toString());
              }));
            } catch (e) {
              debugPrint('[NavigationController] Prefetch headers error: $e');
            }
          }
        }
      }
    } catch (e) {
      pageLoader.setPrefetchAttemptTime(compositeKey, DateTime.now().millisecondsSinceEpoch ~/ 1000);
      debugPrint('[NavigationController] Prefetch failed for chapter ${_chapterTargetId(chapter)}: $e');
    } finally {
      pageLoader.unmarkPrefetching(compositeKey);
    }
  }

  // Dispose
  void dispose() {
    _progressDebounceTimer?.cancel();
    _cancelInFlightResolve();
    if (ownsSubControllers) {
      pageLoader.dispose();
      positionManager.dispose();
    }
  }
}
// ── IMP-012: seamless webtoon chapters (multi-chapter item model) ─────

/// IMP-012: fixed layout extent of a chapterBoundary separator in the strip,
/// so trimming a finished chapter can correct the scroll offset exactly.
const double kReaderChapterBoundaryExtent = 112.0;

/// One chapter's resolved pages, as fed into [buildReaderItems].
class ReaderChapterPages {
  const ReaderChapterPages(this.chapter, this.urls);
  final Chapter chapter;
  final List<String> urls;
}

/// An entry of the webtoon strip: either a page of some chapter or a
/// chapterBoundary separator between two chapters.
sealed class ReaderItem {
  const ReaderItem();
}

/// A page: [pageIndex] is 0-based inside [chapter]; [chapterPageCount] is that
/// chapter's page total so progress is tracked per chapter.
class ReaderPageItem extends ReaderItem {
  const ReaderPageItem({
    required this.chapter,
    required this.pageIndex,
    required this.chapterPageCount,
    required this.url,
  });
  final Chapter chapter;
  final int pageIndex;
  final int chapterPageCount;
  final String url;
}

/// chapterBoundary: the separator after [previous]. [next] is null at the end
/// of the strip when there is no further chapter (or it is not loaded yet).
class ReaderChapterBoundary extends ReaderItem {
  const ReaderChapterBoundary({required this.previous, this.next});
  final Chapter previous;
  final Chapter? next;
}

/// Flattens [chapters] (in reading order) into one strip. A chapterBoundary
/// goes between consecutive chapters and after the last one, whose `next` is
/// [trailingNext]. Chapters with no pages are skipped.
List<ReaderItem> buildReaderItems(
  List<ReaderChapterPages> chapters, {
  Chapter? trailingNext,
}) {
  final nonEmpty = chapters.where((c) => c.urls.isNotEmpty).toList();
  final items = <ReaderItem>[];
  for (var c = 0; c < nonEmpty.length; c++) {
    final entry = nonEmpty[c];
    for (var i = 0; i < entry.urls.length; i++) {
      items.add(ReaderPageItem(
        chapter: entry.chapter,
        pageIndex: i,
        chapterPageCount: entry.urls.length,
        url: entry.urls[i],
      ));
    }
    final next = c + 1 < nonEmpty.length ? nonEmpty[c + 1].chapter : trailingNext;
    items.add(ReaderChapterBoundary(previous: entry.chapter, next: next));
  }
  return items;
}

/// Index of the first item at or after [index] that belongs to a different
/// chapter than the item at [index] (i.e. just past the next chapterBoundary),
/// or -1 when there is none.
int nextChapterStartIndex(List<ReaderItem> items, int index) {
  for (var i = index; i < items.length; i++) {
    if (items[i] is ReaderChapterBoundary) {
      return i + 1 < items.length ? i + 1 : -1;
    }
  }
  return -1;
}
