import 'package:catalyst/src/features/manga_book/presentation/reader/utils/reader_page_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const remote = ['r1', 'r2', 'r3', 'r4', 'r5'];

  group('mergeLocalAndRemotePages', () {
    test('nothing downloaded falls back to the server pages', () {
      expect(mergeLocalAndRemotePages(null, remote), remote);
    });

    test('a fully downloaded chapter reads entirely from disk', () {
      final local = ['l1', 'l2', 'l3', 'l4', 'l5'];

      expect(mergeLocalAndRemotePages(local, remote), local);
    });

    test('a missing page keeps every later page on its own index', () {
      // Page 3 failed to download. It must be filled from the server at the
      // same index — dropping it would shift pages 4 and 5 down one.
      final local = ['l1', 'l2', null, 'l4', 'l5'];

      expect(
        mergeLocalAndRemotePages(local, remote),
        ['l1', 'l2', 'r3', 'l4', 'l5'],
      );
    });

    test('several missing pages are each filled in place', () {
      final local = [null, 'l2', null, null, 'l5'];

      expect(
        mergeLocalAndRemotePages(local, remote),
        ['r1', 'l2', 'r3', 'r4', 'l5'],
      );
    });

    test('page count is unchanged by missing files', () {
      final local = ['l1', null, null, null, 'l5'];

      expect(mergeLocalAndRemotePages(local, remote).length, remote.length);
    });

    test('extra local pages beyond the server list are kept', () {
      final local = ['l1', 'l2', 'l3', 'l4', 'l5', 'l6'];

      expect(mergeLocalAndRemotePages(local, remote).length, 6);
    });

    test('stops at a page available from neither side', () {
      // A chapter cannot have a hole in the middle, so the list ends there.
      final local = ['l1', 'l2', null, 'l4'];

      expect(mergeLocalAndRemotePages(local, const ['r1', 'r2']),
          ['l1', 'l2']);
    });

    test('an empty local list falls through to the server pages', () {
      expect(mergeLocalAndRemotePages(const [], remote), remote);
    });
  });

  group('offlineOnlyPages', () {
    test('with no server, only the files on disk are readable', () {
      final local = ['l1', null, 'l3'];

      expect(offlineOnlyPages(local), ['l1', 'l3']);
    });

    test('nothing downloaded means nothing to read', () {
      expect(offlineOnlyPages(null), isEmpty);
      expect(offlineOnlyPages(const [null, null]), isEmpty);
    });
  });
}
