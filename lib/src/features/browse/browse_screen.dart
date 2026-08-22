import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/quickjs_service.dart';
import '../../core/engine/repo_manager.dart';
import '../../core/engine/source_migration_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import 'extension_details_screen.dart';
import 'global_search_screen.dart';
import 'migrate_search_screen.dart';
import 'source_manga_grid_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── SOURCES STATE ────────────────────────────────────────
  List<Map<String, dynamic>> _sourcesList = [];
  bool _isLoadingSources = true;
  String _sourceSearchQuery = '';
  String _selectedLangFilter = 'EN';

  // ── EXTENSIONS STATE ─────────────────────────────────────
  List<Map<String, dynamic>> _extensionList = [];
  bool _isLoadingExtensions = true;
  String _extensionSearchQuery = '';
  String _selectedRepoUrl = '';

  // ── MIGRATION STATE ──────────────────────────────────────
  List<Manga> _libraryMangaList = [];
  bool _isLoadingLibrary = true;
  bool _migrateSortByCount = true; // true = Count desc, false = Alphabetical A-Z

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchServerSources();
    _fetchExtensions();
    _loadLibraryForMigration();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchServerSources() async {
    setState(() => _isLoadingSources = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // ── STEP 1: Always load installed local JS extensions FIRST (fully offline) ──
    final List<Map<String, dynamic>> localJsSources = [];
    final installedNames = QuickJsService.instance.getInstalledExtensionNames();
    for (final name in installedNames) {
      final localId = 'local_js_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}';
      localJsSources.add({
        'id': localId,
        'name': name,
        'displayName': '$name ⚡',
        'lang': 'en',
        'supportsLatest': true,
        'isPinned': SettingsService.instance.isSourcePinned(localId),
        'iconUrl': '',
        'isLocalJs': true,
      });
    }

    // ── STEP 2: Try fetching server sources (optional, 4s timeout) ──
    final List<ServerSourceItem> serverSourceItems = [];
    final Map<String, String> serverIconMap = {};
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance
            .fetchSources()
            .timeout(const Duration(seconds: 4), onTimeout: () => null);
        if (data != null && data.containsKey('sources')) {
          final nodes = data['sources']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final m = n as Map<String, dynamic>;
              final id = m['id'].toString();
              final name = m['name'] as String? ?? 'Source';
              final rawIcon = m['iconUrl'] as String?;
              final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                  ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                  : '$serverUrl/api/v1/source/$id/icon';
              serverSourceItems.add(ServerSourceItem(
                id: id,
                name: name,
                lang: m['lang'] as String? ?? 'en',
              ));
              serverIconMap[id] = iconUrl;
            }
          }
        }
      }
    } catch (_) {
      // Server unreachable — local JS sources still work
    }

    // ── STEP 3: Deduplicate using SourceMigrationService (Zero UI duplication) ──
    final filteredDisplay = SourceMigrationService.instance.filterDisplaySources(
      localInstalledExtensions: installedNames,
      serverInstalledSources: serverSourceItems,
    );

    final merged = <Map<String, dynamic>>[];
    for (final item in filteredDisplay) {
      final isLocal = item.isLocalJs;
      final iconUrl = isLocal ? QuickJsService.instance.getSourceIconUrl(item.name) : (serverIconMap[item.id] ?? '');
      merged.add({
        'id': item.id,
        'name': item.name,
        'displayName': isLocal ? '${item.name} ⚡' : '${item.name} ☁',
        'lang': item.lang,
        'supportsLatest': true,
        'isPinned': SettingsService.instance.isSourcePinned(item.id),
        'iconUrl': iconUrl,
        'isLocalJs': isLocal,
        'isServerFallback': item.isServerFallback,
      });
    }

    setState(() {
      _sourcesList = merged;
      _isLoadingSources = false;
    });
  }


  Future<void> _fetchExtensions() async {
    setState(() => _isLoadingExtensions = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
    try {
      final items = <Map<String, dynamic>>[];
      final seenKeys = <String>{};

      // 1. Fetch server-side Keiyoushi APK extensions via GraphQL (only if server is online)
      final isServerOnline = await GraphQLClientService.instance.checkServerReachable();
      if (isServerOnline) {
        try {
          final data = await GraphQLClientService.instance.fetchExtensions();

          if (data != null && data.containsKey('extensions')) {
            final nodes = data['extensions']['nodes'] as List<dynamic>?;
            if (nodes != null) {
              for (final n in nodes) {
                final map = n as Map<String, dynamic>;
                final name = map['name'] as String? ?? 'Extension';
                final lang = map['lang'] as String? ?? 'en';
                final key = 'apk_${name}_$lang'.toLowerCase();
                if (!seenKeys.add(key)) continue;

                final rawIcon = map['iconUrl'] as String?;
                final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                    ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                    : '';

                items.add({
                  'id': (map['pkgName'] ?? map['name']).toString(),
                  'name': lang.toLowerCase() == 'en' || lang.isEmpty ? name : '$name (${lang.toUpperCase()})',
                  'lang': lang,
                  'version': (map['versionName'] ?? map['version'] ?? '1.0.0').toString(),
                  'isInstalled': map['isInstalled'] as bool? ?? false,
                  'iconUrl': iconUrl,
                  'isJs': false,
                });
              }
            }
          }
        } catch (_) {}
      }

      // 2. Fetch local JS repo extensions from user-configured repositories
      final customRepos = SettingsService.instance.customRepos;
      if (_selectedRepoUrl.isEmpty && customRepos.isNotEmpty) {
        _selectedRepoUrl = customRepos.first;
      }

      if (_selectedRepoUrl.isNotEmpty) {
        final jsList = await RepoManager.instance.fetchRepoSources(_selectedRepoUrl);
        for (final js in jsList) {
          final key = 'js_${js.name}_${js.lang}'.toLowerCase();
          if (!seenKeys.add(key)) continue;

          final jsLang = js.lang.toLowerCase();
          final isEn = jsLang == 'en' || jsLang == 'all';
          final isInstalled = isEn && QuickJsService.instance.isLocalExtensionInstalled(js.name);

          var iconUrl = js.iconUrl;
          if (iconUrl.isEmpty || iconUrl.contains('m2k3a/mangayomi-extensions/main/javascript/icon')) {
            iconUrl = QuickJsService.instance.getSourceIconUrl(js.name);
          }

          items.add({
            'id': '${js.name}_${js.lang}',
            'name': js.lang.toLowerCase() == 'en' || js.lang.isEmpty ? js.name : '${js.name} (${js.lang.toUpperCase()})',
            'lang': js.lang,
            'version': js.version,
            'isInstalled': isInstalled,
            'sourceCodeUrl': js.sourceCodeUrl,
            'iconUrl': iconUrl,
            'isJs': true,
          });
        }
      }

      setState(() {
        _extensionList = items;
        _isLoadingExtensions = false;
      });
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch extensions: $e', exception: e, stackTrace: stack, category: 'Browse');
      setState(() => _isLoadingExtensions = false);
    }
  }

  Future<void> _loadLibraryForMigration() async {
    setState(() => _isLoadingLibrary = true);
    try {
      var mangas = await IsarService.instance.getLibraryManga();

      if (mangas.isEmpty) {
        await SyncEngine.instance.triggerSync();
        mangas = await IsarService.instance.getLibraryManga();
      }

      setState(() {
        _libraryMangaList = mangas;
        _isLoadingLibrary = false;
      });
    } catch (_) {
      setState(() => _isLoadingLibrary = false);
    }
  }

  void _openSourceGrid(String id, String name, bool isLatest) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SourceMangaGridScreen(
          sourceId: id,
          sourceName: name,
          isLatest: isLatest,
        ),
      ),
    );
  }

  void _toggleSourcePin(String id) {
    SettingsService.instance.togglePinSource(id);
    setState(() {
      final idx = _sourcesList.indexWhere((s) => s['id'] == id);
      if (idx != -1) {
        _sourcesList[idx]['isPinned'] = SettingsService.instance.isSourcePinned(id);
      }
    });
  }

  void _toggleExtensionInstallation(Map<String, dynamic> ext) async {
    final name = ext['name'] as String;
    final isInstalled = ext['isInstalled'] as bool;
    final id = ext['id'] as String;
    final isJs = ext['isJs'] as bool? ?? false;
    final sourceCodeUrl = ext['sourceCodeUrl'] as String? ?? '';
    String? customStatusMessage;

    setState(() {
      ext['isInstalled'] = !isInstalled;
    });

    try {
      if (isJs) {
        if (!isInstalled && sourceCodeUrl.isNotEmpty) {
          final code = await RepoManager.instance.downloadJsSourceCode(sourceCodeUrl);
          if (code != null) {
            await QuickJsService.instance.saveLocalExtension(name, code);

            // Check if available on server and trigger dual install
            final serverExtensionNames = _extensionList
                .where((e) => e['isJs'] == false)
                .map((e) => e['name'] as String)
                .toList();

            final dualResult = SourceMigrationService.instance.checkAndInstallSourceDualChannel(
              jsExtensionName: name,
              serverAvailableSourceNames: serverExtensionNames,
            );

            customStatusMessage = dualResult.statusMessage;

            if (dualResult.isAvailableOnServer && GraphQLClientService.instance.isConfigured) {
              final serverExt = _extensionList.firstWhere(
                (e) => e['name'] == dualResult.serverSourceName,
                orElse: () => {},
              );
              if (serverExt.isNotEmpty && serverExt['id'] != null) {
                await GraphQLClientService.instance.updateExtension(
                  serverExt['id'].toString(),
                  'INSTALL',
                );
              }
            }
          }
        } else if (isInstalled) {
          await QuickJsService.instance.deleteLocalExtension(name);
        }
      } else if (GraphQLClientService.instance.isConfigured) {
        await GraphQLClientService.instance.updateExtension(id, isInstalled ? 'UNINSTALL' : 'INSTALL');
      }
    } catch (_) {}

    await _fetchServerSources();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customStatusMessage ??
                (isInstalled ? 'Uninstalled $name' : 'Installed $name (Ready for on-device scraping)'),
          ),
        ),
      );
    }
  }

  void _showExtensionSettingsDialog(Map<String, dynamic> ext) async {
    final uninstalled = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ExtensionDetailsScreen(extensionData: ext),
      ),
    );

    if (uninstalled == true && mounted) {
      _toggleExtensionInstallation(ext);
    }
  }

  void _showAddRepoDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F24),
        title: const Text('Add Extension Repository', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://raw.githubusercontent.com/.../index.json',
            labelText: 'Repository URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                final normalized = RepoManager.normalizeRepoUrl(url);
                final nav = Navigator.of(context);
                await SettingsService.instance.addCustomRepo(normalized);
                nav.pop();
                if (mounted) {
                  setState(() => _selectedRepoUrl = normalized);
                  _fetchExtensions();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: Icon(Icons.travel_explore_rounded, color: primaryColor),
            tooltip: 'Global Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GlobalSearchScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Sources'),
            Tab(text: 'Extensions'),
            Tab(text: 'Migrate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSourcesTab(),
          _buildExtensionsTab(),
          _buildMigrateTab(),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // ── 1. SOURCES TAB ───────────────────────────────────────
  // ═════════════════════════════════════════════════════════
  Widget _buildSourcesTab() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoadingSources) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    final filtered = _sourcesList.where((s) {
      final name = (s['name'] as String).toLowerCase();
      final lang = (s['lang'] as String).toUpperCase();
      final isEnglish = lang == 'EN' || lang == 'ALL' || lang.isEmpty;
      if (!isEnglish) return false;

      final matchesSearch = _sourceSearchQuery.isEmpty || name.contains(_sourceSearchQuery.toLowerCase());
      final matchesLang = _selectedLangFilter.toUpperCase() == 'ALL' || _selectedLangFilter.toUpperCase() == 'EN' ? isEnglish : lang == _selectedLangFilter.toUpperCase();
      return matchesSearch && matchesLang;
    }).toList();

    final pinned = filtered.where((s) => s['isPinned'] == true).toList();
    final unpinned = filtered.where((s) => s['isPinned'] != true).toList();
    final localJsUnpinned = unpinned.where((s) => s['isLocalJs'] == true).toList();
    final serverUnpinned = unpinned.where((s) => s['isLocalJs'] != true).toList();

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _fetchServerSources,
      child: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 120.0),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sources...',
                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _sourceSearchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list_rounded, color: primaryColor),
                onSelected: (lang) => setState(() => _selectedLangFilter = lang),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'ALL', child: Text('All Languages')),
                  PopupMenuItem(value: 'EN', child: Text('English (EN)')),
                  PopupMenuItem(value: 'JA', child: Text('Japanese (JA)')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (pinned.isNotEmpty) ...[
            Text('PINNED SOURCES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...pinned.map((s) => _buildSourceItemTile(s)),
            const Divider(height: 24, color: Color(0x1AFFFFFF)),
          ],

          if (localJsUnpinned.isNotEmpty) ...[
            const Text(
              '⚡ LOCAL EXTENSIONS (On-Device Engine - Fast & Offline)',
              style: TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            ...localJsUnpinned.map((s) => _buildSourceItemTile(s)),
            const SizedBox(height: 16),
          ],

          if (serverUnpinned.isNotEmpty) ...[
            const Text(
              '☁ SERVER SOURCES (Suwayomi Proxy)',
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            ...serverUnpinned.map((s) => _buildSourceItemTile(s)),
          ],

          if (unpinned.isEmpty && pinned.isEmpty)
            const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('No sources found.', style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }

  Widget _buildSourceItemTile(Map<String, dynamic> source) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final id = source['id'] as String;
    final name = source['name'] as String;
    final displayName = source['displayName'] as String? ?? name;
    final lang = (source['lang'] as String).toUpperCase();
    final iconUrl = source['iconUrl'] as String? ?? '';
    final bool isPinned = source['isPinned'] as bool? ?? false;
    final bool isLocalJs = source['isLocalJs'] as bool? ?? false;
    final bool supportsLatest = source['supportsLatest'] as bool? ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: const Color(0x1F2A2A32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? primaryColor : Colors.grey,
                  size: 20,
                ),
                onPressed: () => _toggleSourcePin(id),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: iconUrl.isNotEmpty
                      ? Image.network(
                          iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            name.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4)),
                          child: Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLocalJs ? Colors.teal.withAlpha(50) : Colors.blue.withAlpha(50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isLocalJs ? '⚡ Local' : '☁ Server',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isLocalJs ? Colors.tealAccent : Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (supportsLatest)
                TextButton(
                  onPressed: () => _openSourceGrid(id, name, true),
                  child: const Text('Latest', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: () => _openSourceGrid(id, name, false),
                child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  String _selectedExtensionFilter = 'All'; // 'All', 'Local JS', 'Server APK', 'Installed'

  // ── 2. EXTENSIONS TAB ────────────────────────────────────
  // ═════════════════════════════════════════════════════════
  Widget _buildExtensionsTab() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filtered = _extensionList.where((ext) {
      final name = (ext['name'] as String).toLowerCase();
      final matchesSearch = _extensionSearchQuery.isEmpty || name.contains(_extensionSearchQuery.toLowerCase());
      if (!matchesSearch) return false;

      final lang = (ext['lang'] as String? ?? 'en').toLowerCase();
      final isEnglish = lang == 'en' || lang == 'all' || lang.isEmpty;
      if (!isEnglish) return false;

      final isJs = ext['isJs'] as bool? ?? false;
      final isInstalled = ext['isInstalled'] as bool? ?? false;

      if (_selectedExtensionFilter == 'Local JS' && !isJs) return false;
      if (_selectedExtensionFilter == 'Server APK' && isJs) return false;
      if (_selectedExtensionFilter == 'Installed' && !isInstalled) return false;

      return true;
    }).toList();

    final sortedList = List<Map<String, dynamic>>.from(filtered);
    sortedList.sort((a, b) {
      final aInstalled = a['isInstalled'] as bool;
      final bInstalled = b['isInstalled'] as bool;
      if (aInstalled && !bInstalled) return -1;
      if (!aInstalled && bInstalled) return 1;
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search extensions...',
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onChanged: (val) => setState(() => _extensionSearchQuery = val),
          ),
        ),
        // ── USER CONFIGURED REPOSITORIES ROW ──
        Builder(
          builder: (context) {
            final customRepos = SettingsService.instance.customRepos;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ...customRepos.map((repoUrl) {
                    final isSelected = _selectedRepoUrl == repoUrl;
                    final repoTitle = RepoManager.deriveRepoTitle(repoUrl);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(repoTitle),
                        selected: isSelected,
                        selectedColor: primaryColor,
                        backgroundColor: const Color(0x1F2A2A32),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (_) {
                          setState(() => _selectedRepoUrl = repoUrl);
                          _fetchExtensions();
                        },
                      ),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Repo'),
                    backgroundColor: const Color(0x1F2A2A32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _showAddRepoDialog(),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // ── EXTENSION TYPE FILTER SUB-ROW ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedExtensionFilter == 'All',
                selectedColor: primaryColor.withAlpha(80),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'All'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('⚡ Local JS (iOS & Android)'),
                selected: _selectedExtensionFilter == 'Local JS',
                selectedColor: Colors.teal.withAlpha(80),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Local JS'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('☁ Server APK (Suwayomi)'),
                selected: _selectedExtensionFilter == 'Server APK',
                selectedColor: Colors.blue.withAlpha(80),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Server APK'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Installed'),
                selected: _selectedExtensionFilter == 'Installed',
                selectedColor: Colors.purple.withAlpha(80),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Installed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _isLoadingExtensions
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : sortedList.isEmpty
                  ? const Center(child: Text('No extensions found.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 120.0),
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) {
                        final ext = sortedList[index];
                        final name = ext['name'] as String;
                        final lang = ext['lang'] as String;
                        final version = ext['version'] as String;
                        final isJs = ext['isJs'] as bool;
                        final isInstalled = ext['isInstalled'] as bool;
                        final iconUrl = ext['iconUrl'] as String? ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Material(
                            color: const Color(0x1F2A2A32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(38),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: iconUrl.isNotEmpty
                                      ? Image.network(
                                          iconUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Center(
                                            child: Text(
                                              lang.substring(0, lang.length.clamp(0, 2)).toUpperCase(),
                                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            lang.substring(0, lang.length.clamp(0, 2)).toUpperCase(),
                                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'v$version • ${isJs ? "⚡ Local JS (Cross-Platform)" : "☁ Server APK (Suwayomi Proxy)"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isJs ? Colors.tealAccent : Colors.lightBlueAccent,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isInstalled) ...[
                                    IconButton(
                                      icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
                                      onPressed: () => _showExtensionSettingsDialog(ext),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0x33FF3D00),
                                        side: const BorderSide(color: Colors.redAccent, width: 0.8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _toggleExtensionInstallation(ext),
                                      child: const Text('Uninstall', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ] else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _toggleExtensionInstallation(ext),
                                      child: const Text('Install', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════
  // ── 3. MIGRATE TAB (MATCHES SUWAYOMI SERVER EXACTLY) ─────
  // ═════════════════════════════════════════════════════════
  Widget _buildMigrateTab() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoadingLibrary) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    // 1. Group library manga strictly by source
    final Map<String, List<Manga>> sourceToMangas = {};
    for (final manga in _libraryMangaList) {
      final key = manga.sourceName.isNotEmpty ? manga.sourceName : 'Unknown Source';
      sourceToMangas.putIfAbsent(key, () => []).add(manga);
    }

    // 2. Build migration source items
    final List<Map<String, dynamic>> migrationItems = [];

    sourceToMangas.forEach((sourceName, mangas) {
      if (mangas.isEmpty) return;

      // Find matching server source metadata
      Map<String, dynamic>? matched;
      for (final s in _sourcesList) {
        final sName = (s['name'] as String).toLowerCase();
        final sDisp = (s['displayName'] as String? ?? '').toLowerCase();
        final qName = sourceName.toLowerCase();
        if (sName == qName || sDisp == qName || s['id'] == sourceName) {
          matched = s;
          break;
        }
      }

      matched ??= {
        'id': sourceName,
        'name': sourceName,
        'displayName': sourceName,
        'lang': 'en',
        'iconUrl': '',
      };

      final iconUrl = (matched['iconUrl'] as String? ?? '');

      migrationItems.add({
        'id': matched['id'] ?? sourceName,
        'name': sourceName,
        'lang': (matched['lang'] as String? ?? 'en').toLowerCase() == 'en' ? 'English' : (matched['lang'] as String? ?? 'en').toUpperCase(),
        'iconUrl': iconUrl,
        'count': mangas.length,
        'mangas': mangas,
      });
    });

    // 3. Sort migration items
    if (_migrateSortByCount) {
      migrationItems.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    } else {
      migrationItems.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${migrationItems.length} SOURCES WITH LIBRARY TITLES',
              style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: _migrateSortByCount ? 'Sort by count' : 'Sort alphabetical',
                  icon: Icon(_migrateSortByCount ? Icons.sort_rounded : Icons.sort_by_alpha_rounded, color: primaryColor, size: 20),
                  onPressed: () => setState(() => _migrateSortByCount = !_migrateSortByCount),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (migrationItems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'No sources with library manga found.\nPull down to sync your library.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Column(
            children: migrationItems.map((item) {
              final name = item['name'] as String;
              final lang = item['lang'] as String;
              final count = item['count'] as int;
              final iconUrl = item['iconUrl'] as String;
              final mangas = item['mangas'] as List<Manga>;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Material(
                  color: const Color(0x1F2A2A32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: iconUrl.isNotEmpty
                            ? Image.network(
                                iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.swap_horizontal_circle_outlined, color: primaryColor, size: 22),
                              )
                            : Icon(Icons.swap_horizontal_circle_outlined, color: primaryColor, size: 22),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text(lang, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                    ),
                    onTap: () => _showMigrationMangaSelectionDialog(name, mangas),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showMigrationMangaSelectionDialog(String sourceName, List<Manga> mangas) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedMangaIds = <int>{};

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final allSelected = selectedMangaIds.length == mangas.length;

            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Migrate from $sourceName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        if (allSelected) {
                          selectedMangaIds.clear();
                        } else {
                          selectedMangaIds.addAll(mangas.map((m) => m.serverId));
                        }
                      });
                    },
                    child: Text(allSelected ? 'Deselect All' : 'Select All', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 380,
                child: ListView.builder(
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final manga = mangas[index];
                    final isSelected = selectedMangaIds.contains(manga.serverId);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selectedMangaIds.add(manga.serverId);
                          } else {
                            selectedMangaIds.remove(manga.serverId);
                          }
                        });
                      },
                      secondary: manga.thumbnailUrl != null && manga.thumbnailUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(manga.thumbnailUrl!, width: 40, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.book_rounded, color: primaryColor)),
                            )
                          : Icon(Icons.book_rounded, color: primaryColor),
                      title: Text(manga.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(manga.author ?? 'Unknown Author', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                if (selectedMangaIds.isNotEmpty)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      final selectedList = mangas.where((m) => selectedMangaIds.contains(m.serverId)).toList();
                      for (final manga in selectedList) {
                        if (!mounted) break;
                        final migrated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MigrateSearchScreen(manga: manga, sources: _sourcesList),
                          ),
                        );
                        if (migrated != true) break;
                      }
                      await _loadLibraryForMigration();
                    },
                    child: Text('Migrate Selected (${selectedMangaIds.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            );
          },
        );
      },
    );
  }




}
