import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/logging/logger_service.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../ui/design_system/sunfire_theme.dart';
import '../settings/tracking_settings_screen.dart';

/// Tracker start/finish date label. Follows General → Date Format (UIS-P3-3)
/// instead of a hard-coded US `MM/dd/yyyy`.
String trackingDateLabel(DateTime date) => SettingsService.instance.formatDate(date);

class TrackingBottomSheet extends StatefulWidget {
  final int mangaServerId;
  final String mangaTitle;

  const TrackingBottomSheet({
    super.key,
    required this.mangaServerId,
    required this.mangaTitle,
  });

  static Future<void> show(BuildContext context, int mangaServerId, String mangaTitle) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
  static const int kMetronTrackerId = -99;

  bool _isLoading = true;
  List<Map<String, dynamic>> _trackers = [];
  List<Map<String, dynamic>> _boundRecords = [];
  Map<int, TrackerInfo> _trackerInfoById = {};
  Manga? _localManga;

  // Search mode state
  int? _searchingTrackerId;
  String _searchQuery = '';
  final TextEditingController _trackerSearchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isScrobbling = false;

  /// Monotonic token so a slow/stale search response can never clobber the
  /// results of a newer search (metron unlink/search race, finding #21/#22).
  int _searchGeneration = 0;

  // Tracker status mapping
  static const Map<int, String> statusNames = {
    1: 'Reading',
    2: 'Completed',
    3: 'On Hold',
    4: 'Dropped',
    5: 'Plan to Read',
    6: 'Re-Reading',
  };


  Map<int, String> _statusesFor(int trackerId) {
    final info = _trackerInfoById[trackerId];
    if (info != null && info.statuses.isNotEmpty) {
      return {for (final s in info.statuses) s.value: s.name};
    }
    return statusNames;
  }

  String _statusLabel(int trackerId, int status) {
    return _statusesFor(trackerId)[status] ?? statusNames[status] ?? 'Unknown';
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.mangaTitle;
    _trackerSearchController.text = widget.mangaTitle;
    unawaited(_loadTrackingData());
  }

