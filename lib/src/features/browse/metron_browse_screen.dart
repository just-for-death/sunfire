import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/metron/metron_models.dart';
import '../../core/metron/metron_service.dart';
import '../settings/tracking_settings_screen.dart';
import 'metron_series_detail_screen.dart';

class MetronBrowseScreen extends StatefulWidget {
  const MetronBrowseScreen({super.key});

  @override
  State<MetronBrowseScreen> createState() => _MetronBrowseScreenState();
}

class _MetronBrowseScreenState extends State<MetronBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<MetronSeries> _seriesList = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalCount = 0;
  String? _nextUrl;
  int? _selectedPublisherId;

  // Major Western Comic Publishers with known Metron IDs
  final List<({String name, int? id})> _publishers = [
    (name: 'All', id: null),
    (name: 'Marvel', id: 1),
    (name: 'DC Comics', id: 2),
    (name: 'Image', id: 3),
    (name: 'Dark Horse', id: 4),
    (name: 'IDW', id: 5),
    (name: 'BOOM! Studios', id: 6),
  ];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _currentPage = 1;
      _performSearch();
    });
  }

  Future<void> _performSearch({bool isLoadMore = false}) async {
    if (!MetronService.instance.isConfigured) return;

    setState(() {
      _isLoading = true;
      if (!isLoadMore) _errorMessage = null;
    });

    try {
      final res = await MetronService.instance.searchSeries(
        query: _searchController.text,
        page: _currentPage,
        publisherId: _selectedPublisherId,
      );

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _seriesList.addAll(res.series);
          } else {
            _seriesList = res.series;
          }
          _totalCount = res.totalCount;
          _nextUrl = res.nextUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConfigured = MetronService.instance.isConfigured;

    if (!isConfigured) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_stories_outlined, size: 64, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text('Metron.cloud Comic Explorer', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Connect your Metron.cloud account to explore Western comic series, enrich metadata for Marvel, DC, Image, and track your reading collections.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.key_rounded),
                label: const Text('Configure Metron Token'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrackingSettingsScreen()),
                  );
                  setState(() {});
                  if (MetronService.instance.isConfigured) {
                    _performSearch();
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Search bar & Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search comic series (e.g. Spider-Man, Batman, Saga)...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        _currentPage = 1;
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              isDense: true,
            ),
          ),
        ),

        // Publisher filter chips
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: _publishers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final pub = _publishers[idx];
              final isSelected = _selectedPublisherId == pub.id;

              return FilterChip(
                label: Text(pub.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPublisherId = selected ? pub.id : null;
                    _currentPage = 1;
                  });
                  _performSearch();
                },
              );
            },
          ),
        ),

        const Divider(height: 1),

        if (_totalCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_totalCount series found', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                if (_isLoading)
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5)),
              ],
            ),
          ),

        // Results Grid
        Expanded(
          child: _isLoading && _seriesList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _seriesList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text('Error searching Metron', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _performSearch(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _seriesList.isEmpty
                      ? const Center(child: Text('No comic series found.', style: TextStyle(color: Colors.grey)))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.56,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _seriesList.length + (_nextUrl != null ? 1 : 0),
                          itemBuilder: (context, idx) {
                            if (idx >= _seriesList.length) {
                              return Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : TextButton(
                                        child: const Text('Load More'),
                                        onPressed: () {
                                          _currentPage++;
                                          _performSearch(isLoadMore: true);
                                        },
                                      ),
                              );
                            }

                            final series = _seriesList[idx];

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MetronSeriesDetailScreen(
                                      seriesId: series.id,
                                      initialTitle: series.name,
                                      initialImage: series.image,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: series.image != null
                                          ? Image.network(
                                              series.image!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: Colors.grey.shade800,
                                                child: const Icon(Icons.book, size: 32),
                                              ),
                                            )
                                          : Container(
                                              color: Colors.grey.shade800,
                                              child: const Icon(Icons.book, size: 32),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    series.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  if (series.publisher != null)
                                    Text(
                                      series.publisher!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, color: Colors.blueAccent),
                                    ),
                                  Text(
                                    '${series.yearBegan != null ? "(${series.yearBegan})" : ""} • ${series.issueCount} issues',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}
