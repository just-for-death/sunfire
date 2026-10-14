// lib/src/core/sync/mihon_adapter.dart
//
// Mihon/Tachiyomi Adapter — local extension scraping, no server sync.
// Part of S4.1: Multi-server support — simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/category.dart';
import '../db/models/chapter.dart' show Chapter, mintLocalChapterServerId;
import '../db/models/manga.dart' show Manga, stableLocalMangaServerId;
import '../engine/quickjs_service.dart';
import 'server_adapter.dart' show ServerAdapter, SyncOperation, LibrarySnapshot, ChapterPagesResult, TrackerProgress;
import 'server_capabilities.dart' show ServerCapabilities;
import 'server_type.dart' show ServerConfigManager;

/// Mihon/Tachiyomi adapter for local extension scraping.
/// This doesn't connect to a server - it scrapes sources locally.
class MihonAdapter extends ServerAdapter {
  MihonAdapter(super.config);

  final QuickJsService _quickJs = QuickJsService.instance;
  ServerCapabilities? _capabilities;

  @override
  bool supports(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.fetchLibrary:
      case SyncOperation.searchManga:
      case SyncOperation.fetchChapterPages:
      case SyncOperation.mangaManagement:
      case SyncOperation.categoryManagement:
        return true;
      case SyncOperation.syncReadingProgress:
      case SyncOperation.syncTrackerProgress:
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

    // Initialize QuickJS if needed
    try {
      await _quickJs.initialize();
    } catch (e) {
      debugPrint('[MihonAdapter] QuickJS init failed: $e');
    }

    return await probeCapabilities();
  }

  @override
  Future<ServerCapabilities> probeCapabilities() async {
    _capabilities = ServerCapabilities(
      version: 'local',
      buildType: 'extension',
      probed: true,
      hasAddManga: true, // Can add manga from local sources
      hasUserField: false,
      hasUserSettings: false,
      hasExtensionStores: true,
      hasChapterFetchMarkers: false,
      hasCategoryIsDefaultCategory: false,
    );
    await ServerConfigManager.instance.updateCapabilities(config.id, _capabilities!.toJson());
    return _capabilities!;
  }

  @override
  Future<bool> isReachable() async {
    // Always "reachable" for local scraping
    return true;
  }

  // ─── Library Sync ──────────────────────────────────────────────────────

  @override
  Future<LibrarySnapshot> fetchLibrary({bool forceRefresh = false}) async {
    // For Mihon, "library" means locally tracked manga from extensions
    try {
      final localManga = await IsarService.instance.getLibraryManga();
      final categories = await IsarService.instance.getCategories();

      return LibrarySnapshot(
        manga: localManga,
        categories: categories,
        timestamp: DateTime.now(),
        isComplete: true,
        totalCount: localManga.length,
      );
    } catch (e) {
      debugPrint('[MihonAdapter] fetchLibrary failed: $e');
      return LibrarySnapshot.empty();
    }
  }

  @override
  Future<Manga?> fetchManga(int mangaId) async {
    try {
      return await IsarService.instance.getManga(mangaId);
    } catch (e) {
      debugPrint('[MihonAdapter] fetchManga failed: $e');
      return null;
    }
  }

  @override
  Future<List<Chapter>> fetchChapters(int mangaId) async {
    try {
      return await IsarService.instance.getChaptersForManga(mangaId);
    } catch (e) {
      debugPrint('[MihonAdapter] fetchChapters failed: $e');
      return [];
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    try {
      return await IsarService.instance.getCategories();
    } catch (e) {
      debugPrint('[MihonAdapter] fetchCategories failed: $e');
      return [];
    }
  }

  @override
  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    // Local search over stored library (no server-side search for extensions).
    try {
      final q = query.toLowerCase();
      final all = await IsarService.instance.getAllManga();
      return all
          .where((m) =>
              m.title.toLowerCase().contains(q) ||
              (m.author?.toLowerCase().contains(q) ?? false))
          .take(limit)
          .toList();
    } catch (e) {
      debugPrint('[MihonAdapter] searchManga failed: $e');
      return [];
    }
  }

