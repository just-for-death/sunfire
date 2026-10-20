// lib/src/features/reader/controller/reader_controller.dart
//
// Central orchestrator for the v6 reader architecture.
// Coordinates PageLoader, PositionManager, NavigationController, and GesturePipeline.
//
// Designed to be independent of UI — no BuildContext, no setState.
// The UI layer (ReaderScreen) listens to callbacks and rebuilds accordingly.

import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable, listEquals;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/metron/metron_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/sync_engine.dart'
    show SyncEngine, syncReaderSettingsMeta;
import '../reader_scroll_utils.dart';
import '../reader_settings_scope.dart';
import '../reading_mode.dart';
import 'gesture_pipeline.dart';
import 'navigation_controller.dart';
import 'page_loader.dart'
    show PageLoader;
import 'position_manager.dart';
import 'reader_theme.dart';
import 'webtoon_item_registry.dart';

/// ReaderController — central state orchestrator for the reader.
///
/// Coordinates:
/// - [PageLoader] for image loading, prefetch, and cache
/// - [PositionManager] for progress persistence and sync
/// - [NavigationController] for chapter/page navigation logic
/// - [GesturePipeline] for gesture, keyboard, and auto-scroll handling
///
/// Designed to be independent of UI — no BuildContext, no setState.
/// All state changes are communicated via callbacks to the UI layer.
class ReaderController {
  factory ReaderController({
    required int chapterServerId,
    required IsarService isarService,
    required SettingsService settings,
    required SyncEngine syncEngine,
    required MetronService metronService,
    PageLoader? pageLoader,
    PositionManager? positionManager,
    NavigationController? navigationController,
    required GesturePipeline gesturePipeline,
  }) =>
      // IMP-049a: the pipeline is always injected; ReaderInputPipeline
      // (screen) or the test builds the only instance and owns its dispose.
      ReaderController._(
        chapterServerId: chapterServerId,
        isarService: isarService,
        settings: settings,
        syncEngine: syncEngine,
        metronService: metronService,
        pageLoader: pageLoader,
        positionManager: positionManager,
        navigationController: navigationController,
        gesturePipeline: gesturePipeline,
      );

  ReaderController._({
    required this.chapterServerId,
    required this.isarService,
    required this.settings,
    required this.syncEngine,
    required this.metronService,
    this._pageLoader,
    this._positionManager,
    NavigationController? navigationController,
    required this._gesturePipeline,
  })  : _navigationController = navigationController,
        _subControllersInjected = navigationController != null,
        _tickerProvider = _TickerProvider();

  final int chapterServerId;
  final IsarService isarService;
  final SettingsService settings;
  final SyncEngine syncEngine;
  final MetronService metronService;

  final _TickerProvider _tickerProvider;

  /// When true, sub-controllers were provided by the caller (tests / DI) and
  /// must not be replaced or double-disposed.
  final bool _subControllersInjected;

  // Sub-controllers (initialized after chapter load, or injected via ctor)
  PageLoader? _pageLoader;
  PositionManager? _positionManager;
  NavigationController? _navigationController;
  final GesturePipeline _gesturePipeline;

  // ─── State ────────────────────────────────────────────────────────
  ReadingMode _readingMode = ReadingMode.longStrip;
  Manga? _parentManga;
  final ReaderSettingsScope _readerSettingsScope = ReaderSettingsScope.global;
  ReaderThemeMode _readerTheme = ReaderThemeMode.black;
  ReaderColorFilter _colorFilter = ReaderColorFilter.none;
  ImageScaleType _scaleType = ImageScaleType.fitWidth;
  bool _cropBorders = false;
  bool _invertTaps = false;
  bool _showTapZoneOverlay = false;
  final bool _showTransitionCard = false;
  bool _isZoomed = false;

  // Auto-scroll state
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 50.0;
  final Map<int, bool> _resumeAutoScrollForChapter = {};

  // Controllers (owned by UI, passed in during initialization)
  ScrollController? _scrollController;
  PageController? _pageController;
  TransformationController? _transformationController;
  Map<int, TransformationController> _webtoonZoomControllers = {};
  AnimationController? _zoomAnimController;

  /// True when [initialize] created the zoom AnimationController itself
  /// (caller passed null) — then dispose owns it too.
  bool _ownsZoomAnimController = false;
  int _currentPage = 1;

  // ─── Callbacks (set by UI) ───────────────────────────────────────
  /// Called when chapter loads (or changes)
  void Function(Chapter chapter, List<Chapter> siblings, Chapter? next, Chapter? prev)?
      onChapterLoaded;

  /// Called when page changes
  void Function(int page)? onPageChanged;

  /// Called when loading state changes
  void Function(bool loading)? onLoadingChanged;

  /// Called when zoom state changes
  void Function(bool isZoomed)? onZoomStateChanged;

  /// Called when auto-scroll state changes
  void Function(bool isAutoScrolling)? onAutoScrollStateChanged;

  /// Called when tap zone overlay should show/hide
  void Function(bool show)? onTapZoneOverlayChanged;

  /// Called to show a snackbar/message
  void Function(String message)? onShowMessage;

  /// Called when reading mode changes
  void Function(ReadingMode mode)? onReadingModeChanged;

  /// Called when parent manga is loaded
  void Function(Manga? manga)? onParentMangaLoaded;

  /// Called when settings should be persisted
  void Function()? onSettingsChanged;

