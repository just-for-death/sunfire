// UIX-12: one source-free prefetch key for the reader's write and read sides.
import 'dart:io';

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

  test('value-side source check: unknown on either side keeps the entry', () {
    expect(prefetchSourceMatches(prefetchedSource: 'unknown', currentSource: 'MangaX'), isTrue);
    expect(prefetchSourceMatches(prefetchedSource: 'MangaX', currentSource: null), isTrue);
    expect(prefetchSourceMatches(prefetchedSource: 'MangaX', currentSource: ''), isTrue);
  });

  test('reader_screen uses the shared key helper on both sides', () {
    final src = File('lib/src/features/reader/reader_screen.dart').readAsStringSync();
    expect(src.contains('_prefetchKeyFor(chapter, '), isFalse);
    expect(src.contains('_prefetchKeyFor(chForKey, '), isFalse);
    expect(src.contains('readerPrefetchKey('), isTrue);
    expect(src.contains('prefetchSourceMatches('), isTrue);
  });
}
