import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  List<Map<String, dynamic>> _updatesList = [];
  bool _isLoading = true;
  bool _isCheckingServer = false;
  bool _isOffline = false;
  String? _lastUpdateText;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  String _formatDateHeader(int? fetchedAt) {
    if (fetchedAt == null || fetchedAt == 0) return 'Recent';
    final date = DateTime.fromMillisecondsSinceEpoch(fetchedAt * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(itemDate).inDays;
    if (diffDays == 0) {
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
    setState(() => _isLoading = true);
    bool serverSucceeded = false;

    // ── TRY SERVER (with 5s timeout) ─────────────────────────────────────
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
        final items = <Map<String, dynamic>>[];

        // Fetch last update timestamp
        final tsStr = await GraphQLClientService.instance
            .fetchLastUpdateTimestamp()
            .timeout(const Duration(seconds: 5));
        if (tsStr != null) {
          final ts = int.tryParse(tsStr);
          if (ts != null) {
            final dt = DateTime.fromMillisecondsSinceEpoch(ts);
            _lastUpdateText = 'Last update: ${DateFormat('MM/dd/yyyy, hh:mm a').format(dt)}';
          }
        }

        final data = await GraphQLClientService.instance
            .fetchUpdatesChapters(first: 100)
            .timeout(const Duration(seconds: 5));

        if (data != null && data.containsKey('chapters')) {
          final nodes = data['chapters']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final map = n as Map<String, dynamic>;
              final mangaMap = map['manga'] as Map<String, dynamic>?;
              final chServerId = map['id'] as int;
              final ch = Chapter()
                ..serverId = chServerId
                ..mangaId = map['mangaId'] as int? ?? 0
                ..name = map['name'] as String? ?? 'Chapter'
                ..chapterNumber = (map['chapterNumber'] as num? ?? 0).toDouble()
                ..isRead = map['isRead'] as bool? ?? false
                ..lastPageRead = map['lastPageRead'] as int? ?? 0;

              String title = 'Manga';
              String thumb = '';
              int mId = ch.mangaId;
              String sourceName = '';

              if (mangaMap != null) {
                title = mangaMap['title'] as String? ?? 'Manga';
                mId = mangaMap['id'] as int? ?? mId;
                final rawThumb = mangaMap['thumbnailUrl'] as String?;
                if (rawThumb != null && rawThumb.isNotEmpty) {
                  thumb = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
                }
                final srcMap = mangaMap['source'] as Map<String, dynamic>?;
                sourceName = srcMap?['displayName'] as String? ?? '';
              }

              final isDownloaded = map['isDownloaded'] as bool? ?? false;
              final fetchedAt = map['fetchedAt'] != null ? int.tryParse(map['fetchedAt'].toString()) : null;

              items.add({
                'chapter': ch,
                'mangaId': mId,
                'title': title,
                'thumbnailUrl': thumb,
                'sourceName': sourceName,
                'isDownloaded': isDownloaded,
                'fetchedAt': fetchedAt,
                'dateHeader': _formatDateHeader(fetchedAt),
              });
            }
          }
        }

        if (items.isNotEmpty) {
          serverSucceeded = true;
          if (mounted) {
            setState(() {
              _updatesList = items;
              _isLoading = false;
              _isOffline = false;
            });
          }
          return;
        }
      } catch (_) {
        // Server unreachable — fall through to local Isar cache
      }
    }

    // ── OFFLINE FALLBACK: Isar chapter cache ──────────────────────────────
    // Uses denormalized mangaTitle + mangaThumbnailUrl saved during last sync.
    await _loadUpdatesFromIsarCache();
    if (!serverSucceeded && mounted) setState(() => _isOffline = true);
  }

  Future<void> _loadUpdatesFromIsarCache() async {
    try {
      final chapters = await IsarService.instance.getRecentChapters(limit: 100);
      final items = <Map<String, dynamic>>[];

      for (final ch in chapters) {
        // Use denormalized fields when available, else fall back to Isar join
        String title = ch.mangaTitle.isNotEmpty ? ch.mangaTitle : 'Manga #${ch.mangaId}';
        String thumb = ch.mangaThumbnailUrl ?? '';

        if (title == 'Manga #${ch.mangaId}' || thumb.isEmpty) {
          final manga = await IsarService.instance.getMangaByServerId(ch.mangaId);
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
          'isDownloaded': ch.isDownloaded,
          'fetchedAt': ch.fetchedAt,
          'dateHeader': _formatDateHeader(ch.fetchedAt),
        });
      }

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

  // Legacy compat — kept for pull-to-refresh and server check button
  Future<void> _loadUpdatesFromServer() => _loadUpdates();


  Future<void> _checkServerForUpdates() async {
    setState(() => _isCheckingServer = true);
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.triggerServerLibraryUpdate();
    }
    await SyncEngine.instance.triggerSync();
    await _loadUpdatesFromServer();

    if (mounted) {
      setState(() => _isCheckingServer = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Server library update completed'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  void _showDownloadOptions(Map<String, dynamic> item) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final ch = item['chapter'] as Chapter;
    final isDownloaded = item['isDownloaded'] as bool? ?? false;

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
                onTap: () {
                  Navigator.pop(sheetContext);
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
                    _loadUpdatesFromServer();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Updates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            if (_isOffline)
              const Text(
                'Offline — Cached updates',
                style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isCheckingServer
                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5))
                : Icon(Icons.refresh_rounded, color: primaryColor),
            tooltip: 'Check Server Updates',
            onPressed: _isCheckingServer ? null : _checkServerForUpdates,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _checkServerForUpdates,
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _updatesList.isEmpty
                  ? const Center(
                      child: Text(
                        'No recent chapter updates found.\nTap refresh to check your Suwayomi server.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        if (_lastUpdateText != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                              child: Text(
                                _lastUpdateText!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _updatesList[index];
                              final ch = item['chapter'] as Chapter;
                              final mangaId = item['mangaId'] as int;
                              final title = item['title'] as String;
                              final thumb = item['thumbnailUrl'] as String;
                              final isDownloaded = item['isDownloaded'] as bool? ?? false;
                              final dateHeader = item['dateHeader'] as String;

                              // Show header if first item or if previous item had different date
                              final bool showHeader = index == 0 || _updatesList[index - 1]['dateHeader'] != dateHeader;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showHeader) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14.0, bottom: 8.0, left: 4.0),
                                        child: Text(
                                          dateHeader,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Material(
                                        color: const Color(0x1F2A2A32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                                        ),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          onTap: () => context.push('/manga/$mangaId'),
                                          leading: Container(
                                            width: 44,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.grey[900],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: thumb.isNotEmpty
                                                  ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.book_rounded, size: 20, color: Colors.grey)))
                                                  : const Center(child: Icon(Icons.book_rounded, size: 20, color: Colors.grey)),
                                            ),
                                          ),
                                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          subtitle: Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                                          trailing: IconButton(
                                            icon: Icon(
                                              isDownloaded ? Icons.cloud_done_rounded : Icons.download_rounded,
                                              color: isDownloaded ? Colors.greenAccent : Colors.grey,
                                              size: 24,
                                            ),
                                            tooltip: 'Download options',
                                            onPressed: () => _showDownloadOptions(item),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: _updatesList.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
        ),
      ),
    );
  }
}
