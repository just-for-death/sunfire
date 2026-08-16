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

  group('ONBOARDING GATEKEEPER: One-Time Setup State', () {
    test('5. Default state reports onboarding is NOT completed', () async {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = await migrationService.isOnboardingCompleted(prefs);
      expect(isCompleted, isFalse);
    });

    test('6. Mark onboarding completed persists server URL, auth, and repos', () async {
      final prefs = await SharedPreferences.getInstance();

      await migrationService.markOnboardingCompleted(
        serverUrl: 'http://192.168.1.100:4567',
        authHeader: 'Bearer test_token_123',
        selectedRepos: ['m2k3a', 'Mallyd11', 'Swakshan'],
        prefs: prefs,
      );

      final isCompleted = await migrationService.isOnboardingCompleted(prefs);
      expect(isCompleted, isTrue);
      expect(prefs.getString(SourceMigrationService.keyServerUrl), equals('http://192.168.1.100:4567'));
      expect(prefs.getString(SourceMigrationService.keyServerAuth), equals('Bearer test_token_123'));
      expect(
        prefs.getStringList(SourceMigrationService.keySelectedRepos),
        equals(['m2k3a', 'Mallyd11', 'Swakshan']),
      );
    });

    test('7. Reset onboarding allows re-running setup if user switches server in settings', () async {
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
