import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/live_activities_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import '../../ui/shell/sunfire_breakpoints.dart';
import 'controller/gesture_pipeline.dart';
import 'controller/navigation_controller.dart';
import 'controller/page_loader.dart';
import 'controller/position_manager.dart';
import 'controller/reader_canvas.dart';
import 'controller/reader_controller.dart';
import 'controller/reader_input_pipeline.dart';
import 'controller/reader_page_widget.dart';
import 'controller/reader_theme.dart';
import 'double_page_layout.dart';
import 'listen_sheet.dart';
import 'reader_chapter_selector_sheet.dart';
import 'reader_chapter_sidebar.dart';
import 'reader_chapter_transition.dart';
import 'reader_overlay_hud.dart';
import 'reader_scroll_utils.dart';
import 'reader_settings_scope.dart';
import 'reader_settings_sheet.dart';
import 'reading_mode.dart';
import 'tap_zone_overlay.dart';
import 'tap_zones.dart';

export 'controller/reader_theme.dart'
    show ReaderThemeMode, ReaderColorFilter, ImageScaleType;
export 'reading_mode.dart' show ReadingMode;

part 'reader_screen_gestures.dart';
part 'reader_screen_view.dart';

class ReaderScreen extends StatefulWidget {
  final int chapterServerId;
  const ReaderScreen({super.key, required this.chapterServerId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with TickerProviderStateMixin, WidgetsBindingObserver
    implements ReaderInputHost {
  final SettingsService _settings = SettingsService.instance;
  // Chapter state lives ONLY in NavigationController; these forward to it.
  String? get _sourceName => _gestureNav.sourceName;
  Chapter? get _chapter => _gestureNav.chapter;
  Chapter? get _nextChapter => _gestureNav.nextChapter;
  Chapter? get _prevChapter => _gestureNav.prevChapter;
  List<Chapter> get _siblingChapters => _gestureNav.siblingChapters;
  List<String> get _pageUrls => _gestureNav.pageUrls;
  Manga? get _parentManga => _gestureNav.parentManga;
  set _parentManga(Manga? v) => _gestureNav.setParentManga(v);
  // Page bytes + display state live ONLY in PageLoader (ISS-125).
  Set<String> get _recoveringUrls => _gestureNav.pageLoader.recoveringUrls;
  Set<String> get _failedImageUrls => _gestureNav.pageLoader.displayFailedUrls;
  bool _isLoading = true;
  bool _showControls = true;
  int _currentPage = 1;
  bool _isDraggingSlider = false;
  double? _sliderDragValue;

  // Zoom & Gestures
  bool get _isZoomed => _input.isZoomed;
  set _doubleTapDetails(TapDownDetails? v) => _input.doubleTapDetails = v;
  final TransformationController _transformationController = TransformationController();
  AnimationController? _zoomAnimController;
  static const double _minZoomScale = 1.0;
  static const double _maxZoomScale = 3.5;

  // Floating scroll indicator for Webtoon mode
  final ValueNotifier<bool> _scrollIndicatorVisible = ValueNotifier(false);
  final ValueNotifier<int> _pageIndicator = ValueNotifier(1);
  /// Layout-width bucket for cached heights (declared here: extensions
  /// cannot hold instance fields). Heights are width-dependent, so
  /// rotation/resize invalidates them instead of mislaying-out the strip.
  int _heightWidthBucket = -1;
  final Map<String, double> _cachedPageHeights = {};
  final Map<int, TransformationController> _webtoonZoomControllers = {};
  int _loadGeneration = 0;
  Timer? _heightRebuildTimer;

  late ReadingMode _readingMode;
  ReaderSettingsScope _readerSettingsScope = ReaderSettingsScope.global;
  late ReaderThemeMode _readerTheme;
  late ReaderColorFilter _colorFilter;
  late ImageScaleType _scaleType;
  late bool _cropBorders;
  late bool _invertTaps;
  bool get _showTapZoneOverlay => _input.showTapZoneOverlay;
  /// Intrinsic width/height per page URL for wide-page isolation in double mode
  /// and R9.1 smart zoom (column-fit double-tap).
  final Map<String, double> _cachedPageAspects = {};

  /// R1.8 slice: PageLoader owns priority loads for desktop upcoming-page prefetch.
  /// Recreated when chapter/source identity changes; null when no chapter.
  PageLoader? _pageLoader;

  /// R1.8 slice: progress persistence / sync / scrobble via PositionManager.
  late final PositionManager _positionManager = PositionManager(
    settings: _settings,
    isarService: IsarService.instance,
    syncEngine: SyncEngine.instance,
    metronService: MetronService.instance,
  );

  /// R1.8 slice: GesturePipeline owns tap/keyboard/pointer routing; page
  /// navigation still runs through proven reader_screen methods via callbacks.
  late final NavigationController _gestureNav = NavigationController(
    isarService: IsarService.instance,
    pageLoader: PageLoader(sourceName: '', mangaId: 0, chapterTargetId: 0),
    positionManager: _positionManager,
    settings: _settings,
  );
  /// ISS-132: screen-owned input pipeline; it owns the single
  /// [GesturePipeline] (IMP-049a) injected into [ReaderController].
  late final ReaderInputPipeline _input = ReaderInputPipeline(
    host: this,
    navigationController: _gestureNav,
    positionManager: _positionManager,
    settings: _settings,
  );
  GesturePipeline get _gesturePipeline => _input.gesturePipeline;

  /// R1.5: orchestrator holding the live PositionManager / Navigation /
  /// GesturePipeline. Chapter load stays on this screen; canvas may consume
  /// the controller for zoom + next-chapter requests.
  late final ReaderController _readerController;

  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;
  late int _currentChapterId;

  bool get _isAutoScrolling => _input.isAutoScrolling;
  set _isAutoScrolling(bool v) => _input.isAutoScrolling = v;
  Map<int, bool> get _resumeAutoScrollForChapter => _input.resumeAutoScrollForChapter;
  double get _autoScrollSpeed => _input.autoScrollSpeed;
  set _autoScrollSpeed(double v) => _input.autoScrollSpeed = v;
  bool get _isUserTouching => _input.isUserTouching;
  bool _isAutoScrollHudCollapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentChapterId = widget.chapterServerId;
    _pageController = PageController();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _readerController = ReaderController(
      chapterServerId: widget.chapterServerId,
      isarService: IsarService.instance,
      settings: _settings,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
      positionManager: _positionManager,
      navigationController: _gestureNav,
      gesturePipeline: _gesturePipeline,
    );
    _input.readerController = _readerController;
    _readerController.attachUiControllers(
      scrollController: _scrollController,
      pageController: _pageController,
      transformationController: _transformationController,
      zoomAnimController: _zoomAnimController,
      webtoonZoomControllers: _webtoonZoomControllers,
    );
    // Step 8: NavigationController owns resolve/prefetch/platform mirrors;
    // the screen only reacts to load start / completion.
    _readerController.restoreProgressOnLoad = false;
    _readerController.onLoadingChanged = _onLoadingChanged;
    // IMP-012: inline strip switch — adopt the new chapter without scrolling.
    _readerController.onStripChapterSwitched = (_, __, ___) {
      if (!mounted) return;
      _rebuild(() => _currentChapterId = _gestureNav.currentChapterId);
    };
    _readerController.onChapterLoaded = (_, __, ___, ____) => _pendingPublish = _onChapterLoaded();
    // ISS-131: PageLoader display changes (bytes landed / failed) rebuild pages.
    _gestureNav.pageLoader.onDisplayChanged = () => _rebuild(() {});
    _initPreferences();
    _wirePipelineCallbacks();
    if (_settings.keepScreenAwake) {
      _safeSetWakelock(true);
    }
    _scrollController.addListener(_onVerticalScroll);
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      _initVolumeKeyListener();
    }
    unawaited(_readerController.loadChapter(widget.chapterServerId));
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _onLifecycleChanged(state);

  /// IMP-010: shed cached page bytes on an OS memory warning (Flutter's
  /// PaintingBinding already clears the decoded imageCache itself).
  @override
  void didHaveMemoryPressure() => _gestureNav.pageLoader.handleMemoryPressure();


  /// URLs with a live height probe, so a rebuild cannot stack listeners.
  final Set<String> _heightProbesInFlight = {};

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    // Invalidate any in-flight chapter load so it stops touching state.
    _loadGeneration++;
    _input.cancelRecenterGuard();
    WidgetsBinding.instance.removeObserver(this);
    _input.disposeAutoScrollTicker();
    // Restore on every platform where initVolumeKeyListener (or its Android
    // branch) hides the HUD — otherwise it stays hidden system-wide.
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) {
      try {
        VolumeController.instance.removeListener();
        VolumeController.instance.showSystemUI = true;
      } catch (e) {
        debugPrint('[Reader] Failed to cleanup volume controller: $e');
      }
    }
    _gestureNav.cancelProgressDebounce();
    _input.cancelScrollIndicatorTimer();
    // Dispose the pipeline first: it stops the shared zoom AnimationController,
    // which asserted when that controller was already disposed below.
    _gesturePipeline.dispose();
    _cancelZoomAnimation();
    _zoomAnimController?.dispose();
    _zoomAnimController = null;
    _transformationController.dispose();
    for (final c in _webtoonZoomControllers.values) {
      c.dispose();
    }
    _webtoonZoomControllers.clear();
    _pageIndicator.dispose();
    _scrollIndicatorVisible.dispose();
    if (_settings.keepScreenAwake) {
      _safeSetWakelock(false);
    }
    if (_chapter != null && !_isLoading && _pageUrls.isNotEmpty) {
      _updateProgress(_currentPage);
    }
    // I8.3: end Live Activity when leaving the reader.
    unawaited(LiveActivitiesService.instance.endReading());
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    _focusNode.dispose();
    _readerController.dispose();
    // Explicit ownership: the screen created _gestureNav, so it disposes it;
    // that disposes its PageLoader and PositionManager exactly once.
    // ReaderController skips injected sub-controllers.
    _gestureNav.pageLoader.onDisplayChanged = null;
    _gestureNav.dispose();
    _pageLoader = null;
    _heightRebuildTimer?.cancel();
    _heightRebuildTimer = null;
    _scrollController.removeListener(_onVerticalScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Load start/finish from [ReaderController] / [NavigationController].
  /// Fires more than once per load (controller + navigation), so the
  /// teardown is idempotent via [_loadInFlight].
  bool _loadInFlight = false;

  /// In-flight [_onChapterLoaded] publish, awaited before the spinner clears.
  Future<void>? _pendingPublish;
  @override
  Widget build(BuildContext context) => _buildScreen(context);


  // ─── Controller callbacks (UI reaction only; logic lives in the controllers) ───

  /// Share NavigationController's [PageLoader] (its desktop preload and
  /// next-chapter warm-up land in the same LRU) and keep its source current.
  void _syncPageLoader() {
    if (_chapter == null) {
      _pageLoader = null;
      _readerController.setPageLoader(null);
      return;
    }
    final loader = _gestureNav.pageLoader;
    if ((_sourceName ?? '') != loader.sourceName) loader.setSourceName(_sourceName ?? '');
    if (!identical(_pageLoader, loader)) {
      _pageLoader = loader;
      _readerController.setPageLoader(loader);
    }
  }

  void _onLoadingChanged(bool loading) {
    if (!mounted) return;
    if (loading) {
      if (_loadInFlight) return;
      _loadInFlight = true;
      _onChapterLoadStarted();
    } else {
      _loadInFlight = false;
      // Review MED (ISS-120): never drop the spinner while _onChapterLoaded is
      // still publishing pages, or the empty/error screen flashes.
      final pending = _pendingPublish;
      final gen = _loadGeneration;
      if (pending != null) {
        unawaited(pending.catchError((Object e) {
          debugPrint('[Reader] publish failed: $e');
        }).whenComplete(() {
          if (identical(_pendingPublish, pending)) _pendingPublish = null;
          if (mounted && gen == _loadGeneration && !_loadInFlight && _isLoading) {
            setState(() => _isLoading = false);
          }
        }));
        return;
      }
      if (_isLoading) setState(() => _isLoading = false);
    }
  }

  /// UI teardown before a chapter switch. Progress for the outgoing chapter
  /// is flushed by NavigationController (synced to our current page here).
  void _onChapterLoadStarted() {
    ++_loadGeneration;
    _input.cancelPendingTap();
    _gestureNav.cancelProgressDebounce();
    _gestureNav.setCurrentPage(_currentPage);
    _stopAutoScroll();
    _gestureNav.pageLoader.resetDisplayState();
    _cachedPageHeights.clear();
    _heightWidthBucket = -1;
    _cachedPageAspects.clear();
    for (final c in _webtoonZoomControllers.values) {
      c.dispose();
    }
    _webtoonZoomControllers.clear();
    _resetZoom();
    setState(() {
      _isLoading = true;
      // Chapter state is NavigationController's; it clears it after the
      // outgoing chapter's progress flush.
      _currentPage = 1;
    });
    _pageIndicator.value = 1;
  }

  /// Publishes NavigationController's freshly loaded chapter into UI state.
  Future<void> _onChapterLoaded() async {
    final loadGen = _loadGeneration;
    final chapter = _gestureNav.chapter;
    if (chapter == null || !mounted) return;
    _currentChapterId = _gestureNav.currentChapterId;
    final resumeAutoScroll = _resumeAutoScrollForChapter.remove(_currentChapterId) ?? false;
    Manga? manga;
    try {
      manga = await IsarService.instance
              .getMangaByServerId(chapter.mangaId)
              .timeout(NavigationController.ioTimeout) ??
          _parentManga;
    } catch (e) {
      // A failed lookup must not hide pages that already resolved.
      debugPrint('[Reader] manga lookup failed after load: $e');
      manga = _parentManga;
    }
    if (loadGen != _loadGeneration || !mounted) return;

    final urls = _gestureNav.pageUrls;
    // A finished chapter re-opens at page 1. Restoring lastPageRead (which is
    // the last page for a completed chapter) would drop the user on the final
    // page and immediately trigger the end-of-chapter dialog.
    final startPage = (!chapter.isRead && chapter.lastPageRead > 0 && chapter.lastPageRead <= urls.length)
        ? chapter.lastPageRead
        : 1;
    setState(() {
      _applyMangaReadingMode(manga);
      _currentPage = startPage;
      _isLoading = false;
    });
    _syncPageLoader();
    _gestureNav.setCurrentPage(_currentPage);
    debugPrint('[Reader] Resolved ${_pageUrls.length} pages for source=$_sourceName');

    final initialPageIndex = _pagedControllerIndexForPage(_currentPage);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(initialPageIndex);
    } else {
      final oldController = _pageController;
      _pageController = PageController(initialPage: initialPageIndex);
      oldController.dispose();
    }
    _setPageIndicator(_currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loadGen != _loadGeneration || !mounted) return;
      _fetchPagesAround(_currentPage); // ISS-128
      final isPaged = isPagedReadingMode(_readingMode);
      if (isPaged && _pageController.hasClients) {
        _pageController.jumpToPage(_pagedControllerIndexForPage(_currentPage));
      } else if (!isPaged && _scrollController.hasClients) {
        _jumpToWebtoonPage(_currentPage);
      }
      if (resumeAutoScroll && !isPaged && _scrollController.hasClients && !_isAutoScrolling) {
        setState(() => _isAutoScrolling = true);
        _startAutoScroll();
      }
    });

