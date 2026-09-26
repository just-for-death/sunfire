import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/engine/repo_manager.dart';
import '../../core/logging/logger_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_subpage_scaffold.dart';

/// Canonical project links, referenced by the About page and by the
/// "check for updates" flow so the URLs only ever live in one place.
class SunfireProject {
  const SunfireProject._();

  static const String repository = 'https://github.com/just-for-death/sunfire';
  static const String issues = '$repository/issues';
  static const String releases = '$repository/releases';
  static const String contributors = '$repository/graphs/contributors';
  static const String license = '$repository/blob/main/LICENSE';
  static const String privacyPolicy = '$repository/blob/main/PRIVACY.md';
  static const String changelog = '$repository/blob/main/CHANGELOG.md';
  static const String latestReleaseApi =
      'https://api.github.com/repos/just-for-death/sunfire/releases/latest';
}

/// A release published on GitHub, reduced to what the About page needs.
class AppReleaseInfo {
  const AppReleaseInfo({required this.version, required this.url, this.isPrerelease = false});

  /// Semver without the conventional leading `v`.
  final String version;
  final String url;
  final bool isPrerelease;

  /// Parses the payload of the GitHub `releases/latest` endpoint.
  ///
  /// Returns `null` for anything that is not a structurally valid release
  /// object (HTML error page, rate-limit body, truncated JSON) so the caller
  /// can report "check failed" instead of claiming an update exists.
  static AppReleaseInfo? tryParse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final tag = decoded['tag_name'];
      if (tag is! String || tag.trim().isEmpty) return null;
      final normalized = tag.trim();
      final version = normalized.startsWith('v') ? normalized.substring(1) : normalized;
      if (version.isEmpty) return null;
      final htmlUrl = decoded['html_url'];
      return AppReleaseInfo(
        version: version,
        url: htmlUrl is String && htmlUrl.isNotEmpty ? htmlUrl : SunfireProject.releases,
        isPrerelease: decoded['prerelease'] == true,
      );
    } catch (e) {
      LoggerService.instance.logWarning('Malformed release payload: $e', 'About');
      return null;
    }
  }

  /// Matches a bare semver-ish version: numeric components, optional
  /// prerelease/build suffix. Used to refuse comparisons against strings that
  /// carry no version information at all.
  static final RegExp _semverLike = RegExp(r'^\d+(\.\d+)*([-+][0-9A-Za-z.\-]+)?$');

  /// Positive when [this] release is newer than [installedVersion].
  ///
  /// Both sides must actually look like versions. `RepoManager.compareVersions`
  /// strips every non-numeric character and substitutes 0 for what it cannot
  /// parse, so comparing `4.1.0` against `unknown` yields `[4,1,0]` vs `[0]`
  /// and reports an update — a PackageInfo failure or a sideload build would
  /// then nag forever about a release it can never reconcile. Refusing to
  /// compare is the only honest answer.
  bool isNewerThan(String installedVersion) {
    final installed = installedVersion.trim();
    if (!_semverLike.hasMatch(installed)) return false;
    if (!_semverLike.hasMatch(version.trim())) return false;
    return RepoManager.compareVersions(version.trim(), installed) > 0;
  }
}

