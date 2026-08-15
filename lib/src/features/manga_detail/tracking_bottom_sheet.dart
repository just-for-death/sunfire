import 'package:flutter/material.dart';

import '../../core/sync/graphql_client_service.dart';

class TrackingBottomSheet extends StatefulWidget {
  final int mangaServerId;
  final String mangaTitle;

  const TrackingBottomSheet({
    super.key,
    required this.mangaServerId,
    required this.mangaTitle,
  });

  static Future<void> show(BuildContext context, int mangaServerId, String mangaTitle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141419),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => TrackingBottomSheet(
        mangaServerId: mangaServerId,
        mangaTitle: mangaTitle,
      ),
    );
  }

  @override
  State<TrackingBottomSheet> createState() => _TrackingBottomSheetState();
}

class _TrackingBottomSheetState extends State<TrackingBottomSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _trackers = [];
  List<Map<String, dynamic>> _boundRecords = [];

  // Search mode state
  int? _searchingTrackerId;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    setState(() => _isLoading = true);
    if (!GraphQLClientService.instance.isConfigured) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final trackersData = await GraphQLClientService.instance.fetchTrackers();
      final recordsData = await GraphQLClientService.instance.fetchTrackRecords(widget.mangaServerId);

      final rawTrackers = trackersData?['trackers']?['nodes'] as List<dynamic>? ?? [];
      final rawRecords = recordsData?['trackRecords']?['nodes'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _trackers = rawTrackers.map((t) => t as Map<String, dynamic>).toList();
          _boundRecords = rawRecords.map((r) => r as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchTracker(int trackerId) async {
    setState(() {
      _searchingTrackerId = trackerId;
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final data = await GraphQLClientService.instance.searchTracker(trackerId, _searchQuery.isEmpty ? widget.mangaTitle : _searchQuery);
      final list = data?['searchTracker']?['trackSearches'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _searchResults = list.map((n) => n as Map<String, dynamic>).toList();
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _bindManga(int trackerId, int remoteId) async {
    setState(() => _isLoading = true);
    _searchingTrackerId = null;
    await GraphQLClientService.instance.bindTrack(widget.mangaServerId, trackerId, remoteId);
    await _loadTrackingData();
  }

  Future<void> _unbindRecord(int recordId) async {
    setState(() => _isLoading = true);
    await GraphQLClientService.instance.unbindTrack(recordId);
    await _loadTrackingData();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        if (_isLoading) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (_searchingTrackerId != null) {
          return _buildSearchTrackerView(primaryColor);
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20.0),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sync_alt_rounded, color: primaryColor, size: 24),
                const SizedBox(width: 10),
                const Text('Manga Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),

            if (_trackers.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No tracker services configured on server.', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ] else ...[
              ..._trackers.map((t) {
                final trackerId = t['id'] as int;
                final trackerName = t['name'] as String? ?? 'Tracker';
                final bound = _boundRecords.firstWhere(
                  (r) => (r['trackerId'] as int?) == trackerId,
                  orElse: () => <String, dynamic>{},
                );
                final isBound = bound.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Material(
                    color: const Color(0x1F2A2A32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.track_changes_rounded, color: isBound ? Colors.greenAccent : primaryColor, size: 22),
                                  const SizedBox(width: 10),
                                  Text(trackerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              if (isBound)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.greenAccent.withAlpha(40), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('TRACKED', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isBound) ...[
                            Text(bound['title'] as String? ?? widget.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Status: ${bound['status'] ?? "Reading"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 16),
                                Text('Ch: ${bound['lastChapterRead'] ?? 0} / ${bound['totalChapters'] ?? "?"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                const SizedBox(width: 16),
                                Text('Score: ${bound['score'] ?? "-"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 16),
                                  label: const Text('Unbind', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                  onPressed: () => _unbindRecord(bound['id'] as int),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text('Not linked with this tracker.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor.withAlpha(40),
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.search_rounded, size: 18),
                                label: const Text('Search & Bind'),
                                onPressed: () {
                                  _searchQuery = widget.mangaTitle;
                                  _searchTracker(trackerId);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchTrackerView(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _searchingTrackerId = null),
              ),
              const Expanded(
                child: Text('Select Tracker Match', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: TextEditingController(text: _searchQuery),
            onSubmitted: (val) {
              _searchQuery = val;
              _searchTracker(_searchingTrackerId!);
            },
            decoration: InputDecoration(
              hintText: 'Search title...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _searchTracker(_searchingTrackerId!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _searchResults.isEmpty
                    ? const Center(child: Text('No matching manga found.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final res = _searchResults[index];
                          final title = res['title'] as String? ?? 'Title';
                          final totalCh = res['totalChapters'] as int? ?? 0;
                          final remoteId = res['remoteId'] as int? ?? res['id'] as int? ?? 0;

                          final cover = res['coverUrl'] as String?;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Material(
                              color: const Color(0x1F2A2A32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                              ),
                              child: ListTile(
                                leading: (cover != null && cover.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          cover,
                                          width: 44,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(width: 44, height: 56, color: const Color(0xFF2A2A32), child: const Icon(Icons.broken_image_rounded, size: 16)),
                                        ),
                                      )
                                    : Container(width: 44, height: 56, decoration: BoxDecoration(color: const Color(0xFF2A2A32), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_rounded, size: 20)),
                                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text('$totalCh Chapters • Score: ${res["score"] ?? "-"}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  child: const Text('Bind', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  onPressed: () => _bindManga(_searchingTrackerId!, remoteId),
                                ),
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
