import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/browse/migrate_track_copy.dart';

void main() {
  test('ISS-088: one failing bind does not stop the rest; failures collected', () async {
    final bound = <int>[];
    final r = await copyTrackBindings([
      {'trackerId': 1, 'remoteId': 'a'},
      {'trackerId': '2', 'remoteId': 'b'},
      {'trackerId': 3, 'id': 'c'},
      {'trackerId': 0, 'remoteId': 'skip'},
      'junk',
    ], (tid, rid) async {
      if (tid == 2) throw StateError('server null');
      bound.add(tid);
    });
    expect(bound, [1, 3]);
    expect(r.copied, 2);
    expect(r.hasFailures, isTrue);
    expect(r.failures.single.trackerId, 2);
    expect(r.failures.single.remoteId, 'b');
  });

  test('ISS-088: all succeed → no failures', () async {
    final r = await copyTrackBindings([{'trackerId': 5, 'remoteId': 'x'}], (_, __) async {});
    expect(r.copied, 1);
    expect(r.hasFailures, isFalse);
  });
}
