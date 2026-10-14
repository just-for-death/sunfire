// IMP-036: store finished local downloads as one CBZ per chapter.
//
// Layout: `<root>/<chapterId>/chapter.cbz` + the usual completion marker.
// Packing is all-or-nothing: the archive is written to a temp name, decoded
// back and checked, renamed, and only then are the loose page files deleted.
// A crash at any step leaves a folder that still validates (loose pages, or
// a verified archive).
import 'dart:io';

import 'package:archive/archive.dart';

import '../engine/image_validation.dart' show isImagePagePath, kChapterCbzName;

export '../engine/image_validation.dart' show kChapterCbzName;

File chapterCbzFile(Directory chapterDir) => File('${chapterDir.path}/$kChapterCbzName');

/// Packs the image pages of [chapterDir] into [kChapterCbzName]. Returns the
/// number of pages packed (0 = nothing to do / failed, folder untouched).
Future<int> packChapterFolderAsCbz(Directory chapterDir) async {
  final pages = <File>[];
  await for (final e in chapterDir.list(followLinks: false)) {
    if (e is File && isImagePagePath(e.path)) pages.add(e);
  }
  if (pages.isEmpty) return 0;
  pages.sort((a, b) => a.path.compareTo(b.path));

  final archive = Archive();
  for (final p in pages) {
    final name = p.uri.pathSegments.last;
    // Images are already compressed: store them (fast, no size gain lost).
    archive.addFile(ArchiveFile.bytes(name, await p.readAsBytes())..compression = CompressionType.none);
  }
  final bytes = ZipEncoder().encode(archive);
  final tmp = File('${chapterDir.path}/$kChapterCbzName.tmp');
  await tmp.writeAsBytes(bytes, flush: true);

  // Verify before anything is deleted.
  try {
    final check = ZipDecoder().decodeBytes(await tmp.readAsBytes());
    final n = check.files.where((f) => f.isFile && isImagePagePath(f.name)).length;
    if (n != pages.length) throw StateError('packed $n of ${pages.length}');
  } catch (_) {
    if (await tmp.exists()) await tmp.delete();
    return 0;
  }
  await tmp.rename(chapterCbzFile(chapterDir).path);
  for (final p in pages) {
    try {
      await p.delete();
    } catch (_) {}
  }
  return pages.length;
}
