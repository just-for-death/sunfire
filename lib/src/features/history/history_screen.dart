import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/sync/sync_engine.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final chapters = await IsarService.instance.getReadingHistory();
      final items = <Map<String, dynamic>>[];

      for (final ch in chapters) {
        final manga = await IsarService.instance.getMangaByServerId(ch.mangaId);
        items.add({
          'chapter': ch,
          'manga': manga,
        });
      }

      setState(() {
        _historyItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.sync_rounded, color: primaryColor),
            onPressed: () async {
              await SyncEngine.instance.triggerSync();
              await _loadHistory();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await SyncEngine.instance.triggerSync();
          await _loadHistory();
        },
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _historyItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No reading history synced yet.\nPull down to sync from server.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 120.0),
                      itemCount: _historyItems.length,
                      itemBuilder: (context, index) {
                        final item = _historyItems[index];
                        final ch = item['chapter'] as Chapter;
                        final manga = item['manga'] as Manga?;
                        final title = manga?.title ?? 'Manga #${ch.mangaId}';
                        final thumb = manga?.thumbnailUrl;

                        final double progressValue = ch.pageCount > 0
                            ? (ch.lastPageRead / ch.pageCount).clamp(0.0, 1.0)
                            : (ch.isRead ? 1.0 : (ch.lastPageRead > 0 ? 0.35 : 0.0));

                        final int currentPage = ch.lastPageRead > 0 ? ch.lastPageRead : 1;
                        final String progressText = ch.pageCount > 0
                            ? 'Page $currentPage / ${ch.pageCount} (${(progressValue * 100).toInt()}%)'
                            : (ch.isRead ? 'Completed' : 'Page $currentPage');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Material(
                            color: const Color(0x1F2A2A32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onTap: () => context.push('/reader/${ch.serverId}'),
                              leading: Container(
                                width: 44,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[900],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: thumb != null && thumb.isNotEmpty
                                      ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.book_rounded, size: 20, color: Colors.grey)))
                                      : const Center(child: Icon(Icons.book_rounded, size: 20, color: Colors.grey)),
                                ),
                              ),
                              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  // ── PROGRESS BAR (Catalyst & Mihon) ──
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
                                onPressed: () => context.push('/reader/${ch.serverId}'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