  // ─── Chapter Operations ────────────────────────────────────────────────

  @override
  Future<ChapterPagesResult> fetchChapterPages(int chapterId) async {
    try {
      final chapter =
          await IsarService.instance.getChapterByServerId(chapterId);
      if (chapter == null) return const ChapterPagesResult(pages: []);

      // Fetch via local extension.
      if (chapter.realUrl.isNotEmpty && chapter.mangaId > 0) {
        final manga = await IsarService.instance.getManga(chapter.mangaId);
        final sourceName = manga?.sourceName ?? '';
        if (sourceName.isNotEmpty) {
          final pages = await _quickJs.fetchChapterPagesLocal(
            sourceName,
            chapter.realUrl,
          );
          if (pages.isNotEmpty) {
            return ChapterPagesResult(pages: pages);
          }
        }
      }
    } catch (e) {
      debugPrint('[MihonAdapter] fetchChapterPages failed: $e');
    }
    return const ChapterPagesResult(pages: []);
  }

  @override
  Future<Chapter?> fetchChapter(int chapterId) async {
    try {
      return await IsarService.instance.getChapterByServerId(chapterId);
    } catch (e) {
      debugPrint('[MihonAdapter] fetchChapter failed: $e');
      return null;
    }
  }

  @override
  Future<bool> updateChapterReadStatus({
    required int chapterId,
    required bool isRead,
    int? lastPageRead,
    DateTime? readAt,
  }) async {
    try {
      final chapter = await IsarService.instance.getChapterByServerId(chapterId);
      if (chapter != null) {
        chapter.isRead = isRead;
        if (lastPageRead != null) chapter.lastPageRead = lastPageRead;
        if (readAt != null) chapter.lastReadAt = readAt.millisecondsSinceEpoch ~/ 1000;
        await IsarService.instance.saveChapter(chapter);
        return true;
      }
    } catch (e) {
      debugPrint('[MihonAdapter] updateChapterReadStatus failed: $e');
    }
    return false;
  }

  @override
  Future<bool> updateReadingProgress({
    required int chapterId,
    required int lastPageRead,
    required int pageCount,
    DateTime? readAt,
  }) async {
    try {
      final chapter = await IsarService.instance.getChapterByServerId(chapterId);
      if (chapter != null) {
        chapter.lastPageRead = lastPageRead;
        if (pageCount > 0) chapter.pageCount = pageCount;
        if (readAt != null) chapter.lastReadAt = readAt.millisecondsSinceEpoch ~/ 1000;
        await IsarService.instance.saveChapter(chapter);
        return true;
      }
    } catch (e) {
      debugPrint('[MihonAdapter] updateReadingProgress failed: $e');
    }
    return false;
  }

  // ─── Manga Operations ──────────────────────────────────────────────────

