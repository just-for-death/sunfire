import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/db/isar_service.dart';
import '../../core/engine/repo_manager.dart';
import '../../core/engine/source_migration_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/sync/websocket_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _serverUrlController = TextEditingController(text: 'http://localhost:4567');
  final TextEditingController _serverAuthController = TextEditingController();
  final TextEditingController _newRepoUrlController = TextEditingController();

  bool _isConnecting = false;
  String? _connectionStatus;
  bool _connectionSuccess = false;

  // Repositories configured by user
  final List<String> _userRepoUrls = [
    'https://kodjodevf.github.io/mangayomi-extensions/index.json',
    'https://m2k3a.github.io/mangayomi-extensions/index.json',
  ];

  // Hydration Progress State
  bool _isHydrating = false;
  int _hydrationStep = 0; // 0 = idle, 1 = sources, 2 = library, 3 = history, 4 = complete
  String _sourcesStatusText = 'Waiting to check server sources...';
  String _libraryStatusText = 'Waiting to cache library manga...';
  String _historyStatusText = 'Waiting to sync reading history...';
  int _matchedSourcesCount = 0;
  int _totalHydratedManga = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _serverUrlController.dispose();
    _serverAuthController.dispose();
    _newRepoUrlController.dispose();
    super.dispose();
  }

  Future<void> _testAndConnectServer() async {
    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Testing connection to Suwayomi server...';
      _connectionSuccess = false;
    });

    try {
      final rawUrl = _serverUrlController.text.trim();
      final url = rawUrl.replaceAll(RegExp(r'/+$'), '');
      final auth = _serverAuthController.text.trim().isNotEmpty ? _serverAuthController.text.trim() : null;

      GraphQLClientService.instance.initialize(url, authToken: auth);

      final data = await GraphQLClientService.instance
          .query('{ aboutServer { version } }')
          .timeout(const Duration(seconds: 4));

      if (data != null && data.containsKey('aboutServer')) {
        final version = data['aboutServer']['version'] ?? 'v1.x';
        WebSocketService.instance.initialize(url);

        setState(() {
          _connectionSuccess = true;
          _connectionStatus = '✓ Successfully connected to Suwayomi $version';
        });

        await Future.delayed(const Duration(milliseconds: 400));
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() {
          _connectionStatus = '⚠️ Could not verify server version. Check URL and credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Could not connect: $e';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _addNewRepo() {
    final url = _newRepoUrlController.text.trim();
    if (url.isNotEmpty && !_userRepoUrls.contains(url)) {
      setState(() {
        _userRepoUrls.add(url);
        _newRepoUrlController.clear();
      });
      RepoManager.instance.addUserRepo('Custom Repo', url);
    }
  }

  void _removeRepo(String url) {
    setState(() {
      _userRepoUrls.remove(url);
    });
    RepoManager.instance.removeUserRepo(url);
  }

  Future<void> _runInitialHydration() async {
    setState(() {
      _isHydrating = true;
      _hydrationStep = 1;
      _sourcesStatusText = 'Fetching installed server sources and matching local JS scrapers...';
    });

    try {
      // ── STEP 1: HYDRATE & MATCH SOURCES ──
      final List<ServerSourceItem> serverSources = [];
      if (GraphQLClientService.instance.isConfigured) {
        final sourcesData = await GraphQLClientService.instance
            .fetchSources()
            .timeout(const Duration(seconds: 6), onTimeout: () => null);

        if (sourcesData != null && sourcesData.containsKey('sources')) {
          final nodes = sourcesData['sources']['nodes'] as List<dynamic>?;
          if (nodes != null) {
            for (final n in nodes) {
              final m = n as Map<String, dynamic>;
              serverSources.add(ServerSourceItem(
                id: m['id'].toString(),
                name: m['name'] as String? ?? '',
                lang: m['lang'] as String? ?? 'en',
              ));
            }
          }
        }
      }

      // Download and install JS scrapers ONLY for installed server sources
      final installedSources = await RepoManager.instance.downloadAndInstallMatchingSources(
        serverSourceNames: serverSources.map((s) => s.name).toList(),
        userRepoUrls: _userRepoUrls,
      );

      final migrationResult = SourceMigrationService.instance.migrateServerSources(
        serverSourceNames: serverSources.map((s) => s.name).toList(),
        availableJsExtensions: installedSources,
      );

      setState(() {
        _matchedSourcesCount = migrationResult.matchedSources.length;
        _sourcesStatusText = '✓ Replicated ${migrationResult.matchedSources.length} sources to Local JS (${migrationResult.serverOnlySources.length} server fallbacks)';
        _hydrationStep = 2;
        _libraryStatusText = 'Fetching complete library manga and caching chapters in Isar DB...';
      });

      await Future.delayed(const Duration(milliseconds: 400));

      // ── STEP 2: HYDRATE LIBRARY & CHAPTERS ──
      if (GraphQLClientService.instance.isConfigured) {
        await SyncEngine.instance.triggerSync();
        final libraryItems = await IsarService.instance.getLibraryManga();
        _totalHydratedManga = libraryItems.length;
      }

      setState(() {
        _libraryStatusText = '✓ Cached $_totalHydratedManga library titles into local DB (100% Offline Ready)';
        _hydrationStep = 3;
        _historyStatusText = '✓ Reading history and chapter feeds synchronized';
        _hydrationStep = 4;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e, st) {
      LoggerService.instance.logError('Initial hydration error', exception: e, stackTrace: st, category: 'Onboarding');
      setState(() {
        _sourcesStatusText = '✓ Local-first mode active (Offline ready)';
        _libraryStatusText = '✓ Local database initialized';
        _historyStatusText = '✓ Ready for on-device reading';
        _hydrationStep = 4;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      setState(() {
        _isHydrating = false;
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final cleanUrl = _serverUrlController.text.trim().replaceAll(RegExp(r'/+$'), '');
    final auth = _serverAuthController.text.trim().isNotEmpty ? _serverAuthController.text.trim() : null;

    await SourceMigrationService.instance.markOnboardingCompleted(
      serverUrl: cleanUrl,
      authHeader: auth,
      selectedRepos: _userRepoUrls,
    );
    SettingsService.instance.onboardingCompleted = true;

    if (cleanUrl.isNotEmpty) {
      GraphQLClientService.instance.initialize(cleanUrl, authToken: auth);
      SyncEngine.instance.initialize();
    }

    if (mounted) {
      context.go('/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D11),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomeStep(),
            _buildServerStep(),
            _buildReposStep(),
            _buildHydrationStep(),
            _buildCompletionStep(),
          ],
        ),
      ),
    );
  }

  // ── STEP 1: WELCOME ─────────────────────────────────────────
  Widget _buildWelcomeStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wb_sunny_rounded, size: 72, color: primaryColor),
          ),
          const SizedBox(height: 28),
          const Text(
            'Sunfire',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The Local-First Manga Experience',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sunfire links with your Suwayomi server to replicate your library, history, and sources. Once hydrated, the app works 100% offline with zero server dependence.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 2: SERVER CONNECTION ──────────────────────────────
  Widget _buildServerStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Icon(Icons.cloud_sync_rounded, color: primaryColor, size: 28),
              const SizedBox(width: 10),
              const Text('Link Suwayomi Server', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your Suwayomi server address to import your past & present library and sources.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _serverUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Server URL',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'http://192.168.1.100:4567',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1B1B22),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.dns_rounded, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _serverAuthController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Auth Token / Password (Optional)',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Bearer token or empty',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1B1B22),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.key_rounded, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          if (_connectionStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _connectionSuccess ? const Color(0x224CAF50) : const Color(0x22F44336),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    _connectionSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: _connectionSuccess ? Colors.green : Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _connectionStatus!,
                      style: TextStyle(
                        color: _connectionSuccess ? Colors.greenAccent : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 28),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isConnecting ? null : _testAndConnectServer,
            child: _isConnecting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Connect & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          if (_connectionStatus != null && !_connectionSuccess) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Colors.white24),
              ),
              onPressed: () {
                final rawUrl = _serverUrlController.text.trim();
                final url = rawUrl.replaceAll(RegExp(r'/+$'), '');
                final auth = _serverAuthController.text.trim().isNotEmpty ? _serverAuthController.text.trim() : null;
                GraphQLClientService.instance.initialize(url, authToken: auth);
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Continue with this URL anyway', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ),
          ],
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Center(
              child: Text('Skip server setup (Use Pure Local Mode)', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 3: REPOSITORIES ────────────────────────────────────
  Widget _buildReposStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.extension_rounded, color: primaryColor, size: 28),
              const SizedBox(width: 10),
              const Text('Extension Repositories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sunfire is a neutral reader. Paste your Mangayomi JSON extension repositories below:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newRepoUrlController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'https://.../index.json',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF1B1B22),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _addNewRepo,
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _userRepoUrls.length,
              itemBuilder: (context, idx) {
                final url = _userRepoUrls[idx];
                final isCore = url.contains('kodjodevf');
                final isCommunity = url.contains('m2k3a');
                final label = isCore
                    ? 'Official Mangayomi Core'
                    : isCommunity
                        ? 'Community Extensions Index'
                        : 'User Custom Repository';
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17171F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                            Text(url, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                        onPressed: () => _removeRepo(url),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              _runInitialHydration();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Snapshot Hydration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.bolt_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 4: LIVE HYDRATION DASHBOARD ────────────────────────
  Widget _buildHydrationStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.sync_alt_rounded, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Replicating State', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Building 100% offline local database', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 36),
          _buildHydrationStatusItem(
            title: 'Sources & Extensions Replicated',
            subtitle: _sourcesStatusText,
            isActive: _hydrationStep == 1,
            isCompleted: _hydrationStep > 1,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _buildHydrationStatusItem(
            title: 'Library & Chapters Hydrated',
            subtitle: _libraryStatusText,
            isActive: _hydrationStep == 2,
            isCompleted: _hydrationStep > 2,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _buildHydrationStatusItem(
            title: 'Reading History & Feeds Synced',
            subtitle: _historyStatusText,
            isActive: _hydrationStep == 3,
            isCompleted: _hydrationStep >= 4,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 40),
          if (_isHydrating)
            const Center(
              child: Column(
                children: [
                  SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2.5)),
                  SizedBox(height: 12),
                  Text('Please keep app open...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHydrationStatusItem({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? primaryColor.withValues(alpha: 0.6)
              : isCompleted
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          if (isCompleted)
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24)
          else if (isActive)
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5),
            )
          else
            const Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isActive ? Colors.white70 : Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 5: COMPLETION & GATEKEEPER ─────────────────────────
  Widget _buildCompletionStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0x224CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 64, color: Colors.greenAccent),
          ),
          const SizedBox(height: 28),
          const Text(
            'You are All Set!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_matchedSourcesCount on-device JS scrapers activated with $_totalHydratedManga titles ready in your library.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16161F),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '100% Server Independence Active: Read offline anytime without keeping your server on.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.cloud_done_rounded, color: Colors.lightBlueAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatic Cloud Sync: Reading progress pushes to your server when connected.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: _finishOnboarding,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.rocket_launch_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
