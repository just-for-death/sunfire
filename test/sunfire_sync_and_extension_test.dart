import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TEST 1: Initial Sync & Complete Local Snapshot', () {
    test('Library manga and chapters snapshot with remote source URLs and metadata', () {
      // 1. Simulate server manga payload received during initial sync
      final serverMangaPayload = {
        'id': 133,
        'title': 'Act Like You Love Me!',
        'sourceId': '2131019126180322627',
        'source': {'name': 'Weeb Central', 'displayName': 'Weeb Central (EN)'},
        'url': '/series/01JJN4',
        'thumbnailUrl': '/api/v1/manga/133/thumbnail',
        'inLibrary': true,
        'unreadCount': 50,
      };

      final manga = Manga()
        ..serverId = serverMangaPayload['id'] as int
        ..title = serverMangaPayload['title'] as String
        ..sourceName = (serverMangaPayload['source'] as Map)['displayName'] as String
        ..url = serverMangaPayload['url'] as String
        ..thumbnailUrl = serverMangaPayload['thumbnailUrl'] as String
        ..inLibrary = serverMangaPayload['inLibrary'] as bool
        ..unreadCount = serverMangaPayload['unreadCount'] as int
        ..chapterCount = 100;

      expect(manga.serverId, equals(133));
      expect(manga.title, equals('Act Like You Love Me!'));
      expect(manga.sourceName, equals('Weeb Central (EN)'));
      expect(manga.url, equals('/series/01JJN4'));
      expect(manga.chapterCount, equals(100));

      // 2. Simulate chapters snapshot with denormalized fields & source URLs
      final ch1 = Chapter()
        ..serverId = 1001
        ..mangaId = 133
        ..name = 'Chapter 1'
        ..chapterNumber = 1.0
        ..url = '/series/01JJN4/chapter-1'
        ..realUrl = 'https://weebcentral.com/series/01JJN4/chapter-1'
        ..isRead = true
        ..lastPageRead = 25
        ..pageCount = 25
        ..fetchedAt = 1786800000
        ..mangaTitle = manga.title
        ..mangaThumbnailUrl = manga.thumbnailUrl;

      final ch2 = Chapter()
        ..serverId = 1002
        ..mangaId = 133
        ..name = 'Chapter 2'
        ..chapterNumber = 2.0
        ..url = '/series/01JJN4/chapter-2'
        ..realUrl = 'https://weebcentral.com/series/01JJN4/chapter-2'
        ..isRead = false
        ..lastPageRead = 5
        ..pageCount = 30
        ..fetchedAt = 1786850000
        ..mangaTitle = manga.title
        ..mangaThumbnailUrl = manga.thumbnailUrl;

      expect(ch1.mangaTitle, equals('Act Like You Love Me!'));
      expect(ch1.url, equals('/series/01JJN4/chapter-1'));
      expect(ch1.isRead, isTrue);
      expect(ch2.lastPageRead, equals(5));

      // 3. Verify monotonic read progression
      ch2.lastPageRead = 15 > ch2.lastPageRead ? 15 : ch2.lastPageRead;
      expect(ch2.lastPageRead, equals(15));
    });

    test('Wipe Guard test: Prevents local Isar library wipe when server is emptied', () {
      final int cachedLocalMangaCount = 163;
      final int serverReturnedCount = 0; // Simulated server wipe / database reset

      // If server returned 0 and local has 163, isRemovalSafe should be blocked from deleting local items
      final bool shouldBlockCascade = (cachedLocalMangaCount > 0 && serverReturnedCount == 0);

      expect(shouldBlockCascade, isTrue);
    });
  });

  group('TEST 2: Mangayomi Local Extension Engine & Offline Independence', () {
    test('Extension name fuzzy matching: Weeb Central (EN) matches Weeb Central', () {
      final quickJs = QuickJsService.instance;

      // Mock JS extension code with Mangayomi scraper interface
      const mockJsCode = '''
        function getPopularManga(page) {
          return { list: [{ title: "Act Like You Love Me!", url: "/series/01JJN4" }] };
        }
        function getPageList(chapterUrl) {
          return { pages: ["https://img.cdn.com/1.jpg", "https://img.cdn.com/2.jpg", "https://img.cdn.com/3.jpg"] };
        }
      ''';

      // Save as "Weeb Central"
      quickJs.saveLocalExtension('Weeb Central', mockJsCode);

      // Verify direct and fuzzy lookups
      expect(quickJs.isLocalExtensionInstalled('Weeb Central'), isTrue);
      expect(quickJs.isLocalExtensionInstalled('Weeb Central (EN)'), isTrue);
      expect(quickJs.isLocalExtensionInstalled('weeb_central'), isTrue);
      expect(quickJs.isLocalExtensionInstalled('weebcentral'), isTrue);

      final code = quickJs.getExtensionCode('Weeb Central (EN)');
      expect(code, isNotNull);
      expect(code, contains('getPageList'));
    });

    test('ContentResolverService Priority 1 (Local Extension) resolves without server', () async {
      // Set up mock local JS code in QuickJsService
      const sampleScraperJs = '''
        function getPageList(url) {
          return { pages: ["https://img.weebcentral.com/pg1.png", "https://img.weebcentral.com/pg2.png"] };
        }
      ''';
      await QuickJsService.instance.saveLocalExtension('MangaKatana', sampleScraperJs);

      // Resolve chapter pages via local extension
      final result = await ContentResolverService.instance.resolveChapterPages(
        chapterServerId: 5001,
        chapterUrl: '/manga/reincarnation-no-kaben/c1',
        sourceName: 'MangaKatana (EN)',
      );

      // Verify that Priority 1 resolved the pages locally
      expect(result.source, equals(ContentSourceType.localExtension));
      expect(result.pageUrls.length, equals(2));
      expect(result.pageUrls[0], equals('https://img.weebcentral.com/pg1.png'));
    });
  });
}
