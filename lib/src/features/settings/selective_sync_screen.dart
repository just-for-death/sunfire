// lib/src/features/settings/selective_sync_screen.dart
//
// S1.4: Pick manga or categories and sync only that subset via SyncManager.

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/db/models/manga.dart';
import '../../core/sync/sync_manager.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/design_system/components/components.dart' show SunfireButton;
import '../../ui/widgets/sync_ui_actions.dart';

class SelectiveSyncScreen extends StatefulWidget {
  const SelectiveSyncScreen({super.key});

  @override
  State<SelectiveSyncScreen> createState() => _SelectiveSyncScreenState();
}

class _SelectiveSyncScreenState extends State<SelectiveSyncScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<Manga> _library = const [];
  List<Category> _categories = const [];
  final Set<int> _selectedManga = {};
  final Set<int> _selectedCategories = {};
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    unawaited(_load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final library = await IsarService.instance.getLibraryManga();
      final cats = await IsarService.instance.getCategories();
      if (!mounted) return;
      setState(() {
        _library = library;
        _categories = cats;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Manga> get _filteredManga {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _library;
    return _library
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.sourceName.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _syncSelectedManga() async {
    if (_selectedManga.isEmpty) return;
    await runSyncWithProgressDialog(
      context,
      title: 'Selective manga sync',
      syncFn: () => SyncManager.instance.syncManga(Set<int>.from(_selectedManga)),
    );
  }

  Future<void> _syncSelectedCategories() async {
    if (_selectedCategories.isEmpty) return;
    await runSyncWithProgressDialog(
      context,
      title: 'Selective category sync',
      syncFn: () => SyncManager.instance
          .syncCategories(Set<int>.from(_selectedCategories)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Selective Sync'),
            SunfireBadge.local(),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Manga'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _buildMangaTab(),
                _buildCategoryTab(),
              ],
            ),
    );
  }

  Widget _buildMangaTab() {
    final items = _filteredManga;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter library…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No manga in library'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final m = items[index];
                    final id = m.canonicalKey;
                    final selected = _selectedManga.contains(id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(m.title),
                      subtitle: Text(
                        m.sourceName.isEmpty ? 'Local' : m.sourceName,
                      ),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedManga.add(id);
                          } else {
                            _selectedManga.remove(id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SunfireButton.primary(
              expanded: true,
              icon: Icons.sync,
              label: 'Sync ${_selectedManga.length} manga',
              onPressed: _selectedManga.isEmpty
                  ? null
                  : () => unawaited(_syncSelectedManga()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab() {
    return Column(
      children: [
        Expanded(
          child: _categories.isEmpty
              ? const Center(child: Text('No categories yet'))
              : ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final c = _categories[index];
                    final id = c.serverId;
                    final selected = _selectedCategories.contains(id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(c.name),
                      subtitle: Text('id $id'),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedCategories.add(id);
                          } else {
                            _selectedCategories.remove(id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SunfireButton.primary(
              expanded: true,
              icon: Icons.sync,
              label: 'Sync ${_selectedCategories.length} categories',
              onPressed: _selectedCategories.isEmpty
                  ? null
                  : () => unawaited(_syncSelectedCategories()),
            ),
          ),
        ),
      ],
    );
  }
}
