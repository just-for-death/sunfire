import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/services/download_manager_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import 'tracking_bottom_sheet.dart';

class MangaDetailScreen extends StatefulWidget {
  final int mangaServerId;

  const MangaDetailScreen({super.key, required this.mangaServerId});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  Manga? _manga;
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  bool _sortAscending = false;
  bool _isDescExpanded = false;

  // Multi-chapter selection state
  final Set<int> _selectedChapterIds = {};

  @override
  void initState() {
    super.initState();
    _loadMangaDetails();
  }

  Future<void> _loadMangaDetails() async {
    setState(() => _isLoading = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // 1. Check local Isar DB first to display immediate cached state
    _manga = await IsarService.instance.getMangaByServerId(widget.mangaServerId);
    _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    if (_manga != null && _chapters.isNotEmpty && mounted) {
      setState(() => _isLoading = false);
    }

    // 2. Fetch fresh details AND chapters from Suwayomi GraphQL
    if (GraphQLClientService.instance.isConfigured) {
      try {
        var detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);

        // If chapters are empty on server, scrape online from source directly!
        final rawChNodes = (detailsData?['manga']?['chapters']?['nodes'] as List<dynamic>?) ?? [];
        if (rawChNodes.isEmpty) {
          await GraphQLClientService.instance.fetchMangaAndChapters(widget.mangaServerId);
          detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);
        }

        if (detailsData != null && detailsData.containsKey('manga') && detailsData['manga'] != null) {
          final mMap = detailsData['manga'] as Map<String, dynamic>;
          _manga ??= Manga()..serverId = widget.mangaServerId;
          _manga!.title = mMap['title'] as String? ?? _manga!.title;
          _manga!.author = mMap['author'] as String?;
          _manga!.artist = mMap['artist'] as String?;
          _manga!.description = mMap['description'] as String?;
          _manga!.status = mMap['status'] as String?;
          _manga!.inLibrary = mMap['inLibrary'] as bool? ?? _manga!.inLibrary;

          final rawThumb = mMap['thumbnailUrl'] as String?;
          if (rawThumb != null && rawThumb.isNotEmpty) {
            _manga!.thumbnailUrl = rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb';
          }

          if (mMap.containsKey('genre') && mMap['genre'] != null) {
            _manga!.genres = (mMap['genre'] as List<dynamic>).map((g) => g.toString()).toList();
          }

          final sourceMap = mMap['source'] as Map<String, dynamic>?;
          if (sourceMap != null) {
            _manga!.sourceName = sourceMap['displayName'] as String? ?? sourceMap['name'] as String? ?? _manga!.sourceName;
          }

          await IsarService.instance.saveManga(_manga!);

          // Process nested chapters
          final chaptersMap = mMap['chapters'] as Map<String, dynamic>?;
          if (chaptersMap != null && chaptersMap.containsKey('nodes')) {
            final chNodes = chaptersMap['nodes'] as List<dynamic>?;
            if (chNodes != null && chNodes.isNotEmpty) {
              final fetched = <Chapter>[];
              for (final n in chNodes) {
                final chMap = n as Map<String, dynamic>;
                final ch = Chapter()
                  ..serverId = chMap['id'] as int
                  ..mangaId = widget.mangaServerId
                  ..name = chMap['name'] ?? 'Chapter ${chMap['chapterNumber']}'
                  ..chapterNumber = (chMap['chapterNumber'] as num? ?? 0).toDouble()
                  ..isRead = chMap['isRead'] as bool? ?? false
                  ..lastPageRead = chMap['lastPageRead'] as int? ?? 0
                  ..pageCount = chMap['pageCount'] as int? ?? 0;
                fetched.add(ch);
              }
              await IsarService.instance.saveChapters(fetched);
              _chapters = fetched;
            }
          }
        }
      } catch (_) {}
    }

    _manga ??= Manga()
      ..serverId = widget.mangaServerId
      ..title = 'Manga #${widget.mangaServerId}'
      ..inLibrary = true;

