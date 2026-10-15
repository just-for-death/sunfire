// IMP-002: LocalSource ↔ database ↔ reader glue.
//
// Local series are ordinary Manga/Chapter rows with sourceName 'local',
// negative synthetic ids (stableLocalMangaServerId /
// mintLocalChapterServerId), and `localfs:` URLs. Negative ids are never
// pushed to Suwayomi (every sync push is guarded by serverId > 0), so nothing
// here reaches the server. The reader resolves `localfs:` chapters into file
// paths through ContentResolverService (isLocalFiles: true).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import '../services/settings_service.dart';
import 'local_source.dart';

const String kLocalSourceName = LocalSource.sourceName; // 'local'
const String kLocalChapterUrlScheme = 'localfs:';

bool isLocalChapterUrl(String? url) => url != null && url.startsWith(kLocalChapterUrlScheme);
String localPathFromUrl(String url) => url.substring(kLocalChapterUrlScheme.length);

/// The persistence the service needs; Isar in the app, a fake in tests.
abstract class LocalLibraryStore {
  Future<List<Manga>> allManga();
  Future<Manga?> mangaByServerId(int serverId);
  Future<void> saveManga(Manga manga);
  Future<List<Chapter>> chaptersFor(int mangaKey);
  Future<void> saveChapters(List<Chapter> chapters);
  Future<void> deleteChapters(List<Chapter> chapters);
}

class IsarLocalLibraryStore implements LocalLibraryStore {
  const IsarLocalLibraryStore();
  IsarService get _db => IsarService.instance;
  @override
  Future<List<Manga>> allManga() => _db.getAllManga();
  @override
  Future<Manga?> mangaByServerId(int serverId) => _db.getMangaByServerId(serverId);
  @override
  Future<void> saveManga(Manga manga) => _db.saveManga(manga);
  @override
  Future<List<Chapter>> chaptersFor(int mangaKey) => _db.getChaptersForManga(mangaKey);
  @override
  Future<void> saveChapters(List<Chapter> chapters) => _db.saveChapters(chapters);
  @override
  Future<void> deleteChapters(List<Chapter> chapters) => _db.deleteChapters(chapters);
}

class LocalScanResult {
  const LocalScanResult({this.manga = 0, this.addedChapters = 0, this.removedChapters = 0, this.error});
  final int manga;
  final int addedChapters;
  final int removedChapters;
  final String? error;
  @override
  String toString() => 'LocalScanResult(manga: $manga, +$addedChapters, -$removedChapters${error == null ? '' : ', $error'})';
}

class LocalSourceService extends ChangeNotifier {
  LocalSourceService._();
  static final LocalSourceService instance = LocalSourceService._();

  @visibleForTesting
  LocalLibraryStore? debugStore;
  @visibleForTesting
  Directory? debugCacheDir;

  LocalLibraryStore get _store => debugStore ?? const IsarLocalLibraryStore();

  bool _scanning = false;
  bool get isScanning => _scanning;

  @visibleForTesting
  void debugReset() {
    debugStore = null;
    debugCacheDir = null;
    _scanning = false;
  }

  /// The folder holding one sub-folder per series; null when unset.
  String? get root {
    final r = SettingsService.instance.localSourceRoot.trim();
    return r.isEmpty ? null : r;
  }

  /// Whether [path] is inside the configured root folder.
  bool isUnderRoot(String path) {
    final r = root;
    if (r == null) return false;
    return p.isWithin(p.normalize(r), p.normalize(path));
  }

  /// Sets (or clears with null/empty) the root folder. Does not scan.
  Future<void> setRoot(String? path) async {
    SettingsService.instance.localSourceRoot = path?.trim() ?? '';
    notifyListeners();
  }

  /// Rescans [root] into the database. Existing chapters keep their read state
  /// and ids (matched by path); chapters whose file/folder is gone are removed.
  /// Series folders that disappeared are left alone (they may be on an
  /// unmounted card).
  Future<LocalScanResult> scan() async {
    final r = root;
    if (r == null) return const LocalScanResult(error: 'No local folder set');
    if (_scanning) return const LocalScanResult(error: 'Scan already running');
    _scanning = true;
    notifyListeners();
    try {
      final src = LocalSource(Directory(r));
      final found = await src.listManga();
      var added = 0;
      var removed = 0;
      for (final lm in found) {
        final key = stableLocalMangaServerId(sourceName: kLocalSourceName, url: lm.path, title: lm.title);
        final manga = await _store.mangaByServerId(key) ?? (Manga()..serverId = key);
        manga
          ..sourceName = kLocalSourceName
          ..title = lm.title
          ..url = '$kLocalChapterUrlScheme${lm.path}'
          ..thumbnailUrl = lm.coverPath ?? manga.thumbnailUrl
          ..lastFetchedAt = DateTime.now().millisecondsSinceEpoch;

        final chapters = await src.listChapters(lm);
        final existing = await _store.chaptersFor(key);
        final byUrl = {for (final c in existing) c.url: c};
        final taken = existing.map((c) => c.serverId).toSet();
        final toSave = <Chapter>[];
        final seen = <String>{};
        for (var i = 0; i < chapters.length; i++) {
          final lc = chapters[i];
          final url = '$kLocalChapterUrlScheme${lc.path}';
          seen.add(url);
          final ch = byUrl[url] ??
              (Chapter()
                ..serverId = mintLocalChapterServerId(mangaId: key, index: i, takenServerIds: taken)
                ..mangaId = key
                ..url = url);
          if (!byUrl.containsKey(url)) added++;
          ch
            ..name = lc.name.replaceAll(RegExp(r'\.(cbz|zip)$', caseSensitive: false), '')
            ..chapterNumber = lc.chapterNumber ?? (i + 1).toDouble()
            ..localPath = lc.path;
          toSave.add(ch);
        }
        final gone = existing.where((c) => isLocalChapterUrl(c.url) && !seen.contains(c.url)).toList();
        removed += gone.length;
        manga.chapterCount = chapters.length;
        manga.unreadCount = toSave.where((c) => !c.isRead).length;

        await _store.saveManga(manga);
        if (toSave.isNotEmpty) await _store.saveChapters(toSave);
        if (gone.isNotEmpty) await _store.deleteChapters(gone);
      }
      return LocalScanResult(manga: found.length, addedChapters: added, removedChapters: removed);
    } catch (e) {
      return LocalScanResult(error: '$e');
    } finally {
      _scanning = false;
      notifyListeners();
    }
  }

  /// Every local series in the database, sorted by title.
  Future<List<Manga>> listLibrary() async {
    final all = await _store.allManga();
    final out = all.where((m) => m.sourceName == kLocalSourceName).toList()
      ..sort((a, b) => naturalCompare(a.title, b.title));
    return out;
  }

  /// Chapters of a local series in reading order.
  Future<List<Chapter>> chaptersFor(Manga manga) async {
    final list = await _store.chaptersFor(manga.canonicalKey);
    list.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    return list;
  }

  /// Page file paths for a `localfs:` chapter URL (CBZ extracted to cache).
  Future<List<String>> pagePathsForChapterUrl(String url) async {
    final path = localPathFromUrl(url);
    final chapter = LocalChapter(
      name: path.split(RegExp(r'[/\\]')).last,
      path: path,
      isArchive: isLocalArchiveFile(path),
    );
    final cache = debugCacheDir ?? Directory('${(await getTemporaryDirectory()).path}/local_cbz');
    return LocalSource(Directory(path)).pagePaths(chapter, cacheDir: cache);
  }
}
