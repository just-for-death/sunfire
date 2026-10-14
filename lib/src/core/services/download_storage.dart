// IMP-035: download storage location + free-space guard.
//
// Chapters live in `<root>/<chapterId>`. The root is the user-picked
// [SettingsService.localDownloadDirectory] or `<app documents>/downloads`.
// Reads and deletes look in BOTH roots, so changing the location never
// orphans chapters that were already downloaded.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'settings_service.dart';

class InsufficientStorageException implements Exception {
  InsufficientStorageException(this.freeBytes, this.requiredBytes);
  final int freeBytes;
  final int requiredBytes;
  @override
  String toString() =>
      'Not enough storage: ${(freeBytes / 1048576).toStringAsFixed(0)} MB free, '
      '${(requiredBytes / 1048576).toStringAsFixed(0)} MB required';
}

/// Parses POSIX `df -Pk <path>` output into available bytes (null if unparsable).
int? parseDfAvailableBytes(String out) {
  final lines = out.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.length < 2) return null;
  final cols = lines.last.trim().split(RegExp(r'\s+'));
  // Filesystem 1024-blocks Used Available Capacity Mounted-on; a long
  // filesystem name may wrap so count from the end.
  if (cols.length < 4) return null;
  final kb = int.tryParse(cols[cols.length - 3]);
  return kb == null ? null : kb * 1024;
}

/// Unknown free space ([free] null) never blocks a download.
bool hasRoomForDownload(int? free, {required int reserveBytes}) => free == null || free >= reserveBytes;

class DownloadStorage {
  DownloadStorage._();

  @visibleForTesting
  static Future<Directory> Function()? debugDocumentsDir;
  @visibleForTesting
  static Future<ProcessResult> Function(String exe, List<String> args)? debugRunProcess;

  /// True while the last free-space check failed (UIS banner hook).
  static final ValueNotifier<bool> lowStorage = ValueNotifier<bool>(false);

  @visibleForTesting
  static void debugReset() {
    debugDocumentsDir = null;
    debugRunProcess = null;
    lowStorage.value = false;
  }

  static Future<Directory> defaultRoot() async {
    final docs = await (debugDocumentsDir ?? getApplicationDocumentsDirectory)();
    return Directory('${docs.path}/downloads');
  }

  /// Where new chapters are written (the downloadDirectory).
  static Future<Directory> downloadDirectory() async {
    final custom = SettingsService.instance.localDownloadDirectory.trim();
    return custom.isNotEmpty ? Directory(custom) : defaultRoot();
  }

  /// Active root first, then the default (deduplicated).
  static Future<List<Directory>> roots() async {
    final active = await downloadDirectory();
    final def = await defaultRoot();
    return active.path == def.path ? [active] : [active, def];
  }

  static Future<Directory> chapterDirForWrite(int chapterId) async =>
      Directory('${(await downloadDirectory()).path}/$chapterId');

  /// Every existing folder for [chapterId] across the roots.
  static Future<List<Directory>> existingChapterDirs(int chapterId) async {
    final out = <Directory>[];
    for (final r in await roots()) {
      final d = Directory('${r.path}/$chapterId');
      if (await d.exists()) out.add(d);
    }
    return out;
  }

  /// Free bytes on the volume holding [path]; null when unknown (Windows,
  /// no `df`, odd output).
  static Future<int?> freeSpaceBytes(String path) async {
    if (!kIsWeb && Platform.isWindows && debugRunProcess == null) return null;
    try {
      final run = debugRunProcess ?? (String e, List<String> a) => Process.run(e, a);
      final r = await run('df', ['-Pk', path]);
      if (r.exitCode != 0) return null;
      return parseDfAvailableBytes(r.stdout.toString());
    } catch (_) {
      return null;
    }
  }

  /// Throws [InsufficientStorageException] when the download root has less
  /// than the configured reserve free; updates [lowStorage] either way.
  static Future<void> ensureFreeSpace() async {
    final root = await downloadDirectory();
    var probe = root;
    while (!await probe.exists() && probe.parent.path != probe.path) {
      probe = probe.parent;
    }
    final free = await freeSpaceBytes(probe.path);
    final reserve = SettingsService.instance.downloadMinFreeSpaceMb * 1048576;
    final ok = hasRoomForDownload(free, reserveBytes: reserve);
    lowStorage.value = !ok;
    if (!ok) throw InsufficientStorageException(free!, reserve);
  }
}
