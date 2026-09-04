import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';
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
  List<Category> _categories = [];

  // Server Download Settings
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
      final cats = await IsarService.instance.getCategories();
      _categories = cats;

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

  void _showDeleteWhileReadingDialog() {
    final options = ['Disabled', 'Immediately', 'When next chapter opens'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Delete finished chapters while reading', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = _settings.deleteFinishedChaptersWhileReading == opt;
              return ListTile(
                title: Text(opt),
                trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.greenAccent) : null,
                onTap: () {
                  setState(() => _settings.deleteFinishedChaptersWhileReading = opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final included = List<String>.from(_settings.autoDownloadCategoriesInclude);
            final excluded = List<String>.from(_settings.autoDownloadCategoriesExclude);

            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: const Text('Auto-Download Categories', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: _categories.isEmpty
                    ? const Text('No categories available. Create categories in Library settings.', style: TextStyle(color: Colors.grey))
                    : ListView(
                        shrinkWrap: true,
                        children: _categories.map((cat) {
                          final isInc = included.contains(cat.name);
                          final isExc = excluded.contains(cat.name);

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: DropdownButton<String>(
                              value: isInc ? 'Include' : (isExc ? 'Exclude' : 'Default'),
                              dropdownColor: const Color(0xFF2B2B32),
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'Default', child: Text('Default')),
                                DropdownMenuItem(value: 'Include', child: Text('Include', style: TextStyle(color: Colors.greenAccent))),
                                DropdownMenuItem(value: 'Exclude', child: Text('Exclude', style: TextStyle(color: Colors.redAccent))),
                              ],
                              onChanged: (val) {
                                setDlgState(() {
                                  included.remove(cat.name);
                                  excluded.remove(cat.name);
                                  if (val == 'Include') included.add(cat.name);
                                  if (val == 'Exclude') excluded.add(cat.name);
                                });
                                setState(() {
                                  _settings.autoDownloadCategoriesInclude = included;
                                  _settings.autoDownloadCategoriesExclude = excluded;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
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
    final incList = _settings.autoDownloadCategoriesInclude;
    final excList = _settings.autoDownloadCategoriesExclude;
    final catSubtitle = 'Include: ${incList.isEmpty ? "All" : incList.join(", ")}\nExclude: ${excList.isEmpty ? "None" : excList.join(", ")}';

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
                    // ── 1. IMAGE DOWNLOAD PROCESSING ──
                    const SectionTitle(title: 'Image download processing'),
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

                    // ── 2. DELETE CHAPTERS ──
                    const SectionTitle(title: 'Delete chapters'),
                    SettingsPropTile(
                      title: 'Delete chapter after manually marking it as read',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.deleteChapterAfterMarkedRead,
                      onBoolChanged: (v) => _settings.deleteChapterAfterMarkedRead = v,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Delete finished chapters while reading', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: Text(_settings.deleteFinishedChaptersWhileReading, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onTap: _showDeleteWhileReadingDialog,
                    ),
                    SettingsPropTile(
                      title: 'Allow deleting bookmarked chapters',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.allowDeletingBookmarkedChapters,
                      onBoolChanged: (v) => _settings.allowDeletingBookmarkedChapters = v,
                    ),

                    const Divider(height: 1, color: Color(0x1AFFFFFF)),

                    // ── 3. AUTO-DOWNLOAD ──
                    const SectionTitle(title: 'Auto-download'),
                    SettingsPropTile(
                      title: 'Download new chapters',
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
                      subtitle: _autoDownloadLimit == 0 ? 'None' : '$_autoDownloadLimit Chapters',
                      description: 'Maximum number of chapters to automatically download per series',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.numberSlider,
                      intValue: _autoDownloadLimit,
                      min: 0,
                      max: 20,
                      unit: ' Chapters',
                      onIntChanged: (v) {
                        setState(() => _autoDownloadLimit = v);
                        _update('autoDownloadNewChaptersLimit', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Ignore automatic chapter downloads for entries with unread chapters',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _excludeEntryWithUnreadChapters,
                      onBoolChanged: (v) {
                        setState(() => _excludeEntryWithUnreadChapters = v);
                        _update('excludeEntryWithUnreadChapters', v);
                      },
                    ),
                    SettingsPropTile(
                      title: 'Ignore re-uploaded chapters',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _autoDownloadIgnoreReUploads,
                      onBoolChanged: (v) {
                        setState(() => _autoDownloadIgnoreReUploads = v);
                        _update('autoDownloadIgnoreReUploads', v);
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: Text(catSubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onTap: _showCategoryFilterDialog,
                    ),

                    const Divider(height: 1, color: Color(0x1AFFFFFF)),

                    // ── 4. DOWNLOAD AHEAD ──
                    const SectionTitle(title: 'Download ahead'),
                    SettingsPropTile(
                      title: 'Auto download while reading',
                      subtitle: 'Automatically cache upcoming unread chapters during reading sessions',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.autoDownloadWhileReading,
                      onBoolChanged: (v) => _settings.autoDownloadWhileReading = v,
                    ),
                    if (_settings.autoDownloadWhileReading)
                      SettingsPropTile(
                        title: 'Number of unread chapters to download',
                        subtitle: '${_settings.downloadAheadChapterCount} Chapters',
                        description: 'How many subsequent chapters to download ahead of current reading position',
                        scope: SettingScope.local,
                        kind: SettingsPropKind.numberSlider,
                        intValue: _settings.downloadAheadChapterCount,
                        min: 1,
                        max: 10,
                        unit: ' Chapters',
                        onIntChanged: (v) => _settings.downloadAheadChapterCount = v,
                      ),

                    const Divider(height: 1, color: Color(0x1AFFFFFF)),

                    // ── 5. NETWORK RESTRICTIONS ──
                    const SectionTitle(title: 'Network Restrictions'),
                    SettingsPropTile(
                      title: 'Download only on Wi-Fi',
                      subtitle: 'Prevent downloading manga over cellular mobile data',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.downloadOnlyOnWifi,
                      onBoolChanged: (v) => _settings.downloadOnlyOnWifi = v,
                    ),
                    SettingsPropTile(
                      title: 'Download only while charging',
                      subtitle: 'Conserve battery by downloading only when connected to power',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.downloadOnlyWhileCharging,
                      onBoolChanged: (v) => _settings.downloadOnlyWhileCharging = v,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
