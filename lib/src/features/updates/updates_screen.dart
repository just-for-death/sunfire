import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
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
    try {
      var libraryMangas = await IsarService.instance.getLibraryManga();

      if (libraryMangas.isEmpty) {
        await SyncEngine.instance.triggerSync();
        libraryMangas = await IsarService.instance.getLibraryManga();
      }

      final items = <Map<String, dynamic>>[];
      for (final manga in libraryMangas) {
        final chapters = await IsarService.instance.getChaptersForManga(manga.serverId);
        if (chapters.isNotEmpty) {
          final latestCh = chapters.first;
          items.add({
            'chapter': latestCh,
            'manga': manga,
          });
        }
      }

      setState(() {
        _updatesList = items;
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
                        'No recent chapter updates.\nPull down to check server for updates.',
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
                        final manga = item['manga'] as Manga;
                        final title = manga.title;
                        final thumb = manga.thumbnailUrl;

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
                              onTap: () => context.push('/manga/${manga.serverId}'),
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
                                  Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: primaryColor)),
                                  const SizedBox(height: 2),
                                  Text(ch.isRead ? 'Read' : 'Unread', style: TextStyle(fontSize: 11, color: ch.isRead ? Colors.grey : primaryColor, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.download_rounded, color: primaryColor),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Downloading ${ch.name}...')),
                                  );
                                },
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
