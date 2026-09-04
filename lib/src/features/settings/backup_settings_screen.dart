import 'package:flutter/material.dart';

import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _isLoading = true;
  bool _isConnected = false;

  String _backupPath = '';
  int _backupInterval = 1;
  int _backupTTL = 14;
  String _backupTime = '00:00';

  // Backup inclusions
  bool _includeCategories = true;
  bool _includeChapters = true;
  bool _includeHistory = true;
  bool _includeManga = true;
  bool _includeTracking = true;
  bool _includeServerSettings = true;
  bool _includeClientData = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final res = await GraphQLClientService.instance.fetchServerSettings();
      if (res != null && res.containsKey('settings')) {
        final s = res['settings'] as Map<String, dynamic>;
        setState(() {
          _isConnected = true;
          _backupPath = (s['backupPath'] as String?) ?? '';
          _backupInterval = parseIntSafe(s['backupInterval'], 1);
          _backupTTL = parseIntSafe(s['backupTTL'], 14);
          _backupTime = (s['backupTime'] as String?) ?? '00:00';

          _includeCategories = parseBoolSafe(s['autoBackupIncludeCategories'], true);
          _includeChapters = parseBoolSafe(s['autoBackupIncludeChapters'], true);
          _includeHistory = parseBoolSafe(s['autoBackupIncludeHistory'], true);
          _includeManga = parseBoolSafe(s['autoBackupIncludeManga'], true);
          _includeTracking = parseBoolSafe(s['autoBackupIncludeTracking'], true);
          _includeServerSettings = parseBoolSafe(s['autoBackupIncludeServerSettings'], true);
          _includeClientData = parseBoolSafe(s['autoBackupIncludeClientData'], true);
        });
      } else {
        setState(() => _isConnected = false);
      }
    } catch (_) {
      setState(() => _isConnected = false);
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

  void _showCreateBackupDialog() {
    bool includeCats = true;
    bool includeChs = true;

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
                    value: includeCats,
                    onChanged: (val) => setDlgState(() => includeCats = val ?? true),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include Chapter Data', style: TextStyle(fontSize: 14)),
                    value: includeChs,
                    onChanged: (val) => setDlgState(() => includeChs = val ?? true),
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
                        includeCategories: includeCats,
                        includeChapters: includeChs,
                      );
                      if (context.mounted) {
                        final url = res?['createBackup']?['url']?.toString() ?? 'data/backups';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Backup created on server: $url')),
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

  @override
  Widget build(BuildContext context) {
    return SettingsSubpageScaffold(
      title: 'Backup and Restore',
      onRefresh: _loadSettings,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SectionTitle(title: 'Backup and Restore'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.backup_rounded),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Create Server Backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: const Text('Generate a .tachibk archive on Suwayomi host', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: _showCreateBackupDialog,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Restore Server Backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: const Text('Restore library from a .tachibk backup file on server', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload backup archive to Suwayomi WebUI or server backups directory')),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Automatic Backup Schedule (Server)'),
                SettingsPropTile(
                  title: 'Backup location',
                  description: 'Host directory on Suwayomi server where backups are saved',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.textField,
                  stringValue: _backupPath,
                  subtitle: _backupPath.isNotEmpty ? _backupPath : 'Default (Server data/backups)',
                  onStringChanged: (v) {
                    setState(() => _backupPath = v);
                    _update('backupPath', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Schedule interval',
                  subtitle: _backupInterval == 0 ? 'Disabled' : 'Every $_backupInterval day(s)',
                  description: 'Frequency of automated server library backups',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _backupInterval,
                  min: 0,
                  max: 30,
                  unit: ' days',
                  onIntChanged: (v) {
                    setState(() => _backupInterval = v);
                    _update('backupInterval', v);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Execution time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: Text('Triggers at $_backupTime UTC', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () async {
                    final parts = _backupTime.split(':');
                    final hour = int.tryParse(parts.first) ?? 0;
                    final min = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: hour, minute: min),
                    );
                    if (picked != null) {
                      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      setState(() => _backupTime = formatted);
                      _update('backupTime', formatted);
                    }
                  },
                ),
                SettingsPropTile(
                  title: 'Retention limit (TTL)',
                  subtitle: _backupTTL == 0 ? 'Keep indefinitely' : 'Keep for $_backupTTL days',
                  description: 'Old backups past this age are automatically deleted',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.numberSlider,
                  intValue: _backupTTL,
                  min: 0,
                  max: 365,
                  unit: ' days',
                  onIntChanged: (v) {
                    setState(() => _backupTTL = v);
                    _update('backupTTL', v);
                  },
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Auto-Backup Content Inclusions (Server)'),
                SettingsPropTile(
                  title: 'Include Categories',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeCategories,
                  onBoolChanged: (v) {
                    setState(() => _includeCategories = v);
                    _update('autoBackupIncludeCategories', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Chapter Data',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeChapters,
                  onBoolChanged: (v) {
                    setState(() => _includeChapters = v);
                    _update('autoBackupIncludeChapters', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Reading History',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeHistory,
                  onBoolChanged: (v) {
                    setState(() => _includeHistory = v);
                    _update('autoBackupIncludeHistory', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Manga Details',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeManga,
                  onBoolChanged: (v) {
                    setState(() => _includeManga = v);
                    _update('autoBackupIncludeManga', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Tracker Status',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeTracking,
                  onBoolChanged: (v) {
                    setState(() => _includeTracking = v);
                    _update('autoBackupIncludeTracking', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Server Settings',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeServerSettings,
                  onBoolChanged: (v) {
                    setState(() => _includeServerSettings = v);
                    _update('autoBackupIncludeServerSettings', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Include Client Data',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeClientData,
                  onBoolChanged: (v) {
                    setState(() => _includeClientData = v);
                    _update('autoBackupIncludeClientData', v);
                  },
                ),
              ],
            ),
    );
  }
}
