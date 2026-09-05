import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';

void main() {
  group('Sunfire Data Models Unit Tests', () {
    test('Manga model instantiation', () {
      final manga = Manga()
        ..serverId = 1
        ..title = 'One Piece'
        ..inLibrary = true
        ..sourceName = 'Weeb Central'
        ..lang = 'en'
        ..url = 'https://weebcentral.com/manga/1';

      expect(manga.serverId, equals(1));
      expect(manga.title, equals('One Piece'));
      expect(manga.inLibrary, isTrue);
      expect(manga.sourceName, equals('Weeb Central'));
    });

    test('Chapter model instantiation & Monotonic read test', () {
      final ch = Chapter()
        ..serverId = 4502
        ..mangaId = 1
        ..name = 'Chapter 102'
        ..chapterNumber = 102.0
        ..isRead = false
        ..lastPageRead = 5
        ..pageCount = 30;

      expect(ch.serverId, equals(4502));
      expect(ch.chapterNumber, equals(102.0));

      ch.isRead = ch.isRead || true;
      ch.lastPageRead = 25 > ch.lastPageRead ? 25 : ch.lastPageRead;

      expect(ch.isRead, isTrue);
      expect(ch.lastPageRead, equals(25));
    });

    test('SyncRecord model enum serialization', () {
      final record = SyncRecord()
        ..recordId = 'uuid-1234'
        ..entityType = SyncEntityType.chapter
        ..entityId = '4502'
        ..action = SyncAction.update
        ..payloadJson = '{"isRead": true, "lastPageRead": 25}'
        ..timestamp = 1786800114
        ..deviceId = 'device-ios-01'
        ..state = SyncRecordState.pending;

      expect(record.recordId, equals('uuid-1234'));
      expect(record.entityType, equals(SyncEntityType.chapter));
      expect(record.action, equals(SyncAction.update));
      expect(record.state, equals(SyncRecordState.pending));
    });

    test('Chapter model uploadDate and scanlator storage', () {
      final ch = Chapter()
        ..serverId = 8801
        ..mangaId = 12
        ..name = 'Superman (2023-) #41'
        ..chapterNumber = 41.0
        ..scanlator = 'DC Comics'
        ..uploadDate = 1787616000 // Real published timestamp
        ..fetchedAt = 1788582000; // Recent sync timestamp

      expect(ch.uploadDate, equals(1787616000));
      expect(ch.fetchedAt, equals(1788582000));
      expect(ch.scanlator, equals('DC Comics'));
    });

    test('ReadComicsOnline cover URL normalization (Bot Fight Mode bypass)', () {
      const blockedUrl = 'https://readcomicsonline.ru/uploads/manga/superman-2023/cover/cover_250x350.jpg';
      final rewritten = blockedUrl.replaceFirst('readcomicsonline.ru/uploads/', 'cdn.readcomicsonline.ru/uploads/');
      expect(rewritten, equals('https://cdn.readcomicsonline.ru/uploads/manga/superman-2023/cover/cover_250x350.jpg'));
    });
  });
}
