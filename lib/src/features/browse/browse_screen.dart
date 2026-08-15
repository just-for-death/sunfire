import 'package:flutter/material.dart';

import '../../core/db/isar_service.dart';
import '../../core/db/models/manga.dart';
import '../../core/engine/repo_manager.dart';
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
  String _selectedRepoUrl = RepoManager.defaultRepos[0]['url']!;

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
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchSources();
        if (data != null && data.containsKey('sources')) {
          final nodes = data['sources']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            _sourcesList = nodes.map((n) {
              final m = n as Map<String, dynamic>;
              final id = m['id'].toString();
              final name = m['name'] as String? ?? 'Source';
              final displayName = m['displayName'] as String? ?? name;
              final rawIcon = m['iconUrl'] as String?;
              final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                  ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                  : '$serverUrl/api/v1/source/$id/icon';

              return {
                'id': id,
                'name': name,
                'displayName': displayName,
                'lang': m['lang'] as String? ?? 'en',
                'supportsLatest': m['supportsLatest'] as bool? ?? true,
                'isPinned': SettingsService.instance.isSourcePinned(id),
                'iconUrl': iconUrl,
              };
            }).toList();
          }
        }
      }

      if (_sourcesList.isEmpty) {
        _sourcesList = [
          {'id': '0', 'name': 'Local source', 'displayName': 'Local source', 'lang': 'en', 'supportsLatest': false, 'isPinned': SettingsService.instance.isSourcePinned('0'), 'iconUrl': ''},
          {'id': '7185601298150078890', 'name': 'ReadAllComics', 'displayName': 'ReadAllComics', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('7185601298150078890'), 'iconUrl': ''},
          {'id': '2499283573021220255', 'name': 'MangaDex', 'displayName': 'MangaDex', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('2499283573021220255'), 'iconUrl': ''},
          {'id': '6084907896154116083', 'name': 'MangaFire', 'displayName': 'MangaFire', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('6084907896154116083'), 'iconUrl': ''},
          {'id': '4972933717624256217', 'name': 'Comick', 'displayName': 'Comick', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('4972933717624256217'), 'iconUrl': ''},
          {'id': '3444662672352788181', 'name': 'MANGA Plus by SHUEISHA', 'displayName': 'MANGA Plus by SHUEISHA', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('3444662672352788181'), 'iconUrl': ''},
          {'id': '5192837192837129381', 'name': 'Mangafreak', 'displayName': 'Mangafreak', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('5192837192837129381'), 'iconUrl': ''},
          {'id': '9182736451928371625', 'name': 'Buon Dua', 'displayName': 'Buon Dua', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('9182736451928371625'), 'iconUrl': ''},
          {'id': '1928374651029384756', 'name': 'Webtoons.com', 'displayName': 'Webtoons.com', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('1928374651029384756'), 'iconUrl': ''},
          {'id': '1928374651029384757', 'name': 'Weeb Central', 'displayName': 'Weeb Central', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('1928374651029384757'), 'iconUrl': ''},
          {'id': '1928374651029384758', 'name': 'Mangakakalot', 'displayName': 'Mangakakalot', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('1928374651029384758'), 'iconUrl': ''},
          {'id': '1928374651029384759', 'name': 'NineAnime', 'displayName': 'NineAnime', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('1928374651029384759'), 'iconUrl': ''},
          {'id': '1928374651029384760', 'name': 'MangaKatana', 'displayName': 'MangaKatana', 'lang': 'en', 'supportsLatest': true, 'isPinned': SettingsService.instance.isSourcePinned('1928374651029384760'), 'iconUrl': ''},
        ];
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch server sources: $e', exception: e, stackTrace: stack, category: 'Browse');
    } finally {
      setState(() => _isLoadingSources = false);
    }
  }

  Future<void> _fetchExtensions() async {
    setState(() => _isLoadingExtensions = true);
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';
    try {
      final items = <Map<String, dynamic>>[];

      // 1. Fetch server-side Keiyoushi APK extensions via GraphQL
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance.fetchExtensions();
        if (data != null && data.containsKey('extensions')) {
          final nodes = data['extensions']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final map = n as Map<String, dynamic>;
              final rawIcon = map['iconUrl'] as String?;
              final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                  ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                  : '';

              items.add({
                'id': (map['pkgName'] ?? map['name']).toString(),
                'name': map['name'] as String? ?? 'Extension',
                'lang': map['lang'] as String? ?? 'en',
                'version': (map['versionName'] ?? map['version'] ?? '1.0.0').toString(),
                'isInstalled': map['isInstalled'] as bool? ?? false,
                'iconUrl': iconUrl,
                'isJs': false,
              });
            }
          }
        }
      }

      // 2. Fetch local JS repo extensions
      final jsList = await RepoManager.instance.fetchRepoSources(_selectedRepoUrl);
      for (final js in jsList) {
        items.add({
          'id': '${js.name}_${js.lang}',
          'name': js.name,
          'lang': js.lang,
          'version': js.version,
          'isInstalled': js.name == '1st Kiss-Manga (unoriginal)' && js.lang == 'en',
          'iconUrl': '',
          'isJs': true,
        });
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

    setState(() {
      ext['isInstalled'] = !isInstalled;
    });

    try {
      if (GraphQLClientService.instance.isConfigured && !ext['isJs']) {
        await GraphQLClientService.instance.updateExtension(id, isInstalled ? 'UNINSTALL' : 'INSTALL');
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isInstalled ? 'Uninstalled $name' : 'Installed $name')),
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
      final matchesSearch = _sourceSearchQuery.isEmpty || name.contains(_sourceSearchQuery.toLowerCase());
      final matchesLang = _selectedLangFilter.toUpperCase() == 'ALL' || lang == _selectedLangFilter.toUpperCase();
      return matchesSearch && matchesLang;
    }).toList();

    final pinned = filtered.where((s) => s['isPinned'] == true).toList();
    final unpinned = filtered.where((s) => s['isPinned'] != true).toList();

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

          Text('INSTALLED SOURCES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          if (unpinned.isEmpty)
            const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text('No sources found.', style: TextStyle(color: Colors.grey))))
          else
            ...unpinned.map((s) => _buildSourceItemTile(s)),
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
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(4)),
                      child: Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
  // ── 2. EXTENSIONS TAB ────────────────────────────────────
  // ═════════════════════════════════════════════════════════
  Widget _buildExtensionsTab() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final filtered = _extensionSearchQuery.isEmpty
        ? _extensionList
        : _extensionList.where((e) => (e['name'] as String).toLowerCase().contains(_extensionSearchQuery.toLowerCase())).toList();

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: RepoManager.defaultRepos.map((repo) {
              final isSelected = _selectedRepoUrl == repo['url'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(repo['name']!),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: const Color(0x1F2A2A32),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) {
                    setState(() => _selectedRepoUrl = repo['url']!);
                    _fetchExtensions();
                  },
                ),
              );
            }).toList(),
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
                              subtitle: Text('v$version • ${isJs ? ".js Extension" : "Keiyoushi APK"}'),
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
