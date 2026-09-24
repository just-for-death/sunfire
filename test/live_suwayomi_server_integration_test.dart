// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

const _liveUrl = 'http://localhost:4567';

void main() {
  HttpOverrides.global = _RealHttpOverrides();
  late bool up;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'server_url': _liveUrl,
      'sunfire_server_url': _liveUrl,
    });
    await SettingsService.instance.initialize();
    GraphQLClientService.instance.initialize(_liveUrl);
    up = await GraphQLClientService.instance.checkServerReachable(force: true);
    if (!up) {
      print('Suwayomi not at $_liveUrl — live tests will skip');
    }
  });

  setUp(() async {
    GraphQLClientService.instance.initialize(_liveUrl);
    if (up) {
      await GraphQLClientService.instance.checkServerReachable(force: true);
    }
  });
  group('LIVE SUWAYOMI SERVER INTEGRATION TESTS', () {
    test('1. Live Server Query: Fetch real server sources', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final data = await GraphQLClientService.instance.fetchSources();
      expect(data, isNotNull);
      expect(data!.containsKey('sources'), isTrue);

      final nodes = data['sources']['nodes'] as List<dynamic>;
      expect(nodes.isNotEmpty, isTrue);
      print('\n✓ [LIVE SUCCESS] Suwayomi returned ${nodes.length} active server sources!');
    });

    test('2. Live Server Query: Fetch real server extensions (installed & uninstalled)', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final data = await GraphQLClientService.instance.fetchExtensions();
      expect(data, isNotNull);
      expect(data!.containsKey('extensions'), isTrue);

      final nodes = data['extensions']['nodes'] as List<dynamic>;
      expect(nodes.isNotEmpty, isTrue);

      final installed = nodes.where((e) => e['isInstalled'] == true).toList();
      final available = nodes.where((e) => e['isInstalled'] != true).toList();

      print(
        '✓ [LIVE SUCCESS] Suwayomi returned ${nodes.length} total extensions: '
        '${installed.length} installed, ${available.length} available!',
      );
      expect(nodes.length, greaterThan(10));
    });

    test('3. Live Server Mutation: Test extension update mutation schema compatibility', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }

      final extensionsData = await GraphQLClientService.instance.fetchExtensions();
      String testId = 'eu.kanade.tachiyomi.extension.all.test_dummy';
      if (extensionsData != null && extensionsData['extensions']?['nodes'] != null) {
        final list = extensionsData['extensions']['nodes'] as List;
        if (list.isNotEmpty) {
          testId = list.first['pkgName'] ?? testId;
        }
      }

      final data = await GraphQLClientService.instance.query(
        r'''
        mutation($id: String!, $patch: UpdateExtensionPatchInput!) {
          updateExtension(input: { id: $id, patch: $patch }) {
            extension {
              pkgName
              isInstalled
            }
          }
        }
        ''',
        variables: {
          'id': testId,
          // Current Suwayomi schema uses install/uninstall/update booleans
          // (not legacy isInstalled). Use update:false as a no-op schema probe
          // against an installed extension when possible.
          'patch': {'update': false},
        },
        label: 'testMutation',
      );

      expect(data, isNotNull);
      print('✓ [LIVE SUCCESS] Suwayomi accepted UpdateExtensionPatchInput mutation schema!\n');
    });

    test('4. Live library + categories + trackers smoke', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final cats = await GraphQLClientService.instance.fetchCategories();
      final trackers = await GraphQLClientService.instance.fetchTrackers();
      expect(lib?['mangas']?['nodes'], isNotEmpty);
      expect(cats?['categories']?['nodes'], isNotEmpty);
      expect(trackers?['trackers']?['nodes'], isNotEmpty);
    });

    test('5. Live migration path: URL resolution creates a real server manga (with cleanup)', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      // This is exactly what _executeMigration's server-resolution/backfill does:
      // resolve source id, then resolve the manga on the server so a
      // local-extension migration stays server-synced.
      final webtoonsSourceId = await GraphQLClientService.instance.resolveServerSourceId('Webtoons');
      if (webtoonsSourceId == null) {
        markTestSkipped('Webtoons source not installed on this Suwayomi server');
        return;
      }
      print('✓ [LIVE] Resolved webtoons server source id: $webtoonsSourceId');

      // Grab a REAL entry from the source's latest catalog (its url may be
      // relative, e.g. /de/canvas/...), then resolve it back via
      // fetchMangaIdByUrl — the exact primitive migrations rely on.
      final browse = await GraphQLClientService.instance.fetchSourceManga(
        webtoonsSourceId,
        isLatest: true,
        page: 1,
      );
      final entries = (browse?['fetchSourceManga']?['mangas'] as List?) ?? const [];
      if (entries.isEmpty) {
        markTestSkipped('Webtoons source returned no catalog entries');
        return;
      }
      final probe = (entries.first as Map).cast<String, dynamic>();
      final probeUrl = (probe['url'] ?? '').toString();
      final probeTitle = (probe['title'] ?? '').toString();
      expect(probeUrl, isNotEmpty, reason: 'catalog entry should expose its url');

      final resolvedId = await GraphQLClientService.instance.fetchMangaIdByUrl(
        webtoonsSourceId,
        probeUrl,
        title: probeTitle,
      );
      print('✓ [LIVE] "$probeTitle" @ $probeUrl -> server manga id $resolvedId');
      expect(resolvedId, isNotNull,
          reason: 'URL resolution should yield a server manga id (addManga or search fallback)');
      expect(resolvedId!, greaterThan(0));

      try {
        // Details + chapter round-trip must succeed against the resolved record.
        final details = await GraphQLClientService.instance.fetchMangaDetails(resolvedId);
        expect(details, isNotNull);
        final chapters = await GraphQLClientService.instance.fetchMangaAndChapters(resolvedId);
        expect(chapters, isNotNull);

        // The migration adds the resolved manga to the server library — assert
        // the round trip, then clean up.
        await GraphQLClientService.instance.updateMangaLibraryState(resolvedId, true);
        final libIn = await GraphQLClientService.instance.fetchLibrary();
        final idsIn = ((libIn?['mangas']?['nodes'] as List?) ?? const [])
            .map((e) => (e as Map)['id'])
            .toList();
        expect(idsIn.contains(resolvedId), isTrue,
            reason: 'updated manga should appear in the server library');
      } finally {
        // Cleanup: pull the probe manga out of the user's library.
        await GraphQLClientService.instance.updateMangaLibraryState(resolvedId, false);
      }

      final lib = await GraphQLClientService.instance.fetchLibrary();
      final ids = ((lib?['mangas']?['nodes'] as List?) ?? const [])
          .map((e) => (e as Map)['id'])
          .toList();
      expect(ids.contains(resolvedId), isFalse,
          reason: 'probe manga must be removed from the server library after the test');
    });

    test('fetchMangaDetails merges ALL chapters via the paginated root query', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      // Pick any library manga that actually has chapters.
      final lib = await GraphQLClientService.instance.fetchLibrary();
      final mangas = ((lib?['mangas']?['nodes'] as List?) ?? const []);
      int? targetId;
      int? expectedTotal;
      for (final raw in mangas.take(40)) {
        final m = raw as Map;
        final id = parseIntSafe(m['id']);
        if (id <= 0) continue;
        final countRes = await GraphQLClientService.instance.query(
          'query { chapters(condition: { mangaId: $id }) { totalCount } }',
          label: 'test.chaptersTotal',
        );
        final total = parseIntSafe((countRes?['chapters'] as Map?)?['totalCount']);
        if (total > 0) {
          targetId = id;
          expectedTotal = total;
          break;
        }
      }
      if (targetId == null) {
        markTestSkipped('no library manga with chapters to paginate');
        return;
      }

      final details = await GraphQLClientService.instance.fetchMangaDetails(targetId);
      expect(details, isNotNull);
      expect(details!['manga'], containsPair('id', targetId),
          reason: 'manga block must survive the paginated detail fetch');
      final nodes = details['manga']?['chapters']?['nodes'] as List?;
      expect(nodes, isNotNull);
      expect(nodes!.length, expectedTotal,
          reason: 'chapters must be assembled from every page — a truncated default '
              'page would drop chapters of long series');
      print('✓ [LIVE] manga=$targetId chapters=${nodes.length} (all pages merged)');
    });
  });
}
