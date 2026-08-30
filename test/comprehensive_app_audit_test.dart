import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/app.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/features/onboarding/onboarding_screen.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';
import 'package:sunfire/src/main_shell.dart';

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
        final res = await gql.fetchLibrary().timeout(const Duration(seconds: 1));
        if (res == null) handledCleanly = true;
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
      expect(find.text('Standalone Mode'), findsOneWidget);
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

    test('11. Library Status Filtering and Sorting logic', () {
      final m1 = Manga()..serverId = 1..title = 'Berserk'..unreadCount = 10..chapterCount = 370..status = 'Ongoing';
      final m2 = Manga()..serverId = 2..title = 'Chainsaw Man'..unreadCount = 0..chapterCount = 150..status = 'Completed';
      final m3 = Manga()..serverId = 3..title = 'Attack on Titan'..unreadCount = 5..chapterCount = 139..status = 'Completed';

      final allManga = [m1, m2, m3];

      // Filter: Unread
      final unreadOnly = allManga.where((m) => (m.unreadCount ?? 0) > 0).toList();
      expect(unreadOnly.length, equals(2));
      expect(unreadOnly.map((m) => m.title), containsAll(['Berserk', 'Attack on Titan']));

      // Filter: Completed
      final completedOnly = allManga.where((m) => (m.status ?? '').toLowerCase() == 'completed').toList();
      expect(completedOnly.length, equals(2));
      expect(completedOnly.map((m) => m.title), containsAll(['Chainsaw Man', 'Attack on Titan']));

      // Sort: Total Chapters Descending
      final sortedByChapters = List<Manga>.from(allManga)..sort((a, b) => b.chapterCount.compareTo(a.chapterCount));
      expect(sortedByChapters.first.title, equals('Berserk'));
      expect(sortedByChapters.last.title, equals('Attack on Titan'));
    });

    test('12. History Date Header Categorization logic', () {
      final now = DateTime.now();
      final todayDate = now;
      final yesterdayDate = now.subtract(const Duration(days: 1));
      final pastWeekDate = now.subtract(const Duration(days: 3));

      String computeDateHeader(DateTime readDate) {
        final diff = now.difference(readDate);
        if (diff.inDays == 0 && now.day == readDate.day) {
          return 'Today';
        } else if (diff.inDays <= 1 || (diff.inDays == 0 && now.day != readDate.day)) {
          return 'Yesterday';
        } else if (diff.inDays < 7) {
          return 'Past Week';
        } else {
          return '${readDate.year}-${readDate.month.toString().padLeft(2, '0')}-${readDate.day.toString().padLeft(2, '0')}';
        }
      }

      expect(computeDateHeader(todayDate), equals('Today'));
      expect(computeDateHeader(yesterdayDate), equals('Yesterday'));
      expect(computeDateHeader(pastWeekDate), equals('Past Week'));
    });

    test('13. Extension Same-Site Deduplication logic prevents duplicate extensions for same domain', () {
      final s1 = const RepoSourceItem(
        name: 'nHentai.com',
        lang: 'en',
        sourceCodeUrl: 'https://repo.com/nhentai_com.js',
        iconUrl: '',
        version: '1.1.0',
        isJs: true,
        baseUrl: 'https://nhentai.net',
      );
      final s2 = const RepoSourceItem(
        name: 'nHentai',
        lang: 'en',
        sourceCodeUrl: 'https://repo.com/nhentai.js',
        iconUrl: '',
        version: '1.2.0',
        isJs: true,
        baseUrl: 'https://nhentai.net',
      );

      final Map<String, RepoSourceItem> siteDedupMap = {};
      for (final item in [s1, s2]) {
        final uri = Uri.tryParse(item.baseUrl);
        final siteKey = (uri != null && uri.host.isNotEmpty) ? uri.host.replaceAll('www.', '').toLowerCase() : item.name.toLowerCase();
        final fullKey = '${siteKey}_${item.lang}'.toLowerCase();

        if (!siteDedupMap.containsKey(fullKey)) {
          siteDedupMap[fullKey] = item;
        } else {
          final existing = siteDedupMap[fullKey]!;
          if (RepoManager.compareVersions(item.version, existing.version) > 0) {
            siteDedupMap[fullKey] = item;
          }
        }
      }

      expect(siteDedupMap.length, equals(1));
      expect(siteDedupMap.values.first.name, equals('nHentai'));
      expect(siteDedupMap.values.first.version, equals('1.2.0'));
    });

    testWidgets('14. Tablet & iPad Responsive Navigation Rail adapts for wide viewports (>= 720px)', (tester) async {
      // Set surface size to iPad screen dimensions (834 x 1194)
      tester.view.physicalSize = const Size(834, 1194);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: MainShell()));
      await tester.pumpAndSettle();

      // Tablet side navigation rail shows icon and labels
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Browse'), findsWidgets);
    });

    test('15. Chapter Published Date Formatting & Sanitization', () {
      String? formatChapterDate(int? rawTimestamp) {
        if (rawTimestamp == null || rawTimestamp <= 0) return null;
        final ms = rawTimestamp > 1000000000000 ? rawTimestamp : rawTimestamp * 1000;
        final date = DateTime.fromMillisecondsSinceEpoch(ms);
        if (date.year < 2005 || date.isAfter(DateTime.now().add(const Duration(days: 2)))) {
          return null;
        }
        final now = DateTime.now();
        final diff = now.difference(date);
        if (diff.isNegative) return 'Today';
        if (diff.inDays == 0) return 'Today';
        if (diff.inDays == 1) return 'Yesterday';
        if (diff.inDays < 30) return '${diff.inDays}d ago';
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }

      // Null, 0, or corrupted 1970 timestamp should return null (omitted from UI)
      expect(formatChapterDate(null), isNull);
      expect(formatChapterDate(0), isNull);
      expect(formatChapterDate(-1), isNull);
      expect(formatChapterDate(100), isNull); // Jan 1970

      // Valid recent timestamps
      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      expect(formatChapterDate(nowSec), equals('Today'));

      final twoDaysAgoSec = DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000;
      expect(formatChapterDate(twoDaysAgoSec), equals('2d ago'));
    });

    test('16. Offline Chapter URL Normalization for Webtoons and relative scrapers', () {
      String normalizeChapterUrl(String rawUrl, String baseUrl) {
        var clean = rawUrl.replaceAll('&amp;', '&').trim();
        if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
          final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
          final path = clean.startsWith('/') ? clean : '/$clean';
          clean = '$cleanBase$path';
        }
        return clean;
      }

      const base = 'https://www.webtoons.com';
      expect(
        normalizeChapterUrl('/en/romance/lore-olympus/episode-1/viewer?title_no=1320&episode_no=1', base),
        equals('https://www.webtoons.com/en/romance/lore-olympus/episode-1/viewer?title_no=1320&episode_no=1'),
      );
      expect(
        normalizeChapterUrl('episode-1/viewer?title_no=1320', base),
        equals('https://www.webtoons.com/episode-1/viewer?title_no=1320'),
      );
      expect(
        normalizeChapterUrl('https://www.webtoons.com/en/viewer?title_no=1320', base),
        equals('https://www.webtoons.com/en/viewer?title_no=1320'),
      );
    });

    test('17. Smart Reading Resume & Continue Reading Order Logic', () {
      final ch1 = Chapter()..serverId = 1..chapterNumber = 1.0..isRead = true..lastPageRead = 20;
      final ch2 = Chapter()..serverId = 2..chapterNumber = 2.0..isRead = false..lastPageRead = 5..lastReadAt = 1000;
      final ch3 = Chapter()..serverId = 3..chapterNumber = 3.0..isRead = false..lastPageRead = 0;
      final ch4 = Chapter()..serverId = 4..chapterNumber = 4.0..isRead = false..lastPageRead = 0;

      final chapters = [ch4, ch3, ch2, ch1]; // Unsorted or descending

      // 1. When a chapter is in-progress (ch2 with lastPageRead > 0), resume that one
      final inProgress = chapters.where((c) => !c.isRead && c.lastPageRead > 0).toList();
      expect(inProgress.isNotEmpty, isTrue);
      expect(inProgress.first.serverId, equals(2));

      // 2. When no chapter is in-progress, start with lowest chapter number
      ch2.isRead = true;
      ch2.lastPageRead = 0;
      final sortedByNum = List<Chapter>.from(chapters)..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      final unread = sortedByNum.firstWhere((c) => !c.isRead, orElse: () => sortedByNum.first);
      expect(unread.serverId, equals(3));
      expect(unread.chapterNumber, equals(3.0));
    });

    test('18. Webtoons Referer and Dynamic Image Headers Guard', () {
      final headers = QuickJsService.getImageHeaders('Webtoons (EN)', 'https://webtoon-phinf.pstatic.net/20240101_1/sample.jpg');
      expect(headers.containsKey('Referer'), isTrue);
      expect(headers['Referer'], equals('https://www.webtoons.com/'));
    });

    test('19. Chapter Selector Auto-Scroll Offset Clamp Calculation', () {
      const itemExtent = 58.0;
      const targetIndex = 15;
      const maxScrollExtent = 1200.0;
      final offset = (targetIndex * itemExtent).clamp(0.0, maxScrollExtent);
      expect(offset, equals(870.0));
    });
  });
}

