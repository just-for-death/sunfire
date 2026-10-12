// lib/src/core/sync/suwayomi_adapter.dart
//
// Suwayomi Server Adapter - wraps GraphQLClientService for Suwayomi/Tachidesk.
// Part of S4.1: Multi-server support - simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import 'server_adapter.dart'
    show
        ServerAdapter,
        SyncOperation,
        LibrarySnapshot,
        ChapterPagesResult,
        TrackerProgress;
import 'server_type.dart' show ServerConfig;
import 'server_capabilities.dart' show ServerCapabilities;
import 'server_type.dart' show ServerConfigManager;
import 'graphql_client_service.dart' show GraphQLClientService;
import 'sync_engine.dart' show SyncEngine, parseCategoryNodes;
import '../db/models/manga.dart';
import '../db/models/chapter.dart';
import '../db/models/category.dart';

/// Suwayomi/Tachidesk server adapter using GraphQL API.
class SuwayomiAdapter extends ServerAdapter {
  SuwayomiAdapter(super.config);

  GraphQLClientService get _client => GraphQLClientService.instance;

  @override
  bool supports(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.fetchLibrary:
      case SyncOperation.searchManga:
      case SyncOperation.fetchChapterPages:
      case SyncOperation.syncReadingProgress:
      case SyncOperation.syncTrackerProgress:
      case SyncOperation.mangaManagement:
      case SyncOperation.categoryManagement:
        return true;
      case SyncOperation.chapterDownload:
      case SyncOperation.offlineSync:
        return false;
    }
  }

  @override
  Future<ServerCapabilities> initialize() async {
    if (config.baseUrl.isEmpty) {
      return ServerCapabilities.empty;
    }

    _client.initialize(config.baseUrl, authToken: config.authToken);
    _client.authRefresher = null;

    return await probeCapabilities();
  }

  @override
  Future<ServerCapabilities> probeCapabilities() async {
    if (config.baseUrl.isEmpty) {
      return ServerCapabilities.empty;
    }

    try {
      final caps = await _client.probeServerCapabilities();
      await ServerConfigManager.instance
          .updateCapabilities(config.id, caps.toJson());
      return caps;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] Capability probe failed: $e');
      return ServerCapabilities.empty;
    }
  }

  @override
  Future<bool> isReachable() async {
    if (config.baseUrl.isEmpty) return false;
    return await _client.checkServerReachable();
  }

  // --- Library Sync ---

  @override
  Future<LibrarySnapshot> fetchLibrary({bool forceRefresh = false}) async {
    if (config.baseUrl.isEmpty) return LibrarySnapshot.empty();

    try {
      final libData = await _client.fetchLibrary();
      final catData = await _client.fetchCategories();

      final mangaList = <Manga>[];
      final nodes = libData?['mangas']?['nodes'] as List?;
      if (nodes != null) {
        for (final n in nodes.whereType<Map>()) {
          mangaList.add(SyncEngine.instance
              .parseMangaNode(Map<String, dynamic>.from(n)));
        }
      }

      final categories = <Category>[];
      final catNodes = catData?['categories']?['nodes'] as List?;
      if (catNodes != null) {
        categories.addAll(parseCategoryNodes(catNodes));
      }

      return LibrarySnapshot(
        manga: mangaList,
        categories: categories,
        timestamp: DateTime.now(),
        isComplete: true,
        totalCount: mangaList.length,
      );
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchLibrary failed: $e');
      return LibrarySnapshot.empty();
    }
  }

  @override
  Future<Manga?> fetchManga(int mangaId) async {
    try {
      final data = await _client.fetchMangaDetails(mangaId);
      final node = data?['manga'];
      if (node is Map) {
        return SyncEngine.instance
            .parseMangaNode(Map<String, dynamic>.from(node));
      }
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchManga failed: $e');
    }
    return null;
  }

  @override
  Future<List<Chapter>> fetchChapters(int mangaId) async {
    try {
      final data = await _client.fetchMangaDetails(mangaId);
      final nodes = data?['chapters']?['nodes'] as List?;
      if (nodes == null) return [];
      return nodes
          .whereType<Map>()
          .map((n) => SyncEngine.instance
              .parseChapterNode(Map<String, dynamic>.from(n)))
          .toList();
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchChapters failed: $e');
      return [];
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    try {
      final data = await _client.fetchCategories();
      final nodes = data?['categories']?['nodes'] as List?;
      if (nodes == null) return [];
      return parseCategoryNodes(nodes);
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchCategories failed: $e');
      return [];
    }
  }

  @override
  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    // Suwayomi has no global search API; search is per-source. Enumerate
    // sources and search each, capped to keep this bounded.
    final results = <Manga>[];
    try {
      final sourcesData = await _client.fetchSources();
      final sourceNodes = sourcesData?['sources']?['nodes'] as List? ?? [];
      for (final s in sourceNodes.take(10)) {
        if (results.length >= limit) break;
        final sourceId = (s as Map)['id']?.toString();
        if (sourceId == null || sourceId.isEmpty) continue;
        try {
          final res = await _client.fetchSourceManga(sourceId,
              searchQuery: query);
          final mangas = res?['fetchSourceManga']?['mangas'] as List? ?? [];
          for (final m in mangas.whereType<Map>()) {
            if (results.length >= limit) break;
            results.add(Manga()
              ..serverId = 0
              ..title = m['title']?.toString() ?? 'Untitled'
              ..thumbnailUrl = m['thumbnailUrl']?.toString()
              ..url = m['url']?.toString() ?? ''
              ..sourceName = sourceId);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[SuwayomiAdapter] searchManga failed: $e');
    }
    return results;
  }

  // --- Chapter Operations ---

  @override
  Future<ChapterPagesResult> fetchChapterPages(int chapterId) async {
    try {
      final data = await _client.fetchChapterPages(chapterId);
      final pages = data?['fetchChapterPages']?['pages'] as List?;
      if (pages == null) return const ChapterPagesResult(pages: []);
      return ChapterPagesResult(
          pages: pages.map((p) => p.toString()).toList());
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchChapterPages failed: $e');
      return const ChapterPagesResult(pages: []);
    }
  }

  @override
  Future<Chapter?> fetchChapter(int chapterId) async {
    // No single-chapter query; chapters come via fetchMangaDetails.
    // Kept for interface completeness; callers should use fetchChapters.
    debugPrint('[SuwayomiAdapter] fetchChapter not supported directly');
    return null;
  }

  @override
  Future<bool> updateChapterReadStatus({
    required int chapterId,
    required bool isRead,
    int? lastPageRead,
    DateTime? readAt,
  }) async {
    try {
      final data = await _client.updateChapterReadStatus(
          chapterId, isRead, lastPageRead ?? 0);
      return data != null;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] updateChapterReadStatus failed: $e');
      return false;
    }
  }

  @override
  Future<bool> updateReadingProgress({
    required int chapterId,
    required int lastPageRead,
    required int pageCount,
    DateTime? readAt,
  }) async {
    // Reading progress on Suwayomi is chapter-level read state.
    return updateChapterReadStatus(
      chapterId: chapterId,
      isRead: pageCount > 0 && lastPageRead >= pageCount - 1,
      lastPageRead: lastPageRead,
      readAt: readAt,
    );
  }

  // --- Manga Operations ---

  @override
  Future<Manga?> addManga({
    required String sourceId,
    required String mangaUrl,
    List<int>? categoryIds,
  }) async {
    // Modern Suwayomi dropped addManga; resolve via fetchMangaIdByUrl then
    // set library state + categories.
    try {
      final mangaId =
          await _client.fetchMangaIdByUrl(sourceId, mangaUrl);
      if (mangaId == null) return null;
      await _client.updateMangaLibraryState(mangaId, true);
      if (categoryIds != null && categoryIds.isNotEmpty) {
        await _client.updateMangaCategories(mangaId, categoryIds);
      }
      return await fetchManga(mangaId);
    } catch (e) {
      debugPrint('[SuwayomiAdapter] addManga failed: $e');
      return null;
    }
  }

  @override
  Future<Manga?> updateManga(Manga manga) async {
    // Suwayomi manga metadata is source-driven; library state is the
    // mutable part. Keep categories in sync.
    try {
      if (manga.serverId > 0 && manga.categoryIds.isNotEmpty) {
        await _client.updateMangaCategories(manga.serverId, manga.categoryIds);
      }
      return manga.serverId > 0 ? await fetchManga(manga.serverId) : manga;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] updateManga failed: $e');
      return null;
    }
  }

  @override
  Future<bool> removeManga(int mangaId) async {
    try {
      final data = await _client.updateMangaLibraryState(mangaId, false);
      return data != null;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] removeManga failed: $e');
      return false;
    }
  }

  @override
  Future<Manga?> updateMangaCategories({
    required int mangaId,
    required List<int> categoryIds,
  }) async {
    try {
      final data = await _client.updateMangaCategories(mangaId, categoryIds);
      if (data == null) return null;
      return await fetchManga(mangaId);
    } catch (e) {
      debugPrint('[SuwayomiAdapter] updateMangaCategories failed: $e');
      return null;
    }
  }

  // --- Category Operations ---

  @override
  Future<Category?> createCategory({
    required String name,
    int? order,
    bool isDefault = false,
  }) async {
    try {
      final data = await _client.createCategory(name);
      final node = data?['createCategory']?['category'];
      if (node is Map) {
        final parsed =
            parseCategoryNodes([Map<String, dynamic>.from(node)]);
        if (parsed.isNotEmpty) return parsed.first;
      }
      return null;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] createCategory failed: $e');
      return null;
    }
  }

  @override
  Future<Category?> updateCategory(Category category) async {
    try {
      final data = await _client.updateCategoryName(
          category.serverId, category.name);
      if (data == null) return null;
      if (category.order >= 0) {
        await _client.updateCategoryOrder(category.serverId, category.order);
      }
      return category;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] updateCategory failed: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    // No delete-category mutation in the verified API surface; Suwayomi
    // manages the Default category as id 0 which must not be removed.
    debugPrint('[SuwayomiAdapter] deleteCategory not supported by server API');
    return false;
  }

  // --- Progress/Tracker Sync ---

  @override
  Future<bool> syncReadingProgress(int mangaId) async {
    try {
      final data = await _client.trackProgress(mangaId);
      return data != null;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] syncReadingProgress failed: $e');
      return false;
    }
  }

  @override
  Future<TrackerProgress?> fetchTrackerProgress(int mangaId) async {
    try {
      final data = await _client.fetchTrackRecords(mangaId);
      final nodes = data?['trackRecords']?['nodes'] as List?;
      if (nodes == null || nodes.isEmpty) return null;
      final first = Map<String, dynamic>.from(nodes.first as Map);
      return TrackerProgress(
        mangaId: mangaId,
        trackerId: first['trackerId'] as int?,
        status: first['status']?.toString(),
        score: (first['score'] as num?)?.toDouble(),
        lastChapterRead: (first['lastChapterRead'] as num?)?.toInt(),
      );
    } catch (e) {
      debugPrint('[SuwayomiAdapter] fetchTrackerProgress failed: $e');
      return null;
    }
  }

  @override
  Future<bool> updateTrackerProgress(TrackerProgress progress) async {
    try {
      final data = await _client.fetchTrackRecords(progress.mangaId);
      final nodes = data?['trackRecords']?['nodes'] as List?;
      if (nodes == null || nodes.isEmpty) return false;
      final recordId =
          (nodes.first as Map)['id'] as int? ?? 0;
      if (recordId <= 0) return false;
      final res = await _client.updateTrack(
        recordId: recordId,
        lastChapterRead:
            (progress.lastChapterRead ?? progress.progress ?? 0).toDouble(),
      );
      return res != null;
    } catch (e) {
      debugPrint('[SuwayomiAdapter] updateTrackerProgress failed: $e');
      return false;
    }
  }

  // --- Download Operations ---

  @override
  Future<String?> getChapterDownloadUrl(int chapterId) async {
    return null;
  }

  @override
  bool get supportsChapterDownload => false;

  // --- Utility ---

  @override
  Future<void> close() async {
    // GraphQLClientService is a singleton shared with SyncEngine;
    // do not reset it here.
  }
}
