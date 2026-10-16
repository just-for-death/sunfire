// lib/src/features/reader/controller/gesture_pipeline.dart
//
// Extracted from reader_screen.dart — handles all gesture input for the reader:
// tap zones, double-tap zoom, keyboard navigation, auto-scroll pause,
// scroll wheel handling, and zoom animations.
//
// Designed to be independent of UI — no BuildContext, no setState.
// All state is passed in/out via callbacks.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/db/models/chapter.dart';
import '../../../core/services/settings_service.dart';
import '../double_page_layout.dart';
import '../reading_mode.dart';
import '../tap_zones.dart';
import 'navigation_controller.dart';
import 'position_manager.dart';
import 'smart_zoom.dart';

/// GesturePipeline — orchestrates all gesture input for the reader.
///
/// Handles:
/// - Tap zones (single tap navigation via tap zones)
/// - Double-tap zoom (with animation)
/// - Keyboard navigation (arrows, space, page up/down)
/// - Auto-scroll pause/resume on touch
/// - Mouse/trackpad scroll wheel for paged navigation
/// - Zoom animations and state sync
///
/// Designed to be independent of UI — no BuildContext, no setState.
/// All state is passed in/out via callbacks.
class GesturePipeline {
  GesturePipeline({
    required this.navigationController,
    required this.positionManager,
    required this.settings,
  });

  final NavigationController navigationController;
  final PositionManager positionManager;
  final SettingsService settings;

  // ─── Configuration constants ──────────────────────────────────────
  static const double _doubleTapZoomScale = 2.5;
  /// Matches live InteractiveViewer maxScale on reader_screen.
  static const double _maxZoomScale = 3.5;

  // ─── State (set by owner via setters) ────────────────────────────
  ReadingMode _readingMode = ReadingMode.longStrip;
  bool _isAutoScrolling = false;
  bool _isUserTouching = false;
  bool _isZoomed = false;
  bool _showTapZoneOverlay = false;
  bool _invertTaps = false;
  double _autoScrollSpeed = 50.0;
  int _currentPage = 1;
  List<String> _pageUrls = const [];
  Chapter? _nextChapter;
  Chapter? _prevChapter;
  Offset? _doubleTapDetails;

  // R9.1: smart-zoom inputs (set by owner; null = unknown -> fallback).
  Size? _viewportSize;
  double? _currentPageAspect;

  /// Viewport size for column-fit zoom computation.
  void setViewportSize(Size? size) => _viewportSize = size;

  /// Aspect ratio (w/h) of the currently visible page image, if known.
  void setCurrentPageAspect(double? aspect) => _currentPageAspect = aspect;

  // Controllers (owned by UI, passed in)
  TransformationController? _transformationController;
  Map<int, TransformationController> _webtoonZoomControllers = {};
  AnimationController? _zoomAnimController;
  CurvedAnimation? _activeZoomCurve;
  VoidCallback? _zoomTickListener;
  int _zoomGeneration = 0;
  ScrollController? _scrollController;
  DateTime? _lastNextPageNavAt;
  DateTime? _lastPrevPageNavAt;

  // ─── Callbacks (set by owner) ────────────────────────────────────
  /// Called when tap zones should be shown/hidden
  void Function(bool show)? onTapZoneOverlayChanged;

  /// Called when zoom state changes
  void Function(bool isZoomed)? onZoomStateChanged;

  /// Called when auto-scroll touch state changes
  void Function(bool isUserTouching)? onUserTouchingChanged;

  /// Called to request a chapter load (next)
  Future<void> Function()? onLoadNextChapter;

  /// Called to request a chapter load (prev)
  Future<void> Function()? onLoadPrevChapter;

  /// Called to toggle controls visibility
  void Function()? onToggleControls;

  /// Called to stop auto-scroll
  void Function()? onStopAutoScroll;

  /// Called when auto-scroll is requested. The owner drives the single
  /// ticker (GesturePipeline owns no ticker); unset = flags only.
  void Function()? onAutoScrollStarted;

  /// Called to scroll vertically by delta (webtoon mode)
  void Function(double delta)? onScrollVerticalBy;

  /// Called when page changes (for paged mode)
  void Function(int page)? onPageChanged;

  /// Called to animate scroll controller
  void Function(double offset, {Duration? duration, Curve? curve})? onAnimateScroll;

  /// Called to animate page controller
  void Function({Duration? duration, Curve? curve})? onAnimatePage;

