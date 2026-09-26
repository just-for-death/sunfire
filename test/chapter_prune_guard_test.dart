// Tests for the chapter-prune wipe guard.
//
// Nothing in the codebase ever deleted a chapter before this, so a chapter
// removed on the server lingered locally forever: chapterCount is overwritten
// from the server so the count and the row set diverged, the chapter reappeared
// in the offline chapter list, it stayed in History forever (getReadingHistory
// filters only on library membership), and Isar grew without bound.
//
// The risk is the mirror image: a truncated or partially-answered
// fetchMangaDetails response looks EXACTLY like "the server deleted most of
// this series". So the guard's refusal behaviour is what actually matters.
//
// Run: fvm flutter test test/chapter_prune_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

Chapter _ch(int serverId, {bool downloaded = false, bool bookmarked = false}) =>
    Chapter()
      ..serverId = serverId
      ..mangaId = 1
      ..isDownloadedLocally = downloaded
      ..isBookmarked = bookmarked;

List<Chapter> _series(int count) => [for (var i = 1; i <= count; i++) _ch(i)];

void main() {
  group('selectPrunableChapters — happy path', () {
    test('removes only the chapters the server no longer reports', () {
      final local = _series(10);
      // Server still has 1..8; 9 and 10 were deleted upstream.
      final seen = <int>{for (var i = 1; i <= 8; i++) i};

      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale.map((c) => c.serverId).toList()..sort(), [9, 10]);
    });

    test('a full match prunes nothing', () {
      final local = _series(10);
      final stale = selectPrunableChapters(
        localChapters: local,
        seenServerIds: {for (var i = 1; i <= 10; i++) i},
      );
      expect(stale, isEmpty);
    });

    test('a shrinking-but-plausible series is still pruned', () {
      // 100 -> 40 is a real, large deletion and passes the 0.3 floor.
      final local = _series(100);
      final seen = <int>{for (var i = 1; i <= 40; i++) i};

      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale, hasLength(60));
    });
  });

  group('selectPrunableChapters — WIPE GUARD (must refuse)', () {
    test('an empty server response prunes nothing', () {
      // The worst case: an auth error or a dead source that returns an empty
      // chapter list. Treating this as "the series has zero chapters" would
      // wipe the user's entire offline history for it.
      final stale = selectPrunableChapters(
        localChapters: _series(50),
        seenServerIds: const <int>{},
      );
      expect(stale, isEmpty);
    });

    test('a truncated response prunes nothing', () {
      // Server returned 5 of the 50 we hold — far below the 0.3 floor.
      final local = _series(50);
      final seen = <int>{1, 2, 3, 4, 5};

      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale, isEmpty, reason: '5/50 is a truncated response, not a mass deletion');
    });

    test('a response just under the ratio floor prunes nothing', () {
      final local = _series(100);
      // 29/100 — just below 0.3.
      final seen = <int>{for (var i = 1; i <= 29; i++) i};
      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);
      expect(stale, isEmpty);
    });

    test('a response exactly at the ratio floor is allowed through', () {
      final local = _series(100);
      final seen = <int>{for (var i = 1; i <= 30; i++) i};
      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);
      expect(stale, hasLength(70));
    });

    test('a single local chapter is never wiped by an empty response', () {
      final stale = selectPrunableChapters(
        localChapters: [_ch(1)],
        seenServerIds: const <int>{},
      );
      expect(stale, isEmpty);
    });
  });

  group('selectPrunableChapters — protected chapters', () {
    test('a downloaded chapter is never pruned', () {
      final local = [
        ..._series(10),
        // Already covered above; make the deleted one downloaded instead.
      ];
      final seen = <int>{for (var i = 1; i <= 8; i++) i};
      final withDownloaded = [...local];
      // Replace #9 with a downloaded variant.
      withDownloaded[8] = _ch(9, downloaded: true);

      final stale = selectPrunableChapters(localChapters: withDownloaded, seenServerIds: seen);

      expect(stale.map((c) => c.serverId), isNot(contains(9)));
      expect(stale.map((c) => c.serverId), contains(10));
    });

    test('a bookmarked chapter is never pruned', () {
      final local = _series(10);
      local[8] = _ch(9, bookmarked: true);
      local[9] = _ch(10, bookmarked: true);

      final seen = <int>{for (var i = 1; i <= 8; i++) i};
      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale, isEmpty, reason: 'both missing chapters are bookmarked');
    });

    test('downloaded and bookmarked chapters can make the prune a no-op', () {
      final local = _series(10);
      for (var i = 9; i <= 10; i++) {
        local[i - 1] = _ch(i, downloaded: true, bookmarked: true);
      }
      final seen = <int>{for (var i = 1; i <= 8; i++) i};
      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);
      expect(stale, isEmpty);
    });
  });

  group('selectPrunableChapters — local-only chapters', () {
    test('a local-scrape chapter (negative synthetic id) is never pruned', () {
      // Local-JS chapters get a negative synthetic serverId and exist only on
      // this device — the server will never report them, so a naive "missing
      // from the server => delete" rule would destroy every scraped chapter.
      final local = [
        _ch(1),
        _ch(2),
        _ch(3),
        Chapter()
          ..serverId = -100001
          ..mangaId = 1,
        Chapter()
          ..serverId = -100002
          ..mangaId = 1,
      ];

      final stale = selectPrunableChapters(
        localChapters: local,
        seenServerIds: const {1, 2, 3},
      );

      expect(stale, isEmpty);
    });

    test('local-scrape chapters do not dilute the wipe guard', () {
      // 3 real server chapters + 97 local ones. The guard must compare against
      // real server chapters only, otherwise 100/100 would look like a full
      // match and a truncated 1-chapter response would pass the ratio.
      final local = <Chapter>[
        _ch(1),
        for (var i = 0; i < 97; i++)
          Chapter()
            ..serverId = -(100000 + i)
            ..mangaId = 1,
      ];

      final stale = selectPrunableChapters(
        localChapters: local,
        seenServerIds: const {1},
      );

      expect(stale, isEmpty, reason: '1 real chapter seen vs 1 held is not a truncation');
    });

    test('a legitimate deletion prunes server chapters but keeps local ones', () {
      final local = <Chapter>[
        _ch(1),
        _ch(2),
        _ch(3),
        _ch(4),
        Chapter()
          ..serverId = -100001
          ..mangaId = 1,
      ];

      // Server now reports 3 of 4 -> 0.75 ratio, passes the guard.
      final stale = selectPrunableChapters(
        localChapters: local,
        seenServerIds: const {1, 2, 3},
      );

      expect(stale.map((c) => c.serverId), [4]);
    });
  });
}
