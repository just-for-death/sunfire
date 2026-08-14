import 'dart:convert';
import 'dart:io';

import 'package:catalyst/src/features/manga_book/data/local_downloads/local_downloads_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _TempPathProvider extends PathProviderPlatform {
  _TempPathProvider(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  const service = LocalDownloadsService();

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('catalyst_offline_lib_');
    PathProviderPlatform.instance = _TempPathProvider(tempRoot.path);
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  Future<void> writeChapter({
    required int chapterId,
    required int mangaId,
    required String title,
    required List<String> pages,
    bool isRead = false,
  }) async {
    final dir = Directory(
      p.join(tempRoot.path, 'catalyst_offline', 'chapters', '$chapterId'),
    )..createSync(recursive: true);
    for (final name in pages) {
      File(p.join(dir.path, name)).writeAsBytesSync([1, 2, 3]);
    }
    File(p.join(dir.path, 'manifest.json')).writeAsStringSync(
      jsonEncode(
        OfflineChapterManifest(
          chapterId: chapterId,
          mangaId: mangaId,
          chapterName: 'Ch $chapterId',
          chapterNumber: chapterId.toDouble(),
          mangaTitle: title,
          pageCount: pages.length,
          pages: pages,
          isRead: isRead,
        ).toJson(),
      ),
    );
  }

  test('listOfflineManga builds stubs with title and unread counts', () async {
    await writeChapter(
      chapterId: 1,
      mangaId: 10,
      title: 'Offline Title',
      pages: const ['0001.jpg'],
      isRead: true,
    );
    await writeChapter(
      chapterId: 2,
      mangaId: 10,
      title: 'Offline Title',
      pages: const ['0001.jpg'],
    );
    await writeChapter(
      chapterId: 3,
      mangaId: 20,
      title: 'Other',
      pages: const ['0001.jpg'],
    );

    final list = await service.listOfflineManga();

    expect(list.map((m) => m.id), unorderedEquals([10, 20]));
    final first = list.firstWhere((m) => m.id == 10);
    expect(first.title, 'Offline Title');
    expect(first.downloadCount, 2);
    expect(first.unreadCount, 1);
    expect(first.thumbnailUrl, isNotNull);
    expect(first.thumbnailUrl, startsWith('file://'));
  });

  test('cached cover is preferred over the first page fallback', () async {
    await writeChapter(
      chapterId: 1,
      mangaId: 7,
      title: 'Covered',
      pages: const ['0001.jpg'],
    );
    await service.cacheCoverBytes(7, [9, 9, 9], extension: '.png');

    final cover = await service.getCoverUri(7);
    expect(cover, contains('covers/7.png'));
  });

  test('deleting the last chapter also removes the cached cover', () async {
    await writeChapter(
      chapterId: 1,
      mangaId: 7,
      title: 'Gone',
      pages: const ['0001.jpg'],
    );
    await service.cacheCoverBytes(7, [1, 2, 3], extension: '.jpg');
    expect(await service.getCachedCoverUri(7), isNotNull);

    await service.deleteChapter(1);

    expect(await service.hasOfflineManga(7), isFalse);
    expect(await service.getCachedCoverUri(7), isNull);
  });

  test('offline library category sentinel is distinct from real categories', () {
    expect(kOfflineLibraryCategoryId, lessThan(0));
  });
}