  @override
  void dispose() {
    _trackerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrackingData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // 1. Load local manga for Metron status
    try {
      _localManga = await IsarService.instance.getMangaByServerId(widget.mangaServerId);
    } catch (ignoredError) { if (kDebugMode) debugPrint('[tracking_bottom_sheet] ignored error: $ignoredError'); }

    // 2. Load server trackers if connected
    if (!GraphQLClientService.instance.isConfigured) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final infos = await GraphQLClientService.instance.fetchTrackerInfos();
      final recordInfos = await GraphQLClientService.instance.fetchTrackRecordInfos(widget.mangaServerId);

      if (infos != null) {
        final byId = {for (final i in infos) i.id: i};
        final trackerMaps = [
          for (final i in infos)
            <String, dynamic>{
              'id': i.id,
              'name': i.name,
              'icon': i.icon,
              'authUrl': i.authUrl,
              'isLoggedIn': i.isLoggedIn,
              'isTokenExpired': i.isTokenExpired,
              'supportsPrivateTracking': i.supportsPrivateTracking,
            },
        ];
        List<Map<String, dynamic>> recordMaps;
        if (recordInfos != null) {
          recordMaps = [
            for (final r in recordInfos)
              <String, dynamic>{
                'id': r.id,
                'mangaId': r.mangaId,
                'trackerId': r.trackerId,
                'remoteId': r.remoteId,
                'remoteUrl': r.remoteUrl,
                'title': r.title,
                'status': r.status,
                'lastChapterRead': r.lastChapterRead,
                'totalChapters': r.totalChapters,
                'score': r.score,
                'displayScore': r.displayScore,
                'startDate': r.startDate,
                'finishDate': r.finishDate,
                'private': r.isPrivate,
              },
          ];
        } else {
          final recordsData = await GraphQLClientService.instance.fetchTrackRecords(widget.mangaServerId);
          final rawRecords = recordsData?['trackRecords']?['nodes'] as List<dynamic>? ?? [];
          recordMaps = rawRecords.map((r) => Map<String, dynamic>.from(r as Map)).toList();
        }
        if (mounted) {
          setState(() {
            _trackerInfoById = byId;
            _trackers = trackerMaps;
            _boundRecords = recordMaps;
            _isLoading = false;
          });
        }
      } else {
        final trackersData = await GraphQLClientService.instance.fetchTrackers();
        final recordsData = await GraphQLClientService.instance.fetchTrackRecords(widget.mangaServerId);
        final rawTrackers = trackersData?['trackers']?['nodes'] as List<dynamic>? ?? [];
        final rawRecords = recordsData?['trackRecords']?['nodes'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _trackerInfoById = {};
            _trackers = rawTrackers.map((t) => Map<String, dynamic>.from(t as Map)).toList();
            _boundRecords = rawRecords.map((r) => Map<String, dynamic>.from(r as Map)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Failed to fetch trackers: $e', exception: e, stackTrace: stack, category: 'Tracking'));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchTracker(int trackerId) async {
    if (!mounted) return;
    final searchGen = ++_searchGeneration;
    setState(() {
      _searchingTrackerId = trackerId;
      _isSearching = true;
      _searchResults = [];
    });

    if (trackerId == kMetronTrackerId) {
      // Search Metron
      // No token -> no request. The card already shows "token not
      // configured" with a Configure shortcut; firing an anonymous search
      // would 401 and log an ERROR + stack trace per attempt for nothing.
      if (!MetronService.instance.isConfigured) {
        if (mounted && searchGen == _searchGeneration) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
        return;
      }
      try {
        final query = _searchQuery.isEmpty ? widget.mangaTitle : _searchQuery;
        final res = await MetronService.instance.searchSeries(query: query);
        // Ignore the response if a newer search was started meanwhile.
        if (mounted && searchGen == _searchGeneration) {
          setState(() {
            _searchResults = res.series.map((s) => {
              'title': s.displayName,
              'remoteId': s.id,
              'coverUrl': s.image,
              'totalChapters': s.issueCount,
              'publisher': s.publisher?.name,
              'status': s.status,
              'isMetron': true,
            }).toList();
            _isSearching = false;
          });
        }
      } catch (e, stack) {
        unawaited(LoggerService.instance.logError('Failed to search Metron: $e', exception: e, stackTrace: stack, category: 'Metron'));
        if (mounted && searchGen == _searchGeneration) setState(() => _isSearching = false);
      }
      return;
    }

    try {
      final data = await GraphQLClientService.instance.searchTracker(trackerId, _searchQuery.isEmpty ? widget.mangaTitle : _searchQuery);
      final list = data?['searchTracker']?['trackSearches'] as List<dynamic>? ?? [];
      // Ignore the response if a newer search was started meanwhile.
      if (mounted && searchGen == _searchGeneration) {
        setState(() {
          _searchResults = list.map((n) => n as Map<String, dynamic>).toList();
          _isSearching = false;
        });
      }
    } catch (e, stack) {
      unawaited(LoggerService.instance.logError('Failed to search tracker: $e', exception: e, stackTrace: stack, category: 'Tracking'));
      if (mounted && searchGen == _searchGeneration) setState(() => _isSearching = false);
    }
  }

  Future<void> _bindManga(int trackerId, dynamic remoteId) async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);
    _searchingTrackerId = null;

    if (trackerId == kMetronTrackerId) {
      try {
        final seriesId = int.parse(remoteId.toString());
        final detail = await MetronService.instance.getSeriesDetail(seriesId);
        final issuesData = await MetronService.instance.getSeriesIssues(seriesId);

        final issueMapJson = issuesData.issueMap.map((k, v) => MapEntry('"$k"', v.toString()));
        final jsonStr = '{${issueMapJson.entries.map((e) => '${e.key}:${e.value}').join(',')}}';

        _localManga ??= await IsarService.instance.getMangaByServerId(widget.mangaServerId);
        if (_localManga != null) {
          _localManga!.metronSeriesId = seriesId;
          _localManga!.publisher = detail.publisher?.name;
          _localManga!.isMetadataLocked = true;
          _localManga!.metronIssuesJson = jsonStr;

          if (detail.description != null && detail.description!.isNotEmpty) {
            _localManga!.description = detail.description;
          }
          if (detail.genres.isNotEmpty) {
            _localManga!.genres = detail.genres;
          }
          if (detail.status != null && detail.status!.isNotEmpty) {
            _localManga!.status = detail.status;
          }

          await IsarService.instance.saveManga(_localManga!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Linked to "${detail.name}"! Metadata enriched & locked.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, st) {
        unawaited(LoggerService.instance.logError('Failed to bind Metron: $e', exception: e, stackTrace: st, category: 'Metron'));
      }
      await _loadTrackingData();
      return;
    }

    try {
      await GraphQLClientService.instance.bindTrack(widget.mangaServerId, trackerId, remoteId);
      await _loadTrackingData();
    } catch (e, st) {
      unawaited(LoggerService.instance.logError('Failed to bind tracker: $e', exception: e, stackTrace: st, category: 'Tracking'));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to link this series to the tracker.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  Future<void> _unlinkMetron() async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);
    if (_localManga != null) {
      _localManga!.metronSeriesId = null;
      _localManga!.publisher = null;
      _localManga!.metronIssuesJson = null;
      _localManga!.isMetadataLocked = false;
      await IsarService.instance.saveManga(_localManga!);
    }
    await _loadTrackingData();
  }

  Future<void> _scrobbleAllReadChapters() async {
    if (!mounted || _isScrobbling) return;
    if (_localManga == null || _localManga!.metronSeriesId == null) return;
    // Incognito promises nothing is pushed to trackers — including an
    // explicit "scrobble all". Same guard + snackbar as the read paths.
    if (SettingsService.instance.incognitoMode) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incognito Mode is on — tracking is paused')),
        );
      }
      return;
    }
    setState(() => _isScrobbling = true);

    try {
      // Key on the manga's canonical id, never its local Isar id.
      // getChaptersForManga is keyed on chapter.mangaId, which is always the
      // parent's serverId (negative synthetic for local-only series). Querying
      // by the local auto-increment id instead returns whichever *other*
      // series has that serverId, and _scrobbleAllReadChapters then pushes
      // their chapter numbers to MAL/AniList — permanently corrupting tracker
      // progress for an unrelated series, with a success snackbar.
      final mId = _localManga?.canonicalKey ?? widget.mangaServerId;
      var chapters = await IsarService.instance.getChaptersForManga(mId);
      if (chapters.isEmpty && widget.mangaServerId != mId) {
        chapters = await IsarService.instance.getChaptersForManga(widget.mangaServerId);
      }
      final readChapters = chapters.where((c) => c.isRead).toList();

      int scrobbledCount = 0;
      for (final ch in readChapters) {
        final ok = await MetronService.instance.scrobbleMangaChapter(
          manga: _localManga!,
          chapter: ch,
        );
        if (ok) scrobbledCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scrobbled $scrobbledCount read issues to Metron!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, st) {
      unawaited(LoggerService.instance.logError('Failed to scrobble read chapters: $e', exception: e, stackTrace: st, category: 'Metron'));
    } finally {
      if (mounted) setState(() => _isScrobbling = false);
    }
  }

  Future<void> _unbindRecord(int recordId) async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await GraphQLClientService.instance.unbindTrack(recordId);
      await _loadTrackingData();
    } catch (e, st) {
      unawaited(LoggerService.instance.logError('Failed to unbind tracker: $e', exception: e, stackTrace: st, category: 'Tracking'));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to unlink the tracking record.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  /// Normalizes a track-record date value (epoch ms or seconds) to epoch
  /// milliseconds. Suwayomi stores these as ms, but legacy rows or other
  /// clients may write seconds; treat any value < 1e12 as seconds (ms values
  /// for the supported date range are >= 1e12). Returns null for 0/empty/invalid.
  String? _normalizeTrackEpoch(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str == '0' || str == 'null') return null;
    final parsed = int.tryParse(str);
    if (parsed == null || parsed <= 0) return null;
    final ms = (normalizeEpochToSeconds(parsed) ?? 0) * 1000;
    return ms.toString();
  }

