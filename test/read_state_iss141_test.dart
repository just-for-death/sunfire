// ISS-141: explicit read-state actions beat automatic progress; the newest
// action wins. Pure merges + the pull node helper; fakes only, no server.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/sync/conflict_resolver.dart';
import 'package:sunfire/src/core/sync/read_state_merge.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart' show mergeSnapshotChapterNode;

Chapter _ch({bool read = false, int page = 0, int? action, int? lastReadAt, bool? snapRead, int? snapPage}) =>
    Chapter()
      ..serverId = 5
      ..isRead = read
      ..lastPageRead = page
      ..readStateActionAt = action
      ..lastReadAt = lastReadAt
      ..syncedIsRead = snapRead
      ..syncedLastPageRead = snapPage;

Map<String, dynamic> _node({bool read = false, int page = 0, int? meta}) => {
      'id': 5,
      'name': 'c',
      'chapterNumber': 1,
      'pageCount': 40,
      'isRead': read,
      'lastPageRead': page,
      if (meta != null) 'meta': [
        {'key': 'sunfire_other', 'value': 'x'},
        {'key': kReadActionMetaKey, 'value': '$meta'},
      ],
    };

void main() {
  group('device vs device (ConflictResolver.resolveChapter)', () {
    test('(1) a stale device cannot roll automatic progress back', () {
      final r = ConflictResolver().resolveChapter(local: _ch(page: 18), remote: _ch(page: 2));
      expect(r.lastPageRead, 18);
    });

    test('(2) Mark unread survives a sync against older progress', () {
      final unread = _ch(read: false, page: 0, action: 200);
      final staleRead = _ch(read: true, page: 40, lastReadAt: 150);
      final r = ConflictResolver().resolveChapter(local: staleRead, remote: unread);
      expect(r.isRead, isFalse);
      expect(r.lastPageRead, 0);
      expect(r.readStateActionAt, 200);
    });

    test('(3) restart to page 0 survives a sync', () {
      final restarted = Chapter()
        ..serverId = 5
        ..lastPageRead = 30;
      restarted
        ..applyReadState(false) // reset/restart stamps an action
        ..lastPageRead = 0;
      final r = ConflictResolver().resolveChapter(local: restarted, remote: _ch(page: 30, action: 10));
      expect(r.lastPageRead, 0);
    });

    test('older action loses to a newer one', () {
      final r = ConflictResolver().resolveChapter(local: _ch(read: true, page: 40, action: 300), remote: _ch(action: 100));
      expect(r.isRead, isTrue);
    });
  });

  group('server pull', () {
    test('(4) a newer server action (Sunfire meta) overrides a stale device', () {
      final c = _ch(read: true, page: 40, action: 100, snapRead: true, snapPage: 40);
      applyServerReadState(c, serverIsRead: false, serverPage: 0, serverMetaActionAt: 500, hasPendingMutation: false);
      expect(c.isRead, isFalse);
      expect(c.lastPageRead, 0);
      expect(c.readStateActionAt, 500);
      expect([c.syncedIsRead, c.syncedLastPageRead], [false, 0]);
    });

    test('server meta newer → server wins even without a snapshot', () {
      final c = _ch(page: 25, action: 100);
      applyServerReadState(c, serverIsRead: false, serverPage: 0, serverMetaActionAt: 101, hasPendingMutation: false);
      expect(c.lastPageRead, 0);
    });

    test('no-meta outside change vs snapshot beats an older device action', () {
      final c = _ch(read: true, page: 40, action: 100, snapRead: true, snapPage: 40);
      applyServerReadState(c,
          serverIsRead: false, serverPage: 0, hasPendingMutation: false, nowSeconds: 1000);
      expect(c.isRead, isFalse);
      expect(c.lastPageRead, 0);
      expect(c.readStateActionAt, 1000);
    });

    test('no-meta values equal to the snapshot mean no change', () {
      final c = _ch(read: false, page: 0, action: 900, snapRead: true, snapPage: 40);
      // Local Mark unread already replayed; server still reports the old
      // snapshot? No: equal-to-snapshot means the server did nothing new.
      final d = _ch(read: false, page: 12, snapRead: false, snapPage: 3);
      applyServerReadState(d, serverIsRead: false, serverPage: 3, hasPendingMutation: false);
      expect(d.lastPageRead, 12, reason: 'local automatic progress is kept');
      applyServerReadState(c, serverIsRead: true, serverPage: 40, serverMetaActionAt: 100, hasPendingMutation: false);
      expect(c.isRead, isFalse, reason: 'unchanged server + older meta: local action stands');
    });

    test('stale server progress never rewinds the device (no snapshot yet)', () {
      final c = _ch(page: 30);
      applyServerReadState(c, serverIsRead: false, serverPage: 4, hasPendingMutation: false);
      expect(c.lastPageRead, 30);
    });

    test('a pending local mutation keeps local values and the old snapshot', () {
      final c = _ch(read: false, page: 0, action: 50, snapRead: true, snapPage: 40);
      applyServerReadState(c, serverIsRead: true, serverPage: 40, serverMetaActionAt: 900, hasPendingMutation: true);
      expect(c.isRead, isFalse);
      expect(c.syncedIsRead, isTrue);
    });

    test('snapshot pull node path reads the meta stamp', () {
      final m = Manga()..serverId = 9;
      final c = _ch(read: true, page: 40, action: 100, snapRead: true, snapPage: 40);
      mergeSnapshotChapterNode(c, _node(read: false, page: 0, meta: 700), manga: m, hasPendingMutation: false);
      expect(c.isRead, isFalse);
      expect(c.readStateActionAt, 700);
      expect(readActionAtFromNode(_node()), isNull);
    });
  });

  test('applyReadState stamps an explicit action', () {
    final c = Chapter()..pageCount = 10;
    expect(c.readStateActionAt, isNull);
    c.applyReadState(true);
    expect(c.readStateActionAt, isNotNull);
    expect(c.lastPageRead, 10);
  });
}
