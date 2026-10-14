// IMP-002: LocalSource engine (image folders + CBZ).
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/local_source.dart';

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('imp002_'));
  tearDown(() async => tmp.delete(recursive: true));

  Future<void> img(String p) async {
    final f = File('${tmp.path}/$p');
    await f.parent.create(recursive: true);
    await f.writeAsBytes([1, 2, 3]);
  }

  Future<void> cbz(String p, List<String> names) async {
    final a = Archive();
    for (final n in names) {
      a.addFile(ArchiveFile.bytes(n, n.codeUnits));
    }
    final f = File('${tmp.path}/$p');
    await f.parent.create(recursive: true);
    await f.writeAsBytes(ZipEncoder().encode(a));
  }

  test('naturalCompare and chapter numbers', () {
    final l = ['p10.jpg', 'p2.jpg', 'P1.jpg']..sort(naturalCompare);
    expect(l, ['P1.jpg', 'p2.jpg', 'p10.jpg']);
    expect(parseLocalChapterNumber('Vol.2 Ch. 12.5 - Title.cbz'), 12.5);
    expect(parseLocalChapterNumber('Chapter 3'), 3);
    expect(parseLocalChapterNumber('007'), 7);
    expect(parseLocalChapterNumber('Extras'), isNull);
  });

  test('lists manga with covers and chapters in reading order', () async {
    await img('Root/Beta/cover.png');
    await img('Root/Beta/Ch 10/1.jpg');
    await img('Root/Beta/Ch 2/1.jpg');
    await Directory('${tmp.path}/Root/Beta/empty').create(recursive: true);
    await cbz('Root/Beta/Ch 5.cbz', ['1.jpg']);
    await img('Root/Alpha/Ch 1/1.jpg');
    await img('Root/.hidden/Ch 1/1.jpg');

    final src = LocalSource(Directory('${tmp.path}/Root'));
    final manga = await src.listManga();
    expect(manga.map((m) => m.title), ['Alpha', 'Beta']);
    expect(manga[1].coverPath, endsWith('cover.png'));
    expect(manga[0].coverPath, isNull);
    final ch = await src.listChapters(manga[1]);
    expect(ch.map((c) => c.name), ['Ch 2', 'Ch 5.cbz', 'Ch 10']);
    expect(ch[1].isArchive, isTrue);
    expect(await LocalSource(Directory('${tmp.path}/missing')).listManga(), isEmpty);
  });

  test('image-folder pages are naturally sorted, non-images ignored', () async {
    for (final n in ['10.jpg', '2.jpg', '1.webp', 'notes.txt', '.DS_Store']) {
      await File('${tmp.path}/M/C/$n').create(recursive: true);
    }
    final pages = await LocalSource(tmp).pagePaths(
      LocalChapter(name: 'C', path: '${tmp.path}/M/C', isArchive: false),
      cacheDir: Directory('${tmp.path}/cache'),
    );
    expect(pages.map((p) => p.split('/').last), ['1.webp', '2.jpg', '10.jpg']);
  });

  test('CBZ pages extract once, flattened (no zip-slip), junk skipped', () async {
    await cbz('M/c.cbz', ['p10.jpg', 'p2.jpg', '../../evil.png', '__MACOSX/p1.jpg', 'info.xml']);
    final ch = LocalChapter(name: 'c.cbz', path: '${tmp.path}/M/c.cbz', isArchive: true);
    final cache = Directory('${tmp.path}/cache');
    final pages = await LocalSource(tmp).pagePaths(ch, cacheDir: cache);
    expect(pages.map((p) => p.split('/').last), ['0001_evil.png', '0002_p2.jpg', '0003_p10.jpg']);
    for (final p in pages) {
      expect(p, startsWith(cache.path));
    }
    expect(File('${tmp.path}/evil.png').existsSync(), isFalse);
    // Second call is served from the cache.
    expect(await LocalSource(tmp).pagePaths(ch, cacheDir: cache), pages);
  });

  test('a corrupt archive raises LocalSourceException', () async {
    await File('${tmp.path}/bad.cbz').writeAsString('not a zip');
    expect(
      LocalSource(tmp).pagePaths(LocalChapter(name: 'bad.cbz', path: '${tmp.path}/bad.cbz', isArchive: true),
          cacheDir: Directory('${tmp.path}/cache')),
      throwsA(isA<LocalSourceException>()),
    );
  });
}
