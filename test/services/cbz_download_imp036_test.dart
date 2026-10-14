// IMP-036: finished local downloads stored as CBZ.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/image_validation.dart';
import 'package:sunfire/src/core/engine/local_source_service.dart';
import 'package:sunfire/src/core/services/cbz_packer.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

// Minimal valid PNG header + padding so looksLikeImageFile accepts it.
List<int> _png(int seed) => [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(600, seed)];

void main() {
  late Directory tmp;
  late Directory chapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    tmp = await Directory.systemTemp.createTemp('imp036_');
    DownloadStorage.debugDocumentsDir = () async => Directory('${tmp.path}/docs');
    LocalSourceService.instance.debugCacheDir = Directory('${tmp.path}/cache');
    chapter = Directory('${tmp.path}/docs/downloads/77');
    await chapter.create(recursive: true);
    for (var i = 1; i <= 3; i++) {
      await File('${chapter.path}/page_00$i.png').writeAsBytes(_png(i));
    }
    await File('${chapter.path}/$kDownloadCompleteMarkerName').writeAsString('3');
  });
  tearDown(() async => tmp.delete(recursive: true));

  test('setting defaults off', () {
    expect(SettingsService.instance.downloadAsCbz, isFalse);
  });

  test('pack → loose pages removed, folder still complete, reader gets ordered files', () async {
    expect(await isDownloadFolderComplete(chapter), isTrue);
    expect(await packChapterFolderAsCbz(chapter), 3);
    final names = chapter.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {kChapterCbzName, kDownloadCompleteMarkerName});
    expect(await isDownloadFolderComplete(chapter), isTrue);

    final res = await ContentResolverService.instance.resolveChapterPages(chapterServerId: 77, sourceName: 'x');
    expect(res.source, ContentSourceType.localDownload);
    expect(res.isLocalFiles, isTrue);
    expect(res.pageUrls.map((p) => p.split('/').last), ['0001_page_001.png', '0002_page_002.png', '0003_page_003.png']);
    expect(await File(res.pageUrls[1]).readAsBytes(), _png(2));
  });

  test('nothing to pack leaves the folder untouched; empty archive is not complete', () async {
    final empty = await Directory('${tmp.path}/e').create();
    expect(await packChapterFolderAsCbz(empty), 0);
    expect(empty.listSync(), isEmpty);
    await File('${empty.path}/$kDownloadCompleteMarkerName').writeAsString('2');
    await File('${empty.path}/$kChapterCbzName').writeAsBytes([]);
    expect(await isDownloadFolderComplete(empty), isFalse);
  });
}