  void _showEditTrackDialog(Map<String, dynamic> record, String trackerName) {
    final recordId = parseIntSafe(record['id']);
    final trackerId = parseIntSafe(record['trackerId']);
    final info = _trackerInfoById[trackerId];
    final statusMap = _statusesFor(trackerId);
    int currentStatus = parseIntSafe(record['status'], 1);
    // Suwayomi/other clients may return a status the app does not know about
    // (e.g. 0 or 7+); clamp to a known value so DropdownButton's
    // "exactly one item with value" assert never fires (finding #20).
    if (!statusMap.containsKey(currentStatus)) {
      currentStatus = statusMap.keys.isNotEmpty ? statusMap.keys.first : 1;
    }
    double currentChapter = parseDoubleSafe(record['lastChapterRead']);
    int totalChapters = parseIntSafe(record['totalChapters']);
    double currentScore = parseDoubleSafe(record['score']);
    bool isPrivate = record['private'] == true;
    final supportsPrivate = info?.supportsPrivateTracking == true;
    final serverScores = info?.scores ?? const <String>[];
    // Prefer server score strings when the tracker publishes them (passed
    // verbatim as `scoreString` on save). Preselect the record's existing
    // score when it matches a published string.
    final rawScoreStr = record['score']?.toString().trim() ?? '';
    String? selectedServerScore = serverScores.contains(rawScoreStr)
        ? rawScoreStr
        : (currentScore > 0 && serverScores.contains(currentScore.toInt().toString())
            ? currentScore.toInt().toString()
            : null);
    // Suwayomi store dates as epoch ms, but be defensive: some legacy rows /
    // other clients may carry seconds. Normalize to ms for display and save.
    String? startEpochStr = _normalizeTrackEpoch(record['startDate']);
    String? finishEpochStr = _normalizeTrackEpoch(record['finishDate']);

    String startDisplay = '';
    if (startEpochStr != null) {
      startDisplay = trackingDateLabel(DateTime.fromMillisecondsSinceEpoch(int.parse(startEpochStr)));
    }
    String finishDisplay = '';
    if (finishEpochStr != null) {
      finishDisplay = trackingDateLabel(DateTime.fromMillisecondsSinceEpoch(int.parse(finishEpochStr)));
    }

    unawaited(showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final cs = Theme.of(dialogCtx).colorScheme;
        final primaryColor = cs.primary;

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: cs.surfaceContainerHigh,
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
                      decoration: BoxDecoration(color: SunfireTheme.tileSurface(dialogCtx), borderRadius: BorderRadius.circular(12), border: Border.all(color: SunfireTheme.tileBorder(dialogCtx))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentStatus,
                          dropdownColor: cs.surfaceContainerHigh,
                          isExpanded: true,
                          items: statusMap.entries.map((e) {
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
                      decoration: BoxDecoration(color: SunfireTheme.tileSurface(dialogCtx), borderRadius: BorderRadius.circular(12), border: Border.all(color: SunfireTheme.tileBorder(dialogCtx))),
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
                            onPressed: totalChapters > 0 && currentChapter >= totalChapters
                                ? null
                                : () => setDialogState(() {
                                    currentChapter++;
                                    // Clamp at total chapters when known (finding #24).
                                    if (totalChapters > 0 && currentChapter > totalChapters) {
                                      currentChapter = totalChapters.toDouble();
                                    }
                                  }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── SCORE ─────────────────────────────────────────────
                    // Server-published score strings win when the tracker
                    // provides them (saved verbatim); otherwise the numeric
                    // 0–10 picker is kept.
                    Text(
                      serverScores.isNotEmpty ? 'SCORE' : 'SCORE (0 - 10)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: SunfireTheme.tileSurface(dialogCtx), borderRadius: BorderRadius.circular(12), border: Border.all(color: SunfireTheme.tileBorder(dialogCtx))),
                      child: DropdownButtonHideUnderline(
                        child: serverScores.isNotEmpty
                            ? DropdownButton<String?>(
                                value: selectedServerScore,
                                dropdownColor: cs.surfaceContainerHigh,
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('No Score (-)', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  for (final s in serverScores)
                                    DropdownMenuItem<String?>(
                                      value: s,
                                      child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                ],
                                onChanged: (val) {
                                  setDialogState(() => selectedServerScore = val);
                                },
                              )
                            : DropdownButton<double>(
                          // Server scores can be fractional (e.g. 6.5) while the
                          // picker only offers integer steps; snap the displayed
                          // value to an existing item so DropdownButton's
                          // "exactly one item with value" assert never fires.
                          // `currentScore` itself stays untouched for saving.
                          value: currentScore < 0 || currentScore > 10
                              ? 0.0
                              : (currentScore.roundToDouble().clamp(0.0, 10.0)),
                          dropdownColor: cs.surfaceContainerHigh,
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
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
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
                                            startDisplay = trackingDateLabel(picked);
                                            startEpochStr = picked.millisecondsSinceEpoch.toString();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  if (startDisplay.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 15, color: Colors.grey),
                                      tooltip: 'Clear start date',
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => setDialogState(() {
                                        startDisplay = '';
                                        startEpochStr = null;
                                      }),
                                    ),
                                ],
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
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
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
                                            finishDisplay = trackingDateLabel(picked);
                                            finishEpochStr = picked.millisecondsSinceEpoch.toString();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  if (finishDisplay.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 15, color: Colors.grey),
                                      tooltip: 'Clear finish date',
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => setDialogState(() {
                                        finishDisplay = '';
                                        finishEpochStr = null;
                                      }),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (supportsPrivate) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Private', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Hide this title on the tracker', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        value: isPrivate,
                        onChanged: (v) => setDialogState(() => isPrivate = v),
                      ),
                    ],
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
                    if (!mounted) return;
                    setState(() => _isLoading = true);
                    try {
                      await GraphQLClientService.instance.updateTrack(
                        recordId: recordId,
                        lastChapterRead: currentChapter,
                        status: currentStatus,
                        scoreString: serverScores.isNotEmpty
                            ? selectedServerScore
                            : (currentScore > 0 ? (currentScore.truncateToDouble() == currentScore ? currentScore.toInt().toString() : currentScore.toString()) : null),
                        startDate: startEpochStr,
                        finishDate: finishEpochStr,
                        isPrivate: supportsPrivate ? isPrivate : null,
                      );
                      await _loadTrackingData();
                    } catch (e, st) {
                      unawaited(LoggerService.instance.logError('Failed to update tracking record: $e', exception: e, stackTrace: st, category: 'Tracking'));
                      if (mounted) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Failed to save tracking changes.'),
                          backgroundColor: Colors.redAccent,
                        ));
                      }
                    }
                  },
                  child: Text('Save Changes', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ));
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

            // ── METRON (WESTERN COMICS) TRACKER ──
            _buildMetronTrackerCard(primaryColor),
            const SizedBox(height: 12),

            // ── SERVER MANGA TRACKERS ──
            if (_trackers.isEmpty) ...[
              _buildEmptyServerTrackersCard(context, primaryColor),
            ] else ...[
              ..._trackers.map((t) => _buildServerTrackerCard(t, primaryColor)),
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
              unawaited(_searchTracker(_searchingTrackerId!));
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
                              color: SunfireTheme.tileSurface(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: SunfireTheme.tileBorder(context), width: 0.8),
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
                                          errorBuilder: (_, __, ___) => Container(width: 44, height: 56, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.broken_image_rounded, size: 16)),
                                        ),
                                      )
                                    : Container(width: 44, height: 56, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_rounded, size: 20)),
                                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text('$totalCh Chapters • Score: ${res["score"] ?? "-"}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  child: Text('Bind', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildMetronTrackerCard(Color primaryColor) {
    final isMetronConfigured = MetronService.instance.isConfigured;
    final isLinked = _localManga?.metronSeriesId != null;
    final issueCount = _localManga?.metronIssuesJson != null
        ? _getIssueCount(_localManga!.metronIssuesJson!)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: SunfireTheme.tileSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLinked
              ? Colors.blueAccent.withValues(alpha: 0.5)
              : isMetronConfigured
                  ? Colors.blueAccent.withValues(alpha: 0.2)
                  : SunfireTheme.tileBorder(context),
          width: isLinked ? 1.5 : 1.0,
        ),
        boxShadow: isLinked
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, and status
            Row(
              children: [
                // Status ring + icon
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isLinked
                            ? Colors.blueAccent.withValues(alpha: 0.15)
                            : isMetronConfigured
                                ? Colors.blueAccent.withValues(alpha: 0.08)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isLinked
                              ? Colors.blueAccent.withValues(alpha: 0.5)
                              : isMetronConfigured
                                  ? Colors.blueAccent.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          color: isLinked
                              ? Colors.blueAccent
                              : isMetronConfigured
                                  ? Colors.blueAccent.withValues(alpha: 0.7)
                                  : Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                    // Connection status dot
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isLinked
                              ? Colors.blueAccent
                              : isMetronConfigured
                                  ? Colors.greenAccent
                                  : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metron.cloud (Western Comics)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isLinked || isMetronConfigured
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isLinked
                                  ? Colors.blueAccent
                                  : isMetronConfigured
                                      ? Colors.greenAccent
                                      : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLinked
                                ? 'Linked & Enriched'
                                : isMetronConfigured
                                    ? 'Connected — Not Linked'
                                    : 'Not Configured',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLinked
                                  ? Colors.blueAccent
                                  : isMetronConfigured
                                      ? Colors.greenAccent
                                      : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                if (isLinked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.link_rounded, size: 12, color: Colors.blueAccent),
                        const SizedBox(width: 4),
                        Text(
                          'LINKED',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (isLinked) ...[
              // Linked state - show rich metadata
              _buildLinkedMetadata(context, issueCount),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        // Colors.blueAccent is dark enough for white text
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      icon: _isScrobbling
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFFFFFFFF),
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: Text(
                        _isScrobbling ? 'Scrobbling...' : 'Scrobble All Read Chapters',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _isScrobbling ? null : _scrobbleAllReadChapters,
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Icons.link_off_rounded, size: 18),
                    label: const Text('Unlink', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: _unlinkMetron,
                  ),
                ],
              ),
            ] else ...[
              // Not linked states
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isMetronConfigured
                      ? Colors.blueAccent.withValues(alpha: 0.05)
                      : Colors.amberAccent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMetronConfigured
                        ? Colors.blueAccent.withValues(alpha: 0.2)
                        : Colors.amberAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMetronConfigured ? Icons.info_outline_rounded : Icons.warning_amber_rounded,
                      color: isMetronConfigured ? Colors.blueAccent : Colors.amberAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMetronConfigured
                            ? 'This manga is not linked to a Metron series. Link it to enable automatic scrobbling and metadata enrichment.'
                            : 'Metron.cloud is not configured. Add your API token in Settings → Tracking to enable western comics tracking.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMetronConfigured
                              ? Colors.blueAccent.withValues(alpha: 0.8)
                              : Colors.amberAccent.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Primary action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMetronConfigured ? Colors.blueAccent : Colors.amberAccent,
                    // blueAccent is dark enough for white; amberAccent is light enough for black
                    foregroundColor: isMetronConfigured ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  icon: Icon(
                    isMetronConfigured ? Icons.search_rounded : Icons.settings_rounded,
                    size: 20,
                  ),
                  label: Text(
                    isMetronConfigured ? 'Match & Enrich This Manga' : 'Configure Metron.cloud',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: isMetronConfigured
                      ? () {
                          _searchQuery = widget.mangaTitle;
                          _trackerSearchController.text = widget.mangaTitle;
                          unawaited(_searchTracker(kMetronTrackerId));
                        }
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (context) => const TrackingSettingsScreen()),
                          );
                          setState(() {});
                        },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedMetadata(BuildContext context, int issueCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Publisher + Issue count row
        Row(
          children: [
            Expanded(
              child: _buildMetadataChip(
                context,
                icon: Icons.menu_book_rounded,
                label: 'Publisher',
                value: _localManga?.publisher ?? 'Unknown Publisher',
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetadataChip(
                context,
                icon: Icons.confirmation_number_rounded,
                label: 'Issues in Series',
                value: issueCount > 0 ? '$issueCount issues' : 'Unknown',
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Locked metadata indicator
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Metadata Locked & Enriched',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Series ID for debugging
            if (_localManga?.metronSeriesId != null)
              Text(
                'Series ID: ${_localManga!.metronSeriesId}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.withValues(alpha: 0.6),
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _getIssueCount(String issuesJson) {
    try {
      final map = jsonDecode(issuesJson) as Map<String, dynamic>;
      return map.length;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildEmptyServerTrackersCard(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.track_changes_outlined,
                size: 48,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No Server Trackers Found',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Connect a Suwayomi server in Settings → Server to track manga via AniList, MyAnimeList, or Kitsu. Once connected and authorized, your trackers will appear here.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Open Server Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: const Color(0xFF000000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings/server');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerTrackerCard(Map<String, dynamic> t, Color primaryColor) {
    final trackerId = parseIntSafe(t['id']);
    final trackerName = t['name'] as String? ?? 'Tracker';
    final isLoggedIn = t['isLoggedIn'] == true;
    final authUrl = t['authUrl'] as String?;
    final tokenExpired = t['isTokenExpired'] == true;
    final iconName = t['icon'] as String?;

    final bound = _boundRecords.firstWhere(
      (r) => parseIntSafe(r['trackerId']) == trackerId,
      orElse: () => <String, dynamic>{},
    );
    final isBound = bound.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isBound
              ? Colors.greenAccent.withValues(alpha: 0.03)
              : isLoggedIn
                  ? primaryColor.withValues(alpha: 0.03)
                  : SunfireTheme.tileSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBound
                ? Colors.greenAccent.withValues(alpha: 0.5)
                : isLoggedIn
                    ? primaryColor.withValues(alpha: 0.3)
                    : SunfireTheme.tileBorder(context),
            width: isBound ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isBound ? () => _showEditTrackDialog(bound, trackerName) : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with tracker icon and status
                Row(
                  children: [
                    // Tracker icon with status ring
                    Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isBound
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : isLoggedIn
                                    ? primaryColor.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isBound
                                  ? Colors.greenAccent.withValues(alpha: 0.5)
                                  : isLoggedIn
                                      ? primaryColor.withValues(alpha: 0.5)
                                      : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: iconName != null && iconName.isNotEmpty
                                ? Image.network(
                                    iconName,
                                    width: 28,
                                    height: 28,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.track_changes_rounded,
                                      color: isBound ? Colors.greenAccent : (isLoggedIn ? primaryColor : Colors.grey),
                                      size: 24,
                                    ),
                                  )
                                : Icon(
                                    Icons.track_changes_rounded,
                                    color: isBound ? Colors.greenAccent : (isLoggedIn ? primaryColor : Colors.grey),
                                    size: 24,
                                  ),
                          ),
                        ),
                        // Connection status dot
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isBound
                                  ? Colors.greenAccent
                                  : isLoggedIn
                                      ? primaryColor
                                      : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Tracker name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isBound || isLoggedIn
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isBound
                                      ? Colors.greenAccent
                                      : isLoggedIn
                                          ? primaryColor
                                          : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isBound
                                    ? 'Tracking Active'
                                    : isLoggedIn
                                        ? 'Authorized — Not Linked'
                                        : tokenExpired
                                            ? 'Session Expired'
                                            : 'Not Authorized',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isBound
                                      ? Colors.greenAccent
                                      : isLoggedIn
                                          ? primaryColor
                                          : tokenExpired
                                              ? Colors.redAccent
                                              : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    if (isBound)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 12, color: Colors.greenAccent),
                            const SizedBox(width: 4),
                            const Text(
                              'TRACKING',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (!isLoggedIn && authUrl != null && authUrl.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amberAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        icon: const Icon(Icons.login_rounded, size: 14),
                        label: const Text('Log In', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          if (await canLaunchUrlString(authUrl)) {
                            await launchUrlString(authUrl, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                if (isBound) ...[
                  // Bound state - show tracking info
                  _buildBoundTrackerInfo(bound, trackerId),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tap card to edit status & progress',
                        style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        icon: const Icon(Icons.link_off_rounded, size: 14),
                        label: const Text('Unbind', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () => _unbindRecord(parseIntSafe(bound['id'])),
                      ),
                    ],
                  ),
                ] else ...[
                  // Not bound states
                  if (!isLoggedIn || tokenExpired) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tokenExpired
                            ? Colors.redAccent.withValues(alpha: 0.08)
                            : Colors.amberAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: tokenExpired
                              ? Colors.redAccent.withValues(alpha: 0.3)
                              : Colors.amberAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tokenExpired ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                            color: tokenExpired ? Colors.redAccent : Colors.amberAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tokenExpired
                                  ? 'Session expired — log in again to restore tracking.'
                                  : 'Not logged in on server. Authorize this tracker to enable tracking.',
                              style: TextStyle(
                                fontSize: 12,
                                color: tokenExpired
                                    ? Colors.redAccent.withValues(alpha: 0.8)
                                    : Colors.amberAccent.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (authUrl != null && authUrl.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.amberAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              icon: const Icon(Icons.login_rounded, size: 14),
                              label: const Text('Log In', style: TextStyle(fontWeight: FontWeight.w600)),
                              onPressed: () async {
                                if (await canLaunchUrlString(authUrl)) {
                                  await launchUrlString(authUrl, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoggedIn ? primaryColor : Colors.amberAccent,
                          // primaryColor uses theme's onPrimary; amberAccent is light -> black
                          foregroundColor: isLoggedIn
                              ? Theme.of(context).colorScheme.onPrimary
                              : const Color(0xFF000000),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: Text(
                          isLoggedIn ? 'Search & Bind' : 'Authorize Tracker',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: isLoggedIn
                            ? () {
                                _searchQuery = widget.mangaTitle;
                                _trackerSearchController.text = widget.mangaTitle;
                                unawaited(_searchTracker(trackerId));
                              }
                            : () async {
                                // authUrl is guaranteed non-null by outer condition (authUrl != null && authUrl.isNotEmpty)
                                final url = authUrl!;
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url, mode: LaunchMode.externalApplication);
                                }
                              },
                      ),
                    ),
                  ] else ...[
                    // Logged in but not linked
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This tracker is authorized but not linked to this manga. Search and bind to start tracking.',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.search_rounded, size: 18),
                        label: const Text('Search & Bind', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _searchQuery = widget.mangaTitle;
                          _trackerSearchController.text = widget.mangaTitle;
                          unawaited(_searchTracker(trackerId));
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoundTrackerInfo(Map<String, dynamic> bound, int trackerId) {
    final currentStatus = parseIntSafe(bound['status'], 1);
    final currentChapter = parseIntSafe(bound['lastChapterRead']);
    final totalChapters = parseIntSafe(bound['totalChapters']);
    final score = bound['score'] != null ? parseDoubleSafe(bound['score']) : null;
    final isPrivate = bound['private'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          bound['title'] as String? ?? widget.mangaTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 10),
        // Status chips row
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_rounded, size: 12, color: Colors.blueAccent),
                  const SizedBox(width: 4),
                  Text(
                    _statusLabel(trackerId, currentStatus),
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Chapter progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 12, color: Colors.purpleAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Ch: $currentChapter / ${totalChapters > 0 ? totalChapters : "?"}',
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            // Score
            if (score != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Score: ${score == score.roundToDouble() ? score.toInt() : score}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            // Private
            if (isPrivate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text(
                      'Private',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

