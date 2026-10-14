// IMP-008 byte-bounded page cache + IMP-010 memory-pressure trim.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';

Uint8List _bytes(int n) => Uint8List(n);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  PageLoader newLoader(int maxBytes) =>
      PageLoader(sourceName: '', mangaId: 0, chapterTargetId: 0, maxMemoryBytes: maxBytes);

  test('default budget is 50 MB and is the enforced bound', () {
    expect(PageLoader.defaultMaxMemoryBytes, 50 * 1024 * 1024);
    final l = PageLoader(sourceName: '', mangaId: 0, chapterTargetId: 0);
    expect(l.maxMemoryBytes, PageLoader.defaultMaxMemoryBytes);
    l.dispose();
  });

  test('evicts least-recently-used pages once total bytes exceed the budget', () {
    final l = newLoader(1000);
    l.cacheBytes('a', _bytes(400));
    l.cacheBytes('b', _bytes(400));
    expect(l.peekCachedBytes('a'), isNotNull); // touch a: b is now oldest
    l.cacheBytes('c', _bytes(400));
    expect(l.cachedBytes, 800);
    expect(l.peekCachedBytes('b'), isNull);
    expect(l.peekCachedBytes('a'), isNotNull);
    expect(l.peekCachedBytes('c'), isNotNull);
    l.dispose();
  });

  test('a single oversized page is still kept (newest wins)', () {
    final l = newLoader(100);
    l.cacheBytes('a', _bytes(50));
    l.cacheBytes('big', _bytes(500));
    expect(l.peekCachedBytes('big'), isNotNull);
    expect(l.peekCachedBytes('a'), isNull);
    expect(l.cachedBytes, 500);
    l.dispose();
  });

  test('replacing and removing keep the byte total exact', () {
    final l = newLoader(10000);
    l.cacheBytes('a', _bytes(300));
    l.cacheBytes('a', _bytes(100));
    expect(l.cachedBytes, 100);
    l.cacheBytes('b', _bytes(200));
    l.resetDisplayState();
    expect(l.metrics.cachedBytes, l.cachedBytes);
    l.dispose();
  });

  test('handleMemoryPressure keeps only the newest quarter of the budget', () {
    final l = newLoader(1000);
    for (final k in ['a', 'b', 'c', 'd']) {
      l.cacheBytes(k, _bytes(200));
    }
    final freed = l.handleMemoryPressure();
    expect(freed, 600);
    expect(l.cachedBytes, 200);
    expect(l.peekCachedBytes('d'), isNotNull);
    expect(l.trimCacheTo(0), 200);
    expect(l.cachedBytes, 0);
    l.dispose();
  });

  group('current-chapter pinning', () {
    test('long chapter + next-chapter prefetch over budget keeps every current page', () {
      final l = newLoader(10000); // budget: 10 000 bytes
      final current = [for (var i = 0; i < 40; i++) 'cur/$i']; // 40 x 200 = 8 000
      l.setCurrentChapterPages(current);
      for (final u in current) {
        l.cacheBytes(u, _bytes(200));
      }
      // Next-chapter prefetch: 30 x 200 = 6 000 more, well over budget.
      for (var i = 0; i < 30; i++) {
        l.cacheBytes('next/$i', _bytes(200));
      }
      for (final u in current) {
        expect(l.peekCachedBytes(u), isNotNull, reason: '$u must survive prefetch');
      }
      expect(l.cachedBytes, lessThanOrEqualTo(10000));
      // Prefetched pages fill only the leftover budget (newest kept).
      expect(l.peekCachedBytes('next/29'), isNotNull);
      expect(l.peekCachedBytes('next/0'), isNull);
      l.dispose();
    });

    test('prefetch never evicts pinned pages even when pinned alone fill the budget', () {
      final l = newLoader(1000);
      l.setCurrentChapterPages(['a', 'b']);
      l.cacheBytes('a', _bytes(500));
      l.cacheBytes('b', _bytes(500));
      l.cacheBytes('n', _bytes(100)); // unpinned, no room
      expect(l.peekCachedBytes('a'), isNotNull);
      expect(l.peekCachedBytes('b'), isNotNull);
      expect(l.peekCachedBytes('n'), isNull);
      l.dispose();
    });

    test('memory pressure drops prefetched pages before current ones', () {
      final l = newLoader(1000);
      l.setCurrentChapterPages(['c']);
      l.cacheBytes('c', _bytes(200));
      l.cacheBytes('p1', _bytes(200));
      l.cacheBytes('p2', _bytes(200));
      l.handleMemoryPressure(); // target 250
      expect(l.peekCachedBytes('c'), isNotNull);
      expect(l.cachedBytes, 200);
      l.dispose();
    });

    test('changing chapter re-pins: old chapter pages become evictable', () {
      final l = newLoader(600);
      l.setCurrentChapterPages(['old1', 'old2']);
      l.cacheBytes('old1', _bytes(200));
      l.cacheBytes('old2', _bytes(200));
      l.setCurrentChapterPages(['new1', 'new2']);
      expect(l.isPinnedPage('old1'), isFalse);
      l.cacheBytes('new1', _bytes(200));
      l.cacheBytes('new2', _bytes(200));
      expect(l.peekCachedBytes('new1'), isNotNull);
      expect(l.peekCachedBytes('new2'), isNotNull);
      expect(l.peekCachedBytes('old1'), isNull);
      l.dispose();
    });
  });
}