  @override
  Future<Manga?> addManga({
    required String sourceId,
    required String mangaUrl,
    List<int>? categoryIds,
  }) async {
    try {
      final detail = await _quickJs.fetchMangaDetailsLocal(sourceId, mangaUrl);
      if (!detail.containsKey('chapters')) return null;

      final title = detail['title']?.toString() ?? 'Unknown';
      final mangaServerId = stableLocalMangaServerId(
        sourceName: sourceId,
        url: mangaUrl,
        title: title,
      );

      final manga = Manga()
        ..serverId = mangaServerId
        ..sourceName = sourceId
        ..url = mangaUrl
        ..title = title
        ..author = detail['author']?.toString()
        ..artist = detail['artist']?.toString()
        ..description = detail['description']?.toString()
        ..status = detail['status']?.toString()
        ..thumbnailUrl = detail['thumbnailUrl']?.toString()
        ..categoryIds = categoryIds ?? []
        ..inLibraryAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await IsarService.instance.saveManga(manga);

      // Save chapters using the collision-safe synthetic id scheme.
      final rawChapters = detail['chapters'] as List<dynamic>?;
      if (rawChapters != null) {
        final takenIds = <int>{};
        final chapters = <Chapter>[];
        for (int i = 0; i < rawChapters.length; i++) {
          final chMap = rawChapters[i] as Map<String, dynamic>;
          final chUrl = (chMap['url'] ?? chMap['link'] ?? '').toString();
          if (chUrl.isNotEmpty) {
            final chServerId = mintLocalChapterServerId(
              mangaId: manga.canonicalKey,
              index: i,
              takenServerIds: takenIds,
            );
            takenIds.add(chServerId);
            chapters.add(Chapter()
              ..serverId = chServerId
              ..mangaId = manga.canonicalKey
              ..name = chMap['name']?.toString() ?? 'Chapter ${i + 1}'
              ..chapterNumber = (chMap['chapterNumber'] as num?)?.toDouble() ?? (i + 1).toDouble()
              ..url = chUrl
              ..realUrl = chUrl
              ..mangaTitle = manga.title
              ..mangaThumbnailUrl = manga.thumbnailUrl
              ..isRead = false
              ..lastPageRead = 0);
          }
        }
        if (chapters.isNotEmpty) {
          await IsarService.instance.saveChapters(chapters);
        }
      }

      return manga;
    } catch (e) {
      debugPrint('[MihonAdapter] addManga failed: $e');
      return null;
    }
  }

  @override
  Future<Manga?> updateManga(Manga manga) async {
    try {
      await IsarService.instance.saveManga(manga);
      return manga;
    } catch (e) {
      debugPrint('[MihonAdapter] updateManga failed: $e');
      return null;
    }
  }

  @override
  Future<bool> removeManga(int mangaId) async {
    try {
      await IsarService.instance.deleteManga(mangaId);
      return true;
    } catch (e) {
      debugPrint('[MihonAdapter] removeManga failed: $e');
      return false;
    }
  }

  @override
  Future<Manga?> updateMangaCategories({
    required int mangaId,
    required List<int> categoryIds,
  }) async {
    try {
      final manga = await IsarService.instance.getManga(mangaId);
      if (manga != null) {
        manga.categoryIds = categoryIds;
        await IsarService.instance.saveManga(manga);
        return manga;
      }
    } catch (e) {
      debugPrint('[MihonAdapter] updateMangaCategories failed: $e');
    }
    return null;
  }

  // ─── Category Operations ───────────────────────────────────────────────

  @override
  Future<Category?> createCategory({
    required String name,
    int? order,
    bool isDefault = false,
  }) async {
    try {
      final category = Category()
        ..name = name
        ..order = order ?? 0
        ..isDefault = isDefault
        ..isDefaultCategory = isDefault;
      await IsarService.instance.saveCategory(category);
      return category;
    } catch (e) {
      debugPrint('[MihonAdapter] createCategory failed: $e');
      return null;
    }
  }

  @override
  Future<Category?> updateCategory(Category category) async {
    try {
      await IsarService.instance.saveCategory(category);
      return category;
    } catch (e) {
      debugPrint('[MihonAdapter] updateCategory failed: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    try {
      await IsarService.instance.deleteCategory(categoryId);
      return true;
    } catch (e) {
      debugPrint('[MihonAdapter] deleteCategory failed: $e');
      return false;
    }
  }

  // ─── Progress/Tracker Sync ─────────────────────────────────────────────

  @override
  Future<bool> syncReadingProgress(int mangaId) async {
    return false; // Local only
  }

  @override
  Future<TrackerProgress?> fetchTrackerProgress(int mangaId) async {
    return null; // Not supported
  }

  @override
  Future<bool> updateTrackerProgress(TrackerProgress progress) async {
    return false; // Not supported
  }

  // ─── Download Operations ───────────────────────────────────────────────

  @override
  Future<String?> getChapterDownloadUrl(int chapterId) async {
    return null; // Local reading only
  }

  @override
  bool get supportsChapterDownload => false;

  // ─── Utility ───────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    // Nothing to close for local adapter
  }
}