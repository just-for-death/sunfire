// Verifies real Suwayomi-shaped delta nodes parse into local models,
// and that SyncResult carries the payload for applyDeltaChanges.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  final engine = SyncEngine.instance;

  group('parseMangaNode (Suwayomi shape)', () {
    test('maps title/source/categories nodes', () {
      final manga = engine.parseMangaNode({
        'id': 42,
        'title': 'Berserk',
        'author': 'Miura',
        'artist': 'Miura',
        'description': 'Dark fantasy',
        'thumbnailUrl': 'https://example.com/cover.jpg',
        'status': 'ONGOING',
        'inLibrary': true,
        'inLibraryAt': 1700000000,
        'url': 'https://example.com/berserk',
        'unreadCount': 3,
        'source': {'displayName': 'MangaDex', 'name': 'MangaDex'},
        'categories': {
          'nodes': [
            {'id': 1},
            {'id': 7},
          ],
        },
      });

      expect(manga.serverId, 42);
      expect(manga.title, 'Berserk');
      expect(manga.author, 'Miura');
      expect(manga.sourceName, 'MangaDex');
      expect(manga.thumbnailUrl, 'https://example.com/cover.jpg');
      expect(manga.inLibrary, isTrue);
      expect(manga.unreadCount, 3);
      expect(manga.categoryIds, [1, 7]);
    });

    test('falls back name/coverUrl/sourceName', () {
      final manga = engine.parseMangaNode({
        'id': 1,
        'name': 'Legacy Title',
        'coverUrl': 'https://example.com/old.jpg',
        'sourceName': 'LegacySource',
        'categoryIds': [2, 3],
      });
      expect(manga.title, 'Legacy Title');
      expect(manga.thumbnailUrl, 'https://example.com/old.jpg');
      expect(manga.sourceName, 'LegacySource');
      expect(manga.categoryIds, [2, 3]);
    });
  });

  group('parseChapterNode (Suwayomi shape)', () {
    test('maps isDownloaded + bookmark', () {
      final chapter = engine.parseChapterNode({
        'id': 99,
        'mangaId': 42,
        'name': 'Ch 1',
        'chapterNumber': 1.0,
        'isRead': false,
        'isBookmarked': true,
        'lastPageRead': 4,
        'isDownloaded': true,
        'fetchedAt': 1700000000,
      });
      expect(chapter.serverId, 99);
      expect(chapter.mangaId, 42);
      expect(chapter.isBookmarked, isTrue);
      expect(chapter.isDownloadedOnServer, isTrue);
      expect(chapter.lastPageRead, 4);
    });
  });

  group('SyncResult data passthrough', () {
    test('copyWith preserves data for applyDeltaChanges', () {
      final result = SyncResult(
        success: true,
        mangaUpdated: 1,
        data: {
          'manga': [
            {'id': 1, 'title': 'X'}
          ],
          'chapters': <Map<String, dynamic>>[],
          'categories': <Map<String, dynamic>>[],
        },
      );
      expect(result.data?['manga'], isNotEmpty);
      expect(result.copyWith(chaptersUpdated: 2).data?['manga'], isNotEmpty);
    });
  });
}
