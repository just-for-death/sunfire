import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting, debugPrint, kDebugMode;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../db/epoch_seconds.dart';
import '../db/isar_service.dart';
import '../db/models/category.dart';
import '../db/models/chapter.dart';
import '../db/models/manga.dart';
import '../db/models/sync_record.dart';
import '../engine/quickjs_service.dart';
import '../engine/repo_manager.dart';
import '../engine/source_migration_service.dart';
import '../logging/logger_service.dart';
import '../services/download_manager_service.dart';
import '../services/image_cache_helper.dart';
import '../services/settings_service.dart';
import '../services/wakelock_coordinator.dart';
import 'conflict_resolver.dart'
    show ConflictResolver, ConflictResolutionStrategy, UserChoiceMarker;
import 'graphql_client_service.dart';
import 'read_state_merge.dart';
import 'suwayomi_parse_helpers.dart';
import 'websocket_service.dart';

// Re-exported so the many existing `sync_engine.dart` importers of this helper
// keep working, and so the DB layer can reach it without a circular import.
export '../db/epoch_seconds.dart';
export 'conflict_resolver.dart' show ConflictResolutionStrategy;

/// Result of a sync operation
/// Outcome of an outbox-backed server action (UIX6-06).
class OutboxResult {
  /// Applied on the server right away.
  final bool applied;

  /// Isar id of the queued SyncRecord when [queued]; pass to
  /// `SyncEngine.undoQueuedMutation` for Undo.
  final int? undoToken;
  bool get queued => undoToken != null;

  const OutboxResult.applied()
      : applied = true,
        undoToken = null;
  const OutboxResult.queued(int token)
      : applied = false,
        undoToken = token;
}

class SyncResult {
  const SyncResult({
    required this.success,
    this.mangaUpdated = 0,
    this.chaptersUpdated = 0,
    this.categoriesUpdated = 0,
    this.errors = const [],
    this.lastSyncTimestamp,
    this.conflicts = const [],
    this.data,
  });

  final bool success;
  final int mangaUpdated;
  final int chaptersUpdated;
  final int categoriesUpdated;
  final List<String> errors;
  final DateTime? lastSyncTimestamp;
  final List<SyncConflict> conflicts;
  final Map<String, dynamic>? data;

  SyncResult copyWith({
    bool? success,
    int? mangaUpdated,
    int? chaptersUpdated,
    int? categoriesUpdated,
    List<String>? errors,
    DateTime? lastSyncTimestamp,
    List<SyncConflict>? conflicts,
    Map<String, dynamic>? data,
  }) {
    return SyncResult(
      success: success ?? this.success,
      mangaUpdated: mangaUpdated ?? this.mangaUpdated,
      chaptersUpdated: chaptersUpdated ?? this.chaptersUpdated,
      categoriesUpdated: categoriesUpdated ?? this.categoriesUpdated,
      errors: errors ?? this.errors,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      conflicts: conflicts ?? this.conflicts,
      data: data ?? this.data,
    );
  }
}

/// Progress updates during sync
class SyncProgress {
  const SyncProgress({
    required this.phase,
    required this.current,
    required this.total,
    this.currentManga,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
  });

  final SyncPhase phase;
  final int current;
  final int total;
  final String? currentManga;
  final int bytesTransferred;
  final int totalBytes;

  double get progress => total > 0 ? current / total : 0.0;
}

enum SyncPhase {
  initializing,
  fetchingDelta,
  fetchingManga,
  fetchingChapters,
  fetchingCategories,
  resolvingConflicts,
  applyingChanges,
  uploadingChanges,
  completed,
  failed,
}

/// Conflict between local and remote data
class SyncConflict {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    required this.field,
    this.localTimestamp,
    this.remoteTimestamp,
    this.resolution,
  });

  final String entityType;
  final int entityId;
  final String field;
  final dynamic localData;
  final dynamic remoteData;
  final DateTime? localTimestamp;
  final DateTime? remoteTimestamp;
  final ConflictResolution? resolution;
}

enum ConflictResolution {
  localWins,
  remoteWins,
  merge,
  userChoice,
}

/// Sync configuration
class SyncConfig {
  const SyncConfig({
    this.deltaSyncEnabled = true,
    this.conflictResolutionStrategy = ConflictResolutionStrategy.lastWriteWins,
    this.batchSize = 50,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
    this.timeout = const Duration(seconds: 30),
    this.syncCategories = true,
    this.syncManga = true,
    this.syncChapters = true,
    this.syncProgress = true,
    this.syncReadingProgress = true,
    this.autoSyncInterval = const Duration(hours: 4),
    this.wifiOnly = false,
    this.maxParallelDownloads = 4,
  });

  final bool deltaSyncEnabled;
  final ConflictResolutionStrategy conflictResolutionStrategy;
  final int batchSize;
  final int maxRetries;
  final Duration retryDelay;
  final Duration timeout;
  final bool syncCategories;
  final bool syncManga;
  final bool syncChapters;
  final bool syncProgress;
  final bool syncReadingProgress;
  final Duration autoSyncInterval;
  final bool wifiOnly;
  final int maxParallelDownloads;
}

/// A queued mutation is abandoned after this many *counted* failures.
const int kMaxSyncRetries = 5;

/// Transient (network) failures don't count toward [kMaxSyncRetries], so they
/// need their own ceiling: a record that has been stuck failing this long is
/// abandoned instead of being retried forever.
const int kTransientSyncMaxAgeSeconds = 14 * 24 * 60 * 60;

/// Floor on how much of a series' chapter list the server must still return
/// before we are willing to conclude that the missing chapters were deleted
/// upstream rather than dropped by a truncated/failed response.
///
/// Deliberately conservative and symmetric with the manga-level wipe guard
/// (`serverCount >= localCountBefore * 0.3`). A series that legitimately lost
/// most of its chapters in one step will be reconciled on the following sync.
const double kChapterPruneRatio = 0.3;

/// Floor for accepting a server category list as a replacement for the local
/// one. Mirrors [kChapterPruneRatio]: a response holding far fewer categories
/// than we already have is far more likely to be truncated than a mass deletion
/// upstream. The category pull had no such guard, so a short response ran the
/// `replaceAll` delete and erased the user's shelf.
const double kCategoryPullRatio = 0.5;

