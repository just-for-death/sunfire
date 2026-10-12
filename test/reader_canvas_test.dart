// Widget smoke / behavior tests for ReaderCanvas (T2.1).
// Prefer real asserts over golden screenshots — CI-stable and API-honest.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/reader_canvas.dart';
import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

import 'reader_canvas_test.mocks.dart';

@GenerateMocks([ReaderController, SettingsService])
void main() {
  group('ReaderCanvas widget tests', () {
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

      when(mockSettings.readingMode).thenReturn('Long Strip');
      when(mockSettings.tapZonesEnabled).thenReturn(true);
      when(mockSettings.tapZonePresetPaged).thenReturn('Default');
      when(mockSettings.tapZonePresetWebtoon).thenReturn('Default');
      when(mockSettings.tapZonesOverlaySeen).thenReturn(true);
      when(mockSettings.defaultAutoScrollSpeed).thenReturn(50.0);
      when(mockSettings.autoScrollPauseOnTouch).thenReturn(true);
      when(mockSettings.autoScrollSmoothEaseIn).thenReturn(true);
      when(mockSettings.doublePageDisplayMode).thenReturn('Automatic');
      when(mockSettings.invertDoublePages).thenReturn(false);
      when(mockSettings.doublePageOffset).thenReturn(false);
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

    Widget buildCanvas({
      ReadingMode readingMode = ReadingMode.longStrip,
      List<String> pageUrls = const ['https://example.com/page1.jpg'],
      ReaderColorFilter colorFilter = ReaderColorFilter.none,
      bool cropBorders = false,
      bool showTransitionCard = false,
      Chapter? nextChapter,
      Chapter? chapter,
    }) {
      return MaterialApp(
        home: ReaderCanvas(
          controller: mockController,
          scrollController: scrollController,
          pageController: pageController,
          transformationController: transformationController,
          webtoonZoomControllers: webtoonZoomControllers,
          webtoonPageKeys: webtoonPageKeys,
          readingMode: readingMode,
          pageUrls: pageUrls,
          currentPage: 1,
          colorFilter: colorFilter,
          cropBorders: cropBorders,
          scaleType: ImageScaleType.fitWidth,
          readerTheme: ReaderThemeMode.black,
          showTransitionCard: showTransitionCard,
          nextChapter: nextChapter,
          chapter: chapter,
        ),
      );
    }

    testWidgets('renders webtoon mode with ListView', (WidgetTester tester) async {
      await tester.pumpWidget(buildCanvas());
      await tester.pump();

      expect(find.byType(ReaderCanvas), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('renders paged LTR mode with PageView', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedLtr);

      await tester.pumpWidget(buildCanvas(readingMode: ReadingMode.pagedLtr));
      await tester.pump();

      expect(find.byType(ReaderCanvas), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('applies ColorFiltered when invert filter set', (WidgetTester tester) async {
      when(mockController.colorFilter).thenReturn(ReaderColorFilter.invert);

      await tester.pumpWidget(buildCanvas(colorFilter: ReaderColorFilter.invert));
      await tester.pump();

      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('applies ClipRect when crop borders enabled', (WidgetTester tester) async {
      when(mockController.cropBorders).thenReturn(true);

      await tester.pumpWidget(buildCanvas(cropBorders: true));
      await tester.pump();

      expect(find.byType(ClipRect), findsAtLeastNWidgets(1));
    });

    testWidgets('shows transition card with next chapter CTA', (WidgetTester tester) async {
      final nextChapter = Chapter()
        ..serverId = 2
        ..name = 'Chapter 2'
        ..isDownloaded = false;

      when(mockController.nextChapter).thenReturn(nextChapter);
      when(mockController.showTransitionCard).thenReturn(true);
      when(mockController.loadNextChapter()).thenAnswer((_) async {});

      await tester.pumpWidget(buildCanvas(
        showTransitionCard: true,
        nextChapter: nextChapter,
        chapter: Chapter()
          ..serverId = 1
          ..name = 'Chapter 1',
      ));
      await tester.pump();

      expect(find.text('Finished:'), findsOneWidget);
      expect(find.text('Next:'), findsOneWidget);
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('Chapter 2'), findsOneWidget);
      expect(find.text('Read Next Chapter'), findsOneWidget);

      await tester.tap(find.text('Read Next Chapter'));
      await tester.pump();
      verify(mockController.loadNextChapter()).called(1);
    });

    testWidgets('shows caught up message when no next chapter', (WidgetTester tester) async {
      when(mockController.nextChapter).thenReturn(null);
      when(mockController.showTransitionCard).thenReturn(true);

      await tester.pumpWidget(buildCanvas(
        showTransitionCard: true,
        nextChapter: null,
        chapter: Chapter()
          ..serverId = 1
          ..name = 'Chapter 1',
      ));
      await tester.pump();

      expect(
        find.text("You're all caught up — there's no next chapter."),
        findsOneWidget,
      );
      expect(find.text('Read Next Chapter'), findsNothing);
    });

    testWidgets('paged RTL PageView is reversed', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedRtl);

      await tester.pumpWidget(buildCanvas(readingMode: ReadingMode.pagedRtl));
      await tester.pump();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.reverse, isTrue);
    });

    testWidgets('double-page landscape builds a Row spread', (WidgetTester tester) async {
      when(mockController.readingMode).thenReturn(ReadingMode.pagedLtr);
      when(mockController.pageUrls).thenReturn([
        'https://example.com/page1.jpg',
        'https://example.com/page2.jpg',
      ]);
      when(mockSettings.doublePageDisplayMode).thenReturn('Always');

      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildCanvas(
        readingMode: ReadingMode.pagedLtr,
        pageUrls: [
          'https://example.com/page1.jpg',
          'https://example.com/page2.jpg',
        ],
      ));
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });

    testWidgets('semantics label includes page and chapter', (WidgetTester tester) async {
      await tester.pumpWidget(buildCanvas(
        chapter: Chapter()
          ..serverId = 1
          ..name = 'Ch. One',
      ));
      await tester.pump();

      expect(
        find.bySemanticsLabel('Page 1 of 1, Ch. One'),
        findsOneWidget,
      );
    });
  });
}
