// lib/src/features/reader/controller/reader_controller.dart
//
// Central orchestrator for the v6 reader architecture.
// Coordinates PageLoader, PositionManager, NavigationController, and GesturePipeline.
//
// Designed to be independent of UI — no BuildContext, no setState.
// The UI layer (ReaderScreen) listens to callbacks and rebuilds accordingly.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/metron/metron_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/sync_engine.dart'
    show SyncEngine;
import '../reader_scroll_utils.dart';
import '../reader_settings_scope.dart';
import '../reading_mode.dart';
import 'gesture_pipeline.dart';
import 'navigation_controller.dart';
import 'page_loader.dart'
    show PageLoader;
import 'position_manager.dart';
import 'reader_theme.dart';

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
  ReaderController({
    required this.chapterServerId,
    required this.isarService,
    required this.settings,
    required this.syncEngine,
    required this.metronService,
  }) : _gesturePipeline = GesturePipeline(
          navigationController: _placeholderNavigationController,
          positionManager: _placeholderPositionManager,
          settings: settings,
        ),
        _tickerProvider = _TickerProvider();

  final int chapterServerId;
  final IsarService isarService;
  final SettingsService settings;
  final SyncEngine syncEngine;
  final MetronService metronService;

  final _TickerProvider _tickerProvider;

  // Placeholder for early initialization
  static final NavigationController _placeholderNavigationController =
      NavigationController(
    isarService: IsarService.instance,
    pageLoader: PageLoader(
      sourceName: '',
      mangaId: 0,
      chapterTargetId: 0,
    ),
    positionManager: PositionManager(
      settings: SettingsService.instance,
      isarService: IsarService.instance,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
    ),
    settings: SettingsService.instance,
  );

  static final PositionManager _placeholderPositionManager = PositionManager(
    settings: SettingsService.instance,
    isarService: IsarService.instance,
    syncEngine: SyncEngine.instance,
    metronService: MetronService.instance,
  );

  // Sub-controllers (initialized after chapter load)
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
  bool _showTransitionCard = false;
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
  Map<int, GlobalKey> get webtoonPageKeys => _webtoonZoomControllers.keys.fold({}, (map, key) => map..[key] = GlobalKey());

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

  /// Initialize the controller and load the initial chapter.
  Future<void> initialize({
    required ScrollController scrollController,
    required PageController pageController,
    required TransformationController transformationController,
    AnimationController? zoomAnimController,
    required Map<int, TransformationController> webtoonZoomControllers,
  }) async {
    _scrollController = scrollController;
    _pageController = pageController;
    _transformationController = transformationController;
    _zoomAnimController =
        zoomAnimController ??
        AnimationController(
          vsync: _tickerProvider,
          duration: const Duration(milliseconds: 200),
        );
    _webtoonZoomControllers = webtoonZoomControllers;

    _initPreferences();
    _applySettingsToPipeline();

    unawaited(_loadChapterAndPages(chapterServerId));
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
    _gesturePipeline.setReadingMode(_readingMode);
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
    );

    _wireNavigationCallbacks();
    _wireGestureCallbacks();
  }

  void _wireNavigationCallbacks() {
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
    };
  }

  void _wireGestureCallbacks() {
    _gesturePipeline.onLoadNextChapter = () => _loadNextChapter();
    _gesturePipeline.onLoadPrevChapter = () => _loadPrevChapter();
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

  /// Load a chapter and its pages.
  Future<void> _loadChapterAndPages(int chapterId) async {
    onLoadingChanged?.call(true);
    
    // If sub-controllers not initialized yet, load chapter first to get source info
    if (_navigationController == null) {
      final loadedChapter = await IsarService.instance.getChapterByServerId(chapterId);
      if (loadedChapter == null) {
        final byLocalId = await IsarService.instance.getChapterByLocalId(chapterId);
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
    
    onLoadingChanged?.call(false);

    // Restore progress after chapter loads
    if (_navigationController?.chapter != null && _navigationController!.pageUrls.isNotEmpty) {
      await _restoreProgress();
    }
    // Ensure we return properly even if no chapter was loaded
    return;
  }

  /// Load the next chapter.
  Future<void> _loadNextChapter() async {
    final next = _navigationController?.nextChapter;
    if (next == null) return;
    final id = next.serverId != 0 ? next.serverId : next.id;
    await _loadChapterAndPages(id);
  }

  /// Load the previous chapter.
  Future<void> _loadPrevChapter() async {
    final prev = _navigationController?.prevChapter;
    if (prev == null) return;
    final id = prev.serverId != 0 ? prev.serverId : prev.id;
    await _loadChapterAndPages(id);
  }

  /// Restore reading progress for current chapter.
  Future<void> _restoreProgress() async {
    final chapter = _navigationController?.chapter;
    if (chapter == null || _navigationController!.pageUrls.isEmpty) return;

    // Read progress from chapter object (already loaded from Isar)
    final lastPage = chapter.lastPageRead.clamp(1, _navigationController!.pageUrls.length);
    final isComplete = chapter.isRead;
    
    // Only restore if not at start and not already at end
    if (lastPage > 1 || isComplete) {
      _currentPage = lastPage;
      _navigationController?.setCurrentPage(_currentPage);
      _gesturePipeline.setCurrentPage(_currentPage);

      // Jump to position
      final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
      if (isPaged && _pageController != null && _pageController!.hasClients) {
        final targetPage = _pagedControllerIndexForPage(_currentPage);
        _pageController!.jumpToPage(targetPage);
      } else if (!isPaged && _scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _jumpToWebtoonPage(_currentPage);
        });
      }
    }
  }

  int _pagedControllerIndexForPage(int page) {
    final isRtl = _readingMode == ReadingMode.pagedRtl;
    // Simplified - UI handles spread slot calculation
    return isRtl ? (_navigationController!.pageUrls.length - page) : (page - 1);
  }

  void _jumpToWebtoonPage(int page) {
    if (_scrollController == null || !_scrollController!.hasClients || _navigationController!.pageUrls.isEmpty) return;
    final width = _scrollController!.position.viewportDimension;
    final contentWidth = width > 800 ? 780.0 : width;
    final offset = resumeOffsetForPage(
      targetPage: page,
      pageCount: _navigationController!.pageUrls.length,
      heightForIndex: (int i) {
        final url = _navigationController!.pageUrls[i];
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
    final isPaged = _readingMode == ReadingMode.pagedLtr || _readingMode == ReadingMode.pagedRtl;
    if (isPaged && _pageController != null && _pageController!.hasClients) {
      final targetPage = _pagedControllerIndexForPage(_currentPage);
      _pageController!.jumpToPage(targetPage);
    } else if (!isPaged && _scrollController != null && _navigationController!.pageUrls.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      transform.value = animation.value;
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
    // Debounced progress update handled by PositionManager
  }

  void _toggleControls() {
    // UI should implement this callback
  }

  // ─── Public API for Canvas ────────────────────────────────────────

  /// Load the next chapter (public for canvas).
  Future<void> loadNextChapter() => _loadNextChapter();

  /// Load the previous chapter (public for canvas).
  Future<void> loadPrevChapter() => _loadPrevChapter();

  /// Stop auto-scroll (public for canvas).
  void stopAutoScroll() => _stopAutoScroll();

  /// Reset zoom (public for canvas).
  void resetZoom({bool animate = false}) => _resetZoom(animate: animate);

  /// Handle double-tap zoom (public for canvas).
  void handleDoubleTapZoom({TransformationController? controllerOverride}) =>
      _gesturePipeline.handleDoubleTapZoom(controllerOverride: controllerOverride);

  // ─── Dispose ──────────────────────────────────────────────────────

  void dispose() {
    try {
      _gesturePipeline.dispose();
    } catch (_) {}
    // NavigationController.dispose() already disposes pageLoader +
    // positionManager internally — do not dispose them twice here.
    try {
      _navigationController?.dispose();
    } catch (_) {}
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
  }
}

/// Simple TickerProvider implementation for creating AnimationControllers outside of widgets.
class _TickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => _TestTicker(onTick);

  @override
  void dispose() {}
}

class _TestTicker extends Ticker {
  _TestTicker(super.callback);
}