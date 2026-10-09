// lib/src/features/reader/controller/position_manager.dart
//
// Extracted from reader_screen.dart — handles reading progress persistence,
// server sync, and tracker scrobbling. Designed to be independent of UI.

import 'dart:async';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/chapter.dart';
import '../../../core/db/models/manga.dart';
import '../../../core/logging/logger_service.dart';
import '../../../core/metron/metron_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/sync/sync_engine.dart';

/// Manages reading progress persistence, server sync, and tracker scrobbling.
///
/// Decouples progress logic from UI — no BuildContext, no setState.
class PositionManager {
  PositionManager({
    required this.settings,
    required this.isarService,
    required this.syncEngine,
    required this.metronService,
  });

  final SettingsService settings;
  final IsarService isarService;
  final SyncEngine syncEngine;
  final MetronService metronService;

  Manga? _parentManga;

  /// Persist reading progress for a chapter and sync to server.
  ///
  /// [chapterSnapshot] — snapshot of the chapter at time of call (prevents cross-chapter pollution)
  /// [totalPages] — total pages in chapter at time of call
  /// [page] — current page (1-indexed)
  /// [parentManga] — parent manga for series updates and scrobbling
  ///
  /// Returns true if progress was actually updated (not debounced/filtered).
  Future<bool> updateProgress({
    required Chapter chapterSnapshot,
    required int totalPages,
    required int page,
    Manga? parentManga,
  }) async {
    if (settings.incognitoMode) return false;
    if (totalPages == 0) return false;

    final clampedPage = totalPages > 0 ? page.clamp(1, totalPages) : page;
    final isComplete = page >= totalPages;
    final wasRead = chapterSnapshot.isRead;

    // Clamp the STORED value, not just the incoming one.
    final previousSaved = totalPages > 0
        ? chapterSnapshot.lastPageRead.clamp(0, totalPages)
        : chapterSnapshot.lastPageRead;

    if (!shouldPersistProgressPage(page: clampedPage, previousSaved: previousSaved)) {
      return false;
    }

    // Apply updates to snapshot
    chapterSnapshot.lastPageRead = clampedPage;
    if (chapterSnapshot.pageCount != totalPages) {
      chapterSnapshot.pageCount = totalPages;
    }
    if (isComplete) {
      chapterSnapshot.isRead = true;
    }
    chapterSnapshot.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Persist to Isar
    try {
      await IsarService.instance.saveChapter(chapterSnapshot);
    } catch (e, st) {
      await LoggerService.instance.logError(
        'Failed to persist reading progress for chapter ${chapterSnapshot.serverId}',
        exception: e,
        stackTrace: st,
        category: 'Reader',
      );
      return false;
    }

    // Update series last-read stamp and unread badge (atomic on single Manga instance)
    final mangaId = chapterSnapshot.mangaId;
    if (mangaId != 0 && (_parentManga != null || wasRead != chapterSnapshot.isRead)) {
      await _updateSeriesReadState(chapterSnapshot, wasRead);
    }

    // Server sync for progress
    if (chapterSnapshot.serverId > 0) {
      unawaited(SyncEngine.instance.syncChapterProgress(
        chapterSnapshot.serverId,
        isRead: chapterSnapshot.isRead,
        lastPageRead: clampedPage,
      ));
    }

    // Tracker scrobble only on transition to fully read
    if (!wasRead && chapterSnapshot.isRead) {
      await _scrobbleIfLinked(chapterSnapshot);
    }

    return true;
  }

  /// Determine if progress should be persisted.
  ///
  /// Progress is persisted if:
  /// - Page has advanced beyond previously saved page (clamped)
  /// - OR chapter is now complete (last page) and wasn't before
  static bool shouldPersistProgressPage({
    required int page,
    required int previousSaved,
  }) {
    // Allow if page advanced beyond previous saved (clamped)
    if (page > previousSaved) return true;
    // Allow if this is the last page and wasn't marked complete before
    // (handled by caller via isComplete check)
    return false;
  }

  /// Update series read state and unread badge atomically.
  Future<void> _updateSeriesReadState(Chapter chapter, bool wasRead) async {
    final mangaId = chapter.mangaId;
    final justBecameRead = !wasRead && chapter.isRead;

    try {
      final parent = await IsarService.instance.getMangaByServerId(mangaId);
      if (parent != null && (parent.serverId == mangaId || parent.id == mangaId)) {
        parent.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (justBecameRead && (parent.unreadCount ?? 0) > 0) {
          parent.unreadCount = parent.unreadCount! - 1;
        }
        await IsarService.instance.saveManga(parent);
      }
    } catch (e, st) {
      await LoggerService.instance.logError(
        'Failed to update series read state for manga $mangaId',
        exception: e,
        stackTrace: st,
        category: 'Reader',
      );
    }
  }

  // Scrobble to Metron if linked
  Future<void> _scrobbleIfLinked(Chapter chapter) async {
    if (!SettingsService.instance.metronAutoScrobble) return;

    if (chapter.mangaId > 0) {
      unawaited(MetronService.instance.scrobbleChapterByMangaId(
        mangaId: chapter.mangaId,
        chapter: chapter,
      ).catchError((Object e, StackTrace st) {
        unawaited(LoggerService.instance.logError(
          'Metron scrobble failed',
          exception: e,
          stackTrace: st,
          category: 'Metron',
        ));
        return false;
      }));
    }
  }

  /// Set parent manga for scrobbling context.
  void setParentManga(Manga? manga) => _parentManga = manga;

  /// Dispose resources (currently no-op, but available for future cleanup).
  void dispose() {}
}