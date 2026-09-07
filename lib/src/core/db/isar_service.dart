import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';

import 'models/category.dart';
import 'models/chapter.dart';
import 'models/manga.dart';
import 'models/sync_meta.dart';
import 'models/sync_record.dart';

class IsarService {
  static IsarService? _instance;
  late Isar _isar;
  bool _isInitialized = false;
  Future<void>? _initFuture;
  static int _syntheticIdCounter = 0;

  static int _generateSyntheticServerId() {
    _syntheticIdCounter = (_syntheticIdCounter + 1) % 10000;
    return -(DateTime.now().microsecondsSinceEpoch % 1000000000 * 10000 + _syntheticIdCounter);
  }

  IsarService._();

  static IsarService get instance {
    _instance ??= IsarService._();
    return _instance!;
  }

  Isar get isar {
    if (!_isInitialized) {
      throw StateError('IsarService has not been initialized. Await initialize() first.');
    }
    return _isar;
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize() => _initFuture ??= _doInitialize();

  Future<void> _doInitialize() async {
    if (_isInitialized) return;
    final existing = Isar.getInstance();
    if (existing != null) {
      _isar = existing;
      _isInitialized = true;
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        MangaSchema,
        ChapterSchema,
        CategorySchema,
        SyncRecordSchema,
        SyncMetaSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
    _isInitialized = true;
  }

  // ── META HELPERS ─────────────────────────────────────────
  Future<String?> getMeta(String key) async {
    if (!_isInitialized) return null;
    final meta = await _isar.syncMetas.filter().keyEqualTo(key).findFirst();
    return meta?.value;
  }

  Future<void> setMeta(String key, String value) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final meta = SyncMeta()
        ..key = key
        ..value = value;
      await _isar.syncMetas.put(meta);
    });
  }

  // ── MANGA CRUD ──────────────────────────────────────────
  Future<void> saveManga(Manga manga) async {
    if (!_isInitialized) return;
    if (manga.serverId == 0) {
      manga.serverId = _generateSyntheticServerId();
    }
    await _isar.writeTxn(() async {
      await _isar.mangas.put(manga);
    });
  }

  Future<void> saveMangas(List<Manga> mangas) async {
    if (!_isInitialized || mangas.isEmpty) return;
    for (int i = 0; i < mangas.length; i++) {
      if (mangas[i].serverId == 0) {
        mangas[i].serverId = _generateSyntheticServerId();
      }
    }
    await _isar.writeTxn(() async {
      await _isar.mangas.putAll(mangas);
    });
  }

  Future<List<Manga>> getAllManga() async {
    if (!_isInitialized) return [];
    return await _isar.mangas.where().findAll();
  }

  Future<List<Manga>> getLibraryManga() async {
    if (!_isInitialized) return [];
    return await _isar.mangas.filter().inLibraryEqualTo(true).findAll();
  }

  Future<Manga?> getManga(int id) async {
    if (!_isInitialized) return null;
    return await _isar.mangas.get(id);
  }

  Future<Manga?> getMangaByServerId(int serverId) async {
    if (!_isInitialized) return null;
    final byServer = await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
    if (byServer != null) return byServer;
    // Fallback to Isar local auto-increment ID for local standalone manga
    return await _isar.mangas.get(serverId);
  }

  /// Returns the count of manga currently marked as inLibrary in Isar.
  /// Used by the wipe guard to detect suspicious server-side library wipes.
  Future<int> getMangaCount() async {
    if (!_isInitialized) return 0;
    return await _isar.mangas.filter().inLibraryEqualTo(true).count();
  }

  // ── CHAPTER CRUD ────────────────────────────────────────
  Future<void> saveChapter(Chapter chapter) async {
    if (!_isInitialized) return;
    if (chapter.serverId == 0) {
      chapter.serverId = _generateSyntheticServerId();
    }
    await _isar.writeTxn(() async {
      await _isar.chapters.put(chapter);
    });
  }

  Future<void> saveChapters(List<Chapter> chapters) async {
    if (!_isInitialized || chapters.isEmpty) return;
    for (int i = 0; i < chapters.length; i++) {
      if (chapters[i].serverId == 0) {
        chapters[i].serverId = _generateSyntheticServerId();
      }
    }
    await _isar.writeTxn(() async {
      await _isar.chapters.putAll(chapters);
    });
  }

  Future<List<Chapter>> getAllChapters() async {
    if (!_isInitialized) return [];
    return await _isar.chapters.where().findAll();
  }

  Future<List<Chapter>> getChaptersForManga(int mangaId) async {
    if (!_isInitialized) return [];
    final chapters = await _isar.chapters.filter().mangaIdEqualTo(mangaId).sortByChapterNumberDesc().findAll();
    if (chapters.isNotEmpty) return chapters;
    // Fallback: if mangaId was an Isar local ID, check its serverId, or vice versa
    final manga = await _isar.mangas.get(mangaId);
    if (manga != null && manga.serverId != 0 && manga.serverId != mangaId) {
      return await _isar.chapters.filter().mangaIdEqualTo(manga.serverId).sortByChapterNumberDesc().findAll();
    }
    final byServerManga = await _isar.mangas.filter().serverIdEqualTo(mangaId).findFirst();
    if (byServerManga != null && byServerManga.id != mangaId) {
      return await _isar.chapters.filter().mangaIdEqualTo(byServerManga.id).sortByChapterNumberDesc().findAll();
    }
    return [];
  }

  Future<Chapter?> getChapterByServerId(int serverId) async {
    if (!_isInitialized) return null;
    final byServer = await _isar.chapters.filter().serverIdEqualTo(serverId).findFirst();
    if (byServer != null) return byServer;
    // Fallback to Isar auto-increment ID
    return await _isar.chapters.get(serverId);
  }

  Future<List<Chapter>> getReadingHistory() async {
    if (!_isInitialized) return [];
    try {
      return await _isar.chapters
          .filter()
          .lastReadAtGreaterThan(0)
          .sortByLastReadAtDesc()
          .findAll();
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Returns chapters sorted by fetchedAt DESC — the offline Updates feed.
  /// Filters to manga currently marked inLibrary == true and chapters with
  /// valid fetchedAt > 0. No per-manga cap here — the display layer groups
  /// by date and the server already limits bulk imports to 3 per manga.
  Future<List<Chapter>> getRecentChapters({int limit = 300}) async {
    if (!_isInitialized) return [];
    try {
      final libraryManga = await getLibraryManga();
      final libraryIds = <int>{
        for (final m in libraryManga) ...[
          if (m.serverId != 0) m.serverId,
          m.id,
        ],
      };

      if (libraryIds.isEmpty) return [];

      final chapters = await _isar.chapters
          .filter()
          .fetchedAtGreaterThan(0)
          .sortByFetchedAtDesc()
          .limit(limit * 3)
          .findAll();

      final result = <Chapter>[];
      for (final ch in chapters) {
        if (!libraryIds.contains(ch.mangaId)) continue;
        result.add(ch);
        if (result.length >= limit) break;
      }
      return result;
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Cleans up ONLY synthetic standalone-scraped chapters that were bulk-stamped
  /// (e.g. the initial Mangago local extension scrape that writes fake serverIds).
  /// Real server chapters (serverId in normal positive range and without bulk stamps) are preserved.
  Future<void> cleanupBulkScrapedUpdates() async {
    if (!_isInitialized) return;
    try {
      final chaptersWithFetchedAt = await _isar.chapters
          .filter()
          .fetchedAtGreaterThan(0)
          .sortByChapterNumberDesc()
          .findAll();
      if (chaptersWithFetchedAt.isEmpty) return;

      // Identify standalone-scraped chapters: url non-empty, serverId in synthetic range
      final standaloneChapters = chaptersWithFetchedAt
          .where((ch) => ch.url.isNotEmpty && (ch.serverId > 200000 || ch.serverId < 0))
          .toList();
      if (standaloneChapters.isEmpty) return;

      final Map<int, List<Chapter>> mangaGroups = {};
      for (final ch in standaloneChapters) {
        mangaGroups.putIfAbsent(ch.mangaId, () => []).add(ch);
      }

      final List<Chapter> toReset = [];
      for (final list in mangaGroups.values) {
        // Group by 60-second time windows to catch bulk scraping batches
        final Map<int, List<Chapter>> timeBuckets = {};
        for (final ch in list) {
          final rawFt = ch.fetchedAt ?? 0;
          final ftSec = rawFt > 100000000000 ? (rawFt ~/ 1000) : rawFt;
          final bucket = ftSec ~/ 60;
          timeBuckets.putIfAbsent(bucket, () => []).add(ch);
        }

        for (final bucketList in timeBuckets.values) {
          if (bucketList.length > 3) {
            // Keep top 3 by chapterNumber (list already sorted Desc), reset older ones
            for (int i = 3; i < bucketList.length; i++) {
              bucketList[i].fetchedAt = 0;
              toReset.add(bucketList[i]);
            }
          }
        }
      }

      if (toReset.isNotEmpty) {
        await _isar.writeTxn(() async {
          await _isar.chapters.putAll(toReset);
        });
        await LoggerService.instance.logInfo(
          'Cleaned up ${toReset.length} bulk-stamped standalone chapters from Updates feed',
          'Database',
        );
      }
    } catch (e) {
      debugPrint('[IsarService] cleanupBulkScrapedUpdates error: $e');
    }
  }

  /// Returns chapters that are currently in-progress (opened but not finished).
  /// Useful for a "Continue Reading" widget that works fully offline.
  Future<List<Chapter>> getInProgressChapters({int limit = 20}) async {
    if (!_isInitialized) return [];
    final all = await _isar.chapters
        .filter()
        .isReadEqualTo(false)
        .lastPageReadGreaterThan(0)
        .sortByLastReadAtDesc()
        .limit(limit)
        .findAll();
    return all;
  }

  Future<void> deleteManga(int serverId) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final manga = await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
      final localManga = manga ?? await _isar.mangas.get(serverId);
      if (localManga != null) {
        await _isar.mangas.delete(localManga.id);
        final chapters = await _isar.chapters
            .filter()
            .mangaIdEqualTo(localManga.serverId)
            .or()
            .mangaIdEqualTo(localManga.id)
            .findAll();
        if (chapters.isNotEmpty) {
          await _isar.chapters.deleteAll(chapters.map((c) => c.id).toList());
        }
      } else {
        final chapters = await _isar.chapters.filter().mangaIdEqualTo(serverId).findAll();
        if (chapters.isNotEmpty) {
          await _isar.chapters.deleteAll(chapters.map((c) => c.id).toList());
        }
      }
    });
  }

  // ── CATEGORY CRUD ───────────────────────────────────────
  Future<void> saveCategory(Category category) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final existing = await _isar.categorys.filter().serverIdEqualTo(category.serverId).findFirst();
      if (existing != null) {
        category.id = existing.id;
      }
      await _isar.categorys.put(category);
    });
  }

  Future<void> saveCategories(List<Category> categories, {bool replaceAll = true}) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final existing = await _isar.categorys.where().findAll();
      final existingMap = {for (var e in existing) e.serverId: e.id};
      for (var c in categories) {
        if (existingMap.containsKey(c.serverId)) {
          c.id = existingMap[c.serverId]!;
        }
      }
      if (replaceAll && categories.isNotEmpty) {
        final newServerIds = categories.map((c) => c.serverId).toSet();
        final toDelete = existing.where((e) => !newServerIds.contains(e.serverId)).map((e) => e.id).toList();
        await _isar.categorys.deleteAll(toDelete);
      }
      await _isar.categorys.putAll(categories);
    });
  }

  Future<void> deleteCategory(int serverId) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final cat = await _isar.categorys.filter().serverIdEqualTo(serverId).findFirst();
      if (cat != null) {
        await _isar.categorys.delete(cat.id);
      } else {
        await _isar.categorys.delete(serverId);
      }
    });
  }

  Future<List<Category>> getCategories() async {
    if (!_isInitialized) return [];
    return await _isar.categorys.where().sortByOrder().findAll();
  }

  // ── SYNC RECORD CRUD ────────────────────────────────────
  Future<void> saveSyncRecord(SyncRecord record) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      await _isar.syncRecords.put(record);
    });
  }

  Future<List<SyncRecord>> getPendingSyncRecords() async {
    if (!_isInitialized) return [];
    return await _isar.syncRecords.filter().stateEqualTo(SyncRecordState.pending).or().stateEqualTo(SyncRecordState.failed).findAll();
  }

  Future<void> deleteSyncRecord(Id id) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      await _isar.syncRecords.delete(id);
    });
  }

  // ── DATABASE MAINTENANCE ────────────────────────────────
  Future<void> clearAll() async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
