import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

class ReaderScreen extends StatefulWidget {
  final int chapterServerId;
  const ReaderScreen({super.key, required this.chapterServerId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  Chapter? _chapter;
  List<String> _pageUrls = [];
  bool _isLoading = true;
  bool _showControls = true;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChapterPages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageUrls.isEmpty) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final pageRatio = (currentScroll / maxScroll).clamp(0.0, 1.0);
    final computedPage = ((pageRatio * (_pageUrls.length - 1)) + 1).round();

    if (computedPage != _currentPage) {
      setState(() => _currentPage = computedPage);
      _updateProgressDebounced(computedPage);
    }
  }

  void _updateProgressDebounced(int page) {
    if (_chapter == null) return;
    _chapter!.lastPageRead = page;
    if (page >= _pageUrls.length) {
      _chapter!.isRead = true;
      _chapter!.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    IsarService.instance.saveChapter(_chapter!);
    SyncEngine.instance.triggerSync();
  }

  Future<void> _loadChapterPages() async {
    _chapter = await IsarService.instance.getChapterByServerId(widget.chapterServerId);

    if (GraphQLClientService.instance.isConfigured) {
      const mutationStr = r'''
        mutation($chapterId: Int!) {
          fetchChapterPages(input: { chapterId: $chapterId }) {
            pages
          }
        }
      ''';
      final data = await GraphQLClientService.instance.query(mutationStr, variables: {'chapterId': widget.chapterServerId}, label: 'fetchChapterPages');

      if (data != null && data.containsKey('fetchChapterPages')) {
        final rawPages = data['fetchChapterPages']['pages'] as List<dynamic>?;
        if (rawPages != null) {
          final serverUrl = GraphQLClientService.instance.baseUrl;
          _pageUrls = rawPages.map((p) => '$serverUrl$p').toList();
        }
      }
    }

    // Fallback placeholder pages if offline without cache
    if (_pageUrls.isEmpty) {
      _pageUrls = List.generate(15, (i) => 'https://via.placeholder.com/800x1200.png?text=Page+${i + 1}');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
          : GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Stack(
                children: [
                  // Continuous Webtoon Scroll Reader
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _pageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _pageUrls[index],
                        fit: BoxFit.fitWidth,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 400,
                            color: const Color(0xFF121216),
                            child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722), strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 300,
                          color: const Color(0xFF1A1A22),
                          child: Center(child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey))),
                        ),
                      );
                    },
                  ),

                  // Floating Controls Overlay (Top App Bar & Minimal HUD)
                  if (_showControls) ...[
                    // Top App Bar Overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xCC000000), Colors.transparent],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            Expanded(
                              child: Text(
                                _chapter?.name ?? 'Reader',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.settings_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    // Minimal Bottom Translucent HUD Pill
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xCC000000),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                          ),
                          child: Text(
                            'Page $_currentPage / ${_pageUrls.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
