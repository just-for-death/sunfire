import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class LibrarySettingsScreen extends StatefulWidget {
  const LibrarySettingsScreen({super.key});

  @override
  State<LibrarySettingsScreen> createState() => _LibrarySettingsScreenState();
}

class _LibrarySettingsScreenState extends State<LibrarySettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isConnected = false;

  // Server Library Settings
  double _globalUpdateInterval = 12.0;
  bool _updateMangas = true;
  bool _excludeCompleted = false;
  bool _excludeNotStarted = false;
  bool _excludeUnreadChapters = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingCategories = true);
    // 1. Load from local DB
    final list = await IsarService.instance.getCategories();
    setState(() {
      _categories = list;
    });

    // 2. Refresh from server if available
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final res = await GraphQLClientService.instance.fetchServerSettings();
        if (res != null && res.containsKey('settings')) {
          final s = res['settings'] as Map<String, dynamic>;
          setState(() {
            _isConnected = true;
            _globalUpdateInterval = parseDoubleSafe(s['globalUpdateInterval'], 12.0);
            _updateMangas = parseBoolSafe(s['updateMangas'], true);
            _excludeCompleted = parseBoolSafe(s['excludeCompleted'], false);
            _excludeNotStarted = parseBoolSafe(s['excludeNotStarted'], false);
            _excludeUnreadChapters = parseBoolSafe(s['excludeUnreadChapters'], false);
          });
        }

        final data = await GraphQLClientService.instance.fetchCategories();
        final rawNodes = data?['categories']?['nodes'] as List<dynamic>? ?? [];
        if (rawNodes.isNotEmpty) {
          final serverCats = <Category>[];
          for (final n in rawNodes) {
            final cMap = n as Map<String, dynamic>;
            final cat = Category()
              ..serverId = parseIntSafe(cMap['id'])
              ..name = cMap['name'] as String? ?? 'Category'
              ..order = parseIntSafe(cMap['order']);
            serverCats.add(cat);
          }
          await IsarService.instance.saveCategories(serverCats);
          if (mounted) {
            setState(() => _categories = serverCats);
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _isLoadingCategories = false);
  }

  Future<void> _updateServer(String key, dynamic val) async {
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

  Future<void> _addCategory(String name) async {
    if (name.trim().isEmpty) return;
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.createCategory(name.trim());
      }
    } catch (_) {}
    await _loadData();
  }

  Future<void> _renameCategory(Category cat, String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.updateCategoryName(cat.serverId, newName.trim());
      }
    } catch (_) {}
    await _loadData();
  }

  Future<void> _deleteCategory(Category cat) async {
    await IsarService.instance.deleteCategory(cat.serverId);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.deleteCategory(cat.serverId);
      }
    } catch (_) {}
    await _loadData();
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Category name (e.g. Completed)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                Navigator.pop(context);
                _addCategory(controller.text);
              },
              child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCategoryDialog(Category cat) {
    final controller = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Rename Category', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New category name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              onPressed: () {
                Navigator.pop(context);
                _renameCategory(cat, controller.text);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryConfirm(Category cat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete "${cat.name}"? Manga inside will remain in the library.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context);
                _deleteCategory(cat);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSkipUpdatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: const Text('Skip Updating Entries (Server)', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Completed Manga'),
                    subtitle: const Text('Skip finished manga series', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _excludeCompleted,
                    onChanged: (val) {
                      setDlgState(() => _excludeCompleted = val ?? false);
                      setState(() => _excludeCompleted = val ?? false);
                      _updateServer('excludeCompleted', val ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Not Started Manga'),
                    subtitle: const Text('Skip series with zero read chapters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _excludeNotStarted,
                    onChanged: (val) {
                      setDlgState(() => _excludeNotStarted = val ?? false);
                      setState(() => _excludeNotStarted = val ?? false);
                      _updateServer('excludeNotStarted', val ?? false);
                    },
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Unread Chapters Exist'),
                    subtitle: const Text('Skip series with unread chapters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    value: _excludeUnreadChapters,
                    onChanged: (val) {
                      setDlgState(() => _excludeUnreadChapters = val ?? false);
                      setState(() => _excludeUnreadChapters = val ?? false);
                      _updateServer('excludeUnreadChapters', val ?? false);
                    },
                  ),
                ],
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

  void _showRadioDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt),
                trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.greenAccent) : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, child) {
        return SettingsSubpageScaffold(
          title: 'Library',
          onRefresh: _loadData,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Category',
              onPressed: _showAddCategoryDialog,
            ),
          ],
          body: _isLoadingCategories
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    const SectionTitle(title: 'Global Update (Server)'),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Global Update Interval', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.server(),
                        ],
                      ),
                      subtitle: Text(_globalUpdateInterval == 0 ? 'Disabled' : 'Every ${_globalUpdateInterval.toInt()} hours', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: DropdownButton<double>(
                        value: _globalUpdateInterval,
                        dropdownColor: const Color(0xFF22222A),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 0.0, child: Text('Disabled')),
                          DropdownMenuItem(value: 6.0, child: Text('Every 6h')),
                          DropdownMenuItem(value: 12.0, child: Text('Every 12h')),
                          DropdownMenuItem(value: 24.0, child: Text('Every 24h')),
                          DropdownMenuItem(value: 48.0, child: Text('Every 48h')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _globalUpdateInterval = val);
                            _updateServer('globalUpdateInterval', val);
                          }
                        },
                      ),
                    ),
                    SettingsPropTile(
                      title: 'Refresh Manga Metadata',
                      subtitle: 'Update cover art, status, and description during updates',
                      scope: SettingScope.server,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _updateMangas,
                      onBoolChanged: (v) {
                        setState(() => _updateMangas = v);
                        _updateServer('updateMangas', v);
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Skip Updating Entries', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.server(),
                        ],
                      ),
                      subtitle: const Text('Configure rules to skip specific manga from global updates', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: _showSkipUpdatingDialog,
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Display & Badges (Local)'),
                    SettingsPropTile(
                      title: 'Show Unread Badges',
                      subtitle: 'Display unread counter badges on library covers',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.showUnreadBadges,
                      onBoolChanged: (v) => _settings.showUnreadBadges = v,
                    ),
                    SettingsPropTile(
                      title: 'Show Downloaded Badges',
                      subtitle: 'Display download indicator badges on saved manga',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.showDownloadedBadges,
                      onBoolChanged: (v) => _settings.showDownloadedBadges = v,
                    ),
                    SettingsPropTile(
                      title: 'Show Category Tabs',
                      subtitle: 'Display horizontal category filter pills at the top of library',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.showCategoryTabs,
                      onBoolChanged: (v) => _settings.showCategoryTabs = v,
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Default Display Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: Text(_settings.libraryDisplayMode, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Library Display Mode',
                          options: const ['Comfortable Grid', 'Compact Grid', 'List'],
                          currentValue: _settings.libraryDisplayMode,
                          onSelected: (val) => setState(() => _settings.libraryDisplayMode = val),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    const SectionTitle(title: 'Categories (Server Synced)'),
                    if (_categories.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: Colors.grey),
                        title: Text('No categories created yet', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        subtitle: Text('Tap + to create categories and organize your library.'),
                      )
                    else
                      ..._categories.map((cat) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          leading: const Icon(Icons.label_outline_rounded),
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SunfireBadge.server(),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _showRenameCategoryDialog(cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                onPressed: () => _showDeleteCategoryConfirm(cat),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
        );
      },
    );
  }
}
