import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/services/wakelock_coordinator.dart';
import '../double_page_layout.dart';
import '../reader_auto_scroll_sheet.dart';
import '../reader_prefetch.dart';
import '../reader_scroll_utils.dart';
import '../reading_mode.dart';
import '../tap_zones.dart';
import 'gesture_pipeline.dart';
import 'navigation_controller.dart';
import 'page_transition.dart';
import 'position_manager.dart';
import 'reader_controller.dart';
import 'reader_theme.dart';

/// What [ReaderInputPipeline] needs from the reader screen it serves (ISS-132).
/// Shared presentation state stays on the screen; the pipeline reads and
/// writes it through this interface.
abstract class ReaderInputHost {
  bool get mounted;
  BuildContext get context;
  TickerProvider get vsync;
  void rebuild(VoidCallback fn);
  ReadingMode get readingMode;
  set readingMode(ReadingMode v);
  ReaderThemeMode get readerTheme;
  set readerTheme(ReaderThemeMode v);
  ReaderColorFilter get colorFilter;
  set colorFilter(ReaderColorFilter v);
  ImageScaleType get scaleType;
  set scaleType(ImageScaleType v);
  bool get cropBorders;
  set cropBorders(bool v);
  bool get invertTaps;
  set invertTaps(bool v);
  int get currentPage;
  set currentPage(int v);
  bool get showControls;
  set showControls(bool v);
  bool get isDraggingSlider;
  ScrollController get scrollController;
  PageController get pageController;
  TransformationController get transformationController;
  AnimationController? get zoomAnimController;
  Map<int, TransformationController> get webtoonZoomControllers;
  Map<String, double> get cachedPageHeights;
  Map<String, double> get cachedPageAspects;
  ValueNotifier<int> get pageIndicator;
  ValueNotifier<bool> get scrollIndicatorVisible;
  List<SpreadSlot> currentSpreadSlots();
  Future<void> persistReadingMode(ReadingMode mode);
  void fetchPagesAround(int page);
}

/// ISS-132: the reader screen's gesture / input logic (tap zones, keys,
/// volume rocker, zoom animation, auto-scroll, page + scroll navigation),
/// moved out of the `_ReaderGestures` extension. The screen owns exactly one
/// instance; it owns and wires the single [GesturePipeline] (IMP-049a).
class ReaderInputPipeline {
  ReaderInputPipeline({
    required this.host,
    required NavigationController navigationController,
    required PositionManager positionManager,
    required SettingsService settings,
    GesturePipeline? gesturePipeline,
  })  : _gestureNav = navigationController,
        _settings = settings,
        gesturePipeline = gesturePipeline ??
            GesturePipeline(
              navigationController: navigationController,
              positionManager: positionManager,
              settings: settings,
            );

  final ReaderInputHost host;
  final NavigationController _gestureNav;
  final SettingsService _settings;
  final GesturePipeline gesturePipeline;
  GesturePipeline get _gesturePipeline => gesturePipeline;

  /// Set by the screen once its ReaderController exists.
  ReaderController? _readerControllerOrNull;
  set readerController(ReaderController c) => _readerControllerOrNull = c;
  ReaderController get readerController => _readerControllerOrNull!;
  ReaderController get _readerController => readerController;

  // Zoom
  bool isZoomed = false;
  TapDownDetails? doubleTapDetails;
  int _zoomGeneration = 0;
  CurvedAnimation? _activeZoomCurve;
  VoidCallback? _zoomTickListener;

  // Floating scroll indicator / page throttles
  Timer? _scrollIndicatorTimer;
  DateTime? _lastPrevPageNavAt;
  DateTime? _lastNextPageNavAt;
  bool showTapZoneOverlay = false;

  /// Double-tap window: prev/next turns wait this long so a double-tap zoom
  /// can cancel them. Below Flutter's kDoubleTapTimeout (300ms) so the zoom
  /// itself never feels late.
  static const Duration _kTapConfirmDelay = Duration(milliseconds: 260);
  Timer? _pendingTapTimer;

  // iOS Hardware Volume Rocker Turn
  double? _lastIosVolume;
  DateTime _lastIosVolumeTurnTime = DateTime.now();
  bool _isRecenteringVolume = false;
  Timer? _recenterGuardTimer;
  int _recenterGeneration = 0;

  // Hands-free Webtoon Auto-Scroll (Vsync Synchronized)
  bool isAutoScrolling = false;
  // Per-chapter flag: chapterServerId -> shouldResumeAutoScroll
  final Map<int, bool> resumeAutoScrollForChapter = {};
  double autoScrollSpeed = 50.0; // px/sec
  Ticker? _autoScrollTicker;
  Duration? _lastAutoScrollElapsed;
  DateTime? _autoScrollStartTime;
  bool isUserTouching = false;

  @visibleForTesting
  bool get hasAutoScrollTicker => _autoScrollTicker != null;

  /// Screen dispose, step 1 (same order as before ISS-132).
  void cancelRecenterGuard() => _recenterGuardTimer?.cancel();

  /// Screen dispose, step 2.
  void disposeAutoScrollTicker() {
    _autoScrollTicker?.stop();
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
  }

  /// Screen dispose, step 3.
  void cancelScrollIndicatorTimer() {
    _scrollIndicatorTimer?.cancel();
    cancelPendingTap();
  }


