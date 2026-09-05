import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'extension_repos_screen.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class BrowseSettingsScreen extends StatefulWidget {
  const BrowseSettingsScreen({super.key});

  @override
  State<BrowseSettingsScreen> createState() => _BrowseSettingsScreenState();
}

class _BrowseSettingsScreenState extends State<BrowseSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  bool _isLoading = true;
  bool _isConnected = false;

  int _maxSourcesInParallel = 6;
  String _localSourcePath = '';

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
          _maxSourcesInParallel = parseIntSafe(s['maxSourcesInParallel'], 6);
          _localSourcePath = (s['localSourcePath'] as String?) ?? '';
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
          title: 'Browse',
          onRefresh: _loadSettings,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const SectionTitle(title: 'Sources & Content'),
                    SettingsPropTile(
                      title: 'Show NSFW sources',
                      subtitle: 'Display 18+ and adult extensions in browse feeds',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.showNsfwSources,
                      onBoolChanged: (v) => _settings.showNsfwSources = v,
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Server Scraper Engine'),
                    SettingsPropTile(
                      title: 'Parallel scrapers concurrency',
                      subtitle: '$_maxSourcesInParallel simultaneous workers',
                      description: 'Number of parallel requests allowed when scraping sources simultaneously',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.numberSlider,
                      intValue: _maxSourcesInParallel,
                      min: 1,
                      max: 20,
                      unit: ' workers',
                      onIntChanged: (v) {
                        setState(() => _maxSourcesInParallel = v);
                        _update('maxSourcesInParallel', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Local source location',
                      description: 'Host directory for custom local CBZ/folder manga on Suwayomi server',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.textField,
                      stringValue: _localSourcePath,
                      subtitle: _localSourcePath.isNotEmpty ? _localSourcePath : 'Default (Server data/local)',
                      onStringChanged: (v) {
                        setState(() => _localSourcePath = v);
                        _update('localSourcePath', v);
                      },
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Extension Repositories'),
                    SettingsPropTile(
                      title: 'Auto-update JS scrapers',
                      subtitle: 'Automatically pull latest bugfixes from registered repos',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.autoUpdateJsSources,
                      onBoolChanged: (v) => _settings.autoUpdateJsSources = v,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(Icons.extension_rounded),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Extension Repositories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: const Text('Add community MangaYomi index.json repositories', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExtensionReposScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Cloudflare Bypass - FlareSolverr (Local App)'),
                    SettingsPropTile(
                      title: 'Local FlareSolverr URL',
                      subtitle: _settings.cfProxyUrl.isNotEmpty ? _settings.cfProxyUrl : 'Disabled (direct connection)',
                      description: 'Proxy endpoint used by this device to solve Cloudflare Turnstile challenges for local extensions and protected sources.',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.textField,
                      stringValue: _settings.cfProxyUrl,
                      onStringChanged: (v) => _settings.cfProxyUrl = v,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
