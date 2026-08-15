import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _loadSourcesAndSearch();
  }

  Future<void> _loadSourcesAndSearch() async {
    if (GraphQLClientService.instance.isConfigured) {
      final data = await GraphQLClientService.instance.fetchSources();
      if (data != null && data.containsKey('sources')) {
        final nodes = data['sources']['nodes'] as List<dynamic>?;
        if (nodes != null) {
          _sources = nodes.map((n) {
            final m = n as Map<String, dynamic>;
            return {
              'id': m['id'].toString(),
              'name': m['displayName'] as String? ?? m['name'] as String? ?? 'Source',
            };
          }).toList();
        }
      }
    }

    if (_searchController.text.trim().isNotEmpty) {
      _executeGlobalSearch(_searchController.text.trim());
    }
  }

  Future<void> _executeGlobalSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _resultsBySource.clear();
      _loadingSources.addAll(_sources.map((s) => s['id'] as String));
    });

    final serverUrl = GraphQLClientService.instance.baseUrl ?? '';

    for (final src in _sources) {
      final sourceId = src['id'] as String;
      final sourceName = src['name'] as String;

      GraphQLClientService.instance.fetchSourceManga(
        sourceId,
        page: 1,
        searchQuery: query,
      ).then((data) {
        if (!mounted) return;
        final list = <Map<String, dynamic>>[];
        if (data != null && data.containsKey('fetchSourceManga')) {
          final payload = data['fetchSourceManga'] as Map<String, dynamic>;
          final nodes = payload['mangas'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final map = n as Map<String, dynamic>;
              final rawThumb = map['thumbnailUrl'] as String?;
              final thumb = (rawThumb != null && rawThumb.isNotEmpty)
                  ? (rawThumb.startsWith('http') ? rawThumb : '$serverUrl$rawThumb')
                  : '';
              list.add({
                'id': map['id'],
                'title': map['title'] ?? 'Untitled',
                'thumbnailUrl': thumb,
              });
            }
          }
        }
        setState(() {
          _loadingSources.remove(sourceId);
          if (list.isNotEmpty) {
            _resultsBySource[sourceName] = list;
          }
        });
      }).catchError((_) {
        if (mounted) setState(() => _loadingSources.remove(sourceId));
      });
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
            hintText: 'Global Search all sources...',
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
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: mangas.length,
                                itemBuilder: (context, index) {
                                  final m = mangas[index];
                                  final id = m['id'] as int;
                                  final title = m['title'] as String;
                                  final thumb = m['thumbnailUrl'] as String;

                                  return GestureDetector(
                                    onTap: () => context.push('/manga/$id'),
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
                                                  ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book_rounded, color: Colors.grey))
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
