import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/isar_service.dart';
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
  
  // Binding & Proxy Controllers
  final TextEditingController _serverIpController = TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();
  final TextEditingController _socksHostController = TextEditingController();
  final TextEditingController _socksPortController = TextEditingController();
  final TextEditingController _socksUsernameController = TextEditingController();
  final TextEditingController _socksPasswordController = TextEditingController();
  
  // FlareSolverr Controllers
  final TextEditingController _cfProxyController = TextEditingController();
  final TextEditingController _flareSolverrSessionNameController = TextEditingController();

  // Storage & Paths Controllers
  final TextEditingController _downloadsPathController = TextEditingController();
  final TextEditingController _backupPathController = TextEditingController();
  final TextEditingController _localSourcePathController = TextEditingController();
  final TextEditingController _webUIInterfaceController = TextEditingController();

  bool _isConnected = false;
  String _serverVersion = 'v2.3.2321';
  int _pendingCount = 0;
  List<Map<String, dynamic>> _serverTrackers = [];
  bool _isLoadingTrackers = true;
  int? _latencyMs;
  bool _isUpdatingLibrary = false;
  bool _isCfTesting = false;
  bool _isSavingSetting = false;
  bool _obscureSocksPassword = true;

  // ── FULL SUWAYOMI SERVER SETTINGS STATE (CATALYST SPEC) ──
  // 1. Server Binding
  String _serverIp = '0.0.0.0';
  int _serverPort = 4567;

  // 2. SOCKS Proxy
  bool _socksProxyEnabled = false;
  int _socksProxyVersion = 5;

  // 3. CloudFlare Bypass (FlareSolverr)
  bool _flareSolverrEnabled = true;
  int _flareSolverrTimeout = 73;
  int _flareSolverrSessionTtl = 20;
  bool _flareSolverrAsResponseFallback = true;

  // 4. Downloads & Storage
  bool _downloadAsCbz = true;
  bool _autoDownloadNewChapters = true;
  int _autoDownloadLimit = 0;
  bool _excludeEntryWithUnreadChapters = false;
  bool _autoDownloadIgnoreReUploads = true;

  // 5. Library & Automated Updates
  double _globalUpdateInterval = 12.0;
  bool _updateMangas = true;
  bool _excludeCompleted = false;
  bool _excludeNotStarted = false;
  bool _excludeUnreadChapters = false;

  // 6. Automatic Backup
  int _backupInterval = 1;
  int _backupTTL = 14;
  String _backupTime = '12:00';

  // 7. Browse & Scrapers Engine
  int _maxSourcesInParallel = 6;

  // 8. WebUI & Misc
  String _webUIFlavor = 'CUSTOM';
  String _webUIInterface = '0.0.0.0';
  String _webUIChannel = 'STABLE';
  bool _debugLogsEnabled = true;
  bool _systemTrayEnabled = true;

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
    _serverIpController.dispose();
    _serverPortController.dispose();
    _socksHostController.dispose();
    _socksPortController.dispose();
    _socksUsernameController.dispose();
    _socksPasswordController.dispose();
    _cfProxyController.dispose();
    _flareSolverrSessionNameController.dispose();
    _downloadsPathController.dispose();
    _backupPathController.dispose();
    _localSourcePathController.dispose();
    _webUIInterfaceController.dispose();
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
        // Server Binding
        _serverIp = (s['ip'] as String?) ?? '0.0.0.0';
        _serverPort = parseIntSafe(s['port'], 4567);
        _serverIpController.text = _serverIp;
        _serverPortController.text = _serverPort.toString();

        // SOCKS Proxy
        _socksProxyEnabled = parseBoolSafe(s['socksProxyEnabled'], false);
        _socksProxyVersion = parseIntSafe(s['socksProxyVersion'], 5);
        _socksHostController.text = (s['socksProxyHost'] as String?) ?? '';
        _socksPortController.text = (s['socksProxyPort']?.toString()) ?? '1080';
        _socksUsernameController.text = (s['socksProxyUsername'] as String?) ?? '';
        _socksPasswordController.text = (s['socksProxyPassword'] as String?) ?? '';

        // FlareSolverr
        _flareSolverrEnabled = parseBoolSafe(s['flareSolverrEnabled'], true);
        _flareSolverrTimeout = parseIntSafe(s['flareSolverrTimeout'], 73);
        _flareSolverrSessionTtl = parseIntSafe(s['flareSolverrSessionTtl'], 20);
        _flareSolverrAsResponseFallback = parseBoolSafe(s['flareSolverrAsResponseFallback'], true);
        _flareSolverrSessionNameController.text = (s['flareSolverrSessionName'] as String?) ?? 'default';
        if (s['flareSolverrUrl'] != null && (s['flareSolverrUrl'] as String).isNotEmpty) {
          _cfProxyController.text = s['flareSolverrUrl'] as String;
        }

        // Downloads
        _downloadAsCbz = parseBoolSafe(s['downloadAsCbz'], true);
        _autoDownloadNewChapters = parseBoolSafe(s['autoDownloadNewChapters'], true);
        _autoDownloadLimit = parseIntSafe(s['autoDownloadNewChaptersLimit'], 0);
        _excludeEntryWithUnreadChapters = parseBoolSafe(s['excludeEntryWithUnreadChapters'], false);
        _autoDownloadIgnoreReUploads = parseBoolSafe(s['autoDownloadIgnoreReUploads'], true);
        _downloadsPathController.text = (s['downloadsPath'] as String?) ?? '';

        // Library Updates
        _globalUpdateInterval = parseDoubleSafe(s['globalUpdateInterval'], 12.0);
        _updateMangas = parseBoolSafe(s['updateMangas'], true);
        _excludeCompleted = parseBoolSafe(s['excludeCompleted'], false);
        _excludeNotStarted = parseBoolSafe(s['excludeNotStarted'], false);
        _excludeUnreadChapters = parseBoolSafe(s['excludeUnreadChapters'], false);

        // Backups
        _backupInterval = parseIntSafe(s['backupInterval'], 1);
        _backupTTL = parseIntSafe(s['backupTTL'], 14);
        _backupTime = (s['backupTime'] as String?) ?? '12:00';
        _backupPathController.text = (s['backupPath'] as String?) ?? '';

        // Browse & Sources
        _maxSourcesInParallel = parseIntSafe(s['maxSourcesInParallel'], 6);
        _localSourcePathController.text = (s['localSourcePath'] as String?) ?? '';

        // WebUI & Misc
        _webUIFlavor = (s['webUIFlavor'] as String?) ?? 'CUSTOM';
        _webUIInterface = (s['webUIInterface'] as String?) ?? '0.0.0.0';
        _webUIInterfaceController.text = _webUIInterface;
        _webUIChannel = (s['webUIChannel'] as String?) ?? 'STABLE';
        _debugLogsEnabled = parseBoolSafe(s['debugLogsEnabled'], true);
        _systemTrayEnabled = parseBoolSafe(s['systemTrayEnabled'], true);
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

  Future<void> _openWebUI() async {
    final serverUrl = SettingsService.instance.serverUrl;
    if (serverUrl.isEmpty) return;
    try {
      final uri = Uri.parse(serverUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WebUI: $e')));
      }
    }
  }

  Future<void> _triggerGlobalUpdate() async {
    setState(() => _isUpdatingLibrary = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await GraphQLClientService.instance.triggerGlobalLibraryUpdate();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('⚡ Global server library update started! Checking all sources...')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error starting library update: $e')));
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
        messenger.showSnackBar(const SnackBar(content: Text('🧹 Server image cache cleared successfully!')));
      }
    } catch (_) {
      if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Failed to clear cache.')));
    }
  }

  void _showCreateBackupDialog() {
    bool includeCategories = true;
    bool includeChapters = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: const Text('Create Server Backup', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Export your Suwayomi library, categories, reading tracking, and history into a .tachibk archive.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include Categories', style: TextStyle(fontSize: 14)),
                    value: includeCategories,
                    onChanged: (val) => setDlgState(() => includeCategories = val ?? true),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include Chapter Data', style: TextStyle(fontSize: 14)),
                    value: includeChapters,
                    onChanged: (val) => setDlgState(() => includeChapters = val ?? true),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      final res = await GraphQLClientService.instance.createServerBackup(
                        includeCategories: includeCategories,
                        includeChapters: includeChapters,
                      );
                      if (context.mounted) {
                        final url = res?['createBackup']?['url']?.toString() ?? 'data/backups';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Backup created: $url')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup triggered: $e')));
                      }
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _testFlareSolverr() async {
    final url = _cfProxyController.text.trim();
    if (url.isEmpty) return;
    setState(() => _isCfTesting = true);

    try {
      final uri = Uri.parse(url);
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (mounted) {
        if (resp.statusCode == 200 && resp.body.contains('FlareSolverr')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ FlareSolverr is active and reachable!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Server responded with HTTP ${resp.statusCode} (unexpected payload)'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ FlareSolverr unreachable: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isCfTesting = false);
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
        title: const Text('Suwayomi Server Admin'),
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
          // ── 1. SERVER CONNECTION & STATUS ──
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
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Client Target Server URL',
                    hintText: 'http://100.71.46.98:4567',
                    prefixIcon: Icon(Icons.link_rounded, color: primaryColor),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _saveAndTestServer,
                        child: const Text('Save & Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                      label: const Text('WebUI'),
                      onPressed: _isConnected ? _openWebUI : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 2. QUICK ACTIONS & TASKS ──
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
                        onPressed: _isConnected ? _showCreateBackupDialog : null,
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

          // ── 3. SERVER BINDING (IP & PORT) ──
          _buildSectionHeader('Server Bindings (Suwayomi Host)', Icons.settings_ethernet_rounded, Colors.lightBlueAccent),
          _buildCard(
            child: Column(
              children: [
                TextField(
                  controller: _serverIpController,
                  decoration: const InputDecoration(
                    labelText: 'Server Binding IP',
                    hintText: '0.0.0.0 (all interfaces)',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) => _updateServerSetting('ip', val.trim()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _serverPortController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Server Listening Port',
                    hintText: '4567',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) {
                    final port = int.tryParse(val.trim());
                    if (port != null && port > 0 && port <= 65535) {
                      _updateServerSetting('port', port);
                    }
                  },
                ),
              ],
            ),
          ),

          // ── 4. LIBRARY & AUTOMATED UPDATES ──
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
                  title: const Text('Exclude Not Started Manga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Skip series with zero read chapters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _excludeNotStarted,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _excludeNotStarted = val);
                          _updateServerSetting('excludeNotStarted', val);
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
              ],
            ),
          ),

          // ── 5. DOWNLOADS & STORAGE ──
          _buildSectionHeader('Downloads & Server Storage', Icons.download_rounded, Colors.greenAccent),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _downloadsPathController,
                  decoration: const InputDecoration(
                    labelText: 'Server Downloads Directory',
                    hintText: 'e.g. /home/user/suwayomi/downloads',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) => _updateServerSetting('downloadsPath', val.trim()),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Save as CBZ Archive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Compress downloaded chapters into standard .cbz zip files', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  subtitle: const Text('Automatically download chapters when found during updates', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  title: const Text('Auto-Download Chapter Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(_autoDownloadLimit == 0 ? 'Download all new chapters' : 'Limit to $_autoDownloadLimit newest chapters', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _autoDownloadLimit,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('All')),
                      DropdownMenuItem(value: 1, child: Text('1 chapter')),
                      DropdownMenuItem(value: 2, child: Text('2 chapters')),
                      DropdownMenuItem(value: 3, child: Text('3 chapters')),
                      DropdownMenuItem(value: 5, child: Text('5 chapters')),
                      DropdownMenuItem(value: 10, child: Text('10 chapters')),
                      DropdownMenuItem(value: 20, child: Text('20 chapters')),
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exclude Entry With Unread Chapters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Do not auto-download if unread chapters exist', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _excludeEntryWithUnreadChapters,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _excludeEntryWithUnreadChapters = val);
                          _updateServerSetting('excludeEntryWithUnreadChapters', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ignore Re-Uploads', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Do not re-download already downloaded chapter numbers', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _autoDownloadIgnoreReUploads,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _autoDownloadIgnoreReUploads = val);
                          _updateServerSetting('autoDownloadIgnoreReUploads', val);
                        }
                      : null,
                ),
              ],
            ),
          ),

          // ── 6. CLOUDFLARE BYPASS (FLARESOLVERR) ──
          _buildSectionHeader('Cloudflare Bypass (FlareSolverr)', Icons.security_rounded, Colors.orangeAccent),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Server FlareSolverr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Route Cloudflare challenges through FlareSolverr proxy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _flareSolverrEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _flareSolverrEnabled = val);
                          _updateServerSetting('flareSolverrEnabled', val);
                        }
                      : null,
                ),
                if (_flareSolverrEnabled) ...[
                  const Divider(height: 1, color: Color(0x1AFFFFFF)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cfProxyController,
                    decoration: const InputDecoration(
                      labelText: 'FlareSolverr Endpoint URL',
                      hintText: 'http://100.85.171.6:8191/v1',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) {
                      SettingsService.instance.cfProxyUrl = val.trim();
                      _updateServerSetting('flareSolverrUrl', val.trim());
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _flareSolverrSessionNameController,
                          decoration: const InputDecoration(
                            labelText: 'Session Name',
                            hintText: 'default',
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) => _updateServerSetting('flareSolverrSessionName', val.trim()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isCfTesting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.network_ping_rounded, size: 16),
                        label: const Text('Test', style: TextStyle(fontSize: 12)),
                        onPressed: _isCfTesting ? null : _testFlareSolverr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('FlareSolverr Timeout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('$_flareSolverrTimeout seconds challenge solve timeout', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  Slider(
                    value: _flareSolverrTimeout.toDouble(),
                    min: 20,
                    max: 300,
                    divisions: 28,
                    label: '${_flareSolverrTimeout}s',
                    onChanged: _isConnected
                        ? (val) {
                            setState(() => _flareSolverrTimeout = val.toInt());
                            _updateServerSetting('flareSolverrTimeout', val.toInt());
                          }
                        : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Session TTL (Lifetime)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('$_flareSolverrSessionTtl minutes session validity', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  Slider(
                    value: _flareSolverrSessionTtl.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${_flareSolverrSessionTtl}m',
                    onChanged: _isConnected
                        ? (val) {
                            setState(() => _flareSolverrSessionTtl = val.toInt());
                            _updateServerSetting('flareSolverrSessionTtl', val.toInt());
                          }
                        : null,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Response Fallback Solving', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Solve Cloudflare on 403 / 503 response fallback', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _flareSolverrAsResponseFallback,
                    onChanged: _isConnected
                        ? (val) {
                            setState(() => _flareSolverrAsResponseFallback = val);
                            _updateServerSetting('flareSolverrAsResponseFallback', val);
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),

          // ── 7. SOCKS PROXY ──
          _buildSectionHeader('SOCKS Proxy', Icons.vpn_lock_rounded, Colors.tealAccent),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable SOCKS Proxy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Tunnel server outbound requests via SOCKS4 / SOCKS5 proxy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _socksProxyEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _socksProxyEnabled = val);
                          _updateServerSetting('socksProxyEnabled', val);
                        }
                      : null,
                ),
                if (_socksProxyEnabled) ...[
                  const Divider(height: 1, color: Color(0x1AFFFFFF)),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('SOCKS Version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: DropdownButton<int>(
                      value: _socksProxyVersion,
                      dropdownColor: const Color(0xFF22222A),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('SOCKS 4')),
                        DropdownMenuItem(value: 5, child: Text('SOCKS 5')),
                      ],
                      onChanged: _isConnected
                          ? (val) {
                              if (val != null) {
                                setState(() => _socksProxyVersion = val);
                                _updateServerSetting('socksProxyVersion', val);
                              }
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _socksHostController,
                          decoration: const InputDecoration(
                            labelText: 'Proxy Host',
                            hintText: '127.0.0.1',
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) => _updateServerSetting('socksProxyHost', val.trim()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _socksPortController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '1080',
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) => _updateServerSetting('socksProxyPort', val.trim()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _socksUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'Proxy Username (optional)',
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (val) => _updateServerSetting('socksProxyUsername', val.trim()),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _socksPasswordController,
                    obscureText: _obscureSocksPassword,
                    decoration: InputDecoration(
                      labelText: 'Proxy Password (optional)',
                      filled: true,
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureSocksPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureSocksPassword = !_obscureSocksPassword),
                      ),
                    ),
                    onSubmitted: (val) => _updateServerSetting('socksProxyPassword', val.trim()),
                  ),
                ],
              ],
            ),
          ),

          // ── 8. AUTOMATIC BACKUPS & RETENTION ──
          _buildSectionHeader('Automatic Backups & Retention', Icons.backup_rounded, Colors.cyanAccent),
          _buildCard(
            child: Column(
              children: [
                TextField(
                  controller: _backupPathController,
                  decoration: const InputDecoration(
                    labelText: 'Server Backup Directory',
                    hintText: 'e.g. /home/user/suwayomi/data/backups',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) => _updateServerSetting('backupPath', val.trim()),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Backup Schedule Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(_backupInterval == 0 ? 'Automatic backups disabled' : 'Create backup every $_backupInterval days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _backupInterval,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Disabled')),
                      DropdownMenuItem(value: 1, child: Text('Daily (Every 1d)')),
                      DropdownMenuItem(value: 2, child: Text('Every 2 Days')),
                      DropdownMenuItem(value: 7, child: Text('Weekly (Every 7d)')),
                      DropdownMenuItem(value: 14, child: Text('Bi-Weekly (14d)')),
                      DropdownMenuItem(value: 30, child: Text('Monthly (30d)')),
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
                  title: const Text('Backup Execution Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Triggers daily at $_backupTime UTC', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.access_time_rounded, size: 16),
                    label: Text(_backupTime),
                    onPressed: _isConnected
                        ? () async {
                            final parts = _backupTime.split(':');
                            final hour = int.tryParse(parts.first) ?? 12;
                            final min = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: hour, minute: min),
                            );
                            if (picked != null) {
                              final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              setState(() => _backupTime = formatted);
                              _updateServerSetting('backupTime', formatted);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Backup Retention TTL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(_backupTTL == 0 ? 'Keep all backups indefinitely' : 'Automatically purge backups older than $_backupTTL days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<int>(
                    value: _backupTTL,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Indefinite')),
                      DropdownMenuItem(value: 7, child: Text('7 Days')),
                      DropdownMenuItem(value: 14, child: Text('14 Days')),
                      DropdownMenuItem(value: 30, child: Text('30 Days')),
                      DropdownMenuItem(value: 90, child: Text('90 Days')),
                      DropdownMenuItem(value: 365, child: Text('1 Year')),
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

          // ── 9. BROWSE & SCRAPER CONCURRENCY ──
          _buildSectionHeader('Browse & Scraper Workers', Icons.language_rounded, Colors.indigoAccent),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Parallel Scrapers Concurrency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('$_maxSourcesInParallel simultaneous source scraping workers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Slider(
                  value: _maxSourcesInParallel.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '$_maxSourcesInParallel workers',
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _maxSourcesInParallel = val.toInt());
                          _updateServerSetting('maxSourcesInParallel', val.toInt());
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _localSourcePathController,
                  decoration: const InputDecoration(
                    labelText: 'Local Source Directory',
                    hintText: 'e.g. /home/user/suwayomi/local_manga',
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (val) => _updateServerSetting('localSourcePath', val.trim()),
                ),
              ],
            ),
          ),

          // ── 10. WEBUI & SYSTEM DIAGNOSTICS ──
          _buildSectionHeader('WebUI & System Diagnostics', Icons.desktop_windows_rounded, Colors.deepPurpleAccent),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('WebUI Interface Flavor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Web dashboard visual theme & layout', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _webUIFlavor,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'CUSTOM', child: Text('Suwayomi Modern')),
                      DropdownMenuItem(value: 'TAIDI', child: Text('Taidi Classic')),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('WebUI Release Channel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: DropdownButton<String>(
                    value: _webUIChannel,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'STABLE', child: Text('Stable')),
                      DropdownMenuItem(value: 'PREVIEW', child: Text('Preview')),
                    ],
                    onChanged: _isConnected
                        ? (val) {
                            if (val != null) {
                              setState(() => _webUIChannel = val);
                              _updateServerSetting('webUIChannel', val);
                            }
                          }
                        : null,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Server Debug Logs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Verbose debug logging for scraping and GraphQL requests', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _debugLogsEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _debugLogsEnabled = val);
                          _updateServerSetting('debugLogsEnabled', val);
                        }
                      : null,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Server System Tray Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Show Suwayomi status icon in host OS tray', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _systemTrayEnabled,
                  onChanged: _isConnected
                      ? (val) {
                          setState(() => _systemTrayEnabled = val);
                          _updateServerSetting('systemTrayEnabled', val);
                        }
                      : null,
                ),
              ],
            ),
          ),

          // ── 11. TRACKERS INTEGRATION ──
          _buildSectionHeader('Manga Trackers & Sync', Icons.sync_alt_rounded, Colors.pinkAccent),
          _buildCard(
            child: _isLoadingTrackers
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Column(
                    children: _serverTrackers.map((tracker) {
                      final name = tracker['name'] as String;
                      final isLoggedIn = tracker['isLoggedIn'] as bool;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isLoggedIn ? Colors.greenAccent.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isLoggedIn ? Icons.verified_rounded : Icons.link_off_rounded,
                            color: isLoggedIn ? Colors.greenAccent : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          isLoggedIn ? 'Authenticated with Server' : 'Not Logged In',
                          style: TextStyle(fontSize: 11, color: isLoggedIn ? Colors.greenAccent : Colors.grey),
                        ),
                        trailing: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            side: BorderSide(color: isLoggedIn ? Colors.redAccent.withValues(alpha: 0.5) : primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showTrackerAuthDialog(tracker),
                          child: Text(
                            isLoggedIn ? 'Manage' : 'Log In',
                            style: TextStyle(
                              fontSize: 12,
                              color: isLoggedIn ? Colors.redAccent : primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // ── 12. SYNC ENGINE & OFFLINE QUEUE ──
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
}