  /// When false the owner (ReaderScreen) restores the start page itself from
  /// [onChapterLoaded]; the controller then skips [_restoreProgress].
  bool restoreProgressOnLoad = true;

  // ─── Getters ──────────────────────────────────────────────────────
  ReadingMode get readingMode => _readingMode;
  Manga? get parentManga => _parentManga;
  ReaderThemeMode get readerTheme => _readerTheme;
  ReaderColorFilter get colorFilter => _colorFilter;
  ImageScaleType get scaleType => _scaleType;
  bool get cropBorders => _cropBorders;
  bool get invertTaps => _invertTaps;
  bool get showTapZoneOverlay => _showTapZoneOverlay;
  bool get showTransitionCard => _showTransitionCard;
  bool get isZoomed => _isZoomed;
  bool get isAutoScrolling => _isAutoScrolling;
  bool get isUserTouching => _gesturePipeline.isUserTouching;
  double get autoScrollSpeed => _autoScrollSpeed;
  int get currentPage => _currentPage;
  List<String> get pageUrls => _navigationController?.pageUrls ?? const [];
  Chapter? get chapter => _navigationController?.chapter;
  Chapter? get nextChapter => _navigationController?.nextChapter;
  Chapter? get prevChapter => _navigationController?.prevChapter;
  List<Chapter> get siblingChapters => _navigationController?.siblingChapters ?? const [];

  // Webtoon zoom controllers
  Map<int, TransformationController> get webtoonZoomControllers => _webtoonZoomControllers;

  /// IMP-028: laid-out webtoon items (GlobalKey-free), filled by ReaderCanvas.
  final WebtoonItemRegistry webtoonItemRegistry = WebtoonItemRegistry();

  // Controllers
  ScrollController? get scrollController => _scrollController;
  PageController? get pageController => _pageController;
  TransformationController? get transformationController => _transformationController;

  // Double-tap zoom details
  Offset? get doubleTapDetails => _gesturePipeline.doubleTapDetails;
  void setDoubleTapDetails(Offset? details) => _gesturePipeline.setDoubleTapDetails(details);

  PageLoader? get pageLoader => _pageLoader;
  PositionManager? get positionManager => _positionManager;
  NavigationController? get navigationController => _navigationController;
  GesturePipeline get gesturePipeline => _gesturePipeline;

  // ─── Initialization ──────────────────────────────────────────────

  /// Bind UI-owned scroll/page/zoom controllers without loading a chapter.
  ///
  /// Used by the live [ReaderScreen] cutover: chapter load stays on the screen
  /// while this orchestrator owns theme/gesture/progress sub-controllers.
  void attachUiControllers({
    required ScrollController scrollController,
    required PageController pageController,
    required TransformationController transformationController,
    AnimationController? zoomAnimController,
    required Map<int, TransformationController> webtoonZoomControllers,
  }) {
    _scrollController = scrollController;
    _pageController = pageController;
    _transformationController = transformationController;
    _zoomAnimController = zoomAnimController;
    _webtoonZoomControllers = webtoonZoomControllers;
    _initPreferences();
    _applySettingsToPipeline();
    // Review H1: the live screen injects sub-controllers and never calls
    // initialize(), so wire NavigationController -> owner callbacks here.
    // Gesture callbacks stay owner-wired (ReaderInputPipeline.wirePipelineCallbacks).
    if (_subControllersInjected) _wireNavigationCallbacksOnce();
  }

  bool _navWired = false;
  void _wireNavigationCallbacksOnce() {
    if (_navWired) return;
    _navWired = true;
    _wireNavigationCallbacks();
  }

  /// Keep PageLoader identity in sync when the live reader recreates it.
  void setPageLoader(PageLoader? loader) {
    _pageLoader = loader;
  }

  /// Mirror live reading-mode / theme for canvas consumers.
  void syncPresentation({
    required ReadingMode readingMode,
    required ReaderThemeMode readerTheme,
    required ReaderColorFilter colorFilter,
    required ImageScaleType scaleType,
    required bool cropBorders,
    required bool invertTaps,
    required bool isZoomed,
    required int currentPage,
  }) {
    _readingMode = readingMode;
    _readerTheme = readerTheme;
    _colorFilter = colorFilter;
    _scaleType = scaleType;
    _cropBorders = cropBorders;
    _invertTaps = invertTaps;
    _isZoomed = isZoomed;
    _currentPage = currentPage;
  }

  /// Initialize the controller and load the initial chapter.
  Future<void> initialize({
    required ScrollController scrollController,
    required PageController pageController,
    required TransformationController transformationController,
    AnimationController? zoomAnimController,
    required Map<int, TransformationController> webtoonZoomControllers,
  }) async {
    _ownsZoomAnimController = zoomAnimController == null;
    attachUiControllers(
      scrollController: scrollController,
      pageController: pageController,
      transformationController: transformationController,
      zoomAnimController: zoomAnimController ??
          AnimationController(
            vsync: _tickerProvider,
            duration: const Duration(milliseconds: 200),
          ),
      webtoonZoomControllers: webtoonZoomControllers,
    );

    // Injected sub-controllers skip the Isar-backed _initSubControllers path,
    // so wire callbacks here once.
    if (_subControllersInjected) {
      _wireNavigationCallbacksOnce();
      _wireGestureCallbacks();
    }

    unawaited(loadChapter(chapterServerId));
  }

