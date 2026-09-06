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

  IsarService._();

  static IsarService get instance {
    _instance ??= IsarService._();
    return _instance!;
  }

  Isar get isar => _isar;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
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
    await _isar.writeTxn(() async {
      await _isar.mangas.put(manga);
    });
  }

  Future<void> saveMangas(List<Manga> mangas) async {
    if (!_isInitialized) return;
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

  Future<Manga?> getMangaByServerId(int serverId) async {
    if (!_isInitialized) return null;
    return await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
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
    await _isar.writeTxn(() async {
      await _isar.chapters.put(chapter);
    });
  }

  Future<void> saveChapters(List<Chapter> chapters) async {
    if (!_isInitialized) return;
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
    return await _isar.chapters.filter().mangaIdEqualTo(mangaId).sortByChapterNumberDesc().findAll();
  }

  Future<Chapter?> getChapterByServerId(int serverId) async {
    if (!_isInitialized) return null;
    return await _isar.chapters.filter().serverIdEqualTo(serverId).findFirst();
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
  /// Strictly filters to manga currently marked inLibrary == true, and
  /// chapters with valid fetchedAt > 0, capped at 3 chapters per manga
  /// to prevent any single title from flooding the feed.
  Future<List<Chapter>> getRecentChapters({int limit = 100}) async {
    if (!_isInitialized) return [];
    try {
      final libraryManga = await getLibraryManga();
      if (libraryManga.isEmpty) return [];

      final libraryIds = <int>{
        for (final m in libraryManga) ...[
          if (m.serverId > 0) m.serverId,
          m.id,
        ],
      };

      final chapters = await _isar.chapters
          .filter()
          .fetchedAtGreaterThan(0)
          .sortByFetchedAtDesc()
          .findAll();

      final mangaCounts = <int, int>{};
      final result = <Chapter>[];
      for (final ch in chapters) {
        if (!libraryIds.contains(ch.mangaId)) continue;
        final count = mangaCounts[ch.mangaId] ?? 0;
        if (count >= 3) continue; // cap at 3 chapters per manga
        mangaCounts[ch.mangaId] = count + 1;
        result.add(ch);
        if (result.length >= limit) break;
      }
      return result;
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Automatically cleans up legacy bulk-scraped chapters from the Updates feed.
  /// If chapters for the same manga were stamped in bulk (e.g. initial scrape/sync),
  /// keeps at most the 3 latest chapters and resets the rest to fetchedAt = 0.
  Future<void> cleanupBulkScrapedUpdates() async {
    if (!_isInitialized) return;
    try {
      final chaptersWithFetchedAt = await _isar.chapters
          .filter()
          .fetchedAtGreaterThan(0)
          .sortByChapterNumberDesc()
          .findAll();
      if (chaptersWithFetchedAt.isEmpty) return;

      final Map<int, List<Chapter>> mangaGroups = {};
      for (final ch in chaptersWithFetchedAt) {
        mangaGroups.putIfAbsent(ch.mangaId, () => []).add(ch);
      }

      final List<Chapter> toReset = [];
      for (final list in mangaGroups.values) {
        // Group by 60-second time windows to catch bulk scraping/importing batches
        final Map<int, List<Chapter>> timeBuckets = {};
        for (final ch in list) {
          final bucket = (ch.fetchedAt ?? 0) ~/ 60;
          timeBuckets.putIfAbsent(bucket, () => []).add(ch);
        }

        for (final bucketList in timeBuckets.values) {
          if (bucketList.length > 3) {
            // Keep top 3 by chapterNumber (since list is already sorted Desc), reset older back-chapters
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
          'Cleaned up ${toReset.length} bulk-stamped chapters from Updates feed',
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
      if (manga != null) {
        await _isar.mangas.delete(manga.id);
      }
      final chapters = await _isar.chapters.filter().mangaIdEqualTo(serverId).findAll();
      if (chapters.isNotEmpty) {
        await _isar.chapters.deleteAll(chapters.map((c) => c.id).toList());
      }
    });
  }

  // ── CATEGORY CRUD ───────────────────────────────────────
  Future<void> saveCategories(List<Category> categories) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final existing = await _isar.categorys.where().findAll();
      final existingMap = {for (var e in existing) e.serverId: e.id};
      for (var c in categories) {
        if (existingMap.containsKey(c.serverId)) {
          c.id = existingMap[c.serverId]!;
        }
      }
      final newServerIds = categories.map((c) => c.serverId).toSet();
      final toDelete = existing.where((e) => !newServerIds.contains(e.serverId)).map((e) => e.id).toList();
      await _isar.categorys.deleteAll(toDelete);
      await _isar.categorys.putAll(categories);
    });
  }

  Future<void> deleteCategory(int serverId) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      final cat = await _isar.categorys.filter().serverIdEqualTo(serverId).findFirst();
      if (cat != null) {
        await _isar.categorys.delete(cat.id);
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
