// ISS-118/120/121: drives the REAL ReaderScreen wiring (injected sub-controllers)
// end to end: Isar chapter -> NavigationController -> ReaderController ->
// screen _onChapterLoaded. Would have caught H1 (callbacks never wired).
import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/metron/metron_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/reader/controller/gesture_pipeline.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/features/reader/controller/reader_controller.dart';
import 'package:sunfire/src/features/reader/reader_chapter_resolve.dart';
import 'package:sunfire/src/features/reader/reader_prefetch.dart';
import 'package:sunfire/src/features/reader/reader_screen.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

import 'reader_controller_test.mocks.dart';

String? _findIsarNative() {
  // Prefer isar_community_flutter_libs (3.3.2); fall back to legacy isar_flutter_libs.
  String? legacy;
  // 1) pub-cache hosted layout: .pub-cache/hosted/pub.dev/isar_community_flutter_libs-*/linux/libisar.so
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 2) legacy flat pub-cache layout.
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 3) flutter test build output (rebuilt via `flutter build linux --debug`).
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}


// 1x1 transparent PNG.
const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late List<String> pages;

  setUpAll(() async {
    pageLoaderTestMode = true;
    tempDir = await Directory.systemTemp.createTemp('sunfire_reader_wiring');
    final native = _findIsarNative();
    if (native == null) fail('libisar.so not found');
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
    pages = [for (var i = 0; i < 3; i++) '${tempDir.path}/p$i.png'];
    for (final p in pages) {
      File(p).writeAsBytesSync(_png);
    }
  });

  tearDownAll(() async {
    pageLoaderTestMode = false;
    NavigationController.debugResetTestOverrides();
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SettingsService.instance.incognitoMode = true; // no platform mirrors
    SettingsService.instance.keepScreenAwake = false;
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() => isar.clear());
    final manga = Manga()
      ..serverId = 7
      ..title = 'Wiring'
      ..sourceName = 'local';
    final chapter = Chapter()
      ..serverId = 70
      ..mangaId = 7
      ..name = 'Ch 1'
      ..url = '/wiring/ch1';
    await IsarService.instance.saveManga(manga);
    await IsarService.instance.saveChapter(chapter);
    await IsarService.instance.saveChapter(Chapter()
      ..serverId = 71
      ..mangaId = 7
      ..name = 'Ch 2'
      ..chapterNumber = 2
      ..url = '/wiring/ch2');
    chapter.chapterNumber = 1;
    await IsarService.instance.saveChapter(chapter);
  });

  NavigationController newNav() => NavigationController(
        isarService: IsarService.instance,
        pageLoader: PageLoader(sourceName: '', mangaId: 7, chapterTargetId: 70),
        positionManager: MockPositionManager(),
        settings: SettingsService.instance,
      );

  Future<void> pumpReader(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: ReaderScreen(chapterServerId: 70)));
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const SizedBox());
      // Give time for the reader screen to dispose (cancels PageLoader timers, etc.)
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
  }

  testWidgets('success: pages appear and the spinner clears', (tester) async {
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    await pumpReader(tester);
    expect(find.text('Loading Chapter...'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(Image), findsWidgets);
    await unmount(tester);
  });

  testWidgets('failure: resolver throws -> error screen with Retry, no spinner', (tester) async {
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) =>
        Future<ChapterPagesResult>.error(StateError('boom'));
    await pumpReader(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('timeout: hung resolver -> error screen with Retry, no spinner', (tester) async {
    NavigationController.resolveTimeout = const Duration(milliseconds: 200);
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) =>
        Completer<ChapterPagesResult>().future;
    await pumpReader(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('UIS-12: narrow 320px phone at 1.5x text has no reader overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    await pumpReader(tester);
    expect(tester.takeException(), isNull, reason: 'reader initial layout');
    // Reveal the overlay chrome (tap centre) and re-check with the HUD up.
    await tester.runAsync(() async {
      await tester.tapAt(const Offset(160, 320));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    });
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'reader HUD layout');
    await unmount(tester);
  });

  test('ISS-119: prefetch hit keeps the prefetched source when ours is unknown', () async {
    final m = (await IsarService.instance.getMangaByServerId(7))!..sourceName = '';
    await IsarService.instance.saveManga(m);
    var resolverCalls = 0;
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async {
      resolverCalls++;
      return ChapterPagesResult(pageUrls: const [], source: ContentSourceType.fallback);
    };
    final loader = PageLoader(sourceName: '', mangaId: 7, chapterTargetId: 70);
    final nav = NavigationController(
      isarService: IsarService.instance,
      pageLoader: loader,
      positionManager: MockPositionManager(),
      settings: SettingsService.instance,
    );
    // Source-free key; value-side source check allows one-known/one-unknown
    loader.setPrefetchedChapter(readerPrefetchKey(chapterTargetId: 70, mangaId: 7), 'SrcX', pages);
    await nav.loadChapterAndPages(70);
    expect(resolverCalls, 0);
    expect(nav.pageUrls, pages);
    expect(nav.sourceName, 'SrcX');
    loader.dispose();
  });

  testWidgets('ISS-127: next-chapter prefetch fires at the 65% threshold through the real paged screen',
      (tester) async {
    SettingsService.instance.readingMode = readingModeSettingsValue(ReadingMode.pagedLtr);
    NavigationController.prefetchFailureCooldown = Duration.zero;
    final ten = [for (var i = 0; i < 10; i++) pages[i % pages.length]];
    final calls = <int>[];
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async {
      calls.add(chapterServerId);
      if (chapterServerId == 70) return ChapterPagesResult(pageUrls: ten, source: ContentSourceType.localExtension);
      return ChapterPagesResult(pageUrls: const [], source: ContentSourceType.fallback); // keep re-firing
    };
    await pumpReader(tester);
    expect(find.text('Retry'), findsNothing);
    final loadEnd = calls.where((c) => c == 71).length; // unconditional post-load prefetch
    final pv = tester.widget<PageView>(find.byType(PageView).first);
    Future<void> goTo(int index) async {
      await tester.runAsync(() async {
        pv.controller!.jumpToPage(index);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }
    await goTo(5); // page 6 of 10: below 65%
    expect(calls.where((c) => c == 71).length, loadEnd);
    await goTo(6); // page 7 of 10: at threshold
    expect(calls.where((c) => c == 71).length, loadEnd + 1);
    await unmount(tester);
  });

  test('ISS-120: a hung self-heal scrape times out and the load still finishes', () async {
    final isar = IsarService.instance;
    final ch = (await isar.getChapterByServerId(70))!
      ..url = ''
      ..realUrl = '';
    await isar.saveChapter(ch);
    NavigationController.selfHealTimeout = const Duration(milliseconds: 100);
    NavigationController.debugSelfHealFetchOverride = (_, __) => Completer<Map<String, dynamic>>().future;
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    final nav = newNav();
    final events = <bool>[];
    nav.onLoadingChanged = events.add;
    await nav.loadChapterAndPages(70).timeout(const Duration(seconds: 5));
    expect(events, [true, false]);
    expect(nav.pageUrls, pages);
    nav.pageLoader.dispose();
  });

  test('ISS-121: hung sibling lookup times out; its late result is discarded', () async {
    NavigationController.ioTimeout = const Duration(milliseconds: 100);
    final late = Completer<SiblingChapterNav>();
    NavigationController.debugSiblingNavOverride = (_) => late.future;
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    final nav = newNav();
    await nav.loadChapterAndPages(70).timeout(const Duration(seconds: 5));
    expect(nav.pageUrls, pages, reason: 'chapter opens without siblings');
    expect(nav.nextChapter, isNull);
    final other = (await IsarService.instance.getChapterByServerId(71))!;
    late.complete(SiblingChapterNav(siblings: [other], next: other, prev: null));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(nav.nextChapter, isNull, reason: 'timed-out lookup must not set next later');
    expect(nav.siblingChapters, isEmpty);
    nav.pageLoader.dispose();
  });

  test('ISS-123: rapid chapter switch — stale load is abandoned and never clears the new spinner', () async {
    final hang = Completer<ChapterPagesResult>();
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) =>
        chapterServerId == 70
            ? hang.future
            : Future.value(ChapterPagesResult(pageUrls: pages.reversed.toList(), source: ContentSourceType.localExtension));
    final nav = newNav();
    final rc = ReaderController(
      chapterServerId: 70,
      isarService: IsarService.instance,
      settings: SettingsService.instance,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
      positionManager: nav.positionManager,
      navigationController: nav,
      gesturePipeline: GesturePipeline(
          navigationController: nav, positionManager: nav.positionManager, settings: SettingsService.instance),
    );
    rc.attachUiControllers(
      scrollController: ScrollController(),
      pageController: PageController(),
      transformationController: TransformationController(),
      webtoonZoomControllers: {},
    );
    rc.restoreProgressOnLoad = false;
    final events = <bool>[];
    final loaded = <int>[];
    rc.onLoadingChanged = events.add;
    rc.onChapterLoaded = (c, _, __, ___) => loaded.add(c.serverId);
    final first = rc.loadChapter(70);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final second = rc.loadChapter(71);
    await second.timeout(const Duration(seconds: 5));
    await first.timeout(const Duration(seconds: 1), onTimeout: () => fail('stale resolve not abandoned'));
    expect(events.last, isFalse);
    final settled = events.length;
    hang.complete(ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(events.length, settled, reason: 'stale load emits nothing after the switch');
    expect(loaded, [71]);
    expect(nav.chapter?.serverId, 71);
    expect(nav.pageUrls, pages.reversed.toList());
    rc.dispose();
    nav.pageLoader.dispose();
  });

  group('ISS-131 desktop remote page: spinner -> image / Retry', () {
    final isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    const remote = ['https://img.invalid/p0.png'];

    Future<void> run(WidgetTester tester, {required bool succeed}) async {
      final gate = Completer<void>();
      PageLoader.debugDefaultFetchOverride = (url) async {
        await gate.future;
        return succeed ? PageLoadResult(bytes: Uint8List.fromList(_png)) : PageLoadResult(error: 'boom');
      };
      NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
          ChapterPagesResult(pageUrls: chapterServerId == 70 ? remote : const [], source: ContentSourceType.fallback);
      await pumpReader(tester);
      expect(find.text('Retry'), findsNothing, reason: 'chapter loaded');
      expect(find.byType(CircularProgressIndicator), findsWidgets, reason: 'page spinner while fetching');
      await tester.runAsync(() async {
        gate.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      if (succeed) {
        expect(find.byWidgetPredicate((w) => w is Image && _isMemoryImage(w.image), skipOffstage: false), findsWidgets);
        expect(find.byTooltip('Retry Page 1', skipOffstage: false), findsNothing);
      } else {
        expect(find.byTooltip('Retry Page 1'), findsOneWidget);
      }
      await unmount(tester);
    }

    testWidgets('loads -> image', (t) => run(t, succeed: true), skip: !isDesktop);
    testWidgets('fails -> Retry', (t) => run(t, succeed: false), skip: !isDesktop);
  });

  test('ISS-121: a hung progress flush times out and the next load still runs', () async {
    NavigationController.ioTimeout = const Duration(milliseconds: 100);
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    final pm = MockPositionManager();
    when(pm.updateProgress(
      chapterSnapshot: anyNamed('chapterSnapshot'),
      totalPages: anyNamed('totalPages'),
      page: anyNamed('page'),
      parentManga: anyNamed('parentManga'),
    )).thenAnswer((_) => Completer<ProgressUpdateResult>().future);
    final nav = NavigationController(
      isarService: IsarService.instance,
      pageLoader: PageLoader(sourceName: '', mangaId: 7, chapterTargetId: 70),
      positionManager: pm,
      settings: SettingsService.instance,
    );
    await nav.loadChapterAndPages(70).timeout(const Duration(seconds: 5));
    final events = <bool>[];
    nav.onLoadingChanged = events.add;
    await nav.loadChapterAndPages(71).timeout(const Duration(seconds: 5), onTimeout: () => fail('flush not bounded'));
    expect(events, [true, false]);
    expect(nav.chapter?.serverId, 71);
    nav.pageLoader.dispose();
  });

  testWidgets('ISS-123: the error screen never flashes during a successful load', (tester) async {
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
    var sawError = false;
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: ReaderScreen(chapterServerId: 70)));
      for (var i = 0; i < 200; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 2));
        await tester.pump();
        if (find.text('Retry').evaluate().isNotEmpty) sawError = true;
      }
    });
    expect(sawError, isFalse);
    expect(find.text('Loading Chapter...'), findsNothing);
    expect(find.byType(Image), findsWidgets);
    await unmount(tester);
  });
}

/// IMP-009: decoded-at-size pages wrap the MemoryImage in a ResizeImage.
bool _isMemoryImage(ImageProvider p) =>
    p is MemoryImage || (p is ResizeImage && p.imageProvider is MemoryImage);
