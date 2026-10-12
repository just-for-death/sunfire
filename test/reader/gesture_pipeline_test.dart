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
}
