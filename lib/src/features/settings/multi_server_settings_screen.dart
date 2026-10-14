// lib/src/features/settings/multi_server_settings_screen.dart
//
// Experimental multi-server config UI. Does NOT change SyncEngine's primary
// Suwayomi GraphQL path — adapters are listed/managed only.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/sync/multi_server_manager.dart';
import '../../core/sync/server_type.dart';
import '../../ui/design_system/components/components.dart'
    show
        SunfireBottomSheet,
        SunfireButton,
        showSunfireConfirmDialog,
        showSunfireSheet;
import '../../ui/widgets/dialog_controllers.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_subpage_scaffold.dart';

class MultiServerSettingsScreen extends StatefulWidget {
  const MultiServerSettingsScreen({super.key});

  @override
  State<MultiServerSettingsScreen> createState() =>
      _MultiServerSettingsScreenState();
}

class _MultiServerSettingsScreenState extends State<MultiServerSettingsScreen> {
  bool _loading = true;
  Map<String, bool> _reachability = {};

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      await MultiServerManager.instance.initialize();
      _reachability = await MultiServerManager.instance.checkAllReachable();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Multi-server init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addServer() async {
    final nameCtrl = TextEditingController(text: 'Extra server');
    final urlCtrl = TextEditingController(text: 'http://');
    final tokenCtrl = TextEditingController();
    var type = ServerType.kavita;

    final ok = await showSunfireSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: SunfireBottomSheet(
            title: 'Add server (experimental)',
            subtitle: 'Adapters only — SyncEngine stays Suwayomi-primary',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: 'Base URL'),
                ),
                TextField(
                  controller: tokenCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API Key / Token (optional)',
                    hintText: 'Bearer token or API key',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ServerType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: ServerType.kavita,
                      child: Text('Kavita'),
                    ),
                    DropdownMenuItem(
                      value: ServerType.mihon,
                      child: Text('Mihon'),
                    ),
                    DropdownMenuItem(
                      value: ServerType.suwayomi,
                      child: Text('Suwayomi (adapter only)'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDlg(() => type = v);
                  },
                ),
              ],
            ),
            actions: [
              SunfireButton.secondary(
                label: 'Cancel',
                onPressed: () => Navigator.pop(ctx, false),
              ),
              SunfireButton.primary(
                label: 'Add',
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    ).then((v) {
      unawaited(disposeAfterDialog([nameCtrl, urlCtrl, tokenCtrl]));
      return v;
    });

    if (ok != true) return;
    final name = nameCtrl.text.trim();
    final url = urlCtrl.text.trim();
    final token = tokenCtrl.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    final config = ServerConfig(
      id: 'exp_${const Uuid().v4()}',
      name: name,
      type: type,
      baseUrl: url,
      authMode: token.isNotEmpty ? AuthMode.apiKey : AuthMode.none,
      authToken: token.isNotEmpty ? token : null,
      isPrimary: false,
      isEnabled: true,
    );
    await ServerConfigManager.instance.addServer(config);
    await MultiServerManager.instance.addAdapter(config);
    if (mounted) await _bootstrap();
  }

  Future<void> _remove(ServerConfig config) async {
    final ok = await showSunfireConfirmDialog(
      context: context,
      title: 'Remove server?',
      message: 'Remove "${config.name}" from the multi-server list? '
          'This does not change the primary Suwayomi sync path.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (ok != true || !mounted) return;
    await MultiServerManager.instance.removeAdapter(config.id);
    await ServerConfigManager.instance.removeServer(config.id);
    if (mounted) await _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final servers = ServerConfigManager.instance.servers;
    return SettingsSubpageScaffold(
      title: 'Multi-server (Experimental)',
      onRefresh: _bootstrap,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add server',
          onPressed: () => unawaited(_addServer()),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Adapters are managed here only. Library sync still uses the '
                    'primary Suwayomi GraphQL SyncEngine path — this does not '
                    'replace or fork it.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SectionTitle(title: 'Configured servers'),
                if (servers.isEmpty)
                  const ListTile(
                    title: Text('No experimental servers yet'),
                    subtitle: Text(
                      'Add Kavita/Mihon adapters to probe them',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                else
                  ...servers.map((s) {
                    final reachable = _reachability[s.id];
                    return ListTile(
                      leading: Icon(
                        reachable == true
                            ? Icons.check_circle_rounded
                            : reachable == false
                                ? Icons.cancel_rounded
                                : Icons.help_outline_rounded,
                        color: reachable == true
                            ? Colors.greenAccent
                            : reachable == false
                                ? Colors.redAccent
                                : Colors.grey,
                      ),
                      title: Text(s.name),
                      subtitle: Text(
                        '${s.type.name} · ${s.baseUrl}'
                        '${s.capabilities?['version'] != null ? " · v${s.capabilities!['version']}" : ""}'
                        '${s.isPrimary ? " · primary" : ""}'
                        '${s.isEnabled ? "" : " (disabled)"}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.network_check_rounded, size: 20),
                            tooltip: 'Test connection',
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final adapter = MultiServerManager.instance.getAdapter(s.id);
                              final ok = adapter != null ? await adapter.isReachable() : false;
                              if (!mounted) return;
                              setState(() => _reachability[s.id] = ok);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(ok ? '${s.name} is reachable' : '${s.name} is unreachable'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, size: 20),
                            tooltip: 'Probe capabilities',
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final adapter = MultiServerManager.instance.getAdapter(s.id);
                              if (adapter == null) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Server adapter not loaded (enable server first)')),
                                );
                                return;
                              }
                              final caps = await adapter.probeCapabilities();
                              if (!mounted) return;
                              await _bootstrap();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(caps.probed
                                      ? '${s.name} probed: v${caps.version ?? "unknown"}'
                                      : 'Capability probe failed for ${s.name}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          Switch(
                            value: s.isEnabled,
                            onChanged: (val) async {
                              final updated = s.copyWith(isEnabled: val);
                              await ServerConfigManager.instance.updateServer(updated);
                              if (val) {
                                await MultiServerManager.instance.addAdapter(updated);
                              } else {
                                await MultiServerManager.instance.removeAdapter(s.id);
                              }
                              if (mounted) await _bootstrap();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            tooltip: 'Remove',
                            onPressed: () => unawaited(_remove(s)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
