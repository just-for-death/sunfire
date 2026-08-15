import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/logging/logger_service.dart';
import '../../core/sync/graphql_client_service.dart';

class MigrateSearchScreen extends StatefulWidget {
  final Manga manga;
  final List<Map<String, dynamic>> sources;

  const MigrateSearchScreen({
    super.key,
    required this.manga,
    required this.sources,
  });

  @override
  State<MigrateSearchScreen> createState() => _MigrateSearchScreenState();
}

class _MigrateSearchScreenState extends State<MigrateSearchScreen> {
  late TextEditingController _searchController;
  String _activeFilter = 'PINNED'; // 'PINNED', 'ALL', 'HAS_RESULTS'
  final Map<String, List<Map<String, dynamic>>> _searchResults = {};
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.manga.title);
    _performSearchAcrossSources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearchAcrossSources() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchResults.clear();
      for (final s in widget.sources) {
        final id = s['id'].toString();
        _loadingStates[id] = true;
      }
    });

    final targetSources = widget.sources.where((s) => s['name'] != widget.manga.sourceName && s['id'] != widget.manga.sourceName).toList();

    // Query in batches of 3 to avoid hammering slow remote extensions
    final batchSize = 3;
    for (var i = 0; i < targetSources.length; i += batchSize) {
      final batch = targetSources.skip(i).take(batchSize).toList();
      await Future.wait(
        batch.map((s) => _searchSingleSource(s['id'].toString(), query)),
      );
    }
  }

  Future<void> _searchSingleSource(String sourceId, String query) async {
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchSourceManga(sourceId, searchQuery: query);
        if (data != null && data.containsKey('fetchSourceManga')) {
          final mangas = data['fetchSourceManga']['mangas'] as List<dynamic>?;
          if (mangas != null) {
            final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
            final list = mangas.map((m) {
              final map = m as Map<String, dynamic>;
              final rawThumb = map['thumbnailUrl'] as String?;
              final thumb = (rawThumb != null && rawThumb.isNotEmpty)
                  ? (rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb')
                  : '';
              return {
                'id': map['id'],
                'title': map['title'] as String? ?? 'Untitled',
                'thumbnailUrl': thumb,
              };
            }).toList();

            if (mounted) {
              setState(() {
                _searchResults[sourceId] = list;
                _loadingStates[sourceId] = false;
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Search timed out on source $sourceId', 'Migrate');
    }

    if (mounted) {
      setState(() {
        _searchResults[sourceId] = [];
        _loadingStates[sourceId] = false;
      });
    }
  }

  void _showMigrationConfirmation(Map<String, dynamic> targetManga, Map<String, dynamic> targetSource) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetTitle = targetManga['title'] as String;
    final targetSourceName = targetSource['displayName'] as String? ?? targetSource['name'] as String;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Confirm Migration', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Migrate "${widget.manga.title}" from ${widget.manga.sourceName} to:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(targetTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Source: $targetSourceName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('• Reading progress & bookmarks will be transferred.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _executeMigration(targetManga, targetSource);
              },
              child: const Text('Migrate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeMigration(Map<String, dynamic> targetManga, Map<String, dynamic> targetSource) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetSourceName = targetSource['displayName'] as String? ?? targetSource['name'] as String;

    // 1. Update Isar DB
    widget.manga.sourceName = targetSourceName;
    if (targetManga['thumbnailUrl'] != null && (targetManga['thumbnailUrl'] as String).isNotEmpty) {
      widget.manga.thumbnailUrl = targetManga['thumbnailUrl'] as String;
    }
    await IsarService.instance.saveManga(widget.manga);

    // 2. Sync with Suwayomi server if configured
    try {
      if (GraphQLClientService.instance.isConfigured && widget.manga.serverId > 0) {
        await GraphQLClientService.instance.updateMangaLibraryState(widget.manga.serverId, true);
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully migrated "${widget.manga.title}" to $targetSourceName!'),
          backgroundColor: primaryColor,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final targetSources = widget.sources.where((s) {
      if (s['name'] == widget.manga.sourceName || s['id'] == widget.manga.sourceName) return false;
      if (_activeFilter == 'PINNED') return s['isPinned'] == true;
      if (_activeFilter == 'HAS_RESULTS') {
        final id = s['id'].toString();
        return (_searchResults[id]?.isNotEmpty ?? false);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Search for target manga...',
            border: InputBorder.none,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.search_rounded, color: primaryColor),
                  onPressed: _performSearchAcrossSources,
                ),
              ],
            ),
          ),
          onSubmitted: (_) => _performSearchAcrossSources(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── FILTER CHIPS (PINNED, ALL, HAS RESULTS) ─────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('PINNED'),
                    ],
                  ),
                  selected: _activeFilter == 'PINNED',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'PINNED' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'PINNED' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'PINNED'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.done_all_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('ALL'),
                    ],
                  ),
                  selected: _activeFilter == 'ALL',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'ALL' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'ALL' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.checklist_rounded, size: 14),
                      SizedBox(width: 4),
                      Text('HAS RESULTS'),
                    ],
                  ),
                  selected: _activeFilter == 'HAS_RESULTS',
                  selectedColor: primaryColor.withAlpha(50),
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(
                    color: _activeFilter == 'HAS_RESULTS' ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _activeFilter == 'HAS_RESULTS' ? primaryColor : const Color(0x2BFFFFFF), width: 0.8),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = 'HAS_RESULTS'),
                ),
              ],
            ),
          ),

          // ── MULTI-SOURCE SEARCH RESULTS ─────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 120),
              itemCount: targetSources.length,
              itemBuilder: (context, index) {
                final source = targetSources[index];
                final sourceId = source['id'].toString();
                final sourceName = source['displayName'] as String? ?? source['name'] as String;
                final lang = (source['lang'] as String? ?? 'en').toUpperCase();
                final isLoading = _loadingStates[sourceId] ?? false;
                final results = _searchResults[sourceId] ?? [];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source Section Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x1F2A2A32),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sourceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(lang, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Results Row / Loading
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        )
                      else if (results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          child: Text('No matching results found on this source.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        )
                      else
                        SizedBox(
                          height: 190,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: results.length,
                            itemBuilder: (context, rIndex) {
                              final item = results[rIndex];
                              final title = item['title'] as String;
                              final thumb = item['thumbnailUrl'] as String? ?? '';

                              return GestureDetector(
                                onTap: () => _showMigrationConfirmation(item, source),
                                child: Container(
                                  width: 110,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            color: const Color(0xFF1F1F24),
                                            border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: thumb.isNotEmpty
                                                ? Image.network(
                                                    thumb,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => Center(child: Icon(Icons.book_rounded, color: primaryColor)),
                                                  )
                                                : Center(child: Icon(Icons.book_rounded, color: primaryColor)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