enum _UpdateCheckState { idle, checking, upToDate, available, failed }

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _logCategory = 'About';

  String _version = '';
  String _buildNumber = '';
  String _packageName = 'sunfire';
  String _platformInfo = '';
  bool _isLoadingAppInfo = true;

  _UpdateCheckState _updateState = _UpdateCheckState.idle;
  AppReleaseInfo? _release;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    String version = '';
    String buildNumber = '';
    String packageName = 'sunfire';
    try {
      // Bounded: `PackageInfo.fromPlatform()` awaits a platform-channel reply,
      // and a plugin that never answers would otherwise leave this page
      // spinning on its progress indicator forever with no way out. The About
      // page must degrade to "unknown", not hang.
      final info = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('PackageInfo.fromPlatform() did not respond'),
      );
      if (info.version.isNotEmpty) version = info.version;
      buildNumber = info.buildNumber;
      if (info.packageName.isNotEmpty) packageName = info.packageName;
    } catch (e) {
      LoggerService.instance.logWarning('PackageInfo unavailable: $e', _logCategory);
    }
    if (!mounted) return;
    setState(() {
      _version = version;
      _buildNumber = buildNumber;
      _packageName = packageName;
      _platformInfo = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'.trim();
      _isLoadingAppInfo = false;
    });
  }

  String get _versionDisplay {
    if (_version.isEmpty) return 'unknown';
    if (_buildNumber.isEmpty) return _version;
    return '$_version+$_buildNumber';
  }

  Future<void> _checkForUpdates() async {
    if (_updateState == _UpdateCheckState.checking) return;
    setState(() => _updateState = _UpdateCheckState.checking);

    try {
      final response = await http
          .get(
            Uri.parse(SunfireProject.latestReleaseApi),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'Sunfire-Client',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        // 403 here is almost always GitHub's unauthenticated rate limiter.
        LoggerService.instance.logWarning('Update check HTTP ${response.statusCode}', _logCategory);
        if (mounted) setState(() => _updateState = _UpdateCheckState.failed);
        return;
      }

      final release = AppReleaseInfo.tryParse(response.body);
      if (release == null) {
        if (mounted) setState(() => _updateState = _UpdateCheckState.failed);
        return;
      }

      LoggerService.instance.logInfo(
        'Update check: installed $_versionDisplay, latest ${release.version}',
        _logCategory,
      );
      if (!mounted) return;
      setState(() {
        _release = release;
        _updateState = release.isNewerThan(_version) ? _UpdateCheckState.available : _UpdateCheckState.upToDate;
      });
    } catch (e) {
      LoggerService.instance.logWarning('Update check failed: $e', _logCategory);
      if (mounted) setState(() => _updateState = _UpdateCheckState.failed);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('No app available to open this link');
      }
    } catch (e) {
      LoggerService.instance.logWarning('Failed to launch $url: $e', _logCategory);
      _snack('Could not open link');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Sunfire',
      applicationVersion: _versionDisplay,
      applicationIcon: const Icon(Icons.local_fire_department_rounded, size: 48, color: Colors.white),
      applicationLegalese: '© Sunfire Contributors. Licensed under the MPL-2.0.',
    );
  }

  String get _diagnosticReport {
    final lines = <String>[
      'Sunfire $_versionDisplay',
      'Package: $_packageName',
      'Platform: $_platformInfo',
      'Dart: ${Platform.version.split(' ').first}',
    ];
    final release = _release;
    if (release != null) lines.add('Latest release: v${release.version}');
    lines.add('Repo: ${SunfireProject.repository}');
    return lines.join('\n');
  }

  void _copyDiagnostics() {
    Clipboard.setData(ClipboardData(text: _diagnosticReport));
    _snack('Diagnostics copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SettingsSubpageScaffold(
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          _buildHeader(primary),
          const SectionTitle(title: 'What is Sunfire?'),
          _buildDescription(),
          const SectionTitle(title: 'Version'),
          _buildUpdateSection(primary),
          const SectionTitle(title: 'Project'),
          _buildProjectLinks(),
          const SectionTitle(title: 'Legal'),
          _buildLegalTiles(primary),
          const SectionTitle(title: 'Diagnostics'),
          _buildDiagnosticsRows(),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: _copyDiagnostics,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy diagnostics'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made for people who self-host their manga.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.local_fire_department_rounded, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text(
            'Sunfire',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Version $_versionDisplay',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x1F2A2A32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x2BFFFFFF), width: 0.8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A cross-platform manga reader and library manager for Suwayomi/Tachidesk servers. '
              'Scrapers run locally through QuickJS, downloads are readable offline, and your '
              'library, history and progress stay in sync with your own server.',
              style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SunfireBadge(label: 'MPL-2.0', color: Colors.tealAccent, fontSize: 9, fontWeight: FontWeight.bold),
                SunfireBadge(label: 'OFFLINE-FIRST', color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold),
                SunfireBadge(label: 'NO ANALYTICS', color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSection(Color primary) {
    final release = _release;

    Widget trailing;
    switch (_updateState) {
      case _UpdateCheckState.checking:
        trailing = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case _UpdateCheckState.available:
        trailing = Icon(Icons.system_update_rounded, color: Colors.amberAccent.shade200);
        break;
      case _UpdateCheckState.upToDate:
        trailing = Icon(Icons.verified_rounded, color: Colors.tealAccent.shade200);
        break;
      case _UpdateCheckState.failed:
        trailing = Icon(Icons.error_outline_rounded, color: Colors.redAccent.shade200);
        break;
      case _UpdateCheckState.idle:
        trailing = const Icon(Icons.chevron_right_rounded, color: Colors.grey);
    }

    String subtitle;
    switch (_updateState) {
      case _UpdateCheckState.idle:
        subtitle = 'Compare against the latest GitHub release';
        break;
      case _UpdateCheckState.checking:
        subtitle = 'Contacting GitHub…';
        break;
      case _UpdateCheckState.upToDate:
        subtitle = 'You are on the latest release';
        break;
      case _UpdateCheckState.available:
        subtitle = 'Update available: v${release?.version}';
        break;
      case _UpdateCheckState.failed:
        subtitle = 'Could not reach GitHub — tap to retry';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(Icons.system_update_alt_rounded, size: 24, color: primary),
          title: const Text('Check for updates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: trailing,
          enabled: _updateState != _UpdateCheckState.checking,
          onTap: _updateState == _UpdateCheckState.available ? _openReleases : _checkForUpdates,
        ),
        if (_updateState == _UpdateCheckState.available)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openReleases,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('View v${release?.version} on GitHub'),
              ),
            ),
          ),
        if (_updateState == _UpdateCheckState.failed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Sunfire never blocks on this check. Releases also ship through '
              'Codemagic, so store updates arrive on their own.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
      ],
    );
  }

  void _openReleases() {
    _openUrl(_release?.url ?? SunfireProject.releases);
  }

  Widget _buildProjectLinks() {
    return Column(
      children: [
        _LinkTile(
          icon: Icons.code_rounded,
          label: 'Source code',
          url: SunfireProject.repository,
          onTap: _openUrl,
        ),
        _LinkTile(
          icon: Icons.bug_report_rounded,
          label: 'Issue tracker',
          url: SunfireProject.issues,
          onTap: _openUrl,
        ),
        _LinkTile(
          icon: Icons.newspaper_rounded,
          label: 'Changelog',
          url: SunfireProject.changelog,
          onTap: _openUrl,
        ),
        _LinkTile(
          icon: Icons.groups_rounded,
          label: 'Contributors',
          url: SunfireProject.contributors,
          onTap: _openUrl,
        ),
        _LinkTile(
          icon: Icons.rocket_launch_rounded,
          label: 'Releases',
          url: SunfireProject.releases,
          onTap: _openUrl,
        ),
      ],
    );
  }

  Widget _buildLegalTiles(Color primary) {
    return Column(
      children: [
        _LinkTile(
          icon: Icons.balance_rounded,
          label: 'License (MPL-2.0)',
          url: SunfireProject.license,
          onTap: _openUrl,
        ),
        _LinkTile(
          icon: Icons.privacy_tip_rounded,
          label: 'Privacy policy',
          url: SunfireProject.privacyPolicy,
          onTap: _openUrl,
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(Icons.description_rounded, size: 24, color: primary),
          title: const Text('Open source licenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: const Text(
            'Every third-party package and its license',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          onTap: _showLicenses,
        ),
      ],
    );
  }

  Widget _buildDiagnosticsRows() {
    if (_isLoadingAppInfo) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final rows = <(String, String)>[
      ('Version', _versionDisplay),
      ('Package', _packageName),
      ('Platform', _platformInfo.isEmpty ? Platform.operatingSystem : _platformInfo),
      ('Dart', Platform.version.split(' ').first),
      ('Release channel', _release == null ? 'not checked' : 'v${_release!.version}'),
    ];

    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Expanded(
                  child: SelectableText(
                    value,
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String url;
  final void Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(
        url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.grey),
      onTap: () => onTap(url),
    );
  }
}
