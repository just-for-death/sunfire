// IMP-002: local source engine (folders of images and CBZ/ZIP chapters).
//
// Layout (Mihon-compatible):
//   <root>/<Manga title>/cover.(jpg|png|webp)        optional
//   <root>/<Manga title>/<Chapter folder>/001.jpg ...  image-folder chapter
//   <root>/<Manga title>/<Chapter 12>.cbz              archive chapter
// CBZ pages are extracted once into a per-chapter cache folder; archive
// entries are flattened to their basename (no zip-slip), and size/entry caps
// guard against zip bombs.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' show sha1;

import 'image_validation.dart' show kImagePageExtensions;

const int kLocalCbzMaxEntries = 5000;
const int kLocalCbzMaxBytes = 1024 * 1024 * 1024; // 1 GiB uncompressed

class LocalSourceException implements Exception {
  LocalSourceException(this.message);
  final String message;
  @override
  String toString() => 'LocalSourceException: $message';
}

class LocalManga {
  LocalManga({required this.title, required this.path, this.coverPath});
  final String title;
  final String path;
  final String? coverPath;
}

class LocalChapter {
  LocalChapter({required this.name, required this.path, required this.isArchive, this.chapterNumber});
  final String name;
  final String path;
  final bool isArchive;
  final double? chapterNumber;
}

String _base(String p) {
  final parts = p.replaceAll('\\', '/').split('/').where((s) => s.isNotEmpty);
  return parts.isEmpty ? '' : parts.last;
}

String _ext(String p) {
  final b = _base(p).toLowerCase();
  final i = b.lastIndexOf('.');
  return i < 0 ? '' : b.substring(i);
}

bool isLocalImageFile(String p) => kImagePageExtensions.contains(_ext(p)) && !_base(p).startsWith('.');
bool isLocalArchiveFile(String p) => const {'.cbz', '.zip'}.contains(_ext(p));

/// Natural ("human") order: "2" < "10", case-insensitive.
int naturalCompare(String a, String b) {
  final re = RegExp(r'(\d+)|(\D+)');
  final ta = re.allMatches(a.toLowerCase()).map((m) => m.group(0)!).toList();
  final tb = re.allMatches(b.toLowerCase()).map((m) => m.group(0)!).toList();
  for (var i = 0; i < ta.length && i < tb.length; i++) {
    final na = int.tryParse(ta[i]);
    final nb = int.tryParse(tb[i]);
    final c = (na != null && nb != null) ? na.compareTo(nb) : ta[i].compareTo(tb[i]);
    if (c != 0) return c;
  }
  return ta.length.compareTo(tb.length);
}

/// "Vol.2 Ch. 12.5 - Title" → 12.5; a bare "007" → 7; null when none.
double? parseLocalChapterNumber(String name) {
  final stem = name.replaceAll(RegExp(r'\.(cbz|zip)$', caseSensitive: false), '');
  final ch = RegExp(r'ch(?:apter|\.)?\s*(\d+(?:\.\d+)?)', caseSensitive: false).firstMatch(stem);
  if (ch != null) return double.tryParse(ch.group(1)!);
  final any = RegExp(r'(\d+(?:\.\d+)?)').allMatches(stem).toList();
  if (any.isEmpty) return null;
  return double.tryParse(any.last.group(1)!);
}

class LocalSource {
  LocalSource(this.root);

  static const String sourceName = 'local';
  final Directory root;

  Future<List<LocalManga>> listManga() async {
    if (!await root.exists()) return const [];
    final out = <LocalManga>[];
    await for (final e in root.list(followLinks: false)) {
      if (e is! Directory) continue;
      final title = _base(e.path);
      if (title.startsWith('.')) continue;
      out.add(LocalManga(title: title, path: e.path, coverPath: await _findCover(e)));
    }
    out.sort((a, b) => naturalCompare(a.title, b.title));
    return out;
  }

  Future<String?> _findCover(Directory dir) async {
    await for (final e in dir.list(followLinks: false)) {
      if (e is File && isLocalImageFile(e.path) && _base(e.path).toLowerCase().startsWith('cover.')) return e.path;
    }
    return null;
  }