  /// When set, page next/prev delegates to the live reader (R1.8 cutover).
  /// Keeps proven `_goToNextPage` / `_goToPrevPage` behavior while this
  /// pipeline owns gesture routing.
  VoidCallback? onGoToNextPage;
  VoidCallback? onGoToPrevPage;

  /// Optional overrides for chapter-advance gates (live reader has stricter
  /// scroll-position checks than [NavigationController]'s debounce-only helpers).
  bool Function()? canAdvanceToNextChapterOverride;
  bool Function()? canGoToPrevChapterFromTopOverride;

  /// Called to get max scroll extent
  double Function()? getMaxScrollExtent;

  /// Called to get current scroll offset
  double Function()? getCurrentScrollOffset;

  /// Called to get screen height for webtoon step calculation
  double Function()? getScreenHeight;

  /// Called to check if page controller has clients
  bool Function()? pageControllerHasClients;

  /// Called to check if scroll controller has clients
  bool Function()? scrollControllerHasClients;

  /// Called to get current page controller page
  double Function()? pageControllerPage;

  // ─── Getters for external state ──────────────────────────────────
  ReadingMode get readingMode => _readingMode;
  bool get isAutoScrolling => _isAutoScrolling;
  bool get isUserTouching => _isUserTouching;
  bool get isZoomed => _isZoomed;
  bool get showTapZoneOverlay => _showTapZoneOverlay;
  double get autoScrollSpeed => _autoScrollSpeed;
  int get currentPage => _currentPage;
  List<String> get pageUrls => _pageUrls;
  Chapter? get nextChapter => _nextChapter;
  Chapter? get prevChapter => _prevChapter;
  Offset? get doubleTapDetails => _doubleTapDetails;

  // ─── Setters for external state (called by owner) ────────────────
  void setReadingMode(ReadingMode mode) => _readingMode = mode;
  void setIsAutoScrolling(bool value) => _isAutoScrolling = value;
  void setIsUserTouching(bool value) => _isUserTouching = value;
  void setIsZoomed(bool value) => _isZoomed = value;
  void setShowTapZoneOverlay(bool value) => _showTapZoneOverlay = value;
  void setInvertTaps(bool value) => _invertTaps = value;
  void setAutoScrollSpeed(double value) => _autoScrollSpeed = value.clamp(10.0, 2000.0);
  void setCurrentPage(int page) => _currentPage = page;
  void setPageUrls(List<String> urls) => _pageUrls = urls;
  void setNextChapter(Chapter? chapter) => _nextChapter = chapter;
  void setPrevChapter(Chapter? chapter) => _prevChapter = chapter;
  void setDoubleTapDetails(Offset? details) => _doubleTapDetails = details;

  // Controller setters
  void setTransformationController(TransformationController? controller) =>
      _transformationController = controller;
  void setWebtoonZoomControllers(Map<int, TransformationController> controllers) =>
      _webtoonZoomControllers = controllers;
  void setZoomAnimController(AnimationController? controller) => _zoomAnimController = controller;
  void setScrollController(ScrollController? controller) => _scrollController = controller;

  // ─── Public API ───────────────────────────────────────────────────

  /// Handle tap zone interaction (called from GestureDetector.onTapUp)
  void handleTapZone(TapUpDetails details, BoxConstraints constraints) {
    if (_isAutoScrolling) {
      onStopAutoScroll?.call();
      return;
    }
    if (_showTapZoneOverlay) {
      _dismissTapZoneOverlay();
      return;
    }

    // Any zoomed page in the (window-pruned) controller map arms the
    // zoomed path: a long strip shows many pages and zoom is per page.
    final webtoonZoomed = isWebtoonReadingMode(_readingMode) &&
        _webtoonZoomControllers.values
            .any((c) => c.value.getMaxScaleOnAxis() > 1.05);

    final preset = _activeTapZonePreset();
    if (!settings.tapZonesEnabled || preset == TapZonePreset.off || _isZoomed || webtoonZoomed) {
      onToggleControls?.call();
      return;
    }

    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;

    final raw = resolveTapZoneAction(
      preset: preset,
      dx: dx,
      dy: dy,
      width: width,
      height: height,
    );
    final action = applyTapZoneModifiers(
      raw,
      invert: _invertTaps,
      rtlPaged: _readingMode == ReadingMode.pagedRtl,
    );

    if (action == TapZoneAction.menu) {
      onToggleControls?.call();
      return;
    }

    _executeTapZoneAction(action);
  }

