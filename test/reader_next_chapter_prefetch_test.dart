// ISS-127 / v6 Step 9: behavioural next-chapter prefetch tests
// (store, threshold, dedupe, cooldown, stale-result discard, timeout).
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/reader_prefetch.dart';

import 'reader_controller_test.mocks.dart';

Chapter _ch(int id) => Chapter()
  ..serverId = id
  ..mangaId = 7
  ..name = 'Ch $id'
  ..url = 'https://src.invalid/c/$id';

String _key(Chapter c) => readerPrefetchKey(chapterTargetId: c.serverId, mangaId: c.mangaId);

void main() {
  late PageLoader loader;
  late NavigationController nav;
  late int calls;

  void resolveWith(Future<ChapterPagesResult> Function() f) {
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) {
      calls++;
      return f();
    };
  }

  // Non-http URLs: the 3-image warm-up skips them, so no network.
  ChapterPagesResult ok() => ChapterPagesResult(
      pageUrls: const ['/p/1', '/p/2'], source: ContentSourceType.localExtension, effectiveSourceName: 'SrcX');
  ChapterPagesResult empty() => ChapterPagesResult(pageUrls: const [], source: ContentSourceType.fallback);

  setUp(() {
    calls = 0;
    NavigationController.debugResetTestOverrides();
    loader = PageLoader(sourceName: 'S', mangaId: 7, chapterTargetId: 1);
    nav = NavigationController(
      isarService: MockIsarService(),
      pageLoader: loader,
      positionManager: MockPositionManager(),
      settings: MockSettingsService(),
    );
  });

  tearDown(() {
    NavigationController.debugResetTestOverrides();
    loader.dispose();
  });

  test('success stores pages under the shared key with the resolved source', () async {
    resolveWith(() async => ok());
    final next = _ch(2);
    await nav.prefetchChapter(next);
    final hit = loader.takePrefetchedChapter(_key(next));
    expect(hit, isNotNull);
    expect(hit!.urls, ['/p/1', '/p/2']);
    expect(hit.sourceName, 'SrcX');
  });

  test('threshold: 65% of the chapter', () {
    expect(kNextChapterPrefetchThreshold, 0.65);
    expect(shouldPrefetchNextChapterAtRatio(0.64), isFalse);
    expect(shouldPrefetchNextChapterAtRatio(0.65), isTrue);
    expect(shouldPrefetchNextChapterAtPage(6, 10), isFalse);
    expect(shouldPrefetchNextChapterAtPage(7, 10), isTrue);
    expect(shouldPrefetchNextChapterAtPage(1, 0), isFalse);
  });

  test('dedupe: concurrent and repeat prefetches resolve once', () async {
    final gate = Completer<ChapterPagesResult>();
    resolveWith(() => gate.future);
    final next = _ch(2);
    final a = nav.prefetchChapter(next);
    final b = nav.prefetchChapter(next);
    await Future<void>.delayed(Duration.zero);
    gate.complete(ok());
    await Future.wait([a, b]);
    await nav.prefetchChapter(next); // already prefetched
    expect(calls, 1);
  });

  test('cooldown: an empty result suppresses retries until the cooldown passes', () async {
    resolveWith(() async => empty());
    final next = _ch(2);
    await nav.prefetchChapter(next);
    await nav.prefetchChapter(next);
    expect(calls, 1);
    NavigationController.prefetchFailureCooldown = Duration.zero;
    await nav.prefetchChapter(next);
    expect(calls, 2);
  });

  test('stale result is discarded when a newer chapter load starts', () async {
    final gate = Completer<ChapterPagesResult>();
    resolveWith(() => gate.future);
    final next = _ch(2);
    final p = nav.prefetchChapter(next);
    await Future<void>.delayed(Duration.zero);
    // Bumps the load generation (the chapter lookup itself fails: no Isar).
    await nav.loadChapterAndPages(99);
    gate.complete(ok());
    await p;
    expect(loader.takePrefetchedChapter(_key(next)), isNull);
    expect(loader.isPrefetching(_key(next)), isFalse);
  });

  test('timeout: a hung resolver ends the prefetch and arms the cooldown', () async {
    NavigationController.prefetchTimeout = const Duration(milliseconds: 50);
    resolveWith(() => Completer<ChapterPagesResult>().future);
    final next = _ch(2);
    await nav.prefetchChapter(next).timeout(const Duration(seconds: 2));
    expect(loader.takePrefetchedChapter(_key(next)), isNull);
    expect(loader.isPrefetching(_key(next)), isFalse);
    await nav.prefetchChapter(next);
    expect(calls, 1);
  });

  test('loadChapterAndPages always ends with loading=false, even on failure', () async {
    final events = <bool>[];
    nav.onLoadingChanged = events.add;
    await nav.loadChapterAndPages(5).timeout(const Duration(seconds: 2));
    expect(events, [true, false]);
  });

  test('failure (resolver throws) arms the cooldown; retry only after it passes', () async {
    resolveWith(() => Future<ChapterPagesResult>.error(StateError('down')));
    final next = _ch(2);
    await nav.prefetchChapter(next);
    expect(loader.isPrefetching(_key(next)), isFalse);
    await nav.prefetchChapter(next);
    expect(calls, 1, reason: 'within cooldown');
    NavigationController.prefetchFailureCooldown = Duration.zero;
    resolveWith(() async => ok());
    await nav.prefetchChapter(next);
    expect(calls, 2);
    expect(loader.takePrefetchedChapter(_key(next))?.urls, ['/p/1', '/p/2']);
  });

  test('dispose mid-prefetch: result is dropped, nothing throws', () async {
    final gate = Completer<ChapterPagesResult>();
    resolveWith(() => gate.future);
    final next = _ch(2);
    final p = nav.prefetchChapter(next);
    await Future<void>.delayed(Duration.zero);
    nav.dispose();
    gate.complete(ok());
    await p;
    expect(loader.isAlive, isFalse);
    expect(loader.takePrefetchedChapter(_key(next)), isNull);
  });

  test('prefetch hit keeps the resolved source type (not hard-coded)', () async {
    resolveWith(() async => ChapterPagesResult(
        pageUrls: const ['/p/1'], source: ContentSourceType.fallback, effectiveSourceName: 'SrcX'));
    final next = _ch(2);
    await nav.prefetchChapter(next);
    expect(loader.takePrefetchedChapter(_key(next))?.sourceType, ContentSourceType.fallback);
  });
}