  /// R1.8: bind GesturePipeline callbacks to live reader actions once.
  void wirePipelineCallbacks() {
    final gp = _gesturePipeline;
    gp.onToggleControls = toggleControls;
    gp.onStopAutoScroll = () {
      gp.setIsAutoScrolling(false);
      stopAutoScroll();
      if (host.mounted) host.rebuild(() => isAutoScrolling = false);
    };
    // Single ticker lives here: a start request from anywhere (screen,
    // ReaderController, Siri/shortcut resume) drives this ticker.
    gp.onAutoScrollStarted = () {
      if (!isAutoScrolling) startAutoScroll();
    };
    gp.onScrollVerticalBy = scrollVerticalBy;
    gp.onGoToNextPage = goToNextPage;
    gp.onGoToPrevPage = goToPrevPage;
    gp.canAdvanceToNextChapterOverride = canAdvanceToNextChapter;
    gp.canGoToPrevChapterFromTopOverride = canGoToPrevChapterFromTop;
    gp.onLoadNextChapter = () async {
      if (_gestureNav.nextChapter == null) return;
      _gestureNav.lastNextChapterNavAt = DateTime.now();
      await _readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.nextChapter!));
    };
    gp.onLoadPrevChapter = () async {
      if (_gestureNav.prevChapter == null) return;
      _gestureNav.lastPrevChapterNavAt = DateTime.now();
      await _readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.prevChapter!));
    };
    gp.onTapZoneOverlayChanged = (show) {
      if (host.mounted) host.rebuild(() => showTapZoneOverlay = show);
    };
    gp.onZoomStateChanged = (zoomed) {
      if (host.mounted) host.rebuild(() => isZoomed = zoomed);
    };
    gp.onUserTouchingChanged = (touching) {
      if (!host.mounted) return;
      host.rebuild(() {
        isUserTouching = touching;
        // Ease-in restart lives on the reader ticker, not GesturePipeline's.
        if (!touching) _autoScrollStartTime = DateTime.now();
      });
    };
    gp.onAnimateScroll = (offset, {duration, curve}) {
      if (!host.scrollController.hasClients) return;
      if (duration != null) {
        unawaited(host.scrollController.animateTo(
          offset,
          duration: duration,
          curve: curve ?? Curves.easeOutCubic,
        ));
      } else {
        host.scrollController.jumpTo(offset);
      }
    };
    gp.getMaxScrollExtent = () =>
        host.scrollController.hasClients
            ? host.scrollController.position.maxScrollExtent
            : 0.0;
    gp.getCurrentScrollOffset =
        () => host.scrollController.hasClients ? host.scrollController.offset : 0.0;
    gp.getScreenHeight =
        () => host.mounted ? MediaQuery.sizeOf(host.context).height : 800.0;
    gp.scrollControllerHasClients = () => host.scrollController.hasClients;
    gp.pageControllerHasClients = () => host.pageController.hasClients;
    gp.pageControllerPage = () =>
        host.pageController.hasClients ? (host.pageController.page ?? 0.0) : 0.0;
  }

  /// Push live reader state into GesturePipeline before handling input.
  void syncGesturePipelineState({int? pageIndexForAspect}) {
    final gp = _gesturePipeline;
    gp.setReadingMode(host.readingMode);
    gp.setIsAutoScrolling(isAutoScrolling);
    gp.setIsUserTouching(isUserTouching);
    gp.setIsZoomed(isZoomed);
    gp.setShowTapZoneOverlay(showTapZoneOverlay);
    gp.setInvertTaps(host.invertTaps);
    gp.setAutoScrollSpeed(autoScrollSpeed);
    gp.setCurrentPage(host.currentPage);
    gp.setPageUrls(_gestureNav.pageUrls);
    gp.setNextChapter(_gestureNav.nextChapter);
    gp.setPrevChapter(_gestureNav.prevChapter);
    gp.setTransformationController(host.transformationController);
    gp.setWebtoonZoomControllers(host.webtoonZoomControllers);
    gp.setZoomAnimController(host.zoomAnimController);
    gp.setScrollController(host.scrollController);
    if (!host.mounted) return;
    gp.setViewportSize(MediaQuery.sizeOf(host.context));
    final idx = pageIndexForAspect ?? (host.currentPage - 1);
    final url = (idx >= 0 && idx < _gestureNav.pageUrls.length) ? _gestureNav.pageUrls[idx] : null;
    gp.setCurrentPageAspect(url == null ? null : host.cachedPageAspects[url]);
  }

  void toggleAutoScroll() {
    host.rebuild(() {
      isAutoScrolling = !isAutoScrolling;
      if (isAutoScrolling) {
        startAutoScroll();
      } else {
        stopAutoScroll();
      }
    });
  }

  void startAutoScroll() {
    resetZoom();
    _autoScrollTicker?.stop();
    _autoScrollTicker?.dispose();
    _lastAutoScrollElapsed = null;
    isUserTouching = false;
    _autoScrollStartTime = DateTime.now();

    _autoScrollTicker = host.vsync.createTicker((Duration elapsed) {
      if (!isAutoScrolling || !host.mounted || !host.scrollController.hasClients) {
        stopAutoScroll();
        return;
      }

      // Check if user is touching/holding or dragging the screen
      if (isUserTouching && _settings.autoScrollPauseOnTouch) {
        // Keep elapsed benchmark updated while holding so release doesn't jump
        _lastAutoScrollElapsed = elapsed;
        return;
      }

      if (_lastAutoScrollElapsed == null) {
        _lastAutoScrollElapsed = elapsed;
        return;
      }

      final dt = (elapsed - _lastAutoScrollElapsed!).inMicroseconds / 1000000.0;
      _lastAutoScrollElapsed = elapsed;

      // Clamp delta time to 50ms (20fps minimum) to prevent sudden jumps if frame drops
      final safeDt = dt.clamp(0.0, 0.05);
      if (safeDt <= 0.0) return;

      final max = host.scrollController.position.maxScrollExtent;
      final cur = host.scrollController.offset;

      // Check bottom of chapter. Chapters shorter than one viewport
      // (max <= 50) can never satisfy the threshold below — treat them as
      // already at bottom so the ticker terminates (and auto-advance fires)
      // instead of clamping to max forever.
      if (max <= 50 || cur >= max - 8) {
        stopAutoScroll();
        if (_settings.autoScrollAutoNextChapter && _gestureNav.nextChapter != null) {
          final nextChapterId = NavigationController.targetIdOf(_gestureNav.nextChapter!);
          resumeAutoScrollForChapter[nextChapterId] = true;
          unawaited(_readerController.loadChapter(nextChapterId));
        }
        return;
      }

      // Smooth ease-in multiplier (from 0.15 to 1.0 over first 400ms)
      double easeMultiplier = 1.0;
      if (_settings.autoScrollSmoothEaseIn && _autoScrollStartTime != null) {
        final elapsedMs = DateTime.now().difference(_autoScrollStartTime!).inMilliseconds;
        if (elapsedMs < 400) {
          easeMultiplier = 0.15 + (elapsedMs / 400.0) * 0.85;
        }
      }

      final step = autoScrollSpeed * safeDt * easeMultiplier;
      final target = (cur + step).clamp(0.0, max);
      host.scrollController.jumpTo(target);
    });

    _autoScrollTicker?.start();
  }

  void stopAutoScroll() {
    _autoScrollTicker?.stop();
    _autoScrollTicker?.dispose();
    _autoScrollTicker = null;
    _lastAutoScrollElapsed = null;
    _autoScrollStartTime = null;
    isUserTouching = false;
    if (isAutoScrolling && host.mounted) {
      host.rebuild(() => isAutoScrolling = false);
    }
  }

  void showAutoScrollSpeedDialog() => showAutoScrollSpeedSheet(
        host.context,
        getSpeed: () => autoScrollSpeed,
        setSpeed: (v) => host.rebuild(() => autoScrollSpeed = v),
        onSaveDefault: (v) => _settings.defaultAutoScrollSpeed = v,
      );

  void safeSetWakelock(bool enable) {
    try {
      if (enable) {
        unawaited(WakelockCoordinator.instance.acquire('reader').catchError((Object e) {
          debugPrint('[Reader] Failed to enable wakelock: $e');
        }));
      } else {
        unawaited(WakelockCoordinator.instance.release('reader').catchError((Object e) {
          debugPrint('[Reader] Failed to disable wakelock: $e');
        }));
      }
    } catch (e) {
      debugPrint('[Reader] Wakelock toggle error: $e');
    }
  }

  void resetZoom({bool animate = false}) {
    cancelZoomAnimation();
    for (final c in host.webtoonZoomControllers.values) {
      c.value = Matrix4.identity();
    }
    if (!animate || host.zoomAnimController == null) {
      host.transformationController.value = Matrix4.identity();
      if (isZoomed && host.mounted) {
        host.rebuild(() => isZoomed = false);
      } else {
        isZoomed = false;
      }
      return;
    }
    animateZoomTo(Matrix4.identity(), markZoomed: false);
  }

  TransformationController webtoonZoomControllerFor(int index) {
    return host.webtoonZoomControllers.putIfAbsent(index, TransformationController.new);
  }

  /// Keep per-page zoom state only for pages inside a small window around the
  /// active page. Without this, very long (300–1000 page) webtoon chapters grow
  /// one TransformationController + GlobalKey per page with no pruning.
  void pruneWebtoonZoomState(int activeIndex) {
    const keepWindow = 40;
    final evict = <int>[
      for (final k in host.webtoonZoomControllers.keys)
        if ((k - activeIndex).abs() > keepWindow) k,
    ];
    if (evict.isEmpty) return;
    for (final k in evict) {
      host.webtoonZoomControllers.remove(k)?.dispose();
    }
  }

  void cancelZoomAnimation() {
    final controller = host.zoomAnimController;
    if (controller != null && _zoomTickListener != null) {
      controller.removeListener(_zoomTickListener!);
      _zoomTickListener = null;
    }
    controller?.stop();
    _activeZoomCurve?.dispose();
    _activeZoomCurve = null;
    _zoomGeneration++;
  }

  void animateZoomTo(Matrix4 end, {required bool markZoomed, TransformationController? controllerOverride}) {
    final transform = controllerOverride ?? host.transformationController;
    final controller = host.zoomAnimController;
    if (controller == null) {
      transform.value = end;
      if (host.mounted) host.rebuild(() => isZoomed = markZoomed);
      return;
    }
    cancelZoomAnimation();
    final begin = Matrix4.copy(transform.value);
    controller.reset();
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    final animation = Matrix4Tween(begin: begin, end: end).animate(curved);
    _activeZoomCurve = curved;
    final gen = _zoomGeneration;
    void tick() {
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
      if (!host.mounted) return;
      host.rebuild(() => isZoomed = markZoomed);
    }));
  }

  void initPreferences() {
    host.readingMode = parseReadingMode(_settings.readingMode);
    host.readerTheme = parseReaderTheme(_settings.readerTheme);
    host.colorFilter = parseColorFilter(_settings.colorFilter);
    host.scaleType = parseScaleType(_settings.scaleType);
    host.cropBorders = _settings.cropBorders;
    host.invertTaps = _settings.invertTapZones;
    autoScrollSpeed = _settings.defaultAutoScrollSpeed;
    // Mihon-style: flash zone map the first time the reader opens.
    if (!_settings.tapZonesOverlaySeen && _settings.tapZonesEnabled) {
      showTapZoneOverlay = true;
    }
  }

  void toggleControls() {
    unawaited(HapticFeedback.selectionClick());
    host.rebuild(() {
      host.showControls = !host.showControls;
      if (!host.showControls) {
        unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
      } else {
        unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
      }
    });
  }

  TapZonePreset activeTapZonePreset() {
    final isPaged = isPagedReadingMode(host.readingMode);
    final raw = isPaged ? _settings.tapZonePresetPaged : _settings.tapZonePresetWebtoon;
    return parseTapZonePreset(raw);
  }

  void dismissTapZoneOverlay() {
    if (!showTapZoneOverlay) return;
    host.rebuild(() => showTapZoneOverlay = false);
    _settings.tapZonesOverlaySeen = true;
  }

  void handleTapZone(TapUpDetails details, BoxConstraints constraints) {
    // Double-tap disambiguation: menu toggles / auto-scroll stops / overlay
    // dismisses stay instant; prev/next page turns wait out the double-tap
    // window so a double-tap zoom never turns the page first (the pending
    // turn is cancelled by handleDoubleTapZoom).
    syncGesturePipelineState();
    final action = _peekTapZoneAction(details, constraints);
    if (action == null || action == TapZoneAction.menu) {
      _gesturePipeline.handleTapZone(details, constraints);
      return;
    }
    _pendingTapTimer?.cancel();
    _pendingTapTimer = Timer(_kTapConfirmDelay, () {
      _pendingTapTimer = null;
      if (!host.mounted) return;
      syncGesturePipelineState();
      _gesturePipeline.handleTapZone(details, constraints);
    });
  }

  /// Cancel a delayed page turn (a double-tap zoom won the gesture arena).
  void cancelPendingTap() {
    _pendingTapTimer?.cancel();
    _pendingTapTimer = null;
  }

  /// Peek the tap-zone action without executing it. Null = handled
  /// immediately by the caller (auto-scroll stop, overlay dismiss, zoomed
  /// toggle). Mirrors GesturePipeline.handleTapZone's pre-checks.
  TapZoneAction? _peekTapZoneAction(TapUpDetails details, BoxConstraints constraints) {
    if (isAutoScrolling || showTapZoneOverlay) return null;
    final webtoonZoomed = isWebtoonReadingMode(host.readingMode) &&
        host.webtoonZoomControllers.values.any((c) => c.value.getMaxScaleOnAxis() > 1.05);
    final preset = activeTapZonePreset();
    if (!_settings.tapZonesEnabled || preset == TapZonePreset.off || isZoomed || webtoonZoomed) {
      return null;
    }
    final raw = resolveTapZoneAction(
      preset: preset,
      dx: details.localPosition.dx,
      dy: details.localPosition.dy,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
    );
    return applyTapZoneModifiers(
      raw,
      invert: host.invertTaps,
      rtlPaged: host.readingMode == ReadingMode.pagedRtl,
    );
  }

  void syncReaderControllerPresentation() {
    _readerController.syncPresentation(
      readingMode: host.readingMode,
      readerTheme: host.readerTheme,
      colorFilter: host.colorFilter,
      scaleType: host.scaleType,
      cropBorders: host.cropBorders,
      invertTaps: host.invertTaps,
      isZoomed: isZoomed,
      currentPage: host.currentPage,
    );
  }

  void handleDoubleTapZoom({TransformationController? controllerOverride, int? pageIndex}) {
    // R1.8: GesturePipeline owns double-tap smart zoom. Cancel any delayed
    // page turn first: this tap's first half already scheduled one.
    cancelPendingTap();
    syncGesturePipelineState(pageIndexForAspect: pageIndex);
    _gesturePipeline.setDoubleTapDetails(
        doubleTapDetails?.localPosition ?? Offset.zero);
    _gesturePipeline.handleDoubleTapZoom(
        controllerOverride: controllerOverride);
  }

  void onLifecycleChanged(AppLifecycleState state) {
    // `hidden` and `detached` are handled alongside `paused`/`inactive` on
    // purpose. The volume-key feature sets VolumeController.showSystemUI =
    // false, which is a *global* OS flag, not a per-window one: if it is not
    // restored before the engine detaches, the user's volume HUD stays hidden
    // system-wide after the app is killed, and nothing ever puts it back.
    // `detached` is the terminal state on Android engine-detach and on desktop
    // window close, and it is NOT preceded by `paused` on every path, so
    // handling only paused/inactive left that flag set.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (isAutoScrolling) {
        stopAutoScroll();
        if (host.mounted) host.rebuild(() => isAutoScrolling = false);
      }
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid)) {
        try {
          VolumeController.instance.showSystemUI = true;
        } catch (e) {
          debugPrint('[Reader] Failed to restore system UI on $state: $e');
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!kIsWeb &&
          (Platform.isIOS || Platform.isMacOS || Platform.isAndroid) &&
          _settings.volumeKeyTurn) {
        try {
          VolumeController.instance.showSystemUI = false;
        } catch (e) {
          debugPrint('[Reader] Failed to hide system UI on resume: $e');
        }
      }
    }
  }

  void initVolumeKeyListener() {
    try {
      // On Android, handleKeyEvent consumes volume keys (LogicalKeyboardKey.audioVolumeUp/Down)
      // so the VolumeController listener would cause DOUBLE page turns.
      // Only install the listener on iOS/macOS where we need the volume-level-based detection.
      if (Platform.isAndroid) {
        VolumeController.instance.showSystemUI = false;
        return;
      }
      VolumeController.instance.showSystemUI = false;
      unawaited(VolumeController.instance.getVolume().then((v) => _lastIosVolume = v).catchError((Object e) {
        _lastIosVolume = 0.0;
        debugPrint('[Reader] Failed to get initial volume: $e');
        return 0.0;
      }));
      VolumeController.instance.addListener((volume) {
        if (!_settings.volumeKeyTurn || !host.mounted) return;
        // Ignore the callback our own recenterVolume() call below triggers,
        // so recentering never registers as a page turn.
        if (_isRecenteringVolume) {
          _isRecenteringVolume = false;
          _lastIosVolume = volume;
          return;
        }
        final now = DateTime.now();
        if (now.difference(_lastIosVolumeTurnTime).inMilliseconds < 280) return;
        if (_lastIosVolume != null) {
          bool turned = false;
          if (volume > _lastIosVolume!) {
            _lastIosVolumeTurnTime = now;
            goToPrevPage();
            turned = true;
          } else if (volume < _lastIosVolume!) {
            _lastIosVolumeTurnTime = now;
            goToNextPage();
            turned = true;
          }
          // At/near min or max volume there's no headroom left to detect the
          // NEXT turn in that direction (volume can't go lower than 0 or
          // higher than 1), so button presses silently stop working. Nudge
          // back to the middle after every turn so there's always room on
          // both sides; the listener suppression above keeps this silent.
          // Android is excluded: there handleKeyEvent consumes the volume
          // keys, so the level never hits a bound and recentering would only
          // change the user's media volume for no benefit.
          if (turned && (Platform.isIOS || Platform.isMacOS) && (volume <= 0.05 || volume >= 0.95)) {
            recenterVolume();
            return;
          }
        }
        _lastIosVolume = volume;
      });
    } catch (e) {
      debugPrint('[Reader] Failed to initialize volume key listener: $e');
    }
  }

  void recenterVolume() {
    final currentGen = ++_recenterGeneration;
    _isRecenteringVolume = true;
    _lastIosVolume = 0.5;
    // If the platform never reports our own setVolume back (or reports it
    // late), the suppression flag would otherwise stay set and swallow the
    // next real page turn. Clear it after a short grace period regardless.
    // Use generation token to prevent stale timer callbacks from clearing
    // the flag after a newer recenter call has started.
    _recenterGuardTimer?.cancel();
    _recenterGuardTimer = Timer(const Duration(milliseconds: 600), () {
      if (_recenterGeneration == currentGen) {
        _isRecenteringVolume = false;
      }
    });
    try {
      unawaited(VolumeController.instance.setVolume(0.5));
    } catch (e) {
      _isRecenteringVolume = false;
      _recenterGuardTimer?.cancel();
      debugPrint('[Reader] Failed to recenter volume: $e');
    }
  }

  void scrollVerticalBy(double delta) {
    if (!host.scrollController.hasClients) return;
    try {
      final maxScroll = host.scrollController.position.maxScrollExtent;
      final currentOffset = host.scrollController.offset;
      final target = (currentOffset + delta).clamp(0.0, maxScroll);
      host.scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      debugPrint('[Reader] Zoom animation error: $e');
    }
  }

  /// Shared webtoon "page" step for side taps, volume keys, and keyboard.
  double webtoonPageStep() => MediaQuery.of(host.context).size.height * 0.85;

  void setPageIndicator(int page) {
    host.currentPage = page;
    if (host.pageIndicator.value != page) {
      host.pageIndicator.value = page;
    }
  }

  void applyReadingMode(ReadingMode mode, {bool showSnack = false}) {
    stopAutoScroll();
    resetZoom();
    host.rebuild(() => host.readingMode = mode);
    unawaited(host.persistReadingMode(mode));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!host.mounted) return;
      restoreReaderPositionForMode();
    });

    if (showSnack) {
      ScaffoldMessenger.of(host.context).hideCurrentSnackBar();
      ScaffoldMessenger.of(host.context).showSnackBar(
        SnackBar(
          content: Text('Reading Mode: ${readingModeSnackLabel(host.readingMode)}'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void restoreReaderPositionForMode() {
    final isPaged = isPagedReadingMode(host.readingMode);
    if (isPaged && host.pageController.hasClients) {
      final targetPage = pagedControllerIndexForPage(host.currentPage);
      host.pageController.jumpToPage(targetPage);
      return;
    }
    if (!isPaged && host.scrollController.hasClients && _gestureNav.pageUrls.isNotEmpty) {
      jumpToWebtoonPage(host.currentPage);
    }
  }

  void jumpToWebtoonPage(int page) {
    if (!host.scrollController.hasClients || _gestureNav.pageUrls.isEmpty) return;
    // IMP-012: with a strip, chapter page N is item N - 1 + offset, and the
    // offset estimate must include the earlier chapters + separators.
    final rc = _readerControllerOrNull;
    final stripItems = rc?.activeStripItems;
    final stripOffset = rc?.stripCurrentChapterOffset;
    if (rc != null && stripItems != null && stripOffset != null) {
      final itemIndex = (page - 1 + stripOffset).clamp(0, stripItems.length - 1);
      final ctx = webtoonItemContext(itemIndex);
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.0, duration: Duration.zero);
        return;
      }
      final width = MediaQuery.of(host.context).size.width;
      final contentWidth = width > 800 ? 780.0 : width;
      final gap = webtoonPageGap(host.readingMode);
      final offset = stripItemScrollOffset(
        items: stripItems,
        itemIndex: itemIndex,
        recorded: rc.recordedStripItemExtent,
        estimatePage: (p) =>
            estimateWebtoonPlaceholderHeight(contentWidth, cachedHeight: host.cachedPageHeights[p.url]) + gap,
      );
      final maxScroll = host.scrollController.position.maxScrollExtent;
      host.scrollController.jumpTo(maxScroll > 0 ? offset.clamp(0.0, maxScroll) : offset);
      return;
    }
    final ctx = webtoonItemContext(page - 1);
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, alignment: 0.0, duration: Duration.zero);
      return;
    }
    final width = MediaQuery.of(host.context).size.width;
    final contentWidth = width > 800 ? 780.0 : width;
    final offset = resumeOffsetForPage(
      targetPage: page,
      pageCount: _gestureNav.pageUrls.length,
      heightForIndex: (i) {
        final url = _gestureNav.pageUrls[i];
        return estimateWebtoonPlaceholderHeight(contentWidth, cachedHeight: host.cachedPageHeights[url]);
      },
      gapAfterIndex: (i) => webtoonPageGap(host.readingMode),
    );
    final maxScroll = host.scrollController.position.maxScrollExtent;
    host.scrollController.jumpTo(maxScroll > 0 ? offset.clamp(0.0, maxScroll) : offset);
  }

  bool canAdvanceToNextChapter() {
    if (_gestureNav.nextChapter == null || !host.scrollController.hasClients) return false;
    final now = DateTime.now();
    if (_gestureNav.lastNextChapterNavAt != null &&
        now.difference(_gestureNav.lastNextChapterNavAt!) < const Duration(milliseconds: 700)) {
      return false;
    }
    return true;
  }

  bool canGoToPrevChapterFromTop() {
    if (_gestureNav.prevChapter == null || !host.scrollController.hasClients) return false;
    final pos = host.scrollController.position;
    if (pos.maxScrollExtent <= 50) return false;
    if (pos.pixels > 20) return false;
    // Ignore while user is actively dragging / a fling is in progress.
    if (pos.isScrollingNotifier.value) return false;
    return _canLoadPrevChapter();
  }

  /// 700ms chapter-load gate shared by paged and webtoon prev-chapter paths.
  bool _canLoadPrevChapter() {
    final now = DateTime.now();
    if (_gestureNav.lastPrevChapterNavAt != null &&
        now.difference(_gestureNav.lastPrevChapterNavAt!) < const Duration(milliseconds: 700)) {
      return false;
    }
    return true;
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    // Held keys arrive as KeyRepeatEvent (not KeyDownEvent); swallow them or
    // a held Space/arrow/volume rocker spams page turns and chapter loads.
    if (event is KeyRepeatEvent) return KeyEventResult.handled;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // R1.8: nav / scroll keys via GesturePipeline; reader keeps volume / HUD keys.
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyA ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.end) {
      syncGesturePipelineState();
      return _gesturePipeline.handleKeyEvent(event);
    }

    if (key == LogicalKeyboardKey.escape) {
      safeExitReader();
      return KeyEventResult.handled;
    }
    // Volume rocker: exactly one path per platform. iOS/macOS use the
    // volume-level listener (initVolumeKeyListener); Android/desktop/web use
    // these key events. Handling both on one platform double-turns pages.
    final volumeKeysOnThisPlatform = !(Platform.isIOS || Platform.isMacOS);
    if (key == LogicalKeyboardKey.audioVolumeDown && _settings.volumeKeyTurn && volumeKeysOnThisPlatform) {
      // Debounce with the same window as the platform volume listener so a
      // single physical press isn't turned twice (keyboard event + listener).
      final now = DateTime.now();
      if (now.difference(_lastIosVolumeTurnTime).inMilliseconds >= 280) {
        _lastIosVolumeTurnTime = now;
        goToNextPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.audioVolumeUp && _settings.volumeKeyTurn && volumeKeysOnThisPlatform) {
      final now = DateTime.now();
      if (now.difference(_lastIosVolumeTurnTime).inMilliseconds >= 280) {
        _lastIosVolumeTurnTime = now;
        goToPrevPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyS) {
      if (host.readingMode == ReadingMode.longStrip || host.readingMode == ReadingMode.longStripGaps) {
        toggleAutoScroll();
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.equal || key == LogicalKeyboardKey.numpadAdd) {
      if (host.readingMode == ReadingMode.longStrip || host.readingMode == ReadingMode.longStripGaps) {
        host.rebuild(() => autoScrollSpeed = (autoScrollSpeed + 10.0).clamp(10.0, 2000.0));
        return KeyEventResult.handled;
      }
    } else if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
      if (host.readingMode == ReadingMode.longStrip || host.readingMode == ReadingMode.longStripGaps) {
        host.rebuild(() => autoScrollSpeed = (autoScrollSpeed - 10.0).clamp(10.0, 2000.0));
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void safeExitReader() {
    if (host.context.canPop()) {
      host.context.pop();
    } else if (Navigator.canPop(host.context)) {
      Navigator.pop(host.context);
    } else if (_gestureNav.chapter?.mangaId != null) {
      host.context.go('/manga/${_gestureNav.chapter!.mangaId}');
    } else {
      host.context.go('/library');
    }
  }

  void onVerticalScroll() {
    if (host.isDraggingSlider) return;
    if (_gestureNav.pageUrls.isEmpty || !host.scrollController.hasClients) return;
    final maxScroll = host.scrollController.position.maxScrollExtent;
    final currentScroll = host.scrollController.offset;
    if (maxScroll <= 0) return;

    // Reveal controls when reaching the end of the chapter
    if (currentScroll >= maxScroll - 30 && !host.showControls) {
      host.showControls = true;
      if (host.mounted) host.rebuild(() {});
    }

    // Show floating page indicator when scrolling with controls hidden
    if (!host.showControls) {
      if (!host.scrollIndicatorVisible.value) {
        host.scrollIndicatorVisible.value = true;
      }
      _scrollIndicatorTimer?.cancel();
      _scrollIndicatorTimer = Timer(const Duration(milliseconds: 1500), () {
        host.scrollIndicatorVisible.value = false;
      });
    }

    final media = MediaQuery.of(host.context);
    final viewportHeight = media.size.height;

    // IMP-012: with a multi-chapter strip, item indices span chapters.
    final stripItems = _readerControllerOrNull?.activeStripItems;
    if (stripItems != null) {
      _onVerticalScrollStrip(stripItems, viewportHeight, media.size.width);
      return;
    }

    final candidates = <({int page, double top, double bottom})>[];
    for (int i = 0; i < _gestureNav.pageUrls.length; i++) {
      final ctx = webtoonItemContext(i);
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final pos = box.localToGlobal(Offset.zero);
      final top = pos.dy;
      final bottom = pos.dy + box.size.height;
      if (top <= viewportHeight && bottom >= 0) {
        candidates.add((page: i + 1, top: top, bottom: bottom));
      }
    }

    final detectedPage = detectBestVisiblePage(
      viewportHeight: viewportHeight,
      pages: candidates,
      scrolledToEnd: currentScroll >= maxScroll - 2,
      lastPage: _gestureNav.pageUrls.length,
    );
    final pageRatio = (currentScroll / maxScroll).clamp(0.0, 1.0);
    final computedPage = detectedPage ?? (((pageRatio * (_gestureNav.pageUrls.length - 1)) + 1).round().clamp(1, _gestureNav.pageUrls.length));

    if (shouldPrefetchNextChapterAtRatio(pageRatio) && _gestureNav.nextChapter != null) {
      unawaited(_gestureNav.prefetchChapter(_gestureNav.nextChapter!));
    }

    // ISS-128: visible window + look-ahead (was fetched from page build).
    host.fetchPagesAround(computedPage);

    // Prefetch a few previous pages' images when scrolling up (helps placeholder stability).
    if (computedPage > 1) {
      final start = (computedPage - 4).clamp(1, _gestureNav.pageUrls.length);
      for (int p = start; p < computedPage; p++) {
        final url = _gestureNav.pageUrls[p - 1];
        final loader = _gestureNav.pageLoader;
        // Skip pages already cached, in flight or failed (no per-tick refetch).
        if (loader.hasDisplayBytes(url) ||
            loader.recoveringUrls.contains(url) ||
            loader.displayFailedUrls.contains(url)) {
          continue;
        }
        if (url.startsWith('http') && !host.cachedPageHeights.containsKey(url)) {
          // Warm decode path on desktop via existing recover; mobile uses Image cache.
          if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
            unawaited(_gestureNav.pageLoader.recoverPage(url, p - 1));
          }
        }
      }
    }

    if (computedPage != host.currentPage) {
      setPageIndicator(computedPage);
      _gestureNav.debouncedUpdateProgress(computedPage);
    }
  }

  /// IMP-028: context of laid-out webtoon item [index]: the GlobalKey-free
  /// registry (GlobalKey-free).
  BuildContext? webtoonItemContext(int index) =>
      _readerControllerOrNull?.webtoonItemRegistry.contextOf(index);

  Iterable<int> _laidOutItemIndices() =>
      _readerControllerOrNull?.webtoonItemRegistry.indices.toList() ?? const <int>[];

  /// IMP-012: visible-item detection over the strip. Records item extents,
  /// maps the visible item to its chapter/page via the controller (progress,
  /// in-place chapter switch) and applies any trim by shifting index-keyed
  /// maps and correcting the scroll offset in the same frame.
  void _onVerticalScrollStrip(List<ReaderItem> items, double viewportHeight, double width) {
    final rc = readerController;
    final gap = webtoonPageGap(host.readingMode);
    final candidates = <({int page, double top, double bottom})>[];
    for (final i in _laidOutItemIndices()) {
      if (i < 0 || i >= items.length) continue;
      final box = webtoonItemContext(i)?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      // Separators are never padded by the gap; pages are.
      rc.recordStripItemExtent(i, box.size.height + (items[i] is ReaderPageItem ? gap : 0));
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      if (top <= viewportHeight && bottom >= 0) {
        candidates.add((page: i + 1, top: top, bottom: bottom));
      }
    }
    final position = host.scrollController.position;
    final visible = detectBestVisiblePage(
      viewportHeight: viewportHeight,
      pages: candidates,
      scrolledToEnd: position.pixels >= position.maxScrollExtent - 2,
      lastPage: items.length,
    );
    if (visible == null) return;
    final contentWidth = width > 800 ? 780.0 : width;
    final r = rc.onStripItemVisible(visible - 1, contentWidth: contentWidth);
    if (r == null) return;
    if (r.removedItems > 0) {
      rc.webtoonItemRegistry.shift(r.removedItems);
      shiftStripIndexMaps(host.webtoonZoomControllers, r.removedItems,
          onDrop: (c) => c.dispose());
      final pos = host.scrollController.position;
      pos.correctPixels(pos.pixels - r.removedExtent);
    }
    host.fetchPagesAround(r.page);
    if (r.page != host.currentPage) setPageIndicator(r.page);
  }

  void onPageChanged(int index) {
    resetZoom();
    final slots = host.currentSpreadSlots();
    final useDouble = slots.isNotEmpty &&
        shouldUseDoublePages(
          mode: parseDoublePageDisplayMode(_settings.doublePageDisplayMode),
          isLandscape: MediaQuery.sizeOf(host.context).width > MediaQuery.sizeOf(host.context).height,
        );
    final int page;
    if (useDouble && index < slots.length) {
      page = pageNumberForSpread(slots, index, pageCount: _gestureNav.pageUrls.length);
    } else if (useDouble && index >= slots.length) {
      // Transition card after last spread
      page = _gestureNav.pageUrls.isNotEmpty ? _gestureNav.pageUrls.length : 1;
    } else {
      page = (index + 1).clamp(1, _gestureNav.pageUrls.isNotEmpty ? _gestureNav.pageUrls.length : 1);
    }
    setPageIndicator(page);
    if (host.mounted) host.rebuild(() {});

    host.fetchPagesAround(page);

    // Trigger prefetch early when reaching 65% of pages in paged mode
    if (shouldPrefetchNextChapterAtPage(page, _gestureNav.pageUrls.length) && _gestureNav.nextChapter != null) {
      unawaited(_gestureNav.prefetchChapter(_gestureNav.nextChapter!));
    }

    _gestureNav.debouncedUpdateProgress(page);
  }

  /// PageView index for a 1-based page number (spread index when double is on).
  int pagedControllerIndexForPage(int page1Based) {
    final pageIndex = (page1Based - 1).clamp(0, _gestureNav.pageUrls.isEmpty ? 0 : _gestureNav.pageUrls.length - 1);
    final slots = host.currentSpreadSlots();
    final useDouble = slots.isNotEmpty &&
        shouldUseDoublePages(
          mode: parseDoublePageDisplayMode(_settings.doublePageDisplayMode),
          isLandscape: MediaQuery.sizeOf(host.context).width > MediaQuery.sizeOf(host.context).height,
        );
    if (!useDouble) return pageIndex;
    return spreadIndexForPage(slots, pageIndex);
  }

  void goToNextPage() {
    if (_gestureNav.pageUrls.isEmpty) return; // No pages loaded; don't auto-advance to next chapter
    final isPaged = isPagedReadingMode(host.readingMode);
    if (isPaged) {
      final slots = host.currentSpreadSlots();
      final useDouble = slots.isNotEmpty &&
          shouldUseDoublePages(
            mode: parseDoublePageDisplayMode(_settings.doublePageDisplayMode),
            isLandscape: MediaQuery.sizeOf(host.context).width > MediaQuery.sizeOf(host.context).height,
          );
      final hasMoreViewport = useDouble
          ? (host.pageController.hasClients &&
              (host.pageController.page ?? 0) <
                  (slots.length - 1 +
                      (_settings.seamlessTransitions && _settings.showEndOfChapterDialog ? 1 : 0)))
          : host.currentPage < _gestureNav.pageUrls.length;
      if (hasMoreViewport && host.pageController.hasClients) {
        // Throttle rapid taps so one tap never double-advances a paged chapter.
        final now = DateTime.now();
        if (_lastNextPageNavAt != null &&
            now.difference(_lastNextPageNavAt!) < const Duration(milliseconds: 250)) {
          return;
        }
        _lastNextPageNavAt = now;
        unawaited(HapticFeedback.lightImpact());
        turnPage(host.pageController, forward: true, mode: parsePageTransition(_settings.pageTransition));
      } else if (_gestureNav.nextChapter != null && canAdvanceToNextChapter()) {
        _gestureNav.lastNextChapterNavAt = DateTime.now();
        unawaited(_readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.nextChapter!)));
      }
    } else {
      if (host.scrollController.hasClients) {
        final maxScroll = host.scrollController.position.maxScrollExtent;
        final currentOffset = host.scrollController.offset;
        if (maxScroll > 50 && currentOffset >= maxScroll - 20) {
          if (_gestureNav.nextChapter != null && canAdvanceToNextChapter()) {
            _gestureNav.lastNextChapterNavAt = DateTime.now();
            unawaited(_readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.nextChapter!)));
          }
        } else {
          final targetOffset = (currentOffset + webtoonPageStep()).clamp(0.0, maxScroll);
          host.scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  void goToPrevPage() {
    if (_gestureNav.pageUrls.isEmpty) return;
    final isPaged = isPagedReadingMode(host.readingMode);
    if (isPaged) {
      final slots = host.currentSpreadSlots();
      final useDouble = slots.isNotEmpty &&
          shouldUseDoublePages(
            mode: parseDoublePageDisplayMode(_settings.doublePageDisplayMode),
            isLandscape: MediaQuery.sizeOf(host.context).width > MediaQuery.sizeOf(host.context).height,
          );
      final hasPrevViewport = useDouble
          ? (host.pageController.hasClients && (host.pageController.page ?? 0) > 0.01)
          : host.currentPage > 1;
      if (hasPrevViewport && host.pageController.hasClients) {
        // Throttle rapid taps so one tap never double-advances a paged chapter.
        final now = DateTime.now();
        if (_lastPrevPageNavAt != null &&
            now.difference(_lastPrevPageNavAt!) < const Duration(milliseconds: 250)) {
          return;
        }
        _lastPrevPageNavAt = now;
        unawaited(HapticFeedback.lightImpact());
        turnPage(host.pageController, forward: false, mode: parsePageTransition(_settings.pageTransition));
      } else if (_gestureNav.prevChapter != null && _canLoadPrevChapter()) {
        _gestureNav.lastPrevChapterNavAt = DateTime.now();
        unawaited(_readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.prevChapter!)));
      }
    } else {
      if (host.scrollController.hasClients) {
        final maxScroll = host.scrollController.position.maxScrollExtent;
        final currentOffset = host.scrollController.offset;
        if (currentOffset <= 20) {
          if (canGoToPrevChapterFromTop()) {
            _gestureNav.lastPrevChapterNavAt = DateTime.now();
            unawaited(_readerController.loadChapter(NavigationController.targetIdOf(_gestureNav.prevChapter!)));
          }
        } else {
          final targetOffset = (currentOffset - webtoonPageStep()).clamp(0.0, maxScroll);
          host.scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  void cycleReaderMode() {
    applyReadingMode(cycleReadingMode(host.readingMode), showSnack: true);
  }
}

/// IMP-012: after trimming [removed] leading strip items, re-key an
/// index-keyed map so each item keeps its own entry (GlobalKeys keep their
/// element, so the visible page is not rebuilt). Dropped entries go to [onDrop].
@visibleForTesting
void shiftStripIndexMaps<V>(Map<int, V> map, int removed, {void Function(V value)? onDrop}) {
  if (removed <= 0) return;
  final shifted = <int, V>{};
  for (final e in map.entries) {
    if (e.key >= removed) {
      shifted[e.key - removed] = e.value;
    } else {
      onDrop?.call(e.value);
    }
  }
  map
    ..clear()
    ..addAll(shifted);
}

/// IMP-012: scroll offset of strip item [itemIndex] = sum of the extents of
/// every item before it: the measured extent where recorded, else
/// [estimatePage] for pages and [kReaderChapterBoundaryExtent] for separators.
@visibleForTesting
double stripItemScrollOffset({
  required List<ReaderItem> items,
  required int itemIndex,
  required double? Function(int index) recorded,
  required double Function(ReaderPageItem page) estimatePage,
}) {
  var offset = 0.0;
  for (var i = 0; i < itemIndex && i < items.length; i++) {
    final item = items[i];
    offset += recorded(i) ??
        (item is ReaderPageItem ? estimatePage(item) : kReaderChapterBoundaryExtent);
  }
  return offset;
}
