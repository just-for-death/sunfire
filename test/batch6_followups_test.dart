import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/list_chunks.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('mergeLastPageRead', () {
    int merge({
      required int local,
      required int server,
      bool localWasRead = false,
      bool serverIsRead = false,
      bool pending = false,
    }) =>
        mergeLastPageRead(
          local: local,
          server: server,
          hasPendingMutation: pending,
        );

    test('in-progress chapter keeps the highest page (never rewinds)', () {
      expect(merge(local: 12, server: 5), 12);
      expect(merge(local: 5, server: 12), 12);
    });

    test('chapter marked unread elsewhere does NOT rewind local progress', () {
      // Server says unread (page 0 or 4), but local has more progress (30)
      // Should NOT rewind to server's lower page
      expect(merge(local: 30, server: 0, localWasRead: true, serverIsRead: false), 30);
      expect(merge(local: 30, server: 4, localWasRead: true, serverIsRead: false), 30);
    });

    test('unread-elsewhere rule does not apply while a local mutation is queued', () {
      expect(merge(local: 30, server: 0, localWasRead: true, serverIsRead: false, pending: true), 30);
    });

    test('pending local mutation always keeps the local page', () {
      expect(merge(local: 3, server: 50, pending: true), 3);
    });

    test('read on both sides keeps the highest page', () {
      expect(merge(local: 20, server: 18, localWasRead: true, serverIsRead: true), 20);
      expect(merge(local: 18, server: 20, localWasRead: true, serverIsRead: true), 20);
    });

    test('chapter that was unread locally and is unread on the server keeps highest', () {
      expect(merge(local: 9, server: 2), 9);
    });
  });

  group('chunkList', () {
    test('splits into ordered chunks of at most size', () {
      expect(chunkList([1, 2, 3, 4, 5], 2), [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('exact multiple and single-chunk cases', () {
      expect(chunkList([1, 2, 3, 4], 2), [
        [1, 2],
        [3, 4],
      ]);
      expect(chunkList([1, 2, 3], 10), [
        [1, 2, 3],
      ]);
    });

    test('empty list yields no chunks', () {
      expect(chunkList(<int>[], 3), isEmpty);
    });

    test('rejects a non-positive size', () {
      expect(() => chunkList([1], 0), throwsArgumentError);
      expect(() => chunkList([1], -1), throwsArgumentError);
    });

    test('concatenating the chunks restores the input', () {
      final input = List<int>.generate(1234, (i) => i);
      final chunks = chunkList(input, 200);
      expect(chunks.length, 7);
      expect(chunks.every((c) => c.length <= 200), isTrue);
      expect(chunks.expand((c) => c).toList(), input);
    });
  });
}
