import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class DownloadsSettingsScreen extends StatefulWidget {
  const DownloadsSettingsScreen({super.key});

  @override
  State<DownloadsSettingsScreen> createState() => _DownloadsSettingsScreenState();
}

class _DownloadsSettingsScreenState extends State<DownloadsSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _isLoading = true;
  bool _isConnected = false;

  String _downloadsPath = '';
  bool _downloadAsCbz = true;
  bool _autoDownloadNewChapters = true;
  int _autoDownloadLimit = 0;
  bool _excludeEntryWithUnreadChapters = false;
  bool _autoDownloadIgnoreReUploads = true;

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
          _downloadsPath = (s['downloadsPath'] as String?) ?? '';
          _downloadAsCbz = parseBoolSafe(s['downloadAsCbz'], true);
          _autoDownloadNewChapters = parseBoolSafe(s['autoDownloadNewChapters'], true);
          _autoDownloadLimit = parseIntSafe(s['autoDownloadNewChaptersLimit'], 0);
          _excludeEntryWithUnreadChapters = parseBoolSafe(s['excludeEntryWithUnreadChapters'], false);
          _autoDownloadIgnoreReUploads = parseBoolSafe(s['autoDownloadIgnoreReUploads'], true);
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return SettingsSubpageScaffold(
          title: 'Downloads',
          onRefresh: _loadSettings,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const SectionTitle(title: 'Server Storage'),
                    SettingsPropTile(
                      title: 'Download location',
                      description: 'Directory where Suwayomi downloads and stores chapters on host',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.textField,
                      stringValue: _downloadsPath,
                      subtitle: _downloadsPath.isNotEmpty ? _downloadsPath : 'Default (Server data/downloads)',
                      onStringChanged: (v) {
                        setState(() => _downloadsPath = v);
                        _update('downloadsPath', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Save as CBZ archive',
                      subtitle: 'Compress downloaded chapters into standard .cbz zip files',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _downloadAsCbz,
                      onBoolChanged: (v) {
                        setState(() => _downloadAsCbz = v);
                        _update('downloadAsCbz', v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Auto Download (Server)'),
                    SettingsPropTile(
                      title: 'Auto download new chapters',
                      subtitle: 'Automatically download newly released chapters found during updates',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _autoDownloadNewChapters,
                      onBoolChanged: (v) {
                        setState(() => _autoDownloadNewChapters = v);
                        _update('autoDownloadNewChapters', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Chapter download limit',
                      subtitle: _autoDownloadLimit == 0 ? 'Download all new chapters' : 'Limit to $_autoDownloadLimit chapters',
                      description: 'Maximum number of chapters to automatically download per series',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.numberSlider,
                      intValue: _autoDownloadLimit,
                      min: 0,
                      max: 20,
                      unit: ' chapters',
                      onIntChanged: (v) {
                        setState(() => _autoDownloadLimit = v);
                        _update('autoDownloadNewChaptersLimit', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Exclude entry with unread chapters',
                      subtitle: 'Do not auto-download if unread chapters exist',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _excludeEntryWithUnreadChapters,
                      onBoolChanged: (v) {
                        setState(() => _excludeEntryWithUnreadChapters = v);
                        _update('excludeEntryWithUnreadChapters', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Ignore re-uploads',
                      subtitle: 'Do not re-download already downloaded chapter numbers',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _autoDownloadIgnoreReUploads,
                      onBoolChanged: (v) {
                        setState(() => _autoDownloadIgnoreReUploads = v);
                        _update('autoDownloadIgnoreReUploads', v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Local Client Downloads'),
                    SettingsPropTile(
                      title: 'Download only on Wi-Fi',
                      subtitle: 'Prevent downloading manga over cellular mobile data',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.downloadOnlyOnWifi,
                      onBoolChanged: (v) => _settings.downloadOnlyOnWifi = v,
                    ),
                    SettingsPropTile(
                      title: 'Auto-delete read chapters',
                      subtitle: 'Remove cached offline chapters after reading',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.autoDeleteRead,
                      onBoolChanged: (v) => _settings.autoDeleteRead = v,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