  /// Handle double-tap zoom (called from GestureDetector.onDoubleTap)
  void handleDoubleTapZoom({TransformationController? controllerOverride}) {
    final transform = controllerOverride ?? _transformationController;
    if (transform == null) return;

    final currentScale = transform.value.getMaxScaleOnAxis();
    if (currentScale > 1.05) {
      _animateZoomTo(Matrix4.identity(), markZoomed: false, controllerOverride: transform);
      return;
    }

    final pos = _doubleTapDetails ?? Offset.zero;
    // R9.1: column-fit scale when dimensions are known, else legacy 2.5x.
    final vp = _viewportSize;
    final scale = (vp == null)
        ? _doubleTapZoomScale
        : smartZoomScale(
            viewportWidth: vp.width,
            viewportHeight: vp.height,
            imageAspect: _currentPageAspect,
            fallback: _doubleTapZoomScale,
            maxScale: _maxZoomScale,
          );
    final zoomedMatrix = _zoomMatrixAround(pos, scale);
    _animateZoomTo(zoomedMatrix, markZoomed: true, controllerOverride: transform);
  }

  /// Handle keyboard events (called from Focus.onKeyEvent)
  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    final isPaged = isPagedReadingMode(_readingMode);
    final isRtl = _readingMode == ReadingMode.pagedRtl;

    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      if (isRtl) {
        _goToPrevPage();
      } else {
        _goToNextPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      if (isRtl) {
        _goToNextPage();
      } else {
        _goToPrevPage();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.pageDown) {
      if (isPaged) {
        _goToNextPage();
      } else {
        _scrollVerticalBy(_webtoonPageStep());
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.pageUp) {
      if (isPaged) {
        _goToPrevPage();
      } else {
        _scrollVerticalBy(-_webtoonPageStep());
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (isPaged) {
        _goToNextPage();
      } else {
        _scrollVerticalBy(_webtoonFineStep());
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (isPaged) {
        _goToPrevPage();
      } else {
        _scrollVerticalBy(-_webtoonFineStep());
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.home) {
      if (!isPaged && _scrollController != null) {
        onAnimateScroll?.call(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.end) {
      if (!isPaged && _scrollController != null) {
        final max = getMaxScrollExtent?.call() ?? 0.0;
        onAnimateScroll?.call(max, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Handle pointer down (for auto-scroll pause on touch)
  void handlePointerDown(PointerDownEvent event) {
    if (_isAutoScrolling && !_isUserTouching) {
      _isUserTouching = true;
      onUserTouchingChanged?.call(true);
    }
  }

  /// Handle pointer up (for auto-scroll resume)
  void handlePointerUp(PointerUpEvent event) {
    if (_isUserTouching) {
      _isUserTouching = false;
      onUserTouchingChanged?.call(false);
    }
  }

  /// Handle pointer cancel (for auto-scroll resume)
  void handlePointerCancel(PointerCancelEvent event) {
    if (_isUserTouching) {
      _isUserTouching = false;
      onUserTouchingChanged?.call(false);
    }
  }

  /// Handle pointer signal (scroll wheel for paged mode)
  void handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    final isPaged = isPagedReadingMode(_readingMode);
    if (!isPaged) return;

    final isRtl = _readingMode == ReadingMode.pagedRtl;
    final effectiveDx = isRtl ? -event.scrollDelta.dx : event.scrollDelta.dx;

    if (effectiveDx > 25 || event.scrollDelta.dy > 25) {
      _goToNextPage();
    } else if (effectiveDx < -25 || event.scrollDelta.dy < -25) {
      _goToPrevPage();
    }
  }

  /// Handle zoom interaction update (from InteractiveViewer.onInteractionUpdate)
  void handleInteractionUpdate(ScaleUpdateDetails details) {
    // Always sync: pinch-zooming IN from unzoomed must flip the flag at
    // gesture start, or taps/pan behave as if unzoomed until finger lift.
    _syncZoomedFlag();
  }

  /// Handle zoom interaction end (from InteractiveViewer.onInteractionEnd)
  void handleInteractionEnd(ScaleEndDetails details) {
    _syncZoomedFlag();
  }

  /// Start auto-scroll. Single-ticker rule: the owner (ReaderInputPipeline)
  /// drives the ticker; this only flips state and notifies. There is no
  /// second ticker to leak or fight, and stop always fully clears state.
  void startAutoScroll() {
    _isAutoScrolling = true;
    _isUserTouching = false;
    onAutoScrollStarted?.call();
  }

  /// Stop auto-scroll. Unconditional: a stale flag with a live ticker is
  /// impossible because no ticker lives here.
  void stopAutoScroll() {
    _isAutoScrolling = false;
    _isUserTouching = false;
  }

  /// Adjust auto-scroll speed
  void adjustAutoScrollSpeed(double delta) {
    _autoScrollSpeed = (_autoScrollSpeed + delta).clamp(10.0, 2000.0);
    settings.defaultAutoScrollSpeed = _autoScrollSpeed;
  }

  /// Dismiss tap zone overlay
  void dismissTapZoneOverlay() => _dismissTapZoneOverlay();

  // ─── Private helpers ──────────────────────────────────────────────

  TapZonePreset _activeTapZonePreset() {
    final isPaged = isPagedReadingMode(_readingMode);
    final presetString = isPaged ? settings.tapZonePresetPaged : settings.tapZonePresetWebtoon;
    return parseTapZonePreset(presetString);
  }

  void _executeTapZoneAction(TapZoneAction action) {
    final isPaged = isPagedReadingMode(_readingMode);

    if (isPaged) {
      if (action == TapZoneAction.next) {
        _goToNextPage();
      } else {
        _goToPrevPage();
      }
      return;
    }

    // Webtoon / vertical
    if (action == TapZoneAction.next) {
      final maxScroll = getMaxScrollExtent?.call() ?? 0.0;
      final currentOffset = getCurrentScrollOffset?.call() ?? 0.0;
      if (maxScroll > 50 && currentOffset >= maxScroll - 20) {
        if (_nextChapter != null && _canAdvanceToNextChapter()) {
          unawaited(onLoadNextChapter?.call());
        }
      } else {
        _scrollVerticalBy(_webtoonPageStep());
      }
    } else {
      if (_canGoToPrevChapterFromTop()) {
        unawaited(onLoadPrevChapter?.call());
      } else {
        _scrollVerticalBy(-_webtoonPageStep());
      }
    }
  }

  bool _canAdvanceToNextChapter() =>
      canAdvanceToNextChapterOverride?.call() ??
      navigationController.canAdvanceToNextChapter();

  bool _canGoToPrevChapterFromTop() =>
      canGoToPrevChapterFromTopOverride?.call() ??
      navigationController.canGoToPrevChapterFromTop();

  void _goToNextPage() {
    if (onGoToNextPage != null) {
      onGoToNextPage!();
      return;
    }
    if (_pageUrls.isEmpty) return;

    final isPaged = isPagedReadingMode(_readingMode);
    if (isPaged) {
      final slots = _currentSpreadSlots();
      final useDouble = slots.isNotEmpty &&
          shouldUseDoublePages(
            mode: parseDoublePageDisplayMode(settings.doublePageDisplayMode),
            isLandscape: false, // Will be determined by UI
          );
      final hasMoreViewport = useDouble
          ? (pageControllerHasClients?.call() == true &&
              (pageControllerPage?.call().round() ?? 0) <
                  (slots.length - 1 +
                      (settings.seamlessTransitions && settings.showEndOfChapterDialog ? 1 : 0)))
          : _currentPage < _pageUrls.length;

      if (hasMoreViewport && pageControllerHasClients?.call() == true) {
        final now = DateTime.now();
        if (_lastNextPageNavAt != null &&
            now.difference(_lastNextPageNavAt!) < const Duration(milliseconds: 250)) {
          return;
        }
        _lastNextPageNavAt = now;
        unawaited(HapticFeedback.lightImpact());
        onAnimatePage?.call(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
      } else if (_nextChapter != null) {
        unawaited(onLoadNextChapter?.call());
      }
    } else {
      if (scrollControllerHasClients?.call() == true) {
        final maxScroll = getMaxScrollExtent?.call() ?? 0.0;
        final currentOffset = getCurrentScrollOffset?.call() ?? 0.0;
        if (maxScroll > 50 && currentOffset >= maxScroll - 20) {
          if (_nextChapter != null) {
            unawaited(onLoadNextChapter?.call());
          }
        } else {
          final targetOffset = (currentOffset + _webtoonPageStep()).clamp(0.0, maxScroll);
          onAnimateScroll?.call(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  void _goToPrevPage() {
    if (onGoToPrevPage != null) {
      onGoToPrevPage!();
      return;
    }
    if (_pageUrls.isEmpty) return;

    final isPaged = isPagedReadingMode(_readingMode);
    if (isPaged) {
      final slots = _currentSpreadSlots();
      final useDouble = slots.isNotEmpty &&
          shouldUseDoublePages(
            mode: parseDoublePageDisplayMode(settings.doublePageDisplayMode),
            isLandscape: false,
          );
      final hasPrevViewport = useDouble
          ? (pageControllerHasClients?.call() == true && (pageControllerPage?.call().round() ?? 0) > 0)
          : _currentPage > 1;

      if (hasPrevViewport && pageControllerHasClients?.call() == true) {
        final now = DateTime.now();
        if (_lastPrevPageNavAt != null &&
            now.difference(_lastPrevPageNavAt!) < const Duration(milliseconds: 250)) {
          return;
        }
        _lastPrevPageNavAt = now;
        unawaited(HapticFeedback.lightImpact());
        onAnimatePage?.call(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
      } else if (_prevChapter != null) {
        unawaited(onLoadPrevChapter?.call());
      }
    } else {
      if (scrollControllerHasClients?.call() == true) {
        final currentOffset = getCurrentScrollOffset?.call() ?? 0.0;
        if (currentOffset <= 20) {
          if (_prevChapter != null && _canGoToPrevChapterFromTop()) {
            unawaited(onLoadPrevChapter?.call());
          }
        } else {
          final targetOffset = (currentOffset - _webtoonPageStep()).clamp(0.0, getMaxScrollExtent?.call() ?? 0.0);
          onAnimateScroll?.call(
            targetOffset,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
    }
  }

  void _scrollVerticalBy(double delta) {
    onScrollVerticalBy?.call(delta);
  }

  double _webtoonPageStep() {
    final screenHeight = getScreenHeight?.call() ?? 800.0;
    return screenHeight * 0.85;
  }

  double _webtoonFineStep() => _webtoonPageStep() * 0.45;

  List<SpreadSlot> _currentSpreadSlots() {
    final slots = <SpreadSlot>[];
    if (_pageUrls.length < 2) return slots;

    for (var i = 0; i < _pageUrls.length; i += 2) {
      if (i + 1 < _pageUrls.length) {
        slots.add(SpreadSlot(primaryIndex: i, secondaryIndex: i + 1));
      } else {
        slots.add(SpreadSlot(primaryIndex: i, secondaryIndex: null));
      }
    }
    return slots;
  }

  void _dismissTapZoneOverlay() {
    if (!_showTapZoneOverlay) return;
    _showTapZoneOverlay = false;
    onTapZoneOverlayChanged?.call(false);
    settings.tapZonesOverlaySeen = true;
  }

  // ─── Zoom handling ────────────────────────────────────────────────

  Matrix4 _zoomMatrixAround(Offset focal, double scale) {
    return Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0)
      ..translateByDouble(-focal.dx, -focal.dy, 0.0, 1.0);
  }

  void _syncZoomedFlag() {
    if (_transformationController == null) return;
    final scale = _transformationController!.value.getMaxScaleOnAxis();
    final isNowZoomed = scale > 1.05;
    if (isNowZoomed != _isZoomed) {
      _isZoomed = isNowZoomed;
      onZoomStateChanged?.call(isNowZoomed);
    }
  }

  void _cancelZoomAnimation() {
    final controller = _zoomAnimController;
    if (controller != null && _zoomTickListener != null) {
      controller.removeListener(_zoomTickListener!);
      _zoomTickListener = null;
    }
    controller?.stop();
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
    // Guard: AnimationController created without a duration (e.g. unbounded
    // fallback) throws on forward(). Production UI always passes a 200ms
    // controller, but default defensively here.
    controller.duration ??= const Duration(milliseconds: 200);
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

  // ─── Dispose ──────────────────────────────────────────────────────

  void dispose() {
    _cancelZoomAnimation();
    // NOTE: _zoomAnimController, _transformationController, _scrollController
    // and _webtoonZoomControllers are UI-owned (passed in via setters).
    // Never dispose them here — only release internal listeners/tickers.
    _zoomAnimController = null;
    _transformationController = null;
    _scrollController = null;
    _activeZoomCurve = null;
    _zoomTickListener = null;

    // Do not dispose webtoon zoom controllers — UI owns the map.
    _webtoonZoomControllers = {};
  }
}