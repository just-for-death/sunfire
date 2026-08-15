import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/category.dart';
import '../../core/services/settings_service.dart';

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
    final list = await IsarService.instance.getCategories();
    setState(() {
      _categories = list;
      _isLoadingCategories = false;
    });
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

              Text('CATEGORIES ENGINE (SYNCED WITH SERVER)', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                                  trailing: isDefault
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.amber.withAlpha(40), borderRadius: BorderRadius.circular(8)),
                                          child: const Text('DEFAULT', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )
                                      : null,
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
