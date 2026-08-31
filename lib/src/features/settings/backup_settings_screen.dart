import 'package:flutter/material.dart';

import '../../core/sync/graphql_client_service.dart';
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
  String _backupTime = '12:00';

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
          _backupTime = (s['backupTime'] as String?) ?? '12:00';
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
                  title: const Text('Create Backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Can be used to restore current library', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: _showCreateBackupDialog,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: const Text('Restore Backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Restores library from a .tachibk or .proto.gz backup file', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Upload backup archive on Suwayomi WebUI or server backups directory')),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0x1AFFFFFF)),
                const SectionTitle(title: 'Automatic Backup'),
                SettingsPropTile(
                  title: 'Backup location',
                  description: 'Directory on Suwayomi host where automatic backups are saved',
                  kind: SettingsPropKind.textField,
                  stringValue: _backupPath,
                  subtitle: _backupPath.isNotEmpty ? _backupPath : 'Default (Server data/backups)',
                  onStringChanged: (v) {
                    setState(() => _backupPath = v);
                    _update('backupPath', v);
                  },
                ),
                SettingsPropTile(
                  title: 'Backup schedule interval',
                  subtitle: _backupInterval == 0 ? 'Disabled' : 'Every $_backupInterval day(s)',
                  description: 'Frequency of automatic full server backups',
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
                  title: const Text('Backup execution time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: Text('Triggers at $_backupTime UTC', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () async {
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
                      _update('backupTime', formatted);
                    }
                  },
                ),
                SettingsPropTile(
                  title: 'Backup retention limit',
                  subtitle: _backupTTL == 0 ? 'Keep indefinitely' : 'Keep for $_backupTTL days',
                  description: 'Old automatic backups past this TTL are automatically deleted',
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
              ],
            ),
    );
  }
}
