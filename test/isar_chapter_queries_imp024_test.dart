// IMP-024: DB-side counts/filters replacing full chapter-table loads.
@Tags(['native'])
library;

import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';

String? _findIsarNative() {
  // Prefer isar_community_flutter_libs (3.3.2); fall back to legacy isar_flutter_libs.
  String? legacy;
  // 1) pub-cache hosted layout: .pub-cache/hosted/pub.dev/isar_community_flutter_libs-*/linux/libisar.so
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 2) legacy flat pub-cache layout.
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 3) flutter test build output (rebuilt via `flutter build linux --debug`).
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_imp024');
    final native = _findIsarNative();
    if (native == null) {
      fail('libisar.so not found (pub cache or build output) — cannot run DB-backed tests');
    }
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
  });

  tearDownAll(() async {
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    await IsarService.instance.isar.writeTxn(() async {
      await IsarService.instance.isar.clear();
    });
  });

  Future<void> seed() async {
    final isar = IsarService.instance.isar;
    final rows = <Chapter>[
      Chapter()..serverId = 1..mangaId = 10..name = 'read'..isRead = true..isDownloadedOnServer = true,
      Chapter()..serverId = 2..mangaId = 10..name = 'pos'..lastPageRead = 3,
      Chapter()..serverId = 3..mangaId = 20..name = 'ts'..lastReadAt = 1000..isDownloadedOnServer = true,
      Chapter()..serverId = 4..mangaId = 30..name = 'unread',
      Chapter()..serverId = -5..mangaId = 0..name = 'orphan',
    ];
    await isar.writeTxn(() => isar.chapters.putAll(rows));
  }

  test('countChapters / countChaptersWithReadEvidence match the old in-memory logic', () async {
    await seed();
    final all = await IsarService.instance.getAllChapters();
    expect(await IsarService.instance.countChapters(), all.length);
    expect(
      await IsarService.instance.countChaptersWithReadEvidence(),
      all.where((c) => c.isRead || c.lastPageRead > 0 || (c.lastReadAt ?? 0) > 0).length,
    );
    expect(await IsarService.instance.countChaptersWithReadEvidence(), 3);
  });

  test('countReadChapters ignores opened-but-unread chapters', () async {
    await seed();
    expect(await IsarService.instance.countReadChapters(), 1);
  });

  test('getServerDownloadedChapterIds returns only server-downloaded ids', () async {
    await seed();
    expect((await IsarService.instance.getServerDownloadedChapterIds()).toSet(), {1, 3});
  });

  test('getChaptersForMangaIdsAndOrphans: selected manga + orphans only', () async {
    await seed();
    final got = await IsarService.instance.getChaptersForMangaIdsAndOrphans({10, 30});
    expect(got.map((c) => c.serverId).toSet(), {1, 2, 4, -5});
    final none = await IsarService.instance.getChaptersForMangaIdsAndOrphans({});
    expect(none.map((c) => c.serverId).toSet(), {-5});
  });
}
