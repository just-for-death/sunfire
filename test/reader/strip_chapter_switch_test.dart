// IMP-012 final piece: inline chapter switch in the seamless webtoon strip.
//  1) [A,B] -> [B,C] trim keeps the visible page in place (no jump/flash).
//  2) ISS-135 pinned page-cache set follows the new current chapter.
//  3) Crossing the separator completes A via the normal end-of-chapter path;
//     incognito saves nothing.
//  +  progress for a next-chapter page lands on that chapter.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/features/reader/controller/gesture_pipeline.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/features/reader/controller/reader_canvas.dart';
import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/controller/reader_input_pipeline.dart'
    show shiftStripIndexMaps, stripItemScrollOffset;
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/features/reader/controller/webtoon_item_registry.dart';
import 'package:sunfire/src/features/reader/reader_prefetch.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

import '../reader_canvas_test.mocks.dart' as cm;
import '../reader_controller_test.mocks.dart';

Chapter _ch(int serverId) => Chapter()
  ..id = serverId
  ..serverId = serverId
  ..mangaId = 7
  ..chapterNumber = serverId.toDouble()
  ..name = 'Ch $serverId'
  ..url = 'https://src.invalid/c/$serverId';

List<String> _urls(String p, int n) => [for (var i = 0; i < n; i++) '$p$i'];

void _stubSettings(MockSettingsService s, {bool incognito = false}) {
  when(s.readingMode).thenReturn('Long Strip');
  when(s.readerTheme).thenReturn('Black');
  when(s.colorFilter).thenReturn('None');
  when(s.scaleType).thenReturn('Fit Width');
  when(s.tapZonesEnabled).thenReturn(true);
  when(s.tapZonePresetPaged).thenReturn('Default');
  when(s.tapZonePresetWebtoon).thenReturn('Default');
  when(s.tapZonesOverlaySeen).thenReturn(true);
  when(s.defaultAutoScrollSpeed).thenReturn(50.0);
  when(s.autoScrollPauseOnTouch).thenReturn(true);
  when(s.autoScrollSmoothEaseIn).thenReturn(true);
  when(s.doublePageDisplayMode).thenReturn('Automatic');
  when(s.invertDoublePages).thenReturn(false);
  when(s.doublePageOffset).thenReturn(false);
  when(s.seamlessTransitions).thenReturn(true);
  when(s.showEndOfChapterDialog).thenReturn(true);
  when(s.cropBorders).thenReturn(false);
  when(s.invertTapZones).thenReturn(false);
  when(s.keepScreenAwake).thenReturn(false);
  when(s.volumeKeyTurn).thenReturn(false);
  when(s.incognitoMode).thenReturn(incognito);
  when(s.deleteFinishedChaptersWhileReading).thenReturn('Never');
}

class _Rig {
  _Rig({bool incognito = false, bool realPositionManager = false}) {
    _stubSettings(settings, incognito: incognito);
    isar = MockIsarService();
    final pm = realPositionManager
        ? PositionManager(
            settings: settings,
            isarService: isar,
            syncEngine: MockSyncEngine(),
            metronService: MockMetronService(),
          )
        : mockPm;
    if (!realPositionManager) {
      when(mockPm.updateProgress(
        chapterSnapshot: anyNamed('chapterSnapshot'),
        totalPages: anyNamed('totalPages'),
        page: anyNamed('page'),
        parentManga: anyNamed('parentManga'),
      )).thenAnswer((_) async => ProgressUpdateResult.none);
    }
    nav = NavigationController(
      isarService: isar,
      pageLoader: loader,
      positionManager: pm,
      settings: settings,
    );
    gp = GesturePipeline(navigationController: nav, positionManager: pm, settings: settings);
    rc = ReaderController(
      chapterServerId: 1,
      isarService: isar,
      settings: settings,
      syncEngine: MockSyncEngine(),
      metronService: MockMetronService(),
      navigationController: nav,
      pageLoader: loader,
      positionManager: pm,
      gesturePipeline: gp,
    );
    // Strip [A,B]; B and C already prefetched (so prefetch is a no-op).
    for (final c in [b, cc]) {
      loader.setPrefetchedChapter(
          readerPrefetchKey(chapterTargetId: c.serverId, mangaId: 7), 'S', c == b ? bUrls : cUrls);
    }
    nav
      ..setSiblingChapters([a, b, cc])
      ..setChapter(a)
      ..setNextChapter(b)
      ..setPageUrls(aUrls);
    rc.refreshStripChapters();
  }

