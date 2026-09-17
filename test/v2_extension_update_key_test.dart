// v2 regression tests for the extension "update requires uninstall" bug.
//
// The installed-extension key was derived from *where the install came from*
// (repo display name, pkg file name, bundled asset file name), so updating from a
// repo item could silently create a second install under a different key while the
// old one lingered — and fuzzy lookups could then return the stale code/version.
// Fix: canonical extension identity + reconciliation in saveLocalExtension and
// variant-aware uninstall.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

const _tempRoot = '/tmp/sunfire_v2_ext_key_test';
const _extDir = '$_tempRoot/extensions';

Future<void> _writeLegacyInstall(String baseName, String version, String name) async {
  final dir = Directory(_extDir);
  if (!await dir.exists()) await dir.create(recursive: true);
  await File('$_extDir/$baseName.js').writeAsString(
    'const baseUrl="https://example.test";\n'
    'const name="$name";\n'
    'const version="$version";\n',
  );
  await File('$_extDir/$baseName.json').writeAsString(jsonEncode({
    'name': name,
    'version': version,
    'iconUrl': '',
  }));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => _tempRoot,
    );
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  tearDownAll(() {
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('EXTENSION IDENTITY', () {
    test('extensionIdentityKey collapses display-name and pkg-file-name forms', () {
      expect(QuickJsService.extensionIdentityKey('MangaDex'), 'mangadex');
      expect(QuickJsService.extensionIdentityKey('MangaDex (ALL)'), 'mangadex');
      expect(QuickJsService.extensionIdentityKey('Mangadex_en'), 'mangadex_en');
      expect(QuickJsService.extensionIdentityKey('ReadComicsOnline'), 'readcomicsonline');
      expect(QuickJsService.extensionIdentityKey('SubsPlease (JA)'), 'subsplease');
    });

    test('extensionVariantIdentityKey strips trailing lang/variant tokens', () {
      expect(QuickJsService.extensionVariantIdentityKey('MangaDex'), 'mangadex');
      expect(QuickJsService.extensionVariantIdentityKey('mangadex_all'), 'mangadex');
      expect(QuickJsService.extensionVariantIdentityKey('mangadex_en'), 'mangadex');
      expect(QuickJsService.extensionVariantIdentityKey('read_comics_online_en'), 'read_comics_online');
      expect(QuickJsService.extensionVariantIdentityKey('mangadex_all_en'), 'mangadex');
      // 'online' is not a language token — it must not be stripped.
      expect(QuickJsService.extensionVariantIdentityKey('read_comics_online'), 'read_comics_online');
    });

    test('sameExtensionIdentity matches across key styles and rejects unrelated', () {
      expect(QuickJsService.sameExtensionIdentity('MangaDex (ALL)', 'mangadex_all'), isTrue);
      expect(QuickJsService.sameExtensionIdentity('MangaDex', 'mangadex'), isTrue);
      expect(QuickJsService.sameExtensionIdentity('Mangago EN', 'mangago'), isTrue);
      expect(QuickJsService.sameExtensionIdentity('nhentai', 'read_comics_online'), isFalse);
      expect(QuickJsService.sameExtensionIdentity('mangahere', 'mangapill'), isFalse);
    });
  });

  group('EXTENSION UPDATE KEY RECONCILIATION', () {
    test('saveLocalExtension replaces a differently-keyed legacy install in memory', () async {
      final qjs = QuickJsService.instance;
      await _writeLegacyInstall('mangadex_all', '1.0.0', 'MangaDex');
      await qjs.initialize();

      // Legacy file-name-keyed install is visible under both query styles.
      expect(qjs.isLocalExtensionInstalled('MangaDex'), isTrue);
      expect(qjs.isLocalExtensionInstalled('mangadex_all'), isTrue);
      expect(qjs.getInstalledVersion('MangaDex'), '1.0.0');

      // Update arrives keyed by the repo display name → canonical key `mangadex`.
      final saved = await qjs.saveLocalExtension(
        'MangaDex (ALL)',
        'const baseUrl="https://example.test";\nconst version="2.0.0";\n',
        version: '2.0.0',
      );
      expect(saved, isTrue);

      // The legacy variant must be gone: exactly one install, canonical, new version.
      expect(qjs.getInstalledVersion('MangaDex'), '2.0.0');
      expect(qjs.getInstalledVersion('MangaDex (ALL)'), '2.0.0');
      expect(qjs.getInstalledVersion('mangadex'), '2.0.0');
      final names = qjs.getInstalledExtensionNames();
      expect(names.where((n) => n.toLowerCase().contains('mangadex')), hasLength(1));
      expect(names.any((n) => n == 'mangadex all'), isFalse,
          reason: 'legacy file-name display must be reconciled away');

      // And the stale files were removed from disk while the canonical one exists.
      expect(File('$_extDir/mangadex_all.js').existsSync(), isFalse,
          reason: 'stale variant file must be deleted on update');
      expect(File('$_extDir/mangadex_all.json').existsSync(), isFalse);
      expect(File('$_extDir/mangadex.js').existsSync(), isTrue,
          reason: 'canonical install must be persisted');
    });

    test('deleteLocalExtension removes every key variant (memory + disk)', () async {
      final qjs = QuickJsService.instance;
      await qjs.saveLocalExtension(
        'MangaDex',
        'const baseUrl="https://example.test";\nconst version="3.0.0";\n',
        version: '3.0.0',
      );
      await _writeLegacyInstall('mangadex_en', '2.5.0', 'MangaDex');
      await qjs.initialize();

      expect(qjs.getInstalledVersion('MangaDex'), '3.0.0',
          reason: 'highest identity-matching version must win');

      final deleted = await qjs.deleteLocalExtension('MangaDex (ALL)');
      expect(deleted, isTrue);
      expect(qjs.isLocalExtensionInstalled('MangaDex'), isFalse);
      expect(qjs.isLocalExtensionInstalled('mangadex_en'), isFalse);
      expect(File('$_extDir/mangadex.js').existsSync(), isFalse);
      expect(File('$_extDir/mangadex_en.js').existsSync(), isFalse);
    });
  });
}