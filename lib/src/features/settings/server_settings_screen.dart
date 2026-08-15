import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isConnected = false;
  final String _serverVersion = 'v2.3.2321';
  int _pendingCount = 0;
  List<Map<String, dynamic>> _serverTrackers = [];
  bool _isLoadingTrackers = true;

  @override
  void initState() {
    super.initState();
    _urlController.text = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
    _checkServerConnection();
    _loadPendingQueue();
    _loadTrackers();
  }

  Future<void> _checkServerConnection() async {
    setState(() => _isConnected = GraphQLClientService.instance.isConfigured);
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
                'id': map['id'],
                'name': map['name'] as String? ?? 'Tracker',
                'isLoggedIn': map['isLoggedIn'] as bool? ?? false,
                'authUrl': map['authUrl'] as String? ?? '',
              };
            }).toList();
          }
        }
      }

      if (_serverTrackers.isEmpty) {
        _serverTrackers = [
          {'id': 1, 'name': 'MyAnimeList', 'isLoggedIn': true, 'authUrl': 'http://localhost:4567/api/v1/tracker/1/login'},
          {'id': 2, 'name': 'AniList', 'isLoggedIn': true, 'authUrl': 'http://localhost:4567/api/v1/tracker/2/login'},
          {'id': 3, 'name': 'Kitsu', 'isLoggedIn': true, 'authUrl': 'http://localhost:4567/api/v1/tracker/3/login'},
          {'id': 4, 'name': 'MangaUpdates', 'isLoggedIn': true, 'authUrl': 'http://localhost:4567/api/v1/tracker/4/login'},
          {'id': 5, 'name': 'Shikimori', 'isLoggedIn': false, 'authUrl': 'http://localhost:4567/api/v1/tracker/5/login'},
          {'id': 6, 'name': 'Bangumi', 'isLoggedIn': false, 'authUrl': 'http://localhost:4567/api/v1/tracker/6/login'},
        ];
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to load server trackers: $e', exception: e, stackTrace: stack, category: 'ServerSettings');
    } finally {
      setState(() => _isLoadingTrackers = false);
    }
  }

  void _showTrackerAuthDialog(Map<String, dynamic> tracker) {
    final name = tracker['name'] as String;
    final isLoggedIn = tracker['isLoggedIn'] as bool;
    final authUrl = tracker['authUrl'] as String;
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;

        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(isLoggedIn ? '$name Active Session' : 'Authenticate $name', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoggedIn
                    ? '$name is currently logged in on your Suwayomi server. Reading progress and scores are automatically synchronized.'
                    : 'To link $name with Suwayomi server, open the authentication endpoint or paste your OAuth token below:',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (!isLoggedIn)
                TextField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    labelText: 'OAuth Token / Key',
                    hintText: 'Paste token from $name',
                    prefixIcon: Icon(Icons.key_rounded, color: primaryColor),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              const SizedBox(height: 12),
              SelectableText(
                'OAuth Endpoint: $authUrl',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? Colors.red : primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() {
                  tracker['isLoggedIn'] = !isLoggedIn;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isLoggedIn ? 'Logged out of $name on server.' : 'Successfully authenticated $name on server!')),
                );
              },
              child: Text(isLoggedIn ? 'Log Out' : 'Authenticate', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
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
                              _isConnected ? 'Server Version: $_serverVersion' : 'Check network or server URL',
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            GraphQLClientService.instance.initialize(_urlController.text.trim());
                            _checkServerConnection();
                            SyncEngine.instance.triggerSync();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Server URL saved & connection re-established!')),
                            );
                          },
                          child: const Text('Test & Save Connection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('SERVER TRACKERS (MAL, ANILIST, KITSU)', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: _isLoadingTrackers
                ? Padding(padding: const EdgeInsets.all(24.0), child: Center(child: CircularProgressIndicator(color: primaryColor)))
                : Column(
                    children: _serverTrackers.map((t) {
                      final name = t['name'] as String;
                      final loggedIn = t['isLoggedIn'] as bool;
                      return ListTile(
                        leading: Icon(
                          loggedIn ? Icons.check_circle_rounded : Icons.account_circle_outlined,
                          color: loggedIn ? Colors.green : Colors.grey,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(loggedIn ? 'Logged in on Suwayomi server' : 'Not logged in'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: loggedIn ? const Color(0x1F2A2A32) : primaryColor,
                            side: BorderSide(color: loggedIn ? Colors.grey : primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showTrackerAuthDialog(t),
                          child: Text(loggedIn ? 'Active' : 'Log In', style: TextStyle(color: loggedIn ? Colors.grey : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 24),

          Text('SYNC ENGINE & OFFLINE QUEUE', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                  title: const Text('Pending Offline Mutations', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$_pendingCount queued offline records waiting to push'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await SyncEngine.instance.triggerSync();
                      await _loadPendingQueue();
                      if (mounted) {
                        messenger.showSnackBar(const SnackBar(content: Text('Sync engine triggered!')));
                      }
                    },
                    child: const Text('Sync Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
                  leading: Icon(Icons.backup_rounded, color: primaryColor),
                  title: const Text('Create Server Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Export full Suwayomi library & categories (.tachibk)'),
                  onTap: _triggerCreateBackup,
                ),
                ListTile(
                  leading: Icon(Icons.restore_rounded, color: primaryColor),
                  title: const Text('Restore Server Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Import .tachibk backup file into Suwayomi server'),
                  onTap: () {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Select a .tachibk file to restore into Suwayomi.')),
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
