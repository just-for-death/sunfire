import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/engine/content_resolver_service.dart'
    show ChapterPagesResult, ContentSourceType, ContentResolverService;
import '../../../core/engine/quickjs_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/widget_sync_service.dart';
import '../reader_chapter_navigation.dart';
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

    // Load chapter
    final loadedChapter = await _loadChapter(chapterId);
    if (loadGen != _loadGeneration) return;
    _chapter = loadedChapter;
    if (_chapter == null) return;

    // A7.4: mirror the session to the home-screen widget (best-effort,
    // never blocks chapter load). Skipped in incognito.
    if (!settings.incognitoMode) {
      unawaited(WidgetSyncService.instance.updateContinueReading(
        mangaTitle: _chapter!.mangaTitle.isNotEmpty
            ? _chapter!.mangaTitle
            : (_parentManga?.title ?? 'Unknown'),
        chapterName: _chapter!.name,
        mangaId: _chapter!.mangaId,
        chapterId: _currentChapterId,
      ));
    }

    // Load sibling chapters and determine next/prev
    await _loadSiblingChapters(loadGen);
    if (loadGen != _loadGeneration) return;

    // Resolve chapter pages
    final pageUrls = await _resolveChapterPages(loadGen);
    if (loadGen != _loadGeneration) return;

    // Update state
    _pageUrls = pageUrls;
    _currentPage = 1;

    // Notify owner
    onChapterLoaded?.call(_chapter!, _siblingChapters, _nextChapter, _prevChapter);
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
    _pageUrls = [];
    _cachedPageHeights.clear();
    _cachedPageAspects.clear();
    for (final c in _webtoonZoomControllers.values) {
      c.dispose();
    }
    _webtoonZoomControllers.clear();
    _resetZoom();
  }

  // Load chapter from Isar
  Future<Chapter?> _loadChapter(int chapterId) async {
    Chapter? loadedChapter = await IsarService.instance.getChapterByServerId(chapterId);
    if (loadedChapter == null) {
      // Local-id fallback
      final byLocalId = await IsarService.instance.getChapterByLocalId(chapterId);
      if (byLocalId != null && byLocalId.id == chapterId && byLocalId.serverId <= 0) {
        loadedChapter = byLocalId;
      }
    }
    return loadedChapter;
  }

  // Load sibling chapters and determine next/prev
  Future<void> _loadSiblingChapters(int loadGen) async {
    if (_chapter == null) return;

    final mId = _chapter!.mangaId > 0 ? _chapter!.mangaId : (_parentManga?.serverId ?? _parentManga?.id ?? 0);
    var siblings = await IsarService.instance.getChaptersForManga(mId);
    if (siblings.isEmpty && _parentManga != null) {
      if (_parentManga!.id > 0 && _parentManga!.id != mId) {
        siblings = await IsarService.instance.getChaptersForManga(_parentManga!.id);
      }
      if (siblings.isEmpty && _parentManga!.serverId > 0 && _parentManga!.serverId != mId) {
        siblings = await IsarService.instance.getChaptersForManga(_parentManga!.serverId);
      }
    }
    if (loadGen != _loadGeneration) return;

    _siblingChapters = sortSiblingChapters(siblings);

    final idx = findSiblingChapterIndex(_siblingChapters, _chapter!);
    Chapter? nextCh;
    Chapter? prevCh;
    if (idx != -1) {
      nextCh = siblingChapterAt(_siblingChapters, idx, 1);
      prevCh = siblingChapterAt(_siblingChapters, idx, -1);
    }

    _nextChapter = nextCh;
    _prevChapter = prevCh;

    // Notify next chapter prefetch
    if (nextCh != null) {
      onNextChapterPrefetched?.call(nextCh);
    }
  }

  Future<List<String>> _resolveChapterPages(int loadGen) async {
    if (_chapter == null) return <String>[];

    String? sourceName;
    if (_chapter != null) {
      final manga = await IsarService.instance.getMangaByServerId(_chapter!.mangaId);
      sourceName = manga?.sourceName;
    }

    var chapterUrlToResolve = (_chapter?.url.isNotEmpty == true)
        ? _chapter!.url
        : ((_chapter?.realUrl.isNotEmpty == true) ? _chapter!.realUrl : _chapter?.localPath);

    // On-demand self-healing: If chapter has empty/blank URL in DB, scrape parent manga details immediately!
    if ((chapterUrlToResolve == null || chapterUrlToResolve.isEmpty) && _chapter != null) {
      final manga = await IsarService.instance.getMangaByServerId(_chapter!.mangaId);
      final effectiveSource = sourceName ?? manga?.sourceName ?? '';
      if (manga != null && effectiveSource.isNotEmpty) {
        final String? resolvedUrl = await _selfHealChapterUrl(effectiveSource, _chapter!, loadGen);
        if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
          chapterUrlToResolve = resolvedUrl;
        }
      }
    }

    // Resolve chapter pages via ContentResolverService
    final resolved = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: _chapter!.serverId > 0 ? _chapter!.serverId : _chapterTargetId(_chapter!),
      chapterUrl: chapterUrlToResolve,
      sourceName: _sourceName ?? '',
    ).timeout(const Duration(seconds: 30), onTimeout: () => ChapterPagesResult(
      pageUrls: const <String>[],
      source: ContentSourceType.fallback,
    ));

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