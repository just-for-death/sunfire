import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isConnecting = false;
  String? _statusMessage;

  Future<void> _testAndConnectServer() async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Testing connection...';
    });

    try {
      final url = _serverUrlController.text.trim();
      GraphQLClientService.instance.initialize(url);
      final data = await GraphQLClientService.instance.query('{ aboutServer { version } }');

      if (data != null && data.containsKey('aboutServer')) {
        final version = data['aboutServer']['version'];
        WebSocketService.instance.initialize(url);
        await SyncEngine.instance.initialize();

        setState(() {
          _statusMessage = '✓ Connected to Suwayomi $version';
        });

        await Future.delayed(const Duration(milliseconds: 800));
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Could not connect: $e';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _finishOnboarding() {
    context.go('/library');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomeStep(),
            _buildServerStep(),
            _buildReposStep(),
            _buildSourceSyncStep(),
            _buildLibrarySyncStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_rounded, size: 80, color: primaryColor),
          const SizedBox(height: 24),
          const Text(
            'Sunfire',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Local-first manga reader powered by QuickJS and Suwayomi sync.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildServerStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect Suwayomi Server', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Enter your home Suwayomi server address for real-time state sync.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          TextField(
            controller: _serverUrlController,
            decoration: InputDecoration(
              labelText: 'Server URL',
              hintText: 'http://192.168.1.x:4567',
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null)
            Text(_statusMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isConnecting ? null : _testAndConnectServer,
            child: _isConnecting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Test & Connect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Center(child: Text('Skip for now (Local-only mode)', style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
    );
  }

  Widget _buildReposStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Extension Repositories', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Sunfire includes 4 active community JS source repos by default:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          _buildRepoTile('m2k3a/mangayomi-extensions', 'Primary Manga sources (250+)'),
          _buildRepoTile('Mallyd11/mangayomi-anime-extensions', 'Anime & Novel sources (310+)'),
          _buildRepoTile('Swakshan/mangayomi-swak-extensions', 'Cloudflare sources (180+)'),
          _buildRepoTile('gato404/kegareta-sauces', 'NSFW sources (90+)'),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoTile(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0x1F2A2A32), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSyncStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.extension_rounded, size: 72, color: primaryColor),
          const SizedBox(height: 24),
          const Text('Extension Architecture', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Browse Tachiyomi Keiyoushi APK sources on your server and QuickJS community sources on your device seamlessly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySyncStep() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_rounded, size: 72, color: primaryColor),
          const SizedBox(height: 24),
          const Text('Real-time State Engine', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Your categories, reading progress, and chapter updates synchronize automatically in the background.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _finishOnboarding,
            child: const Text('Start Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
