import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';

class LibrarySettingsScreen extends StatefulWidget {
  const LibrarySettingsScreen({super.key});

  @override
  State<LibrarySettingsScreen> createState() => _LibrarySettingsScreenState();
}

class _LibrarySettingsScreenState extends State<LibrarySettingsScreen> {
  final SettingsService _settings = SettingsService.instance;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    // 1. Load from local DB
    final list = await IsarService.instance.getCategories();
    setState(() {
      _categories = list;
      _isLoadingCategories = false;
    });

    // 2. Refresh from server if available
    if (GraphQLClientService.instance.isConfigured) {
      try {
        final data = await GraphQLClientService.instance.fetchCategories();
        final rawNodes = data?['categories']?['nodes'] as List<dynamic>? ?? [];
        if (rawNodes.isNotEmpty) {
          final serverCats = <Category>[];
          for (final n in rawNodes) {
            final cMap = n as Map<String, dynamic>;
            final cat = Category()
              ..serverId = cMap['id'] as int
              ..name = cMap['name'] as String? ?? 'Category'
              ..order = cMap['order'] as int? ?? 0;
            serverCats.add(cat);
          }
          await IsarService.instance.saveCategories(serverCats);
          if (mounted) {
            setState(() => _categories = serverCats);
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _addCategory(String name) async {
    if (name.trim().isEmpty) return;
    setState(() => _isLoadingCategories = true);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.createCategory(name.trim());
      }
    } catch (_) {}
    await _loadCategories();
  }

  Future<void> _renameCategory(Category cat, String newName) async {
    if (newName.trim().isEmpty) return;
    setState(() => _isLoadingCategories = true);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.updateCategoryName(cat.serverId, newName.trim());
      }
    } catch (_) {}
    await _loadCategories();
  }

  Future<void> _deleteCategory(Category cat) async {
    setState(() => _isLoadingCategories = true);
    await IsarService.instance.deleteCategory(cat.serverId);
    try {
      if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.deleteCategory(cat.serverId);
      }
    } catch (_) {}
    await _loadCategories();
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Library & Categories'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Add Category',
                onPressed: _showAddCategoryDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Categories',
                onPressed: _loadCategories,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              Text('LIBRARY DISPLAY', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.mark_unread_chat_alt_rounded, color: primaryColor),
                      title: const Text('Show Unread Chapter Badges', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Display unread counter badges on manga covers'),
                      value: _settings.showUnreadBadges,
                      onChanged: (val) => _settings.showUnreadBadges = val,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('DEFAULT CATEGORY FOR NEW MANGA', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: ListTile(
                  leading: Icon(Icons.bookmark_added_rounded, color: primaryColor),
                  title: const Text('Default Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Added titles will be placed in: ${_settings.defaultCategoryName}'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: _showDefaultCategoryDialog,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CATEGORIES ENGINE (SYNCED WITH SERVER)', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: _isLoadingCategories
                    ? Padding(padding: const EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator(color: primaryColor)))
                    : Column(
                        children: _categories.isEmpty
                            ? [
                                const ListTile(
                                  title: Text('No categories synced yet', style: TextStyle(color: Colors.grey)),
                                )
                              ]
                            : _categories.map((cat) {
                                final isDefault = _settings.defaultCategoryId == cat.serverId;
                                return ListTile(
                                  leading: Icon(Icons.folder_special_rounded, color: isDefault ? Colors.amber : primaryColor),
                                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Category ID: ${cat.serverId} • Order: ${cat.order}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isDefault)
                                        Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.amber.withAlpha(40), borderRadius: BorderRadius.circular(8)),
                                          child: const Text('DEFAULT', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Colors.grey, size: 18),
                                        tooltip: 'Rename',
                                        onPressed: () => _showRenameCategoryDialog(cat),
                                      ),
                                      if (cat.serverId != 0)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                          tooltip: 'Delete',
                                          onPressed: () => _showDeleteCategoryConfirm(cat),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDefaultCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Default Category', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('None (Uncategorized / Default)'),
                  trailing: _settings.defaultCategoryId == null ? const Icon(Icons.check_rounded, color: Colors.amber) : null,
                  onTap: () {
                    _settings.defaultCategoryId = null;
                    _settings.defaultCategoryName = 'Default';
                    Navigator.pop(context);
                  },
                ),
                ..._categories.map((cat) {
                  final isSelected = _settings.defaultCategoryId == cat.serverId;
                  return ListTile(
                    title: Text(cat.name),
                    trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.amber) : null,
                    onTap: () {
                      _settings.defaultCategoryId = cat.serverId;
                      _settings.defaultCategoryName = cat.name;
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