  void _initPreferences() {
    _readingMode = parseReadingMode(settings.readingMode);
    _readerTheme = parseReaderTheme(settings.readerTheme);
    _colorFilter = parseColorFilter(settings.colorFilter);
    _scaleType = parseScaleType(settings.scaleType);
    _cropBorders = settings.cropBorders;
    _invertTaps = settings.invertTapZones;
    _autoScrollSpeed = settings.defaultAutoScrollSpeed;

    if (!settings.tapZonesOverlaySeen && settings.tapZonesEnabled) {
      _showTapZoneOverlay = true;
      onTapZoneOverlayChanged?.call(true);
    }
  }

  void _applySettingsToPipeline() {
    _gesturePipeline
      ..setReadingMode(_readingMode)
      ..setInvertTaps(_invertTaps);
    _gesturePipeline.setInvertTaps(_invertTaps);
    _gesturePipeline.setAutoScrollSpeed(_autoScrollSpeed);
    _gesturePipeline.setIsAutoScrolling(_isAutoScrolling);
    _gesturePipeline.setShowTapZoneOverlay(_showTapZoneOverlay);
    _gesturePipeline.setIsZoomed(_isZoomed);
    _gesturePipeline.setTransformationController(_transformationController);
    _gesturePipeline.setWebtoonZoomControllers(_webtoonZoomControllers);
    _gesturePipeline.setZoomAnimController(_zoomAnimController);
    _gesturePipeline.setScrollController(_scrollController);
  }

  // ─── Private: Initialize Sub-controllers ──────────────────────────

  void _initSubControllers(Chapter chapter) {
    if (_subControllersInjected) {
      _wireNavigationCallbacksOnce();
      _wireGestureCallbacks();
      return;
    }

    final sourceName = _parentManga?.sourceName ?? '';
    _pageLoader = PageLoader(
      sourceName: sourceName,
      mangaId: chapter.mangaId,
      chapterTargetId: chapter.serverId != 0 ? chapter.serverId : chapter.id,
    );

    _positionManager = PositionManager(
      settings: settings,
      isarService: isarService,
      syncEngine: syncEngine,
      metronService: metronService,
    );

    _navigationController = NavigationController(
      isarService: isarService,
      pageLoader: _pageLoader!,
      positionManager: _positionManager!,
      settings: settings,
      ownsSubControllers: false,
    );

    _wireNavigationCallbacks();
    _wireGestureCallbacks();
  }

  void _wireNavigationCallbacks() {
    _navWired = true;
    _navigationController!.onChapterLoaded = (chapter, siblings, next, prev) {
      _currentPage = 1;
      _gesturePipeline.setCurrentPage(1);
      _gesturePipeline.setPageUrls(_navigationController!.pageUrls);
      _gesturePipeline.setNextChapter(next);
      _gesturePipeline.setPrevChapter(prev);

      // Reset zoom state on chapter change
      _isZoomed = false;
      onZoomStateChanged?.call(false);

      onChapterLoaded?.call(chapter, siblings, next, prev);
      _stripLog = const []; // a real load starts a fresh strip
      _stripExtents.clear();
      refreshStripChapters();

      // Auto-scroll resume logic
      final nextChapterId = next != null
          ? (next.serverId != 0 ? next.serverId : next.id)
          : 0;
      if (_resumeAutoScrollForChapter[nextChapterId] == true) {
        _resumeAutoScrollForChapter.remove(nextChapterId);
        _startAutoScroll();
      }
    };

    _navigationController!.onPageChanged = (page) {
      _currentPage = page;
      _gesturePipeline.setCurrentPage(page);
      onPageChanged?.call(page);

      // Update progress debounced
      _debounceProgressUpdate();
    };

    _navigationController!.onNextChapterPrefetched = (chapter) {
      _gesturePipeline.setNextChapter(chapter);
      refreshStripChapters();
    };

    // IMP-012: the strip grows once the next chapter's pages are ready.
    _navigationController!.onNextChapterPagesReady = (chapter, urls) {
      refreshStripChapters();
    };

    _navigationController!.onLoadingChanged = (loading) {
      onLoadingChanged?.call(loading);
    };
  }

