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
  int _currentPage = 1;
  final bool _hasNextPage = true;
  String _searchQuery = '';
  late bool _isLatestMode;
  final TextEditingController _searchController = TextEditingController();

  // Mihon Source Filter State
  String _selectedSort = 'Popularity';
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  
  List<dynamic> _dynamicFilters = [];
  bool _hasDynamicFilters = false;

  @override
  void initState() {
    super.initState();
    _isLatestMode = widget.isLatest;
    _fetchFiltersAndManga();
  }
  
  Future<void> _fetchFiltersAndManga() async {
    _dynamicFilters = await QuickJsService.instance.fetchSourceFiltersLocal(widget.sourceName);
    _hasDynamicFilters = _dynamicFilters.isNotEmpty;
    _fetchSourceManga();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSourceManga() async {
    setState(() => _isLoading = true);

    try {
      _mangaList = await ContentResolverService.instance.resolveSourceManga(
        sourceId: widget.sourceId,
        sourceName: widget.sourceName,
        isLatest: _isLatestMode,
        page: _currentPage,
        searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        selectedSort: _selectedSort,
        selectedStatus: _selectedStatus,
        selectedType: _selectedType,
        dynamicFilters: _hasDynamicFilters ? _dynamicFilters : null,
      );
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch source manga: $e', exception: e, stackTrace: stack, category: 'SourceGrid');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                        if (!_hasDynamicFilters) {
                          _isLatestMode = _selectedSort == 'Latest';
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sourceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
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
            // ── MIHON POPULAR / LATEST TAB BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isLatestMode ? primaryColor : const Color(0x1F2A2A32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: !_isLatestMode ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                        ),
                        child: Center(
                          child: Text(
                            'Popular',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_isLatestMode ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isLatestMode ? primaryColor : const Color(0x1F2A2A32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _isLatestMode ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                        ),
                        child: Center(
                          child: Text(
                            'Latest Updates',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLatestMode ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.sourceName}...',
                  prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _fetchSourceManga();
                          },
                        )
                      : null,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onSubmitted: (val) {
                  setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  });
                  _fetchSourceManga();
                },
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
                            final dynamicColumns = (constraints.maxWidth / 135).floor().clamp(2, 8);
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: dynamicColumns,
                                childAspectRatio: 0.62,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 16,
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

                            return GestureDetector(
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
                                    if (existing.url.isEmpty && link.isNotEmpty) {
                                      existing.url = link;
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
                                        color: Colors.grey[900],
                                        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.8),
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
                                  const SizedBox(height: 6),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() => _currentPage--);
                            _fetchSourceManga();
                          }
                        : null,
                    child: const Text('Previous'),
                  ),
                  Text('Page $_currentPage', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: _hasNextPage
                        ? () {
                            setState(() => _currentPage++);
                            _fetchSourceManga();
                          }
                        : null,
                    child: const Text('Next'),
                  ),
                ],
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
