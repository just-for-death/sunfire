import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/library_update_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/background_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/widgets/dialog_controllers.dart';
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
  int _neverUpdatedMangaCount = 0;

  // Server Library Settings
  double _globalUpdateInterval = 12.0;
  bool _updateMangas = true;
  bool _excludeCompleted = false;
  bool _excludeNotStarted = false;
  bool _excludeUnreadChapters = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingCategories = true);
    // 1. Load from local DB
    final list = await IsarService.instance.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = list;
    });
    await _refreshNeverUpdatedCount();

    // 2. Refresh from server if available
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final res = await GraphQLClientService.instance.fetchServerSettings();
        if (!mounted) return;
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
        if (!mounted) return;
        final rawNodes = data?['categories']?['nodes'] as List<dynamic>? ?? [];
        if (rawNodes.isNotEmpty) {
          // Malformed ids are skipped, never mapped to Default (id 0) — UIX-14.
          final serverCats = parseCategoryNodes(rawNodes, fallbackName: 'Category');

          // The same wipe guard the sync path applies.
          //
          // `saveCategories` defaults to `replaceAll: true`, which deletes every
          // local category whose id is absent from the incoming list. This call
          // site had only a non-empty check, so a short or truncated response —
          // which `isCompleteSnapshot` exists precisely to detect, and which
          // `fetchCategories` already stamps for exactly this consumer — erased
          // the user's category shelf, and every `Manga.categoryIds` entry
          // pointing at a deleted row, on this device and every other one.
          //
          // Hoisted into `isCategoryPullAcceptable` so the next caller cannot
          // forget it.
          // `>= 0`, not `> 0`: Suwayomi's built-in "Default" category is
          // id 0 — excluding it under-counted the shelf the ratio guard
          // protects. Same fix as SyncEngine._syncCategories.
          final existingServerLinked =
              (await IsarService.instance.getCategories()).where((c) => c.serverId >= 0).length;
          if (!isCategoryPullAcceptable(
            snapshotComplete: isCompleteSnapshot(data),
            incoming: serverCats.length,
            existingServerLinked: existingServerLinked,
          )) {
            await LoggerService.instance.logWarning(
              'Settings category refresh looks incomplete '
              '(${serverCats.length} returned vs $existingServerLinked held); '
              'keeping local categories rather than replacing them',
              'LibrarySettings',
            );
          } else {
            await IsarService.instance.saveCategories(serverCats);
            if (mounted) {
              setState(() => _categories = serverCats);
            }
            await _refreshNeverUpdatedCount();
          }
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[library_settings_screen] ignored error: $ignoredError'); }
    }
    if (mounted) setState(() => _isLoadingCategories = false);
  }

  Future<void> _updateServer(String key, dynamic val) async {
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

  Future<void> _addCategory(String name) async {
    if (name.trim().isEmpty) return;
    final trimmed = name.trim();
    final existing = await IsarService.instance.getCategories();
    if (existing.any((c) => c.name.toLowerCase() == trimmed.toLowerCase())) {
      await _loadData();
      return;
    }
    // Order must be max(existing)+1: using the list length can collide with an
    // existing order after a deletion, which scrambles tab ordering.
    final maxOrder = existing.fold<int>(0, (acc, c) => c.order > acc ? c.order : acc);
    final localCat = Category()
      ..serverId = IsarService.generateSyntheticServerId()
      ..name = trimmed
      ..order = maxOrder + 1;
    await IsarService.instance.saveCategory(localCat);
    await SyncEngine.instance.syncCategoryCreate(
      name: trimmed,
      localServerId: localCat.serverId,
      order: localCat.order,
    );
    await _loadData();
  }

  Future<void> _renameCategory(Category cat, String newName) async {
    if (newName.trim().isEmpty) return;
    final trimmed = newName.trim();
    cat.name = trimmed;
    await IsarService.instance.saveCategory(cat);
    if (_settings.defaultCategoryId == cat.serverId) {
      _settings.defaultCategoryName = trimmed;
    }
    await SyncEngine.instance.syncCategoryRename(cat.serverId, trimmed);
    await _loadData();
  }

  Future<void> _deleteCategory(Category cat) async {
    await IsarService.instance.deleteCategory(cat.serverId);
    await SyncEngine.instance.syncCategoryDelete(cat.serverId);
    if (_settings.defaultCategoryId == cat.serverId) {
      _settings.defaultCategoryId = null;
      _settings.defaultCategoryName = 'Default';
    }
    await _loadData();
  }


  Future<void> _refreshNeverUpdatedCount() async {
    final excludedIds = _categories
        .where((c) => c.includeInUpdate.toUpperCase() == 'EXCLUDE')
        .map((c) => c.serverId)
        .toSet();
    if (excludedIds.isEmpty) {
      if (mounted) setState(() => _neverUpdatedMangaCount = 0);
      return;
    }
    final manga = await IsarService.instance.getLibraryManga();
    var count = 0;
    for (final m in manga) {
      if (m.categoryIds.any(excludedIds.contains)) count++;
    }
    if (mounted) setState(() => _neverUpdatedMangaCount = count);
  }

  Future<void> _setCategoryInclude({
    required Category cat,
    required bool forUpdate,
    required bool enabled,
  }) async {
    final value = enabled ? 'INCLUDE' : 'EXCLUDE';
    if (forUpdate) {
      cat.includeInUpdate = value;
    } else {
      cat.includeInDownload = value;
    }
    await IsarService.instance.saveCategory(cat);
    if (_isConnected) {
      final res = forUpdate
          ? await GraphQLClientService.instance.setCategoryIncludeInUpdate(cat.serverId, value)
          : await GraphQLClientService.instance.setCategoryIncludeInDownload(cat.serverId, value);
      if (!mounted) return;
      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ${forUpdate ? "update" : "download"} include for ${cat.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    await _refreshNeverUpdatedCount();
    if (mounted) setState(() {});
  }

  void _showCategoryIncludeSheet(Category cat) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final cs = Theme.of(ctx).colorScheme;
            final inUpdate = cat.includeInUpdate.toUpperCase() != 'EXCLUDE';
            final inDownload = cat.includeInDownload.toUpperCase() != 'EXCLUDE';
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Server category include flags (ISS-071 / Q5)',
                      style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include in library updates'),
                      subtitle: Text(
                        inUpdate ? 'INCLUDE' : 'EXCLUDE — manga here are skipped on global update',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      value: inUpdate,
                      onChanged: (v) async {
                        await _setCategoryInclude(cat: cat, forUpdate: true, enabled: v);
                        setSheetState(() {});
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include in auto-download'),
                      subtitle: Text(
                        inDownload ? 'INCLUDE' : 'EXCLUDE',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                      value: inDownload,
                      onChanged: (v) async {
                        await _setCategoryInclude(cat: cat, forUpdate: false, enabled: v);
                        setSheetState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ));
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                unawaited(_addCategory(controller.text));
              },
              child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((_) => disposeAfterDialog([controller])));
  }

  void _showRenameCategoryDialog(Category cat) {
    final controller = TextEditingController(text: cat.name);
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                unawaited(_renameCategory(cat, controller.text));
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).then((_) => disposeAfterDialog([controller])));
  }

  void _showDeleteCategoryConfirm(Category cat) {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                unawaited(_deleteCategory(cat));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ));
  }

  void _showDefaultCategoryDialog() {
    final options = ['None (Uncategorized)', ..._categories.map((c) => c.name)];
    // Resolve the current selection by id against the live category list — the
    // stored name may be stale (renamed/deleted category) and would otherwise
    // leave the radio dialog with nothing selected.
    final currentId = _settings.defaultCategoryId;
    final currentVal = currentId == null
        ? 'None (Uncategorized)'
        : (_categories.where((c) => c.serverId == currentId).map((c) => c.name).firstOrNull ??
            'None (Uncategorized)');
    _showRadioDialog(
      title: 'Default Category',
      options: options,
      currentValue: currentVal,
      onSelected: (val) {
        if (val == 'None (Uncategorized)') {
          setState(() {
            _settings.defaultCategoryId = null;
            _settings.defaultCategoryName = 'Default';
          });
        } else {
          final cat = _categories.firstWhere((c) => c.name == val, orElse: () => _categories.first);
          setState(() {
            _settings.defaultCategoryId = cat.serverId;
            _settings.defaultCategoryName = cat.name;
          });
        }
      },
    );
  }

  void _showSkipUpdatingDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
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
                      unawaited(_updateServer('excludeCompleted', val ?? false));
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
                      unawaited(_updateServer('excludeNotStarted', val ?? false));
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
                      unawaited(_updateServer('excludeUnreadChapters', val ?? false));
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
    ));
  }

  void _showRadioDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
    ));
  }

  String _formatLastUpdated(int timestampSec) {
    if (timestampSec <= 0) return 'Never checked';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampSec * 1000);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                        // The server accepts any positive hour count, so the
                        // fixed preset set may not contain the current value —
                        // include a dynamic item so the dropdown never ends up
                        // with a value that has no matching entry (which would
                        // render blank / assert in debug).
                        items: [
                          const DropdownMenuItem(value: 0.0, child: Text('Disabled')),
                          const DropdownMenuItem(value: 6.0, child: Text('Every 6h')),
                          const DropdownMenuItem(value: 12.0, child: Text('Every 12h')),
                          const DropdownMenuItem(value: 24.0, child: Text('Every 24h')),
                          const DropdownMenuItem(value: 48.0, child: Text('Every 48h')),
                          if (!{0.0, 6.0, 12.0, 24.0, 48.0}.contains(_globalUpdateInterval))
                            DropdownMenuItem(
                              value: _globalUpdateInterval,
                              child: Text('Every ${_globalUpdateInterval.toInt()}h (current)'),
                            ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _globalUpdateInterval = val);
                            unawaited(_updateServer('globalUpdateInterval', val));
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
                        unawaited(_updateServer('updateMangas', v));
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
                    const SectionTitle(title: 'Automated Updates & Notifications (Mihon Parity)'),
                    if (!kIsWeb && !Platform.isAndroid)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: const Text(
                            'On iPhone and iPad, library updates run when you open the app (background WorkManager is Android-only for sideload stability).',
                            style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35),
                          ),
                        ),
                      ),
                    if (!kIsWeb && Platform.isAndroid) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Library Update Frequency', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: Text(
                        _settings.libraryUpdateFrequencyHours == 0
                            ? 'Disabled'
                            : _settings.libraryUpdateFrequencyHours < 24
                                ? 'Every ${_settings.libraryUpdateFrequencyHours} hour${_settings.libraryUpdateFrequencyHours > 1 ? "s" : ""}'
                                : 'Every ${_settings.libraryUpdateFrequencyHours ~/ 24} day${(_settings.libraryUpdateFrequencyHours ~/ 24) > 1 ? "s" : ""}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: DropdownButton<int>(
                        value: _settings.libraryUpdateFrequencyHours,
                        dropdownColor: const Color(0xFF22222A),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Disabled')),
                          DropdownMenuItem(value: 1, child: Text('Every 1h')),
                          DropdownMenuItem(value: 6, child: Text('Every 6h')),
                          DropdownMenuItem(value: 12, child: Text('Every 12h')),
                          DropdownMenuItem(value: 24, child: Text('Daily (24h)')),
                          DropdownMenuItem(value: 48, child: Text('Every 2 days')),
                          DropdownMenuItem(value: 72, child: Text('Every 3 days')),
                          DropdownMenuItem(value: 168, child: Text('Weekly')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _settings.libraryUpdateFrequencyHours = val);
                            unawaited(BackgroundService.instance.rescheduleTask());
                          }
                        },
                      ),
                    ),
                    SettingsPropTile(
                      title: 'Only on Wi-Fi',
                      subtitle: 'Avoid updating library and checking chapters over cellular data',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.libraryUpdateOnlyOnWifi,
                      onBoolChanged: (v) {
                        _settings.libraryUpdateOnlyOnWifi = v;
                        unawaited(BackgroundService.instance.rescheduleTask());
                      },
                    ),
                    SettingsPropTile(
                      title: 'Only While Charging',
                      subtitle: 'Defer automated background refreshes until device is plugged in',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.libraryUpdateOnlyCharging,
                      onBoolChanged: (v) {
                        _settings.libraryUpdateOnlyCharging = v;
                        unawaited(BackgroundService.instance.rescheduleTask());
                      },
                    ),
                    ],
                    SettingsPropTile(
                      title: 'New Chapter Notifications',
                      subtitle: 'Show system notifications when new chapters are found',
                      scope: SettingScope.local,
                      kind: SettingsPropKind.switchTile,
                      boolValue: _settings.newChapterNotificationsEnabled,
                      onBoolChanged: (v) => _settings.newChapterNotificationsEnabled = v,
                    ),
                    ListenableBuilder(
                      listenable: LibraryUpdateService.instance,
                      builder: (context, _) {
                        final updater = LibraryUpdateService.instance;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      updater.isUpdating ? Icons.sync : Icons.update_rounded,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        updater.isUpdating
                                            ? updater.statusMessage
                                            : 'Last checked: ${_formatLastUpdated(_settings.lastLibraryUpdateTimestamp)}',
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (updater.isUpdating) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: updater.progress > 0 ? updater.progress : null,
                                      minHeight: 4,
                                      backgroundColor: const Color(0x22FFFFFF),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.tonalIcon(
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: const Text('Check for New Chapters Now'),
                                      onPressed: () async {
                                        final count = await LibraryUpdateService.instance.checkForNewChapters(isManual: true);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(count > 0 ? 'Found $count new chapters!' : 'Library is up to date'),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
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
                          options: const ['Comfortable Grid', 'Compact Grid', 'List', 'Cover Only'],
                          currentValue: _settings.libraryDisplayMode,
                          onSelected: (val) => setState(() => _settings.libraryDisplayMode = val),
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: const Icon(Icons.category_outlined),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Default Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          SunfireBadge.local(),
                        ],
                      ),
                      subtitle: Text(
                        _settings.defaultCategoryId == null ? 'None (Uncategorized)' : _settings.defaultCategoryName,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: _showDefaultCategoryDialog,
                    ),
                    const Divider(height: 1, color: Color(0x1AFFFFFF)),
                    SectionTitle(title: _isConnected ? 'Categories (Server Synced)' : 'Categories (Local)'),
                    if (_neverUpdatedMangaCount > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Container(
                          key: const Key('category_never_updated_warning'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            categoryNeverUpdatedWarning(_neverUpdatedMangaCount)!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    if (_categories.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: Colors.grey),
                        title: Text('No categories created yet', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        subtitle: Text('Tap + to create categories and organize your library.'),
                      )
                    else
                      ..._categories.map((cat) {
                        final updateExcluded = cat.includeInUpdate.toUpperCase() == 'EXCLUDE';
                        final downloadExcluded = cat.includeInDownload.toUpperCase() == 'EXCLUDE';
                        final flags = <String>[
                          if (updateExcluded) 'updates off',
                          if (downloadExcluded) 'downloads off',
                        ];
                        return ListTile(
                          key: Key('category_include_tile_${cat.serverId}'),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          leading: Icon(
                            updateExcluded ? Icons.label_off_outlined : Icons.label_outline_rounded,
                            color: updateExcluded
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              _isConnected ? SunfireBadge.server() : SunfireBadge.local(),
                            ],
                          ),
                          subtitle: Text(
                            flags.isEmpty
                                ? 'Included in updates & downloads — tap to change'
                                : '${flags.join(' · ')} — tap to change',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () => _showCategoryIncludeSheet(cat),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Rename',
                                onPressed: () => _showRenameCategoryDialog(cat),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                tooltip: 'Delete',
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

/// Warning copy when excluded categories leave manga out of global updates (Q5).
String? categoryNeverUpdatedWarning(int excludedMangaCount) {
  if (excludedMangaCount <= 0) return null;
  if (excludedMangaCount == 1) {
    return '1 manga is never updated (in excluded categories).';
  }
  return '$excludedMangaCount manga are never updated (in excluded categories).';
}
