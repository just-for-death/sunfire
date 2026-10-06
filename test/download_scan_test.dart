// UIX-04: the startup scan must register EVERY complete chapter folder,
// whatever its mtime. A WIP "incremental" scan skipped folders older than
// 7 days on its full pass, so old downloads lost their Downloaded badge.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/image_validation.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';

List<int> _jpeg(int bytes) {
  final out = List<int>.filled(bytes, 0x20);
  out.setAll(0, [0xFF, 0xD8, 0xFF, 0xE0]);
  out[bytes - 2] = 0xFF;
  out[bytes - 1] = 0xD9;
  return out;
}

Future<Directory> _chapter(Directory root, String name, {required int pages, bool marker = true}) async {
  final dir = await Directory('${root.path}/$name').create();
  for (var i = 1; i <= pages; i++) {
    await File('${dir.path}/${i.toString().padLeft(3, '0')}.jpg').writeAsBytes(_jpeg(2048));
  }
  if (marker) {
    await File('${dir.path}/$kDownloadCompleteMarkerName').writeAsString('$pages');
  }
  return dir;
}

Future<void> _age(FileSystemEntity e, String when) async {
  final res = await Process.run('touch', ['-d', when, e.path]);
  expect(res.exitCode, 0, reason: 'touch -d failed: ${res.stderr}');
}

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sunfire_dl_scan');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('old complete folders are registered; incomplete ones are not', () async {
    final old = await _chapter(root, '123', pages: 3);
    await for (final f in old.list()) {
      await _age(f, '10 days ago');
    }
    await _age(old, '10 days ago');
    expect(old.statSync().modified.isBefore(DateTime.now().subtract(const Duration(days: 9))), isTrue);

    await _chapter(root, '456', pages: 3, marker: false); // interrupted download
    await _chapter(root, '789', pages: 2); // fresh complete download
    await Directory('${root.path}/not-a-number').create();
    await File('${root.path}/321').writeAsString('a file, not a chapter folder');

    final ids = await DownloadManagerService.scanCompleteChapterFolders(root);
    expect(ids, {123, 789});
  });

  test('a missing downloads directory yields an empty set', () async {
    final ids = await DownloadManagerService.scanCompleteChapterFolders(Directory('${root.path}/nope'));
    expect(ids, isEmpty);
  });

  test('marker count that does not match the pages on disk is rejected', () async {
    final dir = await _chapter(root, '555', pages: 2);
    await File('${dir.path}/$kDownloadCompleteMarkerName').writeAsString('5');
    expect(await DownloadManagerService.scanCompleteChapterFolders(root), isEmpty);
  });
}
