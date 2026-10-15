// Multi-language Mangayomi scripts (MangaDex, Webtoons, Mangafire, ...) ship
// one .js for every language: the header declares `langs: [...]` and
// `ids: {lang: id}`, and the script reads `this.source.lang` at runtime.
// The header parser used to stringify the list, so MangaDex queried
// `availableTranslatedLanguage[]=[ar, bn, ...]` and got the Indonesian id.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

const _tempRoot = '/tmp/sunfire_lang_variant_test';
const _extDir = '$_tempRoot/extensions';

const _multiLangJs = '''
const mangayomiSources = [{
    "name": "MangaDex",
    "langs": ["ar", "en", "fr", "id"],
    "ids": {"ar": 11, "en": 22, "fr": 33, "id": 44},
    "baseUrl": "https://mangadex.org",
    "apiUrl": "https://api.mangadex.org",
    "iconUrl": "",
    "typeSource": "single",
    "version": "0.2.0",
    "pkgPath": "manga/src/all/mangadex.js"
}];
class DefaultExtension extends MProvider {}
''';

const _singleLangJs = '''
const mangayomiSources = [{
    "name": "Japscan",
    "lang": "fr",
    "id": 99,
    "baseUrl": "https://japscan.test",
    "version": "1.0.0"
}];
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final qjs = QuickJsService.instance;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => _tempRoot,
    );
    QuickJsService.testOnlyExtensionDirs = [_extDir];
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  tearDownAll(() async {
    await qjs.deleteLocalExtension('MangaDex');
    await qjs.deleteLocalExtension('Japscan');
    QuickJsService.testOnlyExtensionDirs = null;
    final dir = Directory(_tempRoot);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  group('extractSourceMetadata', () {
    test('a langs list resolves to one language and its id, not a stringified list', () {
      final meta = qjs.extractSourceMetadata(_multiLangJs);
      expect(meta['lang'], 'en');
      expect(meta['id'], 22);
      expect(meta['langs'], ['ar', 'en', 'fr', 'id']);
    });

    test('a requested language picks that variant', () {
      final meta = qjs.extractSourceMetadata(_multiLangJs, lang: 'FR');
      expect(meta['lang'], 'fr');
      expect(meta['id'], 33);
    });

    test('an unsupported request falls back to en', () {
      expect(qjs.extractSourceMetadata(_multiLangJs, lang: 'xx')['lang'], 'en');
    });

    test('single-language headers keep their declared lang and id', () {
      final meta = qjs.extractSourceMetadata(_singleLangJs);
      expect(meta['lang'], 'fr');
      expect(meta['id'], 99);
    });
  });

  group('installed language variant', () {
    test('is persisted, survives a reload, and drives the installed state', () async {
      expect(await qjs.saveLocalExtension('MangaDex (FR)', _multiLangJs, version: '0.2.0', lang: 'fr'), isTrue);
      expect(qjs.getInstalledLang('MangaDex'), 'fr');

      await qjs.initialize(); // reload from disk
      expect(qjs.getInstalledLang('MangaDex'), 'fr');
      expect(qjs.getSourceLang('MangaDex'), 'FR');
      expect(qjs.isVariantInstalled('MangaDex', 'fr'), isTrue);
      expect(qjs.isVariantInstalled('MangaDex', 'en'), isFalse);
    });

    test('installing another variant switches the language in place', () async {
      await qjs.saveLocalExtension('MangaDex', _multiLangJs, version: '0.2.0', lang: 'en');
      expect(qjs.getInstalledExtensionNames().where((n) => n == 'MangaDex'), hasLength(1));
      expect(qjs.getInstalledLang('MangaDex'), 'en');
      expect(qjs.isVariantInstalled('MangaDex', 'fr'), isFalse);
    });

    test('legacy installs without a recorded language resolve from the header', () async {
      await qjs.saveLocalExtension('Japscan', _singleLangJs, version: '1.0.0');
      expect(qjs.getInstalledLang('Japscan'), 'fr');
    });
  });

  test('langsCompatible treats en and all as one, everything else strictly', () {
    expect(QuickJsService.langsCompatible('en', 'all'), isTrue);
    expect(QuickJsService.langsCompatible('EN', 'en'), isTrue);
    expect(QuickJsService.langsCompatible('', 'fr'), isTrue);
    expect(QuickJsService.langsCompatible('fr', 'en'), isFalse);
    expect(QuickJsService.langsCompatible('pt', 'pt-br'), isFalse);
  });
}
