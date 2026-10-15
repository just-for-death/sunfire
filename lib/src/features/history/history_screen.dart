import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';


import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../main_shell.dart';
import '../../ui/design_system/components/sunfire_chip.dart';
import '../../ui/design_system/sunfire_theme.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import '../../ui/design_system/tokens/sunfire_typography.dart';
import '../../ui/shell/sunfire_breakpoints.dart';

/// S6.7: timeline filter for the History screen.
enum HistoryFilter { all, completed, inProgress }

/// History group label for a read date (UIS-10). Today / Yesterday / Past Week,
/// then Settings > General > Date Format. Grouping compares adjacent labels;
/// formatDate is 1:1 per calendar day, so it stays correct.
@visibleForTesting
String historyDateHeader(DateTime readDate, DateTime now) {
  final nowCalendar = DateTime(now.year, now.month, now.day);
  final readCalendar = DateTime(readDate.year, readDate.month, readDate.day);
  final dayDiff = nowCalendar.difference(readCalendar).inDays;
  if (dayDiff == 0) return 'Today';
  if (dayDiff == 1) return 'Yesterday';
  if (dayDiff < 7) return 'Past Week';
  return SettingsService.instance.formatDate(readDate);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> _historyItems = [];
  // Starts TRUE. It was declared false and never set true outside the loader,
  // so the very first frame of the tab unconditionally rendered "No Reading
  // History" for a user with a full history — a false claim, on every cold
  // start, for at least one frame.
  bool _isLoading = true;

  /// S6.7: history filter (timeline filter chips below the app bar).
  HistoryFilter _filter = HistoryFilter.all;

  /// Last successful sync timestamp for the sync-status line (S6.7).
  DateTime? _lastSyncAt;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
    unawaited(_refreshLastSync());
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
    SettingsService.instance.addListener(_onSettingsChanged);
  }

  late String _lastDateFormat = SettingsService.instance.dateFormat;

  void _onSettingsChanged() {
    final fmt = SettingsService.instance.dateFormat;
    if (fmt == _lastDateFormat || !mounted) return;
    _lastDateFormat = fmt;
    unawaited(_loadHistory());
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value == 2 && mounted) {
      unawaited(_loadHistory());
    }
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    SettingsService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// Monotonic token. A pass that is superseded must not write its results.
  int _loadGeneration = 0;

  /// The in-flight load, if any, so callers can await the real work.
  ///
  /// `_loadHistory` has four entry points — init, every switch to the tab (with
  /// no debounce, unlike Library), the appbar sync button (no busy flag, so a
  /// double-tap ran two full syncs), and the refresh indicator. Two concurrent
  /// passes meant the one that finished LAST won, which is not necessarily the
  /// newest — so a slow pass could land after a fast one and revert the list to
  /// older data.
  ///
  /// A plain `bool` guard would also make the refresh indicator complete
  /// instantly whenever a load was already running, which reads as the pull
  /// doing nothing. Sharing the future means a second caller waits for the pass
  /// that is actually going to populate the list.
  Future<void>? _historyLoadInFlight;

  bool get _isLoadingHistory => _historyLoadInFlight != null;

  /// S6.7: refresh the last-sync timestamp for the sync-status line.
  Future<void> _refreshLastSync() async {
    try {
      final ts = await IsarService.instance.getLastSyncTimestamp();
      if (mounted) setState(() => _lastSyncAt = ts);
    } catch (e) {
      debugPrint('[history] last sync time unavailable: $e');
    }
  }

  /// S6.7: timeline items after applying the active filter.
  List<Map<String, dynamic>> get _filteredItems {
    if (_filter == HistoryFilter.all) return _historyItems;
    return _historyItems.where((item) {
      final ch = item['chapter'] as Chapter;
      if (_filter == HistoryFilter.completed) return ch.isRead;
      return !ch.isRead;
    }).toList();
  }

  /// S6.7: human-readable sync status for the filter row.
  String get _syncStatusLabel {
    if (_lastSyncAt == null) return 'Never synced';
    final diff = DateTime.now().difference(_lastSyncAt!);
    if (diff.inMinutes < 1) return 'Synced just now';
    if (diff.inMinutes < 60) return 'Synced ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Synced ${diff.inHours}h ago';
    return 'Synced ${diff.inDays}d ago';
  }

  Future<void> _loadHistory() {
    final existing = _historyLoadInFlight;
    if (existing != null) return existing;
    final started = _runHistoryLoad();
    _historyLoadInFlight = started;
    return started;
  }

  Future<void> _runHistoryLoad() async {
    final loadGen = ++_loadGeneration;    if (mounted) setState(() => _isLoading = true);
    try {
      final chapters = await IsarService.instance.getReadingHistory();
      final items = <Map<String, dynamic>>[];
      final now = DateTime.now();

      // Cache manga lookups to eliminate N+1 queries.
      //
      // `id > 0` dropped every local/standalone series, whose `mangaId` is a
      // NEGATIVE synthetic value — so those entries rendered as
      // "Manga #-4000123" with no cover, for the whole of History. The hazard is
      // documented in isar_service and handled twice in manga_detail; history
      // was the one screen that never got it. `getMangaByServerId` filters the
      // serverId column, which is where the negative value lives, so no special
      // case is needed beyond not discarding it.
      final mangaIds = chapters.map((c) => c.mangaId).where((id) => id != 0).toSet();
      // ONE query, not one per series. The loop this replaced deduped repeats
      // but was still a sequential N+1, and the comment above it claimed
      // otherwise — a 200-series history meant 200 awaited Isar queries before
      // the list could render, on every tab switch and every pull-to-refresh.
      final mangaMap = <int, Manga?>{
        for (final m in await IsarService.instance.getMangaByServerIds(mangaIds.toList()))
          m.serverId: m,
      };

      for (final ch in chapters) {
        // ISS-060: include lastReadAt==0 reads (isRead / progress). getReadingHistory
        // already filtered to chapters with any read evidence.
        final lastRead = ch.lastReadAt ?? 0;

        final manga = mangaMap[ch.mangaId];
        // The app stores `lastReadAt` in epoch SECONDS. This used to use a
        // `1e12` threshold, while the canonical `normalizeEpochToSeconds` uses
        // `1e11` — so a value in the gap was treated as millis here and as
        // seconds in manga_detail, and this file multiplied a real millis value
        // by 1000 to produce the year 15858. One helper, one threshold.
        final lastReadSeconds = normalizeEpochToSeconds(lastRead) ?? 0;
        final dateHeader = lastReadSeconds > 0
            ? historyDateHeader(
                DateTime.fromMillisecondsSinceEpoch(lastReadSeconds * 1000),
                now,
              )
            : 'Earlier';

        items.add({
          'chapter': ch,
          'manga': manga,
          'dateHeader': dateHeader,
        });
      }

      if (loadGen != _loadGeneration) return;
      if (mounted) {
        setState(() {
          _historyItems = items;
          _isLoading = false;
        });
        // S6.7: refresh the sync-status line alongside the timeline.
        unawaited(_refreshLastSync());
      }
    } catch (e) {
      if (loadGen != _loadGeneration) return;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } finally {
      // Cleared before the future completes, so a caller awaiting the NEXT
      // refresh gets a fresh pass rather than joining this one.
      _historyLoadInFlight = null;
    }
  }

  /// S6.7: filter chips + sync-status header (index 0 of the timeline list).
  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        children: [
          SunfireChip(
            label: 'All',
            selected: _filter == HistoryFilter.all,
            onSelected: (_) => setState(() => _filter = HistoryFilter.all),
          ),
          const SizedBox(width: SunfireSpacing.sm),
          SunfireChip(
            label: 'Completed',
            selected: _filter == HistoryFilter.completed,
            onSelected: (_) =>
                setState(() => _filter = HistoryFilter.completed),
          ),
          const SizedBox(width: SunfireSpacing.sm),
          SunfireChip(
            label: 'In progress',
            selected: _filter == HistoryFilter.inProgress,
            onSelected: (_) =>
                setState(() => _filter = HistoryFilter.inProgress),
          ),
          const Spacer(),
          Text(
            _syncStatusLabel,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        // UIS-ISS-012: theme surface (was hard-coded dark hex)
        title: const Text('Clear Reading History?'),
        content: const Text('This will clear all entries from your reading history feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SunfireColors.error,
              foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final chapters = await IsarService.instance.getReadingHistory();
      for (final ch in chapters) {
        ch.clearHistoryTimestamp();
      }
      await IsarService.instance.saveChapters(chapters);
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading history cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isTablet = MediaQuery.of(context).size.width >= SunfireBreakpoints.narrowTabletMaxWidth;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: Text('History', style: SunfireTypography.withWeight(SunfireTypography.headlineMedium, FontWeight.bold)),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
          IconButton(
            icon: Icon(Icons.sync_rounded, color: primaryColor),
            tooltip: 'Sync History',
            onPressed: _isLoadingHistory
                ? null
                : () async {
                    await SyncEngine.instance.triggerSync();
                    await _loadHistory();
                  },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              await SyncEngine.instance.triggerSync();
              await _loadHistory();
            },
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _historyItems.isEmpty
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                            child: EmptyStateWidget(
                              icon: Icons.history_toggle_off_rounded,
                              title: 'No Reading History',
                              subtitle: 'Start reading a chapter to track your reading progress here.',
                              actionLabel: 'Browse Manga',
                              onAction: () => MainShell.switchToTab(3),
                            ),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            scrollCacheExtent: ScrollCacheExtent.pixels(800),
                            padding: EdgeInsets.only(
                              left: isTablet ? 24.0 : 16.0,
                              right: isTablet ? 24.0 : 16.0,
                              top: 12.0,
                              bottom: SunfireBreakpoints.scrollBottomPadding(context),
                            ),
                      itemCount: _filteredItems.length + 1,
                      itemBuilder: (context, index) {
                        // S6.7: index 0 is the filter + sync-status header.
                        if (index == 0) return _buildFilterHeader();
                        final visibleItems = _filteredItems;
                        final item = visibleItems[index - 1];
                        final ch = item['chapter'] as Chapter;
                        final manga = item['manga'] as Manga?;
                        final title = manga?.title ?? 'Manga #${ch.mangaId}';
                        final thumb = manga?.thumbnailUrl;
                        final dateHeader = item['dateHeader'] as String;
                        final bool showHeader = index == 1 || visibleItems[index - 2]['dateHeader'] != dateHeader;

                        final double progressValue = ch.pageCount > 0
                            ? (ch.lastPageRead / ch.pageCount).clamp(0.0, 1.0)
                            : (ch.isRead ? 1.0 : (ch.lastPageRead > 0 ? 0.35 : 0.0));

                        final int currentPage = ch.lastPageRead > 0 ? ch.lastPageRead : 1;
                        final String progressText = ch.pageCount > 0
                            ? 'Page $currentPage / ${ch.pageCount} (${(progressValue * 100).toInt()}%)'
                            : (ch.isRead ? 'Completed' : 'Page $currentPage');

                        return Column(
                          key: ValueKey('history_${ch.serverId != 0 ? ch.serverId : ch.id}'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0, bottom: 8.0, left: 4.0),
                                child: Text(
                                  dateHeader,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            RepaintBoundary(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Material(
                                  color: SunfireTheme.tileSurface(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(SunfireRadius.lg),
                                    side: BorderSide(color: SunfireTheme.tileBorder(context), width: 0.8),
                                  ),
                                  child: ListTile(
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.lg)),
                                onTap: () async {
                                  await context.push('/reader/${ch.serverId != 0 ? ch.serverId : ch.id}');
                                  if (mounted) unawaited(_loadHistory());
                                },
                               onLongPress: () async {
                                 final remove = await showDialog<bool>(
                                   context: context,
                                   builder: (dCtx) => AlertDialog(
                                     // UIS-ISS-012: theme surface (was hard-coded dark hex)
                                     title: const Text('Remove from History?'),
                                     content: Text('Remove "${ch.name}" from your reading history?'),
                                     actions: [
                                       TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                       ElevatedButton(
                                         style: ElevatedButton.styleFrom(backgroundColor: SunfireColors.error),
                                         onPressed: () => Navigator.pop(dCtx, true),
                                         child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
                                       ),
                                     ],
                                   ),
                                 );
                                   if (remove == true) {
                                   ch.clearHistoryTimestamp();
                                   await IsarService.instance.saveChapter(ch);
                                   unawaited(_loadHistory());
                                 }
                               },
                               leading: GestureDetector(
                                 onTap: () async {
                                   if (manga != null) {
                                     final targetId = manga.canonicalKey;
                                     await context.push('/manga/$targetId');
                                     if (mounted) unawaited(_loadHistory());
                                   }
                                 },
                                 child: Container(
                                   width: 44,
                                   height: 60,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(SunfireRadius.sm),
                                     color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                   ),
                                   child: ClipRRect(
                                     borderRadius: BorderRadius.circular(SunfireRadius.sm),
                                     child: MangaCoverImage(
                                       mangaServerId: ch.mangaId,
                                       thumbnailUrl: thumb,
                                       sourceName: manga?.sourceName,
                                       fit: BoxFit.cover,
                                     ),
                                   ),
                                 ),
                               ),
                               title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                               subtitle: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const SizedBox(height: 2),
                                   Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                                   const SizedBox(height: 6),
                                   // ── PROGRESS BAR (Sunfire & Mihon) ──
                                   ClipRRect(
                                     borderRadius: BorderRadius.circular(SunfireRadius.xs),
                                     child: LinearProgressIndicator(
                                       value: progressValue,
                                       minHeight: 4,
                                       backgroundColor: SunfireTheme.overlayFill(context),
                                       valueColor: AlwaysStoppedAnimation<Color>(ch.isRead ? SunfireColors.success : primaryColor),
                                     ),
                                   ),
                                   const SizedBox(height: SunfireSpacing.xs),
                                   Text(progressText, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                 ],
                               ),
                               trailing: IconButton(
                                 icon: Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 32),
                                 tooltip: 'Resume reading',
                                 onPressed: () async {
                                   await context.push('/reader/${ch.serverId != 0 ? ch.serverId : ch.id}');
                                   if (mounted) unawaited(_loadHistory());
                                 },
                               ),
                             ),
                          ),
                        ),
                      ),
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
