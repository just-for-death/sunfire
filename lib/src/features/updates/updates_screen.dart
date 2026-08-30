import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Map<String, dynamic>> _updatesList = [];
  bool _isLoading = false;
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
    // 1. Show local cache immediately (0ms instant render)
    await _loadUpdatesFromIsarCache();

    // 2. Background server fetch (only if configured, never blocks initial render)
    if (GraphQLClientService.instance.isConfigured) {
      _fetchServerUpdatesInBackground();
    }
  }

  Future<void> _fetchServerUpdatesInBackground() async {
    try {
      final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
      final items = <Map<String, dynamic>>[];

      // Fetch last update timestamp
      final tsStr = await GraphQLClientService.instance
          .fetchLastUpdateTimestamp()
          .timeout(const Duration(seconds: 4));
      if (tsStr != null) {
        final ts = int.tryParse(tsStr);
        if (ts != null && mounted) {
          final dt = DateTime.fromMillisecondsSinceEpoch(ts);
          setState(() {
            _lastUpdateText = 'Last update: ${DateFormat('MM/dd/yyyy, hh:mm a').format(dt)}';
          });
        }
      }

      final data = await GraphQLClientService.instance
          .fetchUpdatesChapters(first: 100)
          .timeout(const Duration(seconds: 8));

      if (data != null && data.containsKey('chapters')) {
        final nodes = data['chapters']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          for (final n in nodes) {
            final map = n as Map<String, dynamic>;
            final mangaMap = map['manga'] as Map<String, dynamic>?;
            final chServerId = parseIntSafe(map['id']);
            final ch = Chapter()
              ..serverId = chServerId
              ..mangaId = parseIntSafe(map['mangaId'])
              ..name = map['name'] as String? ?? 'Chapter'
              ..chapterNumber = parseDoubleSafe(map['chapterNumber'])
              ..isRead = parseBoolSafe(map['isRead'])
              ..lastPageRead = parseIntSafe(map['lastPageRead']);

            String title = 'Manga';
            String thumb = '';
            int mId = ch.mangaId;
            String sourceName = '';

            if (mangaMap != null) {
              title = mangaMap['title'] as String? ?? 'Manga';
              mId = parseIntSafe(mangaMap['id'], mId);
              final rawThumb = mangaMap['thumbnailUrl'] as String?;
              if (rawThumb != null && rawThumb.isNotEmpty) {
                thumb = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
              }
              final srcMap = mangaMap['source'] as Map<String, dynamic>?;
              sourceName = srcMap?['displayName'] as String? ?? '';
            }

            final isDownloaded = parseBoolSafe(map['isDownloaded']);
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

      if (items.isNotEmpty && mounted) {
        setState(() {
          _updatesList = items;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
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
    super.build(context);
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: RefreshIndicator(
            color: primaryColor,
            onRefresh: _checkServerForUpdates,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    scrollCacheExtent: ScrollCacheExtent.pixels(800),
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
                        if (_updatesList.isEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_none_rounded, size: 64, color: primaryColor.withAlpha(120)),
                                  const SizedBox(height: 16),
                                  const Text('No Recent Updates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Pull down to check for updates or\nadd more manga to your library.',
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
                                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                                    label: const Text('Check Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    onPressed: _checkServerForUpdates,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
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
                                              child: MangaCoverImage(
                                                mangaServerId: mangaId,
                                                thumbnailUrl: thumb,
                                                sourceName: item['sourceName'] as String?,
                                                width: 44,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          subtitle: Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  isDownloaded ? Icons.cloud_done_rounded : Icons.download_rounded,
                                                  color: isDownloaded ? Colors.greenAccent : Colors.grey,
                                                  size: 22,
                                                ),
                                                tooltip: 'Download options',
                                                onPressed: () => _showDownloadOptions(item),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 26),
                                                tooltip: 'Read chapter',
                                                onPressed: () => context.push('/reader/${ch.serverId}'),
                                              ),
                                            ],
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
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
