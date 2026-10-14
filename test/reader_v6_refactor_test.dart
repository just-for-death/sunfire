// v6 reader refactor (Steps 1-9) + ISS-032 upcoming-page prefetch wiring.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/reader_page_widget.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/features/reader/reader_download_ahead.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

ReaderPageWidgetConfig _config({
  required int index,
  PageLoader? loader,
  Future<void> Function(String url, int index, {bool manual})? onRecover,
}) {
  return ReaderPageWidgetConfig(
    url: 'https://img.invalid/p$index.jpg',
    index: index,
    constraints: const BoxConstraints(maxWidth: 400, maxHeight: 800),
    isPaged: false,
    contentWidth: 400,
    enablePerPageZoom: false,
    readingMode: ReadingMode.longStrip,
    colorFilter: ReaderColorFilter.none,
    cropBorders: false,
    scaleType: ImageScaleType.fitWidth,
    readerTheme: ReaderThemeMode.black,
    pageLoader: loader,
    sourceName: '',
    settings: SettingsService.instance,
    cachedPageHeights: {},
    cachedPageAspects: {},
    recoveringUrls: {},
    failedImageUrls: {},
    canvasBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(),
    onRecoverImage: onRecover ?? (url, i, {bool manual = false}) async {},
    onScheduleHeightCache: (_, __, ___) {},
    onDoubleTapDown: (_) {},
    onDoubleTapZoom: ({controllerOverride, pageIndex}) {},
    onPruneZoomState: (_) {},
    webtoonZoomControllerFor: (_) => TransformationController(),
    transformationController: null,
    minZoomScale: 1,
    maxZoomScale: 3,
    isZoomed: false,
    onInteractionUpdate: (_) {},
    onInteractionEnd: (_) {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  group('ISS-128 page build has no fetch side effects', () {
    testWidgets('building a remote page does not start a fetch (desktop or not)', (tester) async {
      final calls = <String>[];
      final loader = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2);
      addTearDown(loader.dispose);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (_) => buildReaderPageWidget(_config(
            index: 3,
            loader: loader,
            onRecover: (url, i, {bool manual = false}) async => calls.add(url),
          )),
        ),
      ));
      await tester.pump(); // post-frame callbacks would run here
      expect(calls, isEmpty);
    });

    testWidgets('bytes come from the PageLoader LRU (single cache)', (tester) async {
      final loader = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2);
      addTearDown(loader.dispose);
      loader.cacheBytes('https://img.invalid/p0.jpg', Uint8List.fromList(List.filled(8, 0)));
      await tester.pumpWidget(MaterialApp(home: buildReaderPageWidget(_config(index: 0, loader: loader))));
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('PageLoader helpers (Steps 1-2, 5)', () {
    test('prefetched chapter is consumed exactly once', () {
      final l = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2);
      l.setPrefetchedChapter('2|1', 'S', ['a', 'b']);
      expect(l.isPrefetched('2|1'), isTrue);
      final p = l.takePrefetchedChapter('2|1');
      expect(p?.urls, ['a', 'b']);
      expect(p?.sourceName, 'S');
      expect(l.takePrefetchedChapter('2|1'), isNull);
      l.dispose();
    });

    test('failed URL tracking + mutable source', () {
      final l = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2);
      l.markUrlFailed('u');
      expect(l.isUrlFailed('u'), isTrue);
      l.clearFailedUrl('u');
      expect(l.isUrlFailed('u'), isFalse);
      l.setSourceName('T');
      expect(l.sourceName, 'T');
      l.dispose();
    });

    test('a known-failed URL short-circuits without network', () async {
      final l = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2);
      l.markUrlFailed('https://img.invalid/x.jpg');
      final r = await l.loadPage(url: 'https://img.invalid/x.jpg', index: 0, priority: PageLoadPriority.current);
      expect(r.bytes, isNull);
      l.dispose();
    });
  });

  group('downloadAheadCandidates (extracted)', () {
    Chapter c(int id, {bool read = false}) => Chapter()
      ..id = id
      ..serverId = id * 10
      ..isRead = read;
    test('next unread, not downloaded, capped by count', () {
      final list = [c(1), c(2), c(3, read: true), c(4), c(5), c(6)];
      final got = downloadAheadCandidates(
        siblings: list, current: list[1], count: 2, isDownloaded: (ch) => ch.id == 4);
      expect(got.map((e) => e.id), [5, 6]);
    });
    test('current missing or count 0 → empty', () {
      final list = [c(1), c(2)];
      expect(downloadAheadCandidates(siblings: list, current: c(9), count: 3, isDownloaded: (_) => false), isEmpty);
      expect(downloadAheadCandidates(siblings: list, current: list[0], count: 0, isDownloaded: (_) => false), isEmpty);
    });
  });

  group('ISS-124 decode errors offer Retry', () {
    testWidgets('undecodable cached bytes → Tap to Retry → bytes evicted and refetched', (tester) async {
      final fetched = <String>[];
      // Valid PNG header (passes looksLikeImageHeader) but undecodable body.
      final bogus = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(64, 0)]);
      final loader = PageLoader(
        sourceName: 'S',
        mangaId: 1,
        chapterTargetId: 2,
        fetchOverride: (url) async {
          fetched.add(url);
          return PageLoadResult(bytes: bogus);
        },
      );
      final cfg = _config(index: 0, loader: loader);
      loader.cacheBytes(cfg.url, bogus);
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: buildReaderPageWidget(cfg))));
        for (var i = 0; i < 20 && find.text('Tap to Retry').evaluate().isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
        }
      });
      expect(find.text('Page 1 Failed to Load'), findsOneWidget);
      expect(find.text('Tap to Retry'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Tap to Retry'));
        for (var i = 0; i < 20 && fetched.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });
      expect(fetched, [cfg.url], reason: 'manual retry evicts the bad bytes and refetches');
      loader.dispose();
    });
  });
}
