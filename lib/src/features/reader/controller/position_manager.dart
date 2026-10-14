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
import '../reader_scroll_utils.dart' show shouldPersistProgressPage;
import 'navigation_controller.dart' show ReaderItem, ReaderPageItem, ReaderChapterBoundary;

/// Outcome of a [PositionManager.updateProgress] call.
class ProgressUpdateResult {
  const ProgressUpdateResult({
    required this.updated,
    required this.clampedPage,
    required this.totalPages,
    required this.becameComplete,
    required this.becameRead,
  });

  static const none = ProgressUpdateResult(
    updated: false,
    clampedPage: 0,
    totalPages: 0,
    becameComplete: false,
    becameRead: false,
  );

  final bool updated;
  final int clampedPage;
  final int totalPages;
  final bool becameComplete;
  final bool becameRead;
}

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
  /// [chapterSnapshot] — snapshot of the chapter at time of call (prevents
  /// cross-chapter pollution). [totalPages] / [page] are 1-indexed page counts.
  Future<ProgressUpdateResult> updateProgress({
    required Chapter chapterSnapshot,
    required int totalPages,
    required int page,
    Manga? parentManga,
  }) async {
    if (settings.incognitoMode) return ProgressUpdateResult.none;
    if (totalPages == 0) return ProgressUpdateResult.none;

    final clampedPage = page.clamp(1, totalPages);
    final isComplete = page >= totalPages;
    final wasRead = chapterSnapshot.isRead;

    // Clamp stored lastPageRead: stale oversized values must not veto updates.
    final previousSaved = chapterSnapshot.lastPageRead.clamp(0, totalPages);

    if (!shouldPersistProgressPage(
      page: clampedPage,
      previousSaved: previousSaved,
    )) {
      return ProgressUpdateResult.none;
    }

    chapterSnapshot.lastPageRead = clampedPage;
    if (chapterSnapshot.pageCount != totalPages) {
      chapterSnapshot.pageCount = totalPages;
    }
    if (isComplete) {
      chapterSnapshot.isRead = true;
    }
    chapterSnapshot.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    try {
      await isarService.saveChapter(chapterSnapshot);
    } catch (e, st) {
      await LoggerService.instance.logError(
        'Failed to persist reading progress for chapter ${chapterSnapshot.serverId}',
        exception: e,
        stackTrace: st,
        category: 'Reader',
      );
      return ProgressUpdateResult.none;
    }

    final mangaId = chapterSnapshot.mangaId;
    if (mangaId != 0 &&
        (_parentManga != null || parentManga != null || wasRead != chapterSnapshot.isRead)) {
      await _updateSeriesReadState(
        chapterSnapshot,
        wasRead,
        preferredParent: parentManga ?? _parentManga,
      );
    }

    if (chapterSnapshot.serverId > 0) {
      unawaited(syncEngine.syncChapterProgress(
        chapterSnapshot.serverId,
        isRead: chapterSnapshot.isRead,
        lastPageRead: clampedPage,
      ));
    }

    final becameRead = !wasRead && chapterSnapshot.isRead;
    if (becameRead) {
      await _scrobbleIfLinked(chapterSnapshot, preferredParent: parentManga ?? _parentManga);
      if (chapterSnapshot.mangaId > 0) {
        final chapterNum = chapterSnapshot.chapterNumber > 0
            ? chapterSnapshot.chapterNumber
            : clampedPage.toDouble();
        unawaited(
          syncEngine.syncMangaTrackerProgress(chapterSnapshot.mangaId, chapterNum),
        );
      }
    }

    return ProgressUpdateResult(
      updated: true,
      clampedPage: clampedPage,
      totalPages: totalPages,
      becameComplete: isComplete,
      becameRead: becameRead,
    );
  }

  Future<void> _updateSeriesReadState(
    Chapter chapter,
    bool wasRead, {
    Manga? preferredParent,
  }) async {
    final mangaId = chapter.mangaId;
    final justBecameRead = !wasRead && chapter.isRead;

    try {
      final parent =
          preferredParent ?? await isarService.getMangaByServerId(mangaId);
      if (parent != null &&
          (parent.serverId == mangaId || parent.id == mangaId)) {
        parent.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (justBecameRead && (parent.unreadCount ?? 0) > 0) {
          parent.unreadCount = parent.unreadCount! - 1;
        }
        await isarService.saveManga(parent);
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

  Future<void> _scrobbleIfLinked(
    Chapter chapter, {
    Manga? preferredParent,
  }) async {
    if (!settings.metronAutoScrobble) return;

    final parent = preferredParent ?? _parentManga;
    if (parent != null && parent.metronSeriesId != null) {
      unawaited(metronService
          .scrobbleMangaChapter(manga: parent, chapter: chapter)
          .catchError((Object e, StackTrace st) {
        unawaited(LoggerService.instance.logError(
          'Metron scrobble failed',
          exception: e,
          stackTrace: st,
          category: 'Metron',
        ));
        return false;
      }));
      return;
    }

    if (chapter.mangaId > 0) {
      unawaited(metronService
          .scrobbleChapterByMangaId(
        mangaId: chapter.mangaId,
        chapter: chapter,
      )
          .catchError((Object e, StackTrace st) {
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

  /// Set parent manga for scrobbling / unread badge context.
  void setParentManga(Manga? manga) => _parentManga = manga;

  /// IMP-012: which chapter/page a webtoon strip item stands for. A page item
  /// maps to its own chapter (1-based page); a chapterBoundary counts as the
  /// last page of the chapter it closes. Null when [index] is out of range.
  static ({Chapter chapter, int page, int totalPages})? progressTargetForItem(
    List<ReaderItem> items,
    int index,
  ) {
    if (index < 0 || index >= items.length) return null;
    final item = items[index];
    switch (item) {
      case ReaderPageItem():
        return (
          chapter: item.chapter,
          page: item.pageIndex + 1,
          totalPages: item.chapterPageCount,
        );
      case ReaderChapterBoundary():
        for (var i = index - 1; i >= 0; i--) {
          final prev = items[i];
          if (prev is ReaderPageItem && identical(prev.chapter, item.previous)) {
            return (
              chapter: prev.chapter,
              page: prev.chapterPageCount,
              totalPages: prev.chapterPageCount,
            );
          }
        }
        return null;
    }
  }

  void dispose() {
    _parentManga = null;
  }
}
