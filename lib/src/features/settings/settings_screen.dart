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

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              // 1. GENERAL
              _buildTile(
                icon: Icons.tune_rounded,
                title: 'General',
                subtitle: 'App locale, cache management, network timeouts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdvancedSettingsScreen()),
                  );
                },
              ),

              // 2. APPEARANCE
              _buildTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme mode, pure black OLED, color palette, grid covers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen()),
                  );
                },
              ),

              // 3. LIBRARY
              _buildTile(
                icon: Icons.collections_bookmark_outlined,
                title: 'Library',
                subtitle: 'Categories, global update interval, skip updating rules',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LibrarySettingsScreen()),
                  );
                },
              ),

              // 4. READER
              _buildTile(
                icon: Icons.chrome_reader_mode_outlined,
                title: 'Reader',
                subtitle: 'Reading mode, navigation layout, volume keys, crop borders',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReaderSettingsScreen()),
                  );
                },
              ),

              // 5. DOWNLOADS
              _buildTile(
                icon: Icons.download_outlined,
                title: 'Downloads',
                subtitle: 'Storage location, save as CBZ, auto-download limits',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DownloadsSettingsScreen()),
                  );
                },
              ),

              // 6. BROWSE
              _buildTile(
                icon: Icons.explore_outlined,
                title: 'Browse',
                subtitle: 'NSFW sources, parallel scrapers, extension repositories',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BrowseSettingsScreen()),
                  );
                },
              ),

              // 7. BACKUP AND RESTORE
              _buildTile(
                icon: Icons.settings_backup_restore_rounded,
                title: 'Backup and Restore',
                subtitle: 'Manual and automatic Suwayomi backups, retention schedule',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BackupSettingsScreen()),
                  );
                },
              ),

              // 8. SERVER
              _buildTile(
                icon: Icons.dns_outlined,
                title: 'Server',
                subtitle: 'Client target, WebUI, server binding, SOCKS proxy, FlareSolverr',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServerSettingsScreen()),
                  );
                },
              ),

              // 9. STATISTICS
              _buildTile(
                icon: Icons.insights_rounded,
                title: 'Statistics',
                subtitle: 'Reading history, reading time, genres & sources breakdown',
                onTap: () => context.push('/stats'),
              ),

              // 10. ADVANCED & ABOUT
              _buildTile(
                icon: Icons.code_rounded,
                title: 'Advanced',
                subtitle: 'Diagnostic logs, engine status, system information',
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
