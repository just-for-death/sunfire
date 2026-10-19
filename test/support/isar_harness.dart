// Shared Isar bootstrap for widget tests that must pump real, DB-backed
// screens (library, manga detail, reader) instead of isolated widgets.
//
// Mirrors the proven setup in `test/reader_screen_wiring_test.dart`: locate
// the native `libisar.so`, initialise Isar in a throwaway temp directory, then
// let `IsarService` bind to it. Call [bootIsarHarness] from `setUpAll` and
// [teardownIsarHarness] from `tearDownAll`.
import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';

import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/db/models/tag.dart';

String? _findIsarNative() {
  // 1) pub-cache hosted layout (isar_community_flutter_libs preferred).
  String? legacy;
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
  // 2) flutter test build output (rebuilt via `flutter build linux --debug`).
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}

Directory? _tempDir;

/// Boots an in-process Isar instance backed by a temp dir and binds
/// [IsarService] to it. Throws if the native library cannot be found.
Future<void> bootIsarHarness() async {
  final native = _findIsarNative();
  if (native == null) {
    throw StateError(
      'libisar.so not found — run `flutter build linux --debug` once, or '
      'ensure isar_community_flutter_libs is in the pub cache.',
    );
  }
  _tempDir = await Directory.systemTemp.createTemp('sunfire_ui_harness');
  await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
  await Isar.open(
    [
      MangaSchema,
      ChapterSchema,
      CategorySchema,
      SyncRecordSchema,
      SyncMetaSchema,
      TagSchema,
    ],
    directory: _tempDir!.path,
    inspector: false,
  );
  await IsarService.instance.initialize();
}

/// Closes Isar and deletes the temp dir.
Future<void> teardownIsarHarness() async {
  try {
    await IsarService.instance.isar.close();
  } catch (_) {}
  try {
    await _tempDir?.delete(recursive: true);
  } catch (_) {}
  _tempDir = null;
}

/// Clears every collection so each test starts from a known empty DB.
Future<void> clearIsarHarness() async {
  final isar = IsarService.instance.isar;
  await isar.writeTxn(() => isar.clear());
}
