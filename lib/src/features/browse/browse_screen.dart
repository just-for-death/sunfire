import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class _BrowseScreenState extends State<BrowseScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;

  // ── SOURCES STATE ────────────────────────────────────────
  List<Map<String, dynamic>> _sourcesList = [];
  bool _isLoadingSources = true;
  String _sourceSearchQuery = '';
  String _selectedLangFilter = 'ALL';

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
    SettingsService.instance.addListener(_onSettingsChanged);
    _fetchServerSources();
    _fetchExtensions();
    _loadLibraryForMigration();
  }

  void _onSettingsChanged() {
    if (mounted) {
      _fetchServerSources();
      _fetchExtensions();
    }
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    _tabController.dispose();
    super.dispose();
  }

  String _selectedSourceFilter = 'All'; // 'All', 'Local JS', 'Server', 'Pinned'

  Future<void> _fetchServerSources() async {
    final currentServerUrl = SettingsService.instance.serverUrl;
    if (currentServerUrl.isNotEmpty) {
      if (!GraphQLClientService.instance.isConfigured || GraphQLClientService.instance.baseUrl != currentServerUrl) {
        GraphQLClientService.instance.initialize(currentServerUrl);
      }
    }
    final serverUrl = GraphQLClientService.instance.baseUrl ?? currentServerUrl;

    // ── STEP 1: Always load installed local JS extensions FIRST (fully offline & instant) ──
    final installedNames = QuickJsService.instance.getInstalledExtensionNames();
    final List<Map<String, dynamic>> localJsSources = [];
    for (final name in installedNames) {
      final localId = 'local_js_${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}';
      localJsSources.add({
        'id': localId,
        'name': name,
        'displayName': name,
        'lang': 'EN',
        'supportsLatest': true,
        'isPinned': SettingsService.instance.isSourcePinned(localId),
        'iconUrl': QuickJsService.instance.getSourceIconUrl(name),
        'isLocalJs': true,
        'isServerFallback': false,
      });
    }

    // Immediately show local JS sources on Frame 1
    if (mounted && localJsSources.isNotEmpty) {
      setState(() {
        _sourcesList = localJsSources;
        _isLoadingSources = false;
      });
    }

    // ── STEP 2: Fetch server sources via GraphQL ──
    final List<Map<String, dynamic>> serverSources = [];
    try {
      if (GraphQLClientService.instance.isConfigured) {
        final data = await GraphQLClientService.instance
            .fetchSources()
            .timeout(const Duration(seconds: 6), onTimeout: () => null);

        if (data != null && data.containsKey('sources')) {
          final nodes = data['sources']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final m = n as Map<String, dynamic>;
              final id = m['id'].toString();
              final name = m['displayName'] as String? ?? m['name'] as String? ?? 'Source';
              final rawIcon = m['iconUrl'] as String?;
              final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                  ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                  : '$serverUrl/api/v1/source/$id/icon';
              final lang = (m['lang'] as String? ?? 'en').trim().toUpperCase();
              final supportsLatest = m['supportsLatest'] as bool? ?? true;
              serverSources.add({
                'id': id,
                'name': name,
                'displayName': '$name ☁',
                'lang': lang,
                'supportsLatest': supportsLatest,
                'isPinned': SettingsService.instance.isSourcePinned(id),
                'iconUrl': iconUrl,
                'isLocalJs': false,
                'isServerFallback': false,
              });
            }
            await LoggerService.instance.logInfo('Fetched ${nodes.length} server sources from $serverUrl', 'Browse');
          }
        }
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Failed to fetch server sources: $e', 'Browse');
    }

    final merged = <Map<String, dynamic>>[...localJsSources, ...serverSources];

    if (mounted) {
      setState(() {
        _sourcesList = merged;
        _isLoadingSources = false;
      });
    }
  }

  Future<void> _fetchExtensions() async {
    setState(() => _isLoadingExtensions = true);
    final currentServerUrl = SettingsService.instance.serverUrl;
    if (currentServerUrl.isNotEmpty) {
      if (!GraphQLClientService.instance.isConfigured || GraphQLClientService.instance.baseUrl != currentServerUrl) {
        GraphQLClientService.instance.initialize(currentServerUrl);
      }
    }
    final serverUrl = GraphQLClientService.instance.baseUrl ?? currentServerUrl;
    final customRepos = SettingsService.instance.customRepos;

    try {
      final items = <Map<String, dynamic>>[];
      final seenKeys = <String>{};

      // 1. Fetch server-side Keiyoushi APK extensions via GraphQL
      try {
        if (GraphQLClientService.instance.isConfigured) {
          final data = await GraphQLClientService.instance
              .fetchExtensions()
              .timeout(const Duration(seconds: 6), onTimeout: () => null);

          if (data != null && data.containsKey('extensions')) {
            final nodes = data['extensions']['nodes'] as List<dynamic>?;
            if (nodes != null) {
              for (final n in nodes) {
                final map = n as Map<String, dynamic>;
                final name = map['name'] as String? ?? 'Extension';
                final lang = (map['lang'] as String? ?? 'en').toLowerCase();
                final pkgName = (map['pkgName'] ?? map['name']).toString();
                final key = 'apk_$pkgName'.toLowerCase();
                if (!seenKeys.add(key)) continue;

                final rawIcon = map['iconUrl'] as String?;
                final iconUrl = (rawIcon != null && rawIcon.isNotEmpty)
                    ? (rawIcon.startsWith('http') ? rawIcon : '$serverUrl$rawIcon')
                    : '';

                items.add({
                  'id': pkgName,
                  'pkgName': pkgName,
                  'name': lang == 'en' || lang.isEmpty ? name : '$name (${lang.toUpperCase()})',
                  'lang': lang,
                  'version': (map['versionName'] ?? map['version'] ?? '1.0.0').toString(),
                  'isInstalled': map['isInstalled'] as bool? ?? false,
                  'hasUpdate': map['hasUpdate'] as bool? ?? false,
                  'iconUrl': iconUrl,
                  'isJs': false,
                });
              }
              await LoggerService.instance.logInfo('Fetched ${nodes.length} server extensions from $serverUrl', 'Browse');
            }
          }
        }
      } catch (e) {
        await LoggerService.instance.logWarning('Server extension fetch failed: $e', 'Browse');
      }

      // 2. Fetch local JS repo extensions from all or selected repositories
      final List<RepoSourceItem> jsList;
      if (_selectedRepoUrl.isEmpty || _selectedRepoUrl == 'ALL') {
        jsList = await RepoManager.instance.fetchCombinedRepoSources(customRepos);
      } else {
        jsList = await RepoManager.instance.fetchRepoSources(_selectedRepoUrl);
      }

      for (final js in jsList) {
        final key = 'js_${js.name}_${js.lang}'.toLowerCase();
        if (!seenKeys.add(key)) continue;

        final jsLang = js.lang.toLowerCase();
        final isEn = jsLang == 'en' || jsLang == 'all';
        final isInstalled = isEn && QuickJsService.instance.isLocalExtensionInstalled(js.name);
        final installedVer = isInstalled ? QuickJsService.instance.getInstalledVersion(js.name) : '';
        final hasUpdate = isInstalled && installedVer.isNotEmpty && RepoManager.compareVersions(js.version, installedVer) > 0;

        var iconUrl = js.iconUrl;
        if (iconUrl.isEmpty) {
          iconUrl = QuickJsService.instance.getSourceIconUrl(js.name);
        }

        items.add({
          'id': '${js.name}_${js.lang}',
          'name': js.lang.toLowerCase() == 'en' || js.lang.isEmpty ? js.name : '${js.name} (${js.lang.toUpperCase()})',
          'lang': js.lang,
          'version': js.version,
          'installedVersion': installedVer,
          'hasUpdate': hasUpdate,
          'isInstalled': isInstalled,
          'sourceCodeUrl': js.sourceCodeUrl,
          'iconUrl': iconUrl,
          'isJs': true,
        });
      }

      // 3. Append any locally installed extensions not present in the repo lists
      for (final installedName in QuickJsService.instance.getInstalledExtensionNames()) {
        final key = 'js_${installedName}_en'.toLowerCase();
        if (!seenKeys.add(key)) continue;

        final installedVer = QuickJsService.instance.getInstalledVersion(installedName);
        final iconUrl = QuickJsService.instance.getSourceIconUrl(installedName);

        items.add({
          'id': '${installedName}_en',
          'name': installedName,
          'lang': 'en',
          'version': installedVer.isNotEmpty ? installedVer : '1.0.0',
          'installedVersion': installedVer,
          'hasUpdate': false,
          'isInstalled': true,
          'sourceCodeUrl': '',
          'iconUrl': iconUrl,
          'isJs': true,
        });
      }

      if (mounted) {
        setState(() {
          _extensionList = items;
          _isLoadingExtensions = false;
        });
      }
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch extensions: $e', exception: e, stackTrace: stack, category: 'Browse');
      if (mounted) setState(() => _isLoadingExtensions = false);
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

  void _toggleExtensionInstallation(Map<String, dynamic> ext, {bool isUpdate = false}) async {
    final name = ext['name'] as String;
    final isInstalled = ext['isInstalled'] as bool;
    final isJs = ext['isJs'] as bool? ?? false;
    final sourceCodeUrl = ext['sourceCodeUrl'] as String? ?? '';
    final version = ext['version'] as String? ?? '1.0.0';
    String? customStatusMessage;

    if (!isUpdate) {
      setState(() {
        ext['isInstalled'] = !isInstalled;
      });
    }

    try {
      if (isJs) {
        if ((!isInstalled || isUpdate) && sourceCodeUrl.isNotEmpty) {
          final code = await RepoManager.instance.downloadJsSourceCode(sourceCodeUrl);
          if (code != null) {
            final iconUrl = ext['iconUrl'] as String? ?? '';
            await QuickJsService.instance.saveLocalExtension(
              name,
              code,
              version: version,
              iconUrl: iconUrl,
            );
            setState(() {
              ext['isInstalled'] = true;
              ext['hasUpdate'] = false;
              ext['installedVersion'] = version;
            });

            // Check if available on server and trigger dual install
            final serverExtensionNames = _extensionList
                .where((e) => e['isJs'] == false)
                .map((e) => e['name'] as String)
                .toList();

            final dualResult = SourceMigrationService.instance.checkAndInstallSourceDualChannel(
              jsExtensionName: name,
              serverAvailableSourceNames: serverExtensionNames,
            );

            customStatusMessage = isUpdate ? 'Updated $name to v$version' : dualResult.statusMessage;

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
        } else if (isInstalled && !isUpdate) {
          await QuickJsService.instance.deleteLocalExtension(name);
          setState(() {
            ext['isInstalled'] = false;
            ext['hasUpdate'] = false;
          });
          customStatusMessage = 'Uninstalled $name';
        }
      } else if (GraphQLClientService.instance.isConfigured) {
        final pkgName = (ext['pkgName'] ?? ext['id']).toString();
        if (isUpdate) {
          await GraphQLClientService.instance.updateServerExtension(pkgName);
          setState(() {
            ext['hasUpdate'] = false;
          });
          customStatusMessage = 'Updated $name on server';
        } else if (isInstalled) {
          await GraphQLClientService.instance.uninstallServerExtension(pkgName);
          setState(() {
            ext['isInstalled'] = false;
            ext['hasUpdate'] = false;
          });
          customStatusMessage = 'Uninstalled $name from server';
        } else {
          await GraphQLClientService.instance.installServerExtension(pkgName);
          setState(() {
            ext['isInstalled'] = true;
            ext['hasUpdate'] = false;
          });
          customStatusMessage = 'Installed $name on server';
        }
      }
    } catch (_) {}

    await _fetchServerSources();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customStatusMessage ??
                (isUpdate
                    ? 'Updated $name to v$version'
                    : (isInstalled ? 'Uninstalled $name' : 'Installed $name')),
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
    super.build(context);
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSourcesTab(),
              _buildExtensionsTab(),
              _buildMigrateTab(),
            ],
          ),
        ),
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
      final isEnglish = lang == 'EN' || lang.startsWith('EN') || lang == 'ALL' || lang == 'MULTI' || lang == 'UNIVERSAL' || lang.isEmpty;

      final matchesSearch = _sourceSearchQuery.isEmpty || name.contains(_sourceSearchQuery.toLowerCase());
      final matchesLang = _selectedLangFilter.toUpperCase() == 'ALL'
          ? true
          : (_selectedLangFilter.toUpperCase() == 'EN' ? isEnglish : lang.contains(_selectedLangFilter.toUpperCase()));
      if (!matchesSearch || !matchesLang) return false;

      final isLocal = s['isLocalJs'] as bool? ?? false;
      final isPinned = s['isPinned'] as bool? ?? false;

      if (_selectedSourceFilter == 'Local JS' && !isLocal) return false;
      if (_selectedSourceFilter == 'Server' && isLocal) return false;
      if (_selectedSourceFilter == 'Pinned' && !isPinned) return false;

      return true;
    }).toList();

    final pinned = filtered.where((s) => s['isPinned'] == true).toList();
    final unpinned = filtered.where((s) => s['isPinned'] != true).toList();
    final localJsUnpinned = unpinned.where((s) => s['isLocalJs'] == true).toList();
    final serverUnpinned = unpinned.where((s) => s['isLocalJs'] != true).toList();

    final isTablet = MediaQuery.of(context).size.width >= 720;
    final bottomPadding = isTablet ? 36.0 : 120.0;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _fetchServerSources,
      child: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 12.0, bottom: bottomPadding),
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

          const SizedBox(height: 10),

          // ── SOURCE TYPE FILTER ROW ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedSourceFilter == 'All',
                  selectedColor: primaryColor,
                  backgroundColor: const Color(0x1F2A2A32),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  labelStyle: TextStyle(
                    color: _selectedSourceFilter == 'All' ? Colors.white : Colors.grey[400],
                    fontWeight: _selectedSourceFilter == 'All' ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedSourceFilter == 'All' ? primaryColor : const Color(0x2BFFFFFF),
                      width: _selectedSourceFilter == 'All' ? 1.2 : 0.8,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedSourceFilter = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.flash_on_rounded, size: 15, color: Colors.tealAccent),
                  label: const Text('Local JS'),
                  selected: _selectedSourceFilter == 'Local JS',
                  selectedColor: Colors.teal.shade800,
                  backgroundColor: const Color(0x1F2A2A32),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  labelStyle: TextStyle(
                    color: _selectedSourceFilter == 'Local JS' ? Colors.tealAccent : Colors.grey[400],
                    fontWeight: _selectedSourceFilter == 'Local JS' ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedSourceFilter == 'Local JS' ? Colors.tealAccent : const Color(0x2BFFFFFF),
                      width: _selectedSourceFilter == 'Local JS' ? 1.2 : 0.8,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedSourceFilter = 'Local JS'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.cloud_queue_rounded, size: 15, color: Colors.lightBlueAccent),
                  label: const Text('Server (Suwayomi)'),
                  selected: _selectedSourceFilter == 'Server',
                  selectedColor: Colors.blue.shade800,
                  backgroundColor: const Color(0x1F2A2A32),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  labelStyle: TextStyle(
                    color: _selectedSourceFilter == 'Server' ? Colors.lightBlueAccent : Colors.grey[400],
                    fontWeight: _selectedSourceFilter == 'Server' ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedSourceFilter == 'Server' ? Colors.lightBlueAccent : const Color(0x2BFFFFFF),
                      width: _selectedSourceFilter == 'Server' ? 1.2 : 0.8,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedSourceFilter = 'Server'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.push_pin_rounded, size: 15, color: Colors.amberAccent),
                  label: const Text('Pinned'),
                  selected: _selectedSourceFilter == 'Pinned',
                  selectedColor: Colors.amber.shade900,
                  backgroundColor: const Color(0x1F2A2A32),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  labelStyle: TextStyle(
                    color: _selectedSourceFilter == 'Pinned' ? Colors.amberAccent : Colors.grey[400],
                    fontWeight: _selectedSourceFilter == 'Pinned' ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedSourceFilter == 'Pinned' ? Colors.amberAccent : const Color(0x2BFFFFFF),
                      width: _selectedSourceFilter == 'Pinned' ? 1.2 : 0.8,
                    ),
                  ),
                  onSelected: (_) => setState(() => _selectedSourceFilter = 'Pinned'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (pinned.isNotEmpty) ...[
            Text('PINNED SOURCES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...pinned.map((s) => _buildSourceItemTile(s)),
            const Divider(height: 24, color: Color(0x1AFFFFFF)),
          ],

          if (localJsUnpinned.isNotEmpty && _selectedSourceFilter != 'Server') ...[
            const Text(
              'LOCAL EXTENSIONS (ON-DEVICE)',
              style: TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            ...localJsUnpinned.map((s) => _buildSourceItemTile(s)),
            const SizedBox(height: 16),
          ],

          if (serverUnpinned.isNotEmpty && _selectedSourceFilter != 'Local JS') ...[
            const Text(
              'SERVER SOURCES (SUWAYOMI)',
              style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            ...serverUnpinned.map((s) => _buildSourceItemTile(s)),
          ],

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedSourceFilter == 'Server' ? Icons.cloud_off_rounded : Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey.withAlpha(120),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedSourceFilter == 'Server'
                          ? 'No server sources found'
                          : 'No sources found',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedSourceFilter == 'Server'
                          ? 'Make sure your Suwayomi server is connected in Settings and has extensions installed.'
                          : 'Try changing your search query or language filter.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor.withAlpha(100)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _fetchServerSources();
                        _fetchExtensions();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh Sources'),
                    ),
                  ],
                ),
              ),
            ),
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

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Material(
          color: const Color(0x1F2A2A32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openSourceGrid(id, name, false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      color: isPinned ? primaryColor : Colors.grey,
                      size: 18,
                    ),
                    onPressed: () => _toggleSourcePin(id),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
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
                              cacheWidth: 100,
                              cacheHeight: 100,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            )
                        : Center(
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0x22FFFFFF), borderRadius: BorderRadius.circular(6)),
                            child: Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocalJs ? Colors.teal.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLocalJs ? 'Local' : 'Server',
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
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (supportsLatest)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openSourceGrid(id, name, true),
                        child: const Text('Latest', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openSourceGrid(id, name, false),
                      child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Future<void> _installAllJsExtensions() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Installing all repository extensions locally...')),
    );
    final count = await RepoManager.instance.downloadAndInstallAllRepoExtensions(
      userRepoUrls: SettingsService.instance.customRepos,
    );
    await _fetchServerSources();
    await _fetchExtensions();
    if (mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text('Successfully installed/updated $count extensions locally')),
      );
    }
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
      final isEnglish = lang == 'en' || lang.startsWith('en') || lang == 'all' || lang == 'multi' || lang == 'universal' || lang.isEmpty;
      if (_selectedExtensionFilter != 'Server APK' && _extensionSearchQuery.isEmpty && !isEnglish) return false;

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

    final isTablet = MediaQuery.of(context).size.width >= 720;
    final bottomPadding = isTablet ? 36.0 : 120.0;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: const Text('All Repositories'),
                      selected: _selectedRepoUrl.isEmpty || _selectedRepoUrl == 'ALL',
                      selectedColor: primaryColor,
                      backgroundColor: const Color(0x1F2A2A32),
                      labelStyle: TextStyle(
                        color: (_selectedRepoUrl.isEmpty || _selectedRepoUrl == 'ALL') ? Colors.white : Colors.grey,
                        fontWeight: (_selectedRepoUrl.isEmpty || _selectedRepoUrl == 'ALL') ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) {
                        setState(() => _selectedRepoUrl = 'ALL');
                        _fetchExtensions();
                      },
                    ),
                  ),
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
                selectedColor: primaryColor.withValues(alpha: 0.25),
                backgroundColor: const Color(0x1F2A2A32),
                labelStyle: TextStyle(
                  color: _selectedExtensionFilter == 'All' ? primaryColor : Colors.white70,
                  fontWeight: _selectedExtensionFilter == 'All' ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _selectedExtensionFilter == 'All' ? primaryColor : const Color(0x2BFFFFFF),
                    width: 0.8,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'All'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Local JS'),
                selected: _selectedExtensionFilter == 'Local JS',
                selectedColor: Colors.teal.withValues(alpha: 0.25),
                backgroundColor: const Color(0x1F2A2A32),
                labelStyle: TextStyle(
                  color: _selectedExtensionFilter == 'Local JS' ? Colors.tealAccent : Colors.white70,
                  fontWeight: _selectedExtensionFilter == 'Local JS' ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _selectedExtensionFilter == 'Local JS' ? Colors.teal : const Color(0x2BFFFFFF),
                    width: 0.8,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Local JS'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Server APK'),
                selected: _selectedExtensionFilter == 'Server APK',
                selectedColor: Colors.blue.withValues(alpha: 0.25),
                backgroundColor: const Color(0x1F2A2A32),
                labelStyle: TextStyle(
                  color: _selectedExtensionFilter == 'Server APK' ? Colors.lightBlueAccent : Colors.white70,
                  fontWeight: _selectedExtensionFilter == 'Server APK' ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _selectedExtensionFilter == 'Server APK' ? Colors.blue : const Color(0x2BFFFFFF),
                    width: 0.8,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Server APK'),
              ),
              const SizedBox(width: 6),
              FilterChip(
                label: const Text('Installed'),
                selected: _selectedExtensionFilter == 'Installed',
                selectedColor: primaryColor.withValues(alpha: 0.25),
                backgroundColor: const Color(0x1F2A2A32),
                labelStyle: TextStyle(
                  color: _selectedExtensionFilter == 'Installed' ? primaryColor : Colors.white70,
                  fontWeight: _selectedExtensionFilter == 'Installed' ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _selectedExtensionFilter == 'Installed' ? primaryColor : const Color(0x2BFFFFFF),
                    width: 0.8,
                  ),
                ),
                onSelected: (_) => setState(() => _selectedExtensionFilter = 'Installed'),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.download_done_rounded, size: 16, color: Colors.tealAccent),
                label: const Text('Install All', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                backgroundColor: Colors.teal.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.teal, width: 0.8)),
                onPressed: _installAllJsExtensions,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _isLoadingExtensions
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : sortedList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedExtensionFilter == 'Server APK'
                                  ? Icons.cloud_off_rounded
                                  : Icons.extension_off_rounded,
                              size: 56,
                              color: primaryColor.withAlpha(120),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedExtensionFilter == 'Server APK'
                                  ? 'No Server APKs Found'
                                  : (_selectedExtensionFilter == 'Installed'
                                      ? 'No Extensions Installed'
                                      : 'No Extensions Found'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedExtensionFilter == 'Server APK'
                                  ? 'No Keiyoushi APK extensions found on your Suwayomi server. Switch to Local JS or All to use on-device extensions.'
                                  : (_selectedExtensionFilter == 'Installed'
                                      ? 'You haven\'t installed any extensions yet. Switch to "All" or "Local JS" to install extensions.'
                                      : 'No extensions match your current search and repository filters.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            if (_selectedExtensionFilter != 'All') ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.filter_alt_off_rounded, color: Colors.white),
                                label: const Text('Show All Extensions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                onPressed: () => setState(() => _selectedExtensionFilter = 'All'),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                label: const Text('Add Repository', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                onPressed: () => _showAddRepoDialog(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      scrollCacheExtent: ScrollCacheExtent.pixels(800),
                      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 8.0, bottom: bottomPadding),
                      itemCount: sortedList.length,
                      itemBuilder: (context, index) {
                        final ext = sortedList[index];
                        final name = ext['name'] as String;
                        final lang = ext['lang'] as String;
                        final version = ext['version'] as String;
                        final isJs = ext['isJs'] as bool;
                        final isInstalled = ext['isInstalled'] as bool;
                        final iconUrl = ext['iconUrl'] as String? ?? '';
                        final hasUpdate = ext['hasUpdate'] as bool? ?? false;

                        return RepaintBoundary(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: const Color(0x1F2A2A32),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
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
                                            cacheWidth: 120,
                                            cacheHeight: 120,
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          'v$version',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: isJs ? Colors.teal.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isJs ? 'Local' : 'Server',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isJs ? Colors.tealAccent : Colors.lightBlueAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isInstalled) ...[
                                if (hasUpdate) ...[
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.system_update_alt_rounded, color: Colors.amberAccent, size: 20),
                                    tooltip: 'Update to v$version',
                                    onPressed: () => _toggleExtensionInstallation(ext, isUpdate: true),
                                  ),
                                ],
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 18),
                                  tooltip: 'Settings',
                                  onPressed: () => _showExtensionSettingsDialog(ext),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                  tooltip: 'Uninstall',
                                  onPressed: () => _toggleExtensionInstallation(ext),
                                ),
                              ] else
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => _toggleExtensionInstallation(ext),
                                  child: const Text('Install', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                            ],
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

    // 1. Group library manga by canonical source to prevent case/casing duplicates
    final Map<String, List<Manga>> sourceToMangas = {};
    final Map<String, String> canonicalDisplayNames = {};

    for (final manga in _libraryMangaList) {
      final raw = manga.sourceName.trim();
      final key = raw.isNotEmpty ? raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') : 'unknown';
      final disp = raw.isNotEmpty ? raw : 'Unknown Source';

      if (!canonicalDisplayNames.containsKey(key) || (disp != disp.toLowerCase())) {
        canonicalDisplayNames[key] = disp;
      }
      sourceToMangas.putIfAbsent(key, () => []).add(manga);
    }

    // 2. Build migration source items
    final List<Map<String, dynamic>> migrationItems = [];

    sourceToMangas.forEach((key, mangas) {
      if (mangas.isEmpty) return;
      final sourceName = canonicalDisplayNames[key] ?? key;

      // Find matching server source metadata
      Map<String, dynamic>? matched;
      for (final s in _sourcesList) {
        final sName = (s['name'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final sDisp = (s['displayName'] as String? ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (sName == key || sDisp == key || s['id'] == sourceName) {
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
      migrationItems.sort((a, b) => parseIntSafe(b['count']).compareTo(parseIntSafe(a['count'])));
    } else {
      migrationItems.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    final isTablet = MediaQuery.of(context).size.width >= 720;
    final bottomPadding = isTablet ? 36.0 : 120.0;
    final horizontalPadding = isTablet ? 24.0 : 16.0;

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding, top: 16.0, bottom: bottomPadding),
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
              final count = parseIntSafe(item['count']);
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
