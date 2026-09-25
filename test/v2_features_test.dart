// v2.0.0 feature tests — pure/seam-level coverage for the roadmap items that
// don't require a live server, Isar, or a device: `.tachibk` parsing + import
// planning, extension sha256 verification, auth-error classification,
// background-interrupt notification copy, language badge/filter helpers, and
// the failed-sync retry no-op when the database is unavailable.
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/backup/tachibk_import_service.dart';
import 'package:sunfire/src/core/backup/tachibk_parser.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';
import 'package:sunfire/src/core/services/notification_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

Uint8List _buildTachiBk(Map<String, dynamic> backup) {
  final archive = Archive()
    ..add(ArchiveFile.string('Tachiyomi/backup.json', jsonEncode(backup)));
  return ZipEncoder().encodeBytes(archive);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TachiBkParser', () {
    test('parses sources, categories and manga from a .tachibk archive', () {
      final bytes = _buildTachiBk({
        'backupSources': [
          {'id': 1, 'name': 'MangaDex', 'lang': 'en'},
          {'id': 99, 'name': 'Missing Source', 'lang': 'es'},
        ],
        'backupCategories': [
          {'name': 'Favorites'},
          {'name': 'Reading'},
        ],
        'backupManga': [
          {
            'source': 1,
            'url': '/manga/alpha',
            'title': 'Alpha',
            'lang': 'en',
            'favorite': 1,
            'categories': ['Favorites'],
          },
          {
            'source': 99,
            'url': '/manga/beta',
            'title': 'Beta',
            'lang': 'es',
            'favorite': true,
            'categories': ['Reading'],
          },
        ],
      });

      final backup = TachiBkParser.parseBytes(bytes);

      expect(backup.sources, hasLength(2));
      expect(backup.sources.first.name, 'MangaDex');
      expect(backup.sources.first.lang, 'en');
      expect(backup.categories, ['Favorites', 'Reading']);
      expect(backup.manga, hasLength(2));
      expect(backup.manga.first.sourceId, 1);
      expect(backup.manga.first.favorite, isTrue);
      expect(backup.manga.first.categories, ['Favorites']);
      expect(backup.manga.last.favorite, isTrue); // boolean form is accepted too
    });

    test('throws a descriptive error for a non-zip payload', () {
      expect(
        () => TachiBkParser.parseBytes(Uint8List.fromList(utf8.encode('not a zip'))),
        throwsA(isA<TachiBkParseException>()),
      );
    });

    test('throws when the archive has no backup.json', () {
      final archive = Archive()..add(ArchiveFile.string('readme.txt', 'nothing here'));
      expect(
        () => TachiBkParser.parseBytes(ZipEncoder().encodeBytes(archive)),
        throwsA(isA<TachiBkParseException>()),
      );
    });
  });

  group('TachiBkImportService.planImport', () {
    final backup = TachiBkBackup(
      sources: const [
        TachiBkSource(id: 1, name: 'MangaDex', lang: 'en'),
        TachiBkSource(id: 99, name: 'Missing Source', lang: 'es'),
      ],
      categories: const ['Favorites', 'Reading'],
      manga: const [
        TachiBkManga(
          sourceId: 1,
          url: '/manga/alpha',
          title: 'Alpha',
          lang: 'en',
          favorite: true,
          categories: ['Favorites'],
        ),
        TachiBkManga(
          sourceId: 99,
          url: '/manga/beta',
          title: 'Beta',
          lang: 'es',
          favorite: true,
          categories: ['Reading'],
        ),
        TachiBkManga(
          sourceId: 1,
          url: '/manga/gamma',
          title: 'Gamma',
          lang: 'en',
          favorite: true,
          categories: [],
        ),
        TachiBkManga(
          sourceId: 1,
          url: '/manga/delta',
          title: 'Delta',
          lang: 'en',
          favorite: false,
          categories: ['Reading'],
        ),
      ],
    );

    final serverSources = const [
      ServerSourceInfo(id: '1:111', name: 'MangaDex', displayName: 'MangaDex', lang: 'en'),
      ServerSourceInfo(id: '2:222', name: 'Some Other', displayName: 'Some Other', lang: 'fr'),
    ];

    test('matches installed sources by name+lang and flags missing ones', () {
      final plan = TachiBkImportService.planImport(backup, serverSources);

      expect(plan.entries, hasLength(4));
      // Alpha and Gamma match a server source and are in the library.
      expect(plan.readyEntries, hasLength(2));
      // Beta has no matching source; Delta is favorited=false (not in library).
      expect(plan.skippedEntries, hasLength(2));
      expect(plan.skippedEntries.map((e) => e.manga.title), containsAll(['Beta', 'Delta']));
      expect(plan.readyEntries.every((e) => e.matchedSource?.id == '1:111'), isTrue);
    });

    test('collects categories to create only from matched, included manga', () {
      final plan = TachiBkImportService.planImport(backup, serverSources);
      // 'Reading' is referenced only by Delta (favorite=false) and Beta
      // (no matching source) — neither is imported, so it must not be created.
      expect(plan.categoriesToCreate, ['Favorites']);
    });

    test('unchecking an entry removes it from the import set', () {
      final plan = TachiBkImportService.planImport(backup, serverSources);
      final alpha = plan.entries.firstWhere((e) => e.manga.title == 'Alpha');
      alpha.include = false;

      expect(plan.readyEntries.map((e) => e.manga.title), ['Gamma']);
      expect(plan.skippedEntries.map((e) => e.manga.title), contains('Alpha'));
    });

    test('displayName is used as a fallback match', () {
      final plan = TachiBkImportService.planImport(
        backup,
        const [ServerSourceInfo(id: '9:9', name: 'md', displayName: 'MangaDex', lang: 'en')],
      );
      expect(plan.readyEntries, hasLength(2));
    });
  });

  group('RepoManager.verifySha256 (extension integrity)', () {
    final content = 'const baseUrl = "https://example.test";';
    final digest = sha256.convert(utf8.encode(content)).toString();

    test('accepts a matching digest, case-insensitively', () {
      expect(RepoManager.verifySha256(content, digest), isTrue);
      expect(RepoManager.verifySha256(content, digest.toUpperCase()), isTrue);
    });

    test('rejects a mismatched digest', () {
      expect(RepoManager.verifySha256(content, 'deadbeef'), isFalse);
    });

    test('treats an empty declaration as "no hash to verify"', () {
      expect(RepoManager.verifySha256(content, ''), isTrue);
      expect(RepoManager.verifySha256(content, '   '), isTrue);
    });
  });

  group('GraphQLClientService auth errors (A1)', () {
    test('notifyAuthError / clearAuthError toggle hasAuthError', () {
      final client = GraphQLClientService.instance;
      client.clearAuthError();
      expect(client.hasAuthError, isFalse);

      client.notifyAuthError();
      expect(client.hasAuthError, isTrue);

      client.clearAuthError();
      expect(client.hasAuthError, isFalse);
    });
  });

  group('DownloadManagerService background interruption (B1)', () {
    test('predicate only marks active queues as interrupted', () {
      expect(
        DownloadManagerService.backgroundInterruptsDownloads(isProcessing: true, hasActiveDownloads: false),
        isTrue,
      );
      expect(
        DownloadManagerService.backgroundInterruptsDownloads(isProcessing: false, hasActiveDownloads: true),
        isTrue,
      );
      expect(
        DownloadManagerService.backgroundInterruptsDownloads(isProcessing: false, hasActiveDownloads: false),
        isFalse,
      );
    });

    test('consumeBackgroundInterrupted reports once then resets', () {
      final mgr = DownloadManagerService.instance;
      mgr.debugSetBackgroundInterrupted(true);
      expect(mgr.consumeBackgroundInterrupted(), isTrue);
      expect(mgr.consumeBackgroundInterrupted(), isFalse);
    });
  });

  group('NotificationService.downloadsResumedSummary (B1)', () {
    test('singular copy for a single paused download', () {
      final summary = NotificationService.downloadsResumedSummary(queuedCount: 1);
      expect(summary.title, 'Downloads resumed');
      expect(summary.body, contains('1 download'));
    });

    test('plural copy for multiple paused downloads', () {
      final summary = NotificationService.downloadsResumedSummary(queuedCount: 4);
      expect(summary.body, contains('4 downloads'));
    });
  });

  group('SettingsService language helpers (C1)', () {
    test('languageMatchesFilter passes everything for all/empty', () {
      expect(SettingsService.languageMatchesFilter('es', ['all']), isTrue);
      expect(SettingsService.languageMatchesFilter('es', []), isTrue);
    });

    test('languageMatchesFilter keeps unknown-language entries visible', () {
      expect(SettingsService.languageMatchesFilter('', ['en', 'es']), isTrue);
    });

    test('languageMatchesFilter hides unselected languages', () {
      expect(SettingsService.languageMatchesFilter('fr', ['en', 'es']), isFalse);
      expect(SettingsService.languageMatchesFilter('es', ['en', 'es']), isTrue);
    });

    test('languageBadgeLabel skips default/universal labels', () {
      expect(SettingsService.languageBadgeLabel('en'), isNull);
      expect(SettingsService.languageBadgeLabel('ALL'), isNull);
      expect(SettingsService.languageBadgeLabel('multi'), isNull);
      expect(SettingsService.languageBadgeLabel(''), isNull);
      expect(SettingsService.languageBadgeLabel('Spanish'), 'SPANIS');
      expect(SettingsService.languageBadgeLabel('es'), 'ES');
    });
  });

  group('SyncEngine.retryFailedSyncRecords (A2)', () {
    test('is a safe no-op when the database is unavailable', () async {
      expect(await SyncEngine.instance.retryFailedSyncRecords(), 0);
    });
  });
}