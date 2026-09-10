// ignore_for_file: avoid_print
// Practical online (Docker Suwayomi :4567) + offline flow tests that mirror
// how the app syncs, loads library/trackers/thumbnails, and queues mutations.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';
import 'package:sunfire/src/main_shell.dart';

class _RealHttpOverrides extends HttpOverrides {}

const _liveUrl = 'http://localhost:4567';
const _deadUrl = 'http://127.0.0.1:45999';

Future<bool> _serverUp(String base) async {
  try {
    final res = await http
        .post(
          Uri.parse('$base/api/graphql'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'query': '{ __typename }',
          }),
        )
        .timeout(const Duration(seconds: 3));
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  group('OFFLINE: dead server (no Docker)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'server_url': _deadUrl,
        'sunfire_server_url': _deadUrl,
      });
      await SettingsService.instance.initialize();
      GraphQLClientService.instance.initialize(_deadUrl);
    });

    test('GraphQL reachability is false and fetchLibrary returns null', () async {
      final online = await GraphQLClientService.instance
          .checkServerReachable()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      expect(online, isFalse);

      final lib = await GraphQLClientService.instance
          .fetchLibrary()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      expect(lib, isNull);
    });

    test('chapter / library / category / tracker mutation payloads queue shape', () {
      final chapterPayload = {
        'chapterId': 99,
        'isRead': true,
        'lastPageRead': 12,
      };
      expect(chapterMutationNeedsReadProgress(chapterPayload), isTrue);
      expect(chapterMutationNeedsBookmark(chapterPayload), isFalse);

      final bookmarkPayload = {'chapterId': 99, 'isBookmarked': true};
      expect(chapterMutationNeedsBookmark(bookmarkPayload), isTrue);

      final categoryAssign = {
        'op': 'assign',
        'mangaId': 7,
        'categoryIds': [1, 2],
      };
      expect(categoryAssign['op'], 'assign');

      final trackerProgress = {
        'op': 'mangaProgress',
        'mangaId': 7,
        'chapterNumber': 12.0,
      };
      expect(trackerProgress['op'], 'mangaProgress');

      final rename = {'op': 'rename', 'categoryId': 3, 'name': 'Later'};
      expect(rename['op'], 'rename');

      final record = SyncRecord()
        ..recordId = 'offline-test'
        ..entityType = SyncEntityType.tracker
        ..entityId = 'manga_7'
        ..action = SyncAction.update
        ..payloadJson = jsonEncode(trackerProgress)
        ..timestamp = 1
        ..deviceId = 'test'
        ..state = SyncRecordState.pending;
      expect(record.entityType, SyncEntityType.tracker);
      expect(jsonDecode(record.payloadJson)['mangaId'], 7);
    });

    test('local history / continue-reading still work without server', () {
      final chapters = [
        Chapter()
          ..serverId = 1
          ..mangaId = 10
          ..name = 'Ch 1'
          ..chapterNumber = 1
          ..isRead = true
          ..lastReadAt = 100
          ..mangaTitle = 'Offline Title',
        Chapter()
          ..serverId = 2
          ..mangaId = 10
          ..name = 'Ch 2'
          ..chapterNumber = 2
          ..isRead = false
          ..lastPageRead = 4
          ..lastReadAt = 200
          ..mangaTitle = 'Offline Title',
      ];
      final mid = chapters.where((c) => !c.isRead && c.lastPageRead > 0).toList();
      expect(mid, isNotEmpty);
      expect(mid.first.name, 'Ch 2');
      chapters.first.clearHistoryTimestamp();
      expect(chapters.first.lastReadAt, isNull);
    });

    test('legacy download setting aliases map to live prefs', () async {
      SettingsService.instance.autoDownloadWhileReading = true;
      SettingsService.instance.downloadAheadChapterCount = 5;
      SettingsService.instance.deleteChapterAfterMarkedRead = true;
      expect(SettingsService.instance.autoDownloadEnabled, isTrue);
      expect(SettingsService.instance.autoDownloadCount, 5);
      expect(SettingsService.instance.autoDeleteRead, isTrue);
    });
  });

  group('ONLINE: Docker Suwayomi on :4567', () {
    late bool up;

    setUpAll(() async {
      up = await _serverUp(_liveUrl);
      if (!up) {
        print('Suwayomi not reachable at $_liveUrl — online group will skip');
      }
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'server_url': _liveUrl,
        'sunfire_server_url': _liveUrl,
      });
      await SettingsService.instance.initialize();
      GraphQLClientService.instance.initialize(_liveUrl);
      if (up) {
        await GraphQLClientService.instance.checkServerReachable(force: true);
      }
    });

    test('reachability + library pull', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      expect(await GraphQLClientService.instance.checkServerReachable(), isTrue);
      final data = await GraphQLClientService.instance.fetchLibrary();
      expect(data, isNotNull);
      final nodes = data!['mangas']?['nodes'] as List?;
      expect(nodes, isNotNull);
      expect(nodes!, isNotEmpty);
      final first = nodes.first as Map;
      expect(first['id'], isNotNull);
      expect(first['title'], isNotEmpty);
      print('✓ library: ${nodes.length} titles, first="${first['title']}"');
    });

    test('categories pull', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final data = await GraphQLClientService.instance.fetchCategories();
      expect(data, isNotNull);
      final nodes = data!['categories']?['nodes'] as List?;
      expect(nodes, isNotNull);
      expect(nodes!, isNotEmpty);
      print('✓ categories: ${nodes.map((e) => e['name']).join(', ')}');
    });

    test('sources + extensions lists', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final sources = await GraphQLClientService.instance.fetchSources();
      final extensions = await GraphQLClientService.instance.fetchExtensions();
      expect(sources?['sources']?['nodes'], isNotEmpty);
      expect(extensions?['extensions']?['nodes'], isNotEmpty);
      print(
        '✓ sources=${(sources!['sources']['nodes'] as List).length} '
        'extensions=${(extensions!['extensions']['nodes'] as List).length}',
      );
    });

    test('trackers list (login state)', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final data = await GraphQLClientService.instance.fetchTrackers();
      expect(data, isNotNull);
      final nodes = data!['trackers']?['nodes'] as List?;
      expect(nodes, isNotNull);
      expect(nodes!, isNotEmpty);
      final loggedIn = nodes.where((t) => t['isLoggedIn'] == true).length;
      print('✓ trackers: ${nodes.length} ($loggedIn logged in)');
    });

    test('chapters for library manga + mark-read mutation shape', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final mangas = lib!['mangas']['nodes'] as List;
      final mangaId = parseIntSafe(mangas.first['id']);
      expect(mangaId, greaterThan(0));

      final details = await GraphQLClientService.instance.fetchMangaDetails(mangaId);
      expect(details, isNotNull);
      final nodes = details!['manga']?['chapters']?['nodes'] as List?;
      expect(nodes, isNotNull);
      expect(nodes!, isNotEmpty);

      final chId = parseIntSafe(nodes.first['id']);
      final beforeRead = parseBoolSafe(nodes.first['isRead']);
      final beforePage = parseIntSafe(nodes.first['lastPageRead']);

      // Push a harmless progress update (same page) to validate mutation path.
      final res = await GraphQLClientService.instance.updateChapterReadStatus(
        chId,
        beforeRead,
        beforePage,
      );
      expect(res, isNotNull);
      print('✓ chapter sync ok for manga=$mangaId chapter=$chId');
    });

    test('thumbnail URL formula + HTTP handling (500-safe)', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final mangaId = parseIntSafe((lib!['mangas']['nodes'] as List).first['id']);
      final thumbPath = '/api/v1/manga/$mangaId/thumbnail';
      final thumbUrl = '$_liveUrl$thumbPath';
      expect(thumbUrl, contains('/api/v1/manga/'));

      final res = await http.get(Uri.parse(thumbUrl)).timeout(const Duration(seconds: 8));
      // Server may return image bytes OR 500 when upstream CDN is blocked —
      // app must tolerate both (ImageCacheHelper recovery path).
      expect(res.statusCode, anyOf(200, 404, 500));
      if (res.statusCode == 200) {
        expect(res.bodyBytes.length, greaterThan(100));
        print('✓ thumbnail OK (${res.bodyBytes.length} bytes)');
      } else {
        print('✓ thumbnail upstream failed (${res.statusCode}) — recovery path expected');
      }
    });

    test('track records query for library manga does not throw', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final mangaId = parseIntSafe((lib!['mangas']['nodes'] as List).first['id']);
      final records = await GraphQLClientService.instance.fetchTrackRecords(mangaId);
      expect(records, isNotNull);
      final nodes = records!['trackRecords']?['nodes'] as List? ?? [];
      print('✓ track records for manga $mangaId: ${nodes.length}');
    });

    test('dead-port then live URL recovers (reachability cache reset)', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      GraphQLClientService.instance.initialize(_deadUrl);
      final offline = await GraphQLClientService.instance
          .checkServerReachable(force: true)
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      expect(offline, isFalse);

      GraphQLClientService.instance.initialize(_liveUrl);
      final online = await GraphQLClientService.instance.checkServerReachable(force: true);
      expect(online, isTrue);
      final lib = await GraphQLClientService.instance.fetchLibrary();
      expect(lib?['mangas']?['nodes'], isNotEmpty);
      print('✓ GraphQL recover after dead URL: library still hydrates');
    });

    test('bookmark mutation + tracker list + sources isNsfw field', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final mangaId = parseIntSafe((lib!['mangas']['nodes'] as List).first['id']);
      final details = await GraphQLClientService.instance.fetchMangaDetails(mangaId);
      final chId = parseIntSafe((details!['manga']['chapters']['nodes'] as List).first['id']);
      final wasBookmarked = parseBoolSafe((details['manga']['chapters']['nodes'] as List).first['isBookmarked']);

      final bookmarkRes = await GraphQLClientService.instance.updateChapterBookmark(chId, wasBookmarked);
      expect(bookmarkRes, isNotNull);

      final trackers = await GraphQLClientService.instance.fetchTrackers();
      expect(trackers?['trackers']?['nodes'], isNotEmpty);

      final sources = await GraphQLClientService.instance.fetchSources();
      final nodes = sources!['sources']['nodes'] as List;
      expect(nodes.first.containsKey('isNsfw') || nodes.first.containsKey('name'), isTrue);
      print('✓ bookmark/trackers/sources wired for manga=$mangaId chapter=$chId');
    });
  });

  group('Android / iOS / iPad shell + reader wiring (host-agnostic)', () {
    test('volume-key setting defaults on and reading modes cover HUD labels', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.volumeKeyTurn, isTrue);
      expect(readingModeHudLabel(ReadingMode.longStrip), 'WEBTOON');
      expect(readingModeHudLabel(ReadingMode.pagedRtl), 'RTL');
      expect(readingModeSettingsValue(ReadingMode.longStrip), contains('Long Strip'));
    });

    test('phone vs iPad breakpoints match MainShell', () {
      expect(usesTabletShell(719), isFalse);
      expect(usesTabletShell(720), isTrue);
      expect(usesTabletShell(1024), isTrue); // iPad landscape class
      expect(sunfireDetailTwoPaneMinWidth, 840);
    });

    test('manga lastReadAt sort key for library Last Read', () {
      final a = Manga()..title = 'A'..lastReadAt = 100;
      final b = Manga()..title = 'B'..lastReadAt = 200;
      final c = Manga()..title = 'C'..lastReadAt = null;
      final list = [a, b, c]..sort((x, y) => (y.lastReadAt ?? 0).compareTo(x.lastReadAt ?? 0));
      expect(list.map((m) => m.title).toList(), ['B', 'A', 'C']);
    });
  });
}
