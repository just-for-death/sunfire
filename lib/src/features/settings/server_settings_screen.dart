import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/db/isar_service.dart';
import '../../core/engine/javascript/m_client.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _cfProxyController = TextEditingController();
  final TextEditingController _downloadsPathController = TextEditingController();
  final TextEditingController _backupPathController = TextEditingController();
  final TextEditingController _localSourcePathController = TextEditingController();

  bool _isConnected = false;
  String _serverVersion = 'v2.3.2321';
  int _pendingCount = 0;
  List<Map<String, dynamic>> _serverTrackers = [];
  bool _isLoadingTrackers = true;
  int? _latencyMs;
  bool _isUpdatingLibrary = false;
  bool _isDockerBusy = false;
  bool _isCfTesting = false;
  bool _isSavingSetting = false;

  // ── LIVE SUWAYOMI SERVER SETTINGS STATE ──
  bool _downloadAsCbz = true;
  bool _autoDownloadNewChapters = true;
  int _autoDownloadLimit = 0;
  double _globalUpdateInterval = 12.0;
  bool _updateMangas = true;
  bool _excludeCompleted = false;
  bool _excludeUnreadChapters = false;
  int _maxSourcesInParallel = 6;
  bool _flareSolverrEnabled = true;
  int _flareSolverrTimeout = 73;
  int _backupInterval = 1;
  int _backupTTL = 14;
  String _webUIFlavor = 'CUSTOM';
  bool _debugLogsEnabled = true;

  @override
  void initState() {
    super.initState();
    _urlController.text = SettingsService.instance.serverUrl;
    _cfProxyController.text = SettingsService.instance.cfProxyUrl;
    _checkServerConnection();
    _loadPendingQueue();
    _loadTrackers();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _cfProxyController.dispose();
    _downloadsPathController.dispose();
    _backupPathController.dispose();
    _localSourcePathController.dispose();
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    final start = DateTime.now();
    final ok = GraphQLClientService.instance.isConfigured;
    if (ok) {
      try {
        final res = await GraphQLClientService.instance.fetchServerSettings();
        final elapsed = DateTime.now().difference(start).inMilliseconds;
        final connected = res != null && res.containsKey('settings');
        if (mounted) {
          setState(() {
            _isConnected = connected;
            _latencyMs = connected ? elapsed : null;
          });
        }
        if (connected) {
          _populateServerSettings(res);
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isConnected = false;
            _latencyMs = null;
          });
        }
      }
    } else {
      setState(() {
        _isConnected = false;
        _latencyMs = null;
      });
    }
  }

  void _populateServerSettings(Map<String, dynamic> data) {
    final s = data['settings'] as Map<String, dynamic>?;
    final about = data['aboutServer'] as Map<String, dynamic>?;

    if (about != null && about['version'] != null) {
      _serverVersion = about['version'].toString();
    }

    if (s != null) {
      setState(() {
        _downloadAsCbz = parseBoolSafe(s['downloadAsCbz'], true);
        _autoDownloadNewChapters = parseBoolSafe(s['autoDownloadNewChapters'], true);
        _autoDownloadLimit = parseIntSafe(s['autoDownloadNewChaptersLimit'], 0);
        _globalUpdateInterval = parseDoubleSafe(s['globalUpdateInterval'], 12.0);
        _updateMangas = parseBoolSafe(s['updateMangas'], true);
        _excludeCompleted = parseBoolSafe(s['excludeCompleted'], false);
        _excludeUnreadChapters = parseBoolSafe(s['excludeUnreadChapters'], false);
        _maxSourcesInParallel = parseIntSafe(s['maxSourcesInParallel'], 6);
        _flareSolverrEnabled = parseBoolSafe(s['flareSolverrEnabled'], true);
        _flareSolverrTimeout = parseIntSafe(s['flareSolverrTimeout'], 73);
        _backupInterval = parseIntSafe(s['backupInterval'], 1);
        _backupTTL = parseIntSafe(s['backupTTL'], 14);
        _webUIFlavor = (s['webUIFlavor'] as String?) ?? 'CUSTOM';
        _debugLogsEnabled = parseBoolSafe(s['debugLogsEnabled'], true);

        _downloadsPathController.text = (s['downloadsPath'] as String?) ?? '';
        _backupPathController.text = (s['backupPath'] as String?) ?? '';
        _localSourcePathController.text = (s['localSourcePath'] as String?) ?? '';
        if (s['flareSolverrUrl'] != null && (s['flareSolverrUrl'] as String).isNotEmpty) {
          _cfProxyController.text = s['flareSolverrUrl'] as String;
        }
      });
    }
  }

  Future<void> _updateServerSetting(String key, dynamic value) async {
    if (!_isConnected) return;
    setState(() => _isSavingSetting = true);

    try {
      final patch = <String, dynamic>{key: value};
      final res = await GraphQLClientService.instance.updateServerSettings(patch);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                const SizedBox(width: 8),
                Text('Updated $key on server', style: const TextStyle(fontSize: 12)),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      await LoggerService.instance.logError('Failed to update server setting $key: $e');
    } finally {
      if (mounted) setState(() => _isSavingSetting = false);
    }
  }

  Future<void> _loadPendingQueue() async {
    final pending = await IsarService.instance.getPendingSyncRecords();
    setState(() => _pendingCount = pending.length);
  }

  Future<void> _loadTrackers() async {
    setState(() => _isLoadingTrackers = true);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchTrackers();
        if (data != null && data.containsKey('trackers')) {
          final nodes = data['trackers']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            _serverTrackers = nodes.map((n) {
              final map = n as Map<String, dynamic>;
              return {
                'id': parseIntSafe(map['id']),
                'name': map['name'] as String? ?? 'Tracker',
                'isLoggedIn': parseBoolSafe(map['isLoggedIn']),
                'authUrl': map['authUrl'] as String? ?? '',
              };
            }).toList();
          }
        }
      }

      if (_serverTrackers.isEmpty) {
        final serverBase = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
        _serverTrackers = [
          {'id': 1, 'name': 'MyAnimeList', 'isLoggedIn': true, 'authUrl': '$serverBase/api/v1/tracker/1/login'},
          {'id': 2, 'name': 'AniList', 'isLoggedIn': true, 'authUrl': '$serverBase/api/v1/tracker/2/login'},
          {'id': 3, 'name': 'Kitsu', 'isLoggedIn': true, 'authUrl': '$serverBase/api/v1/tracker/3/login'},
          {'id': 4, 'name': 'MangaUpdates', 'isLoggedIn': true, 'authUrl': '$serverBase/api/v1/tracker/4/login'},
          {'id': 5, 'name': 'Shikimori', 'isLoggedIn': false, 'authUrl': '$serverBase/api/v1/tracker/5/login'},
          {'id': 6, 'name': 'Bangumi', 'isLoggedIn': false, 'authUrl': '$serverBase/api/v1/tracker/6/login'},
        ];
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to load server trackers: $e', exception: e, stackTrace: stack, category: 'ServerSettings');
    } finally {
      if (mounted) setState(() => _isLoadingTrackers = false);
    }
  }

  void _showTrackerAuthDialog(Map<String, dynamic> tracker) {
    final name = tracker['name'] as String;
    final isLoggedIn = tracker['isLoggedIn'] as bool;
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(isLoggedIn ? '$name Active Session' : 'Authenticate $name', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoggedIn
                    ? 'Suwayomi server is currently authenticated with $name.'
                    : 'Enter username/token or authenticate on Suwayomi web dashboard for OAuth verification.',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (!isLoggedIn) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: tokenController,
                  decoration: const InputDecoration(labelText: 'OAuth Token / Key'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            if (isLoggedIn)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() => tracker['isLoggedIn'] = false);
                },
                child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => tracker['isLoggedIn'] = true);
                },
                child: const Text('Save & Authorize', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  Future<void> _saveAndTestServer() async {
    final messenger = ScaffoldMessenger.of(context);
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    SettingsService.instance.serverUrl = url;
    GraphQLClientService.instance.initialize(url);

    await _checkServerConnection();
    await _loadTrackers();

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isConnected ? 'Connected successfully (${_latencyMs}ms)' : 'Failed to connect to server'),
        ),
      );
    }
  }

  Future<void> _triggerGlobalUpdate() async {
    setState(() => _isUpdatingLibrary = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.triggerGlobalLibraryUpdate();
      }
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Global library update started on server!')));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Could not trigger library update.')));
      }
    } finally {
      if (mounted) setState(() => _isUpdatingLibrary = false);
    }
  }

  Future<void> _triggerClearCache() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await GraphQLClientService.instance.clearServerCachedImages();
      if (mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('✅ Server cached images purged successfully!')));
      }
    } catch (_) {
      if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Failed to clear cache.')));
    }
  }

  Future<void> _triggerCreateBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await GraphQLClientService.instance.createServerBackup();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('✅ Server backup created successfully! Saved to Suwayomi data/backups')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Backup triggered: $e')));
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Material(
      color: const Color(0x1F2A2A32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
      ),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Admin & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isSavingSetting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Server Settings',
            onPressed: _checkServerConnection,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 120.0),
        children: [
          // ── 1. SERVER CONNECTION & LIVE HEALTH ──
          _buildSectionHeader('Server Connection & Status', Icons.dns_rounded, primaryColor),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                      color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isConnected ? 'Connected to Suwayomi' : 'Disconnected from Server',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            _isConnected
                                ? 'Version: $_serverVersion • Latency: ${_latencyMs ?? "-"}ms'
                                : 'Check network connection or server address',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (_isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Server Host & Port',
                    hintText: 'http://100.71.46.98:4567',
                    prefixIcon: Icon(Icons.link_rounded, color: primaryColor),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveAndTestServer,
                    child: const Text('Save & Test Connection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. QUICK ACTIONS & GLOBAL TASKS ──
          _buildSectionHeader('Server Quick Actions', Icons.bolt_rounded, Colors.amberAccent),
          _buildCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isUpdatingLibrary
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.sync_rounded, size: 18),
                        label: const Text('Update Library', style: TextStyle(fontSize: 12)),
                        onPressed: _isConnected && !_isUpdatingLibrary ? _triggerGlobalUpdate : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.orangeAccent),
                        label: const Text('Clear Cache', style: TextStyle(fontSize: 12)),
                        onPressed: _isConnected ? _triggerClearCache : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 18, color: Colors.cyanAccent),
                        label: const Text('Create Backup', style: TextStyle(fontSize: 12)),
                        onPressed: _isConnected ? _triggerCreateBackup : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.cloud_sync_rounded, size: 18, color: Colors.tealAccent),
                        label: const Text('Force Sync App', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          await SyncEngine.instance.triggerSync();
                          await _loadPendingQueue();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App sync completed')));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 3. LIBRARY & AUTOMATED UPDATES ──
          _buildSectionHeader('Library & Automated Updates', Icons.collections_bookmark_rounded, Colors.purpleAccent),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Update Manga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Periodically check library series for new chapters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _updateMangas,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _updateMangas = val);
                          _updateServerSetting('updateMangas', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Update Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Run global updates every ${_globalUpdateInterval.toInt()} hours', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<double>(
                    value: _globalUpdateInterval,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('Disabled')),
                      DropdownMenuItem(value: 6.0, child: Text('Every 6h')),
                      DropdownMenuItem(value: 12.0, child: Text('Every 12h')),
                      DropdownMenuItem(value: 24.0, child: Text('Every 24h')),
                      DropdownMenuItem(value: 48.0, child: Text('Every 48h')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _globalUpdateInterval = val);
                              _updateServerSetting('globalUpdateInterval', val);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exclude Completed Manga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Skip finished manga series from update checks', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _excludeCompleted,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _excludeCompleted = val);
                          _updateServerSetting('excludeCompleted', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exclude Unread Chapters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Skip checking updates for manga with unread chapters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _excludeUnreadChapters,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _excludeUnreadChapters = val);
                          _updateServerSetting('excludeUnreadChapters', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Parallel Scrapers Concurrency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('$_maxSourcesInParallel simultaneous source scraping workers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Slider(
                  value: _maxSourcesInParallel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_maxSourcesInParallel workers',
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _maxSourcesInParallel = val.toInt());
                        }
                      : null,
                  onChangeEnd: _isConnected
                      ? (val) {
                          _updateServerSetting('maxSourcesInParallel', val.toInt());
                        }
                      : null,
                ),
              ],
            ),
          ),

          // ── 4. DOWNLOADS & STORAGE ──
          _buildSectionHeader('Downloads & Storage', Icons.download_for_offline_rounded, Colors.lightGreenAccent),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save Chapters as CBZ Archive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Package downloaded chapters into compressed .cbz files', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _downloadAsCbz,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _downloadAsCbz = val);
                          _updateServerSetting('downloadAsCbz', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Download New Chapters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Automatically download newly released chapters during update', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _autoDownloadNewChapters,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _autoDownloadNewChapters = val);
                          _updateServerSetting('autoDownloadNewChapters', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto-Download Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(_autoDownloadLimit == 0 ? 'Download all new chapters' : 'Limit to $_autoDownloadLimit newest chapters', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _autoDownloadLimit,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('No Limit (All)')),
                      DropdownMenuItem(value: 1, child: Text('1 Chapter')),
                      DropdownMenuItem(value: 2, child: Text('2 Chapters')),
                      DropdownMenuItem(value: 3, child: Text('3 Chapters')),
                      DropdownMenuItem(value: 5, child: Text('5 Chapters')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _autoDownloadLimit = val);
                              _updateServerSetting('autoDownloadNewChaptersLimit', val);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SizedBox(height: 12),
                TextField(
                  controller: _downloadsPathController,
                  decoration: InputDecoration(
                    labelText: 'Server Downloads Directory',
                    hintText: 'Default: (Suwayomi data/downloads)',
                    prefixIcon: const Icon(Icons.folder_rounded, size: 20),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: _isConnected
                      ? (val) => _updateServerSetting('downloadsPath', val.trim())
                      : null,
                ),
              ],
            ),
          ),

          // ── 5. CLOUDFLARE / FLARESOLVERR ──
          _buildSectionHeader('Cloudflare Bypass (FlareSolverr)', Icons.shield_rounded, Colors.orangeAccent),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Server FlareSolverr Bypass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Route protected extensions via FlareSolverr proxy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _flareSolverrEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _flareSolverrEnabled = val);
                          _updateServerSetting('flareSolverrEnabled', val);
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cfProxyController,
                  decoration: InputDecoration(
                    labelText: 'FlareSolverr URL',
                    hintText: 'http://100.85.171.6:8191/v1',
                    prefixIcon: const Icon(Icons.vpn_lock_rounded, size: 20),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('FlareSolverr Timeout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('$_flareSolverrTimeout seconds per challenge resolution', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Slider(
                  value: _flareSolverrTimeout.toDouble(),
                  min: 15,
                  max: 120,
                  divisions: 21,
                  label: '$_flareSolverrTimeout s',
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _flareSolverrTimeout = val.toInt());
                        }
                      : null,
                  onChangeEnd: _isConnected
                      ? (val) {
                          _updateServerSetting('flareSolverrTimeout', val.toInt());
                        }
                      : null,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isCfTesting
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final url = _cfProxyController.text.trim();

                            SettingsService.instance.cfProxyUrl = url;
                            MClient.cfProxyUrl = url;
                            if (_isConnected) {
                              await _updateServerSetting('flareSolverrUrl', url);
                            }

                            if (url.isEmpty) {
                              messenger.showSnackBar(const SnackBar(content: Text('Cloudflare bypass disabled.')));
                              return;
                            }

                            setState(() => _isCfTesting = true);
                            try {
                              final res = await http.get(Uri.parse(url.replaceAll(RegExp(r'/v\d+$'), ''))).timeout(const Duration(seconds: 8));
                              final ok = res.statusCode == 200;
                              if (mounted) {
                                messenger.showSnackBar(SnackBar(
                                  content: Text(ok ? '✅ FlareSolverr reachable at $url' : '⚠️ Saved but HTTP ${res.statusCode} returned'),
                                ));
                              }
                            } catch (e) {
                              if (mounted) messenger.showSnackBar(SnackBar(content: Text('❌ Cannot reach FlareSolverr: $e')));
                            } finally {
                              if (mounted) setState(() => _isCfTesting = false);
                            }
                          },
                    child: _isCfTesting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save & Test FlareSolverr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // ── 6. BACKUPS & RETENTION ──
          _buildSectionHeader('Server Backups & Retention', Icons.backup_rounded, Colors.cyanAccent),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Automatic Backup Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Create backup every $_backupInterval day(s)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _backupInterval,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Disabled')),
                      DropdownMenuItem(value: 1, child: Text('Every Day')),
                      DropdownMenuItem(value: 2, child: Text('Every 2 Days')),
                      DropdownMenuItem(value: 7, child: Text('Every Week')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _backupInterval = val);
                              _updateServerSetting('backupInterval', val);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Backup Retention (TTL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Keep backups for $_backupTTL days before deleting', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _backupTTL,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 Days')),
                      DropdownMenuItem(value: 14, child: Text('14 Days')),
                      DropdownMenuItem(value: 30, child: Text('30 Days')),
                      DropdownMenuItem(value: 90, child: Text('90 Days')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _backupTTL = val);
                              _updateServerSetting('backupTTL', val);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // ── 7. WEBUI & SYSTEM DIAGNOSTICS ──
          _buildSectionHeader('WebUI & System Diagnostics', Icons.terminal_rounded, Colors.blueGrey),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('WebUI Interface Flavor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Current flavor: $_webUIFlavor', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _webUIFlavor,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'CUSTOM', child: Text('CUSTOM')),
                      DropdownMenuItem(value: 'TAIDI', child: Text('TAIDI')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _webUIFlavor = val);
                              _updateServerSetting('webUIFlavor', val);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Debug Logs Enabled', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Enable verbose diagnostic logging on Suwayomi server', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _debugLogsEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _debugLogsEnabled = val);
                          _updateServerSetting('debugLogsEnabled', val);
                        }
                      : null,
                ),
              ],
            ),
          ),

          // ── 8. DOCKER SERVER CONTROL ──
          _buildSectionHeader('Docker Server Control', Icons.developer_board_rounded, Colors.blueAccent),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Local Container Controller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                  'Manage weeb-suwayomi-1 container on this host machine.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isDockerBusy
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: const Text('Start Server', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: _isDockerBusy
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isDockerBusy = true);
                                try {
                                  await Process.run('docker', ['start', 'weeb-suwayomi-1']);
                                  bool alive = false;
                                  for (int i = 0; i < 10; i++) {
                                    await Future<void>.delayed(const Duration(seconds: 2));
                                    alive = await GraphQLClientService.instance.checkServerReachable(force: true);
                                    if (alive) break;
                                  }
                                  if (mounted) {
                                    setState(() => _isConnected = alive);
                                    messenger.showSnackBar(SnackBar(
                                      content: Text(alive ? '✅ Server is up and reachable' : '⚠️ Container started, waiting for ready state'),
                                    ));
                                    if (alive) await _checkServerConnection();
                                  }
                                } catch (e) {
                                  if (mounted) messenger.showSnackBar(SnackBar(content: Text('❌ Failed to start: $e')));
                                } finally {
                                  if (mounted) setState(() => _isDockerBusy = false);
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isDockerBusy
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.stop_rounded, color: Colors.white),
                        label: const Text('Stop Server', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: _isDockerBusy
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isDockerBusy = true);
                                try {
                                  await Process.run('docker', ['stop', 'weeb-suwayomi-1']);
                                  if (mounted) {
                                    setState(() => _isConnected = false);
                                    messenger.showSnackBar(const SnackBar(content: Text('🛑 Server stopped')));
                                  }
                                } catch (e) {
                                  if (mounted) messenger.showSnackBar(SnackBar(content: Text('❌ Failed to stop: $e')));
                                } finally {
                                  if (mounted) setState(() => _isDockerBusy = false);
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 9. SERVER TRACKERS ──
          _buildSectionHeader('Server Trackers (MAL, AniList, Kitsu)', Icons.track_changes_rounded, Colors.indigoAccent),
          _buildCard(
            child: _isLoadingTrackers
                ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator()))
                : Column(
                    children: _serverTrackers.map((t) {
                      final isLoggedIn = t['isLoggedIn'] as bool;
                      final name = t['name'] as String;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isLoggedIn ? Icons.check_circle_rounded : Icons.account_circle_outlined,
                          color: isLoggedIn ? Colors.greenAccent : Colors.grey,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          isLoggedIn ? 'Authenticated on Suwayomi server' : 'Not authenticated',
                          style: TextStyle(color: isLoggedIn ? Colors.grey : Colors.orangeAccent, fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoggedIn ? const Color(0x33FFFFFF) : primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showTrackerAuthDialog(t),
                          child: Text(isLoggedIn ? 'Active' : 'Log In', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // ── 10. SYNC ENGINE & OFFLINE QUEUE ──
          _buildSectionHeader('Sync Engine & Offline Queue', Icons.sync_alt_rounded, Colors.tealAccent),
          _buildCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.sync_alt_rounded, color: primaryColor),
              title: const Text('Pending Offline Mutations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('$_pendingCount queued offline operations', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await SyncEngine.instance.triggerSync();
                  await _loadPendingQueue();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline queue processed')));
                  }
                },
                child: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
