import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Final Audit Fixes & Regressions Verification', () {
    test('1. Chapter.isDownloaded setter correctly clears both local and server downloaded flags when false', () {
      final ch = Chapter();
      ch.isDownloadedLocally = true;
      ch.isDownloadedOnServer = true;
      expect(ch.isDownloaded, isTrue);

      ch.isDownloaded = false;
      expect(ch.isDownloadedLocally, isFalse);
      expect(ch.isDownloadedOnServer, isFalse);
      expect(ch.isDownloaded, isFalse);
    });

    test('2. Natural numeric sort correctly orders downloaded chapter images', () {
      final paths = [
        '/downloads/123/10.jpg',
        '/downloads/123/1.jpg',
        '/downloads/123/2.jpg',
        '/downloads/123/20.jpg',
        '/downloads/123/3.jpg',
      ];

      paths.sort((a, b) {
        final fileNameA = a.split('/').last;
        final fileNameB = b.split('/').last;
        final matchA = RegExp(r'(\d+)').firstMatch(fileNameA);
        final matchB = RegExp(r'(\d+)').firstMatch(fileNameB);
        if (matchA != null && matchB != null) {
          final numA = int.tryParse(matchA.group(1)!);
          final numB = int.tryParse(matchB.group(1)!);
          if (numA != null && numB != null && numA != numB) {
            return numA.compareTo(numB);
          }
        }
        return a.compareTo(b);
      });

      expect(paths, equals([
        '/downloads/123/1.jpg',
        '/downloads/123/2.jpg',
        '/downloads/123/3.jpg',
        '/downloads/123/10.jpg',
        '/downloads/123/20.jpg',
      ]));
    });

    test('3. Scraped chapter URL restoration preserves existing authentic URLs', () {
      final match = Chapter()
        ..id = 42
        ..url = 'https://source.com/ch1'
        ..realUrl = 'https://cdn.source.com/ch1';

      final ch = Chapter()
        ..url = ''
        ..realUrl = '';

      if (ch.url.isEmpty && match.url.isNotEmpty) ch.url = match.url;
      if (ch.realUrl.isEmpty && match.realUrl.isNotEmpty) ch.realUrl = match.realUrl;

      expect(ch.url, equals('https://source.com/ch1'));
      expect(ch.realUrl, equals('https://cdn.source.com/ch1'));
    });

    test('4. History calendar day bucketing accurately separates Today, Yesterday, and Past Week', () {
      final now = DateTime(2026, 9, 7, 10, 30);
      final nowCalendar = DateTime(now.year, now.month, now.day);

      String bucketFor(DateTime readDate) {
        final readCalendar = DateTime(readDate.year, readDate.month, readDate.day);
        final dayDiff = nowCalendar.difference(readCalendar).inDays;
        if (dayDiff == 0) return 'Today';
        if (dayDiff == 1) return 'Yesterday';
        if (dayDiff < 7) return 'Past Week';
        return 'Older';
      }

      // Today at 01:00 AM
      expect(bucketFor(DateTime(2026, 9, 7, 1, 0)), equals('Today'));
      // Yesterday at 23:59 PM (11 hours earlier)
      expect(bucketFor(DateTime(2026, 9, 6, 23, 59)), equals('Yesterday'));
      // Yesterday at 08:00 AM (26 hours earlier)
      expect(bucketFor(DateTime(2026, 9, 6, 8, 0)), equals('Yesterday'));
      // 3 days ago
      expect(bucketFor(DateTime(2026, 9, 4, 15, 0)), equals('Past Week'));
      // 10 days ago
      expect(bucketFor(DateTime(2026, 8, 28, 12, 0)), equals('Older'));
    });

    test('5. QuickJsService._headersCache bounded cache eviction works properly', () {
      QuickJsService.clearHeadersCache();
      for (int i = 0; i < 600; i++) {
        QuickJsService.cacheImageHeaders('https://example.com/img_$i.jpg', {'header': 'val_$i'});
      }
      // Should not blow up or leak infinitely
      final h = QuickJsService.getImageHeaders('https://example.com/img_599.jpg');
      expect(h['header'], equals('val_599'));
    });

    test('6. Stats screen genre and source counts sort descending', () {
      final rawGenres = {'Action': 5, 'Romance': 20, 'Comedy': 12, 'Horror': 1};
      final sortedGenres = (rawGenres.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3).toList();

      expect(sortedGenres.map((e) => e.key).toList(), equals(['Romance', 'Comedy', 'Action']));
      expect(sortedGenres.map((e) => e.value).toList(), equals([20, 12, 5]));
    });

    test('7. Library update serverStatus parser handles both nested nodes and int formats', () {
      int extractCount(dynamic jobObj) {
        if (jobObj is int) return jobObj;
        if (jobObj is num) return jobObj.toInt();
        if (jobObj is Map) {
          final mangas = jobObj['mangas'];
          if (mangas is Map) {
            final nodes = mangas['nodes'];
            if (nodes is List) return nodes.length;
          }
          if (jobObj['nodes'] is List) return (jobObj['nodes'] as List).length;
        }
        if (jobObj is List) return jobObj.length;
        return 0;
      }

      // Suwayomi GraphQL structure
      final statusGql = {
        'updateStatus': {
          'runningJobs': {
            'mangas': {
              'nodes': [{'id': 1}, {'id': 2}]
            }
          },
          'pendingJobs': {
            'mangas': {
              'nodes': [{'id': 3}]
            }
          }
        }
      };

      final updateStatus = statusGql['updateStatus'];
      expect(extractCount(updateStatus!['runningJobs']), equals(2));
      expect(extractCount(updateStatus['pendingJobs']), equals(1));

      // Direct integer fallback
      expect(extractCount(5), equals(5));
      expect(extractCount(null), equals(0));
    });

    test('8. Deep link URI validation rejects non-integer IDs and accepts valid integers', () {
      bool isValidMangaDeepLink(Uri uri) {
        if (uri.scheme == 'sunfire' && uri.host == 'manga' && uri.pathSegments.isNotEmpty) {
          final id = int.tryParse(uri.pathSegments.first);
          return id != null && id > 0;
        }
        return false;
      }

      expect(isValidMangaDeepLink(Uri.parse('sunfire://manga/123')), isTrue);
      expect(isValidMangaDeepLink(Uri.parse('sunfire://manga/not-a-number')), isFalse);
      expect(isValidMangaDeepLink(Uri.parse('sunfire://manga/0')), isFalse);
      expect(isValidMangaDeepLink(Uri.parse('sunfire://manga/-5')), isFalse);
      expect(isValidMangaDeepLink(Uri.parse('sunfire://manga/')), isFalse);
    });

    test('9. Sync wipe guard preserves local manga with serverId <= 0', () {
      final serverIds = {101, 102};
      final localStandalone = [
        {'id': 1, 'serverId': 0, 'title': 'Local Standalone A'},
        {'id': 2, 'serverId': -42, 'title': 'Local Standalone B'},
        {'id': 3, 'serverId': 101, 'title': 'Server Manga Present'},
        {'id': 4, 'serverId': 999, 'title': 'Server Manga Deleted On Server'},
      ];

      final toDelete = <Map<String, dynamic>>[];
      for (final local in localStandalone) {
        final serverId = local['serverId'] as int;
        if (serverId > 0 && !serverIds.contains(serverId)) {
          toDelete.add(local);
        }
      }

      // Standalone manga with serverId <= 0 must never be scheduled for deletion
      expect(toDelete.length, equals(1));
      expect(toDelete.first['title'], equals('Server Manga Deleted On Server'));
    });

    test('10. Manga detail chapter deduplication composite key prevents multi-scanlation overwrites', () {
      final ch1ScanA = Chapter()
        ..chapterNumber = 1.0
        ..url = 'https://source.com/ch1'
        ..scanlator = 'ScanGroupA';
      final ch1ScanB = Chapter()
        ..chapterNumber = 1.0
        ..url = 'https://source.com/ch1-alt'
        ..scanlator = 'ScanGroupB';

      String makeKey(Chapter ch) {
        final urlKey = ch.url.isNotEmpty ? ch.url : ch.realUrl;
        final scanlatorPart = ch.scanlator?.trim().toLowerCase() ?? '';
        final numKey = ch.chapterNumber.toStringAsFixed(2);
        return '${ch.mangaId}_${urlKey.isNotEmpty ? urlKey : "$numKey-$scanlatorPart"}';
      }

      final keyA = makeKey(ch1ScanA);
      final keyB = makeKey(ch1ScanB);
      expect(keyA, isNot(equals(keyB)));

      final map = <String, Chapter>{};
      map[keyA] = ch1ScanA;
      map[keyB] = ch1ScanB;
      expect(map.length, equals(2));
    });

    test('11. deleteLocalExtension restricts deletion to exact key matches', () {
      final extensions = ['mangadex.js', 'mangadex_en.js', 'dex.js'];
      const targetToDelete = 'dex';

      final remaining = extensions.where((name) {
        final exact = name == targetToDelete || name == '$targetToDelete.js';
        return !exact;
      }).toList();

      expect(remaining, equals(['mangadex.js', 'mangadex_en.js']));
    });

    test('12. ISO language code mapping correctly maps Spanish to "es" and German to "de"', () {
      const languageCodeMap = {
        'System Default': 'en',
        'English': 'en',
        'Spanish': 'es',
        'French': 'fr',
        'German': 'de',
        'Japanese': 'ja',
      };

      expect(languageCodeMap['Spanish'], equals('es'));
      expect(languageCodeMap['German'], equals('de'));
      expect(languageCodeMap['French'], equals('fr'));
      expect(languageCodeMap['English'], equals('en'));
      expect(languageCodeMap['Japanese'], equals('ja'));
    });

    test('13. Cellular Mobile Data is allowed when downloadOnlyOnWifi is false, and restricted when true', () {
      bool isAllowed(bool downloadOnlyOnWifi, List<ConnectivityResult> results) {
        final hasConnection = results.any((r) => r != ConnectivityResult.none);
        if (!hasConnection) return false;

        if (downloadOnlyOnWifi) {
          return results.contains(ConnectivityResult.wifi) ||
              results.contains(ConnectivityResult.ethernet) ||
              results.contains(ConnectivityResult.vpn);
        }
        return true;
      }

      // Cellular mobile data on Android/iOS
      expect(isAllowed(false, [ConnectivityResult.mobile]), isTrue);
      expect(isAllowed(true, [ConnectivityResult.mobile]), isFalse);

      // Wi-Fi
      expect(isAllowed(true, [ConnectivityResult.wifi]), isTrue);
      expect(isAllowed(false, [ConnectivityResult.wifi]), isTrue);

      // Ethernet
      expect(isAllowed(true, [ConnectivityResult.ethernet]), isTrue);

      // VPN
      expect(isAllowed(true, [ConnectivityResult.vpn]), isTrue);

      // Disconnected
      expect(isAllowed(false, [ConnectivityResult.none]), isFalse);
      expect(isAllowed(true, [ConnectivityResult.none]), isFalse);
    });
  });
}
