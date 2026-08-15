import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/sync/graphql_client_service.dart';

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
  bool _isDescExpanded = false;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadMangaDetails();
  }

  Future<void> _loadMangaDetails() async {
    setState(() => _isLoading = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // 1. Check local Isar DB first
    _manga = await IsarService.instance.getMangaByServerId(widget.mangaServerId);

    // 2. Fetch fresh details from Suwayomi GraphQL
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final detailsData = await GraphQLClientService.instance.fetchMangaDetails(widget.mangaServerId);
        if (detailsData != null && detailsData.containsKey('manga')) {
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
        }

        // Fetch fresh chapters
        final chData = await GraphQLClientService.instance.fetchChaptersForManga(widget.mangaServerId);
        if (chData != null && chData.containsKey('chapters')) {
          final chNodes = chData['chapters']['nodes'] as List<dynamic>;
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
          if (fetched.isNotEmpty) {
            await IsarService.instance.saveChapters(fetched);
            _chapters = fetched;
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
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'Added to library' : 'Removed from library')),
      );
    }
  }

  void _openReader(int chapterServerId) {
    context.push('/reader/$chapterServerId');
  }

  void _continueReading() {
    if (_chapters.isEmpty) return;
    // Find first unread or first chapter
    final unread = _chapters.firstWhere((c) => !c.isRead, orElse: () => _chapters.first);
    _openReader(unread.serverId);
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── HERO BACKDROP HEADER ────────────────────────────────
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
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          manga.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          manga.author?.isNotEmpty == true ? manga.author! : (manga.sourceName.isNotEmpty ? manga.sourceName : 'Unknown Author'),
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        if (manga.status != null && manga.status!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: primaryColor.withAlpha(120), width: 0.8),
                            ),
                            child: Text(
                              manga.status!.toUpperCase(),
                              style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── ACTION BUTTON & SYNOPSIS ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue Reading Action Pill
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: _continueReading,
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    label: const Text(
                      'Continue Reading',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                            (manga.description != null && manga.description!.trim().isNotEmpty)
                                ? manga.description!.trim()
                                : 'No synopsis available for this manga.',
                            maxLines: _isDescExpanded ? null : 3,
                            overflow: _isDescExpanded ? null : TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                          ),
                          if (manga.description != null && manga.description!.trim().length > 120) ...[
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

                  const SizedBox(height: 20),

                  // Chapter Header & Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_chapters.length} Chapters',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: primaryColor),
                        onPressed: () => setState(() => _sortAscending = !_sortAscending),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Material(
                        color: const Color(0x1F2A2A32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0x1AFFFFFF), width: 0.8),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          onTap: () => _openReader(ch.serverId),
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
