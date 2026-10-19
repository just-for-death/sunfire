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
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
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
              backgroundColor: SunfireColors.success,
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
        padding: const EdgeInsets.symmetric(vertical: SunfireSpacing.lg),
        children: [
          // ── METRON (WESTERN COMICS) ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, size: SunfireIconSize.md, color: SunfireColors.trackerBlue),
                const SizedBox(width: SunfireSpacing.sm),
                Expanded(
                  child: Text(
                    'WESTERN COMICS (METRON.CLOUD)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: SunfireColors.trackerBlue,
                    ),
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
            leading: Icon(Icons.sync_alt_rounded, color: isMetronConfigured ? SunfireColors.trackerBlue : SunfireColors.contentTertiary),
            trailing: Switch(
              value: isMetronConfigured && SettingsService.instance.metronAutoScrobble,
              onChanged: isMetronConfigured
                  ? (val) => setState(() => SettingsService.instance.metronAutoScrobble = val)
                  : null,
            ),
          ),

          const SizedBox(height: SunfireSpacing.lg),

          // ── MANGA TRACKERS (SUWAYOMI SERVER) ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cloud_sync, size: SunfireIconSize.md, color: SunfireColors.trackerAmber),
                const SizedBox(width: SunfireSpacing.sm),
                Expanded(
                  child: Text(
                    'MANGA TRACKERS (SERVER-SIDE)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: SunfireColors.trackerAmber,
                    ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.lg)),
      elevation: isConfigured ? 2 : 0,
      color: isConfigured
          ? SunfireColors.trackerBlueSubtle
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
                        ? SunfireColors.trackerBlueContainer
                        : SunfireColors.contentTertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SunfireRadius.md),
                    border: Border.all(
                      color: isConfigured
                          ? SunfireColors.trackerBlue.withValues(alpha: 0.5)
                          : SunfireColors.contentDisabled,
                    ),
                  ),
                  child: Icon(
                    isConfigured ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                    color: isConfigured ? SunfireColors.trackerBlue : SunfireColors.contentTertiary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: SunfireSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metron.cloud',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isConfigured ? theme.colorScheme.onSurface : SunfireColors.contentTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isConfigured ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isConfigured ? 'Connected & Active' : 'Not Configured',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isConfigured ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                              ),
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
                    color: SunfireColors.trackerGreen,
                    icon: const Icon(Icons.check_circle_rounded, size: SunfireIconSize.xs),
                  ),
              ],
            ),

            const SizedBox(height: SunfireSpacing.lg),

            // Token input section
            if (!isConfigured) ...[
              Text(
                'Enter your Metron API token to enable automatic scrobbling of western comics.',
                style: theme.textTheme.bodySmall?.copyWith(color: SunfireColors.contentTertiary),
              ),
              const SizedBox(height: SunfireSpacing.md),
            ],

            TextField(
              controller: _tokenController,
              obscureText: _isObscured,
              enabled: !_isVerifying,
              decoration: InputDecoration(
                labelText: 'API Token',
                hintText: isConfigured ? 'Token configured (hidden)' : 'Enter your Metron API Token',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                prefixIcon: Icon(Icons.key_rounded, color: isConfigured ? SunfireColors.trackerBlue : SunfireColors.contentTertiary),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: isConfigured
                          ? () => setState(() => _isObscured = !_isObscured)
                          : null,
                      color: isConfigured ? SunfireColors.trackerBlue : SunfireColors.contentTertiary,
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
                    ? SunfireColors.trackerBlue.withValues(alpha: 0.03)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),

            if (_verificationMessage != null) ...[
              const SizedBox(height: SunfireSpacing.sm),
              Row(
                children: [
                  Icon(
                    _verificationSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                    size: 14,
                    color: _verificationSuccess ? SunfireColors.trackerGreen : SunfireColors.destructive,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _verificationMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _verificationSuccess ? SunfireColors.trackerGreen : SunfireColors.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: SunfireSpacing.md),

            // Action buttons
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConfigured ? SunfireColors.trackerBlue : SunfireColors.contentTertiary,
                    foregroundColor: SunfireColors.contentPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SunfireColors.contentPrimary),
                        )
                      : Icon(isConfigured ? Icons.check_circle_outline : Icons.save_rounded, size: SunfireIconSize.std),
                  label: Text(
                    _isVerifying
                        ? 'Verifying...'
                        : isConfigured
                            ? 'Update & Verify'
                            : 'Save & Verify',
                  ),
                  onPressed: isConfigured || !_isVerifying ? _verifyAndSaveToken : null,
                ),
                const SizedBox(width: SunfireSpacing.sm),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: SunfireIconSize.std),
                  label: const Text('Get Token'),
                  onPressed: () => launchUrlString(
                    'https://metron.cloud/account/',
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Spacer(),
                if (isConfigured)
                  TextButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: SunfireIconSize.std),
                    label: const Text('Disconnect', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: SunfireColors.destructive,
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
        const SizedBox(height: SunfireSpacing.sm),
        _buildRateLimitTile(
          theme,
          label: 'Burst (1 min)',
          remaining: rateLimits.burstRemaining,
          limit: rateLimits.burstLimit,
          icon: Icons.flash_on_rounded,
          color: SunfireColors.unreadDot,
        ),
        const SizedBox(height: SunfireSpacing.sm),
        _buildRateLimitTile(
          theme,
          label: 'Daily Sustained',
          remaining: rateLimits.sustainedRemaining,
          limit: rateLimits.sustainedLimit,
          icon: Icons.schedule_rounded,
          color: SunfireColors.trackerBlue,
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
          color: isLow ? SunfireColors.destructive.withValues(alpha: 0.5) : color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: SunfireIconSize.sm, color: isLow ? SunfireColors.destructive : color),
              const SizedBox(width: SunfireSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLow ? SunfireColors.destructive : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: SunfireSpacing.sm),
              Text(
                '$remaining / $limit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLow ? SunfireColors.destructive : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(isLow ? SunfireColors.destructive : color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: SunfireSpacing.xs),
          Text(
            isLow ? '⚠️ Quota running low' : 'Quota healthy',
            style: TextStyle(
              fontSize: 11,
              color: isLow ? SunfireColors.destructive : SunfireColors.trackerGreen,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.lg)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 48,
              color: SunfireColors.contentDisabled,
            ),
            const SizedBox(height: SunfireSpacing.md),
            Text(
              'No Server Trackers Found',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SunfireSpacing.sm),
            Text(
              'Connect a Suwayomi server in Settings → Server to track manga via AniList, MyAnimeList, or Kitsu. Once connected and authorized, your trackers will appear here.',
              style: theme.textTheme.bodySmall?.copyWith(color: SunfireColors.contentTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SunfireSpacing.lg),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings_rounded, size: SunfireIconSize.std),
              label: const Text('Open Server Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SunfireColors.trackerAmber,
                foregroundColor: SunfireColors.onTrackerAmber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.md)),
      elevation: isAuth ? 1 : 0,
      color: isAuth
          ? SunfireColors.trackerGreen.withValues(alpha: 0.03)
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
                        ? SunfireColors.trackerGreenContainer
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(SunfireRadius.md),
                    border: Border.all(
                      color: isAuth
                          ? SunfireColors.trackerGreen.withValues(alpha: 0.5)
                          : SunfireColors.contentDisabled,
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
                              color: isAuth ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                              size: 24,
                            ),
                          )
                        : Icon(
                            Icons.track_changes_rounded,
                            color: isAuth ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
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
                      color: isAuth ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: SunfireSpacing.lg),
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
                      color: isAuth ? theme.colorScheme.onSurface : SunfireColors.contentTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isAuth ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isAuth ? 'Authorized & Connected' : 'Not Authorized',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isAuth ? SunfireColors.trackerGreen : SunfireColors.contentTertiary,
                            fontWeight: FontWeight.w500,
                          ),
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
                  backgroundColor: SunfireColors.trackerAmber,
                  foregroundColor: SunfireColors.onTrackerAmber,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunfireRadius.sm)),
                ),
                onPressed: () => launchUrlString(authUrl, mode: LaunchMode.externalApplication),
                child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (isAuth)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SunfireColors.trackerGreenContainer,
                  borderRadius: BorderRadius.circular(SunfireRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: SunfireIconSize.xs, color: SunfireColors.trackerGreen),
                    const SizedBox(width: SunfireSpacing.xs),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: SunfireColors.trackerGreen,
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