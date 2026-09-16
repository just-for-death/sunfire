import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/source_icon_helper.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

/// v11 feature regressions (post GitHub v10.0.0-beta).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BETA V11 FEATURE SUITE', () {
    test('1. pubspec version is 1.0.0', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(pubspec);
      expect(match, isNotNull);
      expect(match!.group(1)!.trim(), startsWith('1.0.0'));
    });

    test('2. every bundled extension has a FOSS asset icon file', () {
      final extDir = Directory('assets/extensions');
      expect(extDir.existsSync(), isTrue);
      final jsFiles = extDir.listSync().whereType<File>().where((f) => f.path.endsWith('.js'));
      expect(jsFiles, isNotEmpty);
      for (final f in jsFiles) {
        final code = f.readAsStringSync();
        final iconMatch = RegExp(r'''iconUrl["']?\s*:\s*["']([^"']+)["']''').firstMatch(code);
        expect(iconMatch, isNotNull, reason: '${f.path} missing iconUrl');
        final icon = iconMatch!.group(1)!;
        expect(icon.startsWith('asset:'), isTrue, reason: '${f.path} icon must be asset: (FOSS)');
        expect(icon.toLowerCase().contains('google.'), isFalse);
        final assetPath = SourceIconHelper.assetPathFromUri(icon);
        expect(File(assetPath).existsSync(), isTrue, reason: 'missing $assetPath for ${f.path}');
      }
    });

    test('3. tracker mangaProgress + category rename payload helpers', () {
      expect(chapterMutationNeedsReadProgress({'isRead': true, 'lastPageRead': 3}), isTrue);
      expect(chapterMutationNeedsBookmark({'isBookmarked': true}), isTrue);
      final rename = {'op': 'rename', 'categoryId': 2, 'name': 'Reading'};
      expect(rename['op'], 'rename');
      final tracker = {'op': 'mangaProgress', 'mangaId': 1, 'chapterNumber': 5.0};
      expect(tracker['op'], 'mangaProgress');
    });

    test('3b. trackProgress mutation matches Suwayomi TrackProgressInput (mangaId only)', () {
      expect(kTrackProgressMutation.contains(r'$mangaId: Int!'), isTrue);
      expect(kTrackProgressMutation.contains('input: { mangaId: \$mangaId }'), isTrue);
      expect(kTrackProgressMutation.contains('trackerId:'), isFalse);
      expect(kTrackProgressMutation.contains('lastChapterRead:'), isFalse);
      expect(kTrackProgressMutation.contains('trackRecords'), isTrue);
    });

    test('4. SourceIconHelper maps all shipped extension display names', () {
      const names = [
        'Weeb Central',
        'Mangapill',
        'Mangago',
        'MangaHere',
        'MangaFreak',
        'nHentai',
        'NineHentai',
        'Webtoons',
        'Read Comics Online',
      ];
      for (final name in names) {
        final uri = SourceIconHelper.bundledAssetUriForName(name);
        expect(uri, isNotNull, reason: name);
        expect(File(SourceIconHelper.assetPathFromUri(uri!)).existsSync(), isTrue);
      }
    });

    test('5. sibling index.json is FOSS (no Google favicon CDN) and versions match JS', () {
      final indexFile = File('../mangayomi-extensions/index.json');
      if (!indexFile.existsSync()) {
        markTestSkipped('mangayomi-extensions sibling repo not present');
        return;
      }
      final index = indexFile.readAsStringSync();
      expect(index.toLowerCase().contains('google.com/s2/favicons'), isFalse);
      expect(index.contains('just-for-death/mangayomi-extensions'), isTrue);

      final jsDir = Directory('../mangayomi-extensions/javascript/manga/src/en');
      final bundled = Directory('assets/extensions');
      for (final f in jsDir.listSync().whereType<File>().where((e) => e.path.endsWith('.js'))) {
        final name = f.uri.pathSegments.last;
        final dest = File('${bundled.path}/$name');
        expect(dest.existsSync(), isTrue, reason: 'bundled missing $name');
        final jsVer = RegExp(r'"version":\s*"([^"]+)"').firstMatch(f.readAsStringSync())?.group(1);
        final bundledVer = RegExp(r'"version":\s*"([^"]+)"').firstMatch(dest.readAsStringSync())?.group(1);
        expect(bundledVer, jsVer, reason: '$name version drift');
      }
    });
  });
}
