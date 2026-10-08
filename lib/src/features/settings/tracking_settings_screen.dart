import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../core/metron/metron_models.dart';
import '../../core/metron/metron_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../shared/friendly_network_error.dart';

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
    unawaited(_fetchServerTrackers());
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
    } catch (ignoredError) { if (kDebugMode) debugPrint('[tracking_settings_screen] fetchServerTrackers: $ignoredError');
    } finally {
      if (mounted) setState(() => _loadingServerTrackers = false);
    }
  }

  Future<void> _verifyAndSaveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      await MetronService.instance.saveToken(null);
      if (!mounted) return;
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
          _verificationMessage =
              '⚠️ Token saved, but Metron.cloud failed (${friendlyNetworkError(e, tag: 'TrackingSettings')}). Connection will proceed when network route stabilizes.';
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
    final MetronRateLimitState rateLimits = MetronService.instance.rateLimitState;

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

          // Metron Connection Card - dramatically improved
          _buildMetronConnectionCard(theme, isMetronConfigured, rateLimits),

          // Metron Preference Toggles
          ListTile(
            title: const Text('Auto-Scrobble to Metron'),
            subtitle: const Text('Mark issue as read on Metron when a chapter is finished'),
            leading: Icon(Icons.sync_alt_rounded, color: isMetronConfigured ? Colors.blueAccent : Colors.grey),
            trailing: Switch(
              value: isMetronConfigured && SettingsService.instance.metronAutoScrobble,
              onChanged: isMetronConfigured
                  ? (val) => setState(() => SettingsService.instance.metronAutoScrobble = val)
                  : null,
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
            _buildEmptyServerTrackersCard(theme)
          else
            ..._serverTrackers.map((t) => _buildServerTrackerCard(t, theme)),
        ],
      ),
    );
  }

  Widget _buildMetronConnectionCard(ThemeData theme, bool isConfigured, MetronRateLimitState rateLimits) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isConfigured ? 2 : 0,
      color: isConfigured
          ? Colors.blueAccent.withValues(alpha: 0.05)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isConfigured
                        ? Colors.blueAccent.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isConfigured
                          ? Colors.blueAccent.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isConfigured ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                    color: isConfigured ? Colors.blueAccent : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metron.cloud',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isConfigured ? theme.colorScheme.onSurface : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConfigured ? Colors.greenAccent : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConfigured ? 'Connected & Active' : 'Not Configured',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isConfigured ? Colors.greenAccent : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isConfigured)
                  SunfireBadge(
                    label: 'ACTIVE',
                    color: Colors.greenAccent,
                    icon: const Icon(Icons.check_circle_rounded, size: 12),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Token input section
            if (!isConfigured) ...[
              Text(
                'Enter your Metron API token to enable automatic scrobbling of western comics.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _tokenController,
              obscureText: _isObscured,
              enabled: !_isVerifying,
              decoration: InputDecoration(
                labelText: 'API Token',
                hintText: isConfigured ? 'Token configured (hidden)' : 'Enter your Metron API Token',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.key_rounded, color: isConfigured ? Colors.blueAccent : Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: isConfigured
                          ? () => setState(() => _isObscured = !_isObscured)
                          : null,
                      color: isConfigured ? Colors.blueAccent : Colors.grey,
                    ),
                    if (!isConfigured)
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
                filled: true,
                fillColor: isConfigured
                    ? Colors.blueAccent.withValues(alpha: 0.03)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),

            if (_verificationMessage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _verificationSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: 14,
                    color: _verificationSuccess ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _verificationMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _verificationSuccess ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConfigured ? Colors.blueAccent : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(isConfigured ? Icons.check_circle_outline : Icons.save_rounded, size: 18),
                  label: Text(
                    _isVerifying
                        ? 'Verifying...'
                        : isConfigured
                            ? 'Update & Verify'
                            : 'Save & Verify',
                  ),
                  onPressed: isConfigured || !_isVerifying ? _verifyAndSaveToken : null,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Get Token'),
                  onPressed: () => launchUrlString(
                    'https://metron.cloud/account/',
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Spacer(),
                if (isConfigured)
                  TextButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Disconnect', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      _tokenController.clear();
                      await MetronService.instance.saveToken(null);
                      if (!mounted) return;
                      setState(() {
                        _verificationMessage = 'Disconnected from Metron.cloud';
                        _verificationSuccess = true;
                      });
                    },
                  ),
              ],
            ),

            if (isConfigured) ...[
              const Divider(height: 24),
              _buildRateLimitSection(theme, rateLimits),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateLimitSection(ThemeData theme, MetronRateLimitState rateLimits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Limit Quota',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildRateLimitTile(
          theme,
          label: 'Burst (1 min)',
          remaining: rateLimits.burstRemaining,
          limit: rateLimits.burstLimit,
          icon: Icons.flash_on_rounded,
          color: Colors.orangeAccent,
        ),
        const SizedBox(height: 8),
        _buildRateLimitTile(
          theme,
          label: 'Daily Sustained',
          remaining: rateLimits.sustainedRemaining,
          limit: rateLimits.sustainedLimit,
          icon: Icons.schedule_rounded,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildRateLimitTile(
    ThemeData theme, {
    required String label,
    required int remaining,
    required int limit,
    required IconData icon,
    required Color color,
  }) {
    final progress = limit > 0 ? remaining / limit : 0.0;
    final isLow = progress < 0.2;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLow ? Colors.redAccent.withValues(alpha: 0.5) : color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isLow ? Colors.redAccent : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLow ? Colors.redAccent : theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$remaining / $limit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLow ? Colors.redAccent : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(isLow ? Colors.redAccent : color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          Text(
            isLow ? '⚠️ Quota running low' : 'Quota healthy',
            style: TextStyle(
              fontSize: 11,
              color: isLow ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyServerTrackersCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No Server Trackers Found',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect a Suwayomi server in Settings → Server to track manga via AniList, MyAnimeList, or Kitsu. Once connected and authorized, your trackers will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Open Server Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Navigate to server settings
                Navigator.of(context).pushNamed('/settings/server');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerTrackerCard(Map<String, dynamic> t, ThemeData theme) {
    final name = t['name'] as String? ?? 'Tracker';
    final isAuth = t['isAuthorized'] == true;
    final authUrl = t['authUrl'] as String?;
    final iconName = t['icon'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isAuth ? 1 : 0,
      color: isAuth
          ? Colors.greenAccent.withValues(alpha: 0.03)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Tracker icon with status ring
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isAuth
                        ? Colors.greenAccent.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAuth
                          ? Colors.greenAccent.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: iconName != null && iconName.isNotEmpty
                        ? Image.network(
                            iconName,
                            width: 28,
                            height: 28,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.track_changes_rounded,
                              color: isAuth ? Colors.greenAccent : Colors.grey,
                              size: 24,
                            ),
                          )
                        : Icon(
                            Icons.track_changes_rounded,
                            color: isAuth ? Colors.greenAccent : Colors.grey,
                            size: 24,
                          ),
                  ),
                ),
                // Status dot
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isAuth ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Tracker info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAuth ? theme.colorScheme.onSurface : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isAuth ? Colors.greenAccent : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAuth ? 'Authorized & Connected' : 'Not Authorized',
                        style: TextStyle(
                          fontSize: 12,
                          color: isAuth ? Colors.greenAccent : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action button
            if (!isAuth && authUrl != null && authUrl.isNotEmpty)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => launchUrlString(authUrl, mode: LaunchMode.externalApplication),
                child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (isAuth)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Colors.greenAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}