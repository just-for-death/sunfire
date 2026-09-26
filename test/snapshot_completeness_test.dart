// Paginated-snapshot completeness contract.
//
// WHY THIS EXISTS
//
// The sync engine's guard philosophy is strong at the NETWORK boundary —
// reachability is tracked separately from authentication, a 401 is never
// treated as a transport drop — and was absent at the COMPLETENESS boundary.
// Every destructive sync operation was driven by "whatever the server returned
// this cycle", and nothing distinguished a complete response from a partial
// one.
//
// A single timed-out page was therefore indistinguishable from a mass deletion.
// Concrete traces:
//
//   * Library: 500 manga, page size 200, page 3 times out. `fetchLibrary`
//     returns the 400 it managed to collect. The caller's 30% ratio guard sees
//     400 >= 150 and concludes the server is healthy, so the 100 missing
//     manga are soft-removed from the user's library. No error is surfaced.
//
//   * Chapters: 600-chapter series, page size 500, page 2 fails. 500 ids are
//     seen, and the prune HARD-DELETES the other 100 rows — taking their
//     isRead, lastPageRead, lastReadAt and bookmarks with them. The ratio
//     guard does not help: 500 clears the floor against 600.
//
// The fix threads a completeness flag from the paginated fetchers to the
// destructive call sites. These tests pin the contract itself.
//
// WHAT IS PINNED HERE
//   1. `isCompleteSnapshot` defaults to FALSE for an unmarked map, so a new
//      paginated fetcher that forgets to stamp the key fails SAFE (keeps local
//      data) rather than open.
//   2. A complete snapshot is recognised.
//   3. A null response is never complete.
//   4. The chapter prune's existing protections still compose with the new
//      completeness gate rather than replacing them.
//
// Run: fvm flutter test test/snapshot_completeness_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('isCompleteSnapshot', () {
    test('recognises a complete snapshot', () {
      expect(
        isCompleteSnapshot({'mangas': {'nodes': []}, kSnapshotCompleteKey: true}),
        isTrue,
      );
    });

    test('rejects a truncated snapshot', () {
      expect(
        isCompleteSnapshot({'mangas': {'nodes': []}, kSnapshotCompleteKey: false}),
        isFalse,
      );
    });

    test('defaults to incomplete for an unmarked map', () {
      // Fail-safe direction. If a new paginated fetcher forgets to stamp the
      // key, the destructive paths must keep local data rather than trust a
      // response that may be half-read.
      expect(isCompleteSnapshot({'mangas': {'nodes': []}}), isFalse);
      expect(isCompleteSnapshot(const {}), isFalse);
    });

    test('a null response is never complete', () {
      expect(isCompleteSnapshot(null), isFalse);
    });

    test('only the literal boolean true counts as complete', () {
      // A truthy string from a JSON-decoded payload must not be read as
      // "complete" — that would defeat the whole guard.
      expect(isCompleteSnapshot({kSnapshotCompleteKey: 'true'}), isFalse);
      expect(isCompleteSnapshot({kSnapshotCompleteKey: 1}), isFalse);
      expect(isCompleteSnapshot({kSnapshotCompleteKey: null}), isFalse);
    });
  });

  group('chapter prune: completeness composes with the existing guards', () {
    // The prune has three independent protections. A truncated snapshot adds a
    // fourth upstream gate; these assert the originals are untouched, because
    // each covers a case the others do not.

    Chapter chapter(int serverId, {bool read = false}) =>
        Chapter()
          ..serverId = serverId
          ..mangaId = 1
          ..isRead = read;

    test('a complete snapshot still prunes genuinely deleted chapters', () {
      // The original bug selectPrunableChapters exists for: chapters removed on
      // the server lingered locally forever. That must stay fixed.
      final local = [for (var i = 1; i <= 10; i++) chapter(i)];
      final seen = <int>{for (var i = 1; i <= 8; i++) i};

      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale.map((c) => c.serverId).toList()..sort(), [9, 10]);
    });

    test('read chapters are still protected independently of completeness', () {
      final local = [chapter(1, read: true), chapter(2), chapter(3), chapter(4)];
      final seen = <int>{3, 4};

      final stale = selectPrunableChapters(localChapters: local, seenServerIds: seen);

      expect(stale.map((c) => c.serverId).toList()..sort(), [2]);
    });

    test('the truncated-response ratio guard is unchanged', () {
      // 5 of 50 is a truncated response, not a mass deletion — this guard is
      // independent of the new completeness flag and must keep working for
      // servers that genuinely return fewer chapters.
      final local = [for (var i = 1; i <= 50; i++) chapter(i)];
      final seen = <int>{1, 2, 3, 4, 5};

      expect(selectPrunableChapters(localChapters: local, seenServerIds: seen), isEmpty);
    });

    test('an empty server set never prunes anything', () {
      final local = [for (var i = 1; i <= 20; i++) chapter(i)];

      expect(
        selectPrunableChapters(localChapters: local, seenServerIds: const <int>{}),
        isEmpty,
      );
    });
  });
}
