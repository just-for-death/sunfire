import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';

class TrackingSettingsScreen extends StatefulWidget {
  const TrackingSettingsScreen({super.key});

  @override
  State<TrackingSettingsScreen> createState() => _TrackingSettingsScreenState();
}

class _TrackingSettingsScreenState extends State<TrackingSettingsScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isObscured = true;
  bool _isVerifying = false;
  String? _verificationMessage;
  bool _verificationSuccess = false;

  List<Map<String, dynamic>> _serverTrackers = [];
  bool _loadingServerTrackers = false;

  @override
  void initState() {
    super.initState();
    final currentToken = MetronService.instance.client.apiToken;
    if (currentToken != null) {
      _tokenController.text = currentToken;
    }
    _fetchServerTrackers();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _fetchServerTrackers() async {
    if (!GraphQLClientService.instance.isConfigured) return;
    setState(() => _loadingServerTrackers = true);
    try {
      final res = await GraphQLClientService.instance.fetchTrackers();
      final nodes = res?['trackers']?['nodes'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _serverTrackers = nodes.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingServerTrackers = false);
    }
  }

  Future<void> _verifyAndSaveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      await MetronService.instance.saveToken(null);
      setState(() {
        _verificationMessage = 'Token cleared.';
        _verificationSuccess = true;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationMessage = null;
    });

    try {
      final ok = await MetronService.instance.testConnection(token);
      if (ok) {
        await MetronService.instance.saveToken(token);
        if (mounted) {
          setState(() {
            _verificationMessage = '✓ Token verified and connected successfully!';
            _verificationSuccess = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Metron.cloud connected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _verificationMessage = 'Verification failed. Please check your token.';
            _verificationSuccess = false;
          });
        }
      }
    } catch (e) {
      await MetronService.instance.saveToken(token);
      if (mounted) {
        setState(() {
          _verificationMessage = '⚠️ Token saved, but Metron.cloud timed out ($e). Connection will proceed when network route stabilizes.';
          _verificationSuccess = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMetronConfigured = MetronService.instance.isConfigured;
    final rateLimits = MetronService.instance.rateLimitState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking & Scrobbling'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── METRON (WESTERN COMICS) ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  'WESTERN COMICS (METRON.CLOUD)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.blueAccent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Metron.cloud',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isMetronConfigured ? 'Connected' : 'Not configured',
                              style: TextStyle(
                                fontSize: 13,
                                color: isMetronConfigured ? Colors.greenAccent : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMetronConfigured)
                        const SunfireBadge(
                          label: 'ACTIVE',
                          color: Colors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tokenController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: 'API Token',
                      hintText: 'Enter your Metron API Token',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscured = !_isObscured),
                          ),
                          IconButton(
                            icon: const Icon(Icons.paste_rounded),
                            onPressed: () async {
                              final data = await Clipboard.getData('text/plain');
                              if (data?.text != null) {
                                _tokenController.text = data!.text!.trim();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_verificationMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _verificationMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _verificationSuccess ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(_isVerifying ? 'Verifying...' : 'Save & Verify'),
                        onPressed: _isVerifying ? null : _verifyAndSaveToken,
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('Get Token', style: TextStyle(fontSize: 13)),
                        onPressed: () => launchUrlString(
                          'https://metron.cloud/account/',
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      const Spacer(),
                      if (isMetronConfigured)
                        TextButton(
                          child: const Text('Disconnect', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                          onPressed: () async {
                            _tokenController.clear();
                            await MetronService.instance.saveToken(null);
                            setState(() {
                              _verificationMessage = 'Disconnected';
                              _verificationSuccess = true;
                            });
                          },
                        ),
                    ],
                  ),
                  if (isMetronConfigured) ...[
                    const Divider(height: 24),
                    Text(
                      'Rate Limit Quota',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Burst (1 min)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  '${rateLimits.burstRemaining} / ${rateLimits.burstLimit}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daily Sustained', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 2),
                                Text(
                                  '${rateLimits.sustainedRemaining} / ${rateLimits.sustainedLimit}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Metron Preference Toggles
          ListTile(
            title: const Text('Auto-Scrobble to Metron'),
            subtitle: const Text('Mark issue as read on Metron when a chapter is finished'),
            trailing: Switch(
              value: SettingsService.instance.metronAutoScrobble,
              onChanged: (val) => setState(() => SettingsService.instance.metronAutoScrobble = val),
            ),
          ),
          ListTile(
            title: const Text('Auto-Match Comic Metadata'),
            subtitle: const Text('Automatically query Metron for metadata when new comics are added'),
            trailing: Switch(
              value: SettingsService.instance.metronAutoMatch,
              onChanged: (val) => setState(() => SettingsService.instance.metronAutoMatch = val),
            ),
          ),

          const SizedBox(height: 16),

          // ── MANGA TRACKERS (SUWAYOMI SERVER) ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync, size: 20, color: Colors.amberAccent),
                const SizedBox(width: 8),
                Text(
                  'MANGA TRACKERS (SERVER-SIDE)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ),
          if (_loadingServerTrackers)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_serverTrackers.isEmpty)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No server trackers found or Suwayomi server is not connected. Connect a server in Settings -> Server to track manga via AniList, MyAnimeList, or Kitsu.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            ..._serverTrackers.map((t) {
              final name = t['name'] as String? ?? 'Tracker';
              final isAuth = t['isAuthorized'] as bool? ?? false;
              final authUrl = t['authUrl'] as String?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    Icons.track_changes_rounded,
                    color: isAuth ? Colors.greenAccent : Colors.grey,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isAuth ? 'Authorized & Connected' : 'Not logged in on server',
                    style: TextStyle(
                      color: isAuth ? Colors.greenAccent : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  trailing: !isAuth && authUrl != null && authUrl.isNotEmpty
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Log In', style: TextStyle(fontSize: 12)),
                          onPressed: () => launchUrlString(authUrl, mode: LaunchMode.externalApplication),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }
}
