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

  /// Languages offered in the filter sheet. The consumer
  /// (`SettingsService.languageMatchesFilter`) compares against a
  /// lowercased/trimmed language code, so these are stored lowercase.
  static const List<String> kFilterableLanguages = <String>[
    'en', 'ja', 'ko', 'zh', 'es', 'fr', 'de', 'it', 'pt', 'ru',
    'ar', 'hi', 'th', 'vi', 'id', 'tr', 'pl', 'nl', 'uk',
  ];

  /// Opens the language multi-select.
  ///
  /// Implemented as a sheet rather than a checkbox list because the language
  /// vocabulary comes from whatever the installed sources report, which is not
  /// knowable here; this offers a fixed common set plus "All" and a free-text
  /// escape hatch via the custom-code field.
  Future<void> _pickLanguages(BuildContext context) async {
    final current = _settings.selectedLanguages;
    final allSelected = current.isEmpty || current.contains('all');

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1F),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selection = <String>{...current.where((l) => l != 'all').map((l) => l.toLowerCase())};
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter updates by language',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        allSelected
                            ? 'Currently showing all languages. Pick one or more to filter; entries with an unknown language always pass.'
                            : 'Currently filtering: ${current.join(', ')}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          CheckboxListTile(
                            value: allSelected,
                            title: const Text('All languages (no filter)'),
                            onChanged: (_) => Navigator.of(ctx).pop(<String>['all']),
                          ),
                          const Divider(height: 1),
                          for (final lang in kFilterableLanguages)
                            CheckboxListTile(
                              value: selection.contains(lang),
                              title: Text(lang.toUpperCase()),
                              onChanged: (v) => setSheetState(() {
                                if (v == true) {
                                  selection.add(lang);
                                } else {
                                  selection.remove(lang);
                                }
                              }),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(<String>['all']),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                if (selection.isEmpty) {
                                  Navigator.of(ctx).pop(<String>['all']);
                                } else {
                                  Navigator.of(ctx).pop(selection.toList()..sort());
                                }
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() => _settings.selectedLanguages = result);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          _maxSourcesInParallel = parseIntSafe(s['maxSourcesInParallel'], 6);
          _localSourcePath = (s['localSourcePath'] as String?) ?? '';
        });
      } else {
        if (mounted) setState(() => _isConnected = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isConnected = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _update(String key, dynamic val) async {
    if (!_isConnected) {
      // Don't silently swallow a user's change: the optimistic UI update above
      // already happened, so tell the user nothing was persisted.
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
                    // ── Language display ────────────────────────────────────
                    // Both of these settings had fully-built consumers
                    // (SettingsService.languageMatchesFilter is applied to the
                    // Updates feed, and languageBadgeLabel is drawn on Library
                    // tiles and Updates rows) but no writer anywhere, so the
                    // filter short-circuited on the 'all' default and badges
                    // were permanently off. Wired up here.
                    SettingsPropTile(
                      title: 'Show language badges',
                      subtitle: 'Display a language tag on library and update entries',
                      description: 'Entries whose language is unknown or universal '
                          '(ALL / MULTI / UNIVERSAL) are never badged.',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.showLanguageBadges,
                      onBoolChanged: (v) => setState(() => _settings.showLanguageBadges = v),
                    ),
                    SettingsPropTile(
                      title: 'Filter by language',
                      subtitle: _settings.selectedLanguages.contains('all')
                          ? 'All languages (no filtering)'
                          : _settings.selectedLanguages.join(', '),
                      description: 'Applied to the Updates feed. Entries with an '
                          'unknown language always pass, so nothing is hidden by '
                          'accident. Requires "Show language badges" to be useful.',
                      scope: SettingScope.local,
                      leading: const Icon(Icons.translate_rounded),
                      onTap: () => _pickLanguages(context),
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
                      subtitle: const Text('Add the official Sunfire index or community MangaYomi repositories', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
