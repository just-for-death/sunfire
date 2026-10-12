// lib/src/core/sync/kavita_adapter.dart
//
// Kavita Server Adapter — REST API + GraphQL for Kavita.
// Part of S4.1: Multi-server support — simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'server_adapter.dart' show ServerAdapter, SyncOperation, LibrarySnapshot, ChapterPagesResult, TrackerProgress;
import 'server_type.dart' show ServerConfig, ServerConfigManager;
import 'server_capabilities.dart' show ServerCapabilities;
import '../db/models/manga.dart';
import '../db/models/chapter.dart';
import '../db/models/category.dart';

/// Kavita server adapter using REST API.
class KavitaAdapter extends ServerAdapter {
  KavitaAdapter(super.config);

  late final Dio _dio;
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

    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl.replaceAll(RegExp(r'/+$'), ''),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        ...config.getAuthHeaders(),
      },
    ));

    return await probeCapabilities();
  }

  @override
  Future<ServerCapabilities> probeCapabilities() async {
    if (config.baseUrl.isEmpty) {
      return ServerCapabilities.empty;
    }

    try {
      final response = await _dio.get('/api/Server/info');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _capabilities = ServerCapabilities(
          version: data['version']?.toString(),
          buildType: data['buildType']?.toString(),
          probed: true,
        );
        await ServerConfigManager.instance.updateCapabilities(config.id, _capabilities!.toJson());
        return _capabilities!;
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] Capability probe failed: $e');
    }
    return ServerCapabilities.empty;
  }

  @override
  Future<bool> isReachable() async {
    if (config.baseUrl.isEmpty) return false;
    try {
      final response = await _dio.get('/api/Server/ping');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Library Sync ──────────────────────────────────────────────────────

  @override
  Future<LibrarySnapshot> fetchLibrary({bool forceRefresh = false}) async {
    if (config.baseUrl.isEmpty) return LibrarySnapshot.empty();

    try {
      final mangaResponse = await _dio.get('/api/Series', queryParameters: {
        'page': 0,
        'pageSize': 1000,
      });

      final categoryResponse = await _dio.get('/api/Categories');

      final mangaList = <Manga>[];
      if (mangaResponse.statusCode == 200) {
        final data = mangaResponse.data as Map<String, dynamic>;
        final items = data['items'] as List? ?? [];
        for (final item in items) {
          mangaList.add(_parseManga(Map<String, dynamic>.from(item as Map)));
        }
      }

      final categories = <Category>[];
      if (categoryResponse.statusCode == 200) {
        final data = categoryResponse.data as Map<String, dynamic>;
        final items = data['items'] as List? ?? [];
        for (final item in items) {
          categories.add(_parseCategory(Map<String, dynamic>.from(item as Map)));
        }
      }

      return LibrarySnapshot(
        manga: mangaList,
        categories: categories,
        timestamp: DateTime.now(),
        isComplete: true,
        totalCount: mangaList.length,
      );
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchLibrary failed: $e');
      return LibrarySnapshot.empty();
    }
  }

  @override
  Future<Manga?> fetchManga(int mangaId) async {
    try {
      final response = await _dio.get('/api/Series/$mangaId');
      if (response.statusCode == 200) {
        return _parseManga(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchManga failed: $e');
    }
    return null;
  }

  @override
  Future<List<Chapter>> fetchChapters(int mangaId) async {
    try {
      final response = await _dio.get('/api/Series/$mangaId/chapters');
      if (response.statusCode == 200) {
        final items = response.data as List? ?? [];
        return items.whereType<Map>().map((m) => _parseChapter(Map<String, dynamic>.from(m))).toList();
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchChapters failed: $e');
    }
    return [];
  }

  @override
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get('/api/Categories');
      if (response.statusCode == 200) {
        final items = response.data['items'] as List? ?? [];
        return items.whereType<Map>().map((m) => _parseCategory(Map<String, dynamic>.from(m))).toList();
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchCategories failed: $e');
    }
    return [];
  }

  @override
  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get('/api/Series/search', queryParameters: {
        'searchTerm': query,
        'pageSize': limit,
      });
      if (response.statusCode == 200) {
        final items = response.data['items'] as List? ?? [];
        return items.whereType<Map>().map((m) => _parseManga(Map<String, dynamic>.from(m))).toList();
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] searchManga failed: $e');
    }
    return [];
  }

  // ─── Chapter Operations ────────────────────────────────────────────────

  @override
  Future<ChapterPagesResult> fetchChapterPages(int chapterId) async {
    try {
      final response = await _dio.get('/api/Chapter/$chapterId/images');
      if (response.statusCode == 200) {
        final items = response.data as List? ?? [];
        final pages = items.map((i) => i['url']?.toString() ?? '').where((u) => u.isNotEmpty).toList();
        return ChapterPagesResult(pages: pages);
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchChapterPages failed: $e');
    }
    return ChapterPagesResult(pages: []);
  }

  @override
  Future<Chapter?> fetchChapter(int chapterId) async {
    try {
      final response = await _dio.get('/api/Chapter/$chapterId');
      if (response.statusCode == 200) {
        return _parseChapter(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] fetchChapter failed: $e');
    }
    return null;
  }

  @override
  Future<bool> updateChapterReadStatus({
    required int chapterId,
    required bool isRead,
    int? lastPageRead,
    DateTime? readAt,
  }) async {
    // Kavita doesn't support read status updates via API
    return false;
  }

  @override
  Future<bool> updateReadingProgress({
    required int chapterId,
    required int lastPageRead,
    required int pageCount,
    DateTime? readAt,
  }) async {
    // Kavita doesn't support reading progress updates via API
    return false;
  }

  // ─── Manga Operations ──────────────────────────────────────────────────

  @override
  Future<Manga?> addManga({
    required String sourceId,
    required String mangaUrl,
    List<int>? categoryIds,
  }) async {
    // Kavita doesn't support adding manga via API (library managed by server)
    return null;
  }

  @override
  Future<Manga?> updateManga(Manga manga) async {
    // Kavita doesn't support updating manga metadata via API
    return null;
  }

  @override
  Future<bool> removeManga(int mangaId) async {
    try {
      final response = await _dio.delete('/api/Series/$mangaId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[KavitaAdapter] removeManga failed: $e');
      return false;
    }
  }

  @override
  Future<Manga?> updateMangaCategories({
    required int mangaId,
    required List<int> categoryIds,
  }) async {
    // Not supported via Kavita API
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
      final response = await _dio.post('/api/Categories', data: {
        'name': name,
        'order': order ?? 0,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseCategory(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] createCategory failed: $e');
    }
    return null;
  }

  @override
  Future<Category?> updateCategory(Category category) async {
    try {
      final response = await _dio.put('/api/Categories/${category.id}', data: {
        'name': category.name,
        'order': category.order,
      });
      if (response.statusCode == 200) {
        return _parseCategory(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] updateCategory failed: $e');
    }
    return null;
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await _dio.delete('/api/Categories/$categoryId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[KavitaAdapter] deleteCategory failed: $e');
      return false;
    }
  }

  // ─── Progress/Tracker Sync ─────────────────────────────────────────────

  @override
  Future<bool> syncReadingProgress(int mangaId) async {
    return false; // Not supported
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
    try {
      final response = await _dio.get('/api/Chapter/$chapterId/download');
      if (response.statusCode == 200) {
        return response.data['downloadUrl']?.toString();
      }
    } catch (e) {
      debugPrint('[KavitaAdapter] getChapterDownloadUrl failed: $e');
    }
    return null;
  }

  @override
  bool get supportsChapterDownload => true;

  // ─── Utility ───────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    _dio.close();
  }

  // ─── Parsing Helpers ───────────────────────────────────────────────────

  Manga _parseManga(Map<String, dynamic> data) {
    return Manga()
      ..id = data['id'] as int? ?? 0
      ..serverId = data['id'] as int? ?? 0
      ..title = data['name']?.toString() ?? ''
      ..author = data['author']?.toString()
      ..artist = data['artist']?.toString()
      ..description = data['description']?.toString()
      ..status = data['status']?.toString()
      ..thumbnailUrl = data['imageUrl']?.toString()
      ..url = data['url']?.toString() ?? ''
      ..categoryIds = (data['categories'] as List?)
              ?.map((c) => c['id'] as int? ?? 0)
              .where((id) => id > 0)
              .toList() ??
          [];
  }

  Chapter _parseChapter(Map<String, dynamic> data) {
    return Chapter()
      ..id = data['id'] as int? ?? 0
      ..serverId = data['id'] as int? ?? 0
      ..mangaId = data['seriesId'] as int? ?? 0
      ..name = data['name']?.toString() ?? ''
      ..chapterNumber = (data['number'] as num?)?.toDouble() ?? 0
      ..pageCount = data['pageCount'] as int? ?? 0
      ..url = data['url']?.toString() ?? ''
      ..isRead = data['read'] as bool? ?? false
      ..lastPageRead = data['lastReadPage'] as int? ?? 0
      ..uploadDate = (data['uploadDate'] as num?)?.toInt() ?? 0;
  }

  Category _parseCategory(Map<String, dynamic> data) {
    return Category()
      ..id = data['id'] as int? ?? 0
      ..serverId = data['id'] as int? ?? 0
      ..name = data['name']?.toString() ?? ''
      ..order = data['order'] as int? ?? 0
      ..isDefault = data['isDefault'] as bool? ?? false;
  }
}