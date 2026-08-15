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
                                return ListTile(
                                  leading: Icon(Icons.folder_special_rounded, color: primaryColor),
                                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Category ID: ${cat.serverId} • Order: ${cat.order}'),
                                  trailing: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
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
}
