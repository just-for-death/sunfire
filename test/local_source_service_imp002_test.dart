// IMP-002: LocalSourceService DB wiring + reader page resolution (fakes only).
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/local_source_service.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

class _FakeStore implements LocalLibraryStore {
  final manga = <int, Manga>{};
  final chapters = <int, Chapter>{};
  @override
  Future<List<Manga>> allManga() async => manga.values.toList();
  @override
  Future<Manga?> mangaByServerId(int serverId) async => manga[serverId];
  @override
  Future<void> saveManga(Manga m) async => manga[m.serverId] = m;
  @override
  Future<List<Chapter>> chaptersFor(int key) async => chapters.values.where((c) => c.mangaId == key).toList();
  @override
  Future<void> saveChapters(List<Chapter> list) async {
    for (final c in list) {
      chapters[c.serverId] = c;
    }
  }

  @override
  Future<void> deleteChapters(List<Chapter> list) async {
    for (final c in list) {
      chapters.remove(c.serverId);
    }
  }
}

void main() {
  late Directory tmp;
  late _FakeStore store;
  final svc = LocalSourceService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    tmp = await Directory.systemTemp.createTemp('imp002svc_');
    store = _FakeStore();
    svc
      ..debugStore = store
      ..debugCacheDir = Directory('${tmp.path}/cache');
    DownloadStorage.debugDocumentsDir = () async => Directory('${tmp.path}/docs');
  });
  tearDown(() async => tmp.delete(recursive: true));

  Future<void> img(String p) async {
    final f = File('${tmp.path}/$p');
    await f.parent.create(recursive: true);
    await f.writeAsBytes([1, 2, 3]);
  }

  test('setRoot/scan without a root reports an error and writes nothing', () async {
    expect(svc.root, isNull);
    final r = await svc.scan();
    expect(r.error, isNotNull);
    expect(store.manga, isEmpty);
  });

  test('scan creates local manga + chapters with negative ids and localfs: urls', () async {
    await img('lib/Solo/cover.jpg');
    await img('lib/Solo/Ch 1/1.jpg');
    await img('lib/Solo/Ch 2/1.jpg');
    await svc.setRoot('${tmp.path}/lib');
    final r = await svc.scan();
    expect(r.error, isNull);
    expect([r.manga, r.addedChapters, r.removedChapters], [1, 2, 0]);

    final lib = await svc.listLibrary();
    expect(lib.single.title, 'Solo');
    expect(lib.single.sourceName, kLocalSourceName);
    expect(lib.single.serverId, lessThan(0), reason: 'negative ids are never synced');
    expect(lib.single.thumbnailUrl, endsWith('cover.jpg'));
    final chs = await svc.chaptersFor(lib.single);
    expect(chs.map((c) => c.name), ['Ch 1', 'Ch 2']);
    expect(chs.every((c) => c.serverId < 0 && isLocalChapterUrl(c.url)), isTrue);
    expect(chs.every((c) => c.mangaId == lib.single.canonicalKey), isTrue);
  });

  test('rescan keeps read state and ids, adds new, removes vanished chapters', () async {
    await img('lib/S/Ch 1/1.jpg');
    await img('lib/S/Ch 2/1.jpg');
    await svc.setRoot('${tmp.path}/lib');
    await svc.scan();
    final m = (await svc.listLibrary()).single;
    final first = (await svc.chaptersFor(m)).first
      ..isRead = true
      ..lastPageRead = 5;
    final keptId = first.serverId;

    await Directory('${tmp.path}/lib/S/Ch 2').delete(recursive: true);
    await img('lib/S/Ch 3/1.jpg');
    final r = await svc.scan();
    expect([r.addedChapters, r.removedChapters], [1, 1]);
    final chs = await svc.chaptersFor(m);
    expect(chs.map((c) => c.name), ['Ch 1', 'Ch 3']);
    expect(chs.first.serverId, keptId);
    expect(chs.first.isRead, isTrue);
    expect(chs.first.lastPageRead, 5);
  });

  test('reader resolves a localfs: CBZ chapter to extracted file paths', () async {
    final a = Archive()
      ..addFile(ArchiveFile.bytes('2.jpg', [2]))
      ..addFile(ArchiveFile.bytes('1.jpg', [1]));
    final cbz = File('${tmp.path}/lib/S/Ch 1.cbz');
    await cbz.parent.create(recursive: true);
    await cbz.writeAsBytes(ZipEncoder().encode(a));

    final res = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: -123,
      chapterUrl: '$kLocalChapterUrlScheme${cbz.path}',
      sourceName: kLocalSourceName,
    );
    expect(res.isLocalFiles, isTrue);
    expect(res.effectiveSourceName, kLocalSourceName);
    expect(res.pageUrls.map((p) => p.split('/').last), ['0001_1.jpg', '0002_2.jpg']);
    expect(res.pageUrls.every((p) => File(p).existsSync()), isTrue);
  });

  test('an extension chapter cannot open a localfs: path outside the root', () async {
    await svc.setRoot('${tmp.path}/lib');
    final outside = Directory('${tmp.path}/private/Ch 1');
    await outside.create(recursive: true);
    await File('${outside.path}/1.jpg').writeAsBytes([1]);

    expect(svc.isUnderRoot('${tmp.path}/lib/S/Ch 1.cbz'), isTrue);
    expect(svc.isUnderRoot('${tmp.path}/lib/../private/Ch 1'), isFalse);
    expect(svc.isUnderRoot('${tmp.path}/library-other/x'), isFalse);
    await expectLater(
      ContentResolverService.instance.resolveChapterPages(
        chapterServerId: -124,
        chapterUrl: '$kLocalChapterUrlScheme${outside.path}',
        sourceName: 'Some Extension',
        allowLocalDownload: false,
      ),
      throwsException,
    );
  });
}
