// Integration tests for chapter navigation flow (T2.4).
// Sub-controllers are injected via ReaderController constructor.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/core/metron/metron_service.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'reader_controller_test.mocks.dart';

@GenerateMocks([
  IsarService,
  SettingsService,
  SyncEngine,
  MetronService,
  NavigationController,
  PageLoader,
  PositionManager,
])
void main() {
  group('ReaderController Integration - Chapter Navigation', () {
    late ReaderController controller;
    late MockIsarService mockIsarService;
    late MockSettingsService mockSettings;
    late MockSyncEngine mockSyncEngine;
    late MockMetronService mockMetronService;
    late MockNavigationController mockNavigationController;
    late MockPageLoader mockPageLoader;
    late MockPositionManager mockPositionManager;

    Chapter chapter1() => Chapter()
      ..serverId = 100
      ..name = 'Chapter 1'
      ..mangaId = 10;

    Chapter chapter2() => Chapter()
      ..serverId = 101
      ..name = 'Chapter 2'
      ..mangaId = 10;

    Chapter chapter0() => Chapter()
      ..serverId = 99
      ..name = 'Chapter 0'
      ..mangaId = 10;

    Future<void> initController(WidgetTester tester) async {
      final scrollController = ScrollController();
      final pageController = PageController();
      final transformationController = TransformationController();
      addTearDown(() {
        scrollController.dispose();
        pageController.dispose();
        transformationController.dispose();
      });

      await controller.initialize(
        scrollController: scrollController,
        pageController: pageController,
        transformationController: transformationController,
        webtoonZoomControllers: {},
      );
      await tester.pump();
      // Let the fire-and-forget initial load settle.
      await tester.pump(const Duration(milliseconds: 50));
    }

    setUp(() {
      mockIsarService = MockIsarService();
      mockSettings = MockSettingsService();
      mockSyncEngine = MockSyncEngine();
      mockMetronService = MockMetronService();
      mockNavigationController = MockNavigationController();
      mockPageLoader = MockPageLoader();
      mockPositionManager = MockPositionManager();

      when(mockSettings.readingMode).thenReturn('Long Strip');
      when(mockSettings.readerTheme).thenReturn('Black');
      when(mockSettings.colorFilter).thenReturn('None');
      when(mockSettings.scaleType).thenReturn('Fit Width');
      when(mockSettings.tapZonesEnabled).thenReturn(true);
      when(mockSettings.tapZonePresetPaged).thenReturn('Default');
      when(mockSettings.tapZonePresetWebtoon).thenReturn('Default');
      when(mockSettings.tapZonesOverlaySeen).thenReturn(true);
      when(mockSettings.defaultAutoScrollSpeed).thenReturn(50.0);
      when(mockSettings.autoScrollPauseOnTouch).thenReturn(true);
      when(mockSettings.autoScrollSmoothEaseIn).thenReturn(true);
      when(mockSettings.doublePageDisplayMode).thenReturn('Automatic');
      when(mockSettings.seamlessTransitions).thenReturn(true);
      when(mockSettings.showEndOfChapterDialog).thenReturn(true);
      when(mockSettings.cropBorders).thenReturn(false);
      when(mockSettings.invertTapZones).thenReturn(false);
      when(mockSettings.keepScreenAwake).thenReturn(false);
      when(mockSettings.volumeKeyTurn).thenReturn(false);
      when(mockSettings.incognitoMode).thenReturn(false);

      when(mockNavigationController.pageUrls).thenReturn([
        'https://example.com/page1.jpg',
        'https://example.com/page2.jpg',
        'https://example.com/page3.jpg',
      ]);
      when(mockNavigationController.currentPage).thenReturn(1);
      when(mockNavigationController.chapter).thenReturn(chapter1());
      when(mockNavigationController.nextChapter).thenReturn(chapter2());
      when(mockNavigationController.prevChapter).thenReturn(null);
      when(mockNavigationController.siblingChapters).thenReturn([
        chapter1(),
        chapter2(),
        Chapter()
          ..serverId = 102
          ..name = 'Chapter 3'
          ..mangaId = 10,
      ]);
      when(mockNavigationController.canAdvanceToNextChapter()).thenReturn(true);
      when(mockNavigationController.canGoToPrevChapterFromTop()).thenReturn(false);
      when(mockNavigationController.loadChapterAndPages(any)).thenAnswer((_) async {});
      when(mockNavigationController.setCurrentPage(any)).thenReturn(null);

      controller = ReaderController(
        chapterServerId: 100,
        isarService: mockIsarService,
        settings: mockSettings,
        syncEngine: mockSyncEngine,
        metronService: mockMetronService,
        navigationController: mockNavigationController,
        pageLoader: mockPageLoader,
        positionManager: mockPositionManager,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    group('Chapter Navigation Flow', () {
      testWidgets('initializes and loads chapter via injected NavigationController',
          (WidgetTester tester) async {
        await initController(tester);

        expect(controller.chapterServerId, equals(100));
        expect(controller.readingMode, equals(ReadingMode.longStrip));
        expect(controller.navigationController, same(mockNavigationController));
        verify(mockNavigationController.loadChapterAndPages(100)).called(1);
      });

      testWidgets('navigates to next chapter', (WidgetTester tester) async {
        await initController(tester);
        clearInteractions(mockNavigationController);

        when(mockNavigationController.nextChapter).thenReturn(chapter2());

        await controller.loadNextChapter();

        verify(mockNavigationController.loadChapterAndPages(101)).called(1);
      });

      testWidgets('navigates to previous chapter when available', (WidgetTester tester) async {
        await initController(tester);
        clearInteractions(mockNavigationController);

        when(mockNavigationController.prevChapter).thenReturn(chapter0());

        await controller.loadPrevChapter();

        verify(mockNavigationController.loadChapterAndPages(99)).called(1);
      });

      testWidgets('skips next chapter load when no next chapter', (WidgetTester tester) async {
        await initController(tester);
        clearInteractions(mockNavigationController);

        when(mockNavigationController.nextChapter).thenReturn(null);

        await controller.loadNextChapter();

        verifyNever(mockNavigationController.loadChapterAndPages(any));
      });

      testWidgets('reading mode change updates controller state', (WidgetTester tester) async {
        await initController(tester);

        await controller.setReadingMode(ReadingMode.pagedLtr);

        expect(controller.readingMode, equals(ReadingMode.pagedLtr));
      });
    });

    group('Auto-scroll Integration', () {
      testWidgets('toggles auto-scroll state', (WidgetTester tester) async {
        await initController(tester);

        expect(controller.isAutoScrolling, isFalse);

        controller.toggleAutoScroll();
        expect(controller.isAutoScrolling, isTrue);

        controller.toggleAutoScroll();
        expect(controller.isAutoScrolling, isFalse);
      });

      testWidgets('adjusts auto-scroll speed with clamp', (WidgetTester tester) async {
        await initController(tester);

        controller.adjustAutoScrollSpeed(50.0);
        expect(controller.autoScrollSpeed, equals(100.0));

        controller.adjustAutoScrollSpeed(2000.0);
        expect(controller.autoScrollSpeed, equals(2000.0));

        controller.adjustAutoScrollSpeed(-5000.0);
        expect(controller.autoScrollSpeed, equals(10.0));
      });

      testWidgets('auto-scroll pauses on touch via gesture pipeline', (WidgetTester tester) async {
        when(mockSettings.autoScrollPauseOnTouch).thenReturn(true);

        await initController(tester);

        controller.toggleAutoScroll();
        expect(controller.isAutoScrolling, isTrue);

        controller.gesturePipeline.handlePointerDown(
          const PointerDownEvent(position: Offset.zero),
        );
        expect(controller.isUserTouching, isTrue);

        controller.gesturePipeline.handlePointerUp(
          const PointerUpEvent(position: Offset.zero),
        );
        expect(controller.isUserTouching, isFalse);
      });
    });

    group('Zoom Integration', () {
      testWidgets('handles double-tap zoom without throwing', (WidgetTester tester) async {
        await initController(tester);

        controller.setDoubleTapDetails(const Offset(100, 100));
        controller.handleDoubleTapZoom();

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(controller.scaleType, equals(ImageScaleType.fitWidth));
        expect(controller.doubleTapDetails, equals(const Offset(100, 100)));
      });
    });

    group('Settings Integration', () {
      testWidgets('updates theme', (WidgetTester tester) async {
        await initController(tester);

        controller.updateTheme(ReaderThemeMode.white);
        expect(controller.readerTheme, equals(ReaderThemeMode.white));
      });

      testWidgets('updates color filter', (WidgetTester tester) async {
        await initController(tester);

        controller.updateColorFilter(ReaderColorFilter.sepia);
        expect(controller.colorFilter, equals(ReaderColorFilter.sepia));
      });

      testWidgets('updates scale type', (WidgetTester tester) async {
        await initController(tester);

        controller.updateScaleType(ImageScaleType.fitScreen);
        expect(controller.scaleType, equals(ImageScaleType.fitScreen));
      });

      testWidgets('updates invert taps', (WidgetTester tester) async {
        await initController(tester);

        controller.updateInvertTaps(true);
        expect(controller.invertTaps, isTrue);
      });
    });
  });
}
