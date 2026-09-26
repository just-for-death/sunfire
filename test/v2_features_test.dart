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
    final backupSources = const [
      TachiBkSource(id: 1, name: 'MangaDex', lang: 'en'),
      TachiBkSource(id: 99, name: 'Missing Source', lang: 'es'),
      TachiBkSource(id: 7, name: 'Absent Extension', lang: 'en'),
      TachiBkSource(id: 8, name: 'Fehlende Erweiterung', lang: 'de'),
    ];

    final backup = TachiBkBackup(
      sources: backupSources,
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
        // Source 7 exists in the backup but is NOT installed on the server.
        // Epsilon is English, which is exactly the case the old lang-only
        // fallback mis-handled by binding it to the first English source.
        TachiBkManga(
          sourceId: 7,
          url: '/manga/epsilon',
          title: 'Epsilon',
          lang: 'en',
          favorite: true,
          categories: [],
        ),
        // Zeta: unknown source AND non-English. The old fallback required
        // lang == 'en', so this one was skipped by accident rather than by
        // design — the test pins that both behave the same way.
        TachiBkManga(
          sourceId: 8,
          url: '/manga/zeta',
          title: 'Zeta',
          lang: 'de',
          favorite: true,
          categories: [],
        ),
      ],
    );

    final serverSources = const [
      ServerSourceInfo(id: '1:111', name: 'MangaDex', displayName: 'MangaDex', lang: 'en'),
      ServerSourceInfo(id: '2:222', name: 'Some Other', displayName: 'Some Other', lang: 'fr'),
    ];

    test('matches installed sources by name+lang and flags missing ones', () {
      final plan = TachiBkImportService.planImport(backup, serverSources);

      expect(plan.entries, hasLength(6));
      // Alpha and Gamma match a server source and are in the library.
      expect(plan.readyEntries, hasLength(2));
      // Beta, Epsilon and Zeta have no matching source; Delta is
      // favorite=false (not in the library).
      expect(plan.skippedEntries, hasLength(4));
      expect(
        plan.skippedEntries.map((e) => e.manga.title),
        containsAll(['Beta', 'Delta', 'Epsilon', 'Zeta']),
      );
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
      // Alpha and Gamma (plus Epsilon? no — Epsilon's backup source name is
      // 'Absent Extension', which still has no match here).
      expect(plan.readyEntries.map((e) => e.manga.title), ['Alpha', 'Gamma']);
    });

    // ── Source mis-attribution during restore ────────────────────────────
    //
    // A lang-only fallback used to run when neither the name nor the
    // displayName matched. Its condition required the server source's lang to
    // equal the backup entry's lang AND to be literally 'en', so it could only
    // ever fire for English — and then it returned the FIRST English source on
    // the server, whatever that happened to be.
    //
    // The consequence was silent mis-attribution, which is worse than a skip:
    // the entry was marked `ready`, so the plan screen showed it as importable
    // and counted it in "N importable". applyPlan then resolved the manga URL
    // against a source the user never had that series on. The restore either
    // failed with a confusing "could not resolve on <wrong source>" message, or
    // — for aggregator sources that do serve many sites — added the WRONG
    // series to the library. Either way the user was told the restore
    // succeeded for an entry that was silently pointed at the wrong source.
    //
    // An unmatched source must be reported as missing so the user sees it.

    test('an unmatched source is never guessed from language alone', () {
      final plan = TachiBkImportService.planImport(
        backup,
        const [
          ServerSourceInfo(id: '1:111', name: 'MangaDex', displayName: 'MangaDex', lang: 'en'),
          ServerSourceInfo(id: '2:222', name: 'Totally Different', displayName: 'Totally Different', lang: 'en'),
        ],
      );

      // Gamma is lang 'en' with source name 'MangaDex' -> exact match, fine.
      // Epsilon is lang 'en' with a source name that exists nowhere on the
      // server. It must NOT be silently bound to 'MangaDex'.
      final epsilon = plan.entries.firstWhere((e) => e.manga.title == 'Epsilon');
      expect(epsilon.status, TachiBkPlanEntryStatus.sourceMissing,
          reason: 'a lang-only match is a guess, not a match');
      expect(epsilon.matchedSource, isNull);
    });

    test('an unmatched non-English source is reported missing, not re-homed', () {
      final plan = TachiBkImportService.planImport(
        backup,
        const [
          ServerSourceInfo(id: '1:111', name: 'MangaDex', displayName: 'MangaDex', lang: 'en'),
        ],
      );

      for (final title in ['Epsilon', 'Zeta']) {
        final entry = plan.entries.firstWhere((e) => e.manga.title == title);
        expect(entry.status, TachiBkPlanEntryStatus.sourceMissing, reason: title);
        expect(entry.matchedSource, isNull, reason: title);
      }
    });

    test('a lang-only match never binds an entry to a different source', () {
      // Every importable entry must be bound to the source it actually came
      // from. This is the invariant the old fallback violated.
      final plan = TachiBkImportService.planImport(backup, serverSources);
      for (final entry in plan.readyEntries) {
        final expectedName = backup.sources
            .firstWhere((s) => s.id == entry.manga.sourceId)
            .name
            .toLowerCase();
        expect(
          entry.matchedSource!.name.toLowerCase(),
          expectedName,
          reason: '${entry.manga.title} was bound to the wrong source',
        );
      }
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