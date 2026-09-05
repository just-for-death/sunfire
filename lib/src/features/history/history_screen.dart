import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';


import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/sync/sync_engine.dart';
import '../../main_shell.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value == 2 && mounted) {
      _loadHistory();
    }
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final chapters = await IsarService.instance.getReadingHistory();
      final items = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (final ch in chapters) {
        final manga = await IsarService.instance.getMangaByServerId(ch.mangaId);
        final lastRead = ch.lastReadAt ?? 0;
        final readDate = lastRead > 0
            ? (lastRead > 1000000000000
                ? DateTime.fromMillisecondsSinceEpoch(lastRead)
                : DateTime.fromMillisecondsSinceEpoch(lastRead * 1000))
            : now;

        final diff = now.difference(readDate);
        String dateHeader;
        if (diff.inDays == 0 && now.day == readDate.day) {
          dateHeader = 'Today';
        } else if (diff.inDays <= 1 || (diff.inDays == 0 && now.day != readDate.day)) {
          dateHeader = 'Yesterday';
        } else if (diff.inDays < 7) {
          dateHeader = 'Past Week';
        } else {
          dateHeader = '${readDate.year}-${readDate.month.toString().padLeft(2, '0')}-${readDate.day.toString().padLeft(2, '0')}';
        }

        items.add({
          'chapter': ch,
          'manga': manga,
          'dateHeader': dateHeader,
        });
      }

      if (mounted) {
        setState(() {
          _historyItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F24),
        title: const Text('Clear Reading History?'),
        content: const Text('This will reset your reading progress and history timestamps locally.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final chapters = await IsarService.instance.getReadingHistory();
      for (final ch in chapters) {
        ch.lastPageRead = 0;
        ch.lastReadAt = 0;
        ch.isRead = false;
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
    final isTablet = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: const Text('History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
          IconButton(
            icon: Icon(Icons.sync_rounded, color: primaryColor),
            tooltip: 'Sync History',
            onPressed: () async {
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 64, color: primaryColor.withAlpha(120)),
                                const SizedBox(height: 16),
                                const Text('No Reading History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Start reading a chapter to track\nyour reading progress here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.explore_outlined, color: Colors.white, size: 18),
                                  label: const Text('Browse Manga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  onPressed: () => context.go('/browse'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            scrollCacheExtent: ScrollCacheExtent.pixels(800),
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width >= 720 ? 24.0 : 16.0,
                              right: MediaQuery.of(context).size.width >= 720 ? 24.0 : 16.0,
                              top: 12.0,
                              bottom: MediaQuery.of(context).size.width >= 720 ? 36.0 : 120.0,
                            ),
                      itemCount: _historyItems.length,
                      itemBuilder: (context, index) {
                        final item = _historyItems[index];
                        final ch = item['chapter'] as Chapter;
                        final manga = item['manga'] as Manga?;
                        final title = manga?.title ?? 'Manga #${ch.mangaId}';
                        final thumb = manga?.thumbnailUrl;
                        final dateHeader = item['dateHeader'] as String;
                        final bool showHeader = index == 0 || _historyItems[index - 1]['dateHeader'] != dateHeader;

                        final double progressValue = ch.pageCount > 0
                            ? (ch.lastPageRead / ch.pageCount).clamp(0.0, 1.0)
                            : (ch.isRead ? 1.0 : (ch.lastPageRead > 0 ? 0.35 : 0.0));

                        final int currentPage = ch.lastPageRead > 0 ? ch.lastPageRead : 1;
                        final String progressText = ch.pageCount > 0
                            ? 'Page $currentPage / ${ch.pageCount} (${(progressValue * 100).toInt()}%)'
                            : (ch.isRead ? 'Completed' : 'Page $currentPage');

                        return Column(
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
                                  color: const Color(0x1F2A2A32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                                  ),
                                  child: ListTile(
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                               onTap: () async {
                                 await context.push('/reader/${ch.serverId}');
                                 if (mounted) _loadHistory();
                               },
                               onLongPress: () async {
                                 final remove = await showDialog<bool>(
                                   context: context,
                                   builder: (dCtx) => AlertDialog(
                                     backgroundColor: const Color(0xFF1F1F24),
                                     title: const Text('Remove from History?'),
                                     content: Text('Remove "${ch.name}" from your reading history?'),
                                     actions: [
                                       TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                                       ElevatedButton(
                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                         onPressed: () => Navigator.pop(dCtx, true),
                                         child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                       ),
                                     ],
                                   ),
                                 );
                                 if (remove == true) {
                                   ch.lastReadAt = null;
                                   await IsarService.instance.saveChapter(ch);
                                   _loadHistory();
                                 }
                               },
                               leading: GestureDetector(
                                 onTap: () async {
                                   if (manga != null) {
                                     await context.push('/manga/${manga.serverId}');
                                     if (mounted) _loadHistory();
                                   }
                                 },
                                 child: Container(
                                   width: 44,
                                   height: 60,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(8),
                                     color: Colors.grey[900],
                                   ),
                                   child: ClipRRect(
                                     borderRadius: BorderRadius.circular(8),
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
                                     borderRadius: BorderRadius.circular(4),
                                     child: LinearProgressIndicator(
                                       value: progressValue,
                                       minHeight: 4,
                                       backgroundColor: const Color(0x33FFFFFF),
                                       valueColor: AlwaysStoppedAnimation<Color>(ch.isRead ? Colors.greenAccent : primaryColor),
                                     ),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(progressText, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                                 ],
                               ),
                               trailing: IconButton(
                                 icon: Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 32),
                                 tooltip: 'Resume reading',
                                 onPressed: () async {
                                   await context.push('/reader/${ch.serverId}');
                                   if (mounted) _loadHistory();
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
