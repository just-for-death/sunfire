// Golden tests for ReaderCanvas

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sunfire/src/features/reader/controller/reader_canvas.dart';
import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'reader_canvas_test.mocks.dart';

@GenerateMocks([ReaderController, SettingsService])
void main() {
  group('ReaderCanvas Golden Tests', () {
    late MockReaderController mockController;
    late MockSettingsService mockSettings;
    late ScrollController scrollController;
    late PageController pageController;
    late TransformationController transformationController;
    late Map<int, TransformationController> webtoonZoomControllers;
    late Map<int, GlobalKey> webtoonPageKeys;

    setUp(() {
      mockController = MockReaderController();
      mockSettings = MockSettingsService();
      scrollController = ScrollController();
      pageController = PageController();
      transformationController = TransformationController();
      webtoonZoomControllers = {};
      webtoonPageKeys = {};

      // Setup default controller behavior
      when(mockController.readingMode).thenReturn(ReadingMode.longStrip);
      when(mockController.pageUrls).thenReturn(['https://example.com/page1.jpg']);
      when(mockController.currentPage).thenReturn(1);
      when(mockController.colorFilter).thenReturn(ReaderColorFilter.none);
      when(mockController.cropBorders).thenReturn(false);
      when(mockController.scaleType).thenReturn(ImageScaleType.fitWidth);
      when(mockController.readerTheme).thenReturn(ReaderThemeMode.black);
      when(mockController.isZoomed).thenReturn(false);
      when(mockController.scrollController).thenReturn(scrollController);
      when(mockController.pageController).thenReturn(pageController);
      when(mockController.transformationController).thenReturn(transformationController);
      when(mockController.webtoonZoomControllers).thenReturn(webtoonZoomControllers);
      when(mockController.webtoonPageKeys).thenReturn(webtoonPageKeys);
      when(mockController.showTransitionCard).thenReturn(false);
      when(mockController.nextChapter).thenReturn(null);
      when(mockController.chapter).thenReturn(null);
      when(mockController.parentManga).thenReturn(null);
      when(mockController.isAutoScrolling).thenReturn(false);
      when(mockController.invertTaps).thenReturn(false);
      when(mockController.showTapZoneOverlay).thenReturn(false);
      when(mockController.settings).thenReturn(mockSettings);

      // Setup default settings behavior
      when(mockSettings.readingMode).thenReturn('Long Strip');
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
    });

    tearDown(() {
      scrollController.dispose();
      pageController.dispose();
      transformationController.dispose();
      for (final c in webtoonZoomControllers.values) {
        c.dispose();
      }
    });

    testWidgets('renders webtoon mode with single page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.longStrip,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the canvas renders
      expect(find.byType(ReaderCanvas), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders paged mode with single page', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedLtr);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.pagedLtr,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ReaderCanvas), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('applies color filter when set', (WidgetTester tester) async {
      when(mockController.colorFilter).thenReturn(ReaderColorFilter.invert);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.longStrip,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.invert,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ColorFiltered widget is present
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('applies crop borders when enabled', (WidgetTester tester) async {
      when(mockController.cropBorders).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.longStrip,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: true,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ClipRect is present for crop borders
      expect(find.byType(ClipRect), findsAtLeastNWidgets(1));
    });

    testWidgets('shows transition card when next chapter available', (WidgetTester tester) async {
      final nextChapter = Chapter()
        ..serverId = 2
        ..name = 'Chapter 2'
        ..isDownloaded = false;

      when(mockController.nextChapter).thenReturn(nextChapter);
      when(mockController.showTransitionCard).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.longStrip,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
            showTransitionCard: true,
            nextChapter: nextChapter,
            chapter: Chapter()..serverId = 1..name = 'Chapter 1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debug: dump widget tree
      debugDumpApp();

      // Verify transition card elements
      expect(find.text('Finished:'), findsOneWidget);
      expect(find.text('Next:'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);
      expect(find.text('Read Next Chapter'), findsOneWidget);
    });

    testWidgets('shows caught up message when no next chapter', (WidgetTester tester) async {
      when(mockController.nextChapter).thenReturn(null);
      when(mockController.showTransitionCard).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.longStrip,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
            showTransitionCard: true,
            nextChapter: null,
            chapter: Chapter()..serverId = 1..name = 'Chapter 1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("You're all caught up — there's no next chapter."), findsOneWidget);
    });

    testWidgets('renders paged RTL mode correctly', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedRtl);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.pagedRtl,
            pageUrls: ['https://example.com/page1.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // PageView should have reverse=true for RTL
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.reverse, isTrue);
    });

    testWidgets('applies double page spread in paged mode', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedLtr);
      when(mockController.pageUrls).thenReturn([
        'https://example.com/page1.jpg',
        'https://example.com/page2.jpg',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scrollController,
            pageController: pageController,
            transformationController: transformationController,
            webtoonZoomControllers: webtoonZoomControllers,
            webtoonPageKeys: webtoonPageKeys,
            readingMode: ReadingMode.pagedLtr,
            pageUrls: ['https://example.com/page1.jpg', 'https://example.com/page2.jpg'],
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render spread with two pages
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });
  });
}