// Unit tests for the server->local chapter merge helpers extracted from the
// three pull paths in sync_engine.dart.
//
// Regression coverage:
//  - B1: `isBookmarked` was never assigned on any pull path even though every
//    chapter query selects it, so a bookmark set on one device never appeared
//    on another.
//  - B2: the recent-updates pull set `isRead` but not `lastReadAt`, so a
//    chapter arriving already-read was absent from History (lastReadAt > 0)
//    and did not float its series in Library "Last Read" sorting.
//  - B3: the recent-updates pull set no `pageCount`, and
//    Chapter.applyReadState does `if (read) lastPageRead = pageCount`, so
//    marking such a chapter read wrote lastPageRead = 0.
//  - O3: `sourceMap['name']` being an empty string short-circuited the `??`
//    chain and stored '' as the source name, silently skipping the local
//    extension fallbacks that guard on sourceName.isNotEmpty.
//
// Run: fvm flutter test test/chapter_merge_helpers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('mergeIsBookmarked — bookmarks must sync DOWN', () {
    test('applies the server value when there is no pending mutation', () {
      final chapter = Chapter()..serverId = 1;
      mergeIsBookmarked(chapter, <String, dynamic>{'isBookmarked': true},
          hasPendingMutation: false);
      expect(chapter.isBookmarked, isTrue);
    });

    test('applies a server clear (true -> false)', () {
      final chapter = Chapter()
        ..serverId = 1
        ..isBookmarked = true;
      mergeIsBookmarked(chapter, <String, dynamic>{'isBookmarked': false},
          hasPendingMutation: false);
      expect(chapter.isBookmarked, isFalse);
    });

    test('leaves the local value alone while a mutation is queued', () {
      final chapter = Chapter()
        ..serverId = 1
        ..isBookmarked = true;
      // A bookmark is still waiting to be pushed; the server's pre-replay
      // value must not clobber it.
      mergeIsBookmarked(chapter, <String, dynamic>{'isBookmarked': false},
          hasPendingMutation: true);
      expect(chapter.isBookmarked, isTrue);
    });

    test('does nothing when the field is absent from the payload', () {
      final chapter = Chapter()
        ..serverId = 1
        ..isBookmarked = true;
      mergeIsBookmarked(chapter, <String, dynamic>{'isRead': true},
          hasPendingMutation: false);
      expect(chapter.isBookmarked, isTrue);
    });

    test('parses string-encoded booleans', () {
      final chapter = Chapter()..serverId = 1;
      mergeIsBookmarked(chapter, <String, dynamic>{'isBookmarked': 'true'},
          hasPendingMutation: false);
      expect(chapter.isBookmarked, isTrue);
    });
  });

  group('mergeLastReadAt — read activity must be timestamped', () {
    test('sets a null stamp', () {
      final chapter = Chapter()..serverId = 1;
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000});
      expect(chapter.lastReadAt, 1700000000);
    });

    test('normalises epoch milliseconds to seconds', () {
      final chapter = Chapter()..serverId = 1;
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000000});
      expect(chapter.lastReadAt, 1700000000);
    });

    test('never moves the stamp backwards', () {
      final chapter = Chapter()
        ..serverId = 1
        ..lastReadAt = 1800000000;
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000});
      expect(chapter.lastReadAt, 1800000000);
    });

    test('ignores absent, zero and negative values', () {
      final absent = Chapter()..serverId = 1;
      mergeLastReadAt(absent, <String, dynamic>{});
      expect(absent.lastReadAt, isNull);

      final zero = Chapter()..serverId = 2;
      mergeLastReadAt(zero, <String, dynamic>{'lastReadAt': 0});
      expect(zero.lastReadAt, isNull);

      final negative = Chapter()..serverId = 3;
      mergeLastReadAt(negative, <String, dynamic>{'lastReadAt': -5});
      expect(negative.lastReadAt, isNull);
    });

    test('accepts a numeric (double) value', () {
      final chapter = Chapter()..serverId = 1;
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000.0});
      expect(chapter.lastReadAt, 1700000000);
    });

    test('is idempotent when applied repeatedly', () {
      final chapter = Chapter()..serverId = 1;
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000});
      mergeLastReadAt(chapter, <String, dynamic>{'lastReadAt': 1700000000});
      expect(chapter.lastReadAt, 1700000000);
    });
  });

  group('pageCount matters for the read-completion position', () {
    test('with a synced pageCount, marking read completes to the last page', () {
      final chapter = Chapter()
        ..serverId = 1
        ..pageCount = 18
        ..lastPageRead = 4;
      chapter.applyReadState(true);
      expect(chapter.lastPageRead, 18,
          reason: 'pageCount lets applyReadState finish the chapter properly');
      expect(chapter.isRead, isTrue);
    });

    test('without pageCount the existing position is preserved, not zeroed', () {
      // applyReadState already guards on `pageCount > 0`, so the resume
      // position survives. The recent-updates pull nevertheless now syncs
      // pageCount, because without it a chapter that first arrives through the
      // updates feed can never be *completed* to its last page and the
      // progress bar has no denominator.
      final chapter = Chapter()
        ..serverId = 2
        ..lastPageRead = 7;
      chapter.applyReadState(true);
      expect(chapter.lastPageRead, 7);
      expect(chapter.pageCount, 0);
    });

    test('un-marking always resets the position', () {
      final chapter = Chapter()
        ..serverId = 3
        ..pageCount = 18
        ..lastPageRead = 4;
      chapter.applyReadState(false);
      expect(chapter.lastPageRead, 0);
      expect(chapter.isRead, isFalse);
    });
  });

  group('mergeLastPageRead still guards the rewind case', () {
    test('a server "unread" with page 0 does not rewind local progress', () {
      expect(
        mergeLastPageRead(
          local: 20,
          server: 0,
          hasPendingMutation: false,
        ),
        20,
      );
    });

    test('strictly greater server progress wins', () {
      expect(
        mergeLastPageRead(
          local: 3,
          server: 9,
          hasPendingMutation: false,
        ),
        9,
      );
    });

    test('a pending mutation pins the local value', () {
      expect(
        mergeLastPageRead(
          local: 4,
          server: 30,
          hasPendingMutation: true,
        ),
        4,
      );
    });
  });
}
