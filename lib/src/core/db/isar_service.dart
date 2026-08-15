import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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
      inspector: true,
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

  Future<List<Manga>> getLibraryManga() async {
    return await _isar.mangas.filter().inLibraryEqualTo(true).findAll();
  }

  Future<Manga?> getMangaByServerId(int serverId) async {
    return await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
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

  Future<List<Chapter>> getChaptersForManga(int mangaId) async {
    return await _isar.chapters.filter().mangaIdEqualTo(mangaId).sortByChapterNumberDesc().findAll();
  }

  Future<Chapter?> getChapterByServerId(int serverId) async {
    return await _isar.chapters.filter().serverIdEqualTo(serverId).findFirst();
  }

  Future<List<Chapter>> getReadingHistory() async {
    final list = await _isar.chapters.filter().isReadEqualTo(true).findAll();
    list.sort((a, b) => (b.lastReadAt ?? 0).compareTo(a.lastReadAt ?? 0));
    return list;
  }

  // ── CATEGORY CRUD ───────────────────────────────────────
  Future<void> saveCategories(List<Category> categories) async {
    await _isar.writeTxn(() async {
      await _isar.categorys.clear();
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