/// Whether [e] is a transient network failure (dropped connection, timeout,
/// DNS hiccup) rather than the server rejecting the mutation.
///
/// Deliberately narrow: bare substrings like "connection" also appear in real
/// server-side error messages, and misclassifying those as transient would
/// retry a rejected mutation forever. Pure so tests can check it directly.
@visibleForTesting
bool isTransientSyncError(Object e) {
  if (e is ServerMutationException) return e.isTransportFailure;
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
///
/// The transient path deliberately does not spend the rejection budget — a
/// dropped connection is not the server saying no — but see
/// [stateAfterFailure]: that made the 5-retry cap unreachable for every
/// transport failure, so a permanently-500 endpoint kept a record alive for the
/// full 14-day window with zero counted attempts.
@visibleForTesting
int retryCountAfterFailure(int current, {required bool transient}) => transient ? current : current + 1;

/// Ceiling on attempts for a record whose failures were all classified
/// transient.
///
/// `kMaxSyncRetries` cannot bound this class: `retryCountAfterFailure` leaves
/// the counter untouched for transient failures, so the only bound was a
/// wall-clock age check. `_isTransportFailure` treats any 5xx as transport, so a
/// schema error surfacing as 500, or a misconfigured reverse-proxy rule, made
/// every queued mutation retry on every sync cycle for two weeks — burning
/// battery, radio and server capacity, and never surfacing to the user.
///
/// This counts *attempts*, not rejections, so it is independent of that
/// classification and of the device clock.
const int kMaxTransientSyncAttempts = 40;

/// Whether a server category list may replace the local one.
///
/// [snapshotComplete] is a hard requirement and is NOT overridable. An
/// incomplete snapshot is a partial VIEW of the shelf, and nothing in it can be
/// reasoned about, because there is no way to tell which categories are absent
/// because the server dropped them from which are absent because the response
/// was truncated. `saveCategories` defaults to `replaceAll: true`, which deletes
/// every local category whose id is missing from the list, so accepting a short
/// response erases the user's shelf — and every `Manga.categoryIds` entry
/// pointing at a deleted row, on every device, permanently.
///
/// The ratio is the secondary, weaker heuristic for "the server was reset".
///
/// Extracted so that EVERY caller gets it. The guard was originally inline in
/// `_syncCategories` only, so the Settings screen's category refresh — which
/// calls the same destructive `saveCategories` — had none of it, and was one
/// short response away from wiping the shelf.
///
/// Public rather than test-only because it is production policy that two
/// separate call sites must apply; `@visibleForTesting` would have flagged the
/// second one as a misuse instead of the first as a bug.
bool isCategoryPullAcceptable({
  required bool snapshotComplete,
  required int incoming,
  required int existingServerLinked,
}) {
  if (!snapshotComplete) return false;
  if (existingServerLinked <= 0) return true;
  return incoming >= existingServerLinked * kCategoryPullRatio;
}

/// Whether local library entries the server did not report may be soft-deleted.
///
/// Two independent conditions, and the order matters.
///
/// [snapshotComplete] is NOT overridable by [force]. Force-reconcile is
/// documented in Settings as applying server removals "even if the wipe-guard
/// would skip them" — that is the 30% ratio heuristic for "the server was
/// reset". Completeness is a different question: an incomplete snapshot is a
/// partial VIEW of the library, and nothing in it can be reasoned about, because
/// there is no way to tell which titles are absent because the server dropped
/// them and which are absent because a page failed. Bypassing it meant one
/// flaky page plus a force-reconcile soft-deleted most of the user's library.
///
/// The ratio is also not sufficient on its own: 500 manga with page 3 timing out
/// returns 400, and 400 comfortably clears 30% of 500.
@visibleForTesting
bool isLibraryRemovalSafe({
  required bool snapshotComplete,
  required bool force,
  required int localCountBefore,
  required int serverCount,
}) {
  if (!snapshotComplete) return false;
  if (force) return true;
  if (localCountBefore == 0) return true;
  return serverCount > 0 && serverCount >= localCountBefore * 0.3;
}

/// State a queued record moves to after a failed dispatch.
///
/// [attempts] is the total number of failed dispatches, transient or not, and
/// bounds BOTH classes. [recordAgeSeconds] remains a second, independent bound
/// for the transient class, but it is no longer the only one: it is derived from
/// `DateTime.now()`, which is not monotonic, so a device whose clock steps
/// backwards — or a record written while the clock was ahead — produced a small
/// or negative age and retried forever.
@visibleForTesting
SyncRecordState stateAfterFailure({
  required int retryCount,
  required bool transient,
  required int recordAgeSeconds,
  int attempts = 0,
}) {
  if (retryCount >= kMaxSyncRetries) return SyncRecordState.abandoned;
  if (attempts >= kMaxTransientSyncAttempts) return SyncRecordState.abandoned;
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

/// ISS-142: automatic progress never goes below the server's current value
/// (page max, read OR). Unknown server state leaves the push unchanged.
@visibleForTesting
({bool isRead, int lastPageRead}) clampAutomaticProgress({
  required bool isRead,
  required int lastPageRead,
  bool? serverIsRead,
  int? serverPage,
}) =>
    (
      isRead: isRead || (serverIsRead ?? false),
      lastPageRead: (serverPage != null && serverPage > lastPageRead) ? serverPage : lastPageRead,
    );

/// Merges a chapter's local `lastPageRead` with the server's during a pull.
///
/// Normally the highest value wins, so a pull never rewinds progress.
/// The server's page number is only used when it represents MORE progress
/// (i.e., server > local). This prevents rewinding local progress when
/// the server reports a chapter as unread with a low page number (e.g., 0).
/// A chapter with an unsynced local mutation always keeps its local value
/// until that mutation replays.
///
/// Read *state* is deliberately not an input. `isRead` is applied separately
/// by the caller, gated on the same [hasPendingMutation], and the position is
/// reconciled purely by magnitude. This signature previously took
/// `localWasRead` and `serverIsRead` as `required` parameters and then read
/// neither, which advertised a coupling that did not exist and invited a
/// future reader to "fix" the merge by consulting them.
@visibleForTesting
int mergeLastPageRead({
  required int local,
  required int server,
  required bool hasPendingMutation,
}) {
  if (hasPendingMutation) return local;
  if (server > local) return server;
  return local;
}

/// Decides which local chapters may be pruned for a series, given the set of
/// chapter ids the server just reported.
///
/// Pure and `@visibleForTesting` so the wipe guard is directly verifiable —
/// this is the one place in the app that can permanently destroy a series'
/// offline reading history, so its "when NOT to delete" behaviour matters more
/// than its "when to delete" behaviour.
///
/// Returns only chapters that are safe to remove: never one the server still
/// reports, never a locally-downloaded or bookmarked chapter, and never
/// anything at all if the response looks truncated ([seenServerIds] empty, or
/// holding less than [kChapterPruneRatio] of what we already had).
@visibleForTesting
List<Chapter> selectPrunableChapters({
  required Iterable<Chapter> localChapters,
  required Set<int> seenServerIds,
}) {
  if (seenServerIds.isEmpty) return const [];

  // Only consider real server chapters; a local-scrape chapter has a negative
  // synthetic serverId and exists solely on this device.
  final known = localChapters.where((c) => c.serverId > 0).toList();
  final stale = <Chapter>[
    for (final c in known)
      if (!seenServerIds.contains(c.serverId) &&
          !c.isDownloadedLocally &&
          !c.isBookmarked &&
          !hasReadingHistory(c))
        c,
  ];
  if (stale.isEmpty) return const [];

  // Wipe guard: a series that suddenly returns far fewer chapters than we hold
  // is far more likely to be a truncated/failed response than a mass deletion
  // upstream. Keep everything and let the next sync reconcile.
  if (seenServerIds.length < known.length * kChapterPruneRatio) return const [];

  return stale;
}

/// Parses GraphQL category nodes into [Category] rows (UIX-14).
///
/// A node whose `id` is missing or malformed is **skipped**. Falling back to 0
/// (the old `parseIntSafe` default) turned it into Suwayomi's built-in Default
/// category, and because `serverId` is a unique-replace index the bogus node
/// then replaced the real Default row. Used by both the sync pull and the
/// library settings refresh.
List<Category> parseCategoryNodes(List<dynamic> nodes, {String fallbackName = 'Default'}) {
  final out = <Category>[];
  for (final n in nodes) {
    if (n is! Map) continue;
    final map = n.cast<String, dynamic>();
    final id = parseIntSafe(map['id'], -1);
    if (id < 0) continue;
    out.add(Category()
      ..serverId = id
      // Trimmed, like every local write. The dedupe check compares
      // trim+lowercase, so an untrimmed pull produced a category that matched
      // nothing and rendered as a second, identical tab.
      ..name = (map['name'] as String? ?? fallbackName).trim()
      ..order = parseIntSafe(map['order'])
      // Server v2.4.2366+ forward-compat: when the server exposes
      // `isDefaultCategory`, it joins `default` as a source of truth for the
      // built-in category (the legacy flag stays until the announced
      // incompatible change lands). Absent on older servers → false.
      ..isDefaultCategory = parseBoolSafe(map['isDefaultCategory'])
      ..isDefault = parseBoolSafe(map['default']) ||
          parseBoolSafe(map['isDefaultCategory'])
      ..includeInUpdate = parseIncludeOrExclude(map['includeInUpdate'])
      ..includeInDownload = parseIncludeOrExclude(map['includeInDownload']));
  }
  return out;
}

/// Parses the category ids for one manga from a `fetchLibrary` node's
/// `categories.nodes` list.
///
/// Suwayomi's built-in "Default" category is id 0. Two server shapes mean
/// "in Default":
///   1. `categories.nodes` explicitly lists `{ id: 0 }`, and
///   2. `categories.nodes` is **empty** — the web UI treats uncategorised
///      in-library manga as Default (ISS-052). An empty list must therefore
///      become `[0]`, not `[]`, or the Library Default tab permanently shows
///      0 while All still lists the titles.
///
/// An old `> 0` guard dropped id 0 entirely; the -1 sentinel still keeps
/// malformed nodes (missing/non-numeric id, which `parseIntSafe` would
/// otherwise report as 0) out of the Default bucket.
///
/// Pure and `@visibleForTesting` like the other sync guards.
@visibleForTesting
List<int> parseMangaCategoryIds(dynamic catNodes) {
  if (catNodes is! List) return const [];
  final ids = <int>[];
  for (final n in catNodes) {
    if (n is! Map) continue;
    final id = parseIntSafe(Map<String, dynamic>.from(n)['id'], -1);
    if (id >= 0) ids.add(id);
  }
  // Empty nodes = uncategorised = Suwayomi Default (id 0).
  if (ids.isEmpty) return const [0];
  return ids;
}

/// Whether a manga with [categoryIds] belongs to library category [catServerId].
///
/// Default (id 0) matches both an explicit `0` and an empty list, so titles
/// synced before empty→`[0]` normalisation still appear under Default.
/// Every other category is a straight membership check. Used by the Library
/// category tabs as well as sync tests (ISS-052).
bool mangaBelongsToCategory(List<int> categoryIds, int catServerId) {
  if (catServerId == 0) {
    return categoryIds.isEmpty || categoryIds.contains(0);
  }
  return categoryIds.contains(catServerId);
}

/// True when [chapter] carries any local evidence that the user read it.
///
/// This is the one piece of chapter state that cannot be recovered once the row
/// is gone. `mergeLastReadAt` is write-only-forward, so after a hard delete
/// there is nothing left for a later sync to merge into and the entry is lost
/// from History, Stats and Continue-Reading permanently.
///
/// The trigger is routine rather than exotic: a server-side re-scan reassigns
/// chapter ids, the old ids stop being reported, and the rows behind them are
/// read-but-not-downloaded and not bookmarked — so they fell straight into the
/// prunable set. Reclaiming a few bytes is never worth destroying a user's
/// reading history, so a chapter is prunable only when it has no read state at
/// all.
///
/// A half-read chapter counts: `isRead == false` with `lastPageRead > 0` is the
/// normal mid-chapter state and the position is just as irreplaceable.
@visibleForTesting
bool hasReadingHistory(Chapter chapter) =>
    chapter.isRead || chapter.lastPageRead > 0 || (chapter.lastReadAt ?? 0) > 0;

/// Returns the first candidate that is non-null and non-blank after trimming,
/// or null when there is none.
String? _firstNonEmpty(List<String?> candidates) {
  for (final c in candidates) {
    if (c == null) continue;
    final trimmed = c.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

/// Merges `isBookmarked` from a server chapter node.
///
/// Bookmarks were only ever *pushed* ([syncChapterBookmark]); none of the
/// three pull paths assigned the field, even though every chapter query
/// already selects `isBookmarked`. A bookmark set on one device therefore
/// never came back down on another — `manga_detail_screen` and the Reader
/// both render `chapter.isBookmarked`, so the icon simply vanished.
///
/// Skipped while this chapter has an unsynced outbound mutation queued, so a
/// bookmark that is still waiting to be pushed is not immediately overwritten
/// by the server's pre-replay value.
void mergeIsBookmarked(
  Chapter chapter,
  Map<String, dynamic> chMap, {
  required bool hasPendingMutation,
}) {
  if (hasPendingMutation) return;
  if (!chMap.containsKey('isBookmarked')) return;
  chapter.isBookmarked = parseBoolSafe(chMap['isBookmarked']);
}

/// Merges `lastReadAt` from a server chapter node, normalising epoch
/// milliseconds to seconds and never moving the stamp backwards.
///
/// `getReadingHistory()` filters on `lastReadAt > 0` and Library's "Last
/// Read" sort reads the series-level stamp, so a chapter that arrives already
/// read but without this field is invisible to both.
@visibleForTesting
void mergeLastReadAt(Chapter chapter, Map<String, dynamic> chMap) {
  final seconds = normalizeEpochToSeconds(chMap['lastReadAt']);
  if (seconds == null) return;
  // Never move the stamp backwards: a server that has not yet seen an offline
  // read would otherwise erase local history ordering on every pull.
  if (seconds > (chapter.lastReadAt ?? 0)) {
    chapter.lastReadAt = seconds;
  }
}

/// Merges one chapter node from the server library snapshot into [chapter]
/// (an existing local row, or a fresh `Chapter()` for a first-seen id).
///
/// Single-flight gate with a one-deep queue for [SyncEngine.triggerSync].
///
/// Extracted so the queue semantics are unit-testable without spinning the
/// full GraphQL / Isar cycle (ISS-050/051).
/// Any number of calls while a pass runs collapse into ONE follow-up pass:
/// that pass starts after every one of them, so it serves them all and none
/// is dropped. Counting calls instead ran one full cycle (flush, library pull,
/// chapter snapshot) per pull-to-refresh, resume or WebSocket event.
@visibleForTesting
class SyncCycleGate {
  bool isSyncing = false;
  bool _queued = false;

  /// Returns `true` when the caller should run a sync cycle. If a cycle is
  /// already running, requests a follow-up pass and returns `false`.
  bool tryBegin() {
    if (isSyncing) {
      _queued = true;
      return false;
    }
    isSyncing = true;
    return true;
  }

  bool get queued => _queued;

  /// Called at the start of a cycle body: this pass serves every request so far.
  void beginPass() => _queued = false;

  /// After a cycle body finishes: `true` when another pass should run.
  bool needsAnotherPass() => _queued;

  /// Releases the single-flight lock and clears the queue. Call only when no
  /// further pass is needed (e.g., server switch quarantine).
  void end() {
    isSyncing = false;
    _queued = false;
  }
}

/// Applies a server `fetchedAt` onto [chapter] for the recent-updates pull.
///
/// When [preserveCleared] is true and the chapter is already persisted with
/// `fetchedAt == 0`, the server stamp is skipped so a user Clear sticks across
/// sync cycles (ISS-055). Brand-new rows (`id == Isar.autoIncrement`) still
/// receive the stamp.
@visibleForTesting
void applyServerFetchedAt(
  Chapter chapter,
  Object? rawFetchedAt, {
  bool preserveCleared = false,
}) {
  if (rawFetchedAt == null) return;
  final ftVal = int.tryParse(rawFetchedAt.toString());
  if (ftVal == null || ftVal <= 0) return;
  final seconds = normalizeEpochToSeconds(ftVal) ?? 0;
  if (seconds <= 0) return;
  if (preserveCleared &&
      chapter.id != Isar.autoIncrement &&
      (chapter.fetchedAt == null || chapter.fetchedAt == 0)) {
    return;
  }
  chapter.fetchedAt = seconds;
}

/// Documented pull-phase order inside one sync cycle (ISS-050 / ISS-051).
///
/// Library membership and the Updates feed must land before the slow per-manga
/// chapter snapshot and before source-extension replication, so onboarding's
/// bounded hydration and the first library paint see server titles / recent
/// chapters even when the rest of the cycle is still running.
@visibleForTesting
const List<String> kSyncPullPhaseOrder = <String>[
  'categories',
  'libraryMembership',
  'recentUpdates',
  'history',
  'chapterSnapshot',
  'sourceReplication',
];

/// Extracted from `_pullServerState` so the snapshot rules are directly
/// testable. In particular a chapter first seen in the snapshot gets
/// `fetchedAt = 0`: the snapshot is the whole back-catalogue, not a feed of
/// updates, and must never stamp chapters into Updates (UIX-05).
@visibleForTesting
void mergeSnapshotChapterNode(
  Chapter chapter,
  Map<String, dynamic> chMap, {
  required Manga manga,
  required bool hasPendingMutation,
}) {
  chapter.mangaId = manga.serverId;
  chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
  chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
  chapter.pageCount = parseIntSafe(chMap['pageCount']);

  // Read-state merge: take the server's value outright unless this
  // chapter has an unsynced outbound mutation queued, in which
  // case keep the local value until that mutation replays — the
  // old "OR true, never false" rule meant an unread-on-another-
  // -device never made it back here.
  // ISS-141: newest explicit action wins (Sunfire meta or an outside change
  // vs the last-synced snapshot); otherwise the furthest page.
  applyServerReadState(
    chapter,
    serverIsRead: parseBoolSafe(chMap['isRead']),
    serverPage: parseIntSafe(chMap['lastPageRead']),
    serverMetaActionAt: readActionAtFromNode(chMap),
    hasPendingMutation: hasPendingMutation,
  );

  mergeLastReadAt(chapter, chMap);
  mergeIsBookmarked(chapter, chMap, hasPendingMutation: hasPendingMutation);

  final rawUpload = chMap['uploadDate'] ?? chMap['dateUpload'];
  if (rawUpload != null) {
    final rawStr = rawUpload.toString().trim();
    if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
      chapter.dateUpload = rawStr;
    }
    final upVal = int.tryParse(rawStr);
    if (upVal != null && upVal > 0) {
      chapter.uploadDate = normalizeEpochToSeconds(upVal) ?? 0;
    }
  }

  // Do not stamp the historical backlog as updates during the
  // snapshot. Genuine new chapters reach the Updates feed via
  // _syncRecentUpdateChapters with the server's fetchedAt. (The
  // snapshot used to run applyFloodCapToNewChapters here, which
  // re-stamped 3-4 arbitrary — often the oldest — chapters per
  // series with `now` on a fresh install / server connect.)
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

  // Denormalize manga info into the chapter for offline display.
  // Guarded on non-empty: this was an unconditional assign, so a
  // series whose manga row has no cover (server returned only a
  // proxy URL) lost the cover on every one of its chapters, unlike
  // the history/recent-update blocks which already guarded.
  chapter.mangaTitle = manga.title;
  final seriesThumb = manga.thumbnailUrl;
  if (seriesThumb != null && seriesThumb.isNotEmpty) {
    chapter.mangaThumbnailUrl = seriesThumb;
  }
}

/// Applies a server manga node onto a stored row, touching only fields the
/// node actually carries. Saving a freshly parsed [Manga] instead replaced the
/// row (unique-replace `serverId` index) and lost tags, metadata locks,
/// `lastReadAt`, the reading-mode override and the local Isar id.
void applyServerMangaNode(Manga manga, Map<String, dynamic> node) {
  String? text(String key) {
    final v = node[key]?.toString().trim();
    return v == null || v.isEmpty || v == 'null' ? null : v;
  }

  final title = text('title') ?? text('name');
  if (title != null) manga.title = title;
  if (!manga.isMetadataLocked) {
    final author = text('author');
    if (author != null) manga.author = author;
    final artist = text('artist');
    if (artist != null) manga.artist = artist;
    final description = text('description');
    if (description != null) manga.description = description;
  }
  final status = text('status');
  if (status != null) manga.status = status;

  final source = node['source'];
  final sourceName = text('sourceName') ??
      (source is Map ? (source['displayName'] ?? source['name'])?.toString() : null);
  if (sourceName != null && sourceName.isNotEmpty) manga.sourceName = sourceName;

  final url = text('url') ?? text('sourceUrl');
  if (url != null) manga.url = url;
  final thumb = text('thumbnailUrl') ?? text('coverUrl');
  if (thumb != null && (manga.thumbnailUrl == null || manga.thumbnailUrl!.isEmpty)) manga.thumbnailUrl = thumb;

  if (node['inLibrary'] is bool) manga.inLibrary = node['inLibrary'] as bool;
  final inLibraryAt = normalizeEpochToSeconds(node['inLibraryAt']);
  if (inLibraryAt != null) manga.inLibraryAt = inLibraryAt;
  if (node['unreadCount'] != null) manga.unreadCount = parseIntSafe(node['unreadCount']);

  final rawCategoryIds = node['categoryIds'];
  final catContainer = node['categories'];
  if (rawCategoryIds is List) {
    manga.categoryIds = rawCategoryIds.map(parseIntSafe).where((id) => id != 0).toList();
  } else if (catContainer is Map && catContainer['nodes'] is List) {
    manga.categoryIds = parseMangaCategoryIds(catContainer['nodes'] as List);
  }
}

// ── IMP-005: per-series reader settings roam via Suwayomi manga meta ─────

/// Manga-meta key (in the ISS-077 `sunfire_` namespace) holding the
/// per-series reader override as `{"v":1,"t":<epoch ms>,"o":{...}}`.
const String kReaderSettingsMetaKey = 'sunfire_reader_settings';

String encodeReaderSettingsMeta(Map<String, Object>? override, int updatedAtMs) =>
    jsonEncode({'v': 1, 't': updatedAtMs, 'o': override ?? const <String, Object>{}});

/// Tolerant decode; null for missing/garbled values.
({Map<String, Object> o, int t})? decodeReaderSettingsMeta(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final v = jsonDecode(raw);
    if (v is! Map) return null;
    final t = v['t'];
    final o = v['o'];
    if (t is! int || o is! Map) return null;
    return (
      o: {
        for (final e in o.entries)
          if (e.value is String || e.value is bool || e.value is num) e.key.toString(): e.value as Object,
      },
      t: t,
    );
  } catch (_) {
    return null;
  }
}

enum ReaderSettingsMetaSync { none, pulled, pushed }

/// IMP-005: reconcile the local per-series override of [manga] with its
/// server manga meta. Newest change wins (local stamp vs meta `t`): a newer
/// server value is saved locally (pulled), a newer local one goes up through
/// `setMangaMeta`, or `deleteMangaMeta` for a reset to "All" (pushed).
/// No-op in incognito, without a configured server, or for local-only manga.
Future<ReaderSettingsMetaSync> syncReaderSettingsMeta({
  required Manga manga,
  required SettingsService settings,
  GraphQLClientService? client,
}) async {
  if (settings.incognitoMode) return ReaderSettingsMetaSync.none;
  final c = client ?? GraphQLClientService.instance;
  if (!c.isConfigured || manga.serverId <= 0) return ReaderSettingsMetaSync.none;
  final remoteMeta = await c.fetchSunfireMangaMeta(manga.serverId);
  if (remoteMeta == null) return ReaderSettingsMetaSync.none; // unreachable: retry next open
  final remote = decodeReaderSettingsMeta(remoteMeta[kReaderSettingsMetaKey]);
  final localT = settings.readerOverrideUpdatedAt(manga.id);
  if (remote != null && remote.t > localT) {
    await settings.setReaderOverrideJson(manga.id, remote.o.isEmpty ? null : remote.o, updatedAtMs: remote.t);
    return ReaderSettingsMetaSync.pulled;
  }
  if (localT > (remote?.t ?? 0)) {
    final local = settings.readerOverrideJson(manga.id);
    final ok = (local == null || local.isEmpty)
        ? (remote == null || await c.deleteMangaMeta(manga.serverId, kReaderSettingsMetaKey))
        : await c.setMangaMeta(
            manga.serverId,
            kReaderSettingsMetaKey,
            encodeReaderSettingsMeta(local.map((k, v) => MapEntry(k, v as Object)), localT),
          );
    return ok ? ReaderSettingsMetaSync.pushed : ReaderSettingsMetaSync.none;
  }
  return ReaderSettingsMetaSync.none;
}

/// Global-meta keys earlier builds wrote by mistake (ISS-077): `lastSync_null`
/// from a sync before `initialize()`, and the shared literal device id.
const List<String> kLegacyLastSyncMetaKeys = ['lastSync_null', 'lastSync_default_device'];

/// `lastSync_<deviceId>` or null when the id is missing / a legacy literal.
@visibleForTesting
String? lastSyncMetaKey(String? deviceId) {
  final id = deviceId?.trim() ?? '';
  if (id.isEmpty || id == 'null' || id == 'default_device') return null;
  return 'lastSync_$id';
}

/// Per-manga change fingerprint for targeted chapter refresh (ISS-076 B6).
///
/// Built from cheap markers on the `fetchLibrary` node: when a server reports
/// the same `chaptersLastFetchedAt`, latest fetched chapter, chapter count,
/// unread/bookmark/download counts and last-read chapter (id, page, time,
/// read flag) as last cycle, nothing a full chapter snapshot would merge has
/// changed and the per-manga `fetchMangaDetails` walk can be skipped.
///
/// Returns null when the server did not report markers (older schema) —
/// callers must then run the full snapshot.
@visibleForTesting
String? chapterRefreshFingerprint(Map<String, dynamic> node) {
  if (!node.containsKey('chaptersLastFetchedAt')) return null;
  String sub(String key, List<String> fields) {
    final m = node[key];
    if (m is! Map) return '-';
    return fields.map((f) => '${m[f]}').join(':');
  }

  return [
    node['chaptersLastFetchedAt'],
    sub('latestFetchedChapter', const ['id', 'fetchedAt']),
    sub('chapterStats', const ['totalCount']),
    node['unreadCount'],
    node['bookmarkCount'],
    node['downloadCount'],
    sub('lastReadChapter', const ['id', 'lastPageRead', 'lastReadAt', 'isRead']),
  ].join('|');
}

/// Max age of a skipped manga's last full chapter snapshot (ISS-076). Past
/// this a full snapshot runs regardless, so anything the markers miss (a
/// chapter renamed in place, a scanlator change) is bounded in staleness.
const Duration kChapterSnapshotMaxAge = Duration(hours: 6);

/// Whether the full chapter snapshot for one manga can be skipped (ISS-076).
@visibleForTesting
bool shouldSkipChapterSnapshot({
  required String? currentFingerprint,
  required String? previousFingerprint,
  required DateTime? lastFullSnapshotAt,
  required int localChapterCount,
  required DateTime now,
  Duration maxAge = kChapterSnapshotMaxAge,
}) {
  if (currentFingerprint == null || previousFingerprint == null) return false;
  if (currentFingerprint != previousFingerprint) return false;
  if (localChapterCount <= 0) return false;
  if (lastFullSnapshotAt == null) return false;
  return now.difference(lastFullSnapshotAt) < maxAge;
}

/// Time window (epoch seconds) for the incremental updates pull (ISS-074).
/// Null → full top-N pull (first cycle, or the periodic full refresh that
/// reconciles read/downloaded flags on older rows). Otherwise the previous
/// high-water mark minus [overlap] so clock skew cannot drop a chapter.
@visibleForTesting
int? updatesWindowSince({
  required int? highWaterFetchedAt,
  required DateTime? lastFullUpdatesPullAt,
  required DateTime now,
  Duration fullEvery = const Duration(hours: 6),
  int overlapSeconds = 3600,
}) {
  if (highWaterFetchedAt == null || highWaterFetchedAt <= 0) return null;
  if (lastFullUpdatesPullAt == null || now.difference(lastFullUpdatesPullAt) >= fullEvery) return null;
  final since = highWaterFetchedAt - overlapSeconds;
  return since > 0 ? since : null;
}

class SyncEngine {
  static SyncEngine? _instance;
  final SyncCycleGate _cycleGate = SyncCycleGate();
  /// Whether a sync cycle (including a queued follow-up pass) is in flight.
  bool get isSyncing => _cycleGate.isSyncing;
  String? _deviceId;
  Completer<void>? _cycleCompleter;
  final StreamController<void> _syncCompleteController =
      StreamController<void>.broadcast();
  // Process-lifetime singleton (ISS-057); intentionally never cancelled.
  // ignore: cancel_subscriptions
  StreamSubscription<Map<String, dynamic>>? _wsUpdatePullSub;
  Timer? _wsUpdatePullTimer;

  // ISS-076: chapter-refresh fingerprints. In-memory by design: the first
  // cycle of every process run takes a full snapshot.
  final Map<int, String> _chapterFingerprints = {};
  final Map<int, DateTime> _lastFullChapterSnapshotAt = {};
  Map<int, String?> _currentLibraryFingerprints = const {};
  int _lastSnapshotSkipped = 0;

  /// How many library manga skipped the full chapter snapshot last cycle (ISS-076).
  int get lastChapterSnapshotSkippedCount => _lastSnapshotSkipped;

  bool _legacyLastSyncMetaCleaned = false;

  // ISS-074: updates time window.
  int? _updatesHighWaterFetchedAt;
  DateTime? _lastFullUpdatesPullAt;

  // Bumped on a server switch. A cycle records the epoch it started under and
  // stops at the next phase boundary once it no longer matches, so it never
  // sends the old server's manga ids to the new server.
  int _serverEpoch = 0;
  int _cycleEpoch = 0;
  bool get _serverSwitchedMidCycle => _serverEpoch != _cycleEpoch;

  /// Fires after each full sync cycle (including any one-deep queued follow-up
  /// pass) finishes. Library / onboarding listen so they can reload Isar when
  /// a mid-flight `triggerSync` was coalesced into the gate (ISS-059).
  Stream<void> get onSyncCycleComplete => _syncCompleteController.stream;

  /// Stable per-device id used for `lastSync_<id>` meta and SyncRecord rows.
  String? get deviceId => _deviceId;

  SyncEngine._();

  static SyncEngine get instance {
    _instance ??= SyncEngine._();
    return _instance!;
  }

  /// Resolves a stable device id: explicit [deviceId], else a persisted UUID in
  /// SettingsService, else a fresh UUID written there. Never falls back to the
  /// shared literal `default_device` (ISS-062).
  static Future<String> resolveStableDeviceId({String? deviceId}) async {
    if (deviceId != null && deviceId.trim().isNotEmpty && deviceId != 'default_device') {
      return deviceId.trim();
    }
    final existing = SettingsService.instance.syncDeviceId;
    if (existing != null && existing.trim().isNotEmpty && existing != 'default_device') {
      return existing.trim();
    }
    final minted = const Uuid().v4();
    SettingsService.instance.syncDeviceId = minted;
    return minted;
  }

  Future<void> initialize({String? deviceId}) async {
    _deviceId = await resolveStableDeviceId(deviceId: deviceId);
    await LoggerService.instance.logInfo('SyncEngine initialized for deviceId: $_deviceId', 'SyncEngine');
    await _loadDispatchAttempts();
    _ensureWsUpdatePullHook();
    await triggerSync();
  }

  /// ISS-057: when the server finishes a library update, pull recent chapters
  /// even if the Updates tab is not open (its listener alone was not enough).
  void _ensureWsUpdatePullHook() {
    if (_wsUpdatePullSub != null) return;
    _wsUpdatePullSub = WebSocketService.instance.onUpdateStatus.listen((event) {
      final jobs = event['jobsInfo'];
      final running = jobs is Map && jobs['isRunning'] == true;
      // Pull when a job reports idle / status progress, coalesced.
      if (running) return;
      _wsUpdatePullTimer?.cancel();
      _wsUpdatePullTimer = Timer(const Duration(milliseconds: 800), () {
        unawaited(triggerSync());
      });
    });
  }

  /// Reset failed/abandoned sync records back to pending so a manual retry can
  /// flush them again (Advanced Settings → "Retry failed sync").
  Future<int> retryFailedSyncRecords() async {
    final records = await IsarService.instance.getFailedSyncRecords();
    if (records.isEmpty) return 0;
    for (final record in records) {
      record.retryCount = 0;
      record.state = SyncRecordState.pending;
      // The in-memory attempt budget must restart too: without this a record
      // that failed 39 times transiently is abandoned after a single further
      // transient failure, so the manual retry silently does almost nothing
      // for exactly the records that need it most.
      _dispatchAttempts.remove(record.id);
      await IsarService.instance.saveSyncRecord(record);
    }
    // Persist the cleared attempt map and reload to sync in-memory state.
    // Without this, a process restart before the unawaited persist completes
    // would read the old persisted map (with high attempt counts) and the
    // "retried" records would immediately be treated as poisoned again.
    await _persistDispatchAttempts();
    await _loadDispatchAttempts();
    await LoggerService.instance.logInfo(
      'Reset ${records.length} failed/abandoned sync record(s) to pending for retry',
      'SyncEngine',
    );
    // Kick an immediate flush so the retry is not only queued for the next cycle.
    unawaited(triggerSync());
    return records.length;
  }

  /// Discards queued + failed sync records when the server URL changes.
  /// Returns the number discarded. Pending records carry small-int ids from
  /// the OLD server; replaying them against a new server would land progress
  /// and category edits on unrelated wrong series with no error surfaced.
  /// Deleting is deliberate: silent corruption beats silent loss, and the
  /// count is logged + surfaced so the user knows what was dropped.
  Future<int> quarantinePendingForServerSwitch() async {
    final pending = await IsarService.instance.getPendingSyncRecords();
    final failed = await IsarService.instance.getFailedSyncRecords();
    final ids = <int>{
      for (final r in [...pending, ...failed]) r.id,
    };
    for (final id in ids) {
      await IsarService.instance.deleteSyncRecord(id);
      _dispatchAttempts.remove(id);
    }
    // Clear in-flight sync state that targets the old server:
    _wsUpdatePullTimer?.cancel();
    _wsUpdatePullTimer = null;
    _progressLocks.clear();
    _lastDirectPage.clear();
    _updatesHighWaterFetchedAt = null;
    _lastFullUpdatesPullAt = null;
    _chapterFingerprints.clear();
    _lastFullChapterSnapshotAt.clear();
    _currentLibraryFingerprints = const {};
    _serverEpoch++;
    // A running cycle stops at its next phase boundary (see _serverEpoch);
    // ending the gate here instead let a second cycle start alongside it.
    // Queue one pass for the new server after it.
    if (_cycleGate.isSyncing) _cycleGate.tryBegin();
    unawaited(_persistDispatchAttempts());
    if (ids.isNotEmpty) {
      await LoggerService.instance.logWarning(
        'Server changed: discarded ${ids.length} queued/failed sync record(s) '
        'addressed to the previous server; re-mark anything missing',
        'SyncEngine',
      );
    }
    return ids.length;
  }

  /// Bypass wipe-guard and apply server library removals (Settings → Advanced).
  Future<void> forceReconcileWithServer() async {
    if (!GraphQLClientService.instance.isConfigured) return;
    // ISS-051: a request while a cycle runs is queued (one-deep) and replayed
    // once that cycle ends, instead of being silently dropped.
    if (!_cycleGate.tryBegin()) {
      final pending = _pendingForceReconcile ??= Completer<void>();
      return pending.future;
    }
    try {
      _cycleEpoch = _serverEpoch;
      final online = await GraphQLClientService.instance.checkServerReachable(force: true);
      if (!online) return;
      await _flushPendingMutations();
      await _syncCategories();
      await _performFullSync(forceLibraryRemovals: true);
      if (_serverSwitchedMidCycle) return;
      await _syncSourcesAndReplicate();
      await IsarService.instance.saveLastSyncTimestamp(DateTime.now());
    } finally {
      final rerun = _cycleGate.needsAnotherPass();
      _cycleGate.end();
      // A triggerSync that arrived during the reconcile is replayed, not lost.
      if (rerun && _pendingForceReconcile == null) unawaited(triggerSync());
      _drainPendingForceReconcile();
    }
  }

  Completer<void>? _pendingForceReconcile;

  void _drainPendingForceReconcile() {
    final pending = _pendingForceReconcile;
    if (pending == null || _cycleGate.isSyncing) return;
    _pendingForceReconcile = null;
    unawaited(forceReconcileWithServer().whenComplete(() {
      if (!pending.isCompleted) pending.complete();
    }));
  }

  /// Runs one sync cycle. Every log line from the cycle carries the same
  /// correlation id (UIX-18).
  Future<void> triggerSync() => LoggerService.withCorrelationAsync(_triggerSyncImpl);

  Future<void> _triggerSyncImpl() async {
    if (!GraphQLClientService.instance.isConfigured) {
      return;
    }
    // Hydration can call triggerSync before initialize(); mint/load a stable
    // device id first so sync meta is never written under default_device (ISS-062).
    if (_deviceId == null || _deviceId == 'default_device') {
      _deviceId = await resolveStableDeviceId();
    }
    // Single-flight with a one-deep queue: a call while busy schedules exactly
    // one follow-up cycle instead of being dropped. Mid-cycle callers await the
    // in-flight Completer so Library/onboarding reload Isar *after* the queued
    // pass finishes, not against a stale snapshot (ISS-059).
    if (!_cycleGate.tryBegin()) {
      final inFlight = _cycleCompleter;
      if (inFlight != null) {
        await inFlight.future;
      }
      return;
    }

    final cycleDone = Completer<void>();
    _cycleCompleter = cycleDone;
    try {
      do {
        _cycleGate.beginPass();
        _cycleEpoch = _serverEpoch;
        final isServerOnline = await GraphQLClientService.instance.checkServerReachable();
        if (!isServerOnline) {
          // Server is offline — silently keep local authoritative state without firing network queries
          continue;
        }
        try {
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            await WakelockCoordinator.instance.acquire('sync');
          }
        } catch (ignoredError) { if (kDebugMode) debugPrint('[sync_engine] ignored error: $ignoredError'); }
        try {
          await LoggerService.instance.logInfo('Starting sync cycle with server...', 'SyncEngine');
          await _flushPendingMutations();
          await _pullServerState();
          if (_serverSwitchedMidCycle) continue;
          // Sync health's "last successful sync" reads this; only the manual
          // delta path used to write it.
          await IsarService.instance.saveLastSyncTimestamp(DateTime.now());
          await LoggerService.instance.logInfo('Sync cycle completed successfully', 'SyncEngine');
        } catch (e, stack) {
          await LoggerService.instance.logError('Sync cycle error: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
        } finally {
          try {
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
              await WakelockCoordinator.instance.release('sync');
            }
          } catch (ignoredError) { if (kDebugMode) debugPrint('[sync_engine] ignored error: $ignoredError'); }
        }
      } while (_cycleGate.needsAnotherPass());
    } finally {
      _cycleGate.end();
      if (!cycleDone.isCompleted) cycleDone.complete();
      _drainPendingForceReconcile(); // ISS-051
      if (identical(_cycleCompleter, cycleDone)) {
        _cycleCompleter = null;
      }
      if (!_syncCompleteController.isClosed) {
        _syncCompleteController.add(null);
      }
    }
  }

  /// Applies a read-state change to [chapter], persists it, and syncs it —
  /// unless Incognito Mode is enabled, in which case nothing is written
  /// anywhere and false is returned.
  ///
  /// The Incognito guard used to live only inside the reader's `_updateProgress`,
  /// so the other eleven read-state mutation paths — marking a chapter read from
  /// the Library, Manga Detail, or the Updates feed, marking previous chapters
  /// read in bulk, and the migration flow — happily wrote progress to Isar and
  /// pushed it to the server with Incognito on. Turning the setting on therefore
  /// only protected the reader, which is the one entry point a user does not
  /// use to mark things read; the setting was trivially defeated.
  ///
  /// Centralised here so the guard cannot be forgotten at a new call site, and
  /// so the reader and the list screens behave identically. [lastPageRead] is
  /// optional and, when given, is authoritative for the stored position —
  /// including for a completion, where [Chapter.applyReadState] would otherwise
  /// force the position to `pageCount`. It is applied *after* `applyReadState`
  /// rather than before, because `applyReadState(false)` zeroes the position and
  /// would otherwise silently discard a partial-progress value.
  ///
  /// Returns whether anything was actually written, so callers can skip
  /// follow-up work (unread-count adjustment, snackbars) that would otherwise
  /// contradict the no-op.
  Future<bool> commitChapterReadState(
    Chapter chapter, {
    required bool isRead,
    int? lastPageRead,
    bool explicit = false,
  }) async {
    if (SettingsService.instance.incognitoMode) return false;
    chapter.applyReadState(isRead);
    if (lastPageRead != null) {
      chapter.lastPageRead = lastPageRead;
    }
    await IsarService.instance.saveChapter(chapter);
    if (isRead) {
      // Advance local read activity so History grouping, the in-progress query
      // and Library "Last Read" sorting all see this action without a resync.
      await stampLocalReadActivity(chapter);
    }
    if (chapter.serverId > 0) {
      // ISS-141: publish the explicit action's stamp as chapter meta.
      final actionAt = chapter.readStateActionAt;
      if (actionAt != null) unawaited(pushReadActionMeta([chapter.serverId], actionAt));
      // Intentionally not awaited: the offline path queues a SyncRecord and
      // the online path does a network round-trip, neither of which the UI
      // should block on. Matches every previous call site.
      unawaited(
        syncChapterProgress(
          chapter.serverId,
          isRead: isRead,
          lastPageRead: chapter.lastPageRead,
          explicit: explicit,
        ),
      );
    }
    return true;
  }

  /// Per-chapter serialization gates: rapid page turns fire overlapping
  /// `syncChapterProgress` calls, and without ordering two direct
  /// `updateChapterReadStatus` mutations (page 20, then 21) race with
  /// last-writer-wins persisting page 20 on the server. Chained futures make
  /// same-chapter work strictly ordered; different chapters stay parallel.
  /// Entries are removed on completion (identical-check) so the map cannot
  /// grow with the library.
  final Map<int, Future<void>> _progressLocks = {};

  /// Last successfully direct-dispatched page per chapter. An offline enqueue
  /// racing a just-completed direct dispatch max()es against this, so a
  /// stale queued page can never overwrite newer server state on replay.
  final Map<int, int> _lastDirectPage = {};

  /// ISS-069: multi-chapter mark read/unread in one `updateChapters` call.
  /// Falls back to per-chapter [syncChapterProgress] (which queues for replay
  /// offline) when the bulk call fails. Honors Incognito like the single path.
  Future<void> syncChaptersProgressBulk(
    List<int> chapterServerIds, {
    required bool isRead,
    int lastPageRead = 0,
  }) async {
    final ids = chapterServerIds.where((id) => id > 0).toSet().toList();
    if (ids.isEmpty || SettingsService.instance.incognitoMode) return;
    // ISS-141: bulk mark read/unread is an explicit action (library batch,
    // manga detail, updates).
    unawaited(pushReadActionMeta(ids, DateTime.now().millisecondsSinceEpoch ~/ 1000));
    if (GraphQLClientService.instance.isConfigured && ids.length > 1) {
      final res = await GraphQLClientService.instance
          .updateChapters(ids, isRead: isRead, lastPageRead: lastPageRead);
      if (res != null) {
        for (final id in ids) {
          _lastDirectPage[id] = lastPageRead;
          await _dropSupersededRecords(SyncEntityType.chapter, '$id', _isProgressPayload);
        }
        return;
      }
    }
    for (final id in ids) {
      await syncChapterProgress(id, isRead: isRead, lastPageRead: lastPageRead, explicit: true);
    }
  }

  /// ISS-142: floors an AUTOMATIC push at the server's current read state
  /// (fetched; the last-synced snapshot when the fetch fails). When the
  /// server is ahead, the local chapter adopts the server values so this
  /// device ends up at the newer progress too.
  Future<({bool isRead, int lastPageRead})> floorAutomaticProgress(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
  }) async {
    ({bool isRead, int lastPageRead})? server;
    try {
      server = await GraphQLClientService.instance.fetchChapterReadState(chapterServerId);
    } catch (_) {}
    Chapter? local;
    try {
      local = await IsarService.instance.getChapterByServerId(chapterServerId);
    } catch (_) {}
    final out = clampAutomaticProgress(
      isRead: isRead,
      lastPageRead: lastPageRead,
      serverIsRead: server?.isRead ?? local?.syncedIsRead,
      serverPage: server?.lastPageRead ?? local?.syncedLastPageRead,
    );
    if (local != null && (out.isRead != isRead || out.lastPageRead != lastPageRead)) {
      local
        ..isRead = out.isRead || local.isRead
        ..lastPageRead = out.lastPageRead > local.lastPageRead ? out.lastPageRead : local.lastPageRead;
      if (server != null) {
        local
          ..syncedIsRead = server.isRead
          ..syncedLastPageRead = server.lastPageRead;
      }
      try {
        await IsarService.instance.saveChapter(local);
      } catch (_) {}
    }
    return out;
  }

  /// ISS-141: best-effort `sunfire_read_action_at` chapter meta for explicit
  /// read-state actions. When it can't be written (offline, old server) other
  /// devices still see the change through the snapshot rule, stamped when
  /// they detect it.
  Future<void> pushReadActionMeta(List<int> chapterServerIds, int actionAtSeconds) async {
    if (SettingsService.instance.incognitoMode) return;
    final client = GraphQLClientService.instance;
    if (!client.isConfigured) return;
    for (final id in chapterServerIds) {
      if (id <= 0) continue;
      try {
        await client.setChapterMeta(id, kReadActionMetaKey, '$actionAtSeconds');
      } catch (e) {
        debugPrint('[SyncEngine] read action meta push skipped for $id: $e');
      }
    }
  }

  /// [explicit] marks a deliberate read-state action (Mark read/unread,
  /// reset, restart). Only explicit pushes may LOWER the server's progress;
  /// automatic ones are floored at the server's current value (ISS-142).
  Future<void> syncChapterProgress(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
    bool explicit = false,
  }) async {
    if (chapterServerId <= 0) return;
    // Defence in depth for [commitChapterReadState]. Anything that reaches the
    // network or the replay queue leaks reading history, and the replay queue in
    // particular would replay long after the user turned Incognito back off.
    if (SettingsService.instance.incognitoMode) return;

    final prior = _progressLocks[chapterServerId] ?? Future<void>.value();
    // Force async boundary so any synchronous throw in _syncChapterProgressInner
    // becomes a Future error, caught by the guarded chain. Without this, a
    // synchronous throw (e.g., JSON encoding, Isar closed) would propagate out
    // of the await below, leaving the guarded future stored but the work lost.
    final current = prior.then((_) => Future.sync(() => _syncChapterProgressInner(
          chapterServerId,
          isRead: isRead,
          lastPageRead: lastPageRead,
          explicit: explicit,
        )));
    // The stored chain must never complete with an error, or every later
    // waiter for this chapter would throw without doing work.
    final guarded = current.then<void>((_) {}, onError: (_) {});
    unawaited(guarded);
    _progressLocks[chapterServerId] = guarded;
    try {
      await current;
    } finally {
      if (identical(_progressLocks[chapterServerId], guarded)) {
        unawaited(_progressLocks.remove(chapterServerId));
      }
    }
  }

  Future<void> _syncChapterProgressInner(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
    bool explicit = false,
  }) async {

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          if (!explicit) {
            // ISS-142: never push automatic progress below the server's.
            final floored = await floorAutomaticProgress(chapterServerId, isRead: isRead, lastPageRead: lastPageRead);
            isRead = floored.isRead;
            lastPageRead = floored.lastPageRead;
          }
          final res = await GraphQLClientService.instance
              .updateChapterReadStatusWithClassification(
                chapterServerId,
                isRead,
                lastPageRead,
              );
          if (res.data != null) {
            // The server now has the latest progress, so any still-queued
            // progress update for this chapter is stale. Replaying it later
            // would overwrite this newer value with an older one.
            _lastDirectPage[chapterServerId] = lastPageRead;
            while (_lastDirectPage.length > 2000) {
              _lastDirectPage.remove(_lastDirectPage.keys.first);
            }
            if (explicit) {
              // Newest explicit action wins, so every older queued progress
              // record (explicit ones included) is stale now.
              await _dropSupersededRecords(SyncEntityType.chapter, '$chapterServerId', _isProgressPayload);
            } else {
              await _dropQueuedProgressRecords(chapterServerId);
            }
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
    final existing = explicit
        ? const <SyncRecord>[]
        : (await IsarService.instance.getPendingChapterRecords(chapterServerId.toString()))
            .where((r) =>
                r.action == SyncAction.update && r.retryCount == 0 && isPureChapterProgressPayload(r.payloadJson))
            .toList();

    if (existing.isNotEmpty) {
      final record = existing.first;
      // Never let a coalesce move progress backwards. Two overlapping
      // debounced page turns (page 20 then page 21) can both read the same
      // queued record before either writes; without this max() the slower
      // writer persisted page 20 over page 21 and the replay uploaded stale
      // progress. Same reason for isRead: a queued "read" must not be undone
      // by a late "unread" from the same burst. The just-dispatched page
      // joins the max so an offline enqueue racing a completed direct send
      // cannot rewind the server either.
      final queued = _readQueuedProgress(record.payloadJson);
      final incoming = lastPageRead;
      var bestPage = queued == null ? incoming : (incoming > queued ? incoming : queued);
      final direct = _lastDirectPage[chapterServerId];
      if (direct != null && direct > bestPage) bestPage = direct;
      final bestRead = isRead || (queued == null ? false : _readQueuedIsRead(record.payloadJson));

      record.payloadJson = jsonEncode({
        'chapterId': chapterServerId,
        'isRead': bestRead,
        'lastPageRead': bestPage,
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

    if (explicit) {
      // An explicit reset/unread supersedes automatic progress queued before
      // it. Left in place, a later page turn coalesced onto that older record
      // (max page, read OR) and replayed after the reset, undoing it.
      await _dropQueuedProgressRecords(chapterServerId);
      _lastDirectPage.remove(chapterServerId);
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
        // ISS-142: an explicit action replays as-is (and is never coalesced
        // with automatic progress, see isPureChapterProgressPayload).
        if (explicit) 'explicit': true,
        if (explicit) 'actionAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      })
      ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
      ..deviceId = _deviceId ?? 'default_device'
      ..state = SyncRecordState.pending;
    await IsarService.instance.saveSyncRecord(record);
  }

  /// Reads `lastPageRead` out of a queued progress payload, or null when the
  /// payload is absent/unparseable.
  static int? _readQueuedProgress(String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map) return null;
      final v = decoded['lastPageRead'];
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '');
    } catch (_) {
      return null;
    }
  }

  /// Reads `isRead` out of a queued progress payload; defaults to false when
  /// the payload is absent/unparseable.
  static bool _readQueuedIsRead(String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) return false;
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map) return false;
      return parseBoolSafe(decoded['isRead']);
    } catch (_) {
      return false;
    }
  }

  /// Deletes queued records for one entity that a direct push just made
  /// stale. Left in the queue they replay on the next flush and undo the
  /// newer value (a removed bookmark comes back, a category edit reverts).
  Future<void> _dropSupersededRecords(
    SyncEntityType type,
    String entityId,
    bool Function(Map<String, dynamic> payload) matches,
  ) async {
    try {
      for (final r in await IsarService.instance.getPendingSyncRecords()) {
        if (r.entityType != type || r.entityId != entityId) continue;
        final payload = jsonDecode(r.payloadJson);
        if (payload is Map<String, dynamic> && matches(payload)) {
          await IsarService.instance.deleteSyncRecord(r.id);
        }
      }
    } catch (e) {
      debugPrint('[SyncEngine] superseded record cleanup skipped for $entityId: $e');
    }
  }

  static bool _isProgressPayload(Map<String, dynamic> p) =>
      p.containsKey('lastPageRead') && !p.containsKey('isBookmarked');

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

  /// Records local read activity for a chapter marked read/unread **outside**
  /// the Reader.
  ///
  /// The Reader stamps `Chapter.lastReadAt` and the parent `Manga.lastReadAt`
  /// itself before calling [syncChapterProgress]. Every other mark-read entry
  /// point (Library, Manga Detail, Updates, source migration) only pushed the
  /// read flag, so the local chapter kept a stale or NULL `lastReadAt`.
  /// Consequences, all observable:
  ///  - History's "Last Read" grouping skipped the chapter,
  ///  - the in-progress query (`lastReadAt > 0`) excluded it,
  ///  - Library "Last Read" sorting did not float the series to the top,
  /// and a later pull could resurrect the older server timestamp over the
  /// action the user just took.
  ///
  /// Un-marking does not move the timestamp backwards: a chapter that is
  /// marked unread keeps its previous `lastReadAt` so it still appears in
  /// History, but only a fresh read activity (newer stamp) advances it.
  Future<void> stampLocalReadActivity(Chapter chapter) async {
    // Public read-state writer, so it has to be safe by construction rather
    // than relying on every call site to remember. commitChapterReadState and
    // syncChapterProgress both guard; this one did not, which made it a loaded
    // gun — the source-migration flow used it to write a full read history
    // with Incognito on, and nothing about that path was guarded.
    if (SettingsService.instance.incognitoMode) return;

    // Epoch SECONDS — Chapter.lastReadAt / Manga.lastReadAt are seconds
    // everywhere (see reader_screen). Mixing in millis breaks sorting.
    final stamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if ((chapter.lastReadAt ?? 0) < stamp) {
      chapter.lastReadAt = stamp;
      await IsarService.instance.saveChapter(chapter);
    }

    // Keep the series-level stamp in sync for Library "Last Read" sorting.
    final mangaId = chapter.mangaId;
    if (mangaId <= 0) return;
    try {
      final manga = await IsarService.instance.getMangaByServerId(mangaId);
      if (manga == null) return;
      if ((manga.lastReadAt ?? 0) < stamp) {
        manga.lastReadAt = stamp;
        await IsarService.instance.saveManga(manga);
      }
    } catch (e) {
      // A missing/renumbered manga must not fail the read toggle.
      await LoggerService.instance.logWarning(
        'Failed to stamp series lastReadAt for manga $mangaId: $e',
        'SyncEngine',
      );
    }
  }

  Future<void> syncChapterBookmark(int chapterServerId, bool isBookmarked) async {
    if (chapterServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateChapterBookmark(chapterServerId, isBookmarked);
          if (res != null) {
            await _dropSupersededRecords(
                SyncEntityType.chapter, '$chapterServerId', (p) => p.containsKey('isBookmarked'));
            return;
          }
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

  // ── UIX6-06: optimistic actions with an outbox + undo ────────────────

  Future<OutboxResult> _applyOrQueue(
    Future<void> Function() send,
    SyncRecord Function() buildRecord,
  ) async {
    try {
      await send();
      return const OutboxResult.applied();
    } on ServerMutationException catch (e) {
      if (!e.isTransportFailure) rethrow;
      final rec = buildRecord()
        ..recordId = const Uuid().v4()
        ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
        ..deviceId = _deviceId ?? 'default_device'
        ..state = SyncRecordState.pending;
      await IsarService.instance.saveSyncRecord(rec);
      return OutboxResult.queued(rec.id);
    }
  }

  /// Sets a manga's server library state. Transport failure → queued for
  /// replay (result.queued, keep the optimistic local change, offer Undo).
  /// Server rejection → throws [ServerMutationException] (roll back locally).
  ///
  /// [categoryIds] (adds only; ignored when removing): applied with an
  /// add-to-categories patch (never the clear+set assign), both directly and
  /// when a queued add is replayed, so the default category survives offline.
  Future<OutboxResult> setMangaInLibraryWithOutbox(
    int mangaServerId,
    bool inLibrary, {
    List<int>? categoryIds,
  }) {
    final cats = inLibrary ? (categoryIds ?? const <int>[]) : const <int>[];
    return _applyOrQueue(
      () => cats.isEmpty
          ? GraphQLClientService.instance.setMangaInLibraryOrThrow(mangaServerId, inLibrary)
          : GraphQLClientService.instance.addMangaToLibraryOrThrow(mangaServerId, categoryIds: cats),
      () => SyncRecord()
        ..entityType = SyncEntityType.manga
        ..entityId = mangaServerId.toString()
        ..action = inLibrary ? SyncAction.update : SyncAction.delete
        ..payloadJson = jsonEncode({
          'mangaId': mangaServerId,
          'inLibrary': inLibrary,
          if (cats.isNotEmpty) 'categoryIds': cats,
        }),
    );
  }

  /// Binds a tracker; queued on transport failure.
  Future<OutboxResult> bindTrackWithOutbox(int mangaServerId, int trackerId, Object remoteId, {bool? isPrivate}) =>
      _applyOrQueue(
        () => GraphQLClientService.instance.bindTrack(mangaServerId, trackerId, remoteId, isPrivate: isPrivate),
        () => SyncRecord()
          ..entityType = SyncEntityType.tracker
          ..entityId = 'manga_$mangaServerId'
          ..action = SyncAction.update
          ..payloadJson = jsonEncode({
            'op': 'bind',
            'mangaId': mangaServerId,
            'trackerId': trackerId,
            'remoteId': remoteId.toString(),
            if (isPrivate != null) 'private': isPrivate,
          }),
      );

  /// Unbinds a track record; queued on transport failure.
  Future<OutboxResult> unbindTrackWithOutbox(int recordId) => _applyOrQueue(
        () => GraphQLClientService.instance.unbindTrack(recordId),
        () => SyncRecord()
          ..entityType = SyncEntityType.tracker
          ..entityId = 'record_$recordId'
          ..action = SyncAction.update
          ..payloadJson = jsonEncode({'op': 'unbind', 'recordId': recordId}),
      );

  /// ISS-105: adds a manga to [categoryIds] (add-only patch, never the
  /// clear+set assign, so replay cannot wipe other categories). Queued on
  /// transport failure; server rejection throws [ServerMutationException].
  Future<OutboxResult> addMangaToCategoriesWithOutbox(int mangaServerId, List<int> categoryIds) {
    final cats = List<int>.of(categoryIds);
    return _applyOrQueue(
      () => GraphQLClientService.instance.addMangaToCategoriesOrThrow(mangaServerId, cats),
      () => SyncRecord()
        ..entityType = SyncEntityType.category
        ..entityId = 'manga_$mangaServerId'
        ..action = SyncAction.update
        ..payloadJson = jsonEncode({'op': 'addTo', 'mangaId': mangaServerId, 'categoryIds': cats}),
    );
  }

  /// ISS-105: removes an extension store (by index URL). Queued on transport
  /// failure; server rejection throws [ServerMutationException].
  Future<OutboxResult> removeExtensionStoreWithOutbox(String indexUrl) {
    final url = indexUrl.trim();
    return _applyOrQueue(
      () => _removeExtensionStoreOrThrow(url),
      () => SyncRecord()
        ..entityType = SyncEntityType.source
        ..entityId = 'store_$url'
        ..action = SyncAction.delete
        ..payloadJson = jsonEncode({'op': 'removeStore', 'indexUrl': url}),
    );
  }

  Future<void> _removeExtensionStoreOrThrow(String url) async {
    final res = await GraphQLClientService.instance.removeExtensionStoreWithClassification(url);
    if (res.data == null) {
      throw ServerMutationException('removeExtensionStore', isTransportFailure: res.wasTransportFailure);
    }
  }

  /// Undo for a queued action: removes the outbox record if it has not been
  /// dispatched yet. Returns false when it was already sent / gone (the UI
  /// must then issue the inverse action instead).
  Future<bool> undoQueuedMutation(int undoToken) async {
    final rec = await IsarService.instance.getSyncRecord(undoToken);
    if (rec == null || rec.state != SyncRecordState.pending) return false;
    await IsarService.instance.deleteSyncRecord(undoToken);
    return true;
  }

  Future<void> syncMangaLibraryState(int mangaServerId, bool inLibrary) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance.updateMangaLibraryState(mangaServerId, inLibrary);
          if (res != null) {
            await _dropSupersededRecords(SyncEntityType.manga, '$mangaServerId', (p) => p.containsKey('inLibrary'));
            return;
          }
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
          final res = await GraphQLClientService.instance
              .createCategoryWithClassification(name);
          final created = res.data?['createCategory']?['category'];
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
                cat.order = parseIntSafe(created['order']);
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
      final ids = (payload['categoryIds'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? const <int>[];
      return ids.contains(categoryId);
    } catch (ignoredError) {
      return false;
    }
  }

  /// Per-manga serialization for category assign coalescing. Rapid UI toggles
  /// fire overlapping `syncMangaCategories` calls, and without ordering two
  /// assign mutations race: both load pending assigns, both delete each other's
  /// records, both save — one assign is lost. Chained futures make same-manga
  /// work strictly ordered; different manga stay parallel.
  final Map<int, Future<void>> _categoryAssignLocks = {};

  Future<void> syncMangaCategories(int mangaServerId, List<int> categoryIds, {List<int>? existingCategoryIds}) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance
              .setMangaCategories(mangaServerId, categoryIds, existingCategoryIds: existingCategoryIds);
          if (res != null) {
            await _dropSupersededRecords(
                SyncEntityType.category, 'manga_$mangaServerId', (p) => p['op']?.toString() == 'assign');
            return;
          }
        } catch (e) {
          await LoggerService.instance.logWarning('Direct manga categories sync failed ($mangaServerId): $e, queuing', 'SyncEngine');
        }
      }
    }

    final prior = _categoryAssignLocks[mangaServerId] ?? Future<void>.value();
    final current = prior.then((_) => _syncMangaCategoriesInner(
          mangaServerId,
          categoryIds,
        ));
    final guarded = current.then<void>((_) {}, onError: (_) {});
    unawaited(guarded);
    _categoryAssignLocks[mangaServerId] = guarded;
    try {
      await current;
    } finally {
      if (identical(_categoryAssignLocks[mangaServerId], guarded)) {
        unawaited(_categoryAssignLocks.remove(mangaServerId));
      }
    }
  }

  Future<void> _syncMangaCategoriesInner(
    int mangaServerId,
    List<int> categoryIds,
  ) async {
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
    // Coalesce like chapter progress: an assign payload carries the FULL
    // category list, so older pending assigns for this manga are pure waste
    // (and replay N full setMangaCategories mutations where one suffices).
    try {
      final pending = await IsarService.instance.getPendingSyncRecords();
      for (final r in pending) {
        if (r.entityType == SyncEntityType.category &&
            r.entityId == 'manga_$mangaServerId' &&
            r.state == SyncRecordState.pending &&
            _isAssignPayload(r.payloadJson)) {
          await IsarService.instance.deleteSyncRecord(r.id);
        }
      }
    } catch (e) { debugPrint('[sync_engine] ignored: $e'); }
    await IsarService.instance.saveSyncRecord(record);
  }

  /// True when a sync payload is a category-assign op (full category list).
  static bool _isAssignPayload(String? payloadJson) {
    if (payloadJson == null || payloadJson.isEmpty) return false;
    try {
      final decoded = jsonDecode(payloadJson);
      return decoded is Map && decoded['op']?.toString() == 'assign';
    } catch (_) {
      return false;
    }
  }

  Future<void> syncCategoryRename(int categoryServerId, String newName) async {
    if (categoryServerId < 0 || newName.trim().isEmpty) return;
    final trimmed = newName.trim();

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance
              .updateCategoryNameWithClassification(categoryServerId, trimmed);
          if (res.data != null) return;
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
    // Defence in depth, mirroring syncChapterProgress: this pushes straight to
    // MAL/AniList and, offline, enqueues a durable SyncRecord that would
    // replay long after the user turned Incognito back off.
    if (SettingsService.instance.incognitoMode) return;

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
    // A null payload means the fetch failed (transport/GraphQL error) — we do
    // NOT know whether a tracker is bound, so treat it as a failure so the
    // pending mutation is retried rather than silently dropped as "success".
    if (data == null) return false;
    final nodes = data['trackRecords']?['nodes'];
    if (nodes is! List || nodes.isEmpty) return true; // nothing bound — treat as success
    final res = await GraphQLClientService.instance.trackProgressWithClassification(mangaServerId);
    if (res.data == null) {
      // ISS-098: carry the transport classification out via the exception.
      throw ServerMutationException('trackProgress',
          isTransportFailure: res.wasTransportFailure);
    }
    return true;
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
        final ids = (payload['categoryIds'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
        final replaced = ids.map((id) => id == localServerId ? remoteId : id).toList();
        if (ids.join(',') != replaced.join(',')) {
          payload['categoryIds'] = replaced;
          rec.payloadJson = jsonEncode(payload);
          changed.add(rec);
        }
      } catch (e) {
        // NOT debugPrint. `kDebugMode` is a compile-time constant, so in a
        // release build this was a bare empty catch — and this is the offline
        // category-id remap, where a dropped payload means every manga assigned
        // to that category offline stays unassigned PERMANENTLY. The category
        // exists on the server and nothing references it.
        unawaited(LoggerService.instance.logWarning(
          'Failed to remap a pending category assignment; that manga will stay '
          'unassigned: $e',
          'SyncEngine',
        ));
      }
    }
    return changed;
  }

  /// Test seam: runs one replay pass over the pending mutation queue.
  @visibleForTesting
  Future<void> debugFlushPendingMutations() => _flushPendingMutations();

  /// Lease holder id for this isolate; the WorkManager task runs a second
  /// SyncEngine in its own isolate against the same queue.
  final String _flushLeaseOwner = const Uuid().v4();
  static const String _flushLeaseKey = 'sync_flush_lease';
  bool _dispatchAttemptsLoaded = false;

  Future<void> _flushPendingMutations() async {
    final pendingRecords = await IsarService.instance.getPendingSyncRecords();
    if (pendingRecords.isEmpty) return;
    // The background isolate never runs initialize(); without this its first
    // failure persisted a near-empty attempt map over the real one.
    if (!_dispatchAttemptsLoaded) await _loadDispatchAttempts();
    if (!await IsarService.instance.tryAcquireLease(_flushLeaseKey, _flushLeaseOwner, const Duration(seconds: 30))) {
      await LoggerService.instance.logInfo('Another isolate is flushing the sync queue; skipping this flush', 'SyncEngine');
      return;
    }
    try {
      await _flushRecords(pendingRecords);
    } finally {
      await IsarService.instance.releaseLease(_flushLeaseKey, _flushLeaseOwner);
    }
  }

  Future<void> _flushRecords(List<SyncRecord> pendingRecords) async {

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
      // Renews this isolate's lease so a long flush is not taken over mid-run.
      if (!await IsarService.instance.tryAcquireLease(_flushLeaseKey, _flushLeaseOwner, const Duration(seconds: 30))) {
        return;
      }
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

      // Incognito also has to cover the REPLAY path, not just enqueue.
      //
      // The guard lives at enqueue time, so a chapter read offline BEFORE the
      // user turned Incognito on was still sitting in the queue and got pushed
      // on the next flush — the opposite of what turning it on is for. Skip
      // chapter updates (read progress AND bookmarks — both are reading
      // activity) while it is on; they stay queued and replay if the user
      // turns it back off. Tracker `mangaProgress` replays are held back too
      // (inside the try below, after the payload is decoded). Category edits,
      // library membership and other tracker ops are deliberate user actions
      // and still go through.
      if (SettingsService.instance.incognitoMode &&
          record.entityType == SyncEntityType.chapter &&
          record.action == SyncAction.update) {
        continue;
      }
      try {
        // Decoded inside the try: a corrupt payload must land in the catch
        // (non-transient failure, retry budget spent) instead of aborting the
        // whole flush — and with it every later pull — on every sync cycle.
        final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
        // Incognito also holds back tracker *progress* replays (they leak
        // reading activity to MAL/AniList). Deliberate tracker ops still go
        // through. The record stays pending for when Incognito is turned off.
        if (SettingsService.instance.incognitoMode &&
            record.entityType == SyncEntityType.tracker &&
            record.action == SyncAction.update &&
            payload['op']?.toString() == 'mangaProgress') {
          continue;
        }
        bool success = false;
        // ISS-098: set by branches that know whether the failure was transport.
        var failTransient = false;

        switch (record.entityType) {
          case SyncEntityType.chapter:
            if (record.action == SyncAction.update) {
              // Re-read record immediately before dispatch to ensure we have
              // the latest payload (concurrent coalescing may have updated it).
              final freshRecord = await IsarService.instance.getSyncRecord(record.id);
              if (freshRecord == null || freshRecord.state != SyncRecordState.pending) {
                continue;
              }
              final freshPayload = jsonDecode(freshRecord.payloadJson) as Map<String, dynamic>;
              final chapterId = parseIntSafe(freshPayload['chapterId']);
              if (chapterId > 0) {
                var allOk = true;
                var attempted = false;
                bool wasTransportFailure = false;
                if (chapterMutationNeedsBookmark(freshPayload)) {
                  attempted = true;
                  final isBookmarked = parseBoolSafe(freshPayload['isBookmarked']);
                  final res = await GraphQLClientService.instance
                      .updateChapterBookmarkWithClassification(chapterId, isBookmarked);
                  allOk = allOk && res.data != null;
                  wasTransportFailure = wasTransportFailure || res.wasTransportFailure;
                }
                if (chapterMutationNeedsReadProgress(freshPayload)) {
                  attempted = true;
                  var isRead = parseBoolSafe(freshPayload['isRead']);
                  var lastPageRead = parseIntSafe(freshPayload['lastPageRead']);
                  final explicitAction = freshPayload['explicit'] == true;
                  if (!explicitAction) {
                    // ISS-142: a stale queued automatic update must not
                    // rewind progress another device already pushed.
                    final floored = await floorAutomaticProgress(chapterId, isRead: isRead, lastPageRead: lastPageRead);
                    isRead = floored.isRead;
                    lastPageRead = floored.lastPageRead;
                  }
                  final res = await GraphQLClientService.instance
                      .updateChapterReadStatusWithClassification(chapterId, isRead, lastPageRead);
                  allOk = allOk && res.data != null;
                  wasTransportFailure = wasTransportFailure || res.wasTransportFailure;
                  final actionAt = freshPayload['actionAt'];
                  if (explicitAction && res.data != null && actionAt is num) {
                    unawaited(pushReadActionMeta([chapterId], actionAt.toInt()));
                  }
                }
                success = attempted && allOk;
                // Capture the transport failure classification for this dispatch.
                // This replaces reading the shared `lastRequestWasTransportFailure` flag
                // which was subject to cross-request races.
                if (!success) {
                  await _recordDispatchFailure(
                    record,
                    transient: wasTransportFailure,
                  );
                  continue;
                }
              } else {
                // `parseIntSafe` returns 0 for a missing or non-numeric id, so
                // a corrupt payload landed here and was reported as SUCCESS.
                // The record was then deleted by _completeDispatchedRecord —
                // the mutation was destroyed without ever being sent, and
                // nothing was logged. The user believes it synced.
                //
                // A payload that cannot be interpreted must never be reported
                // as delivered. Treat as transient failure so it can be retried
                // or surfaced to the user, not silently abandoned.
                await _recordDispatchFailure(freshRecord, transient: true);
                await LoggerService.instance.logWarning(
                  'Corrupt chapter mutation ${freshRecord.id}: payload has no usable chapterId '
                  '(${freshRecord.payloadJson}) — will retry',
                  'SyncEngine',
                );
              }
            }
            break;
          case SyncEntityType.tracker:
            if (record.action == SyncAction.update) {
              // Re-read record immediately before dispatch.
              final freshRecord = await IsarService.instance.getSyncRecord(record.id);
              if (freshRecord == null || freshRecord.state != SyncRecordState.pending) {
                continue;
              }
              final freshPayload = jsonDecode(freshRecord.payloadJson) as Map<String, dynamic>;
              final op = freshPayload['op']?.toString() ?? '';
              if (op == 'mangaProgress') {
                final mangaId = parseIntSafe(freshPayload['mangaId']);
                final res = await GraphQLClientService.instance.trackProgressWithClassification(mangaId);
                success = res.data != null;
                if (!success) failTransient = res.wasTransportFailure;
              } else if (op == 'bind') {
                await GraphQLClientService.instance.bindTrack(
                  parseIntSafe(freshPayload['mangaId']),
                  parseIntSafe(freshPayload['trackerId']),
                  freshPayload['remoteId'],
                  isPrivate: freshPayload['private'] is bool ? freshPayload['private'] as bool : null,
                );
                success = true;
              } else if (op == 'unbind') {
                await GraphQLClientService.instance.unbindTrack(parseIntSafe(freshPayload['recordId']));
                success = true;
              } else {
                final mangaId = parseIntSafe(freshPayload['mangaId']);
                final res = await GraphQLClientService.instance.trackProgressWithClassification(mangaId);
                success = res.data != null;
                if (!success) failTransient = res.wasTransportFailure;
              }
            }
            break;
          case SyncEntityType.manga:
            if (record.action == SyncAction.update || record.action == SyncAction.delete) {
              // Re-read record immediately before dispatch.
              final freshRecord = await IsarService.instance.getSyncRecord(record.id);
              if (freshRecord == null || freshRecord.state != SyncRecordState.pending) {
                continue;
              }
              final freshPayload = jsonDecode(freshRecord.payloadJson) as Map<String, dynamic>;
              final mangaId = parseIntSafe(freshPayload['mangaId']);
              final inLibrary = parseBoolSafe(freshPayload['inLibrary']);
              final cats = inLibrary && freshPayload['categoryIds'] is List
                  ? (freshPayload['categoryIds'] as List).map(parseIntSafe).toList()
                  : const <int>[];
              // Throws ServerMutationException (classified) on failure.
              if (cats.isEmpty) {
                await GraphQLClientService.instance.setMangaInLibraryOrThrow(mangaId, inLibrary);
              } else {
                // Add-to-categories replay (never the set-list assign).
                await GraphQLClientService.instance.addMangaToLibraryOrThrow(mangaId, categoryIds: cats);
              }
              success = true;
            }
            break;
          case SyncEntityType.category:
            final op = payload['op']?.toString() ?? '';
            if (op == 'create' || record.action == SyncAction.create) {
              final name = payload['name']?.toString() ?? '';
              final localServerId = parseIntSafe(payload['localServerId']);

              // Adopt an existing same-named category instead of blindly
              // creating a second one.
              //
              // `createCategory` is not idempotent, and `query()` returns null
              // for a transport failure indistinguishably from a rejection. So
              // if the server committed the create but the response was lost,
              // this record was recorded as a transient failure and retried on
              // the next cycle — creating a DUPLICATE. The local row was then
              // remapped to the second id and the first orphan stayed on the
              // server, which the next pull wrote back locally as a real
              // category. The user ended up with two identically named tabs,
              // one of which nothing referenced.
              //
              // Probing by name first makes the create effectively idempotent.
              Map<String, dynamic>? created;
              final existing = await GraphQLClientService.instance.fetchCategories();
              final categoriesListed = existing != null && existing['categories'] is Map;
              if (categoriesListed) {
                final nodes = (existing['categories'] as Map)['nodes'];
                if (nodes is List) {
                  for (final n in nodes.whereType<Map<String, dynamic>>()) {
                    final existingName = (n['name'] as String? ?? '').trim().toLowerCase();
                    if (existingName.isNotEmpty && existingName == name.trim().toLowerCase()) {
                      created = n;
                      break;
                    }
                  }
                }
              }
              if (created == null) {
                if (!categoriesListed) {
                  // The probe itself failed: a previous attempt may have
                  // committed server-side while its response was lost.
                  // Creating blindly duplicates the category; defer to the
                  // next flush (which probes first) via an explicit transient
                  // failure, skipping the generic epilogue below.
                  // Only treat as transient if it's a transport failure; permanent
                  // errors (4xx) should not retry endlessly.
                  final res = await GraphQLClientService.instance.fetchCategories();
                  final isTransient = res == null || GraphQLClientService.instance.lastRequestWasTransportFailure;
                  await _recordDispatchFailure(record, transient: isTransient);
                  continue;
                }
                created ??= (await GraphQLClientService.instance.createCategory(name))?['createCategory']?['category'] as Map<String, dynamic>?;
              }
              if (created != null) {
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
                // Only a real, usable remote id counts as success. The server
                // answering with a payload we cannot read a positive id from
                // means the local row was never remapped, so every queued
                // 'assign' still carries the dead temporary id and the server
                // will silently drop those assignments forever.
                final remoteIdParsed = parseIntSafe(created['id']);
                success = remoteIdParsed > 0;
                if (!success) {
                  await LoggerService.instance.logWarning(
                    'Category create for "$name" returned no usable id '
                    '(${record.payloadJson}); the local row was not remapped and '
                    'queued assignments still reference the temporary id',
                    'SyncEngine',
                  );
                }
              }
            } else if (op == 'delete' || record.action == SyncAction.delete) {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final res = await GraphQLClientService.instance.deleteCategoryWithClassification(categoryId);
              success = res.data != null;
              // ISS-098: a transport failure must not burn the retry budget.
              if (!success) failTransient = res.wasTransportFailure;
            } else if (op == 'addTo') {
              // ISS-105: add-only replay; throws → classified in the catch.
              final mangaId = parseIntSafe(payload['mangaId']);
              final ids = (payload['categoryIds'] as List?)?.map((e) => parseIntSafe(e)).toList() ?? <int>[];
              if (mangaId > 0 && ids.isNotEmpty) {
                await GraphQLClientService.instance.addMangaToCategoriesOrThrow(mangaId, ids);
              }
              success = true;
            } else if (op == 'assign') {
              final mangaId = parseIntSafe(payload['mangaId']);
              final ids = (payload['categoryIds'] as List?)?.map((e) => parseIntSafe(e)).toList() ?? <int>[];
              final res = await GraphQLClientService.instance
                  .setMangaCategoriesWithClassification(mangaId, ids);
              success = res.data != null;
              if (!success) {
                await _recordDispatchFailure(record, transient: res.wasTransportFailure);
                continue;
              }
            } else if (op == 'rename') {
              final categoryId = parseIntSafe(payload['categoryId'] ?? record.entityId);
              final name = payload['name']?.toString() ?? '';
              final res = await GraphQLClientService.instance
                  .updateCategoryNameWithClassification(categoryId, name);
              success = res.data != null;
              if (!success) {
                await _recordDispatchFailure(record, transient: res.wasTransportFailure);
                continue;
              }
            }
            break;
          case SyncEntityType.source:
            if (payload['op'] == 'removeStore') {
              // ISS-105: throws → classified (transient vs permanent) below.
              await _removeExtensionStoreOrThrow(payload['indexUrl']?.toString() ?? '');
              success = true;
            }
            break;
        }

        if (success) {
          await _completeDispatchedRecord(record);
        } else {
          // ISS-098: branches report transport failures via [failTransient] or
          // by throwing ServerMutationException (classified in the catch below
          // via isTransientSyncError). Anything else burns retry budget.
          await _recordDispatchFailure(record, transient: failTransient);
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
    // The record is done, so its attempt budget is spent.
    _dispatchAttempts.remove(dispatched.id);
    unawaited(_persistDispatchAttempts());
    if (current.payloadJson == dispatched.payloadJson) {
      await IsarService.instance.deleteSyncRecord(dispatched.id);
    } else {
      await LoggerService.instance.logInfo(
        'SyncRecord #${dispatched.id} changed while in flight — keeping it queued for the next cycle',
        'SyncEngine',
      );
    }
  }

  /// Failed-dispatch attempt count per record id, for this process only.
  ///
  /// `SyncRecord.retryCount` deliberately does not move for transient failures,
  /// because a dropped connection is not the server rejecting the mutation and
  /// must not spend the rejection budget. The consequence was that a record
  /// failing only on transport errors had NO counter at all — the sole bound was
  /// a wall-clock age computed from `DateTime.now()`, which is not monotonic.
  ///
  /// In-memory rather than a new persisted column so the Isar schema (and its
  /// generated file) is untouched. Within a session this is the bound that
  /// actually stops a poison record: `_isTransportFailure` classifies any 5xx as
  /// transport, so a schema error or a misconfigured proxy rule previously
  /// re-attempted the same mutation on every sync cycle, burning battery, radio
  /// and server capacity, and never surfacing to the user. Across restarts the
  /// 14-day age bound still applies.
  final Map<int, int> _dispatchAttempts = {};

  /// Serialization chain for attempt persistence. Multiple callers (flush,
  /// retry, quarantine) fire concurrent `setString`; without serialization
  /// the last writer wins and earlier updates are lost, resetting poison
  /// records' attempt budgets on restart.
  Future<void> _attemptsSaveChain = Future.value();

  /// Prefs key for the persisted attempt map. A poison record failing only
  /// with transport-classified errors otherwise gets a fresh 40-attempt
  /// budget on every launch (the map above is process-local) and hammers
  /// for up to 14 days per restart.
  static const _dispatchAttemptsPrefKey = 'sunfire_sync_attempts_v1';

  /// Cap: the map is diagnostic ballast, never unbounded storage.
  static const _maxPersistedAttempts = 500;

  Future<void> _persistDispatchAttempts() {
    _attemptsSaveChain = _attemptsSaveChain.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        var entries = _dispatchAttempts.entries.toList();
        if (entries.length > _maxPersistedAttempts) {
          entries = entries.sublist(entries.length - _maxPersistedAttempts);
        }
        await prefs.setString(_dispatchAttemptsPrefKey,
            jsonEncode({for (final e in entries) e.key.toString(): e.value}));
      } catch (e) { debugPrint('[sync_engine] ignored: $e'); }
    });
    return _attemptsSaveChain;
  }

  /// Restores attempt budgets, keeping only ids that still exist as
  /// pending/failed records (a success between persist and restart must not
  /// keep penalizing anything).
  Future<void> _loadDispatchAttempts() async {
    _dispatchAttemptsLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dispatchAttemptsPrefKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final live = <int>{};
      for (final r in await IsarService.instance.getPendingSyncRecords()) {
        live.add(r.id);
      }
      for (final r in await IsarService.instance.getFailedSyncRecords()) {
        live.add(r.id);
      }
      _dispatchAttempts.clear();
      decoded.forEach((k, v) {
        final id = int.tryParse(k.toString());
        final n = v is int ? v : int.tryParse(v.toString());
        if (id != null && n != null && n > 0 && live.contains(id)) {
          _dispatchAttempts[id] = n;
        }
      });
    } catch (e) { debugPrint('[sync_engine] ignored: $e'); }
  }

  /// Applies retry accounting after a failed dispatch. Re-reads the record so
  /// only `retryCount`/`state` are written and a payload coalesced during the
  /// request isn't reverted by saving the stale in-memory copy.
  Future<void> _recordDispatchFailure(SyncRecord dispatched, {required bool transient}) async {
    final current = await IsarService.instance.getSyncRecord(dispatched.id);
    if (current == null) {
      _dispatchAttempts.remove(dispatched.id);
      return;
    }
    final attempts = (_dispatchAttempts[current.id] ?? 0) + 1;
    _dispatchAttempts[current.id] = attempts;
    unawaited(_persistDispatchAttempts());
    current.retryCount = retryCountAfterFailure(current.retryCount, transient: transient);
    final nextState = stateAfterFailure(
      retryCount: current.retryCount,
      transient: transient,
      recordAgeSeconds: DateTime.now().millisecondsSinceEpoch ~/ 1000 - current.timestamp,
      attempts: attempts,
    );
    if (nextState == SyncRecordState.abandoned) {
      // An abandoned record is never dispatched again, so its attempt entry is
      // dead weight. Without this the map grows by one entry per poisoned
      // record for the life of the process.
      _dispatchAttempts.remove(current.id);
      unawaited(_persistDispatchAttempts());
      if (attempts > 0 && transient) {
        await LoggerService.instance.logWarning(
          'Abandoning sync record ${current.id} after $attempts attempts '
          '(all classified transient); it will not be retried again',
          'SyncEngine',
        );
      }
    }
    current.state = nextState;
    await IsarService.instance.saveSyncRecord(current);
  }

  Future<void> _pullServerState() async {
    // Order matters for onboarding (ISS-050): categories are cheap, then the
    // library membership / updates / chapter snapshot must land in Isar BEFORE
    // source replication. `downloadAndInstallMatchingSources` can burn the
    // entire onboarding hydration timeout downloading JS scrapers, and the old
    // order meant `fetchLibrary` never ran before the timeout — so the app
    // opened with an empty library even though the server had titles.
    // Source replication still benefits: it now sees the freshly-pulled
    // library when remapping.
    await _syncCategories();
    if (_serverSwitchedMidCycle) return;
    await _performFullSync();
    if (_serverSwitchedMidCycle) return;
    await _syncSourcesAndReplicate();
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
            serverSourceLangs: ServerSourceItem.langsByName(serverSources),
          );

          final installedLocalJs = QuickJsService.instance.getInstalledExtensionNames();
          final libraryManga = await IsarService.instance.getLibraryManga();

          final report = await SourceMigrationService.instance.syncAndReplicateServerSources(
            currentServerInstalledSources: serverSources,
            currentlyInstalledLocalJs: installedLocalJs,
            currentLibraryManga: libraryManga,
          );

          // NOTE: deliberately NOT re-saving `libraryManga` here.
          // syncAndReplicateServerSources already persists exactly the rows it
          // mutates (it calls saveMangas(modifiedManga) itself). The blanket
          // re-save that used to sit here was therefore pure redundancy — and
          // actively harmful, because `libraryManga` is a snapshot read before
          // the replication ran. Any change
          // made to a library manga in that window (marking a chapter read
          // rewrites unreadCount, LibraryUpdateService saves updated rows)
          // was silently reverted by this write, and on a large library it
          // dirtied every row to persist nothing. `report` is read for its
          // log-only fields inside the service.
          if (kDebugMode) {
            debugPrint('[sync_engine] source replication remapped ${report.totalReplicatedManga} manga');
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
        final categories = parseCategoryNodes(nodes);

        // Wipe guard, which this path did not have at all.
        //
        // `saveCategories` defaults to `replaceAll: true`, which deletes every
        // local category whose serverId is absent from this list. The manga
        // path has a 30% ratio check and the chapter path has one too; here
        // there was nothing beyond `categories.isNotEmpty`, so a truncated or
        // malformed response erased the user's category shelf — and
        // `Manga.categoryIds` on the affected series then pointed at deleted
        // rows, so the assignments were silently lost on every device.
        //
        // Two independent checks: the response must be structurally complete,
        // and it must not have shrunk catastrophically relative to what we hold.
        final snapshotComplete = isCompleteSnapshot(data);
        // `>= 0`, not `> 0`: Suwayomi's built-in "Default" category is id 0,
        // and excluding it under-counted the shelf the ratio guard protects.
        final existingServerLinked = (await IsarService.instance.getCategories())
            .where((c) => c.serverId >= 0)
            .length;
        if (!isCategoryPullAcceptable(
          snapshotComplete: snapshotComplete,
          incoming: categories.length,
          existingServerLinked: existingServerLinked,
        )) {
          await LoggerService.instance.logWarning(
            'Category pull looks incomplete '
            '(complete=$snapshotComplete, ${categories.length} returned vs $existingServerLinked held); '
            'keeping local categories rather than replacing them',
            'SyncEngine',
          );
          return;
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
      // No wall-clock cap here: fetchLibrary() paginates `first: 200` pages
      // internally, and every page request is individually bounded by query()'s
      // send/receive timeouts. An outer .timeout() previously aborted the whole
      // pull after 8s, permanently disabling sync for any library needing more
      // than one page (~200+ manga) or a slower server.
      final libData = await GraphQLClientService.instance.fetchLibrary();
      if (libData != null && libData.containsKey('mangas')) {
        serverReachable = true;
        final rawNodes = libData['mangas']['nodes'];
        final nodes = rawNodes is List ? rawNodes : const <dynamic>[];
        _currentLibraryFingerprints = {
          for (final n in nodes)
            if (n is Map) parseIntSafe(n['id']): chapterRefreshFingerprint(Map<String, dynamic>.from(n)),
        };
        final serverMangas = <Manga>[];
        final needsExtCover = <int>{};
        // Manga with a queued library or category change keep the local value
        // until it replays, same as chapters with queued read state. Otherwise
        // a removal that failed to replay this cycle is undone by the pull.
        final pendingLibraryIds = <int>{};
        final pendingCategoryIds = <int>{};
        for (final r in await IsarService.instance.getPendingSyncRecords()) {
          if (r.entityType == SyncEntityType.manga) {
            pendingLibraryIds.add(int.tryParse(r.entityId) ?? 0);
          } else if (r.entityType == SyncEntityType.category && r.entityId.startsWith('manga_')) {
            pendingCategoryIds.add(int.tryParse(r.entityId.substring(6)) ?? 0);
          }
        }

        for (final n in nodes) {
          // One malformed node (a non-map, or fields typed differently than
          // expected) must never abort the entire library pull — skip it and
          // keep the rest of the sync going.
          if (n is! Map) continue;
          final nodeMap = Map<String, dynamic>.from(n);
          final serverId = parseIntSafe(nodeMap['id']);
          if (serverId <= 0) continue;
          final stored = await IsarService.instance.getMangaByServerId(serverId);
          final manga = stored ?? (Manga()..serverId = serverId);

          manga.title = nodeMap['title']?.toString() ?? 'Untitled';
          // Only overwrite author/description from server if user has NOT locked
          // metadata via Metron enrichment. Never assign null/blank from a
          // partial library node — that wiped author on every sync when
          // fetchLibrary omitted the fields (ISS-053).
          if (!manga.isMetadataLocked) {
            final serverAuthor = nodeMap['author']?.toString();
            if (serverAuthor != null && serverAuthor.trim().isNotEmpty) {
              manga.author = serverAuthor.trim();
            }
            final serverDesc = nodeMap['description']?.toString();
            if (serverDesc != null && serverDesc.trim().isNotEmpty) {
              manga.description = serverDesc.trim();
            }
          }
          if (stored == null || !pendingLibraryIds.contains(serverId)) manga.inLibrary = true;
          // Normalised to seconds like every other local timestamp. This took
          // the server value verbatim, so a millis-reporting server produced a
          // date ~1000 years in the future and the Library's "Recent" sort
          // pinned those entries to one end forever.
          // Only overwrite with a USABLE value. `normalizeEpochToSeconds`
          // returns null for 0, null, "null" or anything unparseable, and
          // Suwayomi legitimately reports 0 for a manga added outside the
          // normal path. Assigning unconditionally therefore wiped a good
          // timestamp on every sync where the field was absent, dropping the
          // series to the very end of the Library "Recent" sort permanently.
          // `mergeLastReadAt` no-ops on an unusable value for the same reason.
          final inLibraryAt = normalizeEpochToSeconds(nodeMap['inLibraryAt']);
          if (inLibraryAt != null) {
            manga.inLibraryAt = inLibraryAt;
          } else {
            manga.inLibraryAt ??= nowUnix;
          }
          manga.unreadCount = parseIntSafe(nodeMap['unreadCount']);
          manga.lastFetchedAt = nowUnix;

          if (nodeMap['categories'] is Map && !pendingCategoryIds.contains(serverId)) {
            final catContainer = nodeMap['categories'] as Map;
            // Missing/null nodes == uncategorised == Default (id 0).
            manga.categoryIds = parseMangaCategoryIds(catContainer['nodes'] ?? const <dynamic>[]);
          }

          final sourceMapNode = nodeMap['source'];
          final sourceMap = sourceMapNode is Map ? Map<String, dynamic>.from(sourceMapNode) : null;
          // `?.toString()` on an EMPTY string yields '' (not null), so a plain
          // ?? chain short-circuits and stored '' as the source name. The
          // local-extension cover/URL fallbacks below all guard on
          // sourceName.isNotEmpty, so they were silently skipped for such a
          // series. Take the first candidate that is actually non-empty.
          manga.sourceName = _firstNonEmpty([
            sourceMap?['name']?.toString(),
            sourceMap?['displayName']?.toString(),
            nodeMap['sourceId']?.toString(),
          ]) ?? 'Unknown Source';
          final sourceLang = sourceMap?['lang']?.toString();
          if (sourceLang != null && sourceLang.trim().isNotEmpty) {
            manga.lang = sourceLang.trim();
          } else if (manga.lang.isEmpty) {
            manga.lang = 'en';
          }

          // Save the manga's URL on the source website — used by local QuickJS extensions
          // to scrape chapters directly when the server is offline.
          final rawUrl = nodeMap['url'];
          if (rawUrl != null && rawUrl.toString().isNotEmpty) {
            manga.url = rawUrl.toString();
          }

          final rawThumbNode = nodeMap['thumbnailUrl'];
          final rawThumb = rawThumbNode?.toString();
          final isServerProxy = rawThumb == null || rawThumb.isEmpty || rawThumb.contains('/api/v1/manga/');
          final currentThumb = manga.thumbnailUrl;
          final hasDirectThumb = currentThumb != null &&
              currentThumb.isNotEmpty &&
              !currentThumb.contains('/api/v1/manga/') &&
              currentThumb.startsWith('http');

          if (!hasDirectThumb) {
            if (!isServerProxy) {
              manga.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
            } else if (serverUrl.isNotEmpty && serverId > 0 && (manga.thumbnailUrl == null || manga.thumbnailUrl!.isEmpty)) {
              manga.thumbnailUrl = '$serverUrl/api/v1/manga/$serverId/thumbnail';
            }
            if (manga.sourceName.isNotEmpty && manga.url.isNotEmpty) needsExtCover.add(serverId);
          }

          serverMangas.add(manga);
        }
        await IsarService.instance.saveMangas(serverMangas);

        // A local extension's direct CDN cover beats the server's. Resolving it
        // runs QuickJS, so it happens after the save and patches only the
        // thumbnail onto the current row; resolving it mid-loop held every
        // read row across those awaits and saved them stale.
        for (final m in serverMangas.where((m) => needsExtCover.contains(m.serverId))) {
          final extCover = await QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
          if (extCover == null || extCover.isEmpty) continue;
          final current = await IsarService.instance.getMangaByServerId(m.serverId);
          if (current == null) continue;
          current.thumbnailUrl = extCover;
          m.thumbnailUrl = extCover;
          await IsarService.instance.saveManga(current);
        }

        // Pre-cache cover images to local disk for offline resilience
        for (final m in serverMangas) {
          if (m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty) {
            unawaited(ImageCacheHelper.cacheThumbnail(m.serverId, m.thumbnailUrl!, sourceName: m.sourceName));
          }
        }

        // ── WIPE GUARD: Never cascade a server wipe to local Isar ─────────
        // If server returned far fewer manga than Isar has, something is wrong
        // (server was wiped/reset). Skip marking local entries as removed.
        //
        // The 30% ratio is a heuristic for "the server was reset", and it is not
        // sufficient on its own: a page timing out mid-pagination returns
        // however many pages did succeed, and for any library above ~3x the
        // page size that still clears the floor. 500 manga, page 3 times out ->
        // 400 returned -> 400 >= 150 -> the missing 100 are removed from the
        // user's library, with no error surfaced. So a truncated response is
        // refused outright, independent of the ratio.
        final snapshotComplete = isCompleteSnapshot(libData);
        if (!snapshotComplete) {
          await LoggerService.instance.logWarning(
            'Library pull returned an incomplete snapshot '
            '(${serverMangas.length} of $localCountBefore local entries); '
            'skipping the removal cascade so a failed page cannot empty the library',
            'SyncEngine',
          );
        }
        final serverCount = serverMangas.length;
        final removalSafe = isLibraryRemovalSafe(
          snapshotComplete: snapshotComplete,
          force: forceLibraryRemovals,
          localCountBefore: localCountBefore,
          serverCount: serverCount,
        );

        if (removalSafe && serverCount > 0) {
          // Only soft-delete local entries that the server genuinely removed
          final serverIds = serverMangas.map((m) => m.serverId).toSet();
          final localLib = await IsarService.instance.getLibraryManga();
          final toRemove = <Manga>[];
          for (final local in localLib) {
            // Only soft-delete server-linked manga that the server genuinely removed.
            // Local standalone/extension manga (serverId <= 0) must never be removed by server sync.
            if (local.serverId > 0 && !serverIds.contains(local.serverId) && !pendingLibraryIds.contains(local.serverId)) {
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
    } catch (e, stack) {
      // logError, not logInfo. "Server is offline" was assumed for ANY
      // exception here, including a `TypeError` from a single malformed node —
      // and it was logged at info level, so it vanished from a filtered log and
      // the rest of the cycle (chapter snapshot, history pull, updates pull)
      // was skipped with no visible cause. Local data is still left untouched,
      // which is the important part.
      await LoggerService.instance.logError(
        'Library pull failed, skipping the rest of the server sync: $e',
        exception: e,
        stackTrace: stack,
        category: 'SyncEngine',
      );
      return; // Keep local data untouched.
    }

    if (!serverReachable || _serverSwitchedMidCycle) return;

    // ── STEP 3: Recent updates + history BEFORE the full chapter snapshot ─
    // ISS-051: `_syncAllChaptersForLibrary` is O(library) and can run for
    // minutes. It also stamps first-seen chapters with `fetchedAt = 0` so they
    // stay out of Updates (UIX-05). Genuine feed entries must therefore arrive
    // via `_syncRecentUpdateChapters` *before* that long snapshot — otherwise
    // onboarding's timeout / the user opening Updates mid-snapshot sees an
    // empty feed even though the server has recent chapters. Running updates
    // first also means the snapshot finds those rows already persisted
    // (id != Isar.autoIncrement) and keeps their server `fetchedAt`.
    await _syncRecentUpdateChapters(serverUrl: serverUrl);
    if (_serverSwitchedMidCycle) return;
    await _syncHistoryChapters(serverUrl: serverUrl);
    if (_serverSwitchedMidCycle) return;

    // ── STEP 4: Pull ALL chapters for the full library (full snapshot) ────
    // Core of local-first: every chapter, page count, URL, and fetch
    // timestamp is stored in Isar so the app never needs the server to know
    // what chapters exist or to navigate reading history.
    await _syncAllChaptersForLibrary(serverUrl: serverUrl);

    // There is deliberately NO local `last_sync_unix` meta write here. One
    // existed, was written at the end of every full sync, and was never read by
    // anything -- which advertised an incremental-sync capability the app does
    // not have. It could not simply be wired up: skipping the per-manga
    // `fetchMangaDetails` snapshot when the library looks unchanged would also
    // skip cross-device read state, which changes independently of library
    // membership, and `fetchLibrary` does not select a `dateModified` to compare
    // against. Implementing this soundly needs a server-side change first.
    //
    // The server-side per-device marker is kept: the web UI and other tooling
    // read it, and unlike the local one it is not misleading.
    // ISS-077: never write `lastSync_null` (sync before initialize()), and
    // once per process remove the legacy junk keys earlier builds left behind
    // (`lastSync_null`, shared `lastSync_default_device` — ISS-062).
    final markerKey = lastSyncMetaKey(_deviceId);
    if (markerKey != null) {
      try {
        await GraphQLClientService.instance.setGlobalMeta(markerKey, nowUnix.toString());
      } catch (e) {
        await LoggerService.instance.logWarning('Failed to set global meta lastSync: $e', 'SyncEngine');
      }
    }
    if (!_legacyLastSyncMetaCleaned) {
      _legacyLastSyncMetaCleaned = true;
      for (final junk in kLegacyLastSyncMetaKeys) {
        try {
          await GraphQLClientService.instance.deleteGlobalMeta(junk);
        } catch (e) { debugPrint('[sync_engine] ignored: $e'); }
      }
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

      var skipped = 0;
      final now = DateTime.now();

      // Chunk fetch for concurrency
      for (var i = 0; i < library.length; i += 5) {
        if (_serverSwitchedMidCycle) return;
        final chunk = library.skip(i).take(5).toList();
        await Future.wait(chunk.map((manga) async {
          try {
            final fp = _currentLibraryFingerprints[manga.serverId];
            if (shouldSkipChapterSnapshot(
              currentFingerprint: fp,
              previousFingerprint: _chapterFingerprints[manga.serverId],
              lastFullSnapshotAt: _lastFullChapterSnapshotAt[manga.serverId],
              localChapterCount: manga.chapterCount,
              now: now,
            )) {
              skipped++;
              return;
            }
            final data = await GraphQLClientService.instance.fetchMangaDetails(manga.serverId);
            if (data == null || !data.containsKey('manga') || _serverSwitchedMidCycle) return;

          final mangaData = data['manga'] as Map<String, dynamic>;

          // Update manga fields from detail response (respect metadata lock from Metron)
          if (!manga.isMetadataLocked) {
            final detailAuthor = mangaData['author'] as String?;
            if (detailAuthor != null && detailAuthor.trim().isNotEmpty) {
              manga.author = detailAuthor.trim();
            }
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

            // Prefetch this manga's local chapters ONCE and index by server id.
            // The loop below used to call getChapterByServerId per chapter
            // node, which is one sequential Isar round-trip each — a 1000-
            // chapter series cost 1000 queries per manga per sync, and
            // triggerSync runs from pull-to-refresh, the reader, the library
            // updater and the WorkManager task. This is the same rows
            // IsarService.getChaptersForManga already batches.
            final localByServerId = <int, Chapter>{};
            for (final existing in await IsarService.instance.getChaptersForManga(manga.serverId)) {
              if (existing.serverId != 0) {
                localByServerId[existing.serverId] = existing;
              }
            }

            // Server ids present in this response. Used to prune chapters the
            // server no longer knows about, guarded by a wipe check below.
            final seenServerIds = <int>{};

            // A truncated chapter page means "we could not read the rest", not
            // "the server deleted these". Without this, a 600-chapter series
            // whose second page times out yields 500 ids, and the prune deletes
            // the other 100 rows outright — taking their read state,
            // lastReadAt and bookmarks with them. The ratio guard inside
            // selectPrunableChapters does not catch it: 500 clears the floor
            // against 600.
            final chapterSnapshotComplete = isCompleteSnapshot(data);
            if (!chapterSnapshotComplete) {
              await LoggerService.instance.logWarning(
                'Chapter snapshot for manga ${manga.serverId} is incomplete; '
                'skipping the prune so a failed page cannot destroy local chapters',
                'SyncEngine',
              );
            }

            for (final c in chapterNodes) {
              final chMap = c as Map<String, dynamic>;
              final chServerId = parseIntSafe(chMap['id']);
              if (chServerId != 0) seenServerIds.add(chServerId);

              var chapter = localByServerId[chServerId];
              // The batched prefetch is keyed on mangaId == manga.serverId.
              // If a row carries a stale/zero mangaId (older schema, a
              // migrated series, a manual edit) it is missed here, and
              // building a fresh Chapter would silently discard its
              // read state, bookmark and local download. Fall back to the
              // direct serverId lookup for that rare case.
              chapter ??=
                  await IsarService.instance.getChapterByServerId(chServerId);
              chapter ??= Chapter()..serverId = chServerId;

              mergeSnapshotChapterNode(
                chapter,
                chMap,
                manga: manga,
                hasPendingMutation: pendingChapterIds.contains(chapter.serverId.toString()),
              );

              chaptersToSave.add(chapter);
            }

            await IsarService.instance.saveChapters(chaptersToSave);

            // ── Prune chapters the server no longer has ──────────────────
            // Nothing in the codebase ever deleted a chapter, so a chapter
            // removed on the server lingered locally forever: `chapterCount`
            // is overwritten from the server so the count and the row set
            // silently diverged, the chapter reappeared in the offline
            // chapter list and stayed in History (getReadingHistory filters
            // only on library membership), and Isar grew without bound.
            // See selectPrunableChapters for the wipe guard.
            if (seenServerIds.isNotEmpty && chapterSnapshotComplete) {
              final stale = selectPrunableChapters(
                localChapters: localByServerId.values,
                seenServerIds: seenServerIds,
              );
              if (stale.isNotEmpty) {
                await IsarService.instance.deleteChapters(stale);
                await LoggerService.instance.logInfo(
                  'Pruned ${stale.length} chapter(s) no longer on the server '
                  '(manga ${manga.serverId}: server ${seenServerIds.length} / '
                  'local ${localByServerId.length})',
                  'SyncEngine',
                );
              }
            }
          }

          // `manga` was read when the cycle started, possibly minutes ago on a
          // large library. Saving it whole would revert library removals,
          // category edits and lastReadAt made since; write only this pass's
          // fields onto the current row.
          final current = await IsarService.instance.getMangaByServerId(manga.serverId);
          if (current != null) {
            current
              ..author = manga.author
              ..description = manga.description
              ..status = manga.status
              ..genres = manga.genres
              ..url = manga.url
              ..lastFetchedAt = manga.lastFetchedAt
              ..chapterCount = manga.chapterCount;
            await IsarService.instance.saveManga(current);
          }
          // Only a COMPLETE snapshot may seed the skip fingerprint, or a
          // truncated pull would be frozen in place for up to 6h.
          if (chapterNodes != null && isCompleteSnapshot(data) && fp != null) {
            _chapterFingerprints[manga.serverId] = fp;
            _lastFullChapterSnapshotAt[manga.serverId] = DateTime.now();
          } else {
            _chapterFingerprints.remove(manga.serverId);
          }
        } catch (e) {
          // Individual manga chapter sync failure is non-fatal — continue with others
          await LoggerService.instance.logWarning('Chapter snapshot failed for manga ${manga.serverId}: $e', 'SyncEngine');
        }
        }));
      }

      _lastSnapshotSkipped = skipped;
      await LoggerService.instance.logInfo(
        'Full chapter snapshot complete (${library.length - skipped} fetched, $skipped unchanged/skipped)',
        'SyncEngine',
      );
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

        // Extension cover lookups run QuickJS and can take seconds each, so they
        // happen before any chapter or manga row is read for merging. Doing them
        // mid-loop saved rows read long before, reverting the reader's progress.
        final extCovers = <int, String>{};
        for (final c in chNodes) {
          final mangaMap = c is Map ? c['manga'] : null;
          if (mangaMap is! Map) continue;
          final mServerId = parseIntSafe(mangaMap['id']);
          if (extCovers.containsKey(mServerId)) continue;
          final m = await IsarService.instance.getMangaByServerId(mServerId);
          final thumb = m?.thumbnailUrl;
          final hasDirect = thumb != null && thumb.isNotEmpty && !thumb.contains('/api/v1/manga/') && thumb.startsWith('http');
          if (m == null || hasDirect || m.sourceName.isEmpty || m.url.isEmpty) continue;
          extCovers[mServerId] = await QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url) ?? '';
        }

        for (final c in chNodes) {
          final chMap = c as Map<String, dynamic>;
          final chServerId = parseIntSafe(chMap['id']);
          final mangaServerId = parseIntSafe(chMap['mangaId']);
          final serverIsRead = parseBoolSafe(chMap['isRead']);
          final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);

          var chapter = await IsarService.instance.getChapterByServerId(chServerId);
          chapter ??= Chapter()..serverId = chServerId;

          chapter.mangaId = mangaServerId;
          chapter.name = chMap['name'] as String? ?? 'Chapter ${chMap['chapterNumber'] ?? ""}';
          chapter.chapterNumber = parseDoubleSafe(chMap['chapterNumber']);
          chapter.pageCount = parseIntSafe(chMap['pageCount']);

          // Read-state: take the server's value unless this chapter still has
          // an unsynced outbound mutation queued (see _syncAllChaptersForLibrary).
          final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
          applyServerReadState(
            chapter,
            serverIsRead: serverIsRead,
            serverPage: serverLastPageRead,
            serverMetaActionAt: readActionAtFromNode(chMap),
            hasPendingMutation: hasPendingMutation,
          );
          mergeLastReadAt(chapter, chMap);
          mergeIsBookmarked(chapter, chMap, hasPendingMutation: hasPendingMutation);

          // Populate denormalized manga info for offline History display
          if (chMap.containsKey('manga') && chMap['manga'] != null) {
            final mangaMap = chMap['manga'] as Map<String, dynamic>;
            chapter.mangaTitle = mangaMap['title'] as String? ?? chapter.mangaTitle;
            final mThumb = mangaMap['thumbnailUrl'] as String?;
            if (mThumb != null && mThumb.isNotEmpty) {
              chapter.mangaThumbnailUrl = mThumb.startsWith('http') ? mThumb : '$serverUrl$mThumb';
            }

            // Also upsert parent manga into Isar if not already there
            final mServerId = parseIntSafe(mangaMap['id']);
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
              final extCover = extCovers[mServerId];
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
      final now = DateTime.now();
      final since = updatesWindowSince(
        highWaterFetchedAt: _updatesHighWaterFetchedAt,
        lastFullUpdatesPullAt: _lastFullUpdatesPullAt,
        now: now,
      );
      final data = await GraphQLClientService.instance.fetchUpdatesChapters(first: 150, sinceFetchedAt: since);
      if (data == null || !data.containsKey('chapters')) return;
      if (since == null) _lastFullUpdatesPullAt = now;

      final nodes = data['chapters']['nodes'] as List<dynamic>?;
      if (nodes == null) return;

      final chaptersToSave = <Chapter>[];

      for (final n in nodes) {
        final map = n as Map<String, dynamic>;
        final chServerId = parseIntSafe(map['id']);

        var chapter = await IsarService.instance.getChapterByServerId(chServerId);
        chapter ??= Chapter()..serverId = chServerId;

        chapter.mangaId = parseIntSafe(map['mangaId']);
        chapter.name = map['name'] as String? ?? chapter.name;
        chapter.chapterNumber = parseDoubleSafe(map['chapterNumber']);
        // pageCount was missing here, and Chapter.applyReadState does
        // `if (read) lastPageRead = pageCount` — so marking a chapter that
        // first arrived through the updates feed read wrote lastPageRead = 0
        // and threw away the resume position.
        chapter.pageCount = parseIntSafe(map['pageCount']);
        final serverIsRead = parseBoolSafe(map['isRead']);
        final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
        // Same merge as the snapshot/history pulls (ISS-141).
        applyServerReadState(
          chapter,
          serverIsRead: serverIsRead,
          serverPage: parseIntSafe(map['lastPageRead']),
          serverMetaActionAt: readActionAtFromNode(map),
          hasPendingMutation: hasPendingMutation,
        );
        // Also missing here: without lastReadAt a chapter that arrives already
        // read is absent from History (lastReadAt > 0) and does not float its
        // series in Library's "Last Read" sort.
        mergeLastReadAt(chapter, map);
        mergeIsBookmarked(chapter, map, hasPendingMutation: hasPendingMutation);
        // Assigned, not OR-ed. As a monotonic OR the flag could never be
        // cleared, so a chapter deleted from the server's download folder stayed
        // "Downloaded" forever — while the comment two lines below claimed this
        // pass reconciles it. `rebuildServerDownloadCache` rebuilds its in-memory
        // sets from the same flag, so it could not correct the OR either.
        // Absent from the response means "not reported", so keep the local value.
        if (map.containsKey('isDownloaded')) {
          chapter.isDownloadedOnServer = parseBoolSafe(map['isDownloaded']);
        }

        final rawUpload = map['uploadDate'] ?? map['dateUpload'];
        if (rawUpload != null) {
          final rawStr = rawUpload.toString().trim();
          if (rawStr.isNotEmpty && rawStr != '0' && rawStr != 'null') {
            chapter.dateUpload = rawStr;
          }
          final upVal = int.tryParse(rawStr);
          if (upVal != null && upVal > 0) {
            chapter.uploadDate = normalizeEpochToSeconds(upVal) ?? 0;
          }
        }

        // Preserve user-cleared Updates rows (local fetchedAt == 0) across sync
        // (ISS-055). Brand-new chapters still receive the server stamp.
        applyServerFetchedAt(chapter, map['fetchedAt'], preserveCleared: true);

        // Bulk-import chapters share fetchedAt ≈ manga.inLibraryAt; keep them
        // out of the Updates feed so they cannot flood the top-N (ISS-054).
        final mangaMapForImport = map['manga'] as Map<String, dynamic>?;
        final importInLibraryAt = normalizeEpochToSeconds(
          mangaMapForImport?['inLibraryAt'] ?? map['inLibraryAt'],
        );
        if (isLikelyBulkImportChapter(
          fetchedAt: chapter.fetchedAt,
          inLibraryAt: importInLibraryAt,
        )) {
          chapter.fetchedAt = 0;
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
        final rawFetched = normalizeEpochToSeconds(map['fetchedAt']);
        if (rawFetched != null && rawFetched > (_updatesHighWaterFetchedAt ?? 0)) {
          _updatesHighWaterFetchedAt = rawFetched;
        }
      }

      await IsarService.instance.saveChapters(chaptersToSave);
      // Reconcile the server-download cache so the "Downloaded" filter
      // reflects the server's actual state from this sync.
      await DownloadManagerService.instance.rebuildServerDownloadCache();
      await LoggerService.instance.logInfo('Cached ${chaptersToSave.length} recent update chapters to Isar', 'SyncEngine');
    } catch (e) {
      await LoggerService.instance.logError('Recent updates sync error: $e', category: 'SyncEngine');
    }
  }

  // ─── Delta Sync Support ──────────────────────────────────────────

  /// Fetch delta changes since a specific timestamp (real Suwayomi filters).
  Future<SyncResult> fetchDelta({
    required DateTime since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) async {
    if (!GraphQLClientService.instance.isConfigured) {
      return SyncResult(
        success: false,
        errors: ['GraphQL client not configured'],
      );
    }

    try {
      final data = await GraphQLClientService.instance.fetchDelta(
        since: since,
        mangaIds: mangaIds,
        categoryIds: categoryIds,
      );

      if (data == null) {
        return SyncResult(
          success: false,
          errors: ['No delta data returned from server'],
        );
      }

      return SyncResult(
        success: true,
        mangaUpdated: (data['manga'] as List?)?.length ?? 0,
        chaptersUpdated: (data['chapters'] as List?)?.length ?? 0,
        categoriesUpdated: (data['categories'] as List?)?.length ?? 0,
        // Pass payload through so [applyDeltaChanges] can write rows.
        data: data,
      );
    } catch (e, stack) {
      await LoggerService.instance.logError('Delta fetch failed: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      return SyncResult(
        success: false,
        errors: ['Delta fetch failed: $e'],
      );
    }
  }

  /// Apply delta changes from server to local database
  Future<SyncResult> applyDeltaChanges(SyncResult deltaResult) async {
    if (!deltaResult.success) return deltaResult;

    try {
      int mangaCount = 0;
      int chapterCount = 0;
      int categoryCount = 0;

      // Apply manga changes
      final mangaData = deltaResult.data?['manga'] as List?;
      if (mangaData != null && mangaData.isNotEmpty) {
        final mangaList = await _mergeServerMangaNodes(mangaData.whereType<Map<String, dynamic>>());
        await IsarService.instance.saveMangas(mangaList);
        mangaCount = mangaList.length;
      }

      // Apply chapter changes
      final chapterData = deltaResult.data?['chapters'] as List?;
      if (chapterData != null && chapterData.isNotEmpty) {
        final chapters = await _mergeServerChapterNodes(chapterData.whereType<Map<String, dynamic>>());
        await IsarService.instance.saveChapters(chapters);
        chapterCount = chapters.length;
      }

      // Apply category changes
      final categoryData = deltaResult.data?['categories'] as List?;
      if (categoryData != null && categoryData.isNotEmpty) {
        final categories = parseCategoryNodes(categoryData);
        await IsarService.instance.saveCategories(categories);
        categoryCount = categories.length;
      }

      return SyncResult(
        success: true,
        mangaUpdated: mangaCount,
        chaptersUpdated: chapterCount,
        categoriesUpdated: categoryCount,
        lastSyncTimestamp: DateTime.now(),
      );
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to apply delta changes: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      return SyncResult(
        success: false,
        errors: ['Failed to apply delta changes: $e'],
      );
    }
  }

  /// Sync specific manga by IDs (for selective sync)
  Future<SyncResult> syncMangaByIds(Set<int> mangaIds) async {
    if (!GraphQLClientService.instance.isConfigured) {
      return SyncResult(success: false, errors: ['GraphQL client not configured']);
    }

    try {
      final data = await GraphQLClientService.instance.fetchMangaByIds(mangaIds.toList());
      if (data == null || data.isEmpty) {
        return SyncResult(success: true, mangaUpdated: 0);
      }

      final mangaList = await _mergeServerMangaNodes(data);
      await IsarService.instance.saveMangas(mangaList);

      // Also fetch chapters for these manga
      int chapterCount = 0;
      for (final manga in mangaList) {
        if (manga.serverId > 0) {
          final count = await _syncAllChaptersForManga(manga.serverId);
          chapterCount += count;
        }
      }

      return SyncResult(
        success: true,
        mangaUpdated: mangaList.length,
        chaptersUpdated: chapterCount,
      );
    } catch (e, stack) {
      await LoggerService.instance.logError('Selective manga sync failed: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      return SyncResult(success: false, errors: ['Selective manga sync failed: $e']);
    }
  }

  /// Sync specific categories by IDs
  Future<SyncResult> syncCategoriesByIds(Set<int> categoryIds) async {
    if (!GraphQLClientService.instance.isConfigured) {
      return SyncResult(success: false, errors: ['GraphQL client not configured']);
    }

    try {
      final data = await GraphQLClientService.instance.fetchCategoriesByIds(categoryIds.toList());
      if (data == null || data.isEmpty) {
        return SyncResult(success: true, categoriesUpdated: 0);
      }

      final categories = parseCategoryNodes(data);
      await IsarService.instance.saveCategories(categories);

      return SyncResult(
        success: true,
        categoriesUpdated: categories.length,
      );
    } catch (e, stack) {
      await LoggerService.instance.logError('Selective category sync failed: $e', exception: e, stackTrace: stack, category: 'SyncEngine');
      return SyncResult(success: false, errors: ['Selective category sync failed: $e']);
    }
  }

  /// Resolve conflicts using the conflict resolver.
  ///
  /// Pass [resolver] from SyncManager / conflict UI to override the default LWW.
  Future<SyncResult> resolveConflicts(
    List<SyncConflict> conflicts, {
    ConflictResolver? resolver,
  }) async {
    final active = resolver ?? ConflictResolver();
    var resolved = 0;
    var skipped = 0;

    for (final conflict in conflicts) {
      try {
        final resolvedValue = active.resolve(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          field: conflict.field,
          localValue: conflict.localData,
          remoteValue: conflict.remoteData,
          localTimestamp: conflict.localTimestamp ?? DateTime.fromMillisecondsSinceEpoch(0),
          remoteTimestamp: conflict.remoteTimestamp ?? DateTime.now(),
        );

        if (resolvedValue is UserChoiceMarker) {
          // Requires user intervention - keep as conflict
          skipped++;
          continue;
        }

        await _applyConflictResolution(conflict, resolvedValue);
        resolved++;
      } catch (e) {
        skipped++;
        await LoggerService.instance.logError('Failed to resolve conflict: $e', category: 'SyncEngine');
      }
    }

    return SyncResult(
      success: skipped == 0,
      errors: skipped == 0
          ? const []
          : ['Resolved $resolved conflict(s); $skipped still need attention'],
    );
  }

  /// Apply a single conflict with an already-chosen value (conflict UI path).
  Future<void> applyResolvedConflict(
    SyncConflict conflict,
    dynamic resolvedValue,
  ) async {
    await _applyConflictResolution(conflict, resolvedValue);
  }

  Future<void> _applyConflictResolution(SyncConflict conflict, dynamic resolvedValue) async {
    switch (conflict.entityType) {
      case 'manga':
        final manga =
            await IsarService.instance.getMangaByServerId(conflict.entityId);
        if (manga == null) return;
        if (!_applyMangaField(manga, conflict.field, resolvedValue)) return;
        await IsarService.instance.saveManga(manga);
        break;
      case 'chapter':
        final chapter =
            await IsarService.instance.getChapterByServerId(conflict.entityId);
        if (chapter == null) return;
        if (!_applyChapterField(chapter, conflict.field, resolvedValue)) return;
        await IsarService.instance.saveChapter(chapter);
        break;
      case 'category':
        final category =
            await IsarService.instance.getCategoryByServerId(conflict.entityId);
        if (category == null) return;
        if (!_applyCategoryField(category, conflict.field, resolvedValue)) {
          return;
        }
        await IsarService.instance.saveCategory(category);
        break;
    }
  }

  bool _applyMangaField(Manga manga, String field, dynamic value) {
    switch (field) {
      case 'title':
        manga.title = value?.toString() ?? manga.title;
        return true;
      case 'author':
        manga.author = value?.toString();
        return true;
      case 'artist':
        manga.artist = value?.toString();
        return true;
      case 'description':
        manga.description = value?.toString();
        return true;
      case 'status':
        manga.status = value?.toString();
        return true;
      case 'inLibrary':
        manga.inLibrary = value == true;
        return true;
      case 'readingModeOverride':
        manga.readingModeOverride = value?.toString();
        return true;
      case 'unreadCount':
        manga.unreadCount = value is num ? value.toInt() : manga.unreadCount;
        return true;
      case 'lastReadAt':
        manga.lastReadAt = value is num ? value.toInt() : manga.lastReadAt;
        return true;
      case 'categoryIds':
        if (value is List) {
          manga.categoryIds = value
              .map((e) => parseIntSafe(e))
              .where((id) => id != 0)
              .toList();
          return true;
        }
        return false;
      case 'tagIds':
        if (value is List) {
          manga.tagIds = value.map((e) => parseIntSafe(e)).where((id) => id != 0).toList();
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  bool _applyChapterField(Chapter chapter, String field, dynamic value) {
    switch (field) {
      case 'name':
        chapter.name = value?.toString() ?? chapter.name;
        return true;
      case 'isRead':
        chapter.isRead = value == true;
        return true;
      case 'isBookmarked':
        chapter.isBookmarked = value == true;
        return true;
      case 'lastPageRead':
        chapter.lastPageRead = value is num ? value.toInt() : chapter.lastPageRead;
        return true;
      case 'lastReadAt':
        chapter.lastReadAt = value is num ? value.toInt() : chapter.lastReadAt;
        return true;
      case 'pageCount':
        chapter.pageCount = value is num ? value.toInt() : chapter.pageCount;
        return true;
      default:
        return false;
    }
  }

  bool _applyCategoryField(Category category, String field, dynamic value) {
    switch (field) {
      case 'name':
        category.name = (value?.toString() ?? category.name).trim();
        return true;
      case 'order':
        category.order = value is num ? value.toInt() : category.order;
        return true;
      case 'includeInUpdate':
        category.includeInUpdate = parseIncludeOrExclude(value);
        return true;
      case 'includeInDownload':
        category.includeInDownload = parseIncludeOrExclude(value);
        return true;
      case 'default':
      case 'isDefault':
        category.isDefault = value == true;
        return true;
      case 'isDefaultCategory':
        category.isDefaultCategory = value == true;
        category.isDefault = category.isDefault || category.isDefaultCategory;
        return true;
      default:
        return false;
    }
  }

  // ─── Delta Sync Helper Methods ──────────────────────────────────

  /// Parse a manga node from GraphQL response (Suwayomi MangaType shape).
  Manga parseMangaNode(Map<String, dynamic> node) {
    final source = node['source'];
    String sourceName = node['sourceName']?.toString() ?? '';
    if (sourceName.isEmpty && source is Map) {
      sourceName = (source['displayName'] ?? source['name'] ?? '').toString();
    }

    final categoryIds = <int>[];
    final rawCategoryIds = node['categoryIds'];
    if (rawCategoryIds is List) {
      for (final id in rawCategoryIds) {
        final parsed = parseIntSafe(id);
        if (parsed != 0) categoryIds.add(parsed);
      }
    } else {
      final catContainer = node['categories'];
      final catNodes = catContainer is Map ? catContainer['nodes'] : null;
      if (catNodes is List) {
        categoryIds.addAll(parseMangaCategoryIds(catNodes));
      }
    }

    final manga = Manga()
      ..serverId = parseIntSafe(node['id'])
      ..title = (node['title'] ?? node['name'])?.toString() ?? 'Untitled'
      ..author = node['author']?.toString() ?? ''
      ..artist = node['artist']?.toString() ?? ''
      ..description = node['description']?.toString() ?? ''
      ..status = node['status']?.toString() ?? ''
      ..sourceName = sourceName
      ..url = (node['url'] ?? node['sourceUrl'])?.toString() ?? ''
      ..thumbnailUrl =
          (node['thumbnailUrl'] ?? node['coverUrl'])?.toString()
      ..readingModeOverride = node['readingModeOverride']?.toString()
      ..inLibrary = node['inLibrary'] == true
      ..inLibraryAt = parseIntSafe(node['inLibraryAt'])
      ..unreadCount = node['unreadCount'] == null
          ? null
          : parseIntSafe(node['unreadCount'])
      ..categoryIds = categoryIds;

    return manga;
  }

  /// Parse a chapter node from GraphQL response (Suwayomi ChapterType shape).
  Chapter parseChapterNode(Map<String, dynamic> node) {
    return Chapter()
      ..serverId = parseIntSafe(node['id'])
      ..mangaId = parseIntSafe(node['mangaId'])
      ..name = node['name']?.toString() ?? 'Untitled'
      ..chapterNumber = parseDoubleSafe(node['chapterNumber'])
      ..url = node['url']?.toString() ?? ''
      ..realUrl = node['realUrl']?.toString() ?? ''
      ..pageCount = parseIntSafe(node['pageCount'])
      ..isRead = node['isRead'] == true
      ..isBookmarked = node['isBookmarked'] == true
      ..lastPageRead = parseIntSafe(node['lastPageRead'])
      ..lastReadAt = parseIntSafe(node['lastReadAt'])
      ..isDownloadedLocally = node['isDownloadedLocally'] == true
      ..isDownloadedOnServer =
          node['isDownloadedOnServer'] == true || node['isDownloaded'] == true
      ..uploadDate = parseIntSafe(node['uploadDate'])
      ..fetchedAt = parseIntSafe(node['fetchedAt']);
  }

  /// Sync all chapters for a specific manga
  Future<int> _syncAllChaptersForManga(int mangaServerId) async {
    final data = await GraphQLClientService.instance.fetchMangaAndChapters(mangaServerId);
    if (data == null || data['mangaAndChapters'] == null) return 0;

    final chapterNodes = data['mangaAndChapters']['chapters']['nodes'] as List?;
    if (chapterNodes == null || chapterNodes.isEmpty) return 0;

    final chapters = await _mergeServerChapterNodes(
      chapterNodes.whereType<Map<dynamic, dynamic>>().map((n) => Map<String, dynamic>.from(n)..putIfAbsent('mangaId', () => mangaServerId)),
    );

    await IsarService.instance.saveChapters(chapters);
    return chapters.length;
  }

  /// Server manga nodes merged onto their stored rows ([applyServerMangaNode]);
  /// unknown series are parsed fresh.
  Future<List<Manga>> _mergeServerMangaNodes(Iterable<Map<String, dynamic>> nodes) async {
    final out = <Manga>[];
    for (final node in nodes) {
      final serverId = parseIntSafe(node['id']);
      final existing = serverId == 0 ? null : await IsarService.instance.getMangaByServerId(serverId);
      if (existing == null) {
        out.add(parseMangaNode(node));
      } else {
        applyServerMangaNode(existing, node);
        out.add(existing);
      }
    }
    return out;
  }

  /// Server chapter nodes merged onto their stored rows with the same rules as
  /// the chapter snapshot ([mergeSnapshotChapterNode]), so queued local
  /// read-state changes, downloads, `lastReadAt` and stamps survive.
  Future<List<Chapter>> _mergeServerChapterNodes(Iterable<Map<String, dynamic>> nodes) async {
    final list = nodes.where((n) => parseIntSafe(n['id']) != 0).toList();
    if (list.isEmpty) return const [];
    final existingById = await IsarService.instance.getChaptersByServerIds(list.map((n) => parseIntSafe(n['id'])).toList());
    final pending = await IsarService.instance.getPendingChapterEntityIds();
    final mangaCache = <int, Manga?>{};
    final out = <Chapter>[];
    for (final node in list) {
      final serverId = parseIntSafe(node['id']);
      final existing = existingById[serverId];
      if (existing == null) {
        out.add(parseChapterNode(node)..fetchedAt = normalizeEpochToSeconds(node['fetchedAt']) ?? 0);
        continue;
      }
      final mangaId = parseIntSafe(node['mangaId']) != 0 ? parseIntSafe(node['mangaId']) : existing.mangaId;
      if (!mangaCache.containsKey(mangaId)) {
        mangaCache[mangaId] = await IsarService.instance.getMangaByServerId(mangaId);
      }
      final manga = mangaCache[mangaId] ??
          (Manga()
            ..serverId = mangaId
            ..title = existing.mangaTitle
            ..thumbnailUrl = existing.mangaThumbnailUrl);
      mergeSnapshotChapterNode(
        existing,
        node,
        manga: manga,
        hasPendingMutation: pending.contains(serverId.toString()),
      );
      if (node.containsKey('isDownloadedOnServer') || node.containsKey('isDownloaded')) {
        existing.isDownloadedOnServer = node['isDownloadedOnServer'] == true || node['isDownloaded'] == true;
      }
      out.add(existing);
    }
    return out;
  }

  /// Parse int safely from dynamic
  int parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Parse double safely from dynamic
  double parseDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
