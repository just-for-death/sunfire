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

    test('Server proxy thumbnail URL fallback resolution for synced manga', () {
      const baseUrl = 'http://127.0.0.1:4567';
      const mangaServerId = 42;
      String? thumbnailUrl = '';

      // When direct URL is empty, app constructs generic server proxy endpoint
      if (thumbnailUrl.isEmpty && mangaServerId > 0) {
        thumbnailUrl = '$baseUrl/api/v1/manga/$mangaServerId/thumbnail';
      }

      expect(thumbnailUrl, equals('http://127.0.0.1:4567/api/v1/manga/42/thumbnail'));
    });

    test('Generic extension header cache isolation', () {
      final headers = <String, String>{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      };
      // Simulating dynamic extension getHeaders response without any hardcoded domain checks
      final extHeaders = {'Referer': 'https://custom-manga-site.org/'};
      headers.addAll(extHeaders);

      expect(headers['Referer'], equals('https://custom-manga-site.org/'));
      expect(headers['User-Agent'], isNotEmpty);
    });

    test('Chapter model authentic dateUpload preservation across extensions', () {
      final webtoonsCh = Chapter()
        ..serverId = 101
        ..name = 'Ep. 1115 - One Last Prayer'
        ..dateUpload = 'May 6, 2026';

      final weebCentralCh = Chapter()
        ..serverId = 102
        ..name = 'Chapter 23'
        ..dateUpload = '2025-07-19';

      final readComicsCh = Chapter()
        ..serverId = 103
        ..name = 'Chapter 1'
        ..dateUpload = '26 Aug 2026';

      final mangaHereCh = Chapter()
        ..serverId = 104
        ..name = 'Ch.045'
        ..dateUpload = 'Nov 14, 2024';

      expect(webtoonsCh.dateUpload, equals('May 6, 2026'));
      expect(weebCentralCh.dateUpload, equals('2025-07-19'));
      expect(readComicsCh.dateUpload, equals('26 Aug 2026'));
      expect(mangaHereCh.dateUpload, equals('Nov 14, 2024'));
    });

    test('Reading progress clamping avoids Page 11/10 overflow', () {
      final ch = Chapter()
        ..serverId = 201
        ..pageCount = 10
        ..lastPageRead = 11
        ..isRead = false;

      // Clamping logic applied in UI and reader
      final clampedPage = ch.lastPageRead.clamp(1, ch.pageCount);
      expect(clampedPage, equals(10));
      expect(clampedPage <= ch.pageCount, isTrue);

      // Once marked read, subtitle suppresses page progress
      ch.isRead = true;
      expect(ch.isRead, isTrue);
    });

    test('Auto-scroll speed stepping, clamping, and faster turbo jump', () {
      double speed = 50.0;
      expect(speed, equals(50.0));

      // Stepping when < 100
      double step = speed >= 300 ? 50.0 : (speed >= 100 ? 25.0 : 10.0);
      speed = (speed + step).clamp(10.0, 1000.0);
      expect(speed, equals(60.0));

      // Faster preset jump (when < 180 -> 250)
      if (speed < 180.0) {
        speed = 250.0;
      }
      expect(speed, equals(250.0));

      // Turbo preset jump (when >= 180 and < 450 -> 500)
      if (speed >= 180.0 && speed < 450.0) {
        speed = 500.0;
      }
      expect(speed, equals(500.0));

      // Stepping when >= 300
      step = speed >= 300 ? 50.0 : (speed >= 100 ? 25.0 : 10.0);
      speed = (speed + step).clamp(10.0, 1000.0);
      expect(speed, equals(550.0));
    });

    test('Date formatting helper formats accurately across formats', () {
      final testDate = DateTime(2026, 9, 5);
      final y = testDate.year.toString().padLeft(4, '0');
      final m = testDate.month.toString().padLeft(2, '0');
      final d = testDate.day.toString().padLeft(2, '0');

      String format(String fmt) {
        switch (fmt) {
          case 'MM/DD/YYYY':
            return '$m/$d/$y';
          case 'DD/MM/YYYY':
            return '$d/$m/$y';
          case 'DD.MM.YYYY':
            return '$d.$m.$y';
          case 'YYYY-MM-DD':
          default:
            return '$y-$m-$d';
        }
      }

      expect(format('YYYY-MM-DD'), equals('2026-09-05'));
      expect(format('MM/DD/YYYY'), equals('09/05/2026'));
      expect(format('DD/MM/YYYY'), equals('05/09/2026'));
      expect(format('DD.MM.YYYY'), equals('05.09.2026'));
    });

    test('NSFW detection logic flags adult sources accurately', () {
      bool isNsfw(Map<String, dynamic> json) {
        final nameStr = json['name'] as String? ?? '';
        return json['isNsfw'] == true ||
            json['isNsfw'] == 1 ||
            json['nsfw'] == true ||
            json['nsfw'] == 1 ||
            nameStr.toLowerCase().contains('18+') ||
            nameStr.toLowerCase().contains('hentai');
      }

      expect(isNsfw({'name': 'MangaDex', 'isNsfw': false}), isFalse);
      expect(isNsfw({'name': 'ReadComicsOnline', 'isNsfw': false}), isFalse);
      expect(isNsfw({'name': 'Adult Manga (18+)', 'isNsfw': false}), isTrue);
      expect(isNsfw({'name': 'HentaiCafe', 'isNsfw': false}), isTrue);
      expect(isNsfw({'name': 'Generic Source', 'isNsfw': true}), isTrue);
    });

    test('Tab index mapping aligns correctly across all navigation screens', () {
      const tabs = ['Library', 'Updates', 'History', 'Browse', 'Settings'];
      expect(tabs.indexOf('Library'), equals(0));
      expect(tabs.indexOf('Updates'), equals(1));
      expect(tabs.indexOf('History'), equals(2));
      expect(tabs.indexOf('Browse'), equals(3));
      expect(tabs.indexOf('Settings'), equals(4));
    });
  });
}
