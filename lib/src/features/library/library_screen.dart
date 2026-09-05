import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/services/download_manager_service.dart';
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
  String _statusFilter = 'All'; // 'All', 'Unread', 'Downloaded', 'Completed'

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
    MainShell.selectedTabNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (MainShell.selectedTabNotifier.value == 0 && mounted) {
      _loadFromIsarOnly();
    }
  }

  @override
  void dispose() {
    MainShell.selectedTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  /// Load Isar immediately (never blocks on network). Then attempt a background
  /// sync to update. This guarantees the library is visible instantly even when
  /// the server is down, wiped, or unreachable.
  Future<void> _loadFromIsarThenSync() async {
    try {
      final list = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();

      // Proactive self-healing: resolve direct CDN covers for any manga pointing to server proxy
      bool hasHealed = false;
      for (final m in list) {
        if (m.thumbnailUrl == null || m.thumbnailUrl!.isEmpty || m.thumbnailUrl!.contains('/api/v1/manga/')) {
          if (m.sourceName.isNotEmpty && m.url.isNotEmpty) {
            final direct = QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
            if (direct != null && direct.isNotEmpty) {
              m.thumbnailUrl = direct;
              hasHealed = true;
            }
          }
        }
      }
      if (hasHealed) {
        await IsarService.instance.saveMangas(list);
      }

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

      bool hasHealed = false;
      for (final m in list) {
        if (m.thumbnailUrl == null || m.thumbnailUrl!.isEmpty || m.thumbnailUrl!.contains('/api/v1/manga/')) {
          if (m.sourceName.isNotEmpty && m.url.isNotEmpty) {
            final direct = QuickJsService.instance.getExtensionCoverUrl(m.sourceName, m.url);
            if (direct != null && direct.isNotEmpty) {
              m.thumbnailUrl = direct;
              hasHealed = true;
            }
          }
        }
      }
      if (hasHealed) {
        await IsarService.instance.saveMangas(list);
      }

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
      if (GraphQLClientService.instance.isConfigured) {
        await SyncEngine.instance.triggerSync();
      } else {
        // Standalone mode: check local JS extensions for new chapters across library titles
        await _checkStandaloneUpdates();
      }
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

  Future<void> _checkStandaloneUpdates() async {
    final libraryManga = await IsarService.instance.getLibraryManga();
    for (final manga in libraryManga) {
      if (manga.sourceName.isEmpty || manga.url.isEmpty) continue;
      try {
        final detail = await QuickJsService.instance.fetchMangaDetailsLocal(
          manga.sourceName,
          manga.url,
        );
        if (detail.containsKey('chapters')) {
          final rawChapters = detail['chapters'] as List<dynamic>?;
          if (rawChapters != null && rawChapters.isNotEmpty) {
            final existingChapters = await IsarService.instance.getChaptersForManga(manga.serverId);
            final existingUrls = existingChapters.map((c) => c.url).toSet();
            final newChapters = <Chapter>[];
            for (int i = 0; i < rawChapters.length; i++) {
              final chMap = rawChapters[i] as Map<String, dynamic>;
              final chUrl = chMap['url']?.toString() ?? '';
              if (chUrl.isNotEmpty && !existingUrls.contains(chUrl)) {
                final ch = Chapter()
                  ..serverId = manga.serverId * 10000 + i + 1
                  ..mangaId = manga.serverId
                  ..name = chMap['name']?.toString() ?? 'Chapter ${i + 1}'
                  ..chapterNumber = (chMap['chapterNumber'] as num?)?.toDouble() ?? (i + 1).toDouble()
                  ..url = chUrl
                  ..realUrl = chUrl
                  ..fetchedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000
                  ..isRead = false
                  ..lastPageRead = 0;
                newChapters.add(ch);
              }
            }
            if (newChapters.isNotEmpty) {
              await IsarService.instance.saveChapters(newChapters);
              manga.unreadCount = (manga.unreadCount ?? 0) + newChapters.length;
              await IsarService.instance.saveManga(manga);
            }
          }
        }
      } catch (_) {}
    }
  }

  List<Manga> get _filteredManga {
    var list = List<Manga>.from(_allManga);

    // 0. Status Filter
    if (_statusFilter == 'Unread') {
      list = list.where((m) => (m.unreadCount ?? 0) > 0).toList();
    } else if (_statusFilter == 'Downloaded') {
      final downloadedMangaIds = DownloadManagerService.instance.downloadedMangaIds;
      list = list.where((m) => downloadedMangaIds.contains(m.serverId)).toList();
    } else if (_statusFilter == 'Completed') {
      list = list.where((m) => (m.status ?? '').toLowerCase() == 'completed').toList();
    }

    // 1. Category Filter
    if (_settings.showCategoryTabs && _selectedCategoryIndex > 0 && _selectedCategoryIndex <= _categories.length) {
      final selectedCatId = _categories[_selectedCategoryIndex - 1].serverId;
      list = list.where((m) => m.categoryIds.contains(selectedCatId)).toList();
    }

    // 2. Smart Search Query Filter (Mihon / Mangayomi Tokens)
    if (_searchQuery.trim().isNotEmpty) {
      final downloadedMangaIds = DownloadManagerService.instance.downloadedMangaIds;
      final tokens = _searchQuery.trim().toLowerCase().split(RegExp(r'\s+'));
      
      list = list.where((m) {
        final title = m.title.toLowerCase();
        final source = m.sourceName.toLowerCase();
        final author = (m.author ?? '').toLowerCase();
        final artist = (m.artist ?? '').toLowerCase();
        final genres = m.genres.map((g) => g.toLowerCase()).toList();
        final status = (m.status ?? '').toLowerCase();
        final isDownloaded = downloadedMangaIds.contains(m.serverId);

        for (final token in tokens) {
          if (token.isEmpty) continue;
          if (token.startsWith('tag:') || token.startsWith('genre:')) {
            final val = token.substring(token.indexOf(':') + 1);
            if (!genres.any((g) => g.contains(val))) return false;
          } else if (token.startsWith('src:') || token.startsWith('source:')) {
            final val = token.substring(token.indexOf(':') + 1);
            if (!source.contains(val)) return false;
          } else if (token.startsWith('author:')) {
            final val = token.substring(7);
            if (!author.contains(val)) return false;
          } else if (token.startsWith('artist:')) {
            final val = token.substring(7);
            if (!artist.contains(val)) return false;
          } else if (token.startsWith('status:')) {
            final val = token.substring(7);
            if (!status.contains(val)) return false;
          } else if (token == 'unread:true' || token == 'unread:yes') {
            if ((m.unreadCount ?? 0) <= 0) return false;
          } else if (token == 'downloaded:true' || token == 'downloaded:yes') {
            if (!isDownloaded) return false;
          } else {
            // Default keyword search matches title, author, or source
            if (!title.contains(token) && !source.contains(token) && !author.contains(token)) {
              return false;
            }
          }
        }
        return true;
      }).toList();
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
      } else if (_sortBy == 'Chapters') {
        cmp = b.chapterCount.compareTo(a.chapterCount);
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

  Future<void> _batchMoveToCategory() async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    int? selectedCatId;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetBuilderContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Move to Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No categories created yet. Tap "Edit Categories" to create one.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ..._categories.map((cat) {
                      final isSel = selectedCatId == cat.serverId;
                      return ListTile(
                        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: isSel ? Icon(Icons.check_circle_rounded, color: primaryColor) : const Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey),
                        onTap: () {
                          setSheetState(() => selectedCatId = cat.serverId);
                        },
                      );
                    }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: selectedCatId == null
                        ? null
                        : () async {
                            for (final id in _selectedMangaIds) {
                              final m = await IsarService.instance.getMangaByServerId(id);
                              if (m != null) {
                                m.categoryIds = [selectedCatId!];
                                await IsarService.instance.saveManga(m);
                                if (GraphQLClientService.instance.isConfigured) {
                                  await GraphQLClientService.instance.updateMangaCategories(id, [selectedCatId!]);
                                }
                              }
                            }
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                            if (!mounted) return;
                            setState(() {
                              _selectedMangaIds.clear();
                              _isBatchMode = false;
                            });
                            await _loadFromIsarOnly();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Category updated for selected titles')),
                              );
                            }
                          },
                    child: const Text('Move', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _batchMarkRead(bool isRead) async {
    for (final id in _selectedMangaIds) {
      final chapters = await IsarService.instance.getChaptersForManga(id);
      for (final ch in chapters) {
        ch.isRead = isRead;
      }
      await IsarService.instance.saveChapters(chapters);
      final m = await IsarService.instance.getMangaByServerId(id);
      if (m != null) {
        m.unreadCount = isRead ? 0 : chapters.length;
        await IsarService.instance.saveManga(m);
      }
    }
    setState(() {
      _selectedMangaIds.clear();
      _isBatchMode = false;
    });
    await _loadFromIsarOnly();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isRead ? 'Marked all as read' : 'Marked all as unread')),
      );
    }
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
                            final newCat = Category()
                              ..serverId = DateTime.now().millisecondsSinceEpoch
                              ..name = name
                              ..order = _categories.length;
                            await IsarService.instance.saveCategories([newCat]);
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
                              await IsarService.instance.deleteCategory(cat.serverId);
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

  int _getCategoryMangaCount(int catServerId) {
    return _allManga.where((m) => m.categoryIds.contains(catServerId)).length;
  }

  void _showSortAndDisplayDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text('Library View & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('DISPLAY MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Comfortable Grid', 'Compact Grid', 'Cover Only', 'List'].map((mode) {
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
                    const Text('GRID COLUMNS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'label': 'Auto', 'val': 0},
                        {'label': '2', 'val': 2},
                        {'label': '3', 'val': 3},
                        {'label': '4', 'val': 4},
                        {'label': '5', 'val': 5},
                        {'label': '6', 'val': 6},
                      ].map((item) {
                        final isSel = _settings.gridColumnCount == (item['val'] as int);
                        return ChoiceChip(
                          label: Text(item['label'] as String),
                          selected: isSel,
                          selectedColor: primaryColor,
                          backgroundColor: const Color(0x1F2A2A32),
                          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isSel ? primaryColor : const Color(0x2BFFFFFF), width: 0.8)),
                          onSelected: (_) {
                            setState(() => _settings.gridColumnCount = item['val'] as int);
                            setSheetState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('BADGES & INDICATORS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Unread Count'),
                          selected: _settings.showUnreadBadges,
                          selectedColor: primaryColor.withAlpha(80),
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _settings.showUnreadBadges = val);
                            setSheetState(() {});
                          },
                        ),
                        FilterChip(
                          label: const Text('Downloaded Check'),
                          selected: _settings.showDownloadedBadges,
                          selectedColor: primaryColor.withAlpha(80),
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setState(() => _settings.showDownloadedBadges = val);
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('FILTER BY STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Unread', 'Downloaded', 'Completed'].map((filter) {
                        final isSel = _statusFilter == filter;
                        return ChoiceChip(
                          label: Text(filter),
                          selected: isSel,
                          selectedColor: primaryColor,
                          backgroundColor: const Color(0x1F2A2A32),
                          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.grey, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isSel ? primaryColor : const Color(0x2BFFFFFF), width: 0.8)),
                          onSelected: (_) {
                            setState(() => _statusFilter = filter);
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
                      title: const Text('Title (Alphabetical)'),
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
                    ListTile(
                      title: const Text('Total Chapters'),
                      trailing: _sortBy == 'Chapters' ? Icon(Icons.check_rounded, color: primaryColor) : null,
                      onTap: () {
                        setState(() => _sortBy = 'Chapters');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
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
    final isCoverOnly = displayMode == 'Cover Only';
    final isCompact = displayMode == 'Compact Grid';
    final isList = displayMode == 'List';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 720;
    final bottomPadding = isTablet ? 36.0 : 120.0;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    
    final columnsSetting = _settings.gridColumnCount;
    final int crossAxisCount = columnsSetting > 0
        ? columnsSetting
        : (isTablet ? (screenWidth ~/ 160).clamp(3, 7) : (screenWidth ~/ 120).clamp(2, 4));
    final childAspectRatio = isCoverOnly ? 0.70 : (isCompact ? 0.70 : 0.65);

    return PopScope(
      canPop: !_isBatchMode && !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isBatchMode) {
          setState(() {
            _selectedMangaIds.clear();
            _isBatchMode = false;
          });
        } else if (_isSearching) {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
          });
        }
      },
      child: Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
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
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.tune_rounded, size: 26),
                        if (_statusFilter != 'All' || _settings.gridColumnCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    tooltip: 'Filter & Display',
                    onPressed: _showSortAndDisplayDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.label_outline_rounded, size: 26),
                    tooltip: 'Categories',
                    onPressed: _showCategoryManagementDialog,
                  ),
                ],
              ],
        bottom: !_settings.showCategoryTabs || _categories.isEmpty
            ? null
            : PreferredSize(
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
                final count = index == 0 ? _allManga.length : _getCategoryMangaCount(_categories[index - 1].serverId);
                final label = index == 0 ? 'All ($count)' : '${_categories[index - 1].name} ($count)';
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: const Color(0x1F2A2A32),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? primaryColor : const Color(0x2BFFFFFF),
                        width: isSelected ? 1.2 : 0.8,
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
            : CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                scrollCacheExtent: ScrollCacheExtent.pixels(800),
                slivers: [
                  if (_isOffline && GraphQLClientService.instance.isConfigured)
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Unread', 'Downloaded', 'Completed'].map((filter) {
                            final isSel = _statusFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSel,
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                visualDensity: VisualDensity.compact,
                                selectedColor: primaryColor.withValues(alpha: 0.25),
                                backgroundColor: const Color(0x1F2A2A32),
                                labelStyle: TextStyle(
                                  color: isSel ? primaryColor : Colors.grey[400],
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSel ? primaryColor.withValues(alpha: 0.6) : const Color(0x2BFFFFFF),
                                    width: 0.8,
                                  ),
                                ),
                                onSelected: (_) {
                                  setState(() => _statusFilter = filter);
                                },
                              ),
                            );
                          }).toList(),
                        ),
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
                            MainShell.switchToTab(3);
                          }
                        },
                      ),
                    )
                  else if (isList)
                    SliverPadding(
                      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8, bottom: bottomPadding),
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
                      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8, bottom: bottomPadding),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: isTablet ? 16 : 12,
                          mainAxisSpacing: isTablet ? 20 : 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMangaCard(
                            displayManga[index],
                            isCompact: isCompact,
                            isCoverOnly: isCoverOnly,
                          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1F1F24),
                border: Border(top: BorderSide(color: Color(0x2BFFFFFF))),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.drive_file_move_outlined, color: Colors.white70),
                      tooltip: 'Move Category',
                      onPressed: _batchMoveToCategory,
                    ),
                    IconButton(
                      icon: const Icon(Icons.done_all_rounded, color: Colors.greenAccent),
                      tooltip: 'Mark Read',
                      onPressed: () => _batchMarkRead(true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_done_rounded, color: Colors.amberAccent),
                      tooltip: 'Mark Unread',
                      onPressed: () => _batchMarkRead(false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      tooltip: 'Remove',
                      onPressed: _batchRemoveFromLibrary,
                    ),
                  ],
                ),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildMangaCard(Manga manga, {bool isCompact = false, bool isCoverOnly = false}) {
    final isSelected = _selectedMangaIds.contains(manga.serverId);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDownloaded = DownloadManagerService.instance.downloadedLocalChapterIds.contains(manga.serverId);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1F1F24),
                        border: Border.all(
                          color: isSelected ? primaryColor : const Color(0x1AFFFFFF),
                          width: isSelected ? 2.5 : 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                    if (isCompact && !isSelected)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xD9000000), Color(0xF2000000)],
                              stops: [0.0, 0.5, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                          ),
                          child: Text(
                            manga.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white, height: 1.25),
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
                    if (_settings.showUnreadBadges && (manga.unreadCount ?? 0) > 0 && !isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${manga.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    if (_settings.showDownloadedBadges && isDownloaded && !isSelected)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xCC10B981),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.download_done_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    if (isCoverOnly && !isSelected)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xCC000000)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                          ),
                          child: Text(
                            manga.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isCompact && !isCoverOnly) ...[
                const SizedBox(height: 6),
                Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.25),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaListItem(Manga manga) {
    final isSelected = _selectedMangaIds.contains(manga.serverId);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDownloaded = DownloadManagerService.instance.downloadedLocalChapterIds.contains(manga.serverId);

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
            subtitle: Row(
              children: [
                Flexible(child: Text(manga.sourceName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                if (isDownloaded && _settings.showDownloadedBadges) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.download_done_rounded, size: 14, color: Color(0xFF10B981)),
                ],
              ],
            ),
            trailing: _settings.showUnreadBadges && manga.unreadCount != null && manga.unreadCount! > 0
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
