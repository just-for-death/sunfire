import 'package:flutter/material.dart';

import '../../core/engine/repo_manager.dart';
import '../../core/services/settings_service.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_subpage_scaffold.dart';

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

        return SettingsSubpageScaffold(
          title: 'Extension Repositories',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddRepoDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Repo', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SectionTitle(title: 'Configured Repositories'),
              if (customList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.extension_off_outlined, size: 48, color: Colors.grey.withAlpha(120)),
                        const SizedBox(height: 12),
                        const Text('No custom repositories configured', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text(
                          'Add community MangaYomi index.json repository URLs to discover and install scrapers.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...customList.map((url) {
                  final title = RepoManager.deriveRepoTitle(url);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.hub_rounded, color: primaryColor, size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4), width: 0.8),
                          ),
                          child: const Text('LOCAL', style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () async {
                        await _settings.removeCustomRepo(url);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed $title')),
                          );
                        }
                      },
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
