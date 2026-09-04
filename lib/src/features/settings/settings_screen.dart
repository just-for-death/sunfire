import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'advanced_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'backup_settings_screen.dart';
import 'browse_settings_screen.dart';
import 'downloads_settings_screen.dart';
import 'library_settings_screen.dart';
import 'reader_settings_screen.dart';
import 'server_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildScopeTag(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    List<String> tags = const [],
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, size: 24),
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          for (final tag in tags)
            if (tag == 'SERVER')
              _buildScopeTag('SERVER', Colors.tealAccent)
            else if (tag == 'LOCAL')
              _buildScopeTag('LOCAL', Colors.purpleAccent),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isTablet = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // 1. SERVER (PRIMARY)
              _buildTile(
                icon: Icons.dns_outlined,
                title: 'Server',
                subtitle: 'Connection, bindings, SOCKS proxy, FlareSolverr, OPDS, SyncYomi',
                tags: ['SERVER'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServerSettingsScreen()),
                  );
                },
              ),

              // 2. LIBRARY
              _buildTile(
                icon: Icons.collections_bookmark_outlined,
                title: 'Library',
                subtitle: 'Categories, global update interval, skip update rules, badges',
                tags: ['SERVER', 'LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LibrarySettingsScreen()),
                  );
                },
              ),

              // 3. DOWNLOADS
              _buildTile(
                icon: Icons.download_outlined,
                title: 'Downloads',
                subtitle: 'Server downloads directory, CBZ compression, limits, Wi-Fi rules',
                tags: ['SERVER', 'LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DownloadsSettingsScreen()),
                  );
                },
              ),

              // 4. BROWSE
              _buildTile(
                icon: Icons.explore_outlined,
                title: 'Browse',
                subtitle: 'NSFW sources, parallel scrapers concurrency, local paths, repos',
                tags: ['SERVER', 'LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BrowseSettingsScreen()),
                  );
                },
              ),

              // 5. BACKUP AND RESTORE
              _buildTile(
                icon: Icons.settings_backup_restore_rounded,
                title: 'Backup and Restore',
                subtitle: 'Manual and automatic Suwayomi backups, retention TTL schedule',
                tags: ['SERVER'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BackupSettingsScreen()),
                  );
                },
              ),

              // 6. READER
              _buildTile(
                icon: Icons.chrome_reader_mode_outlined,
                title: 'Reader',
                subtitle: 'Reading mode, navigation layout, volume keys, crop borders',
                tags: ['LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReaderSettingsScreen()),
                  );
                },
              ),

              // 7. APPEARANCE
              _buildTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme mode, pure black OLED, color palette, grid covers',
                tags: ['LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen()),
                  );
                },
              ),

              // 8. GENERAL & ADVANCED
              _buildTile(
                icon: Icons.tune_rounded,
                title: 'General',
                subtitle: 'App locale, cache management, network timeouts',
                tags: ['LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdvancedSettingsScreen()),
                  );
                },
              ),

              // 9. STATISTICS
              _buildTile(
                icon: Icons.insights_rounded,
                title: 'Statistics',
                subtitle: 'Reading history, reading time, genres & sources breakdown',
                tags: ['LOCAL'],
                onTap: () => context.push('/stats'),
              ),

              // 10. ADVANCED & DIAGNOSTICS
              _buildTile(
                icon: Icons.code_rounded,
                title: 'Advanced Diagnostics',
                subtitle: 'Diagnostic logs, engine status, system information',
                tags: ['LOCAL'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdvancedSettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
