// UIX-12: one source-free prefetch key for the reader's write and read sides.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/reader_prefetch.dart';

void main() {
  test('key is source-free: writer (manga.sourceName null) == reader (auto-detected MangaX)', () {
    // Writer side never sees the source in the key; reader side neither.
    final writer = readerPrefetchKey(chapterTargetId: 42, mangaId: 7);
    final reader = readerPrefetchKey(chapterTargetId: 42, mangaId: 7);
    expect(writer, reader);
    expect(writer, '42|7');
  });

  test('different chapters / manga rows never share a key (incl. negative local ids)', () {
    expect(readerPrefetchKey(chapterTargetId: -5, mangaId: 1), isNot(readerPrefetchKey(chapterTargetId: -5, mangaId: 2)));
    expect(readerPrefetchKey(chapterTargetId: -5, mangaId: 1), isNot(readerPrefetchKey(chapterTargetId: 5, mangaId: 1)));
  });

  test('value-side source check: known mismatch is discarded', () {
    expect(prefetchSourceMatches(prefetchedSource: 'A', currentSource: 'B'), isFalse);
    expect(prefetchSourceMatches(prefetchedSource: 'A', currentSource: 'A'), isTrue);
  });

  test('value-side source check: one known, one unknown keeps the entry', () {
    expect(prefetchSourceMatches(prefetchedSource: 'unknown', currentSource: 'MangaX'), isTrue);
    expect(prefetchSourceMatches(prefetchedSource: 'MangaX', currentSource: null), isTrue);
    expect(prefetchSourceMatches(prefetchedSource: 'MangaX', currentSource: ''), isTrue);
  });

  test('value-side source check: both unknown DENIES the entry', () {
    expect(prefetchSourceMatches(prefetchedSource: 'unknown', currentSource: 'unknown'), isFalse);
    expect(prefetchSourceMatches(prefetchedSource: null, currentSource: ''), isFalse);
    expect(prefetchSourceMatches(prefetchedSource: '', currentSource: 'unknown'), isFalse);
  });
}