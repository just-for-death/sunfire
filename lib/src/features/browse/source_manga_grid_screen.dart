import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/logger_service.dart';
import '../../core/sync/graphql_client_service.dart';

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
  bool _hasNextPage = true;
  String _searchQuery = '';
  late bool _isLatestMode;
  final TextEditingController _searchController = TextEditingController();

  // Mihon Source Filter State
  String _selectedSort = 'Popularity';
  String _selectedStatus = 'All';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    _isLatestMode = widget.isLatest;
    _fetchSourceManga();
  }

  Future<void> _fetchSourceManga() async {
    setState(() => _isLoading = true);

    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchSourceManga(
          widget.sourceId,
          isLatest: _isLatestMode,
          page: _currentPage,
          searchQuery: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        );

        if (data != null && data.containsKey('fetchSourceManga')) {
          final payload = data['fetchSourceManga'] as Map<String, dynamic>;
          final nodes = payload['mangas'] as List<dynamic>?;
          _hasNextPage = payload['hasNextPage'] as bool? ?? false;

          if (nodes != null) {
            final serverUrl = GraphQLClientService.instance.baseUrl ?? '';
            _mangaList = nodes.map((n) {
              final map = n as Map<String, dynamic>;
              final rawThumb = map['thumbnailUrl'] as String?;
              final thumb = (rawThumb != null && rawThumb.isNotEmpty)
                  ? (rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb')
                  : null;
              return {
                'id': map['id'],
                'title': map['title'] ?? 'Untitled',
                'thumbnailUrl': thumb,
              };
            }).toList();
          }
        }
      }

      if (_mangaList.isEmpty) {
        _mangaList = List.generate(
          18,
          (i) => {
            'id': 100 + i,
            'title': '${widget.sourceName} ${_isLatestMode ? "Latest" : "Top"} ${(_currentPage - 1) * 18 + i + 1}',
            'thumbnailUrl': null,
          },
        );
      }
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
                            _selectedSort = 'Popularity';
                            _selectedStatus = 'All';
                            _selectedType = 'All';
                          });
                        },
                        child: Text('Reset', style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Sort By
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

                  // 2. Status
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

                  const SizedBox(height: 16),

                  // 3. Type
                  const Text('Content Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Manga', 'Manhwa', 'Manhua', 'Comic'].map((t) {
                      final isSelected = _selectedType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        selectedColor: primaryColor,
                        backgroundColor: const Color(0x1F2A2A32),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        onSelected: (_) {
                          setSheetState(() => _selectedType = t);
                        },
                      );
                    }).toList(),
                  ),

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
                        _isLatestMode = _selectedSort == 'Latest';
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
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _mangaList.length,
                      itemBuilder: (context, index) {
                        final manga = _mangaList[index];
                        final id = manga['id'] as int;
                        final title = manga['title'] as String;
                        final thumb = manga['thumbnailUrl'] as String?;

                        return GestureDetector(
                          onTap: () => context.push('/manga/$id'),
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
                                    child: thumb != null && thumb.isNotEmpty
                                        ? Image.network(
                                            thumb,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.book_rounded, color: Colors.grey)),
                                          )
                                        : const Center(child: Icon(Icons.book_rounded, color: Colors.grey)),
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
}