  void _wireGestureCallbacks() {
    _gesturePipeline.onLoadNextChapter = () => loadNextChapter();
    _gesturePipeline.onLoadPrevChapter = () => loadPrevChapter();
    _gesturePipeline.onToggleControls = _toggleControls;
    _gesturePipeline.onStopAutoScroll = _stopAutoScroll;
    _gesturePipeline.onScrollVerticalBy = (delta) {
      if (_scrollController != null && _scrollController!.hasClients) {
        final target = (_scrollController!.offset + delta).clamp(
          0.0,
          _scrollController!.position.maxScrollExtent,
        );
        _scrollController!.jumpTo(target);
      }
    };
    _gesturePipeline.onPageChanged = (page) {
      _currentPage = page;
      _navigationController?.setCurrentPage(page);
      onPageChanged?.call(page);
    };
    _gesturePipeline.onAnimateScroll = (offset, {Duration? duration, Curve? curve}) {
      if (_scrollController != null && _scrollController!.hasClients) {
        if (duration != null && duration > Duration.zero) {
          _scrollController!.animateTo(offset, duration: duration, curve: curve ?? Curves.easeOutCubic);
        } else {
          _scrollController!.jumpTo(offset);
        }
      }
    };
    _gesturePipeline.onAnimatePage = ({Duration? duration, Curve? curve}) {
      if (_pageController != null && _pageController!.hasClients) {
        final current = _pageController!.page?.round() ?? 0;
        final next = current + 1;
        if (next < _pageController!.positions.first.maxScrollExtent) {
          _pageController!.animateToPage(next, duration: duration ?? const Duration(milliseconds: 220), curve: curve ?? Curves.easeOutCubic);
        }
      }
    };
    _gesturePipeline.getMaxScrollExtent = () => _scrollController?.position.maxScrollExtent ?? 0.0;
    _gesturePipeline.getCurrentScrollOffset = () => _scrollController?.offset ?? 0.0;
    _gesturePipeline.getScreenHeight = () => _scrollController?.position.viewportDimension ?? 800.0;
    _gesturePipeline.pageControllerHasClients = () => _pageController?.hasClients ?? false;
    _gesturePipeline.scrollControllerHasClients = () => _scrollController?.hasClients ?? false;
    _gesturePipeline.pageControllerPage = () => _pageController?.page ?? 0.0;
    _gesturePipeline.onTapZoneOverlayChanged = (show) {
      _showTapZoneOverlay = show;
      onTapZoneOverlayChanged?.call(show);
    };
    _gesturePipeline.onZoomStateChanged = (zoomed) {
      _isZoomed = zoomed;
      onZoomStateChanged?.call(zoomed);
    };
    _gesturePipeline.onUserTouchingChanged = (touching) {
      // Handled internally by gesture pipeline
    };
  }

  // ─── Public API: Chapter Loading ─────────────────────────────────

  bool _disposed = false;

  /// Load a chapter and its pages via NavigationController. No-op after
  /// dispose: pre-dispose loads check the generation below.
  Future<void> loadChapter(int chapterId) async {
    if (_disposed) return;
    await _loadChapterAndPagesViaNavigation(chapterId);
  }

  /// Scaffold / test path: NavigationController owns resolve + sibling sync.
  int _controllerLoadGen = 0;

  Future<void> _loadChapterAndPagesViaNavigation(int chapterId) async {
    final gen = ++_controllerLoadGen;
    onLoadingChanged?.call(true);

    try {
      // If sub-controllers not initialized yet, load chapter first to get source info
      // Check generation token before and after async operations to prevent
      // double-initialization race with concurrent loadChapter calls.
      if (_navigationController == null) {
        final loadedChapter = await isarService.getChapterByServerId(chapterId);
        if (gen != _controllerLoadGen) return; // Superseded by newer load
        if (loadedChapter == null) {
          final byLocalId = await isarService.getChapterByLocalId(chapterId);
          if (gen != _controllerLoadGen) return;
          if (byLocalId != null && byLocalId.id == chapterId && byLocalId.serverId <= 0) {
            _initSubControllers(byLocalId);
          }
        } else {
          _initSubControllers(loadedChapter);
        }
      }
      if (_navigationController != null) {
        await _navigationController!.loadChapterAndPages(chapterId);
      }
    } catch (e) {
      // Never leave a permanent spinner: the owner renders the empty state.
      debugPrint('[ReaderController] Chapter load failed: $e');
    } finally {
      // ISS-122: "loading finished" always fires (even if the catch itself
      // throws); a superseded load must not clear the newer load's spinner.
      if (gen == _controllerLoadGen) onLoadingChanged?.call(false);
    }
    if (gen != _controllerLoadGen) return;

    // IMP-013: apply the per-series override at chapter open. The controller
    // never had a parent manga before, so overrides were saved but not read.
    await _applySeriesOverrideOnOpen();
    if (gen != _controllerLoadGen) return;

    // Restore progress after chapter loads
    if (restoreProgressOnLoad &&
        _navigationController?.chapter != null &&
        _navigationController!.pageUrls.isNotEmpty) {
      await _restoreProgress();
    }
  }

  Future<void> _applySeriesOverrideOnOpen() async {
    try {
      final nav = _navigationController;
      var manga = nav?.parentManga ?? _parentManga;
      final mangaId = nav?.chapter?.mangaId ?? 0;
      if (manga == null && mangaId != 0) manga = await isarService.getManga(mangaId);
      if (manga == null) return;
      _parentManga = manga;
      onParentMangaLoaded?.call(manga);
      // IMP-005: pull/push the roaming per-series override first (bounded).
      try {
        await syncReaderSettingsMeta(manga: manga, settings: settings)
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('[ReaderController] reader settings meta sync skipped: $e');
      }
      applySeriesSettings(manga);
    } catch (e) {
      debugPrint('[ReaderController] Series override not applied: $e');
    }
  }

  /// IMP-013: effective reader values for [manga] (series override where set,
  /// global settings otherwise).
  static ReaderSettingsValues resolveSeriesSettings(SettingsService s, Manga manga) =>
      loadReaderSettingsOverride(s, manga.id, readingModeOverride: manga.readingModeOverride)
          .resolve(ReaderSettingsValues.fromSettings(s));

  /// IMP-013: applies [resolveSeriesSettings] to the controller state.
  void applySeriesSettings(Manga manga) {
    final v = resolveSeriesSettings(settings, manga);
    _readingMode = parseReadingMode(v.readingMode);
    _scaleType = parseScaleType(v.scaleType);
    _cropBorders = v.cropBorders;
    _invertTaps = v.invertTapZones;
    _gesturePipeline
      ..setReadingMode(_readingMode)
      ..setInvertTaps(_invertTaps);
  }

