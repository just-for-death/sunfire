import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/db/isar_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/image_cache_helper.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_subpage_scaffold.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  int _mangaCount = 0;
  int _chapterCount = 0;
  int _categoryCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final manga = await IsarService.instance.getAllManga();
      final chapters = await IsarService.instance.getAllChapters();
      final cats = await IsarService.instance.getCategories();
      if (mounted) {
        setState(() {
          _mangaCount = manga.length;
          _chapterCount = chapters.length;
          _categoryCount = cats.length;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _showLogsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141419),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _LiveLogViewerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSubpageScaffold(
      title: 'Advanced & Diagnostics',
      onRefresh: _loadStats,
      body: ListView(
        children: [
          // ── 1. LOGS & CONSOLE ──
          const SectionTitle(title: 'Diagnostics & Telemetry'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: const Icon(Icons.terminal_rounded),
            title: Row(
              children: [
                const Text('Live Diagnostic Console', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: const Text('LOCAL', style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: const Text('Stream live app events, JS scrapers, network & errors', style: TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: _showLogsModal,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: const Icon(Icons.cleaning_services_rounded, color: Colors.redAccent),
            title: const Text('Clear Diagnostic Logs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('Truncate on-device log file and in-memory buffer', style: TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () async {
              await LoggerService.instance.clearLogs();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diagnostic logs cleared.')),
                );
              }
            },
          ),

          const Divider(height: 1, color: Color(0x1AFFFFFF)),

          // ── 2. CACHE & STORAGE ──
          const SectionTitle(title: 'Disk & Memory Cache'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orangeAccent),
            title: Row(
              children: [
                const Text('Clear Image Disk Cache', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: const Text('LOCAL', style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: const Text('Free cached cover thumbnails & manga page images', style: TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () async {
              await ImageCacheHelper.clearCache();
              imageCache.clear();
              imageCache.clearLiveImages();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image disk & memory cache cleared!')),
                );
              }
            },
          ),

          const Divider(height: 1, color: Color(0x1AFFFFFF)),

          // ── 3. DATABASE STATS ──
          const SectionTitle(title: 'Local Database (Isar)'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Database Statistics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: _isLoadingStats
                ? const Text('Loading database metrics...', style: TextStyle(fontSize: 12, color: Colors.grey))
                : Text('$_mangaCount manga entries • $_chapterCount cached chapters • $_categoryCount categories', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),

          const Divider(height: 1, color: Color(0x1AFFFFFF)),

          // ── 4. SYSTEM INFORMATION ──
          const SectionTitle(title: 'System Information'),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Sunfire Client Version', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: Text('v1.2.0 • Platform: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class _LiveLogViewerSheet extends StatefulWidget {
  const _LiveLogViewerSheet();

  @override
  State<_LiveLogViewerSheet> createState() => _LiveLogViewerSheetState();
}

class _LiveLogViewerSheetState extends State<_LiveLogViewerSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<LogEntry>? _subscription;
  List<LogEntry> _logs = [];
  String _selectedLevel = 'ALL';
  String _searchQuery = '';
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _logs = List.from(LoggerService.instance.inMemoryLogs);
    _subscription = LoggerService.instance.logStream.listen((entry) {
      if (!mounted) return;
      setState(() {
        _logs.add(entry);
        if (_logs.length > LoggerService.maxInMemoryLogs) {
          _logs.removeAt(0);
        }
      });
      if (_autoScroll && _scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> get _filteredLogs {
    return _logs.where((entry) {
      if (_selectedLevel != 'ALL' && entry.level != _selectedLevel) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchMsg = entry.message.toLowerCase().contains(q);
        final matchCat = (entry.category ?? '').toLowerCase().contains(q);
        final matchExc = (entry.exception?.toString() ?? '').toLowerCase().contains(q);
        if (!matchMsg && !matchCat && !matchExc) return false;
      }
      return true;
    }).toList();
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'ERROR':
        return Colors.redAccent;
      case 'WARN':
        return Colors.amberAccent;
      case 'NETWORK':
        return Colors.cyanAccent;
      case 'DEBUG':
        return Colors.purpleAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final filtered = _filteredLogs;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal_rounded, color: primaryColor),
              const SizedBox(width: 8),
              const Text('Live Diagnostics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: Icon(_autoScroll ? Icons.vertical_align_bottom_rounded : Icons.pause_rounded, color: _autoScroll ? primaryColor : Colors.grey),
                tooltip: _autoScroll ? 'Auto-scroll ON' : 'Auto-scroll PAUSED',
                onPressed: () => setState(() => _autoScroll = !_autoScroll),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                tooltip: 'Copy all logs',
                onPressed: () {
                  final text = filtered.map((e) => e.format()).join('\n');
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied logs to clipboard!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Filter logs by text or category...',
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1F1F24),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'ERROR', 'WARN', 'INFO', 'NETWORK'].map((lvl) {
                final isSelected = _selectedLevel == lvl;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(lvl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
                    selected: isSelected,
                    selectedColor: _levelColor(lvl).withAlpha(120),
                    backgroundColor: const Color(0x1F2A2A32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => setState(() => _selectedLevel = lvl),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33FFFFFF), width: 0.8),
              ),
              child: filtered.isEmpty
                  ? const Center(child: Text('No matching log entries found.', style: TextStyle(color: Colors.grey, fontSize: 12)))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final timeStr = '${e.timestamp.hour.toString().padLeft(2, "0")}:${e.timestamp.minute.toString().padLeft(2, "0")}:${e.timestamp.second.toString().padLeft(2, "0")}.${e.timestamp.millisecond.toString().padLeft(3, "0")}';
                        final color = _levelColor(e.level);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: SelectableText.rich(
                            TextSpan(
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.3),
                              children: [
                                TextSpan(text: '$timeStr ', style: const TextStyle(color: Colors.grey)),
                                TextSpan(text: '[${e.level}] ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                if (e.category != null)
                                  TextSpan(text: '[${e.category}] ', style: const TextStyle(color: Colors.amberAccent)),
                                TextSpan(text: e.message, style: const TextStyle(color: Colors.white70)),
                                if (e.exception != null)
                                  TextSpan(text: '\n${e.exception}', style: const TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
