import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _trackerSearchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Tracker status mapping
  static const Map<int, String> statusNames = {
    1: 'Reading',
    2: 'Completed',
    3: 'On Hold',
    4: 'Dropped',
    5: 'Plan to Read',
    6: 'Re-Reading',
  };

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.mangaTitle;
    _trackerSearchController.text = widget.mangaTitle;
    _loadTrackingData();
  }

  @override
  void dispose() {
    _trackerSearchController.dispose();
    super.dispose();
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

  Future<void> _bindManga(int trackerId, dynamic remoteId) async {
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

  void _showEditTrackDialog(Map<String, dynamic> record, String trackerName) {
    final recordId = parseIntSafe(record['id']);
    int currentStatus = parseIntSafe(record['status'], 1);
    double currentChapter = parseDoubleSafe(record['lastChapterRead']);
    int totalChapters = parseIntSafe(record['totalChapters']);
    double currentScore = parseDoubleSafe(record['score']);
    
    // Convert timestamp or string to human-readable format
    String? startEpochStr = record['startDate']?.toString();
    String? finishEpochStr = record['finishDate']?.toString();
    if (startEpochStr == '0') startEpochStr = null;
    if (finishEpochStr == '0') finishEpochStr = null;

    String startDisplay = '';
    if (startEpochStr != null && int.tryParse(startEpochStr) != null) {
      startDisplay = DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(startEpochStr)));
    }
    String finishDisplay = '';
    if (finishEpochStr != null && int.tryParse(finishEpochStr) != null) {
      finishDisplay = DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(finishEpochStr)));
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final primaryColor = Theme.of(dialogCtx).colorScheme.primary;

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.track_changes_rounded, color: primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      record['title'] as String? ?? widget.mangaTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // ── STATUS ──────────────────────────────────────────
                    const Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: const Color(0x1F2A2A32), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x2BFFFFFF))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentStatus,
                          dropdownColor: const Color(0xFF1F1F24),
                          isExpanded: true,
                          items: statusNames.entries.map((e) {
                            return DropdownMenuItem<int>(
                              value: e.key,
                              child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => currentStatus = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── CHAPTER READ (WITH +/- BUTTONS) ───────────────────
                    const Text('CHAPTERS READ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0x1F2A2A32), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x2BFFFFFF))),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.grey),
                            onPressed: currentChapter > 0 ? () => setDialogState(() => currentChapter--) : null,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${currentChapter.toInt()} / ${totalChapters > 0 ? totalChapters : "?"}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor),
                            onPressed: () => setDialogState(() => currentChapter++),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SCORE (0 - 10) ──────────────────────────────────
                    const Text('SCORE (0 - 10)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: const Color(0x1F2A2A32), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x2BFFFFFF))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          value: (currentScore >= 0 && currentScore <= 10) ? currentScore : 0.0,
                          dropdownColor: const Color(0xFF1F1F24),
                          isExpanded: true,
                          items: [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0].map((s) {
                            return DropdownMenuItem<double>(
                              value: s,
                              child: Text(s == 0.0 ? 'No Score (-)' : '$s / 10 ★', style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => currentScore = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── START DATE & FINISH DATE ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('START DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.calendar_today_rounded, size: 14),
                                label: Text(startDisplay.isNotEmpty ? startDisplay : 'Set Date', style: const TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: dialogCtx,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2035),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      startDisplay = DateFormat('MM/dd/yyyy').format(picked);
                                      startEpochStr = picked.millisecondsSinceEpoch.toString();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FINISH DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.event_available_rounded, size: 14),
                                label: Text(finishDisplay.isNotEmpty ? finishDisplay : 'Set Date', style: const TextStyle(fontSize: 11)),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: dialogCtx,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2035),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      finishDisplay = DateFormat('MM/dd/yyyy').format(picked);
                                      finishEpochStr = picked.millisecondsSinceEpoch.toString();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    setState(() => _isLoading = true);
                    await GraphQLClientService.instance.updateTrack(
                      recordId: recordId,
                      lastChapterRead: currentChapter,
                      status: currentStatus,
                      scoreString: currentScore > 0 ? (currentScore.truncateToDouble() == currentScore ? currentScore.toInt().toString() : currentScore.toString()) : null,
                      startDate: startEpochStr,
                      finishDate: finishEpochStr,
                    );
                    await _loadTrackingData();
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
                final trackerId = parseIntSafe(t['id']);
                final trackerName = t['name'] as String? ?? 'Tracker';
                final bound = _boundRecords.firstWhere(
                  (r) => parseIntSafe(r['trackerId']) == trackerId,
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: isBound ? () => _showEditTrackDialog(bound, trackerName) : null,
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
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0x2BFFFFFF), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      statusNames[parseIntSafe(bound['status'], 1)] ?? 'Reading',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0x2BFFFFFF), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Ch: ${parseIntSafe(bound["lastChapterRead"])} / ${bound["totalChapters"] != null ? parseIntSafe(bound["totalChapters"]) : "?"}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0x2BFFFFFF), borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      'Score: ${bound["score"] != null ? parseDoubleSafe(bound["score"]) : "-"}',
                                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tap card to edit status & progress', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
                                  TextButton.icon(
                                    icon: const Icon(Icons.link_off_rounded, color: Colors.redAccent, size: 16),
                                    label: const Text('Unbind', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                    onPressed: () => _unbindRecord(parseIntSafe(bound['id'])),
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
                                    _trackerSearchController.text = widget.mangaTitle;
                                    _searchTracker(trackerId);
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
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
            controller: _trackerSearchController,
            onChanged: (val) => _searchQuery = val,
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
                          final totalCh = (res['totalChapters'] as num?)?.toInt() ?? 0;
                          final remoteId = res['remoteId'] ?? res['id'] ?? '0';

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