  // ─── IMP-012: seamless webtoon strip source ──────────────────────

  bool _stripDisposed = false;
  final ValueNotifier<List<ReaderChapterPages>> _stripChapters =
      ValueNotifier<List<ReaderChapterPages>>(const <ReaderChapterPages>[]);

  /// Chapters for the webtoon strip: the current chapter's pages, plus the
  /// next chapter's once its prefetch has finished. Feed to [buildReaderItems].
  List<ReaderChapterPages> get stripChapters => _stripChapters.value;

  /// Notifies when [stripChapters] changes (chapter change / prefetch done).
  ValueListenable<List<ReaderChapterPages>> get stripChaptersListenable => _stripChapters;

  /// Rebuilds [stripChapters] from the NavigationController; only notifies
  /// when the content actually changed.
  ///
  /// After an inline chapter switch ([onStripItemVisible]) the chapters
  /// already in the strip are KEPT in order, so item indices never shift
  /// under the reader; a real [loadChapter] starts a fresh strip.
  void refreshStripChapters() {
    if (_stripDisposed) return;
    final nav = _navigationController;
    final current = nav?.chapter;
    final urls = nav?.pageUrls ?? const <String>[];
    if (nav == null || current == null || urls.isEmpty) {
      _stripLog = [];
    } else {
      final ci = _stripIndexOf(current);
      if (ci < 0) {
        _stripLog = [ReaderChapterPages(current, List.unmodifiable(urls))];
      }
      final next = nav.nextChapter;
      final nextUrls = next == null ? null : nav.peekPrefetchedPages(next);
      if (next != null &&
          nextUrls != null &&
          _stripIndexOf(next) < 0 &&
          _stripIndexOf(current) == _stripLog.length - 1) {
        _stripLog = [..._stripLog, ReaderChapterPages(next, nextUrls)];
      }
    }
    if (!_sameStrip(_stripLog, _stripChapters.value)) {
      _stripChapters.value = List.unmodifiable(_stripLog);
      _stripItemsCache = null;
    }
  }

  List<ReaderChapterPages> _stripLog = const [];

  /// History of trimmed chapters (for scroll-back restoration).
  /// Chapters trimmed from the front of the strip are moved here instead
  /// of being discarded, so they can be restored if the user scrolls back up.
  final List<ReaderChapterPages> _stripHistory = [];

  List<ReaderItem>? _stripItemsCache;

  int _stripIndexOf(Chapter c) {
    final id = NavigationController.targetIdOf(c);
    return _stripLog.indexWhere((e) => NavigationController.targetIdOf(e.chapter) == id);
  }

  /// IMP-012: the items the webtoon view shows when a strip is active (same
  /// rule as the view: seamless transitions on and 2+ chapters), else null.
  List<ReaderItem>? get activeStripItems {
    if (_stripDisposed) return null;
    final strip = _stripChapters.value;
    if (strip.length < 2 || !settings.seamlessTransitions) return null;
    return _stripItemsCache ??= buildReaderItems(strip);
  }

  /// IMP-012: item index of the current chapter's first page in
  /// [activeStripItems] (0 before any inline switch). Null without a strip.
  int? get stripCurrentChapterOffset {
    final items = activeStripItems;
    final cur = _navigationController?.chapter;
    if (items == null || cur == null) return null;
    final id = NavigationController.targetIdOf(cur);
    final i = items.indexWhere(
        (e) => e is ReaderPageItem && NavigationController.targetIdOf(e.chapter) == id);
    return i < 0 ? null : i;
  }

  /// Fired after an inline strip chapter switch (no reload): the view should
  /// update its chapter/next/prev/page-count state WITHOUT scrolling.
  void Function(Chapter chapter, Chapter? next, Chapter? prev)? onStripChapterSwitched;

  /// IMP-012: measured extents of strip items (by item index), recorded by
  /// the input pipeline while scanning visible pages. Used to correct the
  /// scroll offset exactly when finished chapters are trimmed.
  final Map<int, double> _stripExtents = {};
  void recordStripItemExtent(int index, double extent) => _stripExtents[index] = extent;

  /// Measured extent of strip item [index], or null if never laid out.
  double? recordedStripItemExtent(int index) => _stripExtents[index];

