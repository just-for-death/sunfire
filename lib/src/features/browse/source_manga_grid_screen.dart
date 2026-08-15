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

class _SourceMangaGridScreenState extends State<SourceMangaGridScreen> {
  List<Map<String, dynamic>> _mangaList = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasNextPage = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSourceManga();
  }

  Future<void> _fetchSourceManga() async {
    setState(() => _isLoading = true);

    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchSourceManga(
          widget.sourceId,
          isLatest: widget.isLatest,
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
            'title': '${widget.sourceName} Title ${(_currentPage - 1) * 18 + i + 1}',
            'thumbnailUrl': 'https://via.placeholder.com/300x450.png?text=${widget.sourceName}+${i + 1}',
          },
        );
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch source manga: $e', exception: e, stackTrace: stack, category: 'SourceGrid');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sourceName} (${widget.isLatest ? "Latest" : "Popular"})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  setState(() => _searchQuery = val);
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
