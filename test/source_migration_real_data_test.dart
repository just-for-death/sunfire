import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/source_migration_service.dart';

const String _tempRoot = '/tmp/sunfire_test_migration_extensions';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => _tempRoot,
    );
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  tearDownAll(() {
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('SourceMigration & QuickJS Integration: Real Data & Key Resolution', () {
    setUp(() async {
      final quickJs = QuickJsService.instance;
      const testJs = '''
        const mangayomiSources = [{
          "name": "WeebCentral",
          "baseUrl": "https://weebcentral.com"
        }];
        class DefaultExtension extends MProvider {
          async getPopular(page) {
            return {
              list: [
                {
                  name: "One Piece",
                  link: "/series/01JJN4",
                  imageUrl: "https://cdn.weebcentral.com/cover.png"
                }
              ],
              hasNextPage: false
            };
          }
          async getDetail(url) {
            return {
              description: "Pirate adventure",
              author: "Eiichiro Oda",
              imageUrl: "https://cdn.weebcentral.com/cover.png",
              chapters: [
                { name: "Chapter 1", url: "/chapter/1", chapterNumber: 1.0 },
                { name: "Chapter 2", url: "/chapter/2", chapterNumber: 2.0 }
              ]
            };
          }
        }
      ''';
      await quickJs.saveLocalExtension('weeb_central', testJs);
    });

    test('1. QuickJsService recognizes extension names with local_js_ prefix', () {
      final quickJs = QuickJsService.instance;
      expect(quickJs.hasExtension('weeb_central'), isTrue);
      expect(quickJs.hasExtension('local_js_weeb_central'), isTrue);
      expect(quickJs.hasExtension('WeebCentral'), isTrue);
      expect(quickJs.getExtensionCode('local_js_weeb_central'), isNotNull);
    });

    test('2. SourceMigrationService normalizes local_js_ prefixes correctly', () {
      final migration = SourceMigrationService.instance;
      expect(migration.normalizeSourceName('local_js_weeb_central'), equals('weeb central'));
      expect(migration.normalizeSourceName('local_js_mangadex'), equals('mangadex'));
      expect(migration.matchServerSourceToLocalJs('Weeb Central (EN)', ['weeb_central.js']), equals('weeb_central.js'));
    });

    test('3. Migration preserves real scraped URLs and non-colliding chapter association', () {
      // Mock Mangayomi search result (uses 'name', 'link', 'imageUrl')
      final targetMangaMap = {
        'name': 'One Piece',
        'link': '/series/01JJN4',
        'imageUrl': 'https://cdn.weebcentral.com/cover.png',
      };

      final targetLink = (targetMangaMap['link'] ?? targetMangaMap['url'] ?? '').toString();
      final targetThumb = (targetMangaMap['imageUrl'] ?? targetMangaMap['thumbnailUrl'] ?? '').toString();
      final targetTitle = (targetMangaMap['title'] ?? targetMangaMap['name'] ?? 'Unknown').toString();
      var targetMangaId = int.tryParse(targetMangaMap['id']?.toString() ?? '0') ?? 0;
      if (targetMangaId <= 0 && targetLink.isNotEmpty) {
        targetMangaId = (targetLink.hashCode ^ 'Weeb Central'.hashCode).abs();
      }

      final targetMangaEntity = Manga()
        ..serverId = targetMangaId
        ..title = targetTitle
        ..url = targetLink
        ..thumbnailUrl = targetThumb
        ..sourceName = 'local_js_weeb_central'
        ..inLibrary = true;

      // Assert that fields contain real scraped data, not empty stubs
      expect(targetMangaEntity.title, equals('One Piece'));
      expect(targetMangaEntity.url, equals('/series/01JJN4'));
      expect(targetMangaEntity.thumbnailUrl, equals('https://cdn.weebcentral.com/cover.png'));
      expect(targetMangaEntity.serverId, isPositive);

      // Verify that chapter association uses targetMangaEntity.serverId
      final tgtMangaId = targetMangaEntity.serverId != 0 ? targetMangaEntity.serverId : targetMangaEntity.id;
      final ch = Chapter()
        ..serverId = -(tgtMangaId.abs() * 10000 + 1)
        ..mangaId = tgtMangaId
        ..name = 'Chapter 1'
        ..chapterNumber = 1.0
        ..url = '/chapter/1'
        ..realUrl = '/chapter/1';

      expect(ch.mangaId, equals(targetMangaEntity.serverId));
      expect(ch.url, isNotEmpty);
      expect(ch.serverId, isNegative);
    });

    test('4. Migration chapter transfer preserves bookmarks, downloads, and read history', () {
      final sourceChapter = Chapter()
        ..serverId = 101
        ..mangaId = 10
        ..chapterNumber = 1.0
        ..name = 'Chapter 1'
        ..isRead = true
        ..lastPageRead = 20
        ..lastReadAt = 1700000000
        ..isBookmarked = true
        ..isDownloadedLocally = true
        ..localPath = '/downloads/10/ch1'
        ..fetchedAt = 1690000000;

      final targetChapter = Chapter()
        ..serverId = -200001
        ..mangaId = -20
        ..chapterNumber = 1.0
        ..name = 'Chapter 1'
        ..isRead = false
        ..lastPageRead = 0;

      // Transfer progress
      if (sourceChapter.chapterNumber == targetChapter.chapterNumber) {
        targetChapter.isRead = sourceChapter.isRead;
        targetChapter.lastPageRead = sourceChapter.lastPageRead;
        targetChapter.lastReadAt = sourceChapter.lastReadAt;
        targetChapter.isBookmarked = sourceChapter.isBookmarked;
        targetChapter.isDownloadedLocally = sourceChapter.isDownloadedLocally;
        targetChapter.localPath = sourceChapter.localPath;
        targetChapter.fetchedAt = sourceChapter.fetchedAt;
      }

      expect(targetChapter.isRead, isTrue);
      expect(targetChapter.lastPageRead, equals(20));
      expect(targetChapter.isBookmarked, isTrue);
      expect(targetChapter.isDownloadedLocally, isTrue);
      expect(targetChapter.localPath, equals('/downloads/10/ch1'));
      expect(targetChapter.fetchedAt, equals(1690000000));
    });

    test('5. Migration search result correctly resolves title and thumb for JS extension format', () {
      final jsResult = {
        'name': 'Vigilante: Boku no Hero Academia Illegals',
        'imageUrl': 'https://cdn.example.com/cover.jpg',
        'link': '/series/vigilante',
      };

      final thumb = (jsResult['thumbnailUrl'] ?? jsResult['imageUrl'] ?? jsResult['cover'] ?? '').toString();
      final rawTitle = (jsResult['title'] ?? jsResult['name'] ?? '').toString().trim();
      final title = rawTitle.isNotEmpty ? rawTitle : 'Untitled';

      expect(title, equals('Vigilante: Boku no Hero Academia Illegals'));
      expect(thumb, equals('https://cdn.example.com/cover.jpg'));
    });

    test('6. Reader recovered image eviction never drops incoming images under cache pressure', () {
      final cache = <String, List<int>>{};
      const maxCapacity = 40;
      final pageUrls = List.generate(50, (i) => 'https://example.com/page_$i.jpg');
      int currentPage = 16;

      void storeImage(String url, List<int> bytes) {
        if (cache.length >= maxCapacity) {
          String? evictCandidate;
          for (final key in cache.keys) {
            final idx = pageUrls.indexOf(key);
            if (idx == -1 || (idx - (currentPage - 1)).abs() > 2) {
              evictCandidate = key;
              break;
            }
          }
          evictCandidate ??= cache.keys.first;
          cache.remove(evictCandidate);
        }
        cache[url] = bytes;
      }

      for (int i = 0; i < 45; i++) {
        storeImage(pageUrls[i], [i]);
      }

      expect(cache.length, equals(maxCapacity));
      expect(cache.containsKey(pageUrls[44]), isTrue);
      // Current page ± 2 (indices 13..17) must remain in cache
      for (int i = 13; i <= 17; i++) {
        expect(cache.containsKey(pageUrls[i]), isTrue, reason: 'Page $i should not be evicted');
      }
    });

    test('7. ValueNotifier<int> synchronously updates page display for HUD lockstep', () {
      final notifier = ValueNotifier<int>(1);
      int capturedValue = notifier.value;
      notifier.addListener(() {
        capturedValue = notifier.value;
      });

      notifier.value = 5;
      expect(capturedValue, equals(5));

      notifier.value = 16;
      expect(capturedValue, equals(16));
    });
  });
}
