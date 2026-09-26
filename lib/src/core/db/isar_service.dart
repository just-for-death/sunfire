import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';

import 'list_chunks.dart';
import 'models/category.dart';
import 'models/chapter.dart';
import 'models/manga.dart';
import 'models/sync_meta.dart';
import 'models/sync_record.dart';

/// Max manga ids per `anyOf` chapter query in [IsarService.getChaptersForMangas].
const int kChapterQueryChunkSize = 200;

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

  /// Reserves an id for an offline-created entity that has no server id yet.
  /// Negative range never collides with real Suwayomi ids, and
  /// [isSyntheticServerId] lets sync code tell pending-local entities apart
  /// from server-backed ones. Used for offline manga, chapters and categories.
  static int generateSyntheticServerId() => _generateSyntheticServerId();

  /// True for ids produced by [generateSyntheticServerId] (offline-temp ids).
  static bool isSyntheticServerId(int id) => id < 0;

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
    // serverId is a unique-indexed field that is always populated on save
    // (real Suwayomi id, or a synthetic negative id for standalone manga), so
    // this lookup is authoritative. We deliberately do NOT fall back to
    // `_isar.mangas.get(serverId)` (Isar's local auto-increment id) — doing
    // so previously let an unrelated record with a colliding local id be
    // returned/overwritten whenever a server/synthetic id happened to match
    // some other manga's internal Isar id.
    return await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
  }

  /// Batched form of [getMangaByServerId] for callers that need to resolve
  /// many ids at once (e.g. back-filling titles/covers for a feed of chapters
  /// that span many series). Returns only the rows that exist — absent ids are
  /// simply missing from the result, exactly as a null from the single lookup.
  ///
  /// Chunked for the same reason as [getChaptersForMangas]: one giant `anyOf`
  /// filter over thousands of ids is slow to compile and run.
  Future<List<Manga>> getMangaByServerIds(List<int> serverIds) async {
    if (!_isInitialized || serverIds.isEmpty) return [];
    final ids = serverIds.where((id) => id != 0).toSet().toList();
    if (ids.isEmpty) return [];
    final out = <Manga>[];
    for (final chunk in chunkList(ids, kChapterQueryChunkSize)) {
      out.addAll(
        await _isar.mangas.filter().anyOf(chunk, (q, id) => q.serverIdEqualTo(id)).findAll(),
      );
    }
    return out;
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

  /// Deletes the given chapters outright.
  ///
  /// Used by the sync engine to prune chapters the server no longer reports.
  /// Callers are responsible for the wipe guard: an over-eager pass here is
  /// the only thing that can destroy a series' offline reading history, so
  /// never call this with a list derived from a partial or failed response.
  Future<void> deleteChapters(List<Chapter> chapters) async {
    if (!_isInitialized || chapters.isEmpty) return;
    // Never touch a chapter that has no persisted identity, and never a
    // local-scrape chapter (negative synthetic serverId) — those exist only
    // on this device and are not the sync engine's to reap.
    final deletable = chapters.where((c) => c.serverId > 0).toList();
    if (deletable.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.chapters.deleteAll(deletable.map((c) => c.id).toList());
    });
  }

  Future<List<Chapter>> getAllChapters() async {
    if (!_isInitialized) return [];
    return await _isar.chapters.where().findAll();
  }

  Future<List<Chapter>> getChaptersForManga(int mangaId) async {
    if (!_isInitialized) return [];
    // chapter.mangaId is always written as the parent manga's serverId (see
    // sync_engine.dart), never as Isar's local auto-increment id. If a caller
    // passes a manga's local Isar id by mistake, the old fallback here would
    // reinterpret it as *some other* manga's serverId (via `.get(mangaId)`,
    // an unrelated collection's key space) and could return that unrelated
    // manga's chapters. Do a single unambiguous lookup only.
    return await _isar.chapters.filter().mangaIdEqualTo(mangaId).sortByChapterNumberDesc().findAll();
  }

  /// Batched form of [getChaptersForManga] for callers that need chapters for
  /// every manga in a list (library refresh, unread-count recompute, batch
  /// actions). A chunked `anyOf` query plus an in-memory group-by avoids
  /// issuing one Isar query per manga, which is the dominant cost on large
  /// libraries.
  /// Batched form of [getChapterByServerId], keyed by `serverId`.
  ///
  /// Exists because the updates feed merges up to 100 server chapters per fetch
  /// and used to resolve each with its own awaited query — a sequential N+1 on
  /// the hot path of every pull-to-refresh and every background sync. Chunked
  /// for the same reason as [getChaptersForMangas]: one giant `anyOf` filter is
  /// slow to compile and run.
  ///
  /// Absent ids are simply missing from the result, exactly as a null from the
  /// single lookup.
  Future<Map<int, Chapter>> getChaptersByServerIds(List<int> serverIds) async {
    final out = <int, Chapter>{};
    if (!_isInitialized || serverIds.isEmpty) return out;
    final ids = serverIds.where((id) => id != 0).toSet().toList();
    if (ids.isEmpty) return out;
    for (final chunk in chunkList(ids, kChapterQueryChunkSize)) {
      final rows = await _isar.chapters.filter().anyOf(chunk, (q, id) => q.serverIdEqualTo(id)).findAll();
      for (final r in rows) {
        out[r.serverId] = r;
      }
    }
    return out;
  }

  Future<Map<int, List<Chapter>>> getChaptersForMangas(List<int> mangaIds) async {
    if (!_isInitialized || mangaIds.isEmpty) return {};
    final ids = mangaIds.toSet().toList();
    final byManga = <int, List<Chapter>>{for (final id in ids) id: []};
    // Chunked: one giant OR filter over thousands of ids is slow to compile
    // and run, so query kChapterQueryChunkSize manga at a time.
    for (final chunk in chunkList(ids, kChapterQueryChunkSize)) {
      final rows = await _isar.chapters.filter().anyOf(chunk, (q, id) => q.mangaIdEqualTo(id)).findAll();
      for (final ch in rows) {
        (byManga[ch.mangaId] ??= []).add(ch);
      }
    }
    for (final list in byManga.values) {
      list.sort((a, b) => b.chapterNumber.compareTo(a.chapterNumber));
    }
    return byManga;
  }

  Future<Chapter?> getChapterByServerId(int serverId) async {
    if (!_isInitialized) return null;
    // See getMangaByServerId — serverId is unique-indexed and authoritative;
    // no fallback to the Isar local auto-increment id.
    return await _isar.chapters.filter().serverIdEqualTo(serverId).findFirst();
  }

  /// Lookup by Isar's LOCAL auto-increment id. Only for chapters that have no
  /// server id; never use this to resolve a server id.
  Future<Chapter?> getChapterByLocalId(int id) async {
    if (!_isInitialized || id <= 0) return null;
    return await _isar.chapters.get(id);
  }

  Future<List<Chapter>> getReadingHistory() async {
    if (!_isInitialized) return [];
    try {
      // Only surface history for manga still in the library — removed manga
      // leave their local chapter records behind, which must not show in History.
      final libraryManga = await getLibraryManga();
      final libraryIds = <int>{
        for (final m in libraryManga)
          // m.canonicalKey only. Adding m.id (the local Isar auto-increment)
          // put a second id space into a serverId-keyed set, and since both
          // spaces are small integers, a NON-library series whose serverId
          // collided with some library manga's local id surfaced in the
          // Updates feed, History and Continue Reading. The delete path had
          // this exact arm removed already; the three read paths had not.
          if (m.canonicalKey != 0) m.canonicalKey,
      };
      if (libraryIds.isEmpty) return [];

      final chapters = await _isar.chapters
          .filter()
          .lastReadAtGreaterThan(0)
          .sortByLastReadAtDesc()
          .findAll();
      return [
        for (final ch in chapters)
          if (libraryIds.contains(ch.mangaId)) ch,
      ];
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Returns chapters sorted by fetchedAt DESC — the offline Updates feed.
  /// Filters to manga currently marked inLibrary == true and chapters with
  /// valid fetchedAt > 0.
  ///
  /// No per-manga cap here. The cap is client-side, and now applied in three
  /// places that share the same thresholds: at ingestion by
  /// `applyFloodCapToNewChapters` (which zeroes `fetchedAt` on the excess, so
  /// those chapters are filtered out right here), at display time in
  /// `updates_screen.dart`, and as a one-time repair by
  /// `cleanupBulkScrapedUpdates`. The server imposes no such limit.
  Future<List<Chapter>> getRecentChapters({int limit = 300}) async {
    if (!_isInitialized) return [];
    try {
      final libraryManga = await getLibraryManga();
      final libraryIds = <int>{
        for (final m in libraryManga)
          // m.canonicalKey only. Adding m.id (the local Isar auto-increment)
          // put a second id space into a serverId-keyed set, and since both
          // spaces are small integers, a NON-library series whose serverId
          // collided with some library manga's local id surfaced in the
          // Updates feed, History and Continue Reading. The delete path had
          // this exact arm removed already; the three read paths had not.
          if (m.canonicalKey != 0) m.canonicalKey,
      };

      if (libraryIds.isEmpty) return [];

      // Fetch in pages of 300 and filter to library manga in Dart (Isar has no
      // `mangaIdIn(...)` filter). Keep pulling pages until we either have the
      // requested `limit` or have scanned the whole feed, instead of a single
      // `limit * 3` pre-fetch that under-fills when many recent chapters belong
      // to non-library manga.
      const pageSize = 300;
      final result = <Chapter>[];
      int offset = 0;
      const maxScan = 10000; // hard ceiling: never balloon memory on huge feeds
      while (result.length < limit && offset < maxScan) {
        final page = await _isar.chapters
            .filter()
            .fetchedAtGreaterThan(0)
            .sortByFetchedAtDesc()
            .offset(offset)
            .limit(pageSize)
            .findAll();
        if (page.isEmpty) break;
        for (final ch in page) {
          if (libraryIds.contains(ch.mangaId)) {
            result.add(ch);
            if (result.length >= limit) break;
          }
        }
        offset += page.length;
      }
      return result;
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  /// Cleans up ONLY synthetic standalone-scraped chapters that were bulk-stamped
  /// (e.g. the initial Mangago local extension scrape that writes fake serverIds).
  /// Real server chapters (positive serverId) are preserved.
  Future<void> cleanupBulkScrapedUpdates() async {
    if (!_isInitialized) return;
    try {
      final chaptersWithFetchedAt = await _isar.chapters
          .filter()
          .fetchedAtGreaterThan(0)
          .sortByChapterNumberDesc()
          .findAll();
      if (chaptersWithFetchedAt.isEmpty) return;

      // Identify standalone-scraped chapters: url non-empty and a synthetic
      // NEGATIVE serverId (the only range this app ever mints for standalone
      // chapters — see the -(...) formulas in detail/library/update/migrate).
      // A positive serverId — however large — is always a real Suwayomi one on
      // servers with big chapter tables, so never classify it as synthetic.
      final standaloneChapters = chaptersWithFetchedAt
          .where((ch) => ch.url.isNotEmpty && isSyntheticServerId(ch.serverId))
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
          if (bucketList.length > kFloodThresholdChapters) {
            // Keep the newest few (list already sorted Desc); zero the rest.
            // Same thresholds as the ingestion-time gate — see
            // applyFloodCapToNewChapters. This remains useful as a one-time
            // repair for floods that predate the ingestion gate, and for
            // rows written by paths that bypass it.
            for (int i = kFloodCapChapters; i < bucketList.length; i++) {
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
  /// Only library manga are included — chapters of titles removed from the
  /// library (or never added) must not surface in Continue Reading.
  Future<List<Chapter>> getInProgressChapters({int limit = 20}) async {
    if (!_isInitialized) return [];
    try {
      final libraryManga = await getLibraryManga();
      final libraryIds = <int>{
        for (final m in libraryManga)
          // m.canonicalKey only. Adding m.id (the local Isar auto-increment)
          // put a second id space into a serverId-keyed set, and since both
          // spaces are small integers, a NON-library series whose serverId
          // collided with some library manga's local id surfaced in the
          // Updates feed, History and Continue Reading. The delete path had
          // this exact arm removed already; the three read paths had not.
          if (m.canonicalKey != 0) m.canonicalKey,
      };
      if (libraryIds.isEmpty) return [];

      // Same paged scan as getRecentChapters: filter to library manga in Dart
      // (no mangaIdIn filter in the generated Isar query builder).
      const pageSize = 100;
      final result = <Chapter>[];
      int offset = 0;
      const maxScan = 5000;
      while (result.length < limit && offset < maxScan) {
        final page = await _isar.chapters
            .filter()
            .isReadEqualTo(false)
            .lastPageReadGreaterThan(0)
            .sortByLastReadAtDesc()
            .offset(offset)
            .limit(pageSize)
            .findAll();
        if (page.isEmpty) break;
        for (final ch in page) {
          if (libraryIds.contains(ch.mangaId)) {
            result.add(ch);
            if (result.length >= limit) break;
          }
        }
        offset += page.length;
      }
      return result;
    } catch (e, stack) {
      LoggerService.instance.logError('Isar query failed: $e', exception: e, stackTrace: stack, category: 'Database');
      return [];
    }
  }

  Future<void> deleteManga(int serverId) async {
    if (!_isInitialized) return;
    await _isar.writeTxn(() async {
      // No fallback to `.get(serverId)` — see getMangaByServerId. Deleting
      // whatever unrelated manga happened to own that local Isar id was the
      // cause of "wrong series disappeared" reports.
      final localManga = await _isar.mangas.filter().serverIdEqualTo(serverId).findFirst();
      // chapter.mangaId is always the manga's serverId (never its local
      // Isar id), so the `.or().mangaIdEqualTo(localManga.id)` arm below
      // matched by coincidence at best; drop it to avoid deleting chapters
      // that belong to a different manga whose serverId happens to equal
      // this manga's local id.
      final targetServerId = localManga?.serverId ?? serverId;
      if (localManga != null) {
        await _isar.mangas.delete(localManga.id);
      }
      final chapters = await _isar.chapters.filter().mangaIdEqualTo(targetServerId).findAll();
      if (chapters.isNotEmpty) {
        await _isar.chapters.deleteAll(chapters.map((c) => c.id).toList());
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
    Set<int> protectedIds = const {};
    if (replaceAll) {
      // Categories that only exist locally (offline-created, still waiting on
      // a queued create) have ids the server doesn't know about. A server pull
      // must not wipe them, or the pending create's id remap has nothing to
      // attach to and the category reappears as an uncategorizable orphan on
      // the server. Synthetic (negative) temp ids are covered too.
      protectedIds = (await getPendingCategoryRecords())
          .where((r) => r.action == SyncAction.create)
          .map((r) => int.tryParse(r.entityId))
          .whereType<int>()
          .toSet();
    }
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
        final toDelete = existing
            .where((e) =>
                !newServerIds.contains(e.serverId) &&
                !protectedIds.contains(e.serverId) &&
                !isSyntheticServerId(e.serverId))
            .map((e) => e.id)
            .toList();
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
      }
      // No fallback delete by `serverId` as a local id: a server category that
      // is no longer in the DB (already pulled-deleted) carries a positive
      // serverId that can collide with an unrelated row's auto-increment id,
      // silently deleting the wrong category.
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

  /// Failed AND abandoned records (the dead-end queue) — returned so they can be
  /// reset back to [SyncRecordState.pending] by a manual retry.
  Future<List<SyncRecord>> getFailedSyncRecords() async {
    if (!_isInitialized) return [];
    return await _isar.syncRecords.filter().stateEqualTo(SyncRecordState.failed).or().stateEqualTo(SyncRecordState.abandoned).findAll();
  }

  /// Fresh copy of a queued record by its Isar id, or null if it was deleted.
  /// The outbound flush uses this to avoid saving/deleting from a stale
  /// in-memory copy after a concurrent coalesce rewrote the payload.
  Future<SyncRecord?> getSyncRecord(Id id) async {
    if (!_isInitialized) return null;
    return await _isar.syncRecords.get(id);
  }

  /// Pending/failed (i.e. not in-flight, synced or abandoned) chapter records
  /// for one chapter. Filtered inside Isar, so per-page-turn callers don't
  /// materialize the whole queue the way [getPendingSyncRecords] does.
  ///
  /// One query per queued state rather than an Isar filter group, so this only
  /// relies on the `and()` / `Equal` filters already used elsewhere.
  Future<List<SyncRecord>> getPendingChapterRecords(String chapterEntityId) async {
    if (!_isInitialized) return [];
    final out = <SyncRecord>[];
    for (final state in const [SyncRecordState.pending, SyncRecordState.failed]) {
      out.addAll(await _isar.syncRecords
          .filter()
          .entityTypeEqualTo(SyncEntityType.chapter)
          .and()
          .entityIdEqualTo(chapterEntityId)
          .and()
          .stateEqualTo(state)
          .findAll());
    }
    return out;
  }

  /// Entity ids (chapter server ids, as strings) of every chapter that has an
  /// unsynced outbound mutation queued. One pass per sync, so server pulls can
  /// protect optimistic local state without a query per chapter.
  Future<Set<String>> getPendingChapterEntityIds() async {
    if (!_isInitialized) return <String>{};
    final ids = <String>{};
    for (final state in const [SyncRecordState.pending, SyncRecordState.failed]) {
      final records = await _isar.syncRecords
          .filter()
          .entityTypeEqualTo(SyncEntityType.chapter)
          .and()
          .stateEqualTo(state)
          .findAll();
      ids.addAll(records.map((r) => r.entityId));
    }
    return ids;
  }

  /// Pending/failed category records (create/rename/delete/assign). Used to
  /// rewrite queued 'assign' payloads after an offline-created category gets
  /// its real server id, without loading the whole queue.
  Future<List<SyncRecord>> getPendingCategoryRecords() async {
    if (!_isInitialized) return [];
    final out = <SyncRecord>[];
    for (final state in const [SyncRecordState.pending, SyncRecordState.failed]) {
      out.addAll(await _isar.syncRecords
          .filter()
          .entityTypeEqualTo(SyncEntityType.category)
          .and()
          .stateEqualTo(state)
          .findAll());
    }
    return out;
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
