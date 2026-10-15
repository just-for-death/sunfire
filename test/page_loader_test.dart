// v6 Step 9: PageLoader unit tests (no network).
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';

void main() {
  late PageLoader l;
  setUp(() => l = PageLoader(sourceName: 'S', mangaId: 1, chapterTargetId: 2));
  tearDown(() => l.dispose());

  test('cacheBytes / peekCachedBytes round trip', () {
    final b = Uint8List.fromList([1, 2, 3]);
    expect(l.peekCachedBytes('u'), isNull);
    l.cacheBytes('u', b);
    expect(l.peekCachedBytes('u'), b);
  });

  test('prefetch store: consume once, evict oldest, count', () {
    l.setPrefetchedChapter('a', 'S', ['1']);
    l.setPrefetchedChapter('b', 'S', ['2']);
    expect(l.getPrefetchCount(), 2);
    l.evictOldestPrefetch();
    expect(l.isPrefetched('a'), isFalse);
    expect(l.isPrefetched('b'), isTrue);
    expect(l.takePrefetchedChapter('b')?.urls, ['2']);
    expect(l.takePrefetchedChapter('b'), isNull);
  });

  test('in-flight markers and attempt times', () {
    l.markPrefetching('k');
    expect(l.isPrefetching('k'), isTrue);
    l.unmarkPrefetching('k');
    expect(l.isPrefetching('k'), isFalse);
    l.setPrefetchAttemptTime('k', 100);
    expect(l.getPrefetchAttemptTime('k'), 100);
    l.clearPrefetchAttemptTime('k');
    expect(l.getPrefetchAttemptTime('k'), isNull);
  });

  test('failed URLs short-circuit loads; clearing re-enables them', () async {
    const url = 'https://img.invalid/x.jpg';
    l.markUrlFailed(url);
    final r = await l.loadPage(url: url, index: 0, priority: PageLoadPriority.current);
    expect(r.bytes, isNull);
    l.clearFailedUrl(url);
    expect(l.isUrlFailed(url), isFalse);
  });

  test('setSourceName updates header source; disposed loader is not alive', () {
    l.setSourceName('T');
    expect(l.sourceName, 'T');
    expect(l.isAlive, isTrue);
    l.dispose();
    expect(l.isAlive, isFalse);
  });

  group('display state (ISS-125: single byte cache, moved from the screen)', () {
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(300, 0)]);
    late List<String> fetched;
    late Completer<void>? gate;
    late bool fail;
    late PageLoader d;
    late int notified;

    setUp(() {
      fetched = [];
      gate = null;
      fail = false;
      notified = 0;
      d = PageLoader(
        sourceName: 'S',
        mangaId: 1,
        chapterTargetId: 2,
        fetchOverride: (url) async {
          fetched.add(url);
          if (gate != null) await gate!.future;
          return fail ? PageLoadResult(error: 'x') : PageLoadResult(bytes: png);
        },
      )..onDisplayChanged = () => notified++;
    });
    tearDown(() => d.dispose());

    test('recoverPage stores bytes in the LRU only and notifies', () async {
      await d.recoverPage('https://i/1', 0);
      expect(d.hasDisplayBytes('https://i/1'), isTrue);
      expect(d.recoveringUrls, isEmpty);
      expect(notified, greaterThan(0));
      await d.recoverPage('https://i/1', 0);
      expect(fetched, ['https://i/1'], reason: 'cached: no refetch');
    });

    test('failure -> Retry state; auto retry suppressed; manual retry refetches', () async {
      fail = true;
      await d.recoverPage('https://i/1', 0);
      expect(d.displayFailedUrls, contains('https://i/1'));
      await d.recoverPage('https://i/1', 0);
      expect(fetched, hasLength(1));
      fail = false;
      await d.recoverPage('https://i/1', 0, manual: true);
      expect(fetched, hasLength(2));
      expect(d.hasDisplayBytes('https://i/1'), isTrue);
      expect(d.displayFailedUrls, isEmpty);
    });

    test('result of a superseded chapter is discarded', () async {
      gate = Completer<void>();
      final f = d.recoverPage('https://i/1', 0);
      await Future<void>.delayed(Duration.zero);
      d.resetDisplayState();
      gate!.complete();
      await f;
      expect(d.displayFailedUrls, isEmpty, reason: 'old chapter cannot mark failures');
    });

    test('prefetchUpcoming: next 4 remote pages only, skipping cached/failed/local', () async {
      d.cacheBytes('https://i/2', png);
      d.displayFailedUrls.add('https://i/3');
      d.prefetchUpcoming(['https://i/0', 'https://i/1', 'https://i/2', 'https://i/3', '/local/4', 'https://i/5', 'https://i/6'], 0);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fetched, ['https://i/1']);
    });

    test('warmAround skips local files', () async {
      d.warmAround(['/local/0', 'https://i/1'], 1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fetched, ['https://i/1']);
    });

    test('dispose clears display state and stops notifications', () async {
      gate = Completer<void>();
      final f = d.recoverPage('https://i/1', 0);
      await Future<void>.delayed(Duration.zero);
      d.dispose();
      final before = notified;
      gate!.complete();
      await f;
      expect(d.recoveringUrls, isEmpty);
      expect(notified, before);
    });
  });

  test('ISS-129: cancelAll keeps the active-load counter exact while loads run', () async {
    final gate = Completer<void>();
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, ...List.filled(20, 0)]);
    final c = PageLoader(
      sourceName: 'S',
      mangaId: 1,
      chapterTargetId: 2,
      fetchOverride: (_) async {
        await gate.future;
        return PageLoadResult(bytes: png);
      },
    );
    addTearDown(c.dispose);
    final a = c.loadPage(url: 'https://i/a', index: 0);
    final b = c.loadPage(url: 'https://i/b', index: 1);
    await Future<void>.delayed(Duration.zero);
    expect(c.debugActiveLoads, 2);
    c.cancelAll();
    expect((await a).error, 'Cancelled');
    expect((await b).error, 'Cancelled');
    expect(c.debugActiveLoads, 2, reason: 'loads are still running');
    gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.debugActiveLoads, 0, reason: 'never negative');
    final r = await c.loadPage(url: 'https://i/c', index: 2);
    expect(r.isSuccess, isTrue);
    expect(c.debugActiveLoads, 0);
  });

  test('chapter switch drops queued old-chapter loads and forgets failed URLs', () async {
    final gate = Completer<void>();
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0]);
    final c = PageLoader(
      sourceName: 'S',
      mangaId: 1,
      chapterTargetId: 2,
      maxConcurrentLoads: 1,
      fetchOverride: (_) async {
        await gate.future;
        return PageLoadResult(bytes: png);
      },
    );
    addTearDown(c.dispose);
    c.markUrlFailed('https://i/bad');
    final running = c.loadPage(url: 'https://i/old1', index: 0);
    final queued = c.loadPage(url: 'https://i/old2', index: 1);
    await Future<void>.delayed(Duration.zero);

    c.resetDisplayState();
    expect((await queued).error, 'Cancelled');
    expect(c.isUrlFailed('https://i/bad'), isFalse);
    gate.complete();
    expect((await running).isSuccess, isTrue, reason: 'in-flight load still fills the cache');
  });
}