  /// IMP-012: the webtoon item [itemIndex] of [activeStripItems] is the most
  /// visible one.
  /// 1. Saves progress to the chapter owning it (no-op in incognito).
  /// 2. Once it belongs to another chapter, switches the current chapter in
  ///    place (no reload/jump), moves the ISS-135 pinned cache set to it (via
  ///    NavigationController.setPageUrls), and when moving forward completes
  ///    the chapter that was left through the normal end-of-chapter path.
  /// 3. When the reader is 2+ pages into the current chapter, earlier
  ///    chapters are trimmed ([A,B]+C -> [B,C]); the caller must shift its
  ///    index-keyed maps by `removedItems` and correct the scroll offset by
  ///    `removedExtent` in the same frame (no jump or flash).
  ({int page, int removedItems, double removedExtent})? onStripItemVisible(
    int itemIndex, {
    double contentWidth = 0,
  }) {
    if (_disposed) return null;
    final items = activeStripItems;
    final nav = _navigationController;
    if (items == null || nav == null) return null;
    final target = PositionManager.progressTargetForItem(items, itemIndex);
    if (target == null) return null;
    nav.debouncedUpdateProgressForItem(items, itemIndex);
    final cur = nav.chapter;
    final item = items[itemIndex];
    if (item is ReaderPageItem &&
        (cur == null ||
            NavigationController.targetIdOf(cur) != NavigationController.targetIdOf(item.chapter))) {
      final from = cur == null ? -1 : _stripIndexOf(cur);
      final to = _stripIndexOf(item.chapter);
      if (cur != null && from >= 0 && to > from) {
        // Forward across the separator: only the chapter being LEFT is done.
        // Previously this marked ALL chapters between from and to as complete,
        // but the user may have scrolled past them without reading.
        final e = _stripLog[from];
        unawaited(nav.completeChapterNow(e.chapter, e.urls.length));
      }
      final entry = _stripLog[to];
      nav.adoptStripChapter(entry.chapter, entry.urls);
      _gesturePipeline
        ..setPageUrls(nav.pageUrls)
        ..setNextChapter(nav.nextChapter)
        ..setPrevChapter(nav.prevChapter);
      refreshStripChapters();
      onStripChapterSwitched?.call(entry.chapter, nav.nextChapter, nav.prevChapter);
      final next = nav.nextChapter;
      if (next != null) unawaited(nav.prefetchChapter(next));
    }
    _currentPage = target.page;
    _gesturePipeline.setCurrentPage(target.page);

    var removedItems = 0;
    var removedExtent = 0.0;
    final curIdx = nav.chapter == null ? -1 : _stripIndexOf(nav.chapter!);
    if (item is ReaderPageItem && item.pageIndex >= 2 && curIdx > 0) {
      for (var c = 0; c < curIdx; c++) {
        final e = _stripLog[c];
        for (var i = 0; i < e.urls.length; i++) {
          removedExtent += _stripExtents[removedItems] ?? _estimatePageExtent(e.urls[i], contentWidth);
          removedItems++;
        }
        removedExtent += _stripExtents[removedItems] ?? kReaderChapterBoundaryExtent;
        removedItems++;
      }
      // Move trimmed chapters to history instead of discarding them
      _stripHistory.insertAll(0, _stripLog.sublist(0, curIdx));
      _stripLog = _stripLog.sublist(curIdx);
      final shifted = <int, double>{
        for (final e in _stripExtents.entries)
          if (e.key >= removedItems) e.key - removedItems: e.value,
      };
      _stripExtents
        ..clear()
        ..addAll(shifted);
      _stripChapters.value = List.unmodifiable(_stripLog);
      _stripItemsCache = null;
    }
    return (page: target.page, removedItems: removedItems, removedExtent: removedExtent);
  }

