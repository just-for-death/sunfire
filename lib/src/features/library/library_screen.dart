import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/db/models/manga.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../main_shell.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final SettingsService _settings = SettingsService.instance;
  int _selectedCategoryIndex = 0;
  List<Manga> _allManga = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String _sortBy = 'Title';
  bool _isSortAscending = true;

  // Offline banner state
  bool _isOffline = false;
  bool _isSyncing = false;

  // Multi-select batch mode
  bool _isBatchMode = false;
  final Set<int> _selectedMangaIds = {};

  @override
  void initState() {
    super.initState();
    _loadFromIsarThenSync();
  }

  /// Load Isar immediately (never blocks on network). Then attempt a background
  /// sync to update. This guarantees the library is visible instantly even when
  /// the server is down, wiped, or unreachable.
  Future<void> _loadFromIsarThenSync() async {
    try {
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // 2. Background sync (silent — only if server is configured)
    if (GraphQLClientService.instance.isConfigured) {
      _backgroundSync();
    }
  }

  Future<void> _loadFromIsarOnly() async {
    try {
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
        });
      }
    } catch (_) {}
  }

  Future<void> _backgroundSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await SyncEngine.instance.triggerSync().timeout(
        const Duration(seconds: 30),
        onTimeout: () {},
      );
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isSyncing = true);
    try {
      await SyncEngine.instance.triggerSync();
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      if (mounted) {
        setState(() {
          _allManga = list;
          _categories = cats;
          _isOffline = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  List<Manga> get _filteredManga {
    var list = List<Manga>.from(_allManga);

    // 1. Category Filter
    if (_selectedCategoryIndex > 0 && _selectedCategoryIndex <= _categories.length) {
      final selectedCatId = _categories[_selectedCategoryIndex - 1].serverId;
      list = list.where((m) => m.categoryIds.contains(selectedCatId)).toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((m) => m.title.toLowerCase().contains(q)).toList();
    }

    // 3. Sorting
    list.sort((a, b) {
      int cmp = 0;
      if (_sortBy == 'Title') {
        cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        return _isSortAscending ? cmp : -cmp;
      } else if (_sortBy == 'Unread') {
        cmp = (b.unreadCount ?? 0).compareTo(a.unreadCount ?? 0);
        return _isSortAscending ? cmp : -cmp;
      } else if (_sortBy == 'Recent') {
        cmp = (b.inLibraryAt ?? 0).compareTo(a.inLibraryAt ?? 0);
        return _isSortAscending ? cmp : -cmp;
      }
      return cmp;
    });

    return list;
  }

  void _toggleBatchSelection(int mangaServerId) {
    setState(() {
      if (_selectedMangaIds.contains(mangaServerId)) {
        _selectedMangaIds.remove(mangaServerId);
        if (_selectedMangaIds.isEmpty) _isBatchMode = false;
      } else {
        _selectedMangaIds.add(mangaServerId);
        _isBatchMode = true;
      }
    });
  }

  void _selectAll() {
    final currentList = _filteredManga;
    setState(() {
      if (_selectedMangaIds.length == currentList.length) {
        _selectedMangaIds.clear();
        _isBatchMode = false;
      } else {
        _selectedMangaIds.addAll(currentList.map((m) => m.serverId));
        _isBatchMode = true;
      }
    });
  }

  Future<void> _batchRemoveFromLibrary() async {
    final count = _selectedMangaIds.length;
    for (final id in _selectedMangaIds) {
      final m = await IsarService.instance.getMangaByServerId(id);
      if (m != null) {
        m.inLibrary = false;
        await IsarService.instance.saveManga(m);
        if (GraphQLClientService.instance.isConfigured) {
          GraphQLClientService.instance.updateMangaLibraryState(id, false);
        }
      }
    }
    setState(() {
      _selectedMangaIds.clear();
      _isBatchMode = false;
    });
    await _handleRefresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed $count titles from library')),
      );
    }
  }

  void _showCategoryManagementDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Edit Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'New category name...',
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        onPressed: () async {
                          final name = textController.text.trim();
                          if (name.isNotEmpty) {
                            if (GraphQLClientService.instance.isConfigured) {
                              await GraphQLClientService.instance.createCategory(name);
                            }
                            textController.clear();
                            await _handleRefresh();
                            setSheetState(() {});
                          }
                        },
                        child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return ListTile(
                          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () async {
                              if (GraphQLClientService.instance.isConfigured) {
                                await GraphQLClientService.instance.deleteCategory(cat.serverId);
                              }
                              await _handleRefresh();
                              setSheetState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortAndDisplayDialog() {
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
                  const Text('Library View & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('DISPLAY MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Comfortable Grid', 'Compact Grid', 'List'].map((mode) {
                      final isSel = _settings.libraryDisplayMode == mode;
                      return ChoiceChip(
                        label: Text(mode),
                        selected: isSel,
                        selectedColor: primaryColor,
                        backgroundColor: const Color(0x1F2A2A32),
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isSel ? primaryColor : const Color(0x2BFFFFFF), width: 0.8)),
                        onSelected: (_) {
                          setState(() => _settings.libraryDisplayMode = mode);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SORT BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                      IconButton(
                        icon: Icon(_isSortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 20, color: primaryColor),
                        onPressed: () {
                          setState(() => _isSortAscending = !_isSortAscending);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayManga = _filteredManga;
    final displayMode = _settings.libraryDisplayMode;
    final isCompact = displayMode == 'Compact Grid';
    final targetWidth = isCompact ? 110.0 : 145.0;

    return Scaffold(
      appBar: AppBar(
        title: _isBatchMode
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _selectedMangaIds.clear();
                      _isBatchMode = false;
                    }),
                  ),
                  Text('${_selectedMangaIds.length} Selected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectAll,
                    child: Text(_selectedMangaIds.length == displayManga.length ? 'Deselect All' : 'Select All', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            : _isSearching
                ? TextField(
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
                  )
                : const Text('Sunfire', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: _isBatchMode
            ? null
            : [
                if (_isSyncing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                if (!_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.search_rounded, size: 26),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 26),
                    onPressed: _showSortAndDisplayDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.label_outline_rounded, size: 26),
                    tooltip: 'Categories',
                    onPressed: _showCategoryManagementDialog,
                  ),
                ],
              ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                final label = index == 0 ? 'All (${_allManga.length})' : _categories[index - 1].name;
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
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _handleRefresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : displayManga.isEmpty
            ? CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                scrollCacheExtent: ScrollCacheExtent.pixels(800),
                slivers: [
                  if (_isOffline)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withAlpha(80), width: 0.8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Offline — Showing cached library',
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_stories_outlined, size: 64, color: primaryColor.withAlpha(120)),
                            const SizedBox(height: 16),
                            const Text('Library is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text(
                              'Browse to add manga or pull down\nto sync with your server.',
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
                              icon: const Icon(Icons.explore_outlined, color: Colors.white, size: 18),
                              label: const Text('Browse Sources', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              onPressed: () => MainShell.switchToTab(3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                scrollCacheExtent: ScrollCacheExtent.pixels(1500),
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  if (_isOffline)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withAlpha(80), width: 0.8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Offline — Showing cached library',
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (displayManga.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        icon: Icons.auto_stories_rounded,
                        title: _searchQuery.isNotEmpty ? 'No Results Found' : 'Your Library is Empty',
                        subtitle: _searchQuery.isNotEmpty 
                           ? 'Try adjusting your search query.'
                           : 'Browse extensions to find and add manga to your library.',
                        actionLabel: _searchQuery.isNotEmpty ? 'Clear Search' : 'Browse Sources',
                        onAction: () {
                          if (_searchQuery.isNotEmpty) {
                            setState(() {
                              _searchQuery = '';
                              _isSearching = false;
                            });
                          } else {
                            context.go('/browse');
                          }
                        },
                      ),
                    )
                  else if (displayMode == 'List')
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMangaListItem(displayManga[index]),
                          childCount: displayManga.length,
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                          addSemanticIndexes: false,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: targetWidth + 40,
                          childAspectRatio: isCompact ? 0.70 : 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMangaCard(displayManga[index], isCompact: isCompact),
                          childCount: displayManga.length,
                          addAutomaticKeepAlives: true,
                          addRepaintBoundaries: true,
                          addSemanticIndexes: false,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: _isBatchMode
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(color: Color(0xFF1F1F24), border: Border(top: BorderSide(color: Color(0x2BFFFFFF)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Remove from Library',
                    onPressed: _batchRemoveFromLibrary,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildMangaCard(Manga manga, {bool isCompact = false}) {
    final isSelected = _selectedMangaIds.contains(manga.serverId);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () async {
        if (_isBatchMode) {
          _toggleBatchSelection(manga.serverId);
        } else {
          await context.push('/manga/${manga.serverId}');
          if (mounted) {
            await _loadFromIsarOnly();
          }
        }
      },
      onLongPress: () => _toggleBatchSelection(manga.serverId),
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
                    border: Border.all(
                      color: isSelected ? primaryColor : const Color(0x1AFFFFFF),
                      width: isSelected ? 2.5 : 0.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MangaCoverImage(
                      mangaServerId: manga.serverId,
                      thumbnailUrl: manga.thumbnailUrl,
                      sourceName: manga.sourceName,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                if (manga.unreadCount != null && manga.unreadCount! > 0 && !isSelected)
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
          if (!isCompact) ...[
            const SizedBox(height: 6),
            Text(
              manga.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ],
      ),
    ),
  );
  }

  Widget _buildMangaListItem(Manga manga) {
    final isSelected = _selectedMangaIds.contains(manga.serverId);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
        color: isSelected ? primaryColor.withAlpha(40) : const Color(0x1F2A2A32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isSelected ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
        ),
        child: ListTile(
          onTap: () async {
            if (_isBatchMode) {
              _toggleBatchSelection(manga.serverId);
            } else {
              await context.push('/manga/${manga.serverId}');
              if (mounted) {
                await _loadFromIsarOnly();
              }
            }
          },
          onLongPress: () => _toggleBatchSelection(manga.serverId),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MangaCoverImage(
              mangaServerId: manga.serverId,
              thumbnailUrl: manga.thumbnailUrl,
              sourceName: manga.sourceName,
              width: 40,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(manga.sourceName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          trailing: manga.unreadCount != null && manga.unreadCount! > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10)),
                  child: Text('${manga.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              : null,
        ),
      ),
    ),
  );
}
}
