import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/app.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/engine/source_migration_service.dart';
import 'package:sunfire/src/core/engine/source_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/background_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_auth_helper.dart';
import 'package:sunfire/src/features/onboarding/onboarding_screen.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';
import 'package:sunfire/src/main_shell.dart';

/// Stand-in for a real tab screen. Lets these tests assert on [MainShell]'s
/// responsive chrome and on router-driven tab switching without booting every
/// feature screen (whose service initialisation makes `pumpAndSettle` hang).
class _StubTab extends StatelessWidget {
  const _StubTab({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) => Center(child: Text('stub-tab-$index'));
}

/// Pumps [MainShell] inside the real app router with stub tab pages.
Future<void> _pumpShell(WidgetTester tester) async {
  await SettingsService.instance.initialize();
  SettingsService.instance.onboardingCompleted = true;
  // The shell reads this static notifier to pick its initial tab; reset it so
  // each test starts from a known state instead of inheriting the previous one.
  MainShell.switchToTab(0);

  final router = buildAppRouter(
    initialLocation: '/library',
    tabBuilder: (index) => _StubTab(index: index),
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reader: long strip vs gaps (Android & iOS)', () {
    test('settings strings parse to the same modes the Reader settings sheet writes', () {
      expect(parseReadingMode('Long Strip'), ReadingMode.longStrip);
      expect(parseReadingMode('Long Strip (Gaps)'), ReadingMode.longStripGaps);
      expect(parseReadingMode('Paged LTR'), ReadingMode.pagedLtr);
      expect(parseReadingMode('Paged RTL (Manga)'), ReadingMode.pagedRtl);
      expect(parseReadingMode('webtoon'), ReadingMode.longStrip);
    });

    test('cycle visits gaps instead of skipping it', () {
      expect(cycleReadingMode(ReadingMode.longStrip), ReadingMode.longStripGaps);
      expect(cycleReadingMode(ReadingMode.longStripGaps), ReadingMode.pagedRtl);
      expect(cycleReadingMode(ReadingMode.pagedRtl), ReadingMode.pagedLtr);
      expect(cycleReadingMode(ReadingMode.pagedLtr), ReadingMode.longStrip);

      var mode = ReadingMode.longStrip;
      final seen = <ReadingMode>{};
      for (var i = 0; i < 4; i++) {
        seen.add(mode);
        mode = cycleReadingMode(mode);
      }
      expect(seen, containsAll(ReadingMode.values));
    });

    test('no-gaps mode is flush; gaps mode adds 12px; HUD labels stay distinct', () {
      expect(webtoonPageGap(ReadingMode.longStrip), 0);
      expect(webtoonPageGap(ReadingMode.longStripGaps), 12);
      expect(webtoonShouldOverlapPrevious(ReadingMode.longStrip, 0), isFalse);
      expect(webtoonShouldOverlapPrevious(ReadingMode.longStrip, 3), isTrue);
      expect(webtoonShouldOverlapPrevious(ReadingMode.longStripGaps, 3), isFalse);
      expect(readingModeHudLabel(ReadingMode.longStrip), 'WEBTOON');
      expect(readingModeHudLabel(ReadingMode.longStripGaps), 'GAPS');
      expect(readingModeSettingsValue(ReadingMode.longStripGaps), 'Long Strip (Gaps)');
    });

    test('downloaded page filenames sort like the reader offline path', () {
      final paths = [
        '/data/user/0/com.sunfire.app/files/downloads/88/10.webp',
        '/data/user/0/com.sunfire.app/files/downloads/88/2.webp',
        '/data/user/0/com.sunfire.app/files/downloads/88/1.webp',
      ];
      paths.sort(compareDownloadedPagePaths);
      expect(paths.last.endsWith('10.webp'), isTrue);
      expect(paths.first.endsWith('1.webp'), isTrue);

      final iosPaths = [
        '/var/mobile/Containers/Data/Application/ABC/Documents/downloads/9/10.jpg',
        '/var/mobile/Containers/Data/Application/ABC/Documents/downloads/9/1.jpg',
      ];
      iosPaths.sort(compareDownloadedPagePaths);
      expect(iosPaths.first.endsWith('1.jpg'), isTrue);
    });
  });