  /// Chapters in reading order (by chapter number, then natural name).
  Future<List<LocalChapter>> listChapters(LocalManga manga) async {
    final dir = Directory(manga.path);
    if (!await dir.exists()) return const [];
    final out = <LocalChapter>[];
    await for (final e in dir.list(followLinks: false)) {
      final name = _base(e.path);
      if (name.startsWith('.')) continue;
      if (e is File && isLocalArchiveFile(e.path)) {
        out.add(LocalChapter(name: name, path: e.path, isArchive: true, chapterNumber: parseLocalChapterNumber(name)));
      } else if (e is Directory && await _hasImages(e)) {
        out.add(LocalChapter(name: name, path: e.path, isArchive: false, chapterNumber: parseLocalChapterNumber(name)));
      }
    }
    out.sort((a, b) {
      final na = a.chapterNumber;
      final nb = b.chapterNumber;
      if (na != null && nb != null && na != nb) return na.compareTo(nb);
      return naturalCompare(a.name, b.name);
    });
    return out;
  }

  Future<bool> _hasImages(Directory d) async {
    await for (final e in d.list(followLinks: false)) {
      if (e is File && isLocalImageFile(e.path)) return true;
    }
    return false;
  }

  /// Absolute page file paths in order. Archive chapters are extracted into
  /// `<cacheDir>/<sha1(path+mtime)>/` (reused when already there).
  Future<List<String>> pagePaths(LocalChapter chapter, {required Directory cacheDir}) async {
    if (!chapter.isArchive) {
      final files = <String>[];
      await for (final e in Directory(chapter.path).list(followLinks: false)) {
        if (e is File && isLocalImageFile(e.path)) files.add(e.path);
      }
      files.sort((a, b) => naturalCompare(_base(a), _base(b)));
      return files;
    }
    final src = File(chapter.path);
    final stat = await src.stat();
    final key = sha1.convert(utf8.encode('${chapter.path}|${stat.modified.millisecondsSinceEpoch}|${stat.size}')).toString();
    final outDir = Directory('${cacheDir.path}/$key');
    final done = File('${outDir.path}/.extracted');
    if (await done.exists()) {
      final cached = <String>[];
      await for (final e in outDir.list()) {
        if (e is File && isLocalImageFile(e.path)) cached.add(e.path);
      }
      cached.sort((a, b) => naturalCompare(_base(a), _base(b)));
      return cached;
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await src.readAsBytes());
    } catch (e) {
      throw LocalSourceException('Not a valid CBZ/ZIP: ${chapter.name} ($e)');
    }
    if (archive.files.length > kLocalCbzMaxEntries) {
      throw LocalSourceException('${chapter.name} has too many entries');
    }
    final pages = <ArchiveFile>[];
    var total = 0;
    for (final f in archive) {
      if (!f.isFile || !isLocalImageFile(f.name) || f.name.contains('__MACOSX')) continue;
      total += f.size;
      if (total > kLocalCbzMaxBytes) throw LocalSourceException('${chapter.name} is too large');
      pages.add(f);
    }
    // archive's ZipDecoder yields an empty archive for non-zip bytes.
    if (pages.isEmpty) throw LocalSourceException('No images in ${chapter.name} (not a CBZ, or empty)');
    // Nested folders inside the archive: order by full entry path.
    pages.sort((a, b) => naturalCompare(a.name, b.name));
    await outDir.create(recursive: true);
    final out = <String>[];
    for (var i = 0; i < pages.length; i++) {
      // Index prefix keeps archive order and avoids basename collisions.
      final name = '${(i + 1).toString().padLeft(4, '0')}_${_base(pages[i].name)}';
      final file = File('${outDir.path}/$name');
      await file.writeAsBytes(pages[i].readBytes() ?? const <int>[], flush: true);
      out.add(file.path);
    }
    await done.writeAsString('${pages.length}');
    return out;
  }
}
