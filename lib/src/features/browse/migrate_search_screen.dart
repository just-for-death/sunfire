import 'dart:async';
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

  List<Map<String, dynamic>> _getTargetSources() {
    return widget.sources.where((s) {
      final id = s['id'].toString();
      final name = s['name'] as String? ?? '';
      if (name == widget.manga.sourceName || id == widget.manga.sourceName) return false;
      return true;
    }).toList();
  }

  Future<void> _performSearchAcrossSources() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final targetSources = _getTargetSources();

    setState(() {
      _searchResults.clear();
      _loadingStates.clear();
      for (final s in targetSources) {
        final id = s['id'].toString();
        _loadingStates[id] = true;
      }
    });

    // Run searches with individual timeouts so no source blocks the UI
    await Future.wait(
      targetSources.map((s) => _searchSingleSource(s['id'].toString(), query)),
    );
  }

  Future<void> _searchSingleSource(String sourceId, String query) async {
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance
            .fetchSourceManga(sourceId, searchQuery: query)
            .timeout(const Duration(seconds: 8), onTimeout: () => null);

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
                'artist': map['artist'],
                'author': map['author'],
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
      await LoggerService.instance.logWarning('Search timed out on source $sourceId: $e', 'Migrate');
    } finally {
      if (mounted) {
        setState(() {
          _searchResults.putIfAbsent(sourceId, () => []);
          _loadingStates[sourceId] = false;
        });
      }
    }
  }

  void _showMigrationConfirmation(Map<String, dynamic> targetManga, Map<String, dynamic> targetSource) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetTitle = targetManga['title'] as String;
    final targetSourceName = targetSource['displayName'] as String? ?? targetSource['name'] as String;

    bool copyHistory = true;
    bool copyCategories = true;
    bool copyTracking = true;
    bool deleteOriginal = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 10),
                  Text('Migrate Manga (Mihon)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text('Migrate from: ${widget.manga.sourceName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primaryColor.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          if (targetManga['thumbnailUrl'] != null && (targetManga['thumbnailUrl'] as String).isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(targetManga['thumbnailUrl'] as String, width: 42, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book_rounded)),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(targetTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('Target: $targetSourceName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('WHAT TO INCLUDE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: copyHistory,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer chapter reading progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyHistory = v ?? true),
                    ),
                    CheckboxListTile(
                      value: copyCategories,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer category assignments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyCategories = v ?? true),
                    ),
                    CheckboxListTile(
                      value: copyTracking,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transfer manga tracking records', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => copyTracking = v ?? true),
                    ),
                    CheckboxListTile(
                      value: deleteOriginal,
                      activeColor: primaryColor,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Delete original manga from library', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      onChanged: (v) => setDialogState(() => deleteOriginal = v ?? true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await _executeMigration(
                      targetManga,
                      targetSource,
                      copyHistory: copyHistory,
                      copyCategories: copyCategories,
                      copyTracking: copyTracking,
                      deleteOriginal: deleteOriginal,
                    );
                  },
                  child: const Text('Migrate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executeMigration(
    Map<String, dynamic> targetManga,
    Map<String, dynamic> targetSource, {
    required bool copyHistory,
    required bool copyCategories,
    required bool copyTracking,
    required bool deleteOriginal,
  }) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final targetSourceName = targetSource['displayName'] as String? ?? targetSource['name'] as String;
    final targetMangaId = targetManga['id'] as int;

    // 1. Fetch Target Manga into Suwayomi Library
    if (GraphQLClientService.instance.isConfigured) {
      try {
        await GraphQLClientService.instance.fetchMangaAndChapters(targetMangaId);
        await GraphQLClientService.instance.updateMangaLibraryState(targetMangaId, true);

        // Copy Tracking Records
        if (copyTracking && widget.manga.serverId > 0) {
          final existingTracks = await GraphQLClientService.instance.fetchTrackRecords(widget.manga.serverId);
          final nodes = existingTracks?['trackRecords']?['nodes'] as List<dynamic>? ?? [];
          for (final tr in nodes) {
            final trackerId = tr['trackerId'] as int?;
            final remoteId = tr['remoteId']?.toString() ?? tr['id']?.toString();
            if (trackerId != null && remoteId != null) {
              await GraphQLClientService.instance.bindTrack(targetMangaId, trackerId, remoteId);
            }
          }
        }

        // Delete Original if requested
        if (deleteOriginal && widget.manga.serverId > 0) {
          await GraphQLClientService.instance.updateMangaLibraryState(widget.manga.serverId, false);
        }
      } catch (e) {
        await LoggerService.instance.logError('Migration sync error: $e', exception: e, category: 'Migrate');
      }
    }

    // 2. Update local Isar record
    widget.manga.sourceName = targetSourceName;
    if (targetManga['thumbnailUrl'] != null && (targetManga['thumbnailUrl'] as String).isNotEmpty) {
      widget.manga.thumbnailUrl = targetManga['thumbnailUrl'] as String;
    }
    await IsarService.instance.saveManga(widget.manga);

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
      final name = s['name'] as String? ?? '';
      final id = s['id'].toString();
      if (name == widget.manga.sourceName || id == widget.manga.sourceName) return false;

      if (_activeFilter == 'PINNED') return s['isPinned'] == true;
      if (_activeFilter == 'HAS_RESULTS') {
        return (_searchResults[id]?.isNotEmpty ?? false);
      }
      return true;
    }).toList();

    final isAnyLoading = _loadingStates.values.any((loading) => loading);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Search title...',
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
                      Icon(Icons.check_circle_outline_rounded, size: 14),
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
                if (isAnyLoading) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  ),
                  const SizedBox(width: 6),
                  const Text('Searching...', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0x1AFFFFFF)),

          // ── SOURCES EXPANDABLE LIST ─────────────────────────────
          Expanded(
            child: targetSources.isEmpty
                ? Center(
                    child: Text(
                      _activeFilter == 'PINNED'
                          ? 'No pinned sources found.\nSwitch to "ALL" to search across all sources.'
                          : 'No sources available for migration.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: targetSources.length,
                    itemBuilder: (context, index) {
                      final source = targetSources[index];
                      final sourceId = source['id'].toString();
                      final sourceName = source['displayName'] as String? ?? source['name'] as String;
                      final lang = (source['lang'] as String? ?? 'en').toUpperCase();
                      final isLoading = _loadingStates[sourceId] ?? false;
                      final results = _searchResults[sourceId] ?? [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Material(
                          color: const Color(0x1F2A2A32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: results.isNotEmpty,
                            shape: const Border(),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sourceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4)),
                                  child: Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            trailing: isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (results.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withAlpha(50),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${results.length}',
                                            style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                    ],
                                  ),
                            children: [
                              if (results.isEmpty && !isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No matching results found on this source.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                )
                              else
                                ...results.map((res) {
                                  final thumb = res['thumbnailUrl'] as String? ?? '';
                                  final title = res['title'] as String? ?? 'Untitled';

                                  return ListTile(
                                    leading: thumb.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.network(
                                              thumb,
                                              width: 38,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Icon(Icons.book_rounded, color: primaryColor),
                                            ),
                                          )
                                        : Icon(Icons.book_rounded, color: primaryColor),
                                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                      child: const Text('Select', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _showMigrationConfirmation(res, source),
                                    ),
                                  );
                                }),
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
  }
}
