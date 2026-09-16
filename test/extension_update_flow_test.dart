// ignore_for_file: avoid_print
// End-to-end verification of the extension update pipeline:
//   1. The official repo index exposes the newest Mangago (1.3.3) to the app.
//   2. updateInstalledExtensions safely upgrades an older local install and
//      replaces the scraper code with the server-side fix (phantom "×" removal).
//   3. (Live, guarded) The running Suwayomi accepts the app's updateExtension
//      mutation shape (UpdateExtensionPatchInput { install, uninstall, update }).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

const _liveUrl = 'http://localhost:4567';

Future<bool> _serverUp(String base) async {
  try {
    final res = await http
        .post(
          Uri.parse('$base/api/graphql'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': '{ __typename }'}),
        )
        .timeout(const Duration(seconds: 3));
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp/sunfire_ext_update_test',
    );
  });

  group('EXTENSION UPDATE FLOW', () {
    test('official repo index exposes Mangago v1.3.3 to the app', () async {
      final sources = await RepoManager.instance.fetchRepoSources(RepoManager.officialIndexUrl);
      final mangago =
          sources.where((s) => s.name.trim().toLowerCase() == 'mangago').toList();
      expect(mangago, isNotEmpty, reason: 'Mangago must be listed in the official index');
      expect(mangago.first.version, '1.3.3');
      expect(mangago.first.sourceCodeUrl, contains('mangago.js'));

      final combined = await RepoManager.instance.fetchCombinedRepoSources([RepoManager.officialIndexUrl]);
      final best =
          combined.where((s) => s.name.trim().toLowerCase() == 'mangago').toList();
      expect(best, isNotEmpty);
      expect(best.first.version, '1.3.3');
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('local install safely upgrades Mangago 1.3.2 -> 1.3.3', () async {
      final qjs = QuickJsService.instance;
      await qjs.initialize();

      // Bundle a mock "old" 1.3.2 scraper derived from the bundled asset.
      final bundled = File('assets/extensions/mangago.js').readAsStringSync();
      final oldCode = bundled.replaceFirst('"1.3.3"', '"1.3.2"');
      await qjs.saveLocalExtension('Mangago', oldCode, version: '1.3.2');
      expect(qjs.getInstalledVersion('Mangago'), '1.3.2');

      // Run the same updater the app uses.
      final updated = await RepoManager.instance
          .updateInstalledExtensions([RepoManager.officialIndexUrl]);

      expect(qjs.getInstalledVersion('Mangago'), '1.3.3',
          reason: 'updater must pull the newer scraper from the official index');
      final freshCode = qjs.getExtensionCode('Mangago');
      expect(freshCode, isNotNull);
      expect(freshCode, contains("a[href*='/nbt/']"),
          reason: 'updated code must include the phantom-× fix');
      expect(freshCode, isNot(contains('#raws_table tr, tr')),
          reason: 'old bare-`tr` catch-all selector must be gone');
      expect(updated, greaterThanOrEqualTo(0));

      print('✅ Local upgrade Mangago 1.3.2 -> ${qjs.getInstalledVersion('Mangago')} (updated=$updated)');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('SERVER: Suwayomi extension update mutation', () {
    late bool up;

    setUpAll(() async {
      up = await _serverUp(_liveUrl);
      if (!up) print('Suwayomi not reachable at $_liveUrl — server group skips');
      GraphQLClientService.instance.initialize(_liveUrl);
    });

    test('live schema accepts updateExtension with UpdateExtensionPatchInput', () async {
      if (!up) {
        markTestSkipped('Suwayomi Docker not running on $_liveUrl');
        return;
      }
      Future<Map<String, dynamic>?> introspect(String query) async {
        final res = await http
            .post(
              Uri.parse('$_liveUrl/api/graphql'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'query': query}),
            )
            .timeout(const Duration(seconds: 10));
        return jsonDecode(res.body)['data'] as Map<String, dynamic>?;
      }

      final mutField = await introspect('{__type(name:"Mutation"){fields{name}}}');
      expect(mutField, isNotNull);
      final mutationNames = ((mutField?['__type'] as Map<String, dynamic>?)?['fields'] as List?)
              ?.map((f) => (f as Map)['name'])
              .toList() ??
          <Object?>[];
      expect(mutationNames, contains('updateExtension'));

      final patchField =
          await introspect('{__type(name:"UpdateExtensionPatchInput"){inputFields{name}}}');
      expect(patchField, isNotNull);
      final patchFields =
          ((patchField?['__type'] as Map<String, dynamic>?)?['inputFields'] as List?)
                  ?.map((f) => (f as Map)['name'])
                  .toList() ??
              <Object?>[];
      expect(patchFields, containsAll(<Object?>['install', 'uninstall', 'update']));

      // The app client executes the same mutation without throwing (unknown id is an
      // acceptable no-op, but the request must be well-formed against the live schema).
      final client = GraphQLClientService.instance;
      expect(() => client.updateExtension('__sunfire_nonexistent__', 'UPDATE'),
          returnsNormally);
      print('✅ Live Suwayomi updateExtension mutation shape verified');
    }, timeout: const Timeout(Duration(minutes: 1)));
  });
}