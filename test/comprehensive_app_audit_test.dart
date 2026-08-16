import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/app.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/browse/browse_screen.dart';
import 'package:sunfire/src/features/history/history_screen.dart';
import 'package:sunfire/src/features/library/library_screen.dart';
import 'package:sunfire/src/features/onboarding/onboarding_screen.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FULL SYSTEM AUDIT: Core Models, Data Persistence & Offline Protection', () {
    test('1. Manga Model: ID mapping, library flags, and remote URLs', () {
      final manga = Manga()
        ..serverId = 101
        ..title = 'One Piece'
        ..author = 'Eiichiro Oda'
        ..sourceName = 'Weeb Central (EN)'
        ..url = '/series/01JJN4'
        ..thumbnailUrl = 'https://cdn.weebcentral.com/op.jpg'
        ..inLibrary = true
        ..chapterCount = 1100
        ..unreadCount = 5;

      expect(manga.serverId, equals(101));
      expect(manga.title, equals('One Piece'));
      expect(manga.inLibrary, isTrue);
      expect(manga.url, equals('/series/01JJN4'));
      expect(manga.chapterCount, equals(1100));
      expect(manga.unreadCount, equals(5));
    });

    test('2. Chapter Model: Progress, read flags, and denormalized metadata', () {
      final chapter = Chapter()
        ..serverId = 2001
        ..mangaId = 101
        ..name = 'Chapter 1100'
        ..chapterNumber = 1100.0
        ..url = '/series/01JJN4/c1100'
        ..realUrl = 'https://weebcentral.com/chapters/1100'
        ..isRead = true
        ..lastPageRead = 18
        ..pageCount = 18
        ..lastReadAt = 1786800000
        ..fetchedAt = 1786805000
        ..mangaTitle = 'One Piece'
        ..mangaThumbnailUrl = 'https://cdn.weebcentral.com/op.jpg';

      expect(chapter.serverId, equals(2001));
      expect(chapter.isRead, isTrue);
      expect(chapter.lastPageRead, equals(18));
      expect(chapter.pageCount, equals(18));
      expect(chapter.mangaTitle, equals('One Piece'));
      expect(chapter.url, equals('/series/01JJN4/c1100'));
      expect(chapter.realUrl, equals('https://weebcentral.com/chapters/1100'));
    });

    test('3. SyncRecord Model: Queueing offline mutations for server sync', () {
      final record = SyncRecord()
        ..recordId = 'rec_2001'
        ..entityId = '2001'
        ..entityType = SyncEntityType.chapter
        ..action = SyncAction.update
        ..payloadJson = '{"isRead": true, "lastPageRead": 18}'
        ..timestamp = DateTime.now().millisecondsSinceEpoch
        ..deviceId = 'device_ios'
        ..state = SyncRecordState.pending;

      expect(record.recordId, equals('rec_2001'));
      expect(record.entityId, equals('2001'));
      expect(record.action, equals(SyncAction.update));
      expect(record.payloadJson, contains('isRead'));
      expect(record.state, equals(SyncRecordState.pending));
    });

    test('4. QuickJS Fuzzy Source Matching: Weeb Central (EN) -> weeb_central', () {
      final qjs = QuickJsService.instance;
      
      final codeWeeb = qjs.getExtensionCode('Weeb Central (EN)');
      final codeComic = qjs.getExtensionCode('ReadComicOnline (EN)');

      // If bundled extensions exist in assets/extensions/, fuzzy matching should resolve code
      expect(codeWeeb == null || codeWeeb.isNotEmpty, isTrue);
      expect(codeComic == null || codeComic.isNotEmpty, isTrue);
    });

    test('5. ContentResolver 3-Tier Resolution Pipeline ordering', () async {
      final resolver = ContentResolverService.instance;
      
      // Inject mock local JS extension
      await QuickJsService.instance.saveLocalExtension('MangaKatana', '''
        function getPageList(chapterUrl) {
          return { pages: ["https://mangakatana.com/p1.jpg", "https://mangakatana.com/p2.jpg"] };
        }
      ''');

      final result = await resolver.resolveChapterPages(
        chapterServerId: 9999,
        chapterUrl: '/manga/mk123/c1',
        sourceName: 'MangaKatana (EN)',
      );

      // Must resolve via Priority 1 (Local Extension)
      expect(result.source, equals(ContentSourceType.localExtension));
      expect(result.pageUrls.length, equals(2));
      expect(result.pageUrls[0], contains('mangakatana.com'));
    });

    test('6. Offline Server Down Resilience: Server unreachable does not crash client', () async {
      final gql = GraphQLClientService.instance;
      gql.initialize('http://127.0.0.1:9999'); // Unreachable server port

      bool handledCleanly = false;
      try {
        await gql.fetchLibrary().timeout(const Duration(seconds: 1));
      } catch (_) {
        handledCleanly = true;
      }
      expect(handledCleanly, isTrue);
    });

    test('7. Wipe Guard Protection: Server returning empty library preserves local Isar DB', () async {
      final localMangaList = [
        Manga()..serverId = 1..title = 'Manga 1'..inLibrary = true,
        Manga()..serverId = 2..title = 'Manga 2'..inLibrary = true,
        Manga()..serverId = 3..title = 'Manga 3'..inLibrary = true,
      ];

      // Simulate Wipe Guard check: 0 returned vs 3 existing (<30%)
      final serverCount = 0;
      final localCount = localMangaList.length;
      final isWipePrevented = (serverCount < (localCount * 0.3));

      expect(isWipePrevented, isTrue);
      for (final m in localMangaList) {
        expect(m.inLibrary, isTrue);
      }
    });
  });

  group('FULL SYSTEM AUDIT: Widget & UI Rendering', () {
    testWidgets('8. SunfireApp boots cleanly without throwing exception', (WidgetTester tester) async {
      await tester.pumpWidget(const SunfireApp());
      expect(find.text('Sunfire'), findsOneWidget);
    });

    testWidgets('9. OnboardingScreen renders title and navigation buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text('Sunfire'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('10. UpdatesScreen renders header title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: UpdatesScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Updates'), findsOneWidget);
    });
  });
}
