import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/engine/content_resolver_service.dart'
    show ChapterPagesResult, ContentSourceType, ContentResolverService;
import '../../../core/engine/javascript/m_client.dart';
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/download_manager_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/live_activities_service.dart';
import '../../../core/sync/widget_sync_service.dart';
import '../reader_chapter_resolve.dart';
import 'page_loader.dart';
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
  });

  final IsarService isarService;
  final PageLoader pageLoader;
  final PositionManager positionManager;
  final SettingsService settings;

  // Navigation debouncing
  DateTime? _lastNextChapterNavAt;
  DateTime? _lastPrevChapterNavAt;

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

  // Getters for external state
  Chapter? get chapter => _chapter;
  List<Chapter> get siblingChapters => _siblingChapters;
  Chapter? get nextChapter => _nextChapter;
  Chapter? get prevChapter => _prevChapter;
  List<String> get pageUrls => _pageUrls;
  int get currentPage => _currentPage;
  int get currentChapterId => _currentChapterId;
  Manga? get parentManga => _parentManga;
  String? get sourceName => _sourceName;

  // Setters for external state (called by owner)
  void setChapter(Chapter chapter) => _chapter = chapter;
  void setSiblingChapters(List<Chapter> chapters) => _siblingChapters = chapters;
  void setNextChapter(Chapter? chapter) => _nextChapter = chapter;
  void setPrevChapter(Chapter? chapter) => _prevChapter = chapter;
  void setPageUrls(List<String> urls) => _pageUrls = urls;
  void setCurrentPage(int page) => _currentPage = page;
  void setCurrentChapterId(int id) => _currentChapterId = id;

  // Load a chapter and its pages, updating sibling chapters and next/prev.
  Future<void> loadChapterAndPages(int chapterId) async {
    final loadGen = ++_loadGeneration;
    _currentChapterId = chapterId;

    // Flush pending progress write for outgoing chapter before tearing it down
    if (_chapter != null && _pageUrls.isNotEmpty) {
      await positionManager.updateProgress(
        chapterSnapshot: _chapter!,
        totalPages: _pageUrls.length,
        page: _currentPage,
        parentManga: _parentManga,
      );
    }

    // Reset state
    _clearChapterState();
    onLoadingChanged?.call(true);

    // Load chapter
    final loadedChapter = await _loadChapter(chapterId);
    if (loadGen != _loadGeneration) return;
    _chapter = loadedChapter;
    if (_chapter == null) {
      onLoadingChanged?.call(false);
      return;
    }

    if (_parentManga == null) {
      _parentManga = await isarService.getMangaByServerId(_chapter!.mangaId);
    }

    // A7.4: mirror the session to the home-screen widget (best-effort,
    // never blocks chapter load). Skipped in incognito.
    if (!settings.incognitoMode) {
      final mangaTitle = _chapter!.mangaTitle.isNotEmpty
          ? _chapter!.mangaTitle
          : (_parentManga?.title ?? 'Unknown');
      final chapterName = _chapter!.name;
      final mangaId = _chapter!.mangaId != 0
          ? _chapter!.mangaId
          : (_parentManga?.canonicalKey ?? 0);
      final targetId = _chapterTargetId(_chapter!);

      unawaited(WidgetSyncService.instance.updateContinueReading(
        mangaTitle: mangaTitle,
        chapterName: chapterName,
        mangaId: mangaId,
        chapterId: targetId,
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

    // Load sibling chapters and determine next/prev
    await _loadSiblingChapters(loadGen);
    if (loadGen != _loadGeneration) return;

    // Resolve chapter pages
    final pageUrls = await _resolveChapterPages(loadGen);
    if (loadGen != _loadGeneration) return;

    // Update state
    _pageUrls = pageUrls;

    if (_chapter != null && _pageUrls.isNotEmpty && _chapter!.pageCount != _pageUrls.length) {
      _chapter!.pageCount = _pageUrls.length;
      unawaited(isarService.saveChapter(_chapter!));
    }

    // Calculate initial page: resume if unread and lastPageRead > 0
    _currentPage = (_chapter != null &&
            !_chapter!.isRead &&
            _chapter!.lastPageRead > 0 &&
            _chapter!.lastPageRead <= _pageUrls.length)
        ? _chapter!.lastPageRead
        : 1;

    // Proactively pre-fetch first 5 pages on desktop via PageLoader
    if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      for (int i = 0; i < _pageUrls.length && i < 5; i++) {
        unawaited(pageLoader.loadPage(
          url: _pageUrls[i],
          index: i,
          priority: PageLoadPriority.current,
          sourceName: _sourceName,
        ));
      }
    }

    // Single-page chapters: persist progress on open
    if (_pageUrls.length == 1 && _chapter != null && !_chapter!.isRead) {
      unawaited(positionManager.updateProgress(
        chapterSnapshot: _chapter!,
        totalPages: 1,
        page: 1,
        parentManga: _parentManga,
      ));
    }

    // Auto-download ahead
    if (settings.autoDownloadWhileReading) {
      _triggerDownloadAhead();
    }

    // Delete finished chapters when next chapter opens
    if (settings.deleteFinishedChaptersWhileReading == 'When next chapter opens' && _prevChapter != null) {
      if (_prevChapter!.isRead) {
        if (!_prevChapter!.isBookmarked || settings.allowDeletingBookmarkedChapters) {
          unawaited(DownloadManagerService.instance.deleteLocalDownload(_chapterTargetId(_prevChapter!)));
        }
      }
    }

    onLoadingChanged?.call(false);

    // Notify owner
    onChapterLoaded?.call(_chapter!, _siblingChapters, _nextChapter, _prevChapter);
    onPageChanged?.call(_currentPage);

    // Prefetch next chapter in background
    if (_nextChapter != null) {
      prefetchNextChapter();
    }
  }

  int _loadGeneration = 0;
  Manga? _parentManga;

  void setParentManga(Manga? manga) => _parentManga = manga;

  // Clear chapter-related state (keep PageLoader)
  void _clearChapterState() {
    _pageUrls = [];
    _currentPage = 1;
    _nextChapter = null;
    _prevChapter = null;
    _siblingChapters = [];
    _cachedPageHeights.clear();
    _cachedPageAspects.clear();
    for (final c in _webtoonZoomControllers.values) {
      c.dispose();
    }
    _webtoonZoomControllers.clear();
    _resetZoom();
  }

  // Load chapter from Isar (shared resolve with live ReaderScreen).
  Future<Chapter?> _loadChapter(int chapterId) =>
      resolveChapterRecord(isarService, chapterId);

  // Load sibling chapters and determine next/prev.
  Future<void> _loadSiblingChapters(int loadGen) async {
    if (_chapter == null) return;

    final nav = await resolveSiblingChapterNav(
      isar: isarService,
      chapter: _chapter!,
      parentManga: _parentManga,
    );
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

    String? sourceName = _sourceName;
    if (sourceName == null || sourceName.isEmpty) {
      final manga = await isarService.getMangaByServerId(_chapter!.mangaId) ?? _parentManga;
      sourceName = manga?.sourceName;
    }

    var chapterUrlToResolve = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true) ? _chapter!.realUrl : _chapter?.localPath);

    // On-demand self-healing: If chapter has empty/blank URL in DB, scrape parent manga details immediately!
    if ((chapterUrlToResolve == null || chapterUrlToResolve.isEmpty) && _chapter != null) {
      final manga = await isarService.getMangaByServerId(_chapter!.mangaId) ?? _parentManga;
      final effectiveSource = sourceName ?? manga?.sourceName ?? '';
      if (manga != null && effectiveSource.isNotEmpty) {
        final String? resolvedUrl = await _selfHealChapterUrl(effectiveSource, _chapter!, loadGen);
        if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
          chapterUrlToResolve = resolvedUrl;
        }
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

    if (loadGen != _loadGeneration) return <String>[];
    _sourceName = sourceName;

    // Pre-warm FlareSolverr session for this source immediately before resolving
    if (chapterUrlToResolve != null && chapterUrlToResolve.startsWith('http')) {
      try {
        final uri = Uri.parse(chapterUrlToResolve);
        unawaited(MClient.prewarmSession('${uri.scheme}://${uri.host}'));
      } catch (e) {
        debugPrint('[NavigationController] Pre-warm session error: $e');
      }
    }

    // Update pageLoader context for current chapter
    final targetId = _chapterTargetId(_chapter!);
    pageLoader.updateContext(
      sourceName: _sourceName ?? '',
      mangaId: _chapter!.mangaId,
      chapterTargetId: targetId,
    );

    // Check prefetched pages from pageLoader
    final prefetchedUrls = pageLoader.takePrefetchedPages(
      chapterTargetId: targetId,
      mangaId: _chapter!.mangaId,
      sourceName: sourceName,
    );

    if (prefetchedUrls != null && prefetchedUrls.isNotEmpty) {
      return prefetchedUrls;
    }

    // Resolve chapter pages via ContentResolverService
    final resolved = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: _chapter!.serverId > 0 ? _chapter!.serverId : targetId,
      chapterUrl: chapterUrlToResolve,
      sourceName: _sourceName ?? '',
    ).timeout(const Duration(seconds: 30), onTimeout: () => ChapterPagesResult(
      pageUrls: const <String>[],
      source: ContentSourceType.fallback,
    ));

    if (loadGen != _loadGeneration) return <String>[];

    if (resolved.effectiveSourceName != null && resolved.effectiveSourceName!.isNotEmpty) {
      _sourceName = resolved.effectiveSourceName;
    }

    return resolved.pageUrls;
  }

  Future<String?> _selfHealChapterUrl(String effectiveSource, Chapter targetChapter, int loadGen) async {
    try {
      final details = await QuickJsService.instance.fetchMangaDetailsLocal(
        effectiveSource,
        targetChapter.url.isNotEmpty ? targetChapter.url : targetChapter.name,
      );
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
            targetChapter.url = resolvedUrl;
            targetChapter.realUrl = resolvedUrl;
            await isarService.saveChapter(targetChapter);
            if (loadGen != _loadGeneration) return null;
            return resolvedUrl;
          }
        }
      }
    } catch (e) {
      debugPrint('[NavigationController] Self-healing failed: $e');
    }
    return null;
  }

  void _triggerDownloadAhead() async {
    final count = settings.downloadAheadChapterCount;
    if (count <= 0 || _chapter == null) return;
    final currentIdx = _siblingChapters.indexWhere((c) => (c.id == _chapter!.id) || (c.serverId != 0 && c.serverId == _chapter!.serverId));
    if (currentIdx == -1) return;

    final loadGen = _loadGeneration;
    final upcoming = _siblingChapters
        .skip(currentIdx + 1)
        .where((c) => !c.isRead && !DownloadManagerService.instance.isChapterDownloadedLocally(_chapterTargetId(c)))
        .take(count)
        .toList();

    final manga = await isarService.getMangaByServerId(_chapter!.mangaId) ?? _parentManga;
    final mangaTitle = manga?.title ?? 'Manga';

    if (loadGen != _loadGeneration) return;

    for (final ch in upcoming) {
      unawaited(DownloadManagerService.instance.enqueueLocalDownload(
        chapterId: _chapterTargetId(ch),
        mangaId: ch.mangaId,
        chapterName: ch.name,
        mangaTitle: mangaTitle,
        chapterNumber: ch.chapterNumber,
      ));
    }
  }

  String? _sourceName;

  void setSourceName(String? sourceName) => _sourceName = sourceName;

  int _chapterTargetId(Chapter ch) => ch.serverId != 0 ? ch.serverId : ch.id;

  // Navigation debouncing
  bool _canAdvanceToNextChapter() {
    if (_nextChapter == null) return false;
    final now = DateTime.now();
    if (_lastNextChapterNavAt != null &&
        now.difference(_lastNextChapterNavAt!) < const Duration(milliseconds: 700)) {
      return false;
    }
    return true;
  }

  bool _canGoToPrevChapterFromTop() {
    if (_prevChapter == null) return false;
    final now = DateTime.now();
    if (_lastPrevChapterNavAt != null &&
        now.difference(_lastPrevChapterNavAt!) < const Duration(milliseconds: 700)) {
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
      _lastNextChapterNavAt = DateTime.now();
      _currentPage++;
      onPageChanged?.call(_currentPage);
    } else if (_nextChapter != null && _canAdvanceToNextChapter()) {
      _lastNextChapterNavAt = DateTime.now();
      unawaited(loadChapterAndPages(_chapterTargetId(_nextChapter!)));
    }
  }

  void goToPrevPage() {
    if (_pageUrls.isEmpty) return;
    if (_currentPage > 1) {
      _lastPrevChapterNavAt = DateTime.now();
      _currentPage--;
      onPageChanged?.call(_currentPage);
    } else if (_prevChapter != null && _canGoToPrevChapterFromTop()) {
      _lastPrevChapterNavAt = DateTime.now();
      unawaited(loadChapterAndPages(_chapterTargetId(_prevChapter!)));
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _pageUrls.length) {
      _currentPage = page;
      onPageChanged?.call(_currentPage);
      if (_pageUrls.isNotEmpty && page >= (_pageUrls.length * 0.65).round() && _nextChapter != null) {
        prefetchNextChapter();
      }
    }
  }

  // Prefetch next chapter
  void prefetchNextChapter() {
    if (_nextChapter != null) {
      unawaited(_prefetchNextChapter(_nextChapter!));
    }
  }

  // Prefetch a specific chapter
  Future<void> _prefetchNextChapter(Chapter chapter) async {
    // Implementation would go here - uses PageLoader.prefetchChapter
    // For now, delegate to PageLoader
    await pageLoader.prefetchChapter(
      chapterServerId: chapter.serverId > 0 ? chapter.serverId : _chapterTargetId(chapter),
      chapterTargetId: _chapterTargetId(chapter),
      mangaId: chapter.mangaId,
      sourceName: _sourceName ?? '',
      chapterUrl: chapter.url.isNotEmpty ? chapter.url : chapter.realUrl,
    );
  }

  // Recovery and cleanup
  final Map<int, double> _cachedPageHeights = {};
  final Map<String, double> _cachedPageAspects = {};
  final Map<int, TransformationController> _webtoonZoomControllers = {};

  void _resetZoom() {
    // To be implemented by owner
  }

  // Dispose
  void dispose() {
    pageLoader.dispose();
    positionManager.dispose();
    cancelAll();
  }

  void cancelAll() {
    // Cancel any in-flight loads
  }
}