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
  });
}
