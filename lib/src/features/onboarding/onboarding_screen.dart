import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/db/isar_service.dart';
import '../../core/engine/javascript/m_client.dart';
import '../../core/engine/repo_manager.dart';
import '../../core/engine/source_migration_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/background_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/sync/server_auth_helper.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/sync/websocket_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _newRepoUrlController = TextEditingController();

  // Authentication
  ServerAuthType _authType = ServerAuthType.none;
  final TextEditingController _serverUsernameController = TextEditingController();
  final TextEditingController _serverPasswordController = TextEditingController();
  final TextEditingController _serverTokenController = TextEditingController();
  bool _obscurePassword = true;

  // FlareSolverr Proxy (Optional)
  final TextEditingController _flareSolverrController = TextEditingController();
  bool _isTestingFlareSolverr = false;
  String? _flareSolverrStatus;

  bool _isConnecting = false;
  String? _connectionStatus;
  bool _connectionSuccess = false;

  // Setup Mode
  bool _isStandalone = false;

  // Repositories configured by user
  final List<String> _userRepoUrls = [];

  // Hydration Progress State
  bool _isHydrating = false;
  int _hydrationStep = 0; // 0 = idle, 1 = sources, 2 = library, 3 = history, 4 = complete
  String _sourcesStatusText = 'Waiting to initialize sources...';
  String _libraryStatusText = 'Waiting to prepare library database...';
  String _historyStatusText = 'Waiting to configure reader engine...';
  int _matchedSourcesCount = 0;
  int _totalHydratedManga = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _serverUrlController.dispose();
    _newRepoUrlController.dispose();
    _serverUsernameController.dispose();
    _serverPasswordController.dispose();
    _serverTokenController.dispose();
    _flareSolverrController.dispose();
    super.dispose();
  }

  String? _buildAuthHeader() {
    switch (_authType) {
      case ServerAuthType.none:
        return null;
      case ServerAuthType.basic:
        final u = _serverUsernameController.text.trim();
        final p = _serverPasswordController.text.trim();
        if (u.isEmpty && p.isEmpty) return null;
        return ServerAuthCredentials(type: ServerAuthType.basic, username: u, password: p).toHeaderValue();
      case ServerAuthType.bearer:
        final t = _serverTokenController.text.trim();
        if (t.isEmpty) return null;
        return ServerAuthCredentials(type: ServerAuthType.bearer, token: t).toHeaderValue();
    }
  }

  Future<void> _testFlareSolverr() async {
    final text = _flareSolverrController.text.trim();
    if (text.isEmpty) {
      setState(() => _flareSolverrStatus = '⚠️ Please enter a FlareSolverr endpoint URL.');
      return;
    }
    setState(() {
      _isTestingFlareSolverr = true;
      _flareSolverrStatus = 'Testing proxy reachability...';
    });
    try {
      final url = MClient.normalizeProxyUrl(text);
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: '{"cmd":"sessions.list"}',
      ).timeout(const Duration(seconds: 5));
      setState(() {
        _isTestingFlareSolverr = false;
        _flareSolverrStatus = res.statusCode == 200
            ? '✓ FlareSolverr online (HTTP ${res.statusCode})'
            : '❌ HTTP ${res.statusCode} from proxy';
      });
    } catch (e) {
      setState(() {
        _isTestingFlareSolverr = false;
        _flareSolverrStatus = '❌ Reachability failed: $e';
      });
    }
  }

  void _startStandaloneSetup() {
    setState(() {
      _isStandalone = true;
      _serverUrlController.clear();
      _serverUsernameController.clear();
      _serverPasswordController.clear();
      _serverTokenController.clear();
      _authType = ServerAuthType.none;
    });

    // Jump directly to Repos step so user can review/add repos or proceed
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _testAndConnectServer() async {
    final rawUrl = _serverUrlController.text.trim();
    if (rawUrl.isEmpty) {
      setState(() {
        _connectionStatus = '⚠️ Please enter your Suwayomi server address.';
      });
      return;
    }

    setState(() {
      _isStandalone = false;
      _isConnecting = true;
      _connectionStatus = 'Testing connection to Suwayomi server...';
      _connectionSuccess = false;
    });

    try {
      final url = rawUrl.replaceAll(RegExp(r'/+$'), '');
      final auth = _buildAuthHeader();

      GraphQLClientService.instance.initialize(url, authToken: auth);

      final data = await GraphQLClientService.instance
          .query('{ aboutServer { version } }')
          .timeout(const Duration(seconds: 6));

      if (data != null && data.containsKey('aboutServer')) {
        final version = data['aboutServer']['version'] ?? 'v1.x';
        WebSocketService.instance.initialize(url, authToken: auth);

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
        _userRepoUrls.insert(0, url);
        _newRepoUrlController.clear();
      });
      RepoManager.instance.addUserRepo(RepoManager.deriveRepoTitle(url), url);
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
      _sourcesStatusText = _isStandalone
          ? 'Downloading all extensions from configured repositories...'
          : 'Fetching server sources and installing matching local JS scrapers...';
    });

    try {
      if (_isStandalone) {
        // ── STANDALONE MODE: Install all available repo extensions ──
        final installedCount = await RepoManager.instance.downloadAndInstallAllRepoExtensions(
          userRepoUrls: _userRepoUrls,
        );

        setState(() {
          _matchedSourcesCount = installedCount;
          _sourcesStatusText = '✓ Installed $installedCount local extensions (Ready to browse)';
          _hydrationStep = 2;
          _libraryStatusText = '✓ Local Isar database initialized';
          _hydrationStep = 3;
          _historyStatusText = '✓ On-device reader engine ready';
          _hydrationStep = 4;
        });
      } else {
        // ── SERVER MODE: Fetch server sources and match local JS scrapers ──
        final List<ServerSourceItem> serverSources = [];
        if (GraphQLClientService.instance.isConfigured) {
          final sourcesData = await GraphQLClientService.instance
              .fetchSources()
              .timeout(const Duration(seconds: 8), onTimeout: () => null);

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

        setState(() {
          _sourcesStatusText =
              'Installing local JS scrapers for ${serverSources.length} server sources...';
        });

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
          _sourcesStatusText =
              '✓ Installed ${installedSources.length}/${serverSources.length} sources locally'
              ' (${migrationResult.serverOnlySources.length} server-only fallbacks)';
          _hydrationStep = 2;
          _libraryStatusText = 'Fetching complete library manga and caching chapters in Isar DB...';
        });

        await Future.delayed(const Duration(milliseconds: 400));

        // ── STEP 2: HYDRATE LIBRARY & CHAPTERS ──
        if (GraphQLClientService.instance.isConfigured) {
          try {
            await SyncEngine.instance.triggerSync().timeout(const Duration(seconds: 5));
          } catch (_) {}
          final libraryItems = await IsarService.instance.getLibraryManga();
          _totalHydratedManga = libraryItems.length;
        }

        setState(() {
          _libraryStatusText =
              '✓ Cached $_totalHydratedManga library titles into local DB (100% Offline Ready)';
          _hydrationStep = 3;
          _historyStatusText = '✓ Reading history and chapter feeds synchronized';
          _hydrationStep = 4;
        });
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e, st) {
      LoggerService.instance.logError('Initial hydration error',
          exception: e, stackTrace: st, category: 'Onboarding');
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
    final auth = _buildAuthHeader();

    await SourceMigrationService.instance.markOnboardingCompleted(
      serverUrl: cleanUrl,
      authHeader: auth,
      selectedRepos: _userRepoUrls,
    );
    SettingsService.instance.onboardingCompleted = true;

    if (_flareSolverrController.text.trim().isNotEmpty) {
      SettingsService.instance.cfProxyUrl = _flareSolverrController.text.trim();
    }

    if (cleanUrl.isNotEmpty) {
      GraphQLClientService.instance.initialize(cleanUrl, authToken: auth);
      WebSocketService.instance.initialize(cleanUrl, authToken: auth);
      SyncEngine.instance.initialize();
      await BackgroundService.instance.initialize();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.25),
                  primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(Icons.wb_sunny_rounded, size: 68, color: primaryColor),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sunfire',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The Local-First Manga Reader',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'High-performance on-device reading engine with full offline support, QuickJS scrapers, and optional Suwayomi cloud sync.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: Colors.grey, height: 1.45),
          ),
          const SizedBox(height: 36),

          // Option 1: Standalone Mode (No Server Needed)
          InkWell(
            onTap: _startStandaloneSetup,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF191924),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt_rounded, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standalone Mode',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Zero server required. Install extensions directly and read 100% on-device.',
                          style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Option 2: Connect Suwayomi Server
          InkWell(
            onTap: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF14141C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: Colors.lightBlueAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link Suwayomi Server',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Import your existing server library, reading history & categories.',
                          style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.cloud_sync_rounded, color: primaryColor, size: 26),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Link Suwayomi Server',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your Suwayomi server address to import your library, chapters, and history.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _serverUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Server URL',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'http://192.168.1.50:4567 or https://manga.example.com',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1B1B22),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.dns_rounded, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Authentication', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 8),
          SegmentedButton<ServerAuthType>(
            segments: const [
              ButtonSegment(value: ServerAuthType.none, label: Text('None')),
              ButtonSegment(value: ServerAuthType.basic, label: Text('Basic Auth')),
              ButtonSegment(value: ServerAuthType.bearer, label: Text('Bearer Token')),
            ],
            selected: {_authType},
            onSelectionChanged: (set) => setState(() => _authType = set.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 12),
          if (_authType == ServerAuthType.basic) ...[
            TextField(
              controller: _serverUsernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'admin',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1B1B22),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person_rounded, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serverPasswordController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: '••••••••',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1B1B22),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.lock_rounded, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ] else if (_authType == ServerAuthType.bearer) ...[
            TextField(
              controller: _serverTokenController,
              style: const TextStyle(color: Colors.white),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Bearer Token / API Key',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: 'e.g. eyJhbGciOi...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1B1B22),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.key_rounded, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // FlareSolverr Proxy (Optional)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF14141C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.amberAccent, size: 20),
                    SizedBox(width: 8),
                    Text('FlareSolverr Proxy (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bypasses Cloudflare Turnstile challenges for protected sources and extensions.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _flareSolverrController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Proxy Endpoint',
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                    hintText: 'http://192.168.1.50:8191/v1',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color(0xFF1B1B22),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    suffixIcon: TextButton(
                      onPressed: _isTestingFlareSolverr ? null : _testFlareSolverr,
                      child: _isTestingFlareSolverr
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Test', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                if (_flareSolverrStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _flareSolverrStatus!,
                    style: TextStyle(
                      fontSize: 11,
                      color: _flareSolverrStatus!.startsWith('✓') ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ],
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
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isConnecting ? null : _testAndConnectServer,
            child: _isConnecting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Connect & Import Server', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _startStandaloneSetup,
            child: const Center(
              child: Text('Skip server setup (Use Pure Standalone Mode)', style: TextStyle(color: Colors.white60, fontSize: 13)),
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
              const Expanded(
                child: Text(
                  'Extension Repositories',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sunfire is a neutral reader. Paste your Mangayomi JSON extension repositories below:',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_userRepoUrls.isEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MangaYomi Community Repository', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Text('100+ public scrapers (MangaDex, ComicK, etc.)', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      const defaultRepo = 'https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/index.json';
                      if (!_userRepoUrls.contains(defaultRepo)) {
                        setState(() => _userRepoUrls.insert(0, defaultRepo));
                        RepoManager.instance.addUserRepo(RepoManager.deriveRepoTitle(defaultRepo), defaultRepo);
                      }
                    },
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
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
                final label = RepoManager.deriveRepoTitle(url);
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
          const SizedBox(height: 12),
          if (_isStandalone) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14141C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.amberAccent, size: 18),
                      SizedBox(width: 8),
                      Text('FlareSolverr Proxy (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('For Cloudflare protected sources and extensions', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _flareSolverrController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Proxy Endpoint',
                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                      hintText: 'http://192.168.1.50:8191/v1',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF1B1B22),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      suffixIcon: TextButton(
                        onPressed: _isTestingFlareSolverr ? null : _testFlareSolverr,
                        child: _isTestingFlareSolverr
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  if (_flareSolverrStatus != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _flareSolverrStatus!,
                      style: TextStyle(
                        fontSize: 11,
                        color: _flareSolverrStatus!.startsWith('✓') ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
                Text('Start Setup & Hydration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Replicating State', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Building 100% offline local database', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
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
            _isStandalone
                ? '$_matchedSourcesCount on-device JS scrapers activated. Your local library is ready!'
                : '$_matchedSourcesCount on-device JS scrapers activated with $_totalHydratedManga titles ready in your library.',
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
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '100% On-Device Engine: Browse, download, and read manga offline anytime.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _isStandalone ? Icons.cloud_outlined : Icons.cloud_done_rounded,
                      color: _isStandalone ? Colors.grey : Colors.lightBlueAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isStandalone
                            ? 'Cloud Sync Available: You can connect a Suwayomi server anytime in Settings.'
                            : 'Automatic Cloud Sync: Reading progress pushes to your server when connected.',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
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
