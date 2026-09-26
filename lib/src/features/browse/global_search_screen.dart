import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/content_resolver_service.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/sync/graphql_client_service.dart';

class GlobalSearchScreen extends StatefulWidget {
  final String initialQuery;
  const GlobalSearchScreen({super.key, this.initialQuery = ''});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late TextEditingController _searchController;
  final Map<String, List<Map<String, dynamic>>> _resultsBySource = {};
  final Set<String> _loadingSources = {};
  List<Map<String, dynamic>> _sources = [];
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _loadSourcesAndSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSourcesAndSearch() async {
    final combinedSources = <Map<String, dynamic>>[];
    final seen = <String>{};

    // 1. Local JS Extensions
    final localExtNames = QuickJsService.instance.getInstalledExtensionNames();
    for (final name in localExtNames) {
      if (name.isNotEmpty && !seen.contains(name.toLowerCase())) {
        seen.add(name.toLowerCase());
        combinedSources.add({
          'id': 'local_js_${name.toLowerCase().replaceAll(' ', '_')}',
          'name': name,
          'isLocal': true,
        });
      }
    }

    // 2. Server Sources
    if (GraphQLClientService.instance.isConfigured) {
      final data = await GraphQLClientService.instance.fetchSources();
      if (data != null && data.containsKey('sources')) {
        final nodes = data['sources']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          for (final n in nodes) {
            final m = n as Map<String, dynamic>;
            final name = m['displayName'] as String? ?? m['name'] as String? ?? 'Source';
            if (!seen.contains(name.toLowerCase())) {
              seen.add(name.toLowerCase());
              combinedSources.add({
                'id': m['id'].toString(),
                'name': name,
                'isLocal': false,
              });
            }
          }
        }
      }
    }

    if (mounted) {
      setState(() => _sources = combinedSources);
    }

    if (_searchController.text.trim().isNotEmpty) {
      _executeGlobalSearch(_searchController.text.trim());
    }
  }

  Future<void> _executeGlobalSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Generation token: in-flight workers from a previous search must not
    // write their stale results into the freshly-cleared maps of a newer one.
    final generation = ++_searchGeneration;

    setState(() {
      _resultsBySource.clear();
      _loadingSources.addAll(_sources.map((s) => s['name'] as String));
    });

    const maxParallel = 6;
    var nextIndex = 0;
    Future<void> worker() async {
      while (true) {
        final i = nextIndex++;
        if (i >= _sources.length) return;
        final src = _sources[i];
        final sourceId = src['id'] as String;
        final sourceName = src['name'] as String;
        try {
          final list = await ContentResolverService.instance
              .resolveSourceManga(
                sourceId: sourceId,
                sourceName: sourceName,
                searchQuery: trimmed,
                page: 1,
              )
              .timeout(const Duration(seconds: 15));
          if (generation != _searchGeneration) return;
          if (!mounted) return;
          setState(() {
            _loadingSources.remove(sourceName);
            if (list.isNotEmpty) {
              _resultsBySource[sourceName] = list;
            }
          });
        } catch (_) {
          if (generation != _searchGeneration) return;
          if (mounted) {
            setState(() => _loadingSources.remove(sourceName));
          }
        }
      }
    }

    await Future.wait(List.generate(maxParallel.clamp(1, _sources.length), (_) => worker()));
  }

  Future<void> _onMangaTap(Map<String, dynamic> manga, String sourceName) async {
    final title = (manga['title'] ?? manga['name'] ?? 'Unknown Manga').toString();
    final thumb = (manga['thumbnailUrl'] ?? manga['imageUrl'])?.toString();
    final link = (manga['link'] ?? manga['url'] ?? '').toString();

    // Only server-sourced results carry a real server manga id. Local JS-extension
    // scrapes may return arbitrary website ids — store those under a synthetic
    // NEGATIVE serverId (same convention as migration) so they can never collide
    // with a genuine server id in Isar's unique index.
    final isServerSourced = manga['origin'] == 'server';
    int id = parseIntSafe(manga['id']);
    if (id <= 0 && link.isNotEmpty) {
      // Stable content hash, not `String.hashCode` — see the note in
      // `stableLocalMangaServerId`.
      id = stableLocalMangaServerId(sourceName: sourceName, url: link, title: title).abs();
    } else if (id <= 0 && title.isNotEmpty) {
      id = stableLocalMangaServerId(sourceName: sourceName, url: link, title: title).abs();
    }
    if (!isServerSourced && id > 0) id = -id;

    if (id > 0) {
      var existing = await IsarService.instance.getMangaByServerId(id);
      if (existing == null) {
        final newManga = Manga()
          ..serverId = id
          ..title = title
          ..url = link
          ..thumbnailUrl = thumb
          ..sourceName = sourceName;
        await IsarService.instance.saveManga(newManga);
      } else {
        if (existing.url.isEmpty && link.isNotEmpty) {
          existing.url = link;
          await IsarService.instance.saveManga(existing);
        }
      }
      if (mounted) {
        context.push('/manga/$id');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery.isEmpty,
          decoration: InputDecoration(
            hintText: 'Global search all sources...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => _executeGlobalSearch(_searchController.text.trim()),
            ),
          ),
          onSubmitted: _executeGlobalSearch,
        ),
      ),
      body: SafeArea(
        child: _loadingSources.isNotEmpty && _resultsBySource.isEmpty
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : _resultsBySource.isEmpty
                ? const Center(child: Text('No results across sources.', style: TextStyle(color: Colors.grey)))
                : ListView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.only(bottom: 120),
                    children: _resultsBySource.entries.map((entry) {
                      final sourceName = entry.key;
                      final mangas = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '$sourceName (${mangas.length})',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 190,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: mangas.length,
                                itemBuilder: (context, index) {
                                  final m = mangas[index];
                                  final title = (m['title'] ?? m['name'] ?? 'Untitled').toString();
                                  final thumb = (m['thumbnailUrl'] ?? m['imageUrl'])?.toString() ?? '';

                                  return GestureDetector(
                                    onTap: () => _onMangaTap(m, sourceName),
                                    child: Container(
                                      width: 110,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              width: 110,
                                              height: 150,
                                              color: const Color(0xFF1F1F24),
                                              child: thumb.isNotEmpty
                                                  ? Image.network(
                                                      thumb,
                                                      headers: QuickJsService.getImageHeaders(sourceName, thumb),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => const Icon(Icons.book_rounded, color: Colors.grey),
                                                    )
                                                  : const Icon(Icons.book_rounded, color: Colors.grey),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                    }).toList(),
                  ),
      ),
    );
  }
}
