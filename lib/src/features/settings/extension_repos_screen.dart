import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/engine/repo_manager.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/server_compat_models.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/shell/sunfire_breakpoints.dart';
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
  bool _isRefreshing = false;
  String? _lastRefreshText;
  List<ExtensionStoreInfo> _serverStores = const [];
  bool _serverStoresLoading = false;
  bool _serverStoresSupported = false;
  bool _serverRefreshing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadServerStores());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _refreshReposNow() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final urls = _settings.customRepos;
      if (urls.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add a repository first.')),
          );
        }
        return;
      }
      final count = await RepoManager.instance.downloadAndInstallAllRepoExtensions(userRepoUrls: urls);
      if (!mounted) return;
      setState(() {
        _lastRefreshText = 'Updated $count extensions · ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Installed/updated $count extensions from repos.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Repo refresh failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  bool _listContainsRepo(List<String> urls, String candidate) {
    final normalized = RepoManager.normalizeRepoUrl(candidate);
    return urls.any((url) => url == candidate || RepoManager.normalizeRepoUrl(url) == normalized);
  }

  Future<void> _addPreset(String url) async {
    final normalized = RepoManager.normalizeRepoUrl(url);
    await _settings.addCustomRepo(normalized);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added repository: ${RepoManager.deriveRepoTitle(normalized)}')),
    );
  }

  void _showAddRepoDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
unawaited(
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                  hintText: RepoManager.officialIndexUrl,
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
                  final parsed = Uri.tryParse(url);
                  if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid HTTP/HTTPS URL')),
                    );
                    return;
                  }
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
    ));
  }


  Future<void> _loadServerStores() async {
    if (!GraphQLClientService.instance.isConfigured) {
      if (mounted) {
        setState(() {
          _serverStoresSupported = false;
          _serverStores = const [];
        });
      }
      return;
    }
    if (mounted) setState(() => _serverStoresLoading = true);
    try {
      final caps = await GraphQLClientService.instance.probeServerCapabilities();
      final supported = caps.hasExtensionStores;
      List<ExtensionStoreInfo> stores = const [];
      if (supported) {
        stores = await GraphQLClientService.instance.fetchExtensionStores(includeCounts: true) ?? const [];
      }
      if (!mounted) return;
      setState(() {
        _serverStoresSupported = supported;
        _serverStores = stores;
        _serverStoresLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _serverStoresSupported = false;
          _serverStoresLoading = false;
        });
      }
    }
  }

  Future<void> _refreshServerStores() async {
    if (_serverRefreshing) return;
    setState(() => _serverRefreshing = true);
    try {
      final result = await GraphQLClientService.instance.refreshExtensionStores();
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _serverStores = result.stores;
          _lastRefreshText =
              'Server: ${result.extensions.length} extensions · ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refreshed ${result.stores.length} store(s), ${result.extensions.length} extensions.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server store refresh failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server store refresh failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _serverRefreshing = false);
    }
  }

  Future<void> _addServerStore(String url) async {
    final store = await GraphQLClientService.instance.addExtensionStore(url);
    if (!mounted) return;
    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add store — check the index URL.')),
      );
      return;
    }
    await _loadServerStores();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added server store: ${store.name.isEmpty ? store.indexUrl : store.name}')),
      );
    }
  }

  Future<void> _removeServerStore(ExtensionStoreInfo store) async {
    final ok = await GraphQLClientService.instance.removeExtensionStore(store.indexUrl);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove server store.')),
      );
      return;
    }
    await _loadServerStores();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${store.name.isEmpty ? store.indexUrl : store.name}')),
      );
    }
  }

  void _showAddServerStoreDialog() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ctrl = TextEditingController();
    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Add server extension store'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Index URL',
              hintText: 'https://…/index.min.json or index.pb',
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                final url = ctrl.text.trim();
                Navigator.pop(ctx);
                if (url.isNotEmpty) unawaited(_addServerStore(url));
              },
              child: Text('Add', style: TextStyle(color: Theme.of(ctx).colorScheme.onPrimary)),
            ),
          ],
        ),
      ).whenComplete(ctrl.dispose),
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
            padding: EdgeInsets.only(bottom: SunfireBreakpoints.scrollBottomPadding(context)),
            children: [
              const SectionTitle(title: 'Suggested Repositories'),
              if (!_listContainsRepo(customList, RepoManager.officialIndexUrl))
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Icon(Icons.local_fire_department_rounded, color: primaryColor),
                  title: const Text(RepoManager.officialRepoTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: const Text('9 maintained sources (same as bundled extensions)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: TextButton(
                    onPressed: () => _addPreset(RepoManager.officialIndexUrl),
                    child: const Text('Add'),
                  ),
                ),
              if (!_listContainsRepo(customList, RepoManager.communityIndexUrl))
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Icon(Icons.auto_awesome_rounded, color: primaryColor),
                  title: const Text(RepoManager.communityRepoTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: const Text('100+ public scrapers (MangaDex, ComicK, etc.)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: TextButton(
                    onPressed: () => _addPreset(RepoManager.communityIndexUrl),
                    child: const Text('Add'),
                  ),
                ),
              if (_serverStoresSupported) ...[
                const SectionTitle(title: 'Server Extension Stores'),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: (_serverRefreshing || _serverStoresLoading)
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.cloud_sync_rounded, color: primaryColor),
                  title: const Text('Refresh Server Stores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: const Text('Re-download store indexes on Suwayomi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: TextButton(
                    onPressed: _showAddServerStoreDialog,
                    child: const Text('Add'),
                  ),
                  onTap: (_serverRefreshing || _serverStoresLoading) ? null : _refreshServerStores,
                ),
                if (!_serverStoresLoading && _serverStores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No server stores yet — add an index URL.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                else
                  ..._serverStores.map((store) {
                    final title = store.name.isNotEmpty ? store.name : RepoManager.deriveRepoTitle(store.indexUrl);
                    final count = store.extensionCount;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Icon(Icons.storefront_rounded, color: primaryColor),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SunfireBadge.server(),
                          if (store.badgeLabel.isNotEmpty)
                            Text(store.badgeLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      subtitle: Text(
                        count != null ? '${store.indexUrl} · $count extensions' : store.indexUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () => unawaited(_removeServerStore(store)),
                      ),
                    );
                  }),
              ],
              const SectionTitle(title: 'Configured Repositories'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: _isRefreshing
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.system_update_alt_rounded, color: primaryColor),
                title: const Text('Update Extensions Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(
                  _lastRefreshText ?? 'Fetch indexes and install available updates from configured repos',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: _isRefreshing ? null : _refreshReposNow,
              ),
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
                          'Add the official Sunfire index or a community MangaYomi index.json to discover and update scrapers.',
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
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SunfireBadge.local(),
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