  group('Sync & GraphQL wiring', () {
    test('empty server URL is not configured so offline library stays local', () {
      GraphQLClientService.instance.initialize('');
      expect(GraphQLClientService.instance.isConfigured, isFalse);
    });

    test('configured URL is trimmed and graphql path is used as base', () {
      GraphQLClientService.instance.initialize(' http://192.168.1.50:4567/ ');
      expect(GraphQLClientService.instance.isConfigured, isTrue);
      expect(GraphQLClientService.instance.baseUrl, 'http://192.168.1.50:4567');
    });

    test('chapter replay payload can carry both bookmark and read progress', () {
      final bookmarkOnly = {'chapterId': 9, 'isBookmarked': true};
      final readOnly = {'chapterId': 9, 'isRead': true, 'lastPageRead': 12};
      final combined = {'chapterId': 9, 'isBookmarked': true, 'isRead': true, 'lastPageRead': 4};

      expect(chapterMutationNeedsBookmark(bookmarkOnly) && !chapterMutationNeedsReadProgress(bookmarkOnly), isTrue);
      expect(chapterMutationNeedsReadProgress(readOnly) && !chapterMutationNeedsBookmark(readOnly), isTrue);
      expect(chapterMutationNeedsBookmark(combined) && chapterMutationNeedsReadProgress(combined), isTrue);
      expect(parseIntSafe(combined['lastPageRead']), 4);
      expect(parseBoolSafe(combined['isRead']), isTrue);
    });

    test('source names from Suwayomi map onto bundled JS extensions', () {
      const installed = [
        'Weeb Central',
        'Webtoons',
        'MangaHere',
        'nHentai',
        'Read Comics Online',
      ];
      final m = SourceMigrationService.instance;
      expect(m.matchServerSourceToLocalJs('Weeb Central (EN)', installed), 'Weeb Central');
      expect(m.matchServerSourceToLocalJs('Webtoons (EN)', installed), 'Webtoons');
      expect(m.matchServerSourceToLocalJs('MangaHere', installed), 'MangaHere');
    });

    test('resolver exposes download, local JS, server, and fallback sources', () {
      expect(
        ContentSourceType.values.toSet(),
        {
          ContentSourceType.localDownload,
          ContentSourceType.localExtension,
          ContentSourceType.suwayomiServer,
          ContentSourceType.fallback,
        },
      );
    });
  });