  static bool _sameStrip(List<ReaderChapterPages> a, List<ReaderChapterPages> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i].chapter, b[i].chapter) || !listEquals(a[i].urls, b[i].urls)) return false;
    }
    return true;
  }

  double _estimatePageExtent(String url, double contentWidth) {
    final w = contentWidth > 0 ? contentWidth : 400.0;
    final cached = _pageLoader?.getCachedHeight(url) ?? 0.0;
    return estimateWebtoonPlaceholderHeight(w, cachedHeight: cached) + webtoonPageGap(_readingMode);
  }

  /// Load the next chapter (uses synced [NavigationController.nextChapter]).
  Future<void> loadNextChapter() async {
    final next = _navigationController?.nextChapter;
    if (next == null) return;
    final id = next.serverId != 0 ? next.serverId : next.id;
    await loadChapter(id);
  }

  /// Load the previous chapter.
  Future<void> loadPrevChapter() async {
    final prev = _navigationController?.prevChapter;
    if (prev == null) return;
    final id = prev.serverId != 0 ? prev.serverId : prev.id;
    await loadChapter(id);
  }

  /// Restore reading progress for current chapter.
  Future<void> _restoreProgress() async {
    final gen = _controllerLoadGen;
    final nav = _navigationController;
    final chapter = nav?.chapter;
    if (_disposed || chapter == null || nav!.pageUrls.isEmpty) return;

    // Read progress from chapter object (already loaded from Isar)
    final lastPage = chapter.lastPageRead.clamp(1, nav.pageUrls.length);
    final isComplete = chapter.isRead;

    // Only restore if not at start and not already at end
    if (lastPage > 1 || isComplete) {
      if (_disposed || gen != _controllerLoadGen) return;
      _currentPage = lastPage;
      nav.setCurrentPage(_currentPage);
      _gesturePipeline.setCurrentPage(_currentPage);

      // Jump to position
      final isPaged = isPagedReadingMode(_readingMode);
      if (isPaged && _pageController != null && _pageController!.hasClients) {
        final targetPage = _pagedControllerIndexForPage(_currentPage);
        _pageController!.jumpToPage(targetPage);
      } else if (!isPaged && _scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_disposed || gen != _controllerLoadGen) return;
          _jumpToWebtoonPage(_currentPage);
        });
      }
    }
  }

  int _pagedControllerIndexForPage(int page) {
    // PageView indices are always 0-based page indices; reverse:true already
    // handles RTL direction. (A length-page mirror here double-counts and
    // restores RTL+double to the wrong spread.)
    return (page - 1).clamp(0, (_navigationController?.pageUrls.length ?? 1) - 1);
  }

  void _jumpToWebtoonPage(int page) {
    final nav = _navigationController;
    if (_disposed || _scrollController == null || !_scrollController!.hasClients || nav == null || nav.pageUrls.isEmpty) {
      return;
    }
    final width = _scrollController!.position.viewportDimension;
    final contentWidth = width > 800 ? 780.0 : width;
    final offset = resumeOffsetForPage(
      targetPage: page,
      pageCount: nav.pageUrls.length,
      heightForIndex: (int i) {
        final url = nav.pageUrls[i];
        final cachedHeight = _pageLoader?.getCachedHeight(url) ?? 0.0;
        return estimateWebtoonPlaceholderHeight(contentWidth, cachedHeight: cachedHeight);
      },
      gapAfterIndex: (i) => webtoonPageGap(_readingMode),
    );
    final maxScroll = _scrollController!.position.maxScrollExtent;
    _scrollController!.jumpTo(maxScroll > 0 ? offset.clamp(0.0, maxScroll) : offset);
  }

  // ─── Public API: Reading Mode ────────────────────────────────────

  /// Apply a reading mode change.
  Future<void> setReadingMode(ReadingMode mode, {bool showSnack = false}) async {
    _gesturePipeline.stopAutoScroll();
    _resetZoom();

    _readingMode = mode;
    _gesturePipeline.setReadingMode(mode);
    onReadingModeChanged?.call(mode);
    await _persistReadingMode(mode);

    // Restore position for new mode
    _restoreReaderPositionForMode();

    if (showSnack) {
      onShowMessage?.call('Reading Mode: ${readingModeSnackLabel(_readingMode)}');
    }
  }

  Future<void> _persistReadingMode(ReadingMode mode) async {
    final value = readingModeSettingsValue(mode);
    final plan = planReadingModePersist(
      scope: _readerSettingsScope,
      modeValue: value,
      hasManga: _parentManga != null,
    );
    if (plan.globalValue != null) {
      settings.readingMode = plan.globalValue!;
    }
    if (_parentManga != null) {
      if (plan.clearMangaOverride) {
        _parentManga!.readingModeOverride = null;
        await isarService.saveManga(_parentManga!);
      } else if (plan.mangaOverride != null) {
        _parentManga!.readingModeOverride = plan.mangaOverride;
        await isarService.saveManga(_parentManga!);
      }
    }
  }

  void _restoreReaderPositionForMode() {
    if (_disposed) return;
    final gen = _controllerLoadGen;
    final isPaged = isPagedReadingMode(_readingMode);
    if (isPaged && _pageController != null && _pageController!.hasClients) {
      final targetPage = _pagedControllerIndexForPage(_currentPage);
      _pageController!.jumpToPage(targetPage);
    } else if (!isPaged && _scrollController != null && (_navigationController?.pageUrls.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed || gen != _controllerLoadGen) return;
        _jumpToWebtoonPage(_currentPage);
      });
    }
  }

  // ─── Public API: Auto-Scroll ────────────────────────────────────

  void _startAutoScroll() {
    _resetZoom();
    _isAutoScrolling = true;
    _gesturePipeline.setIsAutoScrolling(true);
    _gesturePipeline.startAutoScroll();
    onAutoScrollStateChanged?.call(true);
  }

  void _stopAutoScroll() {
    _isAutoScrolling = false;
    _gesturePipeline.setIsAutoScrolling(false);
    _gesturePipeline.stopAutoScroll();
    onAutoScrollStateChanged?.call(false);
  }

  void toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void adjustAutoScrollSpeed(double delta) {
    _autoScrollSpeed = (_autoScrollSpeed + delta).clamp(10.0, 2000.0);
    _gesturePipeline.adjustAutoScrollSpeed(delta);
    settings.defaultAutoScrollSpeed = _autoScrollSpeed;
    onSettingsChanged?.call();
  }

  // ─── Public API: Zoom ────────────────────────────────────────────

  void _resetZoom({bool animate = false}) {
    _cancelZoomAnimation();
    for (final c in _webtoonZoomControllers.values) {
      c.value = Matrix4.identity();
    }
    if (!animate || _zoomAnimController == null) {
      _transformationController?.value = Matrix4.identity();
      if (_isZoomed) {
        _isZoomed = false;
        onZoomStateChanged?.call(false);
      }
      return;
    }
    _animateZoomTo(Matrix4.identity(), markZoomed: false);
  }

  void _cancelZoomAnimation() {
    _zoomAnimController?.stop();
    _activeZoomCurve?.dispose();
    _activeZoomCurve = null;
    _zoomGeneration++;
  }

  void _animateZoomTo(
    Matrix4 end, {
    required bool markZoomed,
    TransformationController? controllerOverride,
  }) {
    final transform = controllerOverride ?? _transformationController;
    final controller = _zoomAnimController;

    if (controller == null || transform == null) {
      transform?.value = end;
      if (markZoomed != _isZoomed) {
        _isZoomed = markZoomed;
        onZoomStateChanged?.call(markZoomed);
      }
      return;
    }

    _cancelZoomAnimation();
    final begin = Matrix4.copy(transform.value);
    controller.reset();
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    final animation = Matrix4Tween(begin: begin, end: end).animate(curved);
    _activeZoomCurve = curved;

    final gen = _zoomGeneration;
    void tick() {
      if (gen != _zoomGeneration) return;
      // The controller may have been disposed while this animation was in
      // flight; a write then throws StateError.
      try {
        transform.value = animation.value;
      } catch (_) {
        return;
      }
    }

    _zoomTickListener = tick;
    controller.addListener(tick);

    unawaited(controller.forward().whenComplete(() {
      if (gen != _zoomGeneration) return;
      if (_zoomTickListener != null) {
        controller.removeListener(_zoomTickListener!);
        _zoomTickListener = null;
      }
      _activeZoomCurve?.dispose();
      _activeZoomCurve = null;
      if (markZoomed != _isZoomed) {
        _isZoomed = markZoomed;
        onZoomStateChanged?.call(markZoomed);
      }
    }));
  }

  // Zoom state
  CurvedAnimation? _activeZoomCurve;
  VoidCallback? _zoomTickListener;
  int _zoomGeneration = 0;

  // ─── Public API: Settings ────────────────────────────────────────

  void updateTheme(ReaderThemeMode theme) {
    _readerTheme = theme;
    onSettingsChanged?.call();
  }

  void updateColorFilter(ReaderColorFilter filter) {
    _colorFilter = filter;
    onSettingsChanged?.call();
  }

  void updateScaleType(ImageScaleType type) {
    _scaleType = type;
    onSettingsChanged?.call();
  }

  void updateCropBorders(bool value) {
    _cropBorders = value;
    settings.cropBorders = value;
    onSettingsChanged?.call();
  }

  void updateInvertTaps(bool value) {
    _invertTaps = value;
    settings.invertTapZones = value;
    _gesturePipeline.setInvertTaps(value);
    onSettingsChanged?.call();
  }

  void updateTapZoneOverlaySeen() {
    if (!settings.tapZonesOverlaySeen && settings.tapZonesEnabled) {
      _showTapZoneOverlay = true;
      _gesturePipeline.setShowTapZoneOverlay(true);
      onTapZoneOverlayChanged?.call(true);
    }
  }

  void dismissTapZoneOverlay() {
    if (!_showTapZoneOverlay) return;
    _showTapZoneOverlay = false;
    _gesturePipeline.dismissTapZoneOverlay();
    onTapZoneOverlayChanged?.call(false);
    settings.tapZonesOverlaySeen = true;
  }

  // ─── Private Helpers ─────────────────────────────────────────────

  void _debounceProgressUpdate() {
    // Route through NavigationController's coalescing timer (it snapshots the
    // chapter and cancels superseded writes). The input pipeline persists on
    // every page change through the same timer, so at most one write lands.
    _navigationController?.debouncedUpdateProgress(_currentPage);
  }

  void _toggleControls() {
    // UI should implement this callback
  }

  // ─── Public API for Canvas ────────────────────────────────────────

  /// Stop auto-scroll (public for canvas).
  void stopAutoScroll() => _stopAutoScroll();

  /// Reset zoom (public for canvas).
  void resetZoom({bool animate = false}) => _resetZoom(animate: animate);

  /// Handle double-tap zoom (public for canvas).
  void handleDoubleTapZoom({TransformationController? controllerOverride}) =>
      _gesturePipeline.handleDoubleTapZoom(controllerOverride: controllerOverride);

  // ─── Dispose ──────────────────────────────────────────────────────

  void dispose() {
    // Invalidate every in-flight load/zoom/restore continuation first: they
    // all check the generation or _disposed before touching state.
    _disposed = true;
    _controllerLoadGen++;
    // The screen owns (and disposes) the zoom AnimationController; drop our
    // reference first so _cancelZoomAnimation doesn't call stop() on a
    // disposed controller. Curve disposal + generation bump still run.
    _zoomAnimController = null;
    _cancelZoomAnimation();
    // The injected GesturePipeline is owned (and disposed) by the caller.
    // Injected NavigationController (and its PageLoader/PositionManager) are
    // owned by the caller — do not dispose. Production NavigationController
    // dispose() also tears down pageLoader + positionManager.
    if (!_subControllersInjected) {
      try {
        _navigationController?.dispose();
      } catch (e) { debugPrint('[reader_controller] ignored: $e'); }
    }
    _navigationController = null;
    _pageLoader = null;
    _positionManager = null;
    // UI-owned controllers: only drop references, never dispose.
    // The owning widget (ReaderScreen/test) disposes these.
    _scrollController = null;
    _pageController = null;
    _transformationController = null;
    _zoomAnimController = null;
    _webtoonZoomControllers = {};
    _resumeAutoScrollForChapter.clear();
    if (_ownsZoomAnimController) {
      try {
        _zoomAnimController?.dispose();
      } catch (e) { debugPrint('[reader_controller] ignored: $e'); }
      _ownsZoomAnimController = false;
    }
    // Silence post-dispose emissions into a dead owner.
    onChapterLoaded = null;
    onPageChanged = null;
    onLoadingChanged = null;
    onZoomStateChanged = null;
    onAutoScrollStateChanged = null;
    onTapZoneOverlayChanged = null;
    onShowMessage = null;
    onReadingModeChanged = null;
    onParentMangaLoaded = null;
    onSettingsChanged = null;
    onStripChapterSwitched = null;
    if (!_stripDisposed) {
      _stripDisposed = true;
      _stripChapters.dispose();
    }
  }
}

/// Simple TickerProvider implementation for creating AnimationControllers outside of widgets.
class _TickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => _TestTicker(onTick);
}

class _TestTicker extends Ticker {
  _TestTicker(super.callback);
}