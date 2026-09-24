import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting, debugPrint, kDebugMode;
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../db/isar_service.dart';
import '../db/models/category.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import '../db/models/sync_record.dart';
import '../engine/quickjs_service.dart';
import '../engine/repo_manager.dart';
import '../engine/source_migration_service.dart';
import '../logging/logger_service.dart';
import '../services/image_cache_helper.dart';
import '../services/settings_service.dart';
import '../services/wakelock_coordinator.dart';
import 'graphql_client_service.dart';

/// A queued mutation is abandoned after this many *counted* failures.
const int kMaxSyncRetries = 5;

/// Transient (network) failures don't count toward [kMaxSyncRetries], so they
/// need their own ceiling: a record that has been stuck failing this long is
/// abandoned instead of being retried forever.
const int kTransientSyncMaxAgeSeconds = 14 * 24 * 60 * 60;

/// Whether [e] is a transient network failure (dropped connection, timeout,
/// DNS hiccup) rather than the server rejecting the mutation.
///
/// Deliberately narrow: bare substrings like "connection" also appear in real
/// server-side error messages, and misclassifying those as transient would
/// retry a rejected mutation forever. Pure so tests can check it directly.
@visibleForTesting
bool isTransientSyncError(Object e) {
  if (e is SocketException || e is TimeoutException) return true;
  final s = e.toString().toLowerCase();
  return s.contains('socketexception') ||
      s.contains('timeoutexception') ||
      s.contains('timed out') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('connection closed') ||
      s.contains('connection error') ||
      s.contains('network is unreachable') ||
      s.contains('failed host lookup');
}

/// New `retryCount` after a failed dispatch. Transient failures leave it
/// unchanged; everything else (server rejection, GraphQL error) costs one.
@visibleForTesting
int retryCountAfterFailure(int current, {required bool transient}) => transient ? current : current + 1;

/// State a queued record moves to after a failed dispatch.
@visibleForTesting
SyncRecordState stateAfterFailure({
  required int retryCount,
  required bool transient,
  required int recordAgeSeconds,
}) {
  if (retryCount >= kMaxSyncRetries) return SyncRecordState.abandoned;
  if (transient && recordAgeSeconds >= kTransientSyncMaxAgeSeconds) return SyncRecordState.abandoned;
  return SyncRecordState.failed;
}

/// True if [payloadJson] only carries `chapterId`/`isRead`/`lastPageRead` (a
/// pure progress update) and not a bookmark toggle. Only such records may be
/// coalesced onto — a bookmark change must never be overwritten by progress.
@visibleForTesting
bool isPureChapterProgressPayload(String payloadJson) {
  try {
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    final keys = payload.keys.toSet();
    return keys.difference({'chapterId', 'isRead', 'lastPageRead'}).isEmpty && keys.contains('lastPageRead');
  } catch (_) {
    return false;
  }
}

/// Merges a chapter's local `lastPageRead` with the server's during a pull.
///
/// Normally the highest value wins, so a pull never rewinds progress. The one
/// exception is a chapter that was read locally but the server now reports as
/// unread with no local mutation queued: it was marked unread on another
/// device, so the server's page number replaces the stale high local one.
/// A chapter with an unsynced local mutation always keeps its local value
/// until that mutation replays.
@visibleForTesting
int mergeLastPageRead({
  required int local,
  required int server,
  required bool localWasRead,
  required bool serverIsRead,
  required bool hasPendingMutation,
}) {
  if (hasPendingMutation) return local;
  if (localWasRead && !serverIsRead) return server;
  return local > server ? local : server;
}

class SyncEngine {
  static SyncEngine? _instance;
  bool _isSyncing = false;
  String? _deviceId;

  SyncEngine._();

  static SyncEngine get instance {
    _instance ??= SyncEngine._();
    return _instance!;
  }

  Future<void> initialize({String? deviceId}) async {
    _deviceId = deviceId ?? 'default_device';
    await LoggerService.instance.logInfo('SyncEngine initialized for deviceId: $_deviceId', 'SyncEngine');
    await triggerSync();
  }

  /// Reset failed/abandoned sync records back to pending so a manual retry can
  /// flush them again (Advanced Settings → "Retry failed sync").
  Future<int> retryFailedSyncRecords() async {
    final records = await IsarService.instance.getFailedSyncRecords();
    if (records.isEmpty) return 0;
    for (final record in records) {
      record.retryCount = 0;
      record.state = SyncRecordState.pending;
      await IsarService.instance.saveSyncRecord(record);
    }
    await LoggerService.instance.logInfo(
      'Reset ${records.length} failed/abandoned sync record(s) to pending for retry',
      'SyncEngine',
    );
    // Kick an immediate flush so the retry is not only queued for the next cycle.
    unawaited(triggerSync());
    return records.length;
  }

  /// Bypass wipe-guard and apply server library removals (Settings → Advanced).
  Future<void> forceReconcileWithServer() async {
    if (_isSyncing) return;
    if (!GraphQLClientService.instance.isConfigured) return;
    _isSyncing = true;
    try {
      final online = await GraphQLClientService.instance.checkServerReachable(force: true);
      if (!online) return;
      await _flushPendingMutations();
      await _syncCategories();
      await _syncSourcesAndReplicate();
      await _performFullSync(forceLibraryRemovals: true);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    if (!GraphQLClientService.instance.isConfigured) {
      return;
    }

    _isSyncing = true;
    try {
      final isServerOnline = await GraphQLClientService.instance.checkServerReachable();
      if (!isServerOnline) {
        // Server is offline — silently keep local authoritative state without firing network queries
        return;
      }
      try {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          await WakelockCoordinator.instance.acquire('sync');
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[sync_engine] ignored error: $ignoredError'); }
      await LoggerService.instance.logInfo('Starting sync cycle with server...', 'SyncEngine');
      await _flushPendingMutations();
      await _pullServerState();
      await LoggerService.instance.logInfo('Sync cycle completed successfully', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Sync cycle error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    } finally {
      try {
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          await WakelockCoordinator.instance.release('sync');
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[sync_engine] ignored error: $ignoredError'); }
      _isSyncing = false;
    }
  }

  Future<void> syncChapterProgress(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
  }) async {
    if (chapterServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateChapterReadStatus(
            chapterServerId,
            isRead,
            lastPageRead,
          );
          if (res != null) {
            // The server now has the latest progress, so any still-queued
            // progress update for this chapter is stale. Replaying it later
            // would overwrite this newer value with an older one.
            await _dropQueuedProgressRecords(chapterServerId);
            return;
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Direct chapter read status sync failed ($chapterServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    // Queue offline SyncRecord for replay when online. Page turns fire this
    // once per debounced scroll/page-change, so an offline reading session
    // would otherwise queue one record per page — all but the last are
    // redundant since only the final lastPageRead matters. Coalesce onto an
    // existing pending, not-yet-attempted progress record for this chapter
    // instead of piling up a new one each time.
    final existing = (await IsarService.instance.getPendingChapterRecords(chapterServerId.toString()))
        .where((r) =>
            r.action == SyncAction.update && r.retryCount == 0 && isPureChapterProgressPayload(r.payloadJson))
        .toList();

    if (existing.isNotEmpty) {
      final record = existing.first;
      record.payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isRead': isRead,
        'lastPageRead': lastPageRead,
      });
      record.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await IsarService.instance.saveSyncRecord(record);
      // Any duplicates beyond the first (shouldn't normally happen, but a
      // race between two callers could produce one) are stale — drop them.
      for (final dup in existing.skip(1)) {
        await IsarService.instance.deleteSyncRecord(dup.id);
      }
      return;
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.chapter
      ..entityId = chapterServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isRead': isRead,
        'lastPageRead': lastPageRead,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Deletes queued, not-yet-attempted pure progress records for a chapter
  /// (see [isPureChapterProgressPayload]); bookmark records are left alone.
  Future<void> _dropQueuedProgressRecords(int chapterServerId) async {
    try {
      final stale = (await IsarService.instance.getPendingChapterRecords(chapterServerId.toString()))
          .where((r) => r.action == SyncAction.update && isPureChapterProgressPayload(r.payloadJson));
      for (final r in stale) {
        await IsarService.instance.deleteSyncRecord(r.id);
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to drop stale queued progress for $chapterServerId: $e', 'SyncEngine');
    }
  }

  Future<void> syncChapterBookmark(int chapterServerId, bool isBookmarked) async {
    if (chapterServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateChapterBookmark(chapterServerId, isBookmarked);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct bookmark sync failed ($chapterServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.chapter
      ..entityId = chapterServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isBookmarked': isBookmarked,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncMangaLibraryState(int mangaServerId, bool inLibrary) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateMangaLibraryState(mangaServerId, inLibrary);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct manga library state sync failed ($mangaServerId): $e, queuing for replay', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.manga
      ..entityId = mangaServerId.toString()
      ..action = inLibrary ? SyncAction.update : SyncAction.delete
      ..payloadJson = jsonEncode({
        'mangaId': mangaServerId,
        'inLibrary': inLibrary,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryCreate({required String name, required int localServerId, int order = 0}) async {
    if (name.trim().isEmpty) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.createCategory(name);
          final created = res?['createCategory']?['category'];
          if (created is Map) {
            final remoteId = parseIntSafe(created['id']);
            if (remoteId > 0 && remoteId != localServerId) {
              final cats = await IsarService.instance.getCategories();
              final match = cats.where((c) => c.serverId == localServerId).toList();
              if (match.isNotEmpty) {
                final cat = match.first;
                await IsarService.instance.deleteCategory(localServerId);
                cat.serverId = remoteId;
                cat.name = created['name']?.toString() ?? name;
                cat.order = parseIntSafe(created['order'], order);
                await IsarService.instance.saveCategory(cat);
              }
            }
            return;
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category create failed ($name): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = localServerId.toString()
      ..action = SyncAction.create
      ..payloadJson = jsonEncode({
        'op': 'create',
        'name': name,
        'localServerId': localServerId,
        'order': order,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryDelete(int categoryServerId) async {
    if (categoryServerId == 0) return;

    // A local-only category — synthetic temp id (offline-created, negative) or
    // any id that still has a pending create queued — never existed on the
    // server. Cancel its queued create/assign ops instead of issuing a delete
    // the server can't honor (and which would later be "recreated" by the
    // stale pending create on the next flush).
    final pendingRecords = await IsarService.instance.getPendingCategoryRecords();
    if (categoryServerId < 0 ||
        pendingRecords.any((r) =>
            r.action == SyncAction.create &&
            r.entityId == categoryServerId.toString())) {
      for (final r in pendingRecords) {
        if (r.entityId == categoryServerId.toString() ||
            _syncRecordReferencesCategory(r, categoryServerId)) {
          await IsarService.instance.deleteSyncRecord(r.id);
        }
      }
      return;
    }

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.deleteCategory(categoryServerId);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category delete failed ($categoryServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = categoryServerId.toString()
      ..action = SyncAction.delete
      ..payloadJson = jsonEncode({
        'op': 'delete',
        'categoryId': categoryServerId,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// True when a queued category record's payload references [categoryId] —
  /// used to drop dangling 'assign' records when an offline category is
  /// deleted before its create ever reached the server.
  static bool _syncRecordReferencesCategory(SyncRecord record, int categoryId) {
    try {
      final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
      final ids = (payload['categoryIds'] as List?)?.map((e) => parseIntSafe(e)).toList() ?? const <int>[];
      return ids.contains(categoryId);
    } catch (ignoredError) {
      return false;
    }
  }

  Future<void> syncMangaCategories(int mangaServerId, List<int> categoryIds) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.setMangaCategories(mangaServerId, categoryIds);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct manga categories sync failed ($mangaServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = 'manga_$mangaServerId'
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'assign',
        'mangaId': mangaServerId,
        'categoryIds': categoryIds,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  Future<void> syncCategoryRename(int categoryServerId, String newName) async {
    if (categoryServerId < 0 || newName.trim().isEmpty) return;
    final trimmed = newName.trim();

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateCategoryName(categoryServerId, trimmed);
          if (res != null) return;
        } catch (e) {
          await LoggerService.instance.logWarning('Direct category rename failed ($categoryServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.category
      ..entityId = categoryServerId.toString()
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'rename',
        'categoryId': categoryServerId,
        'name': trimmed,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Queue tracker progress for all bound trackers of [mangaServerId].
  /// Online: fetch track records and push immediately. Offline: queue a
  /// manga-level progress record replayed on the next flush.
  Future<void> syncMangaTrackerProgress(int mangaServerId, double chapterNumber) async {
    if (mangaServerId <= 0 || chapterNumber < 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final pushed = await _pushTrackerProgressForManga(mangaServerId);
          if (pushed) return;
        } catch (e) {
          await LoggerService.instance.logWarning(
            'Direct tracker progress sync failed ($mangaServerId): $e, queuing',
            'SyncEngine',
          );
        }
      }
    }

    final record = SyncRecord()
      ..recordId = const Uuid().v4()
      ..entityType = SyncEntityType.tracker
      ..entityId = 'manga_$mangaServerId'
      ..action = SyncAction.update
      ..payloadJson = jsonEncode({
        'op': 'mangaProgress',
        'mangaId': mangaServerId,
        'chapterNumber': chapterNumber,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Pushes MAL/AniList progress via `trackProgress(mangaId)` after chapter
  /// read has been applied on the server. Does not send trackerId.
  Future<bool> _pushTrackerProgressForManga(int mangaServerId) async {
    final data = await GraphQLClientService.instance.fetchTrackRecords(mangaServerId);
    final nodes = data?['trackRecords']?['nodes'];
    if (nodes is! List || nodes.isEmpty) return true; // nothing bound — treat as success
    final res = await GraphQLClientService.instance.trackProgress(mangaServerId);
    return res != null;
  }

  /// Rewrites pending offline 'assign' records that still reference the local
  /// temporary category id so they replay against the real server id once the
  /// category-create mutation has been flushed. Returns only the records whose
  /// payload actually changed (callers persist those).
  ///
  /// Pure so tests can verify the remap without a live queue or DB.
  @visibleForTesting
  static List<SyncRecord> remapOfflineAssignRecords({
    required List<SyncRecord> records,
    required int localServerId,
    required int remoteId,
  }) {
    final changed = <SyncRecord>[];
    for (final rec in records) {
      if (rec.entityType != SyncEntityType.category) continue;
      try {
        final payload = jsonDecode(rec.payloadJson) as Map<String, dynamic>;
        if (payload['op'] != 'assign' || payload['categoryIds'] is! List) continue;
        final ids = (payload['categoryIds'] as List).map((e) => parseIntSafe(e)).toList();
        final replaced = ids.map((id) => id == localServerId ? remoteId : id).toList();
        if (ids.join(',') != replaced.join(',')) {
          payload['categoryIds'] = replaced;
          rec.payloadJson = jsonEncode(payload);
          changed.add(rec);
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[sync_engine] ignored error: $ignoredError'); }
    }
    return changed;
  }

  Future<void> _flushPendingMutations() async {
    final pendingRecords = await IsarService.instance.getPendingSyncRecords();
    if (pendingRecords.isEmpty) return;

    // Replay mutations strictly in chronological order. Records created within
    // the same second (common in bursts) replay in insertion order via the
    // auto-increment id — Dart/Isar sorts aren't stable, so a bare timestamp
    // comparison alone would be nondeterministic.
    final executionList = List<SyncRecord>.from(pendingRecords)
      ..sort((a, b) {
        final byTs = a.timestamp.compareTo(b.timestamp);
        return byTs != 0 ? byTs : a.id.compareTo(b.id);
      });

    for (final queued in executionList) {
      // Re-read each record just before dispatch. Earlier steps of this same
      // flush (the offline-category id remap) and concurrent writes (a direct
      // progress write that dropped this record, a coalesced page turn) may
      // have rewritten or deleted it since the list was loaded; dispatching
      // the stale in-memory copy would replay an outdated payload.
      final record = await IsarService.instance.getSyncRecord(queued.id);
      if (record == null ||
          (record.state != SyncRecordState.pending && record.state != SyncRecordState.failed)) {
        continue;
      }
      try {
        final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
        bool success = false;

        switch (record.entityType) {
          case SyncEntityType.chapter:
            if (record.action == SyncAction.update) {
              final chapterId = parseIntSafe(payload['chapterId']);
              if (chapterId > 0) {
                var allOk = true;
                var attempted = false;
                if (chapterMutationNeedsBookmark(payload)) {
                  attempted = true;
                  final isBookmarked = parseBoolSafe(payload['isBookmarked']);
                  final res = await GraphQLClientService.instance.updateChapterBookmark(chapterId, isBookmarked);
                  allOk = allOk && res != null;
                }
                if (chapterMutationNeedsReadProgress(payload)) {
                  attempted = true;
                  final isRead = parseBoolSafe(payload['isRead']);
                  final lastPageRead = parseIntSafe(payload['lastPageRead']);
                  final res = await GraphQLClientService.instance.updateChapterReadStatus(chapterId, isRead, lastPageRead);
                  allOk = allOk && res != null;
                }
                success = attempted && allOk;
              } else {
                success = true;
              }
            }
            break;
          case SyncEntityType.tracker:
            if (record.action == SyncAction.update) {
              final op = payload['op']?.toString() ?? '';
              if (op == 'mangaProgress') {
                final mangaId = parseIntSafe(payload['mangaId']);
                success = await _pushTrackerProgressForManga(mangaId);
              } else {
                final mangaId = parseIntSafe(payload['mangaId']);
                final res = await GraphQLClientService.instance.trackProgress(mangaId);
                success = res != null;
              }
            }
            break;
          case SyncEntityType.manga:
            if (record.action == SyncAction.update || record.action == SyncAction.delete) {
              final mangaId = parseIntSafe(payload['mangaId']);
              final inLibrary = parseBoolSafe(payload['inLibrary']);
              final res = await GraphQLClientService.instance.updateMangaLibraryState(mangaId, inLibrary);
              success = res != null;
            }
            break;
          case SyncEntityType.category:
            final op = payload['op']?.toString() ?? '';
            if (op == 'create' || record.action == SyncAction.create) {
              final name = payload['name']?.toString() ?? '';
              final localServerId = parseIntSafe(payload['localServerId']);
              final res = await GraphQLClientService.instance.createCategory(name);
              final created = res?['createCategory']?['category'];
              if (created is Map) {
                final remoteId = parseIntSafe(created['id']);
                if (remoteId > 0 && localServerId != remoteId) {
                  final cats = await IsarService.instance.getCategories();
                  final match = cats.where((c) => c.serverId == localServerId).toList();
                  if (match.isNotEmpty) {
                    final cat = match.first;
                    await IsarService.instance.deleteCategory(localServerId);
                    cat.serverId = remoteId;
                    cat.name = created['name']?.toString() ?? name;
                    await IsarService.instance.saveCategory(cat);
                    // Mangas assigned to the temporary id while offline were
                    // queued with the temp id baked into their 'assign'
                    // payload. Rewrite them to the real server id, or the
                    // assign replay would send an unknown category and the
                    // server would silently drop the assignment.
                    final pendingAssigns = await IsarService.instance.getPendingCategoryRecords();
                    final remapped = remapOfflineAssignRecords(
                      records: pendingAssigns,
                      localServerId: localServerId,
                      remoteId: remoteId,
                    );
                    for (final rec in remapped) {
                      await IsarService.instance.saveSyncRecord(rec);
                    }
                  }
                }
                success = true;
              }
            } else if (op == 'delete' || record.action == SyncAction.delete) {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final res = await GraphQLClientService.instance.deleteCategory(categoryId);
              success = res != null;
            } else if (op == 'assign') {
              final mangaId = parseIntSafe(payload['mangaId']);
              final ids = (payload['categoryIds'] as List?)?.map((e) => parseIntSafe(e)).toList() ?? <int>[];
              final res = await GraphQLClientService.instance.setMangaCategories(mangaId, ids);
              success = res != null;
            } else if (op == 'rename') {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final name = payload['name']?.toString() ?? '';
              final res = await GraphQLClientService.instance.updateCategoryName(categoryId, name);
              success = res != null;
            }
            break;
          case SyncEntityType.source:
            break;
        }

        if (success) {
          await _completeDispatchedRecord(record);
        } else {
          // GraphQLClientService.query() swallows every failure and returns
          // null, so a dropped connection lands here, not in the catch below.
          // If the client now considers the server unreachable, the mutation
          // wasn't rejected — don't spend one of its retries on it. An active
          // auth error (401/403) is NOT transient: counting it against the
          // retry budget abandons the record in a bounded number of cycles
          // instead of re-attempting it for 14 days with a bad credential.
          final client = GraphQLClientService.instance;
          await _recordDispatchFailure(
            record,
            transient: client.isKnownUnreachable && !client.hasAuthError,
          );
        }
      } catch (e, stack) {
        await _recordDispatchFailure(record, transient: isTransientSyncError(e));
        await LoggerService.instance.logError('Failed to dispatch SyncRecord #${record.id}: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      }
    }
  }

  /// Removes a successfully dispatched record — unless its payload changed
  /// while the request was in flight. Page turns coalesce onto queued progress
  /// records, so a turn landing mid-flush rewrites the payload; deleting from
  /// our stale in-memory copy would silently discard that newer progress.
  /// In that case the record stays queued and the next cycle sends it.
  Future<void> _completeDispatchedRecord(SyncRecord dispatched) async {
    final current = await IsarService.instance.getSyncRecord(dispatched.id);
    if (current == null) return;
    if (current.payloadJson == dispatched.payloadJson) {
      await IsarService.instance.deleteSyncRecord(dispatched.id);
    } else {
      await LoggerService.instance.logInfo(
        'SyncRecord #${dispatched.id} changed while in flight — keeping it queued for the next cycle',
        'SyncEngine',
      );
    }
  }

  /// Applies retry accounting after a failed dispatch. Re-reads the record so
  /// only `retryCount`/`state` are written and a payload coalesced during the
  /// request isn't reverted by saving the stale in-memory copy.
  Future<void> _recordDispatchFailure(SyncRecord dispatched, {required bool transient}) async {
    final current = await IsarService.instance.getSyncRecord(dispatched.id);
    if (current == null) return;
    current.retryCount = retryCountAfterFailure(current.retryCount, transient: transient);
    current.state = stateAfterFailure(
      retryCount: current.retryCount,
      transient: transient,
      recordAgeSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000 - current.timestamp,
    );
    await IsarService.instance.saveSyncRecord(current);
  }

  Future<void> _pullServerState() async {
    await _syncCategories();
    await _syncSourcesAndReplicate();
    await _performFullSync();
  }

  Future<void> _syncSourcesAndReplicate() async {
    try {
      final sourcesData = await GraphQLClientService.instance.fetchSources();
      if (sourcesData != null && sourcesData.containsKey('sources')) {
        final nodes = sourcesData['sources']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          final serverSources = nodes.map((n) {
            final m = n as Map<String, dynamic>;
            return ServerSourceItem(
              id: m['id'].toString(),
              name: m['name'] as String? ?? '',
              lang: m['lang'] as String? ?? 'en',
            );
          }).toList();

          final userRepos = SettingsService.instance.customRepos;

          // Auto-download and install matching JS scrapers from user repos
          await RepoManager.instance.downloadAndInstallMatchingSources(
            serverSourceNames: serverSources.map((s) => s.name).toList(),
            userRepoUrls: userRepos,
          );

          final installedLocalJs = QuickJsService.instance.getInstalledExtensionNames();
          final libraryManga = await IsarService.instance.getLibraryManga();

          final allRepoSources = await RepoManager.instance.fetchCombinedRepoSources(userRepos);
          final availableRepoNames = allRepoSources.map((r) => r.name).toList();

          final report = await SourceMigrationService.instance.syncAndReplicateServerSources(
            currentServerInstalledSources: serverSources,
            currentlyInstalledLocalJs: installedLocalJs,
            availableMangayomiRepoExtensions: availableRepoNames,
            currentLibraryManga: libraryManga,
          );

          if (report.totalReplicatedManga > 0) {
            await IsarService.instance.saveMangas(libraryManga);
          }
        }
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to sync sources: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  Future<void> _syncCategories() async {
    try {
      final data = await GraphQLClientService.instance.fetchCategories();
      if (data != null && data.containsKey('categories')) {
        final nodes = data['categories']['nodes'] as List<dynamic>;
        final categories = <Category>[];
        for (final n in nodes) {
          final map = n as Map<String, dynamic>;
          final cat = Category()
            ..serverId = parseIntSafe(map['id'])
            ..name = map['name'] as String? ?? 'Default'
            ..order = parseIntSafe(map['order'])
            ..isDefault = parseBoolSafe(map['default']);
          categories.add(cat);
        }
        await IsarService.instance.saveCategories(categories);
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to pull categories: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  Future<void> _performFullSync({bool forceLibraryRemovals = false}) async {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final serverUrl = GraphQLClientService.instance.baseUrl ?? '';

    // ── STEP 1: Read current local count BEFORE touching anything ────────
    final localCountBefore = await IsarService.instance.getMangaCount();

    // ── STEP 2: Pull full library from Suwayomi ───────────────────────────
    bool serverReachable = false;
    try {
      final libData = await GraphQLClientService.instance
          .fetchLibrary()
          .timeout(const Duration(seconds: 8));
      if (libData != null && libData.containsKey('mangas')) {
        serverReachable = true;
        final nodes = libData['mangas']['nodes'] as List<dynamic>;
        final serverMangas = <Manga>[];

        for (final n in nodes) {
          final nodeMap = n as Map<String, dynamic>;
          final serverId = parseIntSafe(nodeMap['id']);
          var manga = await IsarService.instance.getMangaByServerId(serverId);
          manga ??= Manga()..serverId = serverId;

          manga.title = nodeMap['title'] as String? ?? 'Untitled';
          // Only overwrite author/description from server if user has NOT locked metadata via Metron enrichment
          if (!manga.isMetadataLocked) {
            manga.author = nodeMap['author'] as String?;
            manga.description = nodeMap['description'] as String?;
          }
          manga.inLibrary = true;
          manga.inLibraryAt = nodeMap['inLibraryAt'] != null ? int.tryParse(nodeMap['inLibraryAt'].toString()) : null;
          manga.unreadCount = parseIntSafe(nodeMap['unreadCount']);
          manga.lastFetchedAt = nowUnix;

          if (nodeMap.containsKey('categories') && nodeMap['categories'] != null) {
            final catNodes = nodeMap['categories']['nodes'] as List<dynamic>?;
            if (catNodes != null) {
              manga.categoryIds = catNodes.map((c) => parseIntSafe((c as Map<String, dynamic>)['id'])).toList();
            }
          }

          final sourceMap = nodeMap['source'] as Map<String, dynamic>?;
          manga.sourceName = sourceMap?['name'] as String? ?? sourceMap?['displayName'] as String? ?? nodeMap['sourceId']?.toString() ?? 'Unknown Source';
          final sourceLang = sourceMap?['lang']?.toString();
          if (sourceLang != null && sourceLang.trim().isNotEmpty) {
            manga.lang = sourceLang.trim();
          } else if (manga.lang.isEmpty) {
            manga.lang = 'en';
          }

          // Save the manga's URL on the source website — used by local QuickJS extensions
          // to scrape chapters directly when the server is offline.
          if (nodeMap['url'] != null && (nodeMap['url'] as String).isNotEmpty) {
            manga.url = nodeMap['url'] as String;
          }

          final rawThumb = nodeMap['thumbnailUrl'] as String?;
          final isServerProxy = rawThumb == null || rawThumb.isEmpty || rawThumb.contains('/api/v1/manga/');
          final currentThumb = manga.thumbnailUrl;
          final hasDirectThumb = currentThumb != null &&
              currentThumb.isNotEmpty &&
              !currentThumb.contains('/api/v1/manga/') &&
              currentThumb.startsWith('http');

          if (!hasDirectThumb) {
            // Check if local extension can resolve direct CDN cover URL (zero network, instantaneous)
            String? extCover;
            if (manga.sourceName.isNotEmpty && manga.url.isNotEmpty) {
              extCover = QuickJsService.instance.getExtensionCoverUrl(manga.sourceName, manga.url);
            }
            if (extCover != null && extCover.isNotEmpty) {
              manga.thumbnailUrl = extCover;
            } else if (!isServerProxy) {
              manga.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
            } else if (serverUrl.isNotEmpty && serverId > 0 && (manga.thumbnailUrl == null || manga.thumbnailUrl!.isEmpty)) {
              manga.thumbnailUrl = '$serverUrl/api/v1/manga/$serverId/thumbnail';
            }
          }

          serverMangas.add(manga);
        }
        await IsarService.instance.saveMangas(serverMangas);

        // Pre-cache cover images to local disk for offline resilience
        for (final m in serverMangas) {
          if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty) {
            ImageCacheHelper.cacheThumbnail(m.serverId, m.thumbnailUrl!, sourceName: m.sourceName);
          }
        }

        // ── WIPE GUARD: Never cascade a server wipe to local Isar ─────────
        // If server returned far fewer manga than Isar has, something is wrong
        // (server was wiped/reset). Skip marking local entries as removed.
        final serverCount = serverMangas.length;
        final removalSafe = forceLibraryRemovals ||
            localCountBefore == 0 ||
            (serverCount > 0 && serverCount >= localCountBefore * 0.3); // server has at least 30% of what we had

        if (removalSafe && serverCount > 0) {
          // Only soft-delete local entries that the server genuinely removed
          final serverIds = serverMangas.map((m) => m.serverId).toSet();
          final localLib = await IsarService.instance.getLibraryManga();
          final toRemove = <Manga>[];
          for (final local in localLib) {
            // Only soft-delete server-linked manga that the server genuinely removed.
            // Local standalone/extension manga (serverId <= 0) must never be removed by server sync.
            if (local.serverId > 0 && !serverIds.contains(local.serverId)) {
              local.inLibrary = false;
              toRemove.add(local);
            }
          }
          if (toRemove.isNotEmpty) {
            await IsarService.instance.saveMangas(toRemove);
          }
        } else if (serverCount == 0 && localCountBefore > 0) {
          await LoggerService.instance.logWarning(
            'WIPE GUARD TRIGGERED: server returned 0 manga but Isar had $localCountBefore. Keeping local data safe.',
            'SyncEngine'
          );
        } else if (!removalSafe) {
          await LoggerService.instance.logWarning(
            'WIPE GUARD TRIGGERED: server returned $serverCount manga but Isar had $localCountBefore. '
            'Skipping removal cascade — local data preserved. Pull-to-refresh to re-sync manually.',
            'SyncEngine',
          );
        }
      }
    } catch (e) {
      await LoggerService.instance.logInfo('Server unreachable for library sync, skipping server pull ($e)', 'SyncEngine');
      return; // Server is offline — immediately return to keep local data untouched and fast!
    }

    if (!serverReachable) return;

    // ── STEP 3: Pull ALL chapters for the full library (full snapshot) ────
    // This is the core of local-first: every chapter, page count, URL, and
    // fetch timestamp is stored in Isar so the app never needs the server
    // to know what chapters exist or to navigate reading history.
    await _syncAllChaptersForLibrary(serverUrl: serverUrl);

    // ── STEP 4: Pull reading history chapters (isRead=true) ──────────────
    await _syncHistoryChapters(serverUrl: serverUrl);

    // ── STEP 5: Pull recent update chapters (new fetched chapters) ────────
    await _syncRecentUpdateChapters(serverUrl: serverUrl);

    await IsarService.instance.setMeta('last_sync_unix', nowUnix.toString());
    try {
      await GraphQLClientService.instance.setGlobalMeta('lastSync_$_deviceId', nowUnix.toString());
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to set global meta lastSync: $e', 'SyncEngine');
    }
  }

  // ── FULL CHAPTER SNAPSHOT FOR EVERY LIBRARY MANGA ──────────────────────
  // Fetches all chapters for every manga in the library and saves to Isar.
  // After this, chapters exist locally and are accessible without any server.
  Future<void> _syncAllChaptersForLibrary({required String serverUrl}) async {
    try {
      final allLibrary = await IsarService.instance.getLibraryManga();
      final library = allLibrary.where((m) => m.serverId > 0).toList();
      if (library.isEmpty) return;

      // Chapters with an unsynced outbound mutation still queued (e.g. this
      // device marked something read/unread offline) must keep their local
      // value until that mutation actually reaches the server — otherwise
      // this pull would immediately overwrite the optimistic local change
      // with the server's stale value on every sync cycle.
      final pendingChapterIds = await IsarService.instance.getPendingChapterEntityIds();

      await LoggerService.instance.logInfo('Full chapter snapshot: syncing ${library.length} manga', 'SyncEngine');

      // Chunk fetch for concurrency
      for (var i = 0; i < library.length; i += 5) {
        final chunk = library.skip(i).take(5).toList();
        await Future.wait(chunk.map((manga) async {
          try {
            final data = await GraphQLClientService.instance.fetchMangaDetails(manga.serverId);
            if (data == null || !data.containsKey('manga')) return;

          final mangaData = data['manga'] as Map<String, dynamic>;

          // Update manga fields from detail response (respect metadata lock from Metron)
          if (!manga.isMetadataLocked) {
            manga.description = mangaData['description'] as String? ?? manga.description;
            manga.status = mangaData['status'] as String? ?? manga.status;
            final genresList = mangaData['genre'] as List<dynamic>?;
            if (genresList != null) {
              manga.genres = genresList.map((g) => g.toString()).toList();
            }
          } else {
            // Still update status from server even when locked — status is operational data, not editorial
            manga.status = mangaData['status'] as String? ?? manga.status;
          }
          final rawMangaUrl = (mangaData['url'] ?? mangaData['realUrl']) as String?;
          if (rawMangaUrl != null && rawMangaUrl.isNotEmpty) {
            manga.url = rawMangaUrl;
          }
          manga.lastFetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

          final chaptersData = mangaData['chapters'] as Map<String, dynamic>?;
          final chapterNodes = chaptersData?['nodes'] as List<dynamic>?;

          if (chapterNodes != null) {
            manga.chapterCount = chapterNodes.length;
            final chaptersToSave = <Chapter>[];

            for (final c in chapterNodes) {
              final chMap = c as Map<String, dynamic>;
              final chServerId = parseIntSafe(chMap['id']);

              var chapter = await IsarService.instance.getChapterByServerId(chServerId);
              chapter ??= Chapter()..serverId = chServerId;

              chapter.mangaId = manga.serverId;
              chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
              chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
              chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

              // Read-state merge: take the server's value outright unless this
              // chapter has an unsynced outbound mutation queued, in which
              // case keep the local value until that mutation replays — the
              // old "OR true, never false" rule meant an unread-on-another-
              // -device never made it back here.
              final serverIsRead = parseBoolSafe(chMap['isRead']);
              final hasPendingMutation = pendingChapterIds.contains(chapter.serverId.toString());
              final localWasRead = chapter.isRead;
              if (!hasPendingMutation) {
                chapter.isRead = serverIsRead;
              }

              // lastPageRead merge — highest wins, except a chapter marked
              // unread elsewhere takes the server's page (see mergeLastPageRead).
              final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
              chapter.lastPageRead = mergeLastPageRead(
                local: chapter.lastPageRead,
                server: serverLastPageRead,
                localWasRead: localWasRead,
                serverIsRead: serverIsRead,
                hasPendingMutation: hasPendingMutation,
              );

              final rawServerLastReadAt = chMap['lastReadAt'] != null
                  ? int.tryParse(chMap['lastReadAt'].toString())
                  : null;
              if (rawServerLastReadAt != null) {
                final serverLastReadAt = rawServerLastReadAt > 100000000000 ? rawServerLastReadAt ~/ 1000 : rawServerLastReadAt;
                if (serverLastReadAt > (chapter.lastReadAt ?? 0)) {
                  chapter.lastReadAt = serverLastReadAt;
                }
              }

              final rawUpload = chMap['uploadDate'] ?? chMap['dateUpload'];
              if (rawUpload != null) {
                final rawStr = rawUpload.toString().trim();
                if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
                  chapter.dateUpload = rawStr;
                }
                final upVal = int.tryParse(rawStr);
                if (upVal != null && upVal > 0) {
                  chapter.uploadDate = upVal > 1000000000000 ? upVal ~/ 1000 : upVal;
                }
              }

              // Do not stamp full historical chapter backlog as updates during snapshot
              if (chapter.id == Isar.autoIncrement) {
                chapter.fetchedAt = 0;
              }

              final rawScanlator = chMap['scanlator'] as String?;
              if (rawScanlator != null && rawScanlator.isNotEmpty) {
                chapter.scanlator = rawScanlator;
              }

              // Save remote chapter URLs for on-device QuickJS scraping
              if (chMap['url'] != null && (chMap['url'] as String).isNotEmpty) {
                chapter.url = chMap['url'] as String;
              }
              if (chMap['realUrl'] != null && (chMap['realUrl'] as String).isNotEmpty) {
                chapter.realUrl = chMap['realUrl'] as String;
              }

              // Denormalize manga info into the chapter for offline display
              chapter.mangaTitle = manga.title;
              chapter.mangaThumbnailUrl = manga.thumbnailUrl;

              chaptersToSave.add(chapter);
            }

            await IsarService.instance.saveChapters(chaptersToSave);
          }

          await IsarService.instance.saveManga(manga);
        } catch (e) {
          // Individual manga chapter sync failure is non-fatal — continue with others
          await LoggerService.instance.logWarning('Chapter snapshot failed for manga ${manga.serverId}: $e', 'SyncEngine');
        }
        }));
      }

      await LoggerService.instance.logInfo('Full chapter snapshot complete', 'SyncEngine');
    } catch (e, stack) {
      await LoggerService.instance.logError('Full chapter snapshot error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
    }
  }

  // ── HISTORY SYNC (isRead = true chapters) ────────────────────────────────
  Future<void> _syncHistoryChapters({required String serverUrl}) async {
    try {
      // One query for the whole pass — see _syncAllChaptersForLibrary.
      final pendingChapterIds = await IsarService.instance.getPendingChapterEntityIds();
      final historyData = await GraphQLClientService.instance.fetchHistoryChapters(0);
      if (historyData != null && historyData.containsKey('chapters')) {
        final chNodes = historyData['chapters']['nodes'] as List<dynamic>;
        final fetchedChapters = <Chapter>[];
        final parentMangasToSave = <int, Manga>{};

        for (final c in chNodes) {
          final chMap = c as Map<String, dynamic>;
          final chServerId = parseIntSafe(chMap['id']);
          final mangaServerId = parseIntSafe(chMap['mangaId']);
          final serverIsRead = parseBoolSafe(chMap['isRead']);
          final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
          final rawServerLastReadAt = chMap['lastReadAt'] != null ? int.tryParse(chMap['lastReadAt'].toString()) : null;
          final serverLastReadAt = rawServerLastReadAt != null
              ? (rawServerLastReadAt > 100000000000 ? rawServerLastReadAt ~/ 1000 : rawServerLastReadAt)
              : null;

          var chapter = await IsarService.instance.getChapterByServerId(chServerId);
          chapter ??= Chapter()..serverId = chServerId;

          chapter.mangaId = mangaServerId;
          chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
          chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
          chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

          // Read-state: take the server's value unless this chapter still has
          // an unsynced outbound mutation queued (see _syncAllChaptersForLibrary).
          final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
          final localWasRead = chapter.isRead;
          if (!hasPendingMutation) {
            chapter.isRead = serverIsRead;
          }
          chapter.lastPageRead = mergeLastPageRead(
            local: chapter.lastPageRead,
            server: serverLastPageRead,
            localWasRead: localWasRead,
            serverIsRead: serverIsRead,
            hasPendingMutation: hasPendingMutation,
          );
          if (serverLastReadAt != null && serverLastReadAt > (chapter.lastReadAt ?? 0)) {
            chapter.lastReadAt = serverLastReadAt;
          }

          // Populate denormalized manga info for offline History display
          if (chMap.containsKey('manga') && chMap['manga'] != null) {
            final mangaMap = chMap['manga'] as Map<String, dynamic>;
            chapter.mangaTitle = mangaMap['title'] as String? ?? chapter.mangaTitle;
            final mThumb = mangaMap['thumbnailUrl'] as String?;
            if (mThumb != null && mThumb.isNotEmpty) {
              chapter.mangaThumbnailUrl = mThumb.startsWith('http') ? mThumb : '$serverUrl$mThumb';
            }

            // Also upsert parent manga into Isar if not already there
            final mServerId = parseIntSafe(mangaMap['id'], mangaServerId);
            var parentManga = parentMangasToSave[mServerId] ?? await IsarService.instance.getMangaByServerId(mServerId);
            parentManga ??= Manga()..serverId = mServerId;
            if (parentManga.title.isEmpty || parentManga.title == 'Untitled') {
              parentManga.title = mangaMap['title'] as String? ?? 'Manga';
            }
            final mThumbFull = mangaMap['thumbnailUrl'] as String?;
            final isProxy = mThumbFull == null || mThumbFull.isEmpty || mThumbFull.contains('/api/v1/manga/');
            final hasDirect = parentManga.thumbnailUrl != null &&
                parentManga.thumbnailUrl!.isNotEmpty &&
                !parentManga.thumbnailUrl!.contains('/api/v1/manga/') &&
                parentManga.thumbnailUrl!.startsWith('http');
            if (!hasDirect) {
              String? extCover;
              if (parentManga.sourceName.isNotEmpty && parentManga.url.isNotEmpty) {
                extCover = QuickJsService.instance.getExtensionCoverUrl(parentManga.sourceName, parentManga.url);
              }
              if (extCover != null && extCover.isNotEmpty) {
                parentManga.thumbnailUrl = extCover;
              } else if (mThumbFull != null && mThumbFull.isNotEmpty && !isProxy) {
                parentManga.thumbnailUrl = mThumbFull.startsWith('http') ? mThumbFull : '$serverUrl$mThumbFull';
              }
            }
            parentMangasToSave[mServerId] = parentManga;
          }

          fetchedChapters.add(chapter);
        }

        if (parentMangasToSave.isNotEmpty) {
          await IsarService.instance.saveMangas(parentMangasToSave.values.toList());
        }
        await IsarService.instance.saveChapters(fetchedChapters);
      }
    } catch (e) {
      await LoggerService.instance.logError('History sync error: $e', category: 'SyncEngine');
    }
  }

  // ── RECENT UPDATES SYNC (new chapters feed) ───────────────────────────────
  // Populates the Updates tab's offline cache by saving recent chapters with
  // their fetchedAt timestamp and denormalized manga metadata.
  Future<void> _syncRecentUpdateChapters({required String serverUrl}) async {
    try {
      final pendingChapterIds = await IsarService.instance.getPendingChapterEntityIds();
      final data = await GraphQLClientService.instance.fetchUpdatesChapters(first: 150);
      if (data == null || !data.containsKey('chapters')) return;

      final nodes = data['chapters']['nodes'] as List<dynamic>?;
      if (nodes == null) return;

      final chaptersToSave = <Chapter>[];

      for (final n in nodes) {
        final map = n as Map<String, dynamic>;
        final chServerId = parseIntSafe(map['id']);

        var chapter = await IsarService.instance.getChapterByServerId(chServerId);
        chapter ??= Chapter()..serverId = chServerId;

        chapter.mangaId = parseIntSafe(map['mangaId'], chapter.mangaId);
        chapter.name = map['name'] as String? ?? chapter.name;
        chapter.chapterNumber = parseDoubleSafe(map['chapterNumber'], chapter.chapterNumber);
        final serverIsRead = parseBoolSafe(map['isRead']);
        final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
        final localWasRead = chapter.isRead;
        if (!hasPendingMutation) {
          chapter.isRead = serverIsRead;
        }
        // Same merge as the snapshot/history pulls: this used to take the
        // server's page outright, which discarded offline reading progress
        // that was still queued for upload.
        chapter.lastPageRead = mergeLastPageRead(
          local: chapter.lastPageRead,
          server: parseIntSafe(map['lastPageRead'], chapter.lastPageRead),
          localWasRead: localWasRead,
          serverIsRead: serverIsRead,
          hasPendingMutation: hasPendingMutation,
        );
        chapter.isDownloadedOnServer = parseBoolSafe(map['isDownloaded']) || chapter.isDownloadedOnServer;

        final rawUpload = map['uploadDate'] ?? map['dateUpload'];
        if (rawUpload != null) {
          final rawStr = rawUpload.toString().trim();
          if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
            chapter.dateUpload = rawStr;
          }
          final upVal = int.tryParse(rawStr);
          if (upVal != null && upVal > 0) {
            chapter.uploadDate = upVal > 1000000000000 ? upVal ~/ 1000 : upVal;
          }
        }

        final rawFetchedAt = map['fetchedAt'];
        if (rawFetchedAt != null) {
          final ftVal = int.tryParse(rawFetchedAt.toString());
          if (ftVal != null && ftVal > 0) {
            chapter.fetchedAt = ftVal > 1000000000000 ? ftVal ~/ 1000 : ftVal;
          }
        }

        final rawScanlator = map['scanlator'] as String?;
        if (rawScanlator != null && rawScanlator.isNotEmpty) {
          chapter.scanlator = rawScanlator;
        }

        // Denormalize manga metadata so Updates tab renders offline
        final mangaMap = map['manga'] as Map<String, dynamic>?;
        if (mangaMap != null) {
          chapter.mangaTitle = mangaMap['title'] as String? ?? chapter.mangaTitle;
          final rawThumb = mangaMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            chapter.mangaThumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }
        }

        chaptersToSave.add(chapter);
      }

      await IsarService.instance.saveChapters(chaptersToSave);
      await LoggerService.instance.logInfo('Cached ${chaptersToSave.length} recent update chapters to Isar', 'SyncEngine');
    } catch (e) {
      await LoggerService.instance.logError('Recent updates sync error: $e', category: 'SyncEngine');
    }
  }
}
