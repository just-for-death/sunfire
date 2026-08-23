import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      return Directory.systemTemp.path;
    },
  );

  const repoUrl = 'https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/index.json';

  group('REPOSITORY & EXTENSION UPDATE TESTS', () {
    test('0. Verify RepoManager fetchRepoSources against repoUrl', () async {
      final sources = await RepoManager.instance.fetchRepoSources(repoUrl);
      expect(sources, isNotEmpty);
    });

    test('1. Compare versions semver logic', () {
      expect(RepoManager.compareVersions('1.1.1', '1.1.0'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.3', '1.0.2'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.1', '1.0.0'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(RepoManager.compareVersions('1.0.0', '1.0.1'), lessThan(0));
    });

    test('2. Download JS source code live from GitHub raw URL', () async {
      const sampleJsUrl = 'https://raw.githubusercontent.com/just-for-death/mangayomi-extensions/main/javascript/manga/src/en/webtoons.js';
      final jsCode = await RepoManager.instance.downloadJsSourceCode(sampleJsUrl);
      expect(jsCode, isNotNull);
      expect(jsCode!.length, greaterThan(1000));
      expect(jsCode.contains('DefaultExtension'), isTrue);
    });
  });
}