    if (_chapters.isEmpty) {
      _chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleInLibrary() async {
    if (_manga == null) return;
    final newState = !_manga!.inLibrary;
    setState(() => _manga!.inLibrary = newState);
    await IsarService.instance.saveManga(_manga!);

    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.updateMangaLibraryState(widget.mangaServerId, newState);

        // If newly added to library and a default category is set, assign it!
        if (newState && SettingsService.instance.defaultCategoryId != null) {
          await GraphQLClientService.instance.updateMangaCategories(
            widget.mangaServerId,
            [SettingsService.instance.defaultCategoryId!],
          );
        }
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
                ? 'Added to library (${SettingsService.instance.defaultCategoryName})'
                : 'Removed from library',
          ),
        ),
      );
    }
  }

  void _openReader(int chapterServerId) {
    context.push('/reader/$chapterServerId');
  }

  void _continueReading() {
    if (_chapters.isEmpty) return;
    final unread = _chapters.firstWhere((c) => !c.isRead, orElse: () => _chapters.first);
    _openReader(unread.serverId);
  }

  void _toggleChapterRead(Chapter ch) async {
    final newState = !ch.isRead;
    setState(() {
      ch.isRead = newState;
      if (!newState) ch.lastPageRead = 0;
    });
    await IsarService.instance.saveChapter(ch);

    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterReadStatus(ch.serverId, newState, ch.lastPageRead);
    }
  }

  void _toggleChapterBookmark(Chapter ch) async {
    final newState = !ch.isBookmarked;
    setState(() => ch.isBookmarked = newState);
    await IsarService.instance.saveChapter(ch);

    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterBookmark(ch.serverId, newState);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'Bookmark added' : 'Bookmark removed')),
      );
    }
  }

  void _markPreviousChaptersRead(Chapter ch) async {
    final prevs = _chapters.where((c) => c.chapterNumber < ch.chapterNumber && !c.isRead).toList();
    for (final p in prevs) {
      p.isRead = true;
      if (GraphQLClientService.instance.isConfigured) {
        GraphQLClientService.instance.updateChapterReadStatus(p.serverId, true, p.lastPageRead);
      }
    }
    await IsarService.instance.saveChapters(prevs);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${prevs.length} previous chapters as read')),
      );
    }
  }

  // ── MULTI-CHAPTER SELECTION ACTIONS ────────────────────────
  void _enterSelectionMode(Chapter ch) {
    setState(() {
      _selectedChapterIds.add(ch.serverId);
    });
  }

  void _selectAllChapters() {
    setState(() {
      if (_selectedChapterIds.length == _chapters.length) {
        _selectedChapterIds.clear();
      } else {
        _selectedChapterIds.addAll(_chapters.map((c) => c.serverId));
      }
    });
  }

  void _markSelectedRead(bool read) async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    for (final c in targets) {
      c.isRead = read;
      if (!read) c.lastPageRead = 0;
      if (GraphQLClientService.instance.isConfigured) {
        GraphQLClientService.instance.updateChapterReadStatus(c.serverId, read, c.lastPageRead);
      }
    }
    await IsarService.instance.saveChapters(targets);
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marked ${targets.length} chapters as ${read ? "read" : "unread"}')),
      );
    }
  }

  void _downloadSelected(bool local) async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    if (local) {
      for (final c in targets) {
        await DownloadManagerService.instance.enqueueLocalDownload(
          chapterId: c.serverId,
          mangaId: widget.mangaServerId,
          chapterName: c.name,
          mangaTitle: _manga?.title ?? 'Manga',
        );
      }
    } else {
      final ids = targets.map((c) => c.serverId).toList();
      await DownloadManagerService.instance.enqueueServerDownloads(ids);
    }
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enqueued ${targets.length} chapters for ${local ? "device" : "server"} download')),
      );
    }
  }

  void _deleteSelectedDownloads() async {
    final targets = _chapters.where((c) => _selectedChapterIds.contains(c.serverId)).toList();
    for (final c in targets) {
      await DownloadManagerService.instance.deleteLocalDownload(c.serverId);
      await DownloadManagerService.instance.deleteServerDownload(c.serverId);
    }
    setState(() => _selectedChapterIds.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted downloads for ${targets.length} chapters')),
      );
    }
  }

  void _showBatchDownloadModal() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unreadChapters = _chapters.where((c) => !c.isRead).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Download Options (Mihon)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDownloadOptionTile('Next chapter', 1, unreadChapters, primaryColor),
              _buildDownloadOptionTile('Next 5 chapters', 5, unreadChapters, primaryColor),
              _buildDownloadOptionTile('Next 10 chapters', 10, unreadChapters, primaryColor),
              _buildDownloadOptionTile('All unread chapters (${unreadChapters.length})', unreadChapters.length, unreadChapters, primaryColor),
              _buildDownloadOptionTile('All chapters (${_chapters.length})', _chapters.length, _chapters, primaryColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadOptionTile(String title, int count, List<Chapter> sourceList, Color primaryColor) {
    return ListTile(
      leading: Icon(Icons.download_rounded, color: primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () async {
        Navigator.pop(context);
        final targets = sourceList.take(count).map((c) => c.serverId).toList();
        if (targets.isNotEmpty) {
          await DownloadManagerService.instance.enqueueServerDownloads(targets);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enqueued $count chapters for download')),
          );
        }
      },
    );
  }

  void _showSingleChapterOptions(Chapter ch) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final messenger = ScaffoldMessenger.of(context);
    final isDownloadedLocally = DownloadManagerService.instance.isChapterDownloadedLocally(ch.serverId);
    final isDownloadedOnServer = DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId) || ch.isDownloaded;

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
                leading: Icon(Icons.check_box_outlined, color: primaryColor),
                title: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _enterSelectionMode(ch);
                },
              ),
              ListTile(
                leading: Icon(ch.isBookmarked ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded, color: Colors.amber),
                title: Text(ch.isBookmarked ? 'Remove Bookmark' : 'Add Bookmark', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleChapterBookmark(ch);
                },
              ),
              ListTile(
                leading: Icon(ch.isRead ? Icons.mark_chat_unread_rounded : Icons.check_circle_rounded, color: primaryColor),
                title: Text(ch.isRead ? 'Mark as Unread' : 'Mark as Read', style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _toggleChapterRead(ch);
                },
              ),
              ListTile(
                leading: const Icon(Icons.done_all_rounded, color: Colors.grey),
                title: const Text('Mark Previous as Read', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _markPreviousChaptersRead(ch);
                },
              ),

              // Local Download option: Only show Download if not downloaded; show Delete if downloaded!
              if (!isDownloadedLocally)
                ListTile(
                  leading: Icon(Icons.phone_android_rounded, color: primaryColor),
                  title: const Text('Download to Local Device (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Save images to device for offline reading'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.enqueueLocalDownload(
                      chapterId: ch.serverId,
                      mangaId: widget.mangaServerId,
                      chapterName: ch.name,
                      mangaTitle: _manga?.title ?? 'Manga',
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text('Downloading ${ch.name} to device...')),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orangeAccent),
                  title: const Text('Delete from Local Device', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteLocalDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${ch.name} from local storage')),
                    );
                  },
                ),

              // Server Download option: Only show Download if not downloaded; show Delete if downloaded!
              if (!isDownloadedOnServer)
                ListTile(
                  leading: Icon(Icons.cloud_download_rounded, color: primaryColor),
                  title: const Text('Download to Server', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Queue download on Suwayomi server storage'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.enqueueServerDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Enqueued ${ch.name} on server')),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Download from Server', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await DownloadManagerService.instance.deleteServerDownload(ch.serverId);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Deleted ${ch.name} from server')),
                    );
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final manga = _manga!;
    final sortedChapters = List<Chapter>.from(_chapters);
    if (_sortAscending) {
      sortedChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    } else {
      sortedChapters.sort((a, b) => b.chapterNumber.compareTo(a.chapterNumber));
    }

    final isSelecting = _selectedChapterIds.isNotEmpty;

    return Scaffold(
      appBar: isSelecting
          ? AppBar(
              backgroundColor: const Color(0xFF1F1F24),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedChapterIds.clear()),
              ),
              title: Text('${_selectedChapterIds.length} Selected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Select / Deselect All',
                  onPressed: _selectAllChapters,
                ),
                IconButton(
                  icon: const Icon(Icons.done_all_rounded),
                  tooltip: 'Mark as Read',
                  onPressed: () => _markSelectedRead(true),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_done_rounded),
                  tooltip: 'Mark as Unread',
                  onPressed: () => _markSelectedRead(false),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (val) {
                    if (val == 'download_local') _downloadSelected(true);
                    if (val == 'download_server') _downloadSelected(false);
                    if (val == 'delete') _deleteSelectedDownloads();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'download_local', child: Text('Download to Device')),
                    PopupMenuItem(value: 'download_server', child: Text('Download to Server')),
                    PopupMenuItem(value: 'delete', child: Text('Delete Downloads', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // ── HERO BACKDROP HEADER ────────────────────────────────
          if (!isSelecting)
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: manga.inLibrary ? Colors.redAccent : Colors.white,
                  ),
                  onPressed: _toggleInLibrary,
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  tooltip: 'Download Chapters',
                  onPressed: _showBatchDownloadModal,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _loadMangaDetails,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (manga.thumbnailUrl != null && manga.thumbnailUrl!.isNotEmpty)
                      Image.network(
                        manga.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1F1F24)),
                      )
                    else
                      Container(color: const Color(0xFF1F1F24)),
                    // Gradient Vignette
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xCC000000),
                            Color(0x80000000),
                            Color(0xFF121216),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Title & Meta Overlay
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manga.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (manga.author != null && manga.author!.isNotEmpty)
                                Text(manga.author!, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                              if (manga.author != null && manga.author!.isNotEmpty)
                                const Text(' • ', style: TextStyle(color: Colors.white70)),
                              Text(manga.sourceName, style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── ACTIONS & SYNOPSIS SECTION ──────────────────────────
          if (!isSelecting)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interactive Action Buttons Row (In Library & Tracking)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: manga.inLibrary ? primaryColor.withAlpha(50) : primaryColor,
                              foregroundColor: manga.inLibrary ? primaryColor : Colors.white,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: manga.inLibrary ? BorderSide(color: primaryColor, width: 1.2) : null,
                            ),
                            onPressed: _toggleInLibrary,
                            icon: Icon(manga.inLibrary ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20),
                            label: Text(
                              manga.inLibrary ? 'IN LIBRARY' : 'ADD TO LIBRARY',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44),
                              side: const BorderSide(color: Color(0x33FFFFFF), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => TrackingBottomSheet.show(context, widget.mangaServerId, manga.title),
                            icon: const Icon(Icons.sync_alt_rounded, size: 20),
                            label: const Text('TRACKING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Continue Reading Action Pill
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0x33FFFFFF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _continueReading,
                      icon: Icon(Icons.play_arrow_rounded, color: primaryColor, size: 24),
                      label: const Text(
                        'Continue Reading',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Genre Tags
                    if (manga.genres.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: manga.genres.map((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x1F2A2A32),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                            ),
                            child: Text(g, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Expandable Synopsis
                    GestureDetector(
                      onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x1F2A2A32),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga.description ?? 'No synopsis available for this manga.',
                              maxLines: _isDescExpanded ? null : 3,
                              overflow: _isDescExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            if (manga.description != null && manga.description!.length > 100) ...[
                              const SizedBox(height: 6),
                              Text(
                                _isDescExpanded ? 'Show less' : 'Read more',
                                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Chapter List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sortedChapters.length} Chapters',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.checklist_rounded),
                              tooltip: 'Select Chapters',
                              onPressed: () {
                                if (sortedChapters.isNotEmpty) {
                                  _enterSelectionMode(sortedChapters.first);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_for_offline_rounded),
                              tooltip: 'Batch Download',
                              onPressed: _showBatchDownloadModal,
                            ),
                            IconButton(
                              icon: Icon(_sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: primaryColor),
                              onPressed: () => setState(() => _sortAscending = !_sortAscending),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ── CHAPTER LIST ────────────────────────────────────────
          if (sortedChapters.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No chapters found.', style: TextStyle(color: Colors.grey))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 120.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ch = sortedChapters[index];
                    final isSelected = _selectedChapterIds.contains(ch.serverId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Material(
                        color: isSelected ? primaryColor.withAlpha(30) : const Color(0x1F2A2A32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? primaryColor : const Color(0x1AFFFFFF),
                            width: isSelected ? 1.4 : 0.8,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onTap: () {
                            if (isSelecting) {
                              setState(() {
                                if (isSelected) {
                                  _selectedChapterIds.remove(ch.serverId);
                                } else {
                                  _selectedChapterIds.add(ch.serverId);
                                }
                              });
                            } else {
                              _openReader(ch.serverId);
                            }
                          },
                          onLongPress: () => _enterSelectionMode(ch),
                          leading: isSelecting
                              ? Checkbox(
                                  value: isSelected,
                                  activeColor: primaryColor,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedChapterIds.add(ch.serverId);
                                      } else {
                                        _selectedChapterIds.remove(ch.serverId);
                                      }
                                    });
                                  },
                                )
                              : ch.isBookmarked
                                  ? const Icon(Icons.bookmark_rounded, color: Colors.amber, size: 20)
                                  : null,
                          title: Text(
                            ch.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: ch.isRead ? Colors.grey : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Ch. ${ch.chapterNumber}${ch.lastPageRead > 0 ? " • Page ${ch.lastPageRead}" : ""}',
                            style: TextStyle(fontSize: 12, color: ch.isRead ? Colors.grey[600] : primaryColor),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (DownloadManagerService.instance.isChapterDownloadedLocally(ch.serverId))
                                const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(Icons.phone_android_rounded, color: Colors.greenAccent, size: 18),
                                ),
                              if (DownloadManagerService.instance.isChapterDownloadedOnServer(ch.serverId) || ch.isDownloaded)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(Icons.cloud_done_rounded, color: Colors.cyanAccent, size: 18),
                                ),
                              IconButton(
                                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
                                onPressed: () => _showSingleChapterOptions(ch),
                              ),
                              if (ch.isRead)
                                const Icon(Icons.check_circle_rounded, color: Colors.grey, size: 20)
                              else
                                Icon(Icons.play_circle_fill_rounded, color: primaryColor, size: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: sortedChapters.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
