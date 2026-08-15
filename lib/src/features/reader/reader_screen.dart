import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/sync/graphql_client_service.dart';

enum ReadingMode { webtoon, pagedLtr, pagedRtl }

class ReaderScreen extends StatefulWidget {
  final int chapterServerId;
  const ReaderScreen({super.key, required this.chapterServerId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  Chapter? _chapter;
  List<Chapter> _siblingChapters = [];
  List<String> _pageUrls = [];
  bool _isLoading = true;
  bool _showControls = true;
  int _currentPage = 1;
  ReadingMode _readingMode = ReadingMode.webtoon;

  final ScrollController _scrollController = ScrollController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onWebtoonScroll);
    _loadChapterAndPages(widget.chapterServerId);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onWebtoonScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterAndPages(int chapterId) async {
    setState(() {
      _isLoading = true;
      _pageUrls = [];
      _currentPage = 1;
    });

    _chapter = await IsarService.instance.getChapterByServerId(chapterId);

    if (_chapter != null) {
      _siblingChapters = await IsarService.instance.getChaptersForManga(_chapter!.mangaId);
      _siblingChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    }

    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // 1. Fetch real chapter pages from Suwayomi GraphQL
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final data = await GraphQLClientService.instance.fetchChapterPages(chapterId);
        if (data != null && data.containsKey('fetchChapterPages')) {
          final rawPages = data['fetchChapterPages']['pages'] as List<dynamic>?;
          if (rawPages != null && rawPages.isNotEmpty) {
            _pageUrls = rawPages.map((p) {
              final str = p.toString();
              return str.startsWith('http') ? str : '$serverUrl$str';
            }).toList();
          }
        }
      } catch (_) {}
    }

    // 2. Fallback placeholder pages if offline without connection
    if (_pageUrls.isEmpty) {
      _pageUrls = List.generate(
        12,
        (i) => 'https://via.placeholder.com/800x1200.png?text=Page+${i + 1}',
      );
    }

    // Restore last read page if available
    if (_chapter != null && _chapter!.lastPageRead > 0 && _chapter!.lastPageRead <= _pageUrls.length) {
      _currentPage = _chapter!.lastPageRead;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onWebtoonScroll() {
    if (_pageUrls.isEmpty || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (maxScroll <= 0) return;

    final pageRatio = (currentScroll / maxScroll).clamp(0.0, 1.0);
    final computedPage = ((pageRatio * (_pageUrls.length - 1)) + 1).round();

    if (computedPage != _currentPage) {
      setState(() => _currentPage = computedPage);
      _updateProgress(computedPage);
    }
  }

  void _onPageChanged(int index) {
    final page = index + 1;
    setState(() => _currentPage = page);
    _updateProgress(page);
  }

  void _updateProgress(int page) {
    if (_chapter == null) return;
    final isComplete = page >= _pageUrls.length;
    _chapter!.lastPageRead = page;
    if (isComplete) {
      _chapter!.isRead = true;
    }
    _chapter!.lastReadAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    IsarService.instance.saveChapter(_chapter!);

    // Sync with Suwayomi server
    if (GraphQLClientService.instance.isConfigured) {
      GraphQLClientService.instance.updateChapterReadStatus(_chapter!.serverId, _chapter!.isRead, page);
    }
  }

  void _navigateToSiblingChapter(bool next) {
    if (_chapter == null || _siblingChapters.isEmpty) return;
    final currentIndex = _siblingChapters.indexWhere((c) => c.serverId == _chapter!.serverId);
    if (currentIndex == -1) return;

    final targetIndex = next ? currentIndex + 1 : currentIndex - 1;
    if (targetIndex >= 0 && targetIndex < _siblingChapters.length) {
      final targetChapter = _siblingChapters[targetIndex];
      _loadChapterAndPages(targetChapter.serverId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next ? 'You are on the latest chapter' : 'You are on the first chapter')),
      );
    }
  }

  void _showReaderSettingsSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reader Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('READING MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  _buildModeOption(
                    title: 'Webtoon (Vertical Continuous)',
                    mode: ReadingMode.webtoon,
                    primaryColor: primaryColor,
                    onTap: () {
                      setState(() => _readingMode = ReadingMode.webtoon);
                      Navigator.pop(context);
                    },
                  ),
                  _buildModeOption(
                    title: 'Paged Left-to-Right (LTR)',
                    mode: ReadingMode.pagedLtr,
                    primaryColor: primaryColor,
                    onTap: () {
                      setState(() => _readingMode = ReadingMode.pagedLtr);
                      Navigator.pop(context);
                    },
                  ),
                  _buildModeOption(
                    title: 'Paged Right-to-Left (RTL Manga)',
                    mode: ReadingMode.pagedRtl,
                    primaryColor: primaryColor,
                    onTap: () {
                      setState(() => _readingMode = ReadingMode.pagedRtl);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModeOption({
    required String title,
    required ReadingMode mode,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    final isSelected = _readingMode == mode;
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? primaryColor : Colors.white)),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primaryColor) : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // ── READER CANVAS ─────────────────────────────────────
            if (_readingMode == ReadingMode.webtoon)
              ListView.builder(
                controller: _scrollController,
                itemCount: _pageUrls.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Image.network(
                      _pageUrls[index],
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 400,
                          color: const Color(0xFF121216),
                          child: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 300,
                        color: const Color(0xFF1A1A22),
                        child: Center(
                          child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              PageView.builder(
                controller: _pageController,
                reverse: _readingMode == ReadingMode.pagedRtl,
                itemCount: _pageUrls.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Center(
                      child: Image.network(
                        _pageUrls[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2));
                        },
                        errorBuilder: (_, __, ___) => Center(
                          child: Text('Page ${index + 1} Failed to Load', style: const TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // ── OVERLAY CONTROLS (TOP & BOTTOM BARS) ───────────────
            if (_showControls) ...[
              // Top Bar Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _chapter?.name ?? 'Reader',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${_readingMode.name.toUpperCase()} MODE',
                              style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.white),
                        onPressed: _showReaderSettingsSheet,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom HUD Controls
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xE61F1F24),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                          tooltip: 'Previous Chapter',
                          onPressed: () => _navigateToSiblingChapter(false),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Page $_currentPage / ${_pageUrls.length}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                          tooltip: 'Next Chapter',
                          onPressed: () => _navigateToSiblingChapter(true),
                        ),
                      ],
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
