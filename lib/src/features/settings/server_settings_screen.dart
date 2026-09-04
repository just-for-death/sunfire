import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/server_auth_helper.dart';
import '../../core/sync/websocket_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class ServerSettingsScreen extends StatefulWidget {
  const ServerSettingsScreen({super.key});

  @override
  State<ServerSettingsScreen> createState() => _ServerSettingsScreenState();
}

class _ServerSettingsScreenState extends State<ServerSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _isLoading = true;
  bool _isConnected = false;
  int? _latencyMs;
  String _serverVersion = 'v2.3.2344';

  // Client
  String _clientUrl = '';
  ServerAuthCredentials _clientAuth = const ServerAuthCredentials(type: ServerAuthType.none);

  // Auth
  String _authMode = 'NONE';
  String _authUsername = '';
  String _authPassword = '';

  // Server Binding
  String _serverIp = '0.0.0.0';
  int _serverPort = 4567;
  bool _initialOpenInBrowser = false;
  bool _systemTrayEnabled = false;

  // SOCKS Proxy
  bool _socksProxyEnabled = false;
  int _socksProxyVersion = 5;
  String _socksHost = '';
  String _socksPort = '1080';
  String _socksUsername = '';
  String _socksPassword = '';

  // Cloudflare (FlareSolverr)
  bool _flareSolverrEnabled = true;
  String _flareSolverrUrl = '';
  int _flareSolverrTimeout = 73;
  String _flareSolverrSessionName = 'default';
  int _flareSolverrSessionTtl = 20;
  bool _flareSolverrAsResponseFallback = true;

  // OPDS Feed
  int _opdsItemsPerPage = 100;
  bool _opdsShowOnlyDownloaded = false;
  bool _opdsShowOnlyUnread = false;
  bool _opdsMarkAsReadOnDownload = false;
  bool _opdsEnablePageReadProgress = true;
  bool _opdsSkipChapterMetadataFeed = false;
  bool _opdsUseBinaryFileSizes = false;

  // SyncYomi
  bool _syncYomiEnabled = false;
  String _syncYomiHost = '';
  String _syncYomiApiKey = '';

  // WebUI & Diagnostics
  String _webUIFlavor = 'CUSTOM';
  String _webUIChannel = 'STABLE';
  String _webUIInterface = 'BROWSER';
  double _webUIUpdateInterval = 23.0;
  bool _debugLogsEnabled = true;
  bool _kcefEnabled = true;
  int _maxLogFiles = 31;
  String _maxLogFileSize = '10mb';
  String _maxLogFolderSize = '100mb';
  bool _useHikariPool = true;

  @override
  void initState() {
    super.initState();
    _clientUrl = _settings.serverUrl;
    _flareSolverrUrl = _settings.cfProxyUrl;
    _loadAuthAndSettings();
  }

  Future<void> _loadAuthAndSettings() async {
    final creds = await ServerAuthHelper.loadCredentials();
    if (mounted) setState(() => _clientAuth = creds);
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final start = DateTime.now();
    try {
      final res = await GraphQLClientService.instance.fetchServerSettings();
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      if (res != null && res.containsKey('settings')) {
        final s = res['settings'] as Map<String, dynamic>;
        final about = res['aboutServer'] as Map<String, dynamic>?;
        setState(() {
          _isConnected = true;
          _latencyMs = elapsed;
          if (about != null && about['version'] != null) {
            _serverVersion = about['version'].toString();
          }

          _authMode = (s['authMode'] as String?) ?? 'NONE';
          _authUsername = (s['authUsername'] as String?) ?? '';
          _authPassword = (s['authPassword'] as String?) ?? '';

          _serverIp = (s['ip'] as String?) ?? '0.0.0.0';
          _serverPort = parseIntSafe(s['port'], 4567);
          _initialOpenInBrowser = parseBoolSafe(s['initialOpenInBrowserEnabled'], false);
          _systemTrayEnabled = parseBoolSafe(s['systemTrayEnabled'], false);

          _socksProxyEnabled = parseBoolSafe(s['socksProxyEnabled'], false);
          _socksProxyVersion = parseIntSafe(s['socksProxyVersion'], 5);
          _socksHost = (s['socksProxyHost'] as String?) ?? '';
          _socksPort = (s['socksProxyPort']?.toString()) ?? '1080';
          _socksUsername = (s['socksProxyUsername'] as String?) ?? '';
          _socksPassword = (s['socksProxyPassword'] as String?) ?? '';

          _flareSolverrEnabled = parseBoolSafe(s['flareSolverrEnabled'], true);
          _flareSolverrUrl = (s['flareSolverrUrl'] as String?) ?? _settings.cfProxyUrl;
          _flareSolverrTimeout = parseIntSafe(s['flareSolverrTimeout'], 73);
          _flareSolverrSessionName = (s['flareSolverrSessionName'] as String?) ?? 'default';
          _flareSolverrSessionTtl = parseIntSafe(s['flareSolverrSessionTtl'], 20);
          _flareSolverrAsResponseFallback = parseBoolSafe(s['flareSolverrAsResponseFallback'], true);

          _opdsItemsPerPage = parseIntSafe(s['opdsItemsPerPage'], 100);
          _opdsShowOnlyDownloaded = parseBoolSafe(s['opdsShowOnlyDownloadedChapters'], false);
          _opdsShowOnlyUnread = parseBoolSafe(s['opdsShowOnlyUnreadChapters'], false);
          _opdsMarkAsReadOnDownload = parseBoolSafe(s['opdsMarkAsReadOnDownload'], false);
          _opdsEnablePageReadProgress = parseBoolSafe(s['opdsEnablePageReadProgress'], true);
          _opdsSkipChapterMetadataFeed = parseBoolSafe(s['opdsSkipChapterMetadataFeed'], false);
          _opdsUseBinaryFileSizes = parseBoolSafe(s['opdsUseBinaryFileSizes'], false);

          _syncYomiEnabled = parseBoolSafe(s['syncYomiEnabled'], false);
          _syncYomiHost = (s['syncYomiHost'] as String?) ?? '';
          _syncYomiApiKey = (s['syncYomiApiKey'] as String?) ?? '';

          _webUIFlavor = (s['webUIFlavor'] as String?) ?? 'CUSTOM';
          _webUIChannel = (s['webUIChannel'] as String?) ?? 'STABLE';
          _webUIInterface = (s['webUIInterface'] as String?) ?? 'BROWSER';
          _webUIUpdateInterval = parseDoubleSafe(s['webUIUpdateCheckInterval'], 23.0);
          _debugLogsEnabled = parseBoolSafe(s['debugLogsEnabled'], true);
          _kcefEnabled = parseBoolSafe(s['kcefEnabled'], true);
          _maxLogFiles = parseIntSafe(s['maxLogFiles'], 31);
          _maxLogFileSize = (s['maxLogFileSize'] as String?) ?? '10mb';
          _maxLogFolderSize = (s['maxLogFolderSize'] as String?) ?? '100mb';
          _useHikariPool = parseBoolSafe(s['useHikariConnectionPool'], true);
        });
      } else {
        setState(() {
          _isConnected = false;
          _latencyMs = null;
        });
      }
    } catch (_) {
      setState(() {
        _isConnected = false;
        _latencyMs = null;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _update(String key, dynamic val) async {
    if (!_isConnected) return;
    try {
      await GraphQLClientService.instance.updateServerSettings({key: val});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $key on server'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _openWebUI() async {
    if (_clientUrl.isEmpty) return;
    try {
      final uri = Uri.parse(_clientUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WebUI: $e')));
      }
    }
  }

  void _showCredentialsDialog() {
    final userController = TextEditingController(text: _authUsername);
    final passController = TextEditingController(text: _authPassword);
    bool obscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: const Text('HTTP Basic Credentials', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(labelText: 'Username', filled: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                        onPressed: () => setDlgState(() => obscure = !obscure),
                      ),
                    ),
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
                  onPressed: () {
                    final u = userController.text.trim();
                    final p = passController.text.trim();
                    setState(() {
                      _authUsername = u;
                      _authPassword = p;
                    });
                    _update('authUsername', u);
                    _update('authPassword', p);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClientCredentialsDialog() async {
    final currentCreds = await ServerAuthHelper.loadCredentials();
    ServerAuthType selectedType = currentCreds.type;
    final userController = TextEditingController(text: currentCreds.username);
    final passController = TextEditingController(text: currentCreds.password);
    final tokenController = TextEditingController(text: currentCreds.token);
    bool obscure = true;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: Colors.tealAccent),
              SizedBox(width: 8),
              Text('Client Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure credentials Sunfire uses to authenticate with Suwayomi.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ServerAuthType>(
                  segments: const [
                    ButtonSegment(value: ServerAuthType.none, label: Text('None', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: ServerAuthType.basic, label: Text('Basic', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: ServerAuthType.bearer, label: Text('Bearer', style: TextStyle(fontSize: 12))),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (set) => setDlgState(() => selectedType = set.first),
                ),
                const SizedBox(height: 16),
                if (selectedType == ServerAuthType.basic) ...[
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'admin',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                        onPressed: () => setDlgState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ] else if (selectedType == ServerAuthType.bearer) ...[
                  TextField(
                    controller: tokenController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Token / Key',
                      hintText: 'Bearer token or reverse proxy header',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                        onPressed: () => setDlgState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text('No authentication credentials sent to server.', style: TextStyle(fontSize: 13, color: Colors.white60)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newCreds = ServerAuthCredentials(
                  type: selectedType,
                  username: userController.text.trim(),
                  password: passController.text.trim(),
                  token: tokenController.text.trim(),
                );
                await ServerAuthHelper.saveCredentials(newCreds);
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }
                if (mounted) {
                  setState(() => _clientAuth = newCreds);
                  final authHeader = newCreds.toHeaderValue();
                  GraphQLClientService.instance.initialize(_clientUrl, authToken: authHeader);
                  WebSocketService.instance.initialize(_clientUrl, authToken: authHeader);
                  await _loadSettings();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSubpageScaffold(
      title: 'Server',
      onRefresh: _loadSettings,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SectionTitle(title: 'Client Connection (App Target)'),
                SettingsPropTile(
                  title: 'Server URL',
                  subtitle: _clientUrl.isNotEmpty ? _clientUrl : 'Not configured (Standalone mode)',
                  description: 'HTTP target address of your Suwayomi server',
                  scope: SettingScope.local,
                  kind: SettingsPropKind.textField,
                  stringValue: _clientUrl,
                  onStringChanged: (v) async {
                    setState(() => _clientUrl = v);
                    _settings.serverUrl = v;
                    final auth = _clientAuth.toHeaderValue();
                    GraphQLClientService.instance.initialize(v, authToken: auth);
                    WebSocketService.instance.initialize(v, authToken: auth);
                    await _loadSettings();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.vpn_key_rounded, color: Colors.tealAccent),
                  title: const Text('Client Credentials', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    switch (_clientAuth.type) {
                      ServerAuthType.none => 'None (No authentication)',
                      ServerAuthType.basic => 'HTTP Basic Auth (${_clientAuth.username.isNotEmpty ? _clientAuth.username : "configured"})',
                      ServerAuthType.bearer => 'Bearer Token',
                    },
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  onTap: _showClientCredentialsDialog,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Connection Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge(
                        label: _isConnected ? 'CONNECTED' : 'OFFLINE',
                        color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 9.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _isConnected ? 'Latency: ${_latencyMs ?? "-"}ms • Version: $_serverVersion' : 'Cannot reach server at target URL',
                    style: TextStyle(fontSize: 12, color: _isConnected ? Colors.grey : Colors.redAccent),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.web_rounded),
                  title: const Text('Open WebUI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Launch Suwayomi web dashboard in external browser', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: _openWebUI,
                ),

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Authentication (Server)'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Auth Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: Text(_authMode, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _authMode,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'NONE', child: Text('None')),
                      DropdownMenuItem(value: 'BASIC', child: Text('HTTP Basic')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _authMode = v);
                        _update('authMode', v);
                        if (v == 'BASIC') _showCredentialsDialog();
                      }
                    },
                  ),
                ),
                if (_authMode == 'BASIC')
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: const Text('Credentials', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text(_authUsername.isNotEmpty ? 'Username: $_authUsername' : 'Configure login credentials', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.key_rounded),
                    onTap: _showCredentialsDialog,
                  ),

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Server Network Bindings (Server)'),
                SettingsPropTile(
                  title: 'IP Address',
                  description: 'Host network interface binding for Suwayomi',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.textField,
                  stringValue: _serverIp,
                  subtitle: _serverIp,
                  onStringChanged: (v) {
                    setState(() => _serverIp = v);
                    _update('ip', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Server Port',
                  description: 'Port number Suwayomi server listens on',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _serverPort,
                  min: 1,
                  max: 65535,
                  onIntChanged: (v) {
                    setState(() => _serverPort = v);
                    _update('port', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Open in browser on startup',
                  subtitle: 'Automatically open default browser when server starts',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _initialOpenInBrowser,
                  onBoolChanged: (v) {
                    setState(() => _initialOpenInBrowser = v);
                    _update('initialOpenInBrowserEnabled', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Host system tray icon',
                  subtitle: 'Show status icon in desktop system tray',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _systemTrayEnabled,
                  onBoolChanged: (v) {
                    setState(() => _systemTrayEnabled = v);
                    _update('systemTrayEnabled', v);
                  },
                ),

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'SOCKS Proxy Tunnel (Server)'),
                SettingsPropTile(
                  title: 'Enable SOCKS Proxy',
                  subtitle: 'Route all server requests through SOCKS proxy tunnel',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _socksProxyEnabled,
                  onBoolChanged: (v) {
                    setState(() => _socksProxyEnabled = v);
                    _update('socksProxyEnabled', v);
                  },
                ),
                if (_socksProxyEnabled) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: const Text('SOCKS Version', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text('SOCKS $_socksProxyVersion', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: DropdownButton<int>(
                      value: _socksProxyVersion,
                      dropdownColor: const Color(0xFF22222A),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('SOCKS 4')),
                        DropdownMenuItem(value: 5, child: Text('SOCKS 5')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _socksProxyVersion = v);
                          _update('socksProxyVersion', v);
                        }
                      },
                    ),
                  ),
                  SettingsPropTile(
                    title: 'SOCKS Host',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _socksHost,
                    subtitle: _socksHost.isNotEmpty ? _socksHost : '127.0.0.1',
                    onStringChanged: (v) {
                      setState(() => _socksHost = v);
                      _update('socksProxyHost', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'SOCKS Port',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _socksPort,
                    subtitle: _socksPort,
                    onStringChanged: (v) {
                      setState(() => _socksPort = v);
                      _update('socksProxyPort', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'SOCKS Username',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _socksUsername,
                    subtitle: _socksUsername.isNotEmpty ? _socksUsername : 'None',
                    onStringChanged: (v) {
                      setState(() => _socksUsername = v);
                      _update('socksProxyUsername', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'SOCKS Password',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    canObscure: true,
                    stringValue: _socksPassword,
                    subtitle: _socksPassword.isNotEmpty ? '••••••••' : 'None',
                    onStringChanged: (v) {
                      setState(() => _socksPassword = v);
                      _update('socksProxyPassword', v);
                    },
                  ),
                ],

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Cloudflare Bypass - FlareSolverr (Server)'),
                SettingsPropTile(
                  title: 'Enable FlareSolverr',
                  subtitle: 'Route anti-bot challenge solving via FlareSolverr proxy',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _flareSolverrEnabled,
                  onBoolChanged: (v) {
                    setState(() => _flareSolverrEnabled = v);
                    _update('flareSolverrEnabled', v);
                  },
                ),
                if (_flareSolverrEnabled) ...[
                  SettingsPropTile(
                    title: 'FlareSolverr URL',
                    description: 'Full endpoint URL of FlareSolverr service',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _flareSolverrUrl,
                    subtitle: _flareSolverrUrl.isNotEmpty ? _flareSolverrUrl : 'Disabled',
                    onStringChanged: (v) {
                      setState(() => _flareSolverrUrl = v);
                      _settings.cfProxyUrl = v;
                      _update('flareSolverrUrl', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'Solve timeout',
                    subtitle: '$_flareSolverrTimeout seconds',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.numberSlider,
                    intValue: _flareSolverrTimeout,
                    min: 20,
                    max: 300,
                    unit: 's',
                    onIntChanged: (v) {
                      setState(() => _flareSolverrTimeout = v);
                      _update('flareSolverrTimeout', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'Session name',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _flareSolverrSessionName,
                    subtitle: _flareSolverrSessionName,
                    onStringChanged: (v) {
                      setState(() => _flareSolverrSessionName = v);
                      _update('flareSolverrSessionName', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'Session TTL',
                    subtitle: '$_flareSolverrSessionTtl minutes',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.numberSlider,
                    intValue: _flareSolverrSessionTtl,
                    min: 1,
                    max: 60,
                    unit: 'm',
                    onIntChanged: (v) {
                      setState(() => _flareSolverrSessionTtl = v);
                      _update('flareSolverrSessionTtl', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'Fallback on response error',
                    subtitle: 'Attempt FlareSolverr solving when standard scraper gets blocked',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.switchTile,
                    boolValue: _flareSolverrAsResponseFallback,
                    onBoolChanged: (v) {
                      setState(() => _flareSolverrAsResponseFallback = v);
                      _update('flareSolverrAsResponseFallback', v);
                    },
                  ),
                ],

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'OPDS Server Feed (Server)'),
                SettingsPropTile(
                  title: 'Items per page',
                  subtitle: '$_opdsItemsPerPage manga entries',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _opdsItemsPerPage,
                  min: 10,
                  max: 200,
                  onIntChanged: (v) {
                    setState(() => _opdsItemsPerPage = v);
                    _update('opdsItemsPerPage', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Show only downloaded chapters',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsShowOnlyDownloaded,
                  onBoolChanged: (v) {
                    setState(() => _opdsShowOnlyDownloaded = v);
                    _update('opdsShowOnlyDownloadedChapters', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Show only unread chapters',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsShowOnlyUnread,
                  onBoolChanged: (v) {
                    setState(() => _opdsShowOnlyUnread = v);
                    _update('opdsShowOnlyUnreadChapters', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Mark chapter as read on download',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsMarkAsReadOnDownload,
                  onBoolChanged: (v) {
                    setState(() => _opdsMarkAsReadOnDownload = v);
                    _update('opdsMarkAsReadOnDownload', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Enable page read progress sync',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsEnablePageReadProgress,
                  onBoolChanged: (v) {
                    setState(() => _opdsEnablePageReadProgress = v);
                    _update('opdsEnablePageReadProgress', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Skip chapter metadata feed',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsSkipChapterMetadataFeed,
                  onBoolChanged: (v) {
                    setState(() => _opdsSkipChapterMetadataFeed = v);
                    _update('opdsSkipChapterMetadataFeed', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Use binary file sizes',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _opdsUseBinaryFileSizes,
                  onBoolChanged: (v) {
                    setState(() => _opdsUseBinaryFileSizes = v);
                    _update('opdsUseBinaryFileSizes', v);
                  },
                ),

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'SyncYomi Remote Sync (Server)'),
                SettingsPropTile(
                  title: 'Enable SyncYomi',
                  subtitle: 'Sync library state with remote SyncYomi instance',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _syncYomiEnabled,
                  onBoolChanged: (v) {
                    setState(() => _syncYomiEnabled = v);
                    _update('syncYomiEnabled', v);
                  },
                ),
                if (_syncYomiEnabled) ...[
                  SettingsPropTile(
                    title: 'SyncYomi Host',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    stringValue: _syncYomiHost,
                    subtitle: _syncYomiHost.isNotEmpty ? _syncYomiHost : 'Not set',
                    onStringChanged: (v) {
                      setState(() => _syncYomiHost = v);
                      _update('syncYomiHost', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'SyncYomi API Key',
                    scope: SettingScope.server,
                    kind: SettingsPropKind.textField,
                    canObscure: true,
                    stringValue: _syncYomiApiKey,
                    subtitle: _syncYomiApiKey.isNotEmpty ? '••••••••' : 'Not set',
                    onStringChanged: (v) {
                      setState(() => _syncYomiApiKey = v);
                      _update('syncYomiApiKey', v);
                    },
                  ),
                ],

                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'WebUI & Diagnostics (Server)'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('WebUI Flavor', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: Text(_webUIFlavor, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _webUIFlavor,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'CUSTOM', child: Text('Custom / Modern')),
                      DropdownMenuItem(value: 'TAIDI', child: Text('Taidi (Tachiyomi Classic)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _webUIFlavor = v);
                        _update('webUIFlavor', v);
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('WebUI Release Channel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: Text(_webUIChannel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _webUIChannel,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'STABLE', child: Text('Stable')),
                      DropdownMenuItem(value: 'PREVIEW', child: Text('Preview')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _webUIChannel = v);
                        _update('webUIChannel', v);
                      }
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('WebUI Interface', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: Text(_webUIInterface, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _webUIInterface,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'BROWSER', child: Text('Browser')),
                      DropdownMenuItem(value: 'SYSTEM', child: Text('System')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _webUIInterface = v);
                        _update('webUIInterface', v);
                      }
                    },
                  ),
                ),
                SettingsPropTile(
                  title: 'WebUI Update Check Interval',
                  subtitle: 'Every ${_webUIUpdateInterval.toInt()} hours',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _webUIUpdateInterval.toInt(),
                  min: 1,
                  max: 72,
                  unit: 'h',
                  onIntChanged: (v) {
                    setState(() => _webUIUpdateInterval = v.toDouble());
                    _update('webUIUpdateCheckInterval', v.toDouble());
                  },
                ),
                SettingsPropTile(
                  title: 'Server Debug Logs',
                  subtitle: 'Verbose debug output for scraping and GraphQL operations',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _debugLogsEnabled,
                  onBoolChanged: (v) {
                    setState(() => _debugLogsEnabled = v);
                    _update('debugLogsEnabled', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Embedded CEF Scraper (kCEF)',
                  subtitle: 'Enable Chromium Embedded Framework engine on server',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _kcefEnabled,
                  onBoolChanged: (v) {
                    setState(() => _kcefEnabled = v);
                    _update('kcefEnabled', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Hikari Connection Pool',
                  subtitle: 'High-performance JDBC database connection pooling',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _useHikariPool,
                  onBoolChanged: (v) {
                    setState(() => _useHikariPool = v);
                    _update('useHikariConnectionPool', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Max Log Files Count',
                  subtitle: 'Keep up to $_maxLogFiles rotated log files',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _maxLogFiles,
                  min: 5,
                  max: 100,
                  onIntChanged: (v) {
                    setState(() => _maxLogFiles = v);
                    _update('maxLogFiles', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Max Single Log File Size',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.textField,
                  stringValue: _maxLogFileSize,
                  subtitle: _maxLogFileSize,
                  onStringChanged: (v) {
                    setState(() => _maxLogFileSize = v);
                    _update('maxLogFileSize', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Max Log Folder Total Size',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.textField,
                  stringValue: _maxLogFolderSize,
                  subtitle: _maxLogFolderSize,
                  onStringChanged: (v) {
                    setState(() => _maxLogFolderSize = v);
                    _update('maxLogFolderSize', v);
                  },
                ),
              ],
            ),
    );
  }
}
