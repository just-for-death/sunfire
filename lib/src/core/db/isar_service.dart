import 'package:flutter/foundation.dart' show kDebugMode;
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
    final meta = await _isar.syncMetas.filter().keyEqualTo(key).findFirst();
    return meta?.value;
  }

  Future<void> setMeta(String key, String value) async {
    await _isar.writeTxn(() async {
      final meta = SyncMeta()
        ..key = key
        ..value = value;
      await _isar.syncMetas.put(meta);
    });
  }

  // ── MANGA CRUD ──────────────────────────────────────────
  Future<void> saveManga(Manga manga) async {
    await _isar.writeTxn(() async {
      await _isar.mangas.put(manga);
    });
  }

  Future<void> saveMangas(List<Manga> mangas) async {
    await _isar.writeTxn(() async {
      await _isar.mangas.putAll(mangas);
    });
  }

  Future<List<Manga>> getAllManga() async {
    return await _isar.mangas.where().findAll();
  }

  Future<List<Manga>> getLibraryManga() async {
    return await _isar.mangas.filter().inLibraryEqualTo(true).findAll();
  }

  Future<Manga?> getMangaByServerId(int serverId) async {
    return await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
  }

  /// Returns the count of manga currently marked as inLibrary in Isar.
  /// Used by the wipe guard to detect suspicious server-side library wipes.
  Future<int> getMangaCount() async {
    return await _isar.mangas.filter().inLibraryEqualTo(true).count();
  }

  // ── CHAPTER CRUD ────────────────────────────────────────
  Future<void> saveChapter(Chapter chapter) async {
    await _isar.writeTxn(() async {
      await _isar.chapters.put(chapter);
    });
  }

  Future<void> saveChapters(List<Chapter> chapters) async {
    await _isar.writeTxn(() async {
      await _isar.chapters.putAll(chapters);
    });
  }

  Future<List<Chapter>> getAllChapters() async {
    return await _isar.chapters.where().findAll();
  }

  Future<List<Chapter>> getChaptersForManga(int mangaId) async {
    return await _isar.chapters.filter().mangaIdEqualTo(mangaId).sortByChapterNumberDesc().findAll();
  }

  Future<Chapter?> getChapterByServerId(int serverId) async {
    return await _isar.chapters.filter().serverIdEqualTo(serverId).findFirst();
  }

  Future<List<Chapter>> getReadingHistory() async {
    try {
      return await _isar.chapters
          .filter()
          .isReadEqualTo(true)
          .or()
          .lastPageReadGreaterThan(0)
          .or()
          .lastReadAtGreaterThan(0)
          .sortByLastReadAtDesc()
          .findAll();
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Returns chapters sorted by fetchedAt DESC — the offline Updates feed.
  /// Chapters with denormalized [mangaTitle] and [mangaThumbnailUrl] render
  /// the Updates tab fully without any network or join.
  Future<List<Chapter>> getRecentChapters({int limit = 100}) async {
    try {
      return await _isar.chapters
          .where()
          .sortByFetchedAtDesc()
          .limit(limit)
          .findAll();
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Returns chapters that are currently in-progress (opened but not finished).
  /// Useful for a "Continue Reading" widget that works fully offline.
  Future<List<Chapter>> getInProgressChapters({int limit = 20}) async {
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
    await _isar.writeTxn(() async {
      final existing = await _isar.categorys.where().findAll();
      final existingMap = {for (var e in existing) e.serverId: e.id};
      for (var c in categories) {
        if (existingMap.containsKey(c.serverId)) {
          c.id = existingMap[c.serverId]!;
        }
      }
      final newServerIds = categories.map((c) => c.serverId).whereType<int>().toSet();
      final toDelete = existing.where((e) => !newServerIds.contains(e.serverId)).map((e) => e.id).toList();
      await _isar.categorys.deleteAll(toDelete);
      await _isar.categorys.putAll(categories);
    });
  }

  Future<void> deleteCategory(int serverId) async {
    await _isar.writeTxn(() async {
      final cat = await _isar.categorys.filter().serverIdEqualTo(serverId).findFirst();
      if (cat != null) {
        await _isar.categorys.delete(cat.id);
      }
    });
  }

  Future<List<Category>> getCategories() async {
    return await _isar.categorys.where().sortByOrder().findAll();
  }

  // ── SYNC RECORD CRUD ────────────────────────────────────
  Future<void> saveSyncRecord(SyncRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.syncRecords.put(record);
    });
  }

  Future<List<SyncRecord>> getPendingSyncRecords() async {
    return await _isar.syncRecords.filter().stateEqualTo(SyncRecordState.pending).or().stateEqualTo(SyncRecordState.failed).findAll();
  }

  Future<void> deleteSyncRecord(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.syncRecords.delete(id);
    });
  }

  // ── DATABASE MAINTENANCE ────────────────────────────────
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }
}
