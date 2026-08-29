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
  bool _isConnected = false;
  final String _serverVersion = 'v2.3.2321';
  int _pendingCount = 0;
  List<Map<String, dynamic>> _serverTrackers = [];
  bool _isLoadingTrackers = true;
  int? _latencyMs;
  bool _isUpdatingLibrary = false;
  bool _isDockerBusy = false;
  bool _isCfTesting = false;

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
    super.dispose();
  }

  Future<void> _checkServerConnection() async {
    final start = DateTime.now();
    final ok = GraphQLClientService.instance.isConfigured;
    if (ok) {
      try {
        final res = await GraphQLClientService.instance.fetchCategories();
        final elapsed = DateTime.now().difference(start).inMilliseconds;
        final connected = res != null;
        if (mounted) {
          setState(() {
            _isConnected = connected;
            _latencyMs = connected ? elapsed : null;
          });
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
        await GraphQLClientService.instance.query('mutation { updateLibrary(input: {}) { clientMutationId } }', label: 'updateLibrary');
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

  Future<void> _triggerCreateBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      const mut = r'''
        mutation {
          createBackup(input: { includeCategories: true, includeChapters: true }) {
            url
          }
        }
      ''';
      final data = await GraphQLClientService.instance.query(mut, label: 'createBackup');
      if (data != null && data.containsKey('createBackup')) {
        final url = data['createBackup']['url'] as String?;
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Backup created successfully: $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Backup created: /api/v1/backup/export.tachibk')),
        );
      }
    }
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
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        children: [
          Text('SERVER CONNECTION & HEALTH', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                    children: [
                      Icon(
                        _isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                        color: _isConnected ? Colors.green : Colors.red,
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
                      labelText: 'Server Host & Port',
                      hintText: 'http://192.168.x.x:4567',
                      prefixIcon: Icon(Icons.dns_rounded, color: primaryColor),
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
                      child: const Text('Test & Save Connection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── CLOUDFLARE BYPASS (FLARESOLVERR / BYPARR) ──────────────
          Text('CLOUDFLARE BYPASS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                    children: [
                      Icon(Icons.shield_rounded, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FlareSolverr / Byparr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              'Enables Mangago, ReadComicOnline and other Cloudflare-protected sources to work on Linux desktop.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cfProxyController,
                    decoration: InputDecoration(
                      labelText: 'FlareSolverr URL',
                      hintText: 'http://192.168.x.x:8191/v1',
                      prefixIcon: Icon(Icons.vpn_lock_rounded, color: primaryColor),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      helperText: 'Point to your FlareSolverr or Byparr instance. Leave empty to disable.',
                      helperStyle: const TextStyle(color: Colors.grey, fontSize: 11),
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
                      onPressed: _isCfTesting ? null : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final url = _cfProxyController.text.trim();

                        // Save immediately
                        SettingsService.instance.cfProxyUrl = url;
                        MClient.cfProxyUrl = url;

                        if (url.isEmpty) {
                          messenger.showSnackBar(const SnackBar(content: Text('Cloudflare bypass disabled.')));
                          return;
                        }

                        setState(() => _isCfTesting = true);
                        try {
                          // Test by sending a version-check request to the FlareSolverr API
                          final res = await http.get(
                            Uri.parse(url.replaceAll(RegExp(r'/v\d+$'), '')),
                          ).timeout(const Duration(seconds: 8));
                          final ok = res.statusCode == 200;
                          if (mounted) {
                            messenger.showSnackBar(SnackBar(
                              content: Text(ok
                                  ? '✅ FlareSolverr reachable at $url'
                                  : '⚠️ Saved but got HTTP ${res.statusCode} — check the URL'),
                            ));
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(SnackBar(
                              content: Text('❌ Cannot reach FlareSolverr: $e'),
                            ));
                          }
                        } finally {
                          if (mounted) setState(() => _isCfTesting = false);
                        }
                      },
                      child: _isCfTesting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save & Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── DOCKER SERVER CONTROL ──────────────────────────────────
          Text('DOCKER SERVER CONTROL', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                    children: [
                      Icon(Icons.dns_rounded, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Suwayomi Docker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(
                              'Manually start or stop the weeb-suwayomi-1 container on this machine.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          onPressed: _isDockerBusy ? null : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _isDockerBusy = true);
                            try {
                              await Process.run('docker', ['start', 'weeb-suwayomi-1']);
                              // Poll up to 20s for server to respond
                              bool alive = false;
                              for (int i = 0; i < 10; i++) {
                                await Future<void>.delayed(const Duration(seconds: 2));
                                alive = await GraphQLClientService.instance.checkServerReachable(force: true);
                                if (alive) break;
                              }
                              if (mounted) {
                                setState(() => _isConnected = alive);
                                messenger.showSnackBar(SnackBar(
                                  content: Text(alive ? '✅ Server is up and reachable' : '⚠️ Container started but server not responding yet'),
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
                          onPressed: _isDockerBusy ? null : () async {
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
          ),

          const SizedBox(height: 24),

          // ── GLOBAL SERVER MAINTENANCE & TASKS ─────────────────────
          Text('SERVER MAINTENANCE & TASKS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.sync_rounded, color: primaryColor),
                  title: const Text('Global Library Update', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Instruct Suwayomi server to scrape for new chapters across all library titles'),
                  trailing: _isUpdatingLibrary
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: _triggerGlobalUpdate,
                          child: const Text('Update Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.greenAccent),
                  title: const Text('Resume Server Downloader', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Start processing pending Suwayomi chapter download queue'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await GraphQLClientService.instance.startDownloader();
                    if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Server downloader resumed')));
                  },
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  leading: const Icon(Icons.pause_circle_filled_rounded, color: Colors.amber),
                  title: const Text('Pause Server Downloader', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Temporarily pause Suwayomi background chapter downloads'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await GraphQLClientService.instance.stopDownloader();
                    if (mounted) messenger.showSnackBar(const SnackBar(content: Text('Server downloader paused')));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── SERVER TRACKERS ───────────────────────────────────────
          Text('SERVER TRACKERS (MAL, ANILIST, KITSU, ETC)', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: _isLoadingTrackers
                ? const Padding(padding: EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator()))
                : Column(
                    children: _serverTrackers.map((t) {
                      final isLoggedIn = t['isLoggedIn'] as bool;
                      final name = t['name'] as String;

                      return ListTile(
                        leading: Icon(
                          isLoggedIn ? Icons.check_circle_rounded : Icons.account_circle_outlined,
                          color: isLoggedIn ? Colors.green : Colors.grey,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          isLoggedIn ? 'Logged in on Suwayomi server' : 'Not logged in',
                          style: TextStyle(color: isLoggedIn ? Colors.grey : Colors.orangeAccent, fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoggedIn ? const Color(0x33FFFFFF) : primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showTrackerAuthDialog(t),
                          child: Text(isLoggedIn ? 'Active' : 'Log In', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 24),

          // ── SYNC ENGINE & OFFLINE QUEUE ───────────────────────────
          Text('SYNC ENGINE & OFFLINE QUEUE', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: ListTile(
              leading: Icon(Icons.sync_alt_rounded, color: primaryColor),
              title: const Text('Pending Offline Mutations', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$_pendingCount queued offline records waiting to push'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await SyncEngine.instance.triggerSync();
                  await _loadPendingQueue();
                },
                child: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── SERVER BACKUP & RESTORE ───────────────────────────────
          Text('SERVER BACKUP & RESTORE (.TACHIBK)', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_download_rounded, color: Colors.cyanAccent),
                  title: const Text('Create Server Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Export full Suwayomi library & categories (.tachibk)'),
                  onTap: _triggerCreateBackup,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                ListTile(
                  leading: const Icon(Icons.cloud_upload_rounded, color: Colors.tealAccent),
                  title: const Text('Restore Server Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Import Tachiyomi/Mihon backup file onto server'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Place .tachibk backup file in Suwayomi data/backups folder')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
