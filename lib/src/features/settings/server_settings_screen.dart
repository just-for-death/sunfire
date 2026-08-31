import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
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
  String _serverVersion = 'v2.3.2321';

  // Client
  String _clientUrl = '';
  
  // Auth
  String _authType = 'None';
  String _authUsername = '';
  String _authPassword = '';

  // Server Binding
  String _serverIp = '0.0.0.0';
  int _serverPort = 4567;

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

  // Misc
  bool _debugLogsEnabled = true;
  bool _systemTrayEnabled = true;

  @override
  void initState() {
    super.initState();
    _clientUrl = _settings.serverUrl;
    _flareSolverrUrl = _settings.cfProxyUrl;
    _loadSettings();
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

          _serverIp = (s['ip'] as String?) ?? '0.0.0.0';
          _serverPort = parseIntSafe(s['port'], 4567);

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

          _debugLogsEnabled = parseBoolSafe(s['debugLogsEnabled'], true);
          _systemTrayEnabled = parseBoolSafe(s['systemTrayEnabled'], true);
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
                    setState(() {
                      _authUsername = userController.text.trim();
                      _authPassword = passController.text.trim();
                    });
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

  @override
  Widget build(BuildContext context) {
    return SettingsSubpageScaffold(
      title: 'Server',
      onRefresh: _loadSettings,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SectionTitle(title: 'Client'),
                SettingsPropTile(
                  title: 'Server URL',
                  subtitle: _clientUrl.isNotEmpty ? _clientUrl : 'http://100.71.46.98:4567',
                  description: 'HTTP target address of your Suwayomi server',
                  kind: SettingsPropKind.textField,
                  stringValue: _clientUrl,
                  onStringChanged: (v) async {
                    setState(() => _clientUrl = v);
                    _settings.serverUrl = v;
                    GraphQLClientService.instance.initialize(v);
                    await _loadSettings();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: const Text('Server Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    _isConnected ? 'Connected • Latency: ${_latencyMs ?? "-"}ms • Version: $_serverVersion' : 'Disconnected from server',
                    style: TextStyle(fontSize: 12, color: _isConnected ? Colors.greenAccent : Colors.redAccent),
                  ),
                  trailing: Icon(
                    _isConnected ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Authentication'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: const Text('Authentication Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: Text(_authType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: DropdownButton<String>(
                    value: _authType,
                    dropdownColor: const Color(0xFF22222A),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'None', child: Text('None')),
                      DropdownMenuItem(value: 'Basic', child: Text('HTTP Basic')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _authType = v);
                        if (v == 'Basic') _showCredentialsDialog();
                      }
                    },
                  ),
                ),
                if (_authType == 'Basic')
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: const Text('Credentials', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text(_authUsername.isNotEmpty ? 'Username: $_authUsername' : 'No credentials configured', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.key_rounded),
                    onTap: _showCredentialsDialog,
                  ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.web_rounded),
                  title: const Text('WebUI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Open Suwayomi web interface in external browser', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: _openWebUI,
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Server Bindings'),
                SettingsPropTile(
                  title: 'IP Address',
                  description: 'Host network interface binding for Suwayomi',
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
                  kind: SettingsPropKind.numberSlider,
                  intValue: _serverPort,
                  min: 1,
                  max: 65535,
                  onIntChanged: (v) {
                    setState(() => _serverPort = v);
                    _update('port', v);
                  },
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'SOCKS Proxy'),
                SettingsPropTile(
                  title: 'Enable SOCKS Proxy',
                  subtitle: 'Route all server outbound requests via SOCKS proxy',
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
                const SectionTitle(title: 'Cloudflare Bypass'),
                SettingsPropTile(
                  title: 'FlareSolverr',
                  subtitle: 'Route protected scraping requests through FlareSolverr proxy',
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
                    kind: SettingsPropKind.textField,
                    stringValue: _flareSolverrUrl,
                    subtitle: _flareSolverrUrl.isNotEmpty ? _flareSolverrUrl : 'http://100.85.171.6:8191/v1',
                    onStringChanged: (v) {
                      setState(() => _flareSolverrUrl = v);
                      _settings.cfProxyUrl = v;
                      _update('flareSolverrUrl', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'FlareSolverr Request Timeout',
                    subtitle: '$_flareSolverrTimeout seconds',
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
                    title: 'FlareSolverr Session Name',
                    kind: SettingsPropKind.textField,
                    stringValue: _flareSolverrSessionName,
                    subtitle: _flareSolverrSessionName,
                    onStringChanged: (v) {
                      setState(() => _flareSolverrSessionName = v);
                      _update('flareSolverrSessionName', v);
                    },
                  ),
                  SettingsPropTile(
                    title: 'FlareSolverr Session TTL',
                    subtitle: '$_flareSolverrSessionTtl minutes',
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
                ],
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Misc'),
                SettingsPropTile(
                  title: 'Debug Logs',
                  subtitle: 'Enable verbose server logging output',
                  kind: SettingsPropKind.switchTile,
                  boolValue: _debugLogsEnabled,
                  onBoolChanged: (v) {
                    setState(() => _debugLogsEnabled = v);
                    _update('debugLogsEnabled', v);
                  },
                ),
                SettingsPropTile(
                  title: 'System Tray Icon',
                  subtitle: 'Show status icon in host OS system tray',
                  kind: SettingsPropKind.switchTile,
                  boolValue: _systemTrayEnabled,
                  onBoolChanged: (v) {
                    setState(() => _systemTrayEnabled = v);
                    _update('systemTrayEnabled', v);
                  },
                ),
              ],
            ),
    );
  }
}
