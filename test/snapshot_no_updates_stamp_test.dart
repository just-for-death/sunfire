// UIX-05: the server library snapshot must not stamp the back-catalogue into
// the Updates feed. It used to zero `fetchedAt` for first-seen chapters and
// then run applyFloodCapToNewChapters, which re-stamped 3-4 of them per series
// with `now` (about 300 stale "updates" for 100 series after a fresh connect).
// Genuine updates come from _syncRecentUpdateChapters with the server's
// fetchedAt.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

bool _isInFeed(Chapter c) => (c.fetchedAt ?? 0) > 0;

Map<String, dynamic> _node(int id, {double? number, bool isRead = false}) => {
      'id': id,
      'name': 'Chapter ${number ?? id}',
      'chapterNumber': number ?? id.toDouble(),
      'isRead': isRead,
      'lastPageRead': 0,
      'pageCount': 20,
      'uploadDate': '1700000000000',
      'url': '/c/$id',
    };

void main() {
  final manga = Manga()
    ..serverId = 42
    ..title = 'Series'
    ..thumbnailUrl = 'https://example.com/cover.jpg';

  test('first-seen snapshot chapters (10 new) all get fetchedAt == 0', () {
    final chapters = <Chapter>[];
    for (var i = 1; i <= 10; i++) {
      final ch = Chapter()..serverId = 1000 + i;
      expect(ch.id, Isar.autoIncrement);
      mergeSnapshotChapterNode(ch, _node(1000 + i), manga: manga, hasPendingMutation: false);
      chapters.add(ch);
    }
    expect(chapters.where(_isInFeed), isEmpty);
    expect(chapters.every((c) => c.fetchedAt == 0), isTrue);
    expect(chapters.every((c) => c.mangaId == 42 && c.mangaTitle == 'Series'), isTrue);
  });

  test('a known chapter keeps its existing fetchedAt (server-reported update)', () {
    final existing = Chapter()
      ..id = 7
      ..serverId = 2001
      ..fetchedAt = 1786805000;
    mergeSnapshotChapterNode(existing, _node(2001), manga: manga, hasPendingMutation: false);
    expect(existing.fetchedAt, 1786805000);
  });

  test('pending local mutation keeps local read state', () {
    final existing = Chapter()
      ..id = 8
      ..serverId = 2002
      ..isRead = true
      ..lastPageRead = 12;
    mergeSnapshotChapterNode(existing, _node(2002, isRead: false), manga: manga, hasPendingMutation: true);
    expect(existing.isRead, isTrue);
    expect(existing.lastPageRead, 12);
  });
}
