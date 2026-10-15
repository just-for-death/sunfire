// IMP-024 guard: library-update new-chapter detection.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/library_update_service.dart';

Chapter _ch(int serverId, int mangaId, {bool read = false, String title = ''}) => Chapter()
  ..serverId = serverId
  ..mangaId = mangaId
  ..name = 'c$serverId'
  ..chapterNumber = serverId.toDouble()
  ..isRead = read
  ..mangaTitle = title;

void main() {
  test('a manga that joins the library mid-update reports none of its chapters as new', () {
    final before = [_ch(1, 10)];
    final after = [
      _ch(1, 10),
      _ch(2, 10), // genuinely new, manga 10 was in the library
      _ch(50, 99), // manga 99 joined mid-update: existing chapter
      _ch(51, 99),
    ];
    final got = detectNewLibraryChapters(
      beforeChapters: before,
      afterChapters: after,
      beforeLibraryIds: {10},
      libraryMangaIds: {10, 99},
    );
    expect(got.map((c) => c.serverId), [2]);
  });

  test('known chapters, read chapters and non-library manga are skipped; titles filled', () {
    final got = detectNewLibraryChapters(
      beforeChapters: [_ch(1, 10)],
      afterChapters: [_ch(1, 10), _ch(3, 10, read: true), _ch(4, 10), _ch(5, 20)],
      beforeLibraryIds: {10, 20},
      libraryMangaIds: {10},
      mangaTitleMap: {10: 'Series Ten'},
    );
    expect(got.map((c) => c.serverId), [4]);
    expect(got.single.mangaTitle, 'Series Ten');
  });

  test('orphan chapters (mangaId 0) are still diffed as before', () {
    final got = detectNewLibraryChapters(
      beforeChapters: [_ch(7, 0)],
      afterChapters: [_ch(7, 0), _ch(8, 0)],
      beforeLibraryIds: const {},
      libraryMangaIds: const {},
    );
    expect(got.map((c) => c.serverId), [8]);
  });

  test('a series fetched for the first time reports no chapters', () {
    final got = detectNewLibraryChapters(
      beforeChapters: [_ch(1, 10)],
      afterChapters: [_ch(1, 10), _ch(60, 30), _ch(61, 30)],
      beforeLibraryIds: {10, 30},
      libraryMangaIds: {10, 30},
    );
    expect(got, isEmpty);
  });

  test('local series (negative ids) are filtered and diffed like server ones', () {
    final got = detectNewLibraryChapters(
      beforeChapters: [_ch(-1, -10), _ch(-5, -20)],
      afterChapters: [_ch(-1, -10), _ch(-2, -10), _ch(-6, -20)],
      beforeLibraryIds: {-10},
      libraryMangaIds: {-10},
    );
    expect(got.map((c) => c.serverId), [-2]);
  });

  group('updateIntervalElapsed', () {
    const h = 3600;
    test('a run slightly before the interval still counts', () {
      expect(updateIntervalElapsed(nowSec: 12 * h - 600, lastSec: 0, freqHours: 12), isTrue);
    });
    test('a run well before the interval is skipped', () {
      expect(updateIntervalElapsed(nowSec: 6 * h, lastSec: 0, freqHours: 12), isFalse);
    });
    test('slack is a quarter of short intervals', () {
      expect(updateIntervalElapsed(nowSec: 50 * 60, lastSec: 0, freqHours: 1), isTrue);
      expect(updateIntervalElapsed(nowSec: 40 * 60, lastSec: 0, freqHours: 1), isFalse);
    });
  });
}
