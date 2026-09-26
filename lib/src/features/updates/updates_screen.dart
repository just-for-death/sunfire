import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/db/models/sync_record.dart';
import '../../core/logging/logger_service.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/library_update_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/sync/websocket_service.dart';
import '../../main_shell.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

/// Snapshots the accumulated unread delta for [mangaId] and resets it to 0.
///
/// The read-then-clear ORDER is the whole point, which is why it is a named
/// function with a test rather than two inline statements. Written inline once,
/// the two got swapped — clear, then read — and because there is no `await`
/// between them the read was structurally guaranteed to return 0. Every
/// unread-badge update from the Updates screen was then discarded, and
/// `saveManga` below was unreachable: a worse outcome than the plain
/// read-modify-write it replaced, and invisible to a 700-test suite.
///
/// Returns 0 when there is nothing pending.
@visibleForTesting
int takePendingUnreadDelta(Map<int, int> pending, int mangaId) {
  final value = pending[mangaId] ?? 0;
  pending[mangaId] = 0;
  return value;
}

class _UpdatesScreenState extends State<UpdatesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _updatesList = [];
  final Map<int, String> _langByMangaId = {};
  bool _isLoading = true;
  bool _isCheckingServer = false;
  bool _isOffline = false;
  String? _lastUpdateText;
  bool _unreadOnly = false;
  String _searchQuery = '';
  bool _isSearching = false;
  String? _liveUpdateStatus;
  StreamSubscription? _wsUpdateSub;
  StreamSubscription? _wsDownloadSub;
  Timer? _reloadTimer;
  bool _isReloadingFromCache = false;
  bool _reloadQueued = false;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
    // showLanguageBadges and selectedLanguages are both read during build (via
    // _languageBadgeLabel and _filteredUpdates) and both are written from the
    // Browse settings page, which sits under the "More" tab. Without this the
    // feed kept rendering the old filtering until something unrelated forced a
    // rebuild.
    SettingsService.instance.addListener(_onSettingsChanged);
    _wsUpdateSub = WebSocketService.instance.onUpdateStatus.listen((event) {
      if (!mounted) return;
      final status = event['status']?.toString() ?? event.toString();
      setState(() => _liveUpdateStatus = status);
      // Debounced: a single library-update run emits one
      // libraryUpdateStatusChanged per source plus an updateStatusChanged per
      // affected chapter, so this fired dozens of times in a row, each one
      // re-running a 100-row Isar query plus a per-row cover back-fill. See
      // _scheduleCacheReload.
      _scheduleCacheReload();
    });
    _wsDownloadSub = WebSocketService.instance.onDownloadStatus.listen((event) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /// Coalesces cache reloads triggered by tab switches and by bursts of
  /// WebSocket update events into a single read, and never runs two
  /// concurrently.
  ///
  /// The in-flight guard matters because the async read can resolve after a
  /// newer request has already started; without it, whichever read finished
  /// last won and the feed could show a stale snapshot.
  void _scheduleCacheReload({Duration delay = const Duration(milliseconds: 400)}) {
    _reloadTimer?.cancel();
    _reloadTimer = Timer(delay, () {
      _reloadTimer = null;
      if (_isReloadingFromCache) {
        // A read is already in flight; make sure one more runs once it ends so
        // the newest state is not lost.
        _reloadQueued = true;
        return;
      }
      _loadUpdatesFromIsarCache();
    });
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value == 1 && mounted) {
      _scheduleCacheReload(delay: Duration.zero);
    }
  }

  List<Map<String, dynamic>> get _filteredUpdates {
    var list = List<Map<String, dynamic>>.from(_updatesList);
    if (_unreadOnly) {
      list = list.where((it) => !(it['chapter'] as Chapter).isRead).toList();
    }
    // Honor the reader's selected languages (Mihon parity): 'all' shows everything.
    final selectedLangs = SettingsService.instance.selectedLanguages;
    if (selectedLangs.isNotEmpty && !selectedLangs.contains('all')) {
      list = list.where((it) {
        final lang = (it['lang'] as String? ?? '').trim().toLowerCase();
        return SettingsService.languageMatchesFilter(lang, selectedLangs);
      }).toList();
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((it) {
        final ch = it['chapter'] as Chapter;
        final title = (it['mangaTitle'] ?? ch.mangaTitle).toString().toLowerCase();
        return title.contains(q) || ch.name.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    SettingsService.instance.removeListener(_onSettingsChanged);
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    _wsUpdateSub?.cancel();
    _wsDownloadSub?.cancel();
    super.dispose();
  }

  String _formatDateHeader(int? fetchedAt) {
    if (fetchedAt == null || fetchedAt <= 0) return 'Recent';
    final int millis = (normalizeEpochToSeconds(fetchedAt) ?? 0) * 1000;
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(itemDate).inDays;
    if (diffDays <= 0) {
      return 'Today';
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays < 7) {
      return DateFormat('EEEE').format(date); // e.g. "Wednesday"
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  Future<void> _loadUpdates() async {
    // 1. Show local cache immediately (0ms instant render)
    await _loadUpdatesFromIsarCache();

    // 2. Background server fetch (only if configured, never blocks initial render)
    if (GraphQLClientService.instance.isConfigured) {
      _fetchServerUpdatesInBackground();
    }
  }

  /// Builds mangaId → language cache from the local library so update feed items
  /// can be language-badged and filtered (`showLanguageBadges` / `selectedLanguages`).
  ///
  /// Rebuilt on every call rather than short-circuited on "already non-empty".
  /// The map was populated once and never invalidated, so any manga added to the
  /// library after the first load had no entry and its feed items were badged
  /// `''` — silently mis-labelled as unknown — and, once the language filter is
  /// actually enabled, filtered as if their language were unknown. The read is a
  /// single indexed Isar query over the library and this only runs from the
  /// (already debounced) cache reload, so it is not worth memoising.
  Future<void> _loadLangMap() async {
    try {
      final mangas = await IsarService.instance.getLibraryManga();
      final next = <int, String>{};
      for (final m in mangas) {
        // canonicalKey only. Keying on the local Isar id as well let a chapter
        // pick up ANOTHER series' language badge whenever the two ids collided.
        if (m.canonicalKey != 0) next[m.canonicalKey] = m.lang;
      }
      _langByMangaId
        ..clear()
        ..addAll(next);
    } catch (ignoredError) { if (kDebugMode) debugPrint('[updates_screen] ignored error: $ignoredError'); }
  }

  /// Short uppercase language code for badges, or null when the entry is
  /// default English / universal and doesn't warrant a badge.
  String? _languageBadgeLabel(String lang) {
    if (!SettingsService.instance.showLanguageBadges) return null;
    return SettingsService.languageBadgeLabel(lang);
  }

  /// The in-flight server fetch, so concurrent callers share one.
  ///
  /// There are two entry points — the initial load and every pull-to-refresh —
  /// with no re-entrancy guard, so two fast pulls ran two concurrent full
  /// fetches. Both then persisted their chapters and both merged into
  /// `_updatesList`, so the last writer won and the merge was applied to a list
  /// the other pass had already replaced. Sharing the future also means the
  /// refresh indicator waits for the pass that will actually populate the list,
  /// rather than completing instantly.
  Future<void>? _serverFetchInFlight;

  Future<void> _fetchServerUpdatesInBackground() {
    final existing = _serverFetchInFlight;
    if (existing != null) return existing;
    final started = _runServerUpdatesFetch();
    _serverFetchInFlight = started;
    return started;
  }

  Future<void> _runServerUpdatesFetch() async {
    try {
      final serverUrl = GraphQLClientService.instance.baseUrl ?? '';
      final items = <Map<String, dynamic>>[];
      final chaptersToSave = <Chapter>[];

      // Fetch last update timestamp
      final tsStr = await GraphQLClientService.instance
          .fetchLastUpdateTimestamp()
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (!mounted) return;
      if (tsStr != null) {
        final ts = int.tryParse(tsStr);
        if (ts != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch((normalizeEpochToSeconds(ts) ?? 0) * 1000);
          setState(() {
            _lastUpdateText = 'Last update: ${DateFormat('MM/dd/yyyy, hh:mm a').format(dt)}';
          });
        }
      }

      if (!mounted) return;
      final data = await GraphQLClientService.instance
          .fetchUpdatesChapters(first: 100)
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (!mounted) return;
      if (data != null && data.containsKey('chapters')) {
        final nodes = data['chapters']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          // Count chapters per manga in this incoming batch to detect bulk imports/refreshes
          final mangaCounts = <int, int>{};
          for (final n in nodes) {
            final map = n as Map<String, dynamic>;
            final mId = parseIntSafe(map['mangaId']);
            mangaCounts[mId] = (mangaCounts[mId] ?? 0) + 1;
          }

          final mangaAddedCount = <int, int>{};
          for (final n in nodes) {
            final map = n as Map<String, dynamic>;
            final mangaMap = map['manga'] as Map<String, dynamic>?;
            final chServerId = parseIntSafe(map['id']);
            final mId = parseIntSafe(map['mangaId']);

            // If a manga was bulk imported or bulk refreshed on server, show at
            // most the newest few chapters in the updates feed to prevent
            // flooding. Thresholds are the shared constants so this display cap
            // cannot drift from the ingestion-time gate in
            // applyFloodCapToNewChapters / cleanupBulkScrapedUpdates.
            final totalForManga = mangaCounts[mId] ?? 0;
            final isFlooded = totalForManga > kFloodThresholdChapters;
            final added = mangaAddedCount[mId] ?? 0;
            final shouldAddToFeed = !isFlooded || (added < kFloodCapChapters);
            if (shouldAddToFeed) {
              mangaAddedCount[mId] = added + 1;
            }

            final isDownloaded = parseBoolSafe(map['isDownloaded']);
            final rawFetchedAt = map['fetchedAt'] != null ? int.tryParse(map['fetchedAt'].toString()) : null;
            final fetchedAt = rawFetchedAt == null ? null : normalizeEpochToSeconds(rawFetchedAt);

            String title = 'Manga';
            String thumb = '';
            int resolvedMId = mId;
            String sourceName = '';

            if (mangaMap != null) {
              title = mangaMap['title'] as String? ?? 'Manga';
              resolvedMId = parseIntSafe(mangaMap['id'], resolvedMId);
              final rawThumb = mangaMap['thumbnailUrl'] as String?;
              if (rawThumb != null && rawThumb.isNotEmpty) {
                thumb = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
              }
              final srcMap = mangaMap['source'] as Map<String, dynamic>?;
              sourceName = srcMap?['displayName'] as String? ?? '';
            }

            final ch = Chapter()
              ..serverId = chServerId
              ..mangaId = resolvedMId
              ..name = map['name'] as String? ?? 'Chapter'
              ..chapterNumber = parseDoubleSafe(map['chapterNumber'])
              ..isRead = parseBoolSafe(map['isRead'])
              ..lastPageRead = parseIntSafe(map['lastPageRead'])
              ..mangaTitle = title
              ..mangaThumbnailUrl = thumb
              ..fetchedAt = fetchedAt
              ..isDownloadedOnServer = isDownloaded;

            chaptersToSave.add(ch);

            if (shouldAddToFeed) {
              items.add({
                'chapter': ch,
                'mangaId': resolvedMId,
                'title': title,
                'thumbnailUrl': thumb,
                'sourceName': sourceName,
                'lang': _langByMangaId[resolvedMId] ?? '',
                'isDownloaded': isDownloaded,
                'fetchedAt': fetchedAt,
                'dateHeader': _formatDateHeader(fetchedAt),
              });
            }
          }
        }
      }

      // Persist fetched chapters into Isar so cache stays synchronized with server
      if (chaptersToSave.isNotEmpty) {
        // One batched query, not one per chapter. This loop ran up to 100
        // SEQUENTIAL Isar queries on every pull-to-refresh and every background
        // sync — the N+1 was on the hot path of the screen the app opens to find
        // out whether anything updated.
        final existingByServerId = await IsarService.instance
            .getChaptersByServerIds(chaptersToSave.map((c) => c.serverId).toList());
        for (final ch in chaptersToSave) {
          final existing = existingByServerId[ch.serverId];
          if (existing != null) {
            ch.id = existing.id;
            ch.isRead = ch.isRead || existing.isRead;
            ch.lastPageRead = ch.lastPageRead > existing.lastPageRead ? ch.lastPageRead : existing.lastPageRead;
            if (existing.url.isNotEmpty && ch.url.isEmpty) ch.url = existing.url;
            if (existing.isBookmarked) ch.isBookmarked = true;
            // Merge download state per-flag so a server-only existing download
            // isn't miscopied onto the local flag (and vice-versa).
            if (existing.isDownloadedLocally) ch.isDownloadedLocally = true;
            if (existing.isDownloadedOnServer) ch.isDownloadedOnServer = true;
          }
        }
        await IsarService.instance.saveChapters(chaptersToSave);
      }

      // Reached the server. Clear the offline banner on ANY successful round
      // trip, including one that returned no chapters — "you are up to date" is
      // a normal response, and the flag was only cleared inside the
      // `items.isNotEmpty` branch, so it stuck at true forever afterwards.
      if (mounted) setState(() => _isOffline = false);
      if (items.isNotEmpty && mounted) {
        items.sort((a, b) {
          final fa = a['fetchedAt'] as int? ?? 0;
          final fb = b['fetchedAt'] as int? ?? 0;
          return fb.compareTo(fa);
        });

        // Merge server items INTO local list, preserving local-only chapters
        // and chapters with pending mutations.
        final mergedList = await _mergeServerItemsIntoLocal(_updatesList, items);
        if (mounted) {
          setState(() {
            _updatesList = mergedList;
            _isLoading = false;
            _isOffline = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    } finally {
      // Cleared before the future completes, so the next caller gets a fresh
      // pass rather than joining this one.
      _serverFetchInFlight = null;
    }
  }

  /// Merges server-fetched update items into the local updates list.
  ///
  /// Preserves:
  /// - Local-only chapters (serverId == 0 or negative synthetic IDs)
  /// - Chapters with pending read-state mutations (tracked via SyncRecord)
  /// - Local read-state for chapters with pending mutations
  ///
  /// Updates:
  /// - Existing chapters by serverId with server data (isRead, lastPageRead, etc.)
  /// - Adds new server chapters not present locally
  Future<List<Map<String, dynamic>>> _mergeServerItemsIntoLocal(
    List<Map<String, dynamic>> localItems,
    List<Map<String, dynamic>> serverItems,
  ) async {
    // Compute pending read mutations once
    final pendingReadChapterIds = await _computePendingReadChapterIds();

    // Build a map of local items by serverId for quick lookup
    final localByServerId = <int, Map<String, dynamic>>{};
    final localOnlyItems = <Map<String, dynamic>>[];

    for (final item in localItems) {
      final ch = item['chapter'] as Chapter;
      if (ch.serverId > 0) {
        localByServerId[ch.serverId] = item;
      } else {
        // Local-only chapter (serverId <= 0) - always preserve
        localOnlyItems.add(item);
      }
    }

    final mergedItems = <Map<String, dynamic>>[];

    // First, add/update items from server
    for (final serverItem in serverItems) {
      final serverCh = serverItem['chapter'] as Chapter;
      final serverId = serverCh.serverId;

      if (serverId > 0 && localByServerId.containsKey(serverId)) {
        // Existing chapter - merge server data into local
        final localItem = localByServerId[serverId]!;
        final localCh = localItem['chapter'] as Chapter;

        // Preserve local read state if there's a pending mutation
        final hasPendingReadMutation = pendingReadChapterIds.contains(serverId);

        final mergedItem = Map<String, dynamic>.from(serverItem);
        mergedItem['chapter'] = Chapter()
          ..id = localCh.id
          ..serverId = serverCh.serverId
          ..mangaId = serverCh.mangaId
          ..name = serverCh.name
          ..chapterNumber = serverCh.chapterNumber
          ..isRead = hasPendingReadMutation ? localCh.isRead : serverCh.isRead
          ..lastPageRead = serverCh.lastPageRead > localCh.lastPageRead
              ? serverCh.lastPageRead
              : localCh.lastPageRead
          ..mangaTitle = serverCh.mangaTitle
          ..mangaThumbnailUrl = serverCh.mangaThumbnailUrl
          ..fetchedAt = serverCh.fetchedAt
          ..isDownloadedLocally = localCh.isDownloadedLocally
          ..isDownloadedOnServer = serverCh.isDownloadedOnServer
          ..url = serverCh.url.isNotEmpty ? serverCh.url : localCh.url
          ..isBookmarked = localCh.isBookmarked || serverCh.isBookmarked
          ..scanlator = serverCh.scanlator
          ..uploadDate = serverCh.uploadDate
          ..pageCount = serverCh.pageCount;

        mergedItems.add(mergedItem);
      } else {
        // New chapter from server - add as-is
        mergedItems.add(serverItem);
      }
    }

    // Add local-only items (serverId <= 0) that weren't in server response
    mergedItems.addAll(localOnlyItems);

    // Also add any local items with serverId > 0 that weren't in server response
    // (e.g., chapters that exist locally but server didn't return in this batch)
    for (final entry in localByServerId.entries) {
      if (!mergedItems.any((item) => (item['chapter'] as Chapter).serverId == entry.key)) {
        mergedItems.add(entry.value);
      }
    }

    // Sort by fetchedAt descending (newest first)
    mergedItems.sort((a, b) {
      final fa = a['fetchedAt'] as int? ?? 0;
      final fb = b['fetchedAt'] as int? ?? 0;
      return fb.compareTo(fa);
    });

    return mergedItems;
  }

  /// Computes the set of chapterServerIds that have pending read-state mutations.
  Future<Set<int>> _computePendingReadChapterIds() async {
    try {
      final pendingRecords = await IsarService.instance.getPendingSyncRecords();
      final ids = <int>{};
      for (final record in pendingRecords) {
        if (record.entityType == SyncEntityType.chapter &&
            record.action == SyncAction.update &&
            record.retryCount == 0) {
          final payload = jsonDecode(record.payloadJson) as Map<String, dynamic>;
          if (payload.containsKey('isRead') || payload.containsKey('lastPageRead')) {
            final chapterId = int.tryParse(record.entityId);
            if (chapterId != null && chapterId > 0) {
              ids.add(chapterId);
            }
          }
        }
      }
      return ids;
    } catch (_) {
      return <int>{};
    }
  }

  Future<void> _loadUpdatesFromIsarCache() async {
    if (_isReloadingFromCache) {
      _reloadQueued = true;
      return;
    }
    _isReloadingFromCache = true;
    try {
      await _loadUpdatesFromIsarCacheInner();
    } finally {
      _isReloadingFromCache = false;
      if (_reloadQueued) {
        _reloadQueued = false;
        // Something changed while we were reading. Re-read so the feed does
        // not settle on the older snapshot.
        _scheduleCacheReload(delay: Duration.zero);
      }
    }
  }

  Future<void> _loadUpdatesFromIsarCacheInner() async {
    try {
      await _loadLangMap();
      final chapters = await IsarService.instance.getRecentChapters(limit: 100);
      if (chapters.isEmpty && _updatesList.isNotEmpty) {
        // Retain current in-memory feed if cache temporarily returns empty
        return;
      }

      // Count chapters per manga to detect bulk imports/refreshes (same logic as server feed)
      final mangaCounts = <int, int>{};
      for (final ch in chapters) {
        mangaCounts[ch.mangaId] = (mangaCounts[ch.mangaId] ?? 0) + 1;
      }

      final items = <Map<String, dynamic>>[];

      // ── Batch the cover/title back-fill ──────────────────────────────
      // This used to issue one getMangaByServerId per feed item that needed
      // one — up to 100 sequential Isar queries, on every tab visit and on
      // every single WebSocket updateStatus event. `title` starts out as
      // 'Manga #<id>' exactly when the chapter stored no title, and `thumb` is
      // empty exactly when the chapter stored no cover, so the set of manga to
      // resolve is knowable up front from the chapter rows alone.
      final needsBackfill = <int>{};
      for (final ch in chapters) {
        if (ch.mangaTitle.isEmpty || (ch.mangaThumbnailUrl ?? '').isEmpty) {
          needsBackfill.add(ch.mangaId);
        }
      }
      final mangaById = <int, Manga>{};
      if (needsBackfill.isNotEmpty) {
        final rows = await IsarService.instance.getMangaByServerIds(needsBackfill.toList());
        for (final m in rows) {
          if (m.serverId != 0) mangaById[m.serverId] = m;
        }
      }

      final mangaAddedCount = <int, int>{};

      for (final ch in chapters) {
        // Bulk imported/refreshed series are capped in the feed. Shared
        // thresholds — see applyFloodCapToNewChapters, which now also applies
        // the same cap at ingestion so this display layer rarely has to.
        final totalForManga = mangaCounts[ch.mangaId] ?? 0;
        final isFlooded = totalForManga > kFloodThresholdChapters;
        final added = mangaAddedCount[ch.mangaId] ?? 0;
        if (isFlooded && added >= kFloodCapChapters) continue;
        mangaAddedCount[ch.mangaId] = added + 1;

        String title = ch.mangaTitle.isNotEmpty ? ch.mangaTitle : 'Manga #${ch.mangaId}';
        String thumb = ch.mangaThumbnailUrl ?? '';

        if (title == 'Manga #${ch.mangaId}' || thumb.isEmpty) {
          final manga = mangaById[ch.mangaId];
          if (manga != null) {
            if (title == 'Manga #${ch.mangaId}') title = manga.title;
            if (thumb.isEmpty) thumb = manga.thumbnailUrl ?? '';
          }
        }

        items.add({
          'chapter': ch,
          'mangaId': ch.mangaId,
          'title': title,
          'thumbnailUrl': thumb,
          'sourceName': '',
          'lang': _langByMangaId[ch.mangaId] ?? '',
          'isDownloaded': ch.isDownloaded || ch.isDownloadedOnServer,
          'fetchedAt': ch.fetchedAt,
          'dateHeader': _formatDateHeader(ch.fetchedAt),
        });
      }

      items.sort((a, b) {
        final fa = a['fetchedAt'] as int? ?? 0;
        final fb = b['fetchedAt'] as int? ?? 0;
        return fb.compareTo(fa);
      });

      if (mounted) {
        setState(() {
          _updatesList = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Pull-to-refresh: re-read the local cache, then pull the latest update
  /// chapters from the server. Bounded, and never triggers a library-wide
  /// re-scrape — see the RefreshIndicator for why.
  Future<void> _refreshFeed() async {
    await _loadUpdatesFromIsarCache();
    if (!mounted) return;
    if (!GraphQLClientService.instance.isConfigured) return;
    await _fetchServerUpdatesInBackground();
  }

  Future<void> _checkServerForUpdates() async {
    setState(() => _isCheckingServer = true);
    final primaryColor = Theme.of(context).colorScheme.primary;

    try {
      final newFound = await LibraryUpdateService.instance.checkForNewChapters(isManual: true);
      // Reload directly from cache — the sync above already wrote to Isar.
      // Do NOT call _loadUpdates() here; that would re-trigger server fetch and old cleanup.
      await _loadUpdatesFromIsarCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFound > 0 ? 'Found $newFound new chapters!' : 'Library is up to date',
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingServer = false);
      }
    }
  }

  Future<void> _toggleChapterRead(Map<String, dynamic> item) async {
    final ch = item['chapter'] as Chapter;
    final newState = !ch.isRead;
    // Centralised so the Incognito guard is applied here exactly as it is in
    // the reader — previously this path wrote to Isar and pushed to the server
    // with Incognito on.
    final wrote = await SyncEngine.instance.commitChapterReadState(ch, isRead: newState);
    if (!wrote) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }
    if (mounted) setState(() {});

    // Keep the library unread badge in sync — the reader and manga-detail
    // paths both do this, and without it toggling read state here leaves the
    // badge stale until the next full library refresh.
    await _adjustMangaUnreadCount(ch.mangaId, delta: newState ? -1 : 1);

    // Match manga-detail parity: delete-if-marked-read and the Metron scrobble
    // fire only on the read transition there too (never on un-read).
    if (newState) {
      await _applyMarkedReadSideEffects(ch);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Marked "${ch.name}" as read' : 'Marked "${ch.name}" as unread'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Side effects shared with manga-detail when a chapter crosses to read:
  /// honor "delete chapter after marked read" and auto-scrobble to Metron.
  Future<void> _applyMarkedReadSideEffects(Chapter ch) async {
    try {
      final settings = SettingsService.instance;
      if (settings.deleteChapterAfterMarkedRead && ch.isDownloaded) {
        if (!ch.isBookmarked || settings.allowDeletingBookmarkedChapters) {
          DownloadManagerService.instance.deleteLocalDownload(ch.serverId != 0 ? ch.serverId : ch.id);
        }
      }
      if (settings.metronAutoScrobble && ch.mangaId > 0) {
        MetronService.instance
            .scrobbleChapterByMangaId(mangaId: ch.mangaId, chapter: ch)
            .catchError((e, st) {
          LoggerService.instance.logError('Metron scrobble failed', exception: e, stackTrace: st, category: 'Metron');
          return false;
        });
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Marked-read side effects failed for chapter ${ch.id}: $e', 'Updates');
    }
  }

  /// Adjusts the parent manga's unread counter without re-querying every
  /// chapter, mirroring the reader's incremental update.
  Future<void> _adjustMangaUnreadCount(int mangaId, {required int delta}) async {
    // `mangaId == 0`, not `<= 0`: a local/standalone manga's canonical id is a
    // negative synthetic value, so the old gate skipped every local series and
    // their unread badge drifted permanently. getMangaByServerId resolves
    // negative ids because it filters the serverId column, which is where the
    // synthetic value lives.
    if (mangaId == 0 || delta == 0) return;
    // Serialise per manga and coalesce deltas.
    //
    // This was a bare read-modify-write with no in-flight guard, and its
    // callers are fire-and-forget (a per-row IconButton) — so double-tapping two
    // chapters of the same series had both invocations read the same
    // `unreadCount`, both compute n-1, and the second write was lost. The badge
    // then drifted by one per race, permanently, with no correction pass
    // anywhere on this path.
    _pendingUnreadDeltas[mangaId] = (_pendingUnreadDeltas[mangaId] ?? 0) + delta;
    await _drainUnreadDeltas(mangaId);
  }

  /// Applies the accumulated unread deltas for [mangaId] to Isar.
  ///
  /// Serialised per manga: only the first caller for a given id runs, everyone
  /// else has already added their delta to the accumulator and returns. Each
  /// round snapshots the accumulator and clears it BEFORE awaiting, so a delta
  /// that arrives mid-write starts a fresh batch and is picked up by the next
  /// loop iteration — applied exactly once, never lost, never double-counted.
  Future<void> _drainUnreadDeltas(int mangaId) async {
    if (!_unreadDrainInFlight.add(mangaId)) return;
    try {
      var pending = takePendingUnreadDelta(_pendingUnreadDeltas, mangaId);
      while (pending != 0) {
        try {
          final manga = await IsarService.instance.getMangaByServerId(mangaId);
          if (manga != null) {
            manga.unreadCount = ((manga.unreadCount ?? 0) + pending).clamp(0, 1 << 30);
            await IsarService.instance.saveManga(manga);
          }
        } catch (e) {
          // Put the batch back so a transient Isar failure is not silently
          // discarded — this is the same class of loss the drain exists to
          // prevent, so it must not introduce its own.
          _pendingUnreadDeltas[mangaId] = (_pendingUnreadDeltas[mangaId] ?? 0) + pending;
          await LoggerService.instance.logWarning(
            'Failed to apply unread-count delta of $pending for manga $mangaId: $e',
            'Updates',
          );
          break;
        }
        pending = takePendingUnreadDelta(_pendingUnreadDeltas, mangaId);
      }
    } finally {
      _unreadDrainInFlight.remove(mangaId);
      // A delta that landed after the loop's last read but before the lock was
      // released would otherwise sit unapplied with nobody left to drain it.
      if (takePendingUnreadDelta(_pendingUnreadDeltas, mangaId) != 0) {
        unawaited(_drainUnreadDeltas(mangaId));
      }
    }
  }

  /// Unapplied unread deltas per manga, and which drains are currently running.
  final Map<int, int> _pendingUnreadDeltas = {};
  final Set<int> _unreadDrainInFlight = {};

  Future<void> _markAllAsRead() async {
    if (_updatesList.isEmpty) return;

    final unreadItems = _updatesList.where((it) => !(it['chapter'] as Chapter).isRead).toList();
    if (unreadItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All update chapters are already marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark All as Read', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Mark all ${unreadItems.length} update chapters as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mark as Read'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Centralised Incognito guard (see commitChapterReadState). Previously this
    // bulk path wrote every chapter read to Isar and pushed every one to the
    // server even with Incognito on.
    if (SettingsService.instance.incognitoMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — reading state is not saved')),
        );
      }
      return;
    }

    if (!mounted) return;
    // Re-derive the selection from the LIVE list.
    //
    // `unreadItems` was snapshotted before the confirmation dialog, and the
    // WebSocket listener schedules a cache reload during that await which
    // REPLACES `_updatesList` with fresh Chapter instances. So the snapshot
    // held detached objects: mutating them was invisible to the widget tree
    // (the feed still showed them unread) while `saveChapters` persisted them
    // read and the deltas below decremented the live badge — the badge and the
    // feed disagreed with no resync until a cold start. The snapshot is still
    // used for the dialog's count text, which is correct.
    final chaptersToUpdate = <Chapter>[];
    setState(() {
      for (final it in _updatesList) {
        final ch = it['chapter'] as Chapter;
        if (ch.isRead) continue;
        ch.applyReadState(true);
        chaptersToUpdate.add(ch);
      }
    });

    await IsarService.instance.saveChapters(chaptersToUpdate);

    // Keep library unread badges in sync with bulk mark-read (same invariant
    // the reader/detail maintain per chapter). Group deltas by manga so each
    // manga wrapper is adjusted and persisted once instead of N times. Every
    // chapter in chaptersToUpdate was unread before this batch (it derives
    // from unreadItems above), so each contributes exactly one read marker.
    final deltas = <int, int>{};
    for (final ch in chaptersToUpdate) {
      // `!= 0`, not `> 0`: a local/standalone series' mangaId is a NEGATIVE
      // synthetic value, so `> 0` silently skipped every local series' badge.
      if (ch.mangaId == 0) continue;
      deltas[ch.mangaId] = (deltas[ch.mangaId] ?? 0) + 1;
    }
    for (final entry in deltas.entries) {
      await _adjustMangaUnreadCount(entry.key, delta: -entry.value);
    }

    // manga-detail parity for the bulk path (delete-if-marked-read + scrobble).
    for (final ch in chaptersToUpdate) {
      await _applyMarkedReadSideEffects(ch);
    }

    for (final ch in chaptersToUpdate) {
      await SyncEngine.instance.stampLocalReadActivity(ch);
      if (ch.serverId > 0) {
        unawaited(
          SyncEngine.instance.syncChapterProgress(
            ch.serverId,
            isRead: true,
            lastPageRead: ch.lastPageRead,
          ),
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked ${chaptersToUpdate.length} chapters as read'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearUpdatesHistory() async {
    if (_updatesList.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Updates Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Remove current chapters from the Updates feed? This will not delete any chapters or reading history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final chaptersToReset = <Chapter>[];
    for (final it in _updatesList) {
      final ch = it['chapter'] as Chapter;
      ch.fetchedAt = 0;
      chaptersToReset.add(ch);
    }

    await IsarService.instance.saveChapters(chaptersToReset);

    // Guarded, and assigned rather than cleared in place.
    //
    // This ran `setState` after two awaits (the dialog, then the Isar write) with
    // no check, while the `if (mounted)` sat on the very next line — an omission
    // rather than a judgement call, since `setState` after unmount is a
    // null-check crash in release, not an assert.
    //
    // `_updatesList.clear()` also mutated the list in place, so an in-flight
    // background fetch — which has no re-entrancy guard — merged its results
    // into the list the user had just emptied and repopulated it.
    if (!mounted) return;
    setState(() {
      _updatesList = [];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updates feed cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDownloadOptions(Map<String, dynamic> item) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final ch = item['chapter'] as Chapter;
    final isDownloaded = item['isDownloaded'] as bool? ?? false;
    final chId = ch.serverId != 0 ? ch.serverId : ch.id;
    final isLocalDownloaded = DownloadManagerService.instance.isChapterDownloadedLocally(chId);
    final resolvedMangaTitle = (item['title'] as String?) ?? 'Manga';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.cloud_download_rounded, color: primaryColor),
                title: const Text('Download to Suwayomi Server', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Download and cache on your central server storage'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (GraphQLClientService.instance.isConfigured) {
                    await GraphQLClientService.instance.enqueueChapterDownload(ch.serverId);
                  }
                  messenger.showSnackBar(
                    SnackBar(content: Text('Enqueued ${ch.name} on server')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.phone_android_rounded, color: primaryColor),
                title: const Text('Download to Local Device (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Save chapter pages locally for offline reading'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await DownloadManagerService.instance.enqueueLocalDownload(
                    chapterId: chId,
                    mangaId: ch.mangaId,
                    chapterName: ch.name,
                    mangaTitle: resolvedMangaTitle,
                    chapterNumber: ch.chapterNumber,
                  );
                  messenger.showSnackBar(
                    SnackBar(content: Text('Downloading ${ch.name} to local device...')),
                  );
                },
              ),
              if (isDownloaded)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Server', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    if (GraphQLClientService.instance.isConfigured) {
                      await GraphQLClientService.instance.deleteDownloadedChapter(ch.serverId);
                    }
                    if (mounted) {
                      await _loadUpdatesFromIsarCache();
                    }
                  },
                ),
              if (isLocalDownloaded)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Local Device', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Free up offline storage space on this device'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteLocalDownload(chId);
                    if (mounted) _loadUpdatesFromIsarCache();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpdateCard(BuildContext context, Map<String, dynamic> item, {required bool isTablet}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ch = item['chapter'] as Chapter;
    final mangaId = item['mangaId'] as int;
    final title = item['title'] as String;
    final thumb = item['thumbnailUrl'] as String;
    final chId = ch.serverId != 0 ? ch.serverId : ch.id;

    final isLocalDownloaded = DownloadManagerService.instance.isChapterDownloadedLocally(chId);
    final isDownloading = DownloadManagerService.instance.localTasks
        .any((t) => t.chapterId == chId && (t.status == LocalDownloadStatus.downloading || t.status == LocalDownloadStatus.queued));
    final isDownloaded = (item['isDownloaded'] as bool? ?? false) || isLocalDownloaded || ch.isDownloaded || ch.isDownloadedOnServer;
    final isRead = ch.isRead;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 0.0 : 16.0,
        vertical: 4.0,
      ),
      child: Material(
        color: const Color(0x1F22222E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isRead ? const Color(0x15FFFFFF) : const Color(0x28FFFFFF),
            width: 0.8,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/manga/$mangaId'),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 10 : 8),
            child: Row(
              children: [
                // Manga cover thumbnail
                Hero(
                  tag: 'update_cover_${chId}_$mangaId',
                  child: Container(
                    width: isTablet ? 50 : 44,
                    height: isTablet ? 72 : 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[900],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: MangaCoverImage(
                        mangaServerId: mangaId,
                        thumbnailUrl: thumb,
                        sourceName: item['sourceName'] as String?,
                        width: isTablet ? 50 : 44,
                        height: isTablet ? 72 : 62,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Manga title and chapter info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14.5 : 13.5,
                          color: isRead ? Colors.white60 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (!isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Text(
                              ch.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isTablet ? 12.5 : 12,
                                color: isRead ? Colors.white38 : primaryColor,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isTablet && (item['sourceName'] as String? ?? '').isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item['sourceName'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (_languageBadgeLabel(item['lang'] as String? ?? '') != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0x26FFFFFF)),
                            ),
                            child: Text(
                              _languageBadgeLabel(item['lang'] as String? ?? '')!,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // Quick Actions Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mark as read/unread button
                    IconButton(
                      icon: Icon(
                        isRead ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                        color: isRead ? primaryColor : Colors.white38,
                        size: isTablet ? 22 : 20,
                      ),
                      tooltip: isRead ? 'Mark as unread' : 'Mark as read',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _toggleChapterRead(item),
                    ),
                    // Download button
                    IconButton(
                      icon: isDownloading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isLocalDownloaded
                                  ? Icons.download_done_rounded
                                  : (ch.isDownloadedOnServer || (item['isDownloaded'] as bool? ?? false)
                                      ? Icons.cloud_done_rounded
                                      : Icons.download_rounded),
                              color: isDownloaded ? Colors.greenAccent : Colors.grey,
                              size: isTablet ? 22 : 20,
                            ),
                      tooltip: isLocalDownloaded
                          ? 'Downloaded on device'
                          : (ch.isDownloadedOnServer ? 'Downloaded on server' : 'Download options'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showDownloadOptions(item),
                    ),
                    // Read chapter button
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_fill_rounded,
                        color: primaryColor,
                        size: isTablet ? 28 : 24,
                      ),
                      tooltip: 'Read chapter',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        await context.push('/reader/${ch.serverId != 0 ? ch.serverId : ch.id}');
                        if (mounted) _loadUpdatesFromIsarCache();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 720;

    // Group updates by dateHeader
    final visibleUpdates = _filteredUpdates;
    final Map<String, List<Map<String, dynamic>>> groupedUpdates = {};
    for (final item in visibleUpdates) {
      final header = item['dateHeader'] as String? ?? 'Recent';
      groupedUpdates.putIfAbsent(header, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search updates...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Updates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            if (_liveUpdateStatus != null && _liveUpdateStatus!.isNotEmpty)
              Text(
                _liveUpdateStatus!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
              )
            else if (!GraphQLClientService.instance.isConfigured)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4), width: 0.6),
                ),
                child: const Text(
                  'STANDALONE MODE',
                  style: TextStyle(fontSize: 9.5, color: Colors.tealAccent, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              )
            else if (_isOffline)
              const Text(
                'Offline — Cached updates',
                style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: 'Search',
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: Icon(
              _unreadOnly ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              color: _unreadOnly ? primaryColor : null,
            ),
            tooltip: _unreadOnly ? 'Show all updates' : 'Unread only',
            onPressed: () => setState(() => _unreadOnly = !_unreadOnly),
          ),
          ListenableBuilder(
            listenable: LibraryUpdateService.instance,
            builder: (context, _) {
              final isBusy = LibraryUpdateService.instance.isUpdating || _isCheckingServer;
              return IconButton(
                icon: isBusy
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.2))
                    : Icon(Icons.refresh_rounded, color: primaryColor),
                tooltip: GraphQLClientService.instance.isConfigured ? 'Check Server Updates' : 'Check for Updates',
                onPressed: isBusy ? null : _checkServerForUpdates,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More options',
            color: const Color(0xFF22222C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'mark_all_read') {
                _markAllAsRead();
              } else if (val == 'clear_feed') {
                _clearUpdatesHistory();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20, color: Colors.white70),
                    SizedBox(width: 10),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_feed',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 20, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Clear feed', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: RefreshIndicator(
            color: primaryColor,
            // A pull gesture means "refresh this feed", not "re-scrape the
            // whole library". This used to call _checkServerForUpdates, which
            // with isManual: true bypasses every constraint gate and runs the
            // entire pipeline: it makes Suwayomi re-scrape every source, polls
            // for up to serverUpdatePollTimeoutSeconds, triggers a full
            // SyncEngine snapshot (one fetchMangaDetails per library title), and
            // then serially re-scrapes every local-JS title through QuickJS —
            // with no overall timeout, so the spinner could run for minutes.
            //
            // Now it re-reads the local cache and pulls the latest update
            // chapters (a single fetchUpdatesChapters(first: 100)) — the same
            // lightweight path the screen already uses on first load. The
            // expensive library-wide check remains on the AppBar button, which
            // is where an explicit "check for updates" belongs.
            onRefresh: _refreshFeed,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ListenableBuilder(
                    listenable: DownloadManagerService.instance,
                    builder: (context, _) {
                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        scrollCacheExtent: ScrollCacheExtent.pixels(800),
                        slivers: [
                          ListenableBuilder(
                            listenable: LibraryUpdateService.instance,
                            builder: (context, _) {
                              final updater = LibraryUpdateService.instance;
                              if (!updater.isUpdating) return const SliverToBoxAdapter(child: SizedBox.shrink());
                              return SliverToBoxAdapter(
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24 : 16,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E26),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              updater.statusMessage,
                                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: updater.progress > 0 ? updater.progress : null,
                                          minHeight: 4,
                                          backgroundColor: const Color(0x22FFFFFF),
                                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (_lastUpdateText != null)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 24.0 : 20.0,
                                  vertical: 6.0,
                                ),
                                child: Text(
                                  _lastUpdateText!,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          if (visibleUpdates.isEmpty)
                            SliverToBoxAdapter(
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none_rounded, size: 64, color: primaryColor.withAlpha(120)),
                                    const SizedBox(height: 16),
                                    Text(
                                      _updatesList.isEmpty ? 'No Recent Updates' : 'No Matching Updates',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _updatesList.isEmpty
                                          ? 'Pull down to check for updates or\nadd more manga to your library.'
                                          : 'Nothing matches your current filters\n(unread-only, languages, or search).',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 20),
                                    if (_updatesList.isEmpty)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        ),
                                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                        label: const Text('Check Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        onPressed: _checkServerForUpdates,
                                      )
                                    else
                                      TextButton.icon(
                                        onPressed: () => setState(() {
                                          _unreadOnly = false;
                                          _searchQuery = '';
                                        }),
                                        icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                                        label: const Text('Clear filters', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            for (final entry in groupedUpdates.entries) ...[
                              // Date Section Header
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 18.0,
                                    bottom: 8.0,
                                    left: isTablet ? 20.0 : 20.0,
                                    right: 20.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18.5 : 16.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${entry.value.length}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Section Content: Grid on Tablet, List on Phone
                              if (isTablet)
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  sliver: SliverGrid(
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 480,
                                      mainAxisExtent: 96,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 10,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildUpdateCard(
                                        context,
                                        entry.value[index],
                                        isTablet: true,
                                      ),
                                      childCount: entry.value.length,
                                    ),
                                  ),
                                )
                              else
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildUpdateCard(
                                      context,
                                      entry.value[index],
                                      isTablet: false,
                                    ),
                                    childCount: entry.value.length,
                                  ),
                                ),
                            ],
                            SliverToBoxAdapter(
                              child: SizedBox(height: isTablet ? 40 : 120),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
