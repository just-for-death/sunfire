// UIS-06: async memoised local cover path — no sync I/O in cover build().
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/image_cache_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_cover_cache_');
    ImageCacheHelper.debugSetCandidateCoverPaths([tempDir.path]);
  });

  tearDown(() async {
    ImageCacheHelper.debugClearLocalPathCache();
    ImageCacheHelper.debugSetCandidateCoverPaths([]);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('resolveLocalCoverPath caches, then re-reads after invalidate', () async {
    const mangaId = 42;
    final file = File('${tempDir.path}/$mangaId.jpg');
    await file.writeAsBytes(List<int>.filled(200, 7));

    final first = await ImageCacheHelper.resolveLocalCoverPath(mangaId, null);
    expect(first, file.path);

    // Delete on disk — memo should still return the cached path.
    await file.delete();
    final cached = await ImageCacheHelper.resolveLocalCoverPath(mangaId, null);
    expect(cached, file.path);

    ImageCacheHelper.invalidateLocalCover(mangaId, null);
    final afterInvalidate =
        await ImageCacheHelper.resolveLocalCoverPath(mangaId, null);
    expect(afterInvalidate, isNull);

    // Recreate and resolve again.
    await file.writeAsBytes(List<int>.filled(200, 8));
    ImageCacheHelper.invalidateLocalCover(mangaId, null);
    final again = await ImageCacheHelper.resolveLocalCoverPath(mangaId, null);
    expect(again, file.path);
  });

  test('resolveLocalCoverPath finds URL-hash covers', () async {
    const url = 'https://example.com/cover.jpg';
    // Mirror ImageCacheHelper._hashUrl FNV-1a.
    var hash = 0xcbf29ce484222325;
    for (var i = 0; i < url.length; i++) {
      hash ^= url.codeUnitAt(i);
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    final name = 'url_${hash.toRadixString(16)}.jpg';
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(List<int>.filled(150, 1));

    final path = await ImageCacheHelper.resolveLocalCoverPath(0, url);
    expect(path, file.path);

    final again = await ImageCacheHelper.resolveLocalCoverPath(0, url);
    expect(identical(path, again) || again == path, isTrue);
  });

  test('clearCache empties the local-path memo', () async {
    const mangaId = 7;
    final file = File('${tempDir.path}/$mangaId.jpg');
    await file.writeAsBytes(List<int>.filled(120, 3));
    expect(await ImageCacheHelper.resolveLocalCoverPath(mangaId, null), file.path);

    await file.delete();
    await ImageCacheHelper.clearCache();
    expect(await ImageCacheHelper.resolveLocalCoverPath(mangaId, null), isNull);
  });
}
