import 'dart:convert';
import 'dart:io';

import 'package:catalyst/src/features/manga_book/data/local_downloads/local_downloads_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Points the app-documents directory at a real temp folder so the service can
/// be exercised against actual files.
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
  const chapterId = 42;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('catalyst_offline_test');
    PathProviderPlatform.instance = _TempPathProvider(tempRoot.path);
  });

  tearDown(() {
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  Directory chapterDir() => Directory(
        p.join(tempRoot.path, 'catalyst_offline', 'chapters', '$chapterId'),
      );

  /// Writes a manifest listing [pageNames] and creates only [presentPages].
  Future<void> writeChapter({
    required List<String> pageNames,
    required List<String> presentPages,
  }) async {
    final dir = chapterDir()..createSync(recursive: true);
    for (final name in presentPages) {
      File(p.join(dir.path, name)).writeAsBytesSync([1, 2, 3]);
    }
    File(p.join(dir.path, 'manifest.json')).writeAsStringSync(
      jsonEncode(
        OfflineChapterManifest(
          chapterId: chapterId,
          mangaId: 7,
          chapterName: 'Ch 1',
          chapterNumber: 1,
          mangaTitle: 'Test',
          pageCount: pageNames.length,
          pages: pageNames,
        ).toJson(),
      ),
    );
  }

  const allPages = ['0001.jpg', '0002.jpg', '0003.jpg', '0004.jpg'];

  test('a fully downloaded chapter returns every page in order', () async {
    await writeChapter(pageNames: allPages, presentPages: allPages);

    final pages = await service.getLocalPages(chapterId);

    expect(pages, isNotNull);
    expect(pages!.length, 4);
    expect(pages.every((p) => p != null), isTrue);
    expect(pages[0], contains('0001.jpg'));
    expect(pages[3], contains('0004.jpg'));
    expect(await service.isChapterDownloaded(chapterId), isTrue);
  });

  test('a missing page leaves a hole instead of shifting later pages',
      () async {
    // Page 2 never finished downloading.
    await writeChapter(
      pageNames: allPages,
      presentPages: const ['0001.jpg', '0003.jpg', '0004.jpg'],
    );

    final pages = await service.getLocalPages(chapterId);

    expect(pages, isNotNull);
    expect(
      pages!.length,
      4,
      reason: 'the list must stay aligned with the manifest',
    );
    expect(pages[1], isNull, reason: 'the missing page is a hole');
    expect(
      pages[2],
      contains('0003.jpg'),
      reason: 'page 3 must stay at index 2, not slide down to index 1',
    );
    expect(pages[3], contains('0004.jpg'));
  });

  test('a partially downloaded chapter does not count as downloaded', () async {
    await writeChapter(
      pageNames: allPages,
      presentPages: const ['0001.jpg', '0002.jpg'],
    );

    expect(await service.isChapterDownloaded(chapterId), isFalse);
  });

  test('a manifest with no files on disk reads as nothing downloaded',
      () async {
    await writeChapter(pageNames: allPages, presentPages: const []);

    expect(await service.getLocalPages(chapterId), isNull);
    expect(await service.isChapterDownloaded(chapterId), isFalse);
  });

  test('a chapter that was never downloaded has no pages', () async {
    expect(await service.getLocalPages(chapterId), isNull);
    expect(await service.getOfflineManifest(chapterId), isNull);
  });

  test('deleting a chapter removes its files', () async {
    await writeChapter(pageNames: allPages, presentPages: allPages);

    await service.deleteChapter(chapterId);

    expect(chapterDir().existsSync(), isFalse);
    expect(await service.getLocalPages(chapterId), isNull);
  });

  test('a corrupt manifest is treated as not downloaded, not a crash',
      () async {
    final dir = chapterDir()..createSync(recursive: true);
    File(p.join(dir.path, 'manifest.json')).writeAsStringSync('{not json');

    expect(await service.getOfflineManifest(chapterId), isNull);
    expect(await service.getLocalPages(chapterId), isNull);
  });
}
