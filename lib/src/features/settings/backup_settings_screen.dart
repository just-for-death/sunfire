import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  bool _restoring = false;
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
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final res = await GraphQLClientService.instance.fetchServerSettings();
      if (!mounted) return;
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
      if (mounted) setState(() => _isConnected = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _update(String key, dynamic val) async {
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not connected to server — change was not saved'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    try {
      final res = await GraphQLClientService.instance.persistSetting(key, val);
      if (!mounted) return;
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated $key on server'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $key on server'),
            duration: const Duration(seconds: 3),
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
unawaited(
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
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
                        final createdUrl = res?['createBackup']?['url']?.toString();
                        if (createdUrl != null && createdUrl.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✅ Backup created on server: $createdUrl')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('⚠️ Backup request failed — server did not create a backup. Check the server is reachable.'),
                              backgroundColor: Colors.orange.shade800,
                            ),
                          );
                        }
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
    ));
  }


  Future<void> _pickValidateAndRestore() async {
    if (_restoring) return;
    if (!GraphQLClientService.instance.isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connect to the server first.')),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['tachibk', 'zip', 'proto.gz'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    late final Uint8List bytes;
    try {
      bytes = file.bytes ?? (await file.xFile.readAsBytes());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read file: $e')),
        );
      }
      return;
    }
    final filename = file.name.isNotEmpty ? file.name : 'backup.tachibk';

    if (!mounted) return;
    setState(() => _restoring = true);
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Validating backup…')),
          ],
        ),
      ),
    ));

    BackupValidationResult? validation;
    try {
      validation = await GraphQLClientService.instance.validateBackup(bytes, filename: filename);
    } catch (e) {
      validation = null;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _restoring = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Validate failed: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final missingLines = <String>[];
    if (validation != null) {
      for (final s in validation.missingSources) {
        missingLines.add('Source: ${s.name.isEmpty ? s.id : s.name}');
      }
      for (final tname in validation.missingTrackers) {
        missingLines.add('Tracker: $tname');
      }
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Restore server backup?'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (validation == null)
                  const Text('Could not validate — restore may still work, but missing sources are unknown.')
                else if (validation.isClean)
                  const Text('Backup looks clean — no missing sources or trackers.')
                else ...[
                  const Text('Missing on server:'),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final line in missingLines)
                          Text('• $line', style: TextStyle(color: cs.error, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text('This replaces library data on the server. Continue?', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cs.primary),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Restore', style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (proceed != true || !mounted) {
      if (mounted) setState(() => _restoring = false);
      return;
    }

    final progressNotifier = ValueNotifier<String>('Starting restore…');
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ValueListenableBuilder<String>(
        valueListenable: progressNotifier,
        builder: (ctx, label, __) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    ));

    BackupRestoreStatusInfo? status;
    try {
      status = await GraphQLClientService.instance.restoreBackupAndWait(
        bytes,
        filename: filename,
        onProgress: (st) {
          progressNotifier.value = st.totalManga > 0
              ? '${st.state} · ${st.mangaProgress}/${st.totalManga}'
              : st.state;
        },
      );
    } catch (e) {
      status = null;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _restoring = false);
        progressNotifier.dispose();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _restoring = false);
    progressNotifier.dispose();

    if (status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restore could not start.')),
      );
    } else if (status.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server backup restored.')),
      );
    } else if (status.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed (${status.state}).')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore ended: ${status.state}')),
      );
    }
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
                  leading: _restoring
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.settings_backup_restore_rounded),
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('Restore Server Backup', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      SunfireBadge.server(),
                    ],
                  ),
                  subtitle: const Text('Validate and restore a .tachibk file to Suwayomi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: _restoring ? null : () => unawaited(_pickValidateAndRestore()),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: const Icon(Icons.restore_from_trash_rounded),
                  title: const Text('Restore from .tachibk File (Device)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Parse a .tachibk backup on this device and import it into your server library', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () => context.push('/settings/import-backup'),
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
                    unawaited(_update('backupPath', v));
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
                    unawaited(_update('backupInterval', v));
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
                      unawaited(_update('backupTime', formatted));
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
                    unawaited(_update('backupTTL', v));
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
                    unawaited(_update('autoBackupIncludeCategories', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Chapter Data',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeChapters,
                  onBoolChanged: (v) {
                    setState(() => _includeChapters = v);
                    unawaited(_update('autoBackupIncludeChapters', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Reading History',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeHistory,
                  onBoolChanged: (v) {
                    setState(() => _includeHistory = v);
                    unawaited(_update('autoBackupIncludeHistory', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Manga Details',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeManga,
                  onBoolChanged: (v) {
                    setState(() => _includeManga = v);
                    unawaited(_update('autoBackupIncludeManga', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Tracker Status',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeTracking,
                  onBoolChanged: (v) {
                    setState(() => _includeTracking = v);
                    unawaited(_update('autoBackupIncludeTracking', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Server Settings',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeServerSettings,
                  onBoolChanged: (v) {
                    setState(() => _includeServerSettings = v);
                    unawaited(_update('autoBackupIncludeServerSettings', v));
                  },
                ),
                SettingsPropTile(
                  title: 'Include Client Data',
                  scope: SettingScope.server,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _includeClientData,
                  onBoolChanged: (v) {
                    setState(() => _includeClientData = v);
                    unawaited(_update('autoBackupIncludeClientData', v));
                  },
                ),
              ],
            ),
    );
  }
}
