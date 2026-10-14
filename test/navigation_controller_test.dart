// v6 Step 9: NavigationController unit tests (no Isar / network).
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/reader_prefetch.dart';

import 'reader_controller_test.mocks.dart';

Chapter _ch(int serverId, {int mangaId = 7}) => Chapter()
  ..serverId = serverId
  ..mangaId = mangaId
  ..name = 'Ch $serverId'
  ..url = 'https://src.invalid/c/$serverId';

void main() {
  late PageLoader loader;
  late NavigationController nav;

  setUp(() {
    loader = PageLoader(sourceName: 'S', mangaId: 7, chapterTargetId: 1);
    nav = NavigationController(
      isarService: MockIsarService(),
      pageLoader: loader,
      positionManager: MockPositionManager(),
      settings: MockSettingsService(),
    );
  });

  tearDown(() => loader.dispose());

  test('owner-synced state is exposed through getters', () {
    final a = _ch(1), b = _ch(2), c = _ch(3);
    nav
      ..setChapter(b)
      ..setSiblingChapters([a, b, c])
      ..setNextChapter(c)
      ..setPrevChapter(a)
      ..setPageUrls(['p1', 'p2'])
      ..setCurrentPage(2)
      ..setCurrentChapterId(2);
    expect(nav.chapter, same(b));
    expect(nav.siblingChapters, hasLength(3));
    expect(nav.nextChapter, same(c));
    expect(nav.prevChapter, same(a));
    expect(nav.pageUrls, ['p1', 'p2']);
    expect(nav.currentPage, 2);
    expect(nav.currentChapterId, 2);
    expect(nav.sourceName, isNull, reason: 'set only by a real load');
  });

  test('prefetchChapter is a no-op when the chapter is already prefetched (shared key)', () async {
    final next = _ch(9);
    final key = readerPrefetchKey(chapterTargetId: 9, mangaId: 7);
    loader.setPrefetchedChapter(key, 'S', ['u1']);
    await nav.prefetchChapter(next); // would hit Isar/resolver otherwise
    expect(loader.takePrefetchedChapter(key)?.urls, ['u1']);
  });

  test('prefetchChapter is a no-op while the same chapter is in flight', () async {
    final key = readerPrefetchKey(chapterTargetId: 9, mangaId: 7);
    loader.markPrefetching(key);
    await nav.prefetchChapter(_ch(9));
    expect(loader.isPrefetching(key), isTrue, reason: 'in-flight marker untouched');
  });

  test('prefetchChapter honours the failure cooldown', () async {
    final key = readerPrefetchKey(chapterTargetId: 9, mangaId: 7);
    loader.setPrefetchAttemptTime(key, DateTime.now().millisecondsSinceEpoch ~/ 1000);
    await nav.prefetchChapter(_ch(9));
    expect(loader.isPrefetched(key), isFalse);
    expect(loader.isPrefetching(key), isFalse);
  });

  test('local chapters (negative serverId) key by serverId, not local id', () {
    final local = _ch(-5001)..id = 42;
    expect(readerPrefetchKey(chapterTargetId: local.serverId, mangaId: 7), '-5001|7');
  });
}