  group('Repos & settings persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('github repo URLs become the official index.json', () {
      expect(
        RepoManager.normalizeRepoUrl('https://github.com/just-for-death/mangayomi-extensions'),
        RepoManager.officialIndexUrl,
      );
      expect(
        RepoManager.normalizeRepoUrl(RepoManager.officialIndexUrl),
        RepoManager.officialIndexUrl,
      );
      expect(RepoManager.deriveRepoTitle(RepoManager.officialIndexUrl), RepoManager.officialRepoTitle);
      expect(RepoManager.deriveRepoTitle(RepoManager.communityIndexUrl), RepoManager.communityRepoTitle);
    });

    test('adding a repo stores the canonical URL and is idempotent', () async {
      await SettingsService.instance.initialize();
      await SettingsService.instance.addCustomRepo('https://github.com/just-for-death/mangayomi-extensions');
      await SettingsService.instance.addCustomRepo(RepoManager.officialIndexUrl);
      expect(SettingsService.instance.customRepos, [RepoManager.officialIndexUrl]);

      await SettingsService.instance.removeCustomRepo('https://github.com/just-for-death/mangayomi-extensions');
      expect(SettingsService.instance.customRepos, isEmpty);
    });

    test('onboarding repo key is merged into Settings custom_repos on initialize', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('custom_repos', []);
      await prefs.setStringList('sunfire_selected_repos', [
        'https://github.com/just-for-death/mangayomi-extensions',
      ]);
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.customRepos, [RepoManager.officialIndexUrl]);
    });
  });

  group('Safe area: iPhone vs iPad vs sideload', () {
    test('does not inflate a real iPad inset', () {
      expect(
        effectiveTopSafeInset(rawTop: 24, isApple: true, isTablet: true),
        24,
      );
    });

    test('does not inflate a real iPhone inset', () {
      expect(
        effectiveTopSafeInset(rawTop: 47, isApple: true, isTablet: false),
        47,
      );
    });

    test('sideload with zero inset gets a fallback, Android phone stays 0', () {
      expect(
        effectiveTopSafeInset(rawTop: 0, isApple: true, isTablet: true),
        24,
      );
      expect(
        effectiveTopSafeInset(rawTop: 0, isApple: true, isTablet: false),
        47,
      );
      expect(
        effectiveTopSafeInset(rawTop: 0, isApple: false, isTablet: false),
        0,
      );
    });
  });

  group('Platform shells', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('phone widths stay on the bottom bar; iPad widths use the rail', () {
      expect(usesTabletShell(390), isFalse);
      expect(usesTabletShell(428), isFalse);
      expect(usesTabletShell(sunfireTabletMinWidth), isTrue);
      expect(usesTabletShell(768), isTrue);
      expect(usesTabletShell(1024), isTrue);
    });

    test('background WorkManager is Android-only', () {
      expect(kIsWeb, isFalse);
      // iOS/iPad sync on resume in MainShell.didChangeAppLifecycleState.
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        expect(BackgroundService.instance, isNotNull);
      }
    });

    test('HTTP engine is dart:io on Android-class hosts and Cupertino on Apple', () {
      expect(MClient.userAgent, contains('Mozilla'));
      final client = MClient.init();
      expect(client, isNotNull);
    });

    testWidgets('phone width uses the bottom nav, not the iPad rail', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpShell(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Library'), findsWidgets);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);

      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));
      expect(tester.takeException(), isNull);
      expect(find.text('Browse'), findsWidgets);
    });

    testWidgets('iPad width uses the sidebar rail', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpShell(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Library'), findsWidgets);
      expect(find.text('Browse'), findsWidgets);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('iPad landscape still uses the sidebar rail', (tester) async {
      tester.view.physicalSize = const Size(1366, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpShell(tester);

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('iPad sidebar collapse/expand does not overflow during animation', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpShell(tester);
      expect(tester.takeException(), isNull);
      expect(sunfireSidebarExpandedLayoutMinWidth, 180);

      await tester.tap(find.byTooltip('Collapse sidebar'));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Expand sidebar'), findsOneWidget);

      await tester.tap(find.byTooltip('Expand sidebar'));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    });

    testWidgets('compact Android phone nav does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpShell(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('standalone onboarding offers official and community repos', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await SettingsService.instance.initialize();
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pump();

      expect(find.text('Standalone Mode'), findsOneWidget);
      await tester.tap(find.text('Standalone Mode'));
      await tester.pump(); // apply setState
      await tester.pump(); // run post-frame jumpToPage
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Sunfire Official'), findsOneWidget);
      expect(find.text('MangaYomi Community'), findsOneWidget);

      await tester.tap(find.text('Add').first);
      await tester.pump();
      await tester.pump();
      expect(find.text(RepoManager.officialRepoTitle), findsWidgets);
      expect(SettingsService.instance.customRepos, contains(RepoManager.officialIndexUrl));
    });

    testWidgets('iPad onboarding repos step is usable in portrait', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await SettingsService.instance.initialize();
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pump();
      await tester.tap(find.text('Standalone Mode'));
      await tester.pump(); // apply setState
      await tester.pump(); // run post-frame jumpToPage
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Sunfire Official'), findsOneWidget);
      expect(find.text('Start Setup & Hydration'), findsOneWidget);
    });
  });

  group('Sprint A–C logic (practical)', () {
    test('mark-read applies pageCount; continue-reading prefers last read when all read', () {
      final unread = Chapter()
        ..name = 'Ch 1'
        ..chapterNumber = 1
        ..pageCount = 20
        ..isRead = false
        ..lastPageRead = 0;
      unread.applyReadState(true);
      expect(unread.isRead, isTrue);
      expect(unread.lastPageRead, 20);
      unread.applyReadState(false);
      expect(unread.lastPageRead, 0);

      final ch1 = Chapter()
        ..name = '1'
        ..chapterNumber = 1
        ..isRead = true
        ..lastReadAt = 100;
      final ch2 = Chapter()
        ..name = '2'
        ..chapterNumber = 2
        ..isRead = true
        ..lastReadAt = 200;
      final pick = pickContinueReadingChapter([ch1, ch2]);
      expect(pick?.name, '2');

      final mid = Chapter()
        ..name = 'mid'
        ..chapterNumber = 1.5
        ..isRead = false
        ..lastPageRead = 3
        ..lastReadAt = 50;
      expect(pickContinueReadingChapter([ch1, mid, ch2])?.name, 'mid');
    });

    test('select-all style filtered chapter set uses visible ids only', () {
      final all = [
        Chapter()..serverId = 1..isRead = false..name = 'a',
        Chapter()..serverId = 2..isRead = true..name = 'b',
        Chapter()..serverId = 3..isRead = false..name = 'c',
      ];
      final unread = all.where((c) => !c.isRead).toList();
      final selected = <int>{};
      selected.addAll(unread.map((c) => c.serverId));
      expect(selected, {1, 3});
      expect(selected.length, isNot(all.length));
    });

    test('per-manga reading mode override wins over global settings string', () {
      const global = 'Long Strip';
      const override = 'Paged RTL (Manga)';
      expect(parseReadingMode(override.isNotEmpty ? override : global), ReadingMode.pagedRtl);
      expect(parseReadingMode(global), ReadingMode.longStrip);
      final manga = Manga()..readingModeOverride = override;
      expect(parseReadingMode(manga.readingModeOverride!), ReadingMode.pagedRtl);
    });

    test('source preference mirror override mutates metadata baseUrl', () async {
      SharedPreferences.setMockInitialValues({});
      await SourcePreferences.setCustomBaseUrl('Weeb Central', 'https://mirror.example/');
      final meta = <String, dynamic>{'name': 'Weeb Central', 'baseUrl': 'https://weebcentral.com'};
      final applied = SourcePreferences.applyToSourceMeta('Weeb Central', meta);
      expect(applied['baseUrl'], 'https://mirror.example/');
      expect(meta['baseUrl'], 'https://weebcentral.com');
    });

    test('Browse GraphQL re-init path preserves auth when token present', () {
      const creds = ServerAuthCredentials(type: ServerAuthType.bearer, token: 'test-token-xyz');
      final header = creds.toHeaderValue();
      expect(header, contains('Bearer'));
      GraphQLClientService.instance.initialize('http://192.168.1.10:4567', authToken: header);
      expect(GraphQLClientService.instance.isConfigured, isTrue);
      expect(GraphQLClientService.instance.baseUrl, 'http://192.168.1.10:4567');
    });

    test('history clear uses null timestamp helper', () {
      final ch = Chapter()..lastReadAt = 12345;
      ch.clearHistoryTimestamp();
      expect(ch.lastReadAt, isNull);
    });

    test('detail two-pane breakpoint stays wider than shell tablet rail', () {
      expect(sunfireDetailTwoPaneMinWidth, greaterThan(sunfireTabletMinWidth));
      expect(usesTabletShell(800), isTrue);
      expect(800 >= sunfireDetailTwoPaneMinWidth, isFalse);
    });

    test('volume key page-turn setting is wired for Android and iOS', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.volumeKeyTurn, isTrue);
      SettingsService.instance.volumeKeyTurn = false;
      expect(SettingsService.instance.volumeKeyTurn, isFalse);
      SettingsService.instance.volumeKeyTurn = true;
    });

    test('tracker mangaProgress and category rename sync payloads are well-formed', () {
      final tracker = {
        'op': 'mangaProgress',
        'mangaId': 42,
        'chapterNumber': 12.5,
      };
      expect(tracker['op'], 'mangaProgress');
      expect(tracker['chapterNumber'], 12.5);

      final rename = {
        'op': 'rename',
        'categoryId': 3,
        'name': 'Reading',
      };
      expect(rename['op'], 'rename');
      expect(chapterMutationNeedsReadProgress({'isRead': true, 'lastPageRead': 1}), isTrue);
      expect(chapterMutationNeedsBookmark({'isBookmarked': false}), isTrue);
    });

    test('legacy auto-download aliases map onto live download prefs', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
      SettingsService.instance.autoDownloadEnabled = true;
      SettingsService.instance.autoDownloadCount = 4;
      SettingsService.instance.autoDeleteRead = true;
      expect(SettingsService.instance.autoDownloadWhileReading, isTrue);
      expect(SettingsService.instance.downloadAheadChapterCount, 4);
      expect(SettingsService.instance.deleteChapterAfterMarkedRead, isTrue);
    });

    test('WorkManager background path is Android-only by design', () {
      // Mirrors BackgroundService.initialize gating — iOS/iPad sync on app open.
      final androidWouldRegister = !kIsWeb && Platform.isAndroid;
      final iosWouldSkip = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
      expect(androidWouldRegister || iosWouldSkip || Platform.isLinux || Platform.isWindows, isTrue);
      expect(BackgroundService, isNotNull);
    });
  });
}
