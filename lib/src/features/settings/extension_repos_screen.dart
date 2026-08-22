import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/engine/repo_manager.dart';
import '../../core/services/settings_service.dart';

class ExtensionReposScreen extends StatefulWidget {
  const ExtensionReposScreen({super.key});

  @override
  State<ExtensionReposScreen> createState() => _ExtensionReposScreenState();
}

class _ExtensionReposScreenState extends State<ExtensionReposScreen> {
  final SettingsService _settings = SettingsService.instance;
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showAddRepoDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: const Text('Add Extension Repository', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter a raw GitHub or web URL pointing to a MangaYomi index.json:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'https://raw.githubusercontent.com/.../index.json',
                  prefixIcon: Icon(Icons.link_rounded, color: primaryColor),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _urlController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) {
                  final normalized = RepoManager.normalizeRepoUrl(url);
                  await _settings.addCustomRepo(normalized);
                  _urlController.clear();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added repository: ${RepoManager.deriveRepoTitle(normalized)}')),
                    );
                  }
                }
              },
              child: const Text('Add Repo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        final customList = _settings.customRepos;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Extension Repositories'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_rounded, color: primaryColor),
                onPressed: () => _showAddRepoDialog(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              Text('CONFIGURED REPOSITORIES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: customList.isEmpty
                    ? const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: Colors.grey),
                        title: Text('No custom repositories added.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        subtitle: Text('Tap + to register your custom MangaYomi index.json repository URL.'),
                      )
                    : Column(
                        children: customList.map((url) {
                          final title = RepoManager.deriveRepoTitle(url);
                          return ListTile(
                            leading: Icon(Icons.link_rounded, color: primaryColor),
                            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              onPressed: () async {
                                await _settings.removeCustomRepo(url);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Removed repository: $title')),
                                  );
                                }
                              },
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
}
