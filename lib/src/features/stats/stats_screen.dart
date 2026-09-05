import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  int _totalManga = 0;
  int _totalChapters = 0;
  int _totalReadChapters = 0;
  int _totalReadTimeSeconds = 0;
  Map<String, int> _genreCounts = {};
  Map<String, int> _sourceCounts = {};

  int _readingStreakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final mangas = await IsarService.instance.getLibraryManga();
      final historyChapters = await IsarService.instance.getReadingHistory();

      _totalManga = mangas.length;
      int allChCount = 0;
      int readChCount = 0;
      final genres = <String, int>{};
      final sources = <String, int>{};

      for (final m in mangas) {
        final chs = await IsarService.instance.getChaptersForManga(m.serverId);
        allChCount += chs.length;
        readChCount += chs.where((c) => c.isRead).length;

        for (final g in m.genres) {
          genres[g] = (genres[g] ?? 0) + 1;
        }

        final src = m.sourceName.isNotEmpty ? m.sourceName : 'Unknown';
        sources[src] = (sources[src] ?? 0) + 1;
      }

      // Calculate streak
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final uniqueDays = <DateTime>{};
      for (final ch in historyChapters) {
        final ts = ch.lastReadAt ?? 0;
        if (ts > 0) {
          final dt = ts > 1000000000000
              ? DateTime.fromMillisecondsSinceEpoch(ts)
              : DateTime.fromMillisecondsSinceEpoch(ts * 1000);
          uniqueDays.add(DateTime(dt.year, dt.month, dt.day));
        }
      }
      int streak = 0;
      var checkDate = today;
      if (!uniqueDays.contains(checkDate)) {
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      }
      while (uniqueDays.contains(checkDate)) {
        streak++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      }

      // Estimate reading time: 4 minutes per read chapter
      _totalReadTimeSeconds = readChCount * 240;

      if (mounted) {
        setState(() {
          _totalChapters = allChCount;
          _totalReadChapters = readChCount;
          _genreCounts = genres;
          _sourceCounts = sources;
          _readingStreakDays = streak;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatReadingTime(int seconds) {
    final duration = Duration(seconds: seconds);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isTablet = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: const Text('Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/more');
            }
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
              children: [
                // ── SUMMARY CARDS ──
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Reading Streak', '$_readingStreakDays days', Icons.local_fire_department_rounded, Colors.orangeAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Chapters Read', '$_totalReadChapters', Icons.check_circle_rounded, Colors.greenAccent)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Library Manga', '$_totalManga', Icons.auto_stories_rounded, primaryColor)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricCard('Est. Read Time', _formatReadingTime(_totalReadTimeSeconds), Icons.timer_rounded, Colors.cyanAccent)),
                  ],
                ),

                const SizedBox(height: 24),

                // ── READ PROGRESS BAR ──
                Text('OVERALL READING PROGRESS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 8),
                Material(
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
                            const Text('Chapters Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _totalChapters > 0 ? '${((_totalReadChapters / _totalChapters) * 100).toStringAsFixed(1)}%' : '0%',
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _totalChapters > 0 ? (_totalReadChapters / _totalChapters).clamp(0.0, 1.0) : 0.0,
                            minHeight: 8,
                            backgroundColor: const Color(0x33FFFFFF),
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── TOP GENRES ──
                if (_genreCounts.isNotEmpty) ...[
                  Text('TOP GENRES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Material(
                    color: const Color(0x1F2A2A32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: _genreCounts.entries.take(6).map((entry) {
                          final ratio = _totalManga > 0 ? (entry.value / _totalManga).clamp(0.0, 1.0) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                SizedBox(width: 90, child: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 6,
                                      backgroundColor: const Color(0x26FFFFFF),
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── SOURCES BREAKDOWN ──
                if (_sourceCounts.isNotEmpty) ...[
                  Text('SOURCES IN LIBRARY', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Material(
                    color: const Color(0x1F2A2A32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                    ),
                    child: Column(
                      children: _sourceCounts.entries.map((e) {
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.source_rounded, color: primaryColor, size: 20),
                          title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          trailing: Text('${e.value} manga', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Material(
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
