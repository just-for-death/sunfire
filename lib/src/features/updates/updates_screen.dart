import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    setState(() => _isLoading = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    try {
      final items = <Map<String, dynamic>>[];

      // 1. Fetch live unread updates from Suwayomi
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchUpdatesChapters(first: 50);
        if (data != null && data.containsKey('chapters')) {
          final nodes = data['chapters']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final map = n as Map<String, dynamic>;
              final chServerId = map['id'] as int;
              final mangaMap = map['manga'] as Map<String, dynamic>?;

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

              if (mangaMap != null) {
                title = mangaMap['title'] as String? ?? 'Manga';
                mId = mangaMap['id'] as int? ?? mId;
                final rawThumb = mangaMap['thumbnailUrl'] as String?;
                if (rawThumb != null && rawThumb.isNotEmpty) {
                  thumb = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
                }
              }

              items.add({
                'chapter': ch,
                'mangaId': mId,
                'title': title,
                'thumbnailUrl': thumb,
              });
            }
          }
        }
      }

      // 2. Fallback to local DB if offline
      if (items.isEmpty) {
        final libraryMangas = await IsarService.instance.getLibraryManga();
        for (final manga in libraryMangas) {
          final chapters = await IsarService.instance.getChaptersForManga(manga.serverId);
          final unread = chapters.where((c) => !c.isRead).toList();
          if (unread.isNotEmpty) {
            items.add({
              'chapter': unread.first,
              'mangaId': manga.serverId,
              'title': manga.title,
              'thumbnailUrl': manga.thumbnailUrl ?? '',
            });
          }
        }
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.sync_rounded, color: primaryColor),
            onPressed: () async {
              await SyncEngine.instance.triggerSync();
              await _loadUpdates();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await SyncEngine.instance.triggerSync();
          await _loadUpdates();
        },
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _updatesList.isEmpty
                  ? const Center(
                      child: Text(
                        'No unread chapter updates.\nPull down to check server for updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 120.0),
                      itemCount: _updatesList.length,
                      itemBuilder: (context, index) {
                        final item = _updatesList[index];
                        final ch = item['chapter'] as Chapter;
                        final mangaId = item['mangaId'] as int;
                        final title = item['title'] as String;
                        final thumb = item['thumbnailUrl'] as String;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor)),
                                  const SizedBox(height: 2),
                                  Text('Unread Chapter', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 30),
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
