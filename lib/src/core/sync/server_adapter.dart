// lib/src/core/sync/server_adapter.dart
//
// Server Adapter — abstract interface for different server types.
// Part of S4.1: Multi-server support — simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;

import 'server_type.dart';
import '../db/models/manga.dart';
import '../db/models/chapter.dart';
import '../db/models/category.dart';
import 'server_capabilities.dart';

/// Abstract interface for server adapters.
///
/// Each server type (Suwayomi, Kavita, Mihon, etc.) implements this interface
/// to provide a unified API for sync operations.
abstract class ServerAdapter {
  ServerAdapter(this.config);

  final ServerConfig config;

  /// Server type identifier.
  ServerType get type => config.type;

  /// Server display name.
  String get name => config.name;

  /// Base URL for API requests.
  String get baseUrl => config.baseUrl;

  /// Whether this adapter supports the given operation.
  bool supports(SyncOperation operation);

  /// Initialize the adapter (connect, authenticate, probe capabilities).
  Future<ServerCapabilities> initialize();

  /// Probe server capabilities.
  Future<ServerCapabilities> probeCapabilities();

  /// Check if server is reachable.
  Future<bool> isReachable();

  // ─── Library Sync ──────────────────────────────────────────────────────

  /// Fetch full library from server.
  Future<LibrarySnapshot> fetchLibrary({
    bool forceRefresh = false,
  });

  /// Fetch manga details by ID.
  Future<Manga?> fetchManga(int mangaId);

  /// Fetch manga chapters by manga ID.
  Future<List<Chapter>> fetchChapters(int mangaId);

  /// Fetch categories from server.
  Future<List<Category>> fetchCategories();

  /// Search manga on server.
  Future<List<Manga>> searchManga(String query, {int limit = 20});

  // ─── Chapter Operations ────────────────────────────────────────────────

  /// Fetch chapter pages (for reading).
  Future<ChapterPagesResult> fetchChapterPages(int chapterId);

  /// Fetch chapter details.
  Future<Chapter?> fetchChapter(int chapterId);

  /// Mark chapter as read/unread on server.
  Future<bool> updateChapterReadStatus({
    required int chapterId,
    required bool isRead,
    int? lastPageRead,
    DateTime? readAt,
  });

  /// Update reading progress on server.
  Future<bool> updateReadingProgress({
    required int chapterId,
    required int lastPageRead,
    required int pageCount,
    DateTime? readAt,
  });

  // ─── Manga Operations ──────────────────────────────────────────────────

  /// Add manga to library (if supported).
  Future<Manga?> addManga({
    required String sourceId,
    required String mangaUrl,
    List<int>? categoryIds,
  });

  /// Update manga metadata.
  Future<Manga?> updateManga(Manga manga);

  /// Remove manga from library.
  Future<bool> removeManga(int mangaId);

  /// Update manga categories.
  Future<Manga?> updateMangaCategories({
    required int mangaId,
    required List<int> categoryIds,
  });

  // ─── Category Operations ───────────────────────────────────────────────

  /// Create category.
  Future<Category?> createCategory({
    required String name,
    int? order,
    bool isDefault = false,
  });

  /// Update category.
  Future<Category?> updateCategory(Category category);

  /// Delete category.
  Future<bool> deleteCategory(int categoryId);

  // ─── Progress/Tracker Sync ─────────────────────────────────────────────

  /// Sync reading progress for a manga.
  Future<bool> syncReadingProgress(int mangaId);

  /// Fetch tracker progress from server.
  Future<TrackerProgress?> fetchTrackerProgress(int mangaId);

  /// Update tracker progress on server.
  Future<bool> updateTrackerProgress(TrackerProgress progress);

  // ─── Download Operations ───────────────────────────────────────────────

  /// Get download URL for chapter.
  Future<String?> getChapterDownloadUrl(int chapterId);

  /// Check if server supports chapter download.
  bool get supportsChapterDownload => false;

  // ─── Utility ───────────────────────────────────────────────────────────

  /// Close connections and cleanup.
  Future<void> close();

  /// Get server info for display.
  Map<String, dynamic> getServerInfo() {
    return {
      'type': type.name,
      'name': name,
      'baseUrl': baseUrl,
      'supports': SyncOperation.values
          .where(supports)
          .map((e) => e.name)
          .toList(),
    };
  }
}

/// Supported sync operations.
enum SyncOperation {
  /// Basic library fetch
  fetchLibrary,

  /// Manga search
  searchManga,

  /// Chapter pages for reading
  fetchChapterPages,

  /// Reading progress sync
  syncReadingProgress,

  /// Tracker progress sync
  syncTrackerProgress,

  /// Manga management (add/remove/update)
  mangaManagement,

  /// Category management
  categoryManagement,

  /// Chapter download
  chapterDownload,

  /// Offline content sync
  offlineSync,
}

/// Result of library fetch operation.
class LibrarySnapshot {
  const LibrarySnapshot({
    required this.manga,
    required this.categories,
    required this.timestamp,
    this.isComplete = true,
    this.totalCount,
  });

  factory LibrarySnapshot.empty() => LibrarySnapshot(
        manga: [],
        categories: [],
        timestamp: DateTime.now(),
        isComplete: false,
      );

  final List<Manga> manga;
  final List<Category> categories;
  final DateTime timestamp;
  final bool isComplete;
  final int? totalCount;
}

/// Result of chapter pages fetch.
class ChapterPagesResult {
  const ChapterPagesResult({
    required this.pages,
    this.chapter,
    this.isComplete = true,
  });

  final List<String> pages;
  final Chapter? chapter;
  final bool isComplete;
}

/// Tracker progress data.
class TrackerProgress {
  const TrackerProgress({
    required this.mangaId,
    this.trackerId,
    this.status,
    this.score,
    this.progress,
    this.lastChapterRead,
    this.lastUpdated,
  });

  final int mangaId;
  final int? trackerId;
  final String? status;
  final double? score;
  final int? progress;
  final int? lastChapterRead;
  final DateTime? lastUpdated;

  Map<String, dynamic> toJson() => {
        'mangaId': mangaId,
        if (trackerId != null) 'trackerId': trackerId,
        if (status != null) 'status': status,
        if (score != null) 'score': score,
        if (progress != null) 'progress': progress,
        if (lastChapterRead != null) 'lastChapterRead': lastChapterRead,
        if (lastUpdated != null) 'lastUpdated': lastUpdated!.millisecondsSinceEpoch,
      };
}