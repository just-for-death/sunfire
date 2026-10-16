// R1.8: GesturePipeline tap-zone routing unit tests.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/metron/metron_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/reader/controller/gesture_pipeline.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';
import 'package:sunfire/src/features/reader/tap_zones.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SettingsService settings;
  late GesturePipeline pipeline;
  late bool toggledControls;
  late bool stoppedAutoScroll;
  late int nextPageCalls;
  late int prevPageCalls;

  setUp(() {
    settings = SettingsService.instance;
    settings.tapZonesEnabled = true;
    settings.tapZonePresetPaged = tapZonePresetSettingsValue(TapZonePreset.defaultZones);
    settings.tapZonePresetWebtoon = tapZonePresetSettingsValue(TapZonePreset.defaultZones);
    settings.tapZonesOverlaySeen = true;

    final positionManager = PositionManager(
      settings: settings,
      isarService: IsarService.instance,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
    );
    final nav = NavigationController(
      isarService: IsarService.instance,
      pageLoader: PageLoader(sourceName: '', mangaId: 0, chapterTargetId: 0),
      positionManager: positionManager,
      settings: settings,
    );
    pipeline = GesturePipeline(
      navigationController: nav,
      positionManager: positionManager,
      settings: settings,
    );

    toggledControls = false;
    stoppedAutoScroll = false;
    nextPageCalls = 0;
    prevPageCalls = 0;

    pipeline.onToggleControls = () => toggledControls = true;
    pipeline.onStopAutoScroll = () => stoppedAutoScroll = true;
    pipeline.onGoToNextPage = () => nextPageCalls++;
    pipeline.onGoToPrevPage = () => prevPageCalls++;
    pipeline.setReadingMode(ReadingMode.pagedLtr);
    pipeline.setPageUrls(List.generate(5, (i) => 'https://example.com/$i.jpg'));
    pipeline.setCurrentPage(2);
    pipeline.setInvertTaps(false);
    pipeline.setIsZoomed(false);
    pipeline.setShowTapZoneOverlay(false);
    pipeline.setIsAutoScrolling(false);
  });

  tearDown(() {
    pipeline.dispose();
  });

  TapUpDetails tapAt(double dx, double dy) => TapUpDetails(
        kind: PointerDeviceKind.touch,
        globalPosition: Offset(dx, dy),
        localPosition: Offset(dx, dy),
      );

  const constraints = BoxConstraints.tightFor(width: 300, height: 600);

  test('stops auto-scroll on tap when scrolling', () {
    pipeline.setIsAutoScrolling(true);
    pipeline.handleTapZone(tapAt(150, 300), constraints);
    expect(stoppedAutoScroll, isTrue);
    expect(nextPageCalls, 0);
    expect(toggledControls, isFalse);
  });

  test('toggles controls when zoomed (tap zones suppressed)', () {
    // SettingsService prefs are often null in pure unit tests, so prefer the
    // in-memory zoomed gate over tapZonesEnabled=false.
    pipeline.setIsZoomed(true);
    pipeline.handleTapZone(tapAt(280, 300), constraints);
    expect(toggledControls, isTrue);
    expect(nextPageCalls, 0);
  });

  test('pinch-in flips the zoomed flag at gesture start', () {
    pipeline.setIsZoomed(false);
    var zoomedStates = <bool>[];
    pipeline.onZoomStateChanged = (z) => zoomedStates.add(z);
    pipeline.setTransformationController(TransformationController()
      ..value = Matrix4.diagonal3Values(2, 2, 1));
    pipeline.handleInteractionUpdate(ScaleUpdateDetails(
      focalPoint: Offset.zero,
      localFocalPoint: Offset.zero,
      scale: 2.0,
      horizontalScale: 2.0,
      verticalScale: 2.0,
      rotation: 0.0,
      pointerCount: 2,
    ));
    expect(zoomedStates, [true]);
  });

  test('toggles controls for menu zone (center third)', () {
    pipeline.handleTapZone(tapAt(150, 300), constraints);
    expect(toggledControls, isTrue);
    expect(nextPageCalls, 0);
  });

  test('routes right-third tap to next page in LTR paged', () {
    pipeline.handleTapZone(tapAt(280, 300), constraints);
    expect(nextPageCalls, 1);
    expect(prevPageCalls, 0);
  });

  test('routes left-third tap to prev page in LTR paged', () {
    pipeline.handleTapZone(tapAt(20, 300), constraints);
    expect(prevPageCalls, 1);
    expect(nextPageCalls, 0);
  });

  test('inverted taps swap next/prev', () {
    pipeline.setInvertTaps(true);
    pipeline.handleTapZone(tapAt(280, 300), constraints);
    expect(prevPageCalls, 1);
    expect(nextPageCalls, 0);
  });

  test('prev-page throttle is independent of next-page throttle', () {
    // Bypass the live-reader delegates to exercise the internal throttle.
    pipeline.onGoToNextPage = null;
    pipeline.onGoToPrevPage = null;
    pipeline.pageControllerHasClients = () => true;
    var animates = 0;
    pipeline.onAnimatePage = ({Duration? duration, Curve? curve}) => animates++;
    pipeline.handleTapZone(tapAt(280, 300), constraints); // next
    expect(animates, 1);
    pipeline.handleTapZone(tapAt(20, 300), constraints); // prev, immediately after
    expect(animates, 2, reason: 'a Next tap must not swallow the Prev tap');
  });

  test('start notifies owner; stop always clears state', () {
    var started = 0;
    pipeline.onAutoScrollStarted = () => started++;
    pipeline.startAutoScroll();
    expect(pipeline.isAutoScrolling, isTrue);
    expect(started, 1);
    pipeline.stopAutoScroll();
    pipeline.stopAutoScroll(); // idempotent: no ticker left to leak
    expect(pipeline.isAutoScrolling, isFalse);
  });
}