  final settings = MockSettingsService();
  late final MockIsarService isar;
  final mockPm = MockPositionManager();
  final loader = PageLoader(sourceName: 'S', mangaId: 7, chapterTargetId: 1, prefetchMode: () => 'Never');
  late final NavigationController nav;
  late final GesturePipeline gp;
  late final ReaderController rc;
  final a = _ch(1), b = _ch(2), cc = _ch(3);
  final aUrls = _urls('a', 3), bUrls = _urls('b', 3), cUrls = _urls('c', 2);

  void dispose() {
    rc.dispose();
    gp.dispose();
    loader.dispose();
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('crossing the separator switches chapter in place, pins B, completes A', () async {
    final r = _Rig();
    addTearDown(r.dispose);
    // items: a0 a1 a2 | b0 b1 b2 |
    expect(r.rc.activeStripItems, hasLength(8));
    var switched = 0;
    r.rc.onStripChapterSwitched = (_, __, ___) => switched++;

    final res = r.rc.onStripItemVisible(4)!; // b0, past the separator
    await _settle();

    expect(r.nav.chapter, same(r.b), reason: 'switched without a reload');
    expect(r.nav.pageUrls, r.bUrls);
    expect(r.nav.nextChapter, same(r.cc));
    expect(switched, 1);
    expect(res.page, 1);
    expect(res.removedItems, 0, reason: 'no trim while the separator may be on screen');
    // 2) ISS-135 pinned set moved to B.
    expect(r.loader.isPinnedPage('b0'), isTrue);
    expect(r.loader.isPinnedPage('a0'), isFalse);
    // 3) A completed through the normal path (PositionManager.updateProgress, last page).
    verify(r.mockPm.updateProgress(
      chapterSnapshot: r.a,
      totalPages: 3,
      page: 3,
      parentManga: anyNamed('parentManga'),
    )).called(1);
    // Strip grew to [A,B,C] (C was prefetched), indices unchanged.
    expect(r.rc.stripChapters.map((e) => e.chapter.serverId), [1, 2, 3]);
  });

  test('progress for a page in the next chapter lands on that chapter', () async {
    final r = _Rig();
    addTearDown(r.dispose);
    r.rc.onStripItemVisible(5); // b1
    await Future<void>.delayed(const Duration(milliseconds: 650)); // debounce
    verify(r.mockPm.updateProgress(
      chapterSnapshot: r.b,
      totalPages: 3,
      page: 2,
      parentManga: anyNamed('parentManga'),
    )).called(1);
    verifyNever(r.mockPm.updateProgress(
      chapterSnapshot: r.a,
      totalPages: anyNamed('totalPages'),
      page: 2,
      parentManga: anyNamed('parentManga'),
    ));
  });

  test('2+ pages into B the strip trims to [B,C] with an exact offset delta', () async {
    final r = _Rig();
    addTearDown(r.dispose);
    r.rc.onStripItemVisible(4);
    for (var i = 0; i < 4; i++) {
      r.rc.recordStripItemExtent(i, i == 3 ? kReaderChapterBoundaryExtent : 300);
    }
    final res = r.rc.onStripItemVisible(6)!; // b2
    expect(res.removedItems, 4);
    expect(res.removedExtent, 900 + kReaderChapterBoundaryExtent);
    expect(r.rc.stripChapters.map((e) => e.chapter.serverId), [2, 3]);
    final items = r.rc.activeStripItems!;
    expect((items[2] as ReaderPageItem).url, 'b2', reason: 'b2 is now item 2 (6 - 4)');
    expect(r.rc.stripCurrentChapterOffset, 0);
  });

  test('incognito: crossing the separator saves nothing', () async {
    final r = _Rig(incognito: true, realPositionManager: true);
    addTearDown(r.dispose);
    r.rc.onStripItemVisible(4);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    expect(r.nav.chapter, same(r.b), reason: 'the switch itself still happens');
    verifyZeroInteractions(r.isar);
  });

  testWidgets('trim + key shift + offset correction keep the visible page still',
      (tester) async {
    final mockController = cm.MockReaderController();
    final registry = WebtoonItemRegistry();
    final mockSettings = cm.MockSettingsService();
    when(mockController.settings).thenReturn(mockSettings);
    when(mockController.isZoomed).thenReturn(false);
    when(mockController.webtoonItemRegistry).thenReturn(registry);
    final scroll = ScrollController();
    final zooms = <int, TransformationController>{};
    addTearDown(scroll.dispose);
    final a = _ch(1), b = _ch(2), c = _ch(3);
    var items = buildReaderItems([
      ReaderChapterPages(a, _urls('a', 3)),
      ReaderChapterPages(b, _urls('b', 3)),
      ReaderChapterPages(c, _urls('c', 2)),
    ]);

    Widget canvas() => MaterialApp(
          home: ReaderCanvas(
            controller: mockController,
            scrollController: scroll,
            pageController: PageController(),
            transformationController: TransformationController(),
            webtoonZoomControllers: zooms,
            readingMode: ReadingMode.longStrip,
            pageUrls: _urls('b', 3),
            currentPage: 1,
            colorFilter: ReaderColorFilter.none,
            cropBorders: false,
            scaleType: ImageScaleType.fitWidth,
            readerTheme: ReaderThemeMode.black,
            webtoonItems: items,
            pageBuilder: (context, url, index,
                    {required isPaged, contentWidth, enablePerPageZoom = false}) =>
                SizedBox(height: 300, child: Text('page:$url')),
          ),
        );

    await tester.pumpWidget(canvas());
    scroll.jumpTo(900 + kReaderChapterBoundaryExtent + 600 + 50); // into b2
    await tester.pump();
    final before = tester.getTopLeft(find.text('page:b2')).dy;
    final elementBefore = tester.element(find.text('page:b2'));

    // What ReaderInputPipeline does on a trim of A (3 pages + separator).
    const removed = 4;
    const removedExtent = 900 + kReaderChapterBoundaryExtent;
    registry.shift(removed);
    shiftStripIndexMaps(zooms, removed, onDrop: (z) => z.dispose());
    scroll.position.correctPixels(scroll.position.pixels - removedExtent);
    items = buildReaderItems([
      ReaderChapterPages(b, _urls('b', 3)),
      ReaderChapterPages(c, _urls('c', 2)),
    ]);
    await tester.pumpWidget(canvas()); // single frame: no intermediate paint
    final after = tester.getTopLeft(find.text('page:b2')).dy;
    expect(after, closeTo(before, 0.5));
    // IMP-028: stable item keys keep b2's element across the index shift.
    expect(identical(tester.element(find.text('page:b2')), elementBefore), isTrue);
    expect(registry.contextOf(2), isNotNull, reason: 'b2 re-registered at its new index');
    expect(find.text('page:a0'), findsNothing);
  });

  testWidgets('jump to an offscreen page while the old chapter is still in the strip lands exactly',
      (tester) async {
    final mockController = cm.MockReaderController();
    final registry = WebtoonItemRegistry();
    when(mockController.settings).thenReturn(cm.MockSettingsService());
    when(mockController.isZoomed).thenReturn(false);
    when(mockController.webtoonItemRegistry).thenReturn(registry);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    final heights = {'a0': 300.0, 'a1': 450.0, 'a2': 250.0, 'b0': 500.0, 'b1': 350.0, 'b2': 300.0};
    final items = buildReaderItems([
      ReaderChapterPages(_ch(1), _urls('a', 3)),
      ReaderChapterPages(_ch(2), _urls('b', 3)),
      ReaderChapterPages(_ch(3), _urls('c', 2)),
    ]);
    await tester.pumpWidget(MaterialApp(
      home: ReaderCanvas(
        controller: mockController,
        scrollController: scroll,
        pageController: PageController(),
        transformationController: TransformationController(),
        webtoonZoomControllers: <int, TransformationController>{},
        readingMode: ReadingMode.longStrip,
        pageUrls: _urls('b', 3),
        currentPage: 1,
        colorFilter: ReaderColorFilter.none,
        cropBorders: false,
        scaleType: ImageScaleType.fitWidth,
        readerTheme: ReaderThemeMode.black,
        webtoonItems: items,
        pageBuilder: (context, url, index,
                {required isPaged, contentWidth, enablePerPageZoom = false}) =>
            SizedBox(height: heights[url] ?? 300, child: Text('page:$url')),
      ),
    ));
    expect(find.text('page:b2'), findsNothing, reason: 'target starts offscreen');
    // Current chapter B starts at item 4 (A's 3 pages + separator). A was
    // measured while reading (recorded); B's pages fall back to estimates.
    final recorded = <int, double>{0: 300, 1: 450, 2: 250, 3: kReaderChapterBoundaryExtent};
    const page = 3; // b2
    const stripOffset = 4;
    final target = stripItemScrollOffset(
      items: items,
      itemIndex: page - 1 + stripOffset,
      recorded: (i) => recorded[i],
      estimatePage: (p) => heights[p.url]!, // exact cached heights
    );
    expect(target, 300 + 450 + 250 + kReaderChapterBoundaryExtent + 500 + 350);
    scroll.jumpTo(target);
    await tester.pump();
    // -1: longStrip's intentional 1px paint-only overlap (Transform), not layout.
    expect(tester.getTopLeft(find.text('page:b2')).dy, closeTo(-1, 0.01));
  });
}
