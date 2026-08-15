import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/db/models/manga.dart';
import '../../core/sync/sync_engine.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedCategoryIndex = 0;
  List<Manga> _allManga = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  String _sortBy = 'Title';

  @override
  void initState() {
    super.initState();
    _loadLibraryAndCategories();
  }

  Future<void> _loadLibraryAndCategories() async {
    var list = await IsarService.instance.getLibraryManga();
    var cats = await IsarService.instance.getCategories();

    if (list.isEmpty) {
      // Trigger sync if local DB is empty
      await SyncEngine.instance.triggerSync();
      list = await IsarService.instance.getLibraryManga();
      cats = await IsarService.instance.getCategories();
    }

    if (mounted) {
      setState(() {
        _allManga = list;
        _categories = cats;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await SyncEngine.instance.triggerSync();
    final list = await IsarService.instance.getLibraryManga();
    final cats = await IsarService.instance.getCategories();
    if (mounted) {
      setState(() {
        _allManga = list;
        _categories = cats;
      });
    }
  }

  List<Manga> get _filteredManga {
    var list = List<Manga>.from(_allManga);

    // 1. Filter by category
    if (_selectedCategoryIndex > 0 && _selectedCategoryIndex <= _categories.length) {
      final selectedCatId = _categories[_selectedCategoryIndex - 1].serverId;
      list = list.where((m) => m.categoryIds.contains(selectedCatId)).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((m) => m.title.toLowerCase().contains(q)).toList();
    }

    // 3. Sort
    if (_sortBy == 'Title') {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortBy == 'Unread') {
      list.sort((a, b) => (b.unreadCount ?? 0).compareTo(a.unreadCount ?? 0));
    } else if (_sortBy == 'Recent') {
      list.sort((a, b) => (b.inLibraryAt ?? 0).compareTo(a.inLibraryAt ?? 0));
    }

    return list;
  }

  void _showSortDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
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
              const Text('Sort Library By', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Title (A-Z)'),
                trailing: _sortBy == 'Title' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                onTap: () {
                  setState(() => _sortBy = 'Title');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Unread Count'),
                trailing: _sortBy == 'Unread' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                onTap: () {
                  setState(() => _sortBy = 'Unread');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Recently Added'),
                trailing: _sortBy == 'Recent' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                onTap: () {
                  setState(() => _sortBy = 'Recent');
                  Navigator.pop(context);
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
    final displayManga = _filteredManga;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  slivers: [
                    // Top App Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            if (_isSearching)
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Search library...',
                                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: () => setState(() {
                                        _isSearching = false;
                                        _searchQuery = '';
                                      }),
                                    ),
                                    filled: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                ),
                              )
                            else ...[
                              const Text(
                                'Sunfire',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.search_rounded, size: 26),
                                onPressed: () => setState(() => _isSearching = true),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list_rounded, size: 26),
                                onPressed: _showSortDialog,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Hero Showcase Banner (Currently Reading)
                    if (_allManga.isNotEmpty && !_isSearching)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: _buildHeroBanner(_allManga.first),
                        ),
                      ),

                    // Category Pill Selector
                    SliverToBoxAdapter(
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length + 1,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedCategoryIndex == index;
                            final label = index == 0 ? 'All' : _categories[index - 1].name;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                selectedColor: primaryColor,
                                backgroundColor: const Color(0x1F2A2A32),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? primaryColor : const Color(0x2BFFFFFF),
                                    width: 0.8,
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedCategoryIndex = index);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Manga Grid View
                    if (displayManga.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_stories_outlined, size: 64, color: primaryColor.withAlpha(120)),
                              const SizedBox(height: 16),
                              const Text('No manga found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Pull down to sync or browse to add titles.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildMangaCard(displayManga[index]),
                            childCount: displayManga.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeroBanner(Manga manga) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => context.push('/manga/${manga.serverId}'),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              primaryColor.withAlpha(50),
              const Color(0x1F2A2A32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: manga.thumbnailUrl != null && manga.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      manga.thumbnailUrl!,
                      width: 80,
                      height: 106,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 106,
                        color: Colors.grey[800],
                        child: Icon(Icons.book_rounded, color: primaryColor),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 106,
                      color: Colors.grey[800],
                      child: Icon(Icons.book_rounded, color: primaryColor),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('CURRENTLY READING', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${manga.unreadCount ?? 0} unread chapters', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: const Color(0x33FFFFFF),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 6,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMangaCard(Manga manga) {
    return GestureDetector(
      onTap: () => context.push('/manga/${manga.serverId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1F1F24),
                    border: Border.all(color: const Color(0x1AFFFFFF), width: 0.8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: manga.thumbnailUrl != null && manga.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            manga.thumbnailUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.book_rounded, color: Colors.grey)),
                          )
                        : const Center(child: Icon(Icons.book_rounded, color: Colors.grey)),
                  ),
                ),
                if (manga.unreadCount != null && manga.unreadCount! > 0)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                      ),
                      child: Text(
                        '${manga.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            manga.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
