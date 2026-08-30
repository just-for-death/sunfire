import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/source_migration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SourceMigrationService migrationService;



  setUp(() {
    migrationService = SourceMigrationService.instance;
    SharedPreferences.setMockInitialValues({});
  });

  group('SOURCE MIGRATION SERVICE: Fuzzy Matching & Normalization', () {
    test('1. Normalizes source names by stripping language tags and symbols', () {
      expect(migrationService.normalizeSourceName('MangaDex (EN)'), equals('mangadex'));
      expect(migrationService.normalizeSourceName('Weeb Central [EN]'), equals('weeb central'));
      expect(migrationService.normalizeSourceName('MangaKatana (ALL) v1.4'), equals('mangakatana v14'));
      expect(migrationService.normalizeSourceName('Asura Scans'), equals('asura scans'));
    });

    test('2. Accurately matches common server sources to available Mangayomi JS extensions', () {
      final availableExtensions = [
        'mangadex.js',
        'weeb_central.js',
        'mangakatana.js',
        'asura_scans.js',
        'flame_scans.js',
        'reaper_scans.js',
      ];

      expect(
        migrationService.matchServerSourceToLocalJs('MangaDex (EN)', availableExtensions),
        equals('mangadex.js'),
      );
      expect(
        migrationService.matchServerSourceToLocalJs('Weeb Central (EN)', availableExtensions),
        equals('weeb_central.js'),
      );
      expect(
        migrationService.matchServerSourceToLocalJs('MangaKatana', availableExtensions),
        equals('mangakatana.js'),
      );
      expect(
        migrationService.matchServerSourceToLocalJs('Asura Scans (EN)', availableExtensions),
        equals('asura_scans.js'),
      );
      expect(
        migrationService.matchServerSourceToLocalJs('Flame Comics', availableExtensions),
        equals('flame_scans.js'),
      );
    });

    test('3. Returns null for unmatched server-only sources without throwing exceptions', () {
      final availableExtensions = ['mangadex.js', 'weeb_central.js'];
      final match = migrationService.matchServerSourceToLocalJs('Custom Obscure Source (JP)', availableExtensions);
      expect(match, isNull);
    });

    test('4. Full batch migration correctly categorizes matched vs server-only sources', () {
      final serverSources = [
        'MangaDex (EN)',
        'Weeb Central (EN)',
        'Asura Scans',
        'Obscure Private Server Source',
      ];
      final availableExtensions = [
        'mangadex.js',
        'weeb_central.js',
        'asura_scans.js',
      ];

      final sampleLibrary = [
        Manga()
          ..title = 'One Piece'
          ..sourceName = 'MangaDex (EN)',
        Manga()
          ..title = 'Solo Leveling'
          ..sourceName = 'Asura Scans',
        Manga()
          ..title = 'Custom Comic'
          ..sourceName = 'Obscure Private Server Source',
      ];

      final result = migrationService.migrateServerSources(
        serverSourceNames: serverSources,
        availableJsExtensions: availableExtensions,
        libraryManga: sampleLibrary,
      );

      expect(result.totalServerSources, equals(4));
      expect(result.matchedSources.length, equals(3));
      expect(result.matchedSources['MangaDex (EN)'], equals('mangadex.js'));
      expect(result.matchedSources['Weeb Central (EN)'], equals('weeb_central.js'));
      expect(result.matchedSources['Asura Scans'], equals('asura_scans.js'));
      expect(result.serverOnlySources, contains('Obscure Private Server Source'));
      expect(result.remappedMangaCount, equals(2));
      expect(result.hasLocalMatches, isTrue);
      expect(result.localMatchRatio, equals(0.75));
    });
  });

  group('UNIFIED SOURCES TAB: Deduplication & Missing Source Fallback', () {
    test('5. Deduplicates sources: hides server duplicate if local Mangayomi exists, shows only missing server source', () {
      final localInstalledExtensions = [
        'mangadex.js',
        'weeb_central.js',
      ];

      final serverInstalledSources = [
        ServerSourceItem(id: '1001', name: 'MangaDex (EN)', lang: 'en'),
        ServerSourceItem(id: '1002', name: 'Weeb Central (EN)', lang: 'en'),
        ServerSourceItem(id: '1003', name: 'Niche Japanese Raw Source', lang: 'ja'), // Missing in Mangayomi
      ];

      final displaySources = migrationService.filterDisplaySources(
        localInstalledExtensions: localInstalledExtensions,
        serverInstalledSources: serverInstalledSources,
      );

      // Should display exactly 3 sources: 2 Local Mangayomi + 1 Server Fallback
      expect(displaySources.length, equals(3));

      // Check Local Mangayomi sources
      final mangadex = displaySources.firstWhere((s) => s.id == 'local_js_mangadex');
      expect(mangadex.isLocalJs, isTrue);
      expect(mangadex.isServerFallback, isFalse);

      final weebCentral = displaySources.firstWhere((s) => s.id == 'local_js_weeb_central');
      expect(weebCentral.isLocalJs, isTrue);
      expect(weebCentral.isServerFallback, isFalse);

      // Check Server Fallback source
      final nicheSource = displaySources.firstWhere((s) => s.id == '1003');
      expect(nicheSource.name, equals('Niche Japanese Raw Source'));
      expect(nicheSource.isLocalJs, isFalse);
      expect(nicheSource.isServerFallback, isTrue);

      // Server versions of MangaDex and Weeb Central are strictly excluded
      expect(displaySources.any((s) => s.id == '1001'), isFalse);
      expect(displaySources.any((s) => s.id == '1002'), isFalse);
    });
  });

  group('DUAL-CHANNEL SOURCE INSTALLATION', () {
    test('6. Installing source available on server performs dual installation (App + Server)', () {
      final serverCatalog = [
        'MangaDex (EN)',
        'Weeb Central (EN)',
        'MangaKatana',
      ];

      final result = migrationService.checkAndInstallSourceDualChannel(
        jsExtensionName: 'mangadex.js',
        serverAvailableSourceNames: serverCatalog,
      );

      expect(result.isInstalledLocally, isTrue);
      expect(result.isAvailableOnServer, isTrue);
      expect(result.serverSourceName, equals('MangaDex (EN)'));
      expect(result.statusMessage, contains('Installed locally & synced with server'));
    });

    test('7. Installing source NOT available on server installs locally with clear status message', () {
      final serverCatalog = [
        'MangaDex (EN)',
      ];

      final result = migrationService.checkAndInstallSourceDualChannel(
        jsExtensionName: 'obscure_local_only.js',
        serverAvailableSourceNames: serverCatalog,
      );

      expect(result.isInstalledLocally, isTrue);
      expect(result.isAvailableOnServer, isFalse);
      expect(result.serverSourceName, isNull);
      expect(result.statusMessage, contains('Installed locally on device (Source not available on server repo)'));
    });
  });

  group('CONTINUOUS SERVER SOURCE REPLICATION & MANGA RE-MAPPING', () {
    test('8. Automatically detects newly installed server sources and installs local JS scrapers + remaps manga', () {
      final currentlyInstalledLocalJs = ['mangadex.js'];

      final currentServerSources = [
        ServerSourceItem(id: '1001', name: 'MangaDex (EN)', lang: 'en'), // already local
        ServerSourceItem(id: '1002', name: 'MangaKatana (EN)', lang: 'en'), // NEW server source with JS match
        ServerSourceItem(id: '1003', name: 'Rare Unscraped Raw Server Source', lang: 'ja'), // NEW server source without JS match
      ];

      final availableRepoExtensions = [
        'mangadex.js',
        'weeb_central.js',
        'mangakatana.js',
        'asura_scans.js',
      ];

      final attachedLibraryManga = [
        Manga()
          ..title = 'Katana Manga'
          ..sourceName = 'MangaKatana (EN)',
        Manga()
          ..title = 'Dex Manga'
          ..sourceName = 'local_js_mangadex',
      ];

      final report = migrationService.syncAndReplicateServerSources(
        currentServerInstalledSources: currentServerSources,
        currentlyInstalledLocalJs: currentlyInstalledLocalJs,
        availableMangayomiRepoExtensions: availableRepoExtensions,
        currentLibraryManga: attachedLibraryManga,
      );

      expect(report.hasChanges, isTrue);
      expect(report.newlyInstalledLocalScrapers, contains('mangakatana.js'));
      expect(report.newlyAddedServerFallbacks, contains('Rare Unscraped Raw Server Source'));
      expect(report.totalReplicatedManga, equals(1));

      // Assert that manga attached to MangaKatana is re-mapped to local JS ID
      final katanaManga = attachedLibraryManga.firstWhere((m) => m.title == 'Katana Manga');
      expect(katanaManga.sourceName, equals('local_js_mangakatana'));
    });
  });

  group('ONBOARDING GATEKEEPER: One-Time Setup State', () {
    test('9. Default state reports onboarding is NOT completed', () async {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = await migrationService.isOnboardingCompleted(prefs);
      expect(isCompleted, isFalse);
    });

    test('10. Mark onboarding completed persists server URL, auth, and repos', () async {
      final prefs = await SharedPreferences.getInstance();

      await migrationService.markOnboardingCompleted(
        serverUrl: 'http://192.168.1.100:4567',
        authHeader: null,
        selectedRepos: ['m2k3a', 'Mallyd11', 'Swakshan'],
        prefs: prefs,
      );

      final isCompleted = await migrationService.isOnboardingCompleted(prefs);
      expect(isCompleted, isTrue);
      expect(prefs.getString(SourceMigrationService.keyServerUrl), equals('http://192.168.1.100:4567'));
      expect(
        prefs.getStringList(SourceMigrationService.keySelectedRepos),
        equals(['m2k3a', 'Mallyd11', 'Swakshan']),
      );
    });

    test('11. Reset onboarding allows re-running setup if user switches server in settings', () async {
      final prefs = await SharedPreferences.getInstance();

      await migrationService.markOnboardingCompleted(
        serverUrl: 'http://192.168.1.100:4567',
        prefs: prefs,
      );
      expect(await migrationService.isOnboardingCompleted(prefs), isTrue);

      await migrationService.resetOnboarding(prefs);
      expect(await migrationService.isOnboardingCompleted(prefs), isFalse);
    });
  });
}
