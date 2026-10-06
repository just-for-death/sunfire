import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting, debugPrint, kDebugMode;
import 'package:isar_community/isar.dart';
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
import 'graphql_client_service.dart';
import 'suwayomi_parse_helpers.dart';
import 'websocket_service.dart';

// Re-exported so the many existing `sync_engine.dart` importers of this helper
// keep working, and so the DB layer can reach it without a circular import.
export '../db/epoch_seconds.dart';

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
      // `isDefault` carried across; a missing value used to reset it to false
      // on every row during `putAll`.
      ..isDefault = parseBoolSafe(map['default'])
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
@visibleForTesting
class SyncCycleGate {
  bool isSyncing = false;
  bool queued = false;

  /// Returns `true` when the caller should run a sync cycle. If a cycle is
  /// already running, marks [queued] and returns `false`.
  bool tryBegin() {
    if (isSyncing) {
      queued = true;
      return false;
    }
    isSyncing = true;
    queued = false;
    return true;
  }

  /// Clears the queue flag at the start of a cycle body.
  void beginPass() => queued = false;

  /// After a cycle body finishes: `true` when another pass should run.
  bool needsAnotherPass() => queued;

  /// Releases the single-flight lock. Call only when no further pass is needed.
  void end() {
    isSyncing = false;
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
  chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

  // Read-state merge: take the server's value outright unless this
  // chapter has an unsynced outbound mutation queued, in which
  // case keep the local value until that mutation replays — the
  // old "OR true, never false" rule meant an unread-on-another-
  // -device never made it back here.
  final serverIsRead = parseBoolSafe(chMap['isRead']);
  if (!hasPendingMutation) {
    chapter.isRead = serverIsRead;
  }

  // lastPageRead merge — the server's page only wins when it
  // represents strictly more progress (see mergeLastPageRead).
  final serverLastPageRead = parseIntSafe(chMap['lastPageRead']);
  chapter.lastPageRead = mergeLastPageRead(
    local: chapter.lastPageRead,
    server: serverLastPageRead,
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
  bool get _isSyncing => _cycleGate.isSyncing;
  /// Whether a sync cycle (including a queued follow-up pass) is in flight.
  bool get isSyncing => _cycleGate.isSyncing;
  set _isSyncing(bool v) {
    // forceReconcile and a few early-return paths still flip the flag directly.
    if (v) {
      _cycleGate.isSyncing = true;
    } else {
      _cycleGate.end();
    }
  }
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
      await _performFullSync(forceLibraryRemovals: true);
      await _syncSourcesAndReplicate();
    } finally {
      _isSyncing = false;
    }
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
      // Intentionally not awaited: the offline path queues a SyncRecord and
      // the online path does a network round-trip, neither of which the UI
      // should block on. Matches every previous call site.
      unawaited(
        syncChapterProgress(
          chapter.serverId,
          isRead: isRead,
          lastPageRead: chapter.lastPageRead,
        ),
      );
    }
    return true;
  }

  Future<void> syncChapterProgress(
    int chapterServerId, {
    required bool isRead,
    required int lastPageRead,
  }) async {
    if (chapterServerId <= 0) return;
    // Defence in depth for [commitChapterReadState]. Anything that reaches the
    // network or the replay queue leaks reading history, and the replay queue in
    // particular would replay long after the user turned Incognito back off.
    if (SettingsService.instance.incognitoMode) return;

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
      // Never let a coalesce move progress backwards. Two overlapping
      // debounced page turns (page 20 then page 21) can both read the same
      // queued record before either writes; without this max() the slower
      // writer persisted page 20 over page 21 and the replay uploaded stale
      // progress. Same reason for isRead: a queued "read" must not be undone
      // by a late "unread" from the same burst.
      final queued = _readQueuedProgress(record.payloadJson);
      final incoming = lastPageRead;
      final bestPage = queued == null ? incoming : (incoming > queued ? incoming : queued);
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

  Future<void> syncMangaCategories(int mangaServerId, List<int> categoryIds, {List<int>? existingCategoryIds}) async {
    if (mangaServerId <= 0) return;

    if (GraphQLClientService.instance.isConfigured) {
      final isOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isOnline) {
        try {
          final res = await GraphQLClientService.instance
              .setMangaCategories(mangaServerId, categoryIds, existingCategoryIds: existingCategoryIds);
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
                // `parseIntSafe` returns 0 for a missing or non-numeric id, so
                // a corrupt payload landed here and was reported as SUCCESS.
                // The record was then deleted by _completeDispatchedRecord —
                // the mutation was destroyed without ever being sent, and
                // nothing was logged. The user believes it synced.
                //
                // A payload that cannot be interpreted must never be reported
                // as delivered.
                success = false;
                await LoggerService.instance.logWarning(
                  'Discarding chapter mutation ${record.id}: payload has no usable chapterId '
                  '(${record.payloadJson})',
                  'SyncEngine',
                );
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
              if (existing != null && existing['categories'] is Map) {
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
              created ??= (await GraphQLClientService.instance.createCategory(name))?['createCategory']?['category'] as Map<String, dynamic>?;
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
          // `isKnownUnreachable` is the right discriminator and needs no auth
          // guard: it tracks the transport only. A 401/403 is answered by the
          // server, so it leaves that status reachable and falls through to
          // transient: false, which is what we want — counting an auth failure
          // against the retry budget abandons the record in a bounded number of
          // cycles instead of re-attempting it for 14 days with a bad
          // credential.
          //
          // Do NOT re-add `&& !hasAuthError` here. It used to paper over
          // checkServerReachable marking a 401'd server unreachable, and now
          // that distinction is correct it actively backfires: a real network
          // drop arriving while a *stale* auth error is still latched would be
          // read as permanent and burn the record's retry budget on something
          // that would have succeeded on the next attempt.
          final client = GraphQLClientService.instance;
          await _recordDispatchFailure(
            record,
            transient: client.isKnownUnreachable,
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
    // The record is done, so its attempt budget is spent.
    _dispatchAttempts.remove(dispatched.id);
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
    await _performFullSync();
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

          // NOTE: deliberately NOT re-saving `libraryManga` here.
          // syncAndReplicateServerSources already persists exactly the rows it
          // mutates (it calls saveMangas(modifiedManga) itself). The blanket
          // re-save that used to sit here was therefore pure redundancy — and
          // actively harmful, because `libraryManga` is a snapshot read BEFORE
          // downloadAndInstallMatchingSources, fetchCombinedRepoSources and the
          // whole replication ran, each of which can take seconds. Any change
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

        for (final n in nodes) {
          // One malformed node (a non-map, or fields typed differently than
          // expected) must never abort the entire library pull — skip it and
          // keep the rest of the sync going.
          if (n is! Map) continue;
          final nodeMap = Map<String, dynamic>.from(n);
          final serverId = parseIntSafe(nodeMap['id']);
          if (serverId <= 0) continue;
          var manga = await IsarService.instance.getMangaByServerId(serverId);
          manga ??= Manga()..serverId = serverId;

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
          manga.inLibrary = true;
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

          if (nodeMap.containsKey('categories') && nodeMap['categories'] != null && nodeMap['categories'] is Map) {
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
            // Check if local extension can resolve direct CDN cover URL (zero network, instantaneous)
            String? extCover;
            if (manga.sourceName.isNotEmpty && manga.url.isNotEmpty) {
              extCover = await QuickJsService.instance.getExtensionCoverUrl(manga.sourceName, manga.url);
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

    if (!serverReachable) return;

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
    await _syncHistoryChapters(serverUrl: serverUrl);

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
        } catch (_) {}
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
            if (data == null || !data.containsKey('manga')) return;

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

          await IsarService.instance.saveManga(manga);
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
          chapter.pageCount = parseIntSafe(chMap['pageCount'], chapter.pageCount);

          // Read-state: take the server's value unless this chapter still has
          // an unsynced outbound mutation queued (see _syncAllChaptersForLibrary).
          final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
          if (!hasPendingMutation) {
            chapter.isRead = serverIsRead;
          }
          chapter.lastPageRead = mergeLastPageRead(
            local: chapter.lastPageRead,
            server: serverLastPageRead,
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
                extCover = await QuickJsService.instance.getExtensionCoverUrl(parentManga.sourceName, parentManga.url);
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

        chapter.mangaId = parseIntSafe(map['mangaId'], chapter.mangaId);
        chapter.name = map['name'] as String? ?? chapter.name;
        chapter.chapterNumber = parseDoubleSafe(map['chapterNumber'], chapter.chapterNumber);
        // pageCount was missing here, and Chapter.applyReadState does
        // `if (read) lastPageRead = pageCount` — so marking a chapter that
        // first arrived through the updates feed read wrote lastPageRead = 0
        // and threw away the resume position.
        chapter.pageCount = parseIntSafe(map['pageCount'], chapter.pageCount);
        final serverIsRead = parseBoolSafe(map['isRead']);
        final hasPendingMutation = pendingChapterIds.contains(chServerId.toString());
        if (!hasPendingMutation) {
          chapter.isRead = serverIsRead;
        }
        // Same merge as the snapshot/history pulls: this used to take the
        // server's page outright, which discarded offline reading progress
        // that was still queued for upload.
        chapter.lastPageRead = mergeLastPageRead(
          local: chapter.lastPageRead,
          server: parseIntSafe(map['lastPageRead'], chapter.lastPageRead),
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
}
