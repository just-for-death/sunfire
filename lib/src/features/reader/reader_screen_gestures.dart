part of 'reader_screen.dart';

/// ISS-132: the gesture / input logic lives in [ReaderInputPipeline]
/// (controller/reader_input_pipeline.dart). These keep the screen call sites.
extension _ReaderGestures on _ReaderScreenState {
  void _wirePipelineCallbacks() => _input.wirePipelineCallbacks();
  void _syncGesturePipelineState({int? pageIndexForAspect}) =>
      _input.syncGesturePipelineState(pageIndexForAspect: pageIndexForAspect);
  void _toggleAutoScroll() => _input.toggleAutoScroll();
  void _startAutoScroll() => _input.startAutoScroll();
  void _stopAutoScroll() => _input.stopAutoScroll();
  void _showAutoScrollSpeedDialog() => _input.showAutoScrollSpeedDialog();
  void _safeSetWakelock(bool enable) => _input.safeSetWakelock(enable);
  void _resetZoom({bool animate = false}) => _input.resetZoom(animate: animate);
  TransformationController _webtoonZoomControllerFor(int index) => _input.webtoonZoomControllerFor(index);
  void _pruneWebtoonZoomState(int activeIndex) => _input.pruneWebtoonZoomState(activeIndex);
  void _cancelZoomAnimation() => _input.cancelZoomAnimation();
  void _initPreferences() => _input.initPreferences();
  TapZonePreset _activeTapZonePreset() => _input.activeTapZonePreset();
  void _dismissTapZoneOverlay() => _input.dismissTapZoneOverlay();
  void _handleTapZone(TapUpDetails details, BoxConstraints constraints) =>
      _input.handleTapZone(details, constraints);
  void _syncReaderControllerPresentation() => _input.syncReaderControllerPresentation();
  void _handleDoubleTapZoom({TransformationController? controllerOverride, int? pageIndex}) =>
      _input.handleDoubleTapZoom(controllerOverride: controllerOverride, pageIndex: pageIndex);
  void _onLifecycleChanged(AppLifecycleState state) => _input.onLifecycleChanged(state);
  void _initVolumeKeyListener() => _input.initVolumeKeyListener();
  void _setPageIndicator(int page) => _input.setPageIndicator(page);
  void _applyReadingMode(ReadingMode mode, {bool showSnack = false}) =>
      _input.applyReadingMode(mode, showSnack: showSnack);
  /// IMP-012: the strip offset (item index + earlier chapters' extents) is
  /// applied once, inside ReaderInputPipeline.jumpToWebtoonPage.
  void _jumpToWebtoonPage(int page) => _input.jumpToWebtoonPage(page);
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) => _input.handleKeyEvent(node, event);
  void _safeExitReader() => _input.safeExitReader();
  void _onVerticalScroll() => _input.onVerticalScroll();
  void _onPageChanged(int index) => _input.onPageChanged(index);
  int _pagedControllerIndexForPage(int page1Based) => _input.pagedControllerIndexForPage(page1Based);
  void _cycleReadingMode() => _input.cycleReaderMode();
}