    // Single-page chapters: persist progress as soon as the chapter opens so a
    // mid-read app kill never loses it.
    if (_pageUrls.length == 1 && !chapter.isRead) {
      _debouncedUpdateProgress(1);
    }

    _gestureNav.runPostLoadHousekeeping();
  }

  /// setState for the part-file extensions (setState is @protected).
  void _rebuild(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // Thin delegates into the controllers (ISS-125).
  int _chapterTargetId(Chapter ch) => NavigationController.targetIdOf(ch);
  void _debouncedUpdateProgress(int page) => _gestureNav.debouncedUpdateProgress(page);
  void _updateProgress(int page) => _gestureNav.updateProgressNow(page);
  Future<void> _recoverImage(String url, int index, {bool manual = false}) =>
      _gestureNav.pageLoader.recoverPage(url, index, manual: manual);

  /// ISS-128: page fetches run from load/page-change/scroll, never from build.
  /// Desktop renders remote pages from fetched bytes (curl), so fetch the
  /// visible window and look ahead; other platforms warm the LRU.
  void _fetchPagesAround(int page) {
    if (kIsWeb || _pageUrls.isEmpty) return;
    final loader = _gestureNav.pageLoader;
    loader.warmAround(_pageUrls, page);
    if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) return;
    final idx = page - 1;
    for (int i = idx - 1; i <= idx + 2; i++) {
      if (i < 0 || i >= _pageUrls.length) continue;
      final url = _pageUrls[i];
      if (url.startsWith('http')) unawaited(loader.recoverPage(url, i));
    }
    loader.prefetchUpcoming(_pageUrls, idx);
  }

  // ─── ReaderInputHost (ISS-132) ───
  @override
  TickerProvider get vsync => this;
  @override
  void rebuild(VoidCallback fn) => _rebuild(fn);
  @override
  ReadingMode get readingMode => _readingMode;
  @override
  set readingMode(ReadingMode v) => _readingMode = v;
  @override
  ReaderThemeMode get readerTheme => _readerTheme;
  @override
  set readerTheme(ReaderThemeMode v) => _readerTheme = v;
  @override
  ReaderColorFilter get colorFilter => _colorFilter;
  @override
  set colorFilter(ReaderColorFilter v) => _colorFilter = v;
  @override
  ImageScaleType get scaleType => _scaleType;
  @override
  set scaleType(ImageScaleType v) => _scaleType = v;
  @override
  bool get cropBorders => _cropBorders;
  @override
  set cropBorders(bool v) => _cropBorders = v;
  @override
  bool get invertTaps => _invertTaps;
  @override
  set invertTaps(bool v) => _invertTaps = v;
  @override
  int get currentPage => _currentPage;
  @override
  set currentPage(int v) => _currentPage = v;
  @override
  bool get showControls => _showControls;
  @override
  set showControls(bool v) => _showControls = v;
  @override
  bool get isDraggingSlider => _isDraggingSlider;
  @override
  ScrollController get scrollController => _scrollController;
  @override
  PageController get pageController => _pageController;
  @override
  TransformationController get transformationController => _transformationController;
  @override
  AnimationController? get zoomAnimController => _zoomAnimController;
  @override
  Map<int, TransformationController> get webtoonZoomControllers => _webtoonZoomControllers;
  @override
  Map<String, double> get cachedPageHeights => _cachedPageHeights;
  @override
  Map<String, double> get cachedPageAspects => _cachedPageAspects;
  @override
  ValueNotifier<int> get pageIndicator => _pageIndicator;
  @override
  ValueNotifier<bool> get scrollIndicatorVisible => _scrollIndicatorVisible;
  @override
  List<SpreadSlot> currentSpreadSlots() => _currentSpreadSlots();
  @override
  Future<void> persistReadingMode(ReadingMode mode) => _persistReadingMode(mode);
  @override
  void fetchPagesAround(int page) => _fetchPagesAround(page);
}
