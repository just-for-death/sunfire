// IMP-032: field-wise conflict merge; progress never regresses.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/sync/conflict_resolver.dart';

dynamic _resolve(ConflictResolutionStrategy s, String field, Object? local, Object? remote,
        {bool remoteNewer = true}) =>
    ConflictResolver(strategy: s).resolve(
      entityType: 'chapter',
      entityId: 1,
      field: field,
      localValue: local,
      remoteValue: remote,
      localTimestamp: DateTime(2026, 1, remoteNewer ? 1 : 2),
      remoteTimestamp: DateTime(2026, 1, remoteNewer ? 2 : 1),
    );

void main() {
  test('LWW: a newer but lower lastPageRead does not roll progress back', () {
    expect(_resolve(ConflictResolutionStrategy.lastWriteWins, 'lastPageRead', 30, 4), 30);
    expect(_resolve(ConflictResolutionStrategy.lastWriteWins, 'lastReadAt', 100, 50), 100);
    expect(_resolve(ConflictResolutionStrategy.crdt, 'progress', 0.2, 0.9), 0.9);
  });

  test('non-progress fields keep their strategy', () {
    expect(_resolve(ConflictResolutionStrategy.lastWriteWins, 'name', 'a', 'b'), 'b');
    expect(_resolve(ConflictResolutionStrategy.lastWriteWins, 'isBookmarked', true, false), isFalse);
    expect(_resolve(ConflictResolutionStrategy.lastWriteWins, 'name', 'a', 'b', remoteNewer: false), 'a');
  });

  test('explicit choices are honoured even for progress', () {
    expect(_resolve(ConflictResolutionStrategy.serverWins, 'lastPageRead', 30, 4), 4);
    expect(_resolve(ConflictResolutionStrategy.localWins, 'lastPageRead', 3, 40), 3);
    expect(_resolve(ConflictResolutionStrategy.userChoice, 'lastPageRead', 3, 40), isA<UserChoiceMarker>());
  });

  test('mergeProgress / maxProgress helpers', () {
    expect(ConflictResolver.mergeProgress('lastPageRead', null, 7), 7);
    expect(ConflictResolver.mergeProgress('lastPageRead', 'x', 'y'), isNull);
    expect(ConflictResolver.mergeProgress('title', 1, 2), isNull);
    expect(ConflictResolver.maxProgress(null, null), isNull);
    expect(ConflictResolver.maxProgress(3, 3.5), 3.5);
  });

  test('resolveChapter keeps the furthest page and uses lastReadAt for isRead', () {
    final local = Chapter()
      ..id = 1
      ..lastPageRead = 18
      ..isRead = false
      ..lastReadAt = 100; // local read more recently
    final remote = Chapter()
      ..serverId = 9
      ..lastPageRead = 2
      ..isRead = true
      ..lastReadAt = 50; // remote read earlier
    final r = ConflictResolver().resolveChapter(local: local, remote: remote);
    expect(r.lastPageRead, 18);
    expect(r.isRead, isFalse, reason: 'local read more recently, so local isRead=false wins');
  });

  test('resolveChapter uses remote isRead when remote lastReadAt is newer', () {
    final local = Chapter()
      ..id = 1
      ..lastPageRead = 18
      ..isRead = false
      ..lastReadAt = 50; // local read earlier
    final remote = Chapter()
      ..serverId = 9
      ..lastPageRead = 2
      ..isRead = true
      ..lastReadAt = 100; // remote read more recently
    final r = ConflictResolver().resolveChapter(local: local, remote: remote);
    expect(r.lastPageRead, 18);
    expect(r.isRead, isTrue, reason: 'remote read more recently, so remote isRead=true wins');
  });
}
