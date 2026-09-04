import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/empty_state_widget.dart';

class SourceMangaGridScreen extends StatefulWidget {
  final String sourceId;
  final String sourceName;
  final bool isLatest;

  const SourceMangaGridScreen({
    super.key,
    required this.sourceId,
    required this.sourceName,
    this.isLatest = false,
  });

  @override
  State<SourceMangaGridScreen> createState() => _SourceMangaGridScreenState();
}

class _SourceMangaGridScreenState extends State<SourceMangaGridScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _mangaList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String _searchQuery = '';
  late bool _isLatestMode;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mihon Source Filter State
  String _selectedSort = 'Popularity';
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  
  List<dynamic> _dynamicFilters = [];
  bool _hasDynamicFilters = false;
  bool _isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    _isLatestMode = widget.isLatest;
    _scrollController.addListener(_onScroll);
    _fetchFiltersAndManga();
  }
  
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasNextPage) {
      _loadMoreManga();
    }
  }

  Future<void> _fetchFiltersAndManga() async {
    _dynamicFilters = await QuickJsService.instance.fetchSourceFiltersLocal(widget.sourceName);
    _hasDynamicFilters = _dynamicFilters.isNotEmpty;
    _fetchSourceManga();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSourceManga() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasNextPage = true;
    });

    try {
      _mangaList = await ContentResolverService.instance.resolveSourceManga(
        sourceId: widget.sourceId,
        sourceName: widget.sourceName,
        isLatest: _isLatestMode,
        page: 1,
        searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        selectedSort: _selectedSort,
        selectedStatus: _selectedStatus,
        selectedType: _selectedType,
        dynamicFilters: (_hasDynamicFilters && (_isFilterApplied || _searchQuery.trim().isNotEmpty)) ? _dynamicFilters : null,
      );
      if (_mangaList.length < 10) {
        _hasNextPage = false;
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch source manga: $e', exception: e, stackTrace: stack, category: 'SourceGrid');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreManga() async {
    if (_isLoadingMore || !_hasNextPage) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final newManga = await ContentResolverService.instance.resolveSourceManga(
        sourceId: widget.sourceId,
        sourceName: widget.sourceName,
        isLatest: _isLatestMode,
        page: nextPage,
        searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        selectedSort: _selectedSort,
        selectedStatus: _selectedStatus,
        selectedType: _selectedType,
        dynamicFilters: (_hasDynamicFilters && (_isFilterApplied || _searchQuery.trim().isNotEmpty)) ? _dynamicFilters : null,
      );

      if (mounted) {
        setState(() {
          if (newManga.isEmpty) {
            _hasNextPage = false;
          } else {
            // Deduplicate incoming manga against already loaded items
            final existingKeys = _mangaList.map((m) {
              final url = (m['url'] ?? m['link'] ?? '').toString().trim();
              if (url.isNotEmpty) return url;
              final name = (m['name'] ?? m['title'] ?? '').toString().trim().toLowerCase();
              return name;
            }).where((k) => k.isNotEmpty).toSet();

            final uniqueNewManga = newManga.where((m) {
              final url = (m['url'] ?? m['link'] ?? '').toString().trim();
              final name = (m['name'] ?? m['title'] ?? '').toString().trim().toLowerCase();
              if (url.isNotEmpty && existingKeys.contains(url)) return false;
              if (url.isEmpty && name.isNotEmpty && existingKeys.contains(name)) return false;
              return true;
            }).toList();

            if (uniqueNewManga.isEmpty) {
              _hasNextPage = false;
            } else {
              _currentPage = nextPage;
              _mangaList.addAll(uniqueNewManga);
              if (newManga.length < 8) _hasNextPage = false;
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hasNextPage = false);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _showFilterSheet() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${widget.sourceName} Filters', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            if (_hasDynamicFilters) {
                               for(var f in _dynamicFilters) {
                                  if (f['type_name'] == 'SelectFilter' || f['type_name'] == 'SortFilter') {
                                      f['state'] = 0;
                                  }
                               }
                            } else {
                                _selectedSort = 'Popularity';
                                _selectedStatus = 'All';
                                _selectedType = 'All';
                            }
                          });
                        },
                        child: Text('Reset', style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_hasDynamicFilters) ...[
                     for (int i = 0; i < _dynamicFilters.length; i++) ...[
                        Text((_dynamicFilters[i]['name'] ?? 'Filter').toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        if (_dynamicFilters[i]['type_name'] == 'SelectFilter' || _dynamicFilters[i]['type_name'] == 'SortFilter')
                           Wrap(
                             spacing: 8,
                             children: ((_dynamicFilters[i]['values'] as List<dynamic>?) ?? []).asMap().entries.map((entry) {
                               final idx = entry.key;
                               final valObj = entry.value;
                               final isSelected = _dynamicFilters[i]['state'] == idx;
                               return ChoiceChip(
                                 label: Text((valObj['name'] ?? valObj['value'] ?? '').toString()),
                                 selected: isSelected,
                                 selectedColor: primaryColor,
                                 backgroundColor: const Color(0x1F2A2A32),
                                 labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                 onSelected: (_) {
                                   setSheetState(() => _dynamicFilters[i]['state'] = idx);
                                 },
                               );
                             }).toList(),
                           ),
                        const SizedBox(height: 16),
                     ]
                  ] else ...[
                     const Text('Sort By', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                     const SizedBox(height: 8),
                     Wrap(
                       spacing: 8,
                       children: ['Popularity', 'Latest', 'Title', 'Rating'].map((s) {
                         final isSelected = _selectedSort == s;
                         return ChoiceChip(
                           label: Text(s),
                           selected: isSelected,
                           selectedColor: primaryColor,
                           backgroundColor: const Color(0x1F2A2A32),
                           labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                           onSelected: (_) {
                             setSheetState(() => _selectedSort = s);
                           },
                         );
                       }).toList(),
                     ),
                     const SizedBox(height: 16),
                     const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                     const SizedBox(height: 8),
                     Wrap(
                       spacing: 8,
                       children: ['All', 'Ongoing', 'Completed', 'Hiatus'].map((st) {
                         final isSelected = _selectedStatus == st;
                         return ChoiceChip(
                           label: Text(st),
                           selected: isSelected,
                           selectedColor: primaryColor,
                           backgroundColor: const Color(0x1F2A2A32),
                           labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                           onSelected: (_) {
                             setSheetState(() => _selectedStatus = st);
                           },
                         );
                       }).toList(),
                     ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _currentPage = 1;
                        _isFilterApplied = true;
                        if (!_hasDynamicFilters) {
                          _isLatestMode = _selectedSort == 'Latest';
                          // Legacy filters apply via the same _isFilterApplied flag
                        }
                      });
                      _fetchSourceManga();
                    },
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSourceSettings() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text('${widget.sourceName} Settings', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.fingerprint_rounded, color: primaryColor),
                title: const Text('Source ID', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: Text(widget.sourceId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language_rounded, color: primaryColor),
                title: const Text('Status', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: const Text('Installed & Synced from Suwayomi Server', style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.sourceName}...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
                onSubmitted: (val) {
                  setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  });
                  _fetchSourceManga();
                },
              )
            : Text(widget.sourceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isSearchExpanded) {
              setState(() {
                _isSearchExpanded = false;
                _searchController.clear();
                _searchQuery = '';
                _currentPage = 1;
              });
              _fetchSourceManga();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search source',
              onPressed: () => setState(() => _isSearchExpanded = true),
            ),
          if (_isSearchExpanded && _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _currentPage = 1;
                });
                _fetchSourceManga();
              },
            ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filter source',
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Source settings',
            onPressed: _showSourceSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── MIHON POPULAR / LATEST TAB BAR (Compact & Centered) ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0x1F2A2A32),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isLatestMode) {
                                setState(() {
                                  _isLatestMode = false;
                                  _currentPage = 1;
                                });
                                _fetchSourceManga();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: !_isLatestMode ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: !_isLatestMode
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Popular',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: !_isLatestMode ? Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isLatestMode) {
                                setState(() {
                                  _isLatestMode = true;
                                  _currentPage = 1;
                                });
                                _fetchSourceManga();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: _isLatestMode ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: _isLatestMode
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Latest Updates',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: _isLatestMode ? Colors.white : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _mangaList.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.wifi_off_rounded,
                          title: 'No Manga Found',
                          subtitle: 'Source timed out or no results match your query.',
                          actionLabel: 'Retry',
                          onAction: _fetchSourceManga,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth >= 720;
                            final targetWidth = isTablet ? 175.0 : 120.0;
                            final dynamicColumns = (constraints.maxWidth / targetWidth).floor().clamp(2, 5);
                            final horizontalPad = isTablet ? 24.0 : 16.0;

                            return Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 12),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: dynamicColumns,
                                      childAspectRatio: 0.68,
                                      crossAxisSpacing: isTablet ? 16 : 12,
                                      mainAxisSpacing: isTablet ? 20 : 16,
                                    ),
                                    itemCount: _mangaList.length,
                                    itemBuilder: (context, index) {
                                      final manga = _mangaList[index];
                                      final title = (manga['title'] ?? manga['name'] ?? 'Unknown Manga').toString();
                                      final thumb = (manga['thumbnailUrl'] ?? manga['imageUrl'])?.toString();
                                      final link = (manga['link'] ?? manga['url'] ?? '').toString();

                                      final rawId = manga['id'];
                                      int id = rawId is int ? rawId : (int.tryParse(rawId?.toString() ?? '0') ?? 0);
                                      if (id <= 0 && link.isNotEmpty) {
                                        id = (link.hashCode ^ widget.sourceName.hashCode).abs();
                                      } else if (id <= 0 && title.isNotEmpty) {
                                        id = (title.hashCode ^ widget.sourceName.hashCode).abs();
                                      }

                                      return Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () async {
                                            if (id > 0) {
                                              var existing = await IsarService.instance.getMangaByServerId(id);
                                              if (existing == null) {
                                                final newManga = Manga()
                                                  ..serverId = id
                                                  ..title = title
                                                  ..url = link
                                                  ..thumbnailUrl = thumb
                                                  ..sourceName = widget.sourceName;
                                                await IsarService.instance.saveManga(newManga);
                                              } else {
                                                bool needsUpdate = false;
                                                if (existing.url.isEmpty && link.isNotEmpty) {
                                                  existing.url = link;
                                                  needsUpdate = true;
                                                }
                                                if (existing.sourceName.isEmpty && widget.sourceName.isNotEmpty) {
                                                  existing.sourceName = widget.sourceName;
                                                  needsUpdate = true;
                                                }
                                                if (needsUpdate) {
                                                  await IsarService.instance.saveManga(existing);
                                                }
                                              }
                                              if (context.mounted) {
                                                context.push('/manga/$id');
                                              }
                                            }
                                          },
                                          onLongPress: () => _showMangaQuickActions(id, title, thumb),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(16),
                                                    color: const Color(0xFF16161E),
                                                    border: Border.all(color: const Color(0x1FFFFFFF), width: 0.8),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color(0x33000000),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: MangaCoverImage(
                                                      mangaServerId: id,
                                                      thumbnailUrl: thumb,
                                                      sourceName: widget.sourceName,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: isTablet ? 13 : 12,
                                                  height: 1.25,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (_isLoadingMore)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: primaryColor),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMangaQuickActions(int mangaId, String title, String? thumb) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
              Row(
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MangaCoverImage(
                        mangaServerId: mangaId,
                        thumbnailUrl: thumb,
                        sourceName: widget.sourceName,
                        width: 40,
                        height: 55,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Quick Actions', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.favorite_rounded, color: primaryColor),
                title: const Text('Add to Library (Default Category)', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (GraphQLClientService.instance.isConfigured) {
                    await GraphQLClientService.instance.updateMangaLibraryState(mangaId, true);
                    if (SettingsService.instance.defaultCategoryId != null) {
                      await GraphQLClientService.instance.updateMangaCategories(mangaId, [SettingsService.instance.defaultCategoryId!]);
                    }
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added "$title" to library')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: Colors.white),
                title: const Text('View Manga Details', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/manga/$mangaId');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
