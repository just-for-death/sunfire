import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  Manga stored() => Manga()
    ..id = 77
    ..serverId = 5
    ..title = 'Old title'
    ..author = 'Locked Author'
    ..description = 'kept'
    ..isMetadataLocked = true
    ..readingModeOverride = 'webtoon'
    ..lastReadAt = 1700000000
    ..tagIds = [3, 4]
    ..categoryIds = [1]
    ..inLibrary = true
    ..thumbnailUrl = 'https://cdn/x.jpg';

  test('delta manga node updates server fields onto the stored row', () {
    final m = stored();
    applyServerMangaNode(m, {
      'id': 5,
      'title': 'New title',
      'author': 'Server Author',
      'status': 'ONGOING',
      'unreadCount': 9,
      'categories': {
        'nodes': [
          {'id': 2},
        ],
      },
    });
    expect(m.title, 'New title');
    expect(m.status, 'ONGOING');
    expect(m.unreadCount, 9);
    expect(m.categoryIds, [2]);
    expect(m.author, 'Locked Author', reason: 'metadata lock respected');
  });

  test('local-only fields and absent server fields survive', () {
    final m = stored();
    applyServerMangaNode(m, {'id': 5, 'title': 'T', 'description': '', 'thumbnailUrl': '/api/v1/manga/5/thumbnail'});
    expect(m.id, 77);
    expect(m.tagIds, [3, 4]);
    expect(m.readingModeOverride, 'webtoon');
    expect(m.lastReadAt, 1700000000);
    expect(m.description, 'kept');
    expect(m.categoryIds, [1]);
    expect(m.inLibrary, isTrue);
    expect(m.thumbnailUrl, 'https://cdn/x.jpg');
  });
}
