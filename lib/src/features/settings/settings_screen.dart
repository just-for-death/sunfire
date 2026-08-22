import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'advanced_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'extension_repos_screen.dart';
import 'library_settings_screen.dart';
import 'reader_settings_screen.dart';
import 'server_settings_screen.dart';
import 'storage_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              // ── HIGHLIGHTED SUWAYOMI SERVER ADMIN BANNER ──────
              Material(
                color: primaryColor.withAlpha(38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: primaryColor, width: 1.2),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: Icon(Icons.cloud_sync_rounded, color: primaryColor, size: 30),
                  title: const Text('Suwayomi Server Admin & Trackers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: const Text('Server connection, MyAnimeList/AniList trackers & backups'),
                  trailing: Icon(Icons.chevron_right_rounded, color: primaryColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ServerSettingsScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Text('LOCAL APP PREFERENCES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),

              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: Column(
                  children: [
                    // 1. READER SETTINGS
                    ListTile(
                      leading: Icon(Icons.chrome_reader_mode_rounded, color: primaryColor),
                      title: const Text('Reader Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Reading mode, direction, tap zones, volume keys & crop'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReaderSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 2. APPEARANCE & THEMES
                    ListTile(
                      leading: Icon(Icons.palette_rounded, color: primaryColor),
                      title: const Text('Appearance & Themes', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Accent colors, OLED Pure Black, Material You dynamic color'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 3. LIBRARY & CATEGORIES
                    ListTile(
                      leading: Icon(Icons.collections_bookmark_rounded, color: primaryColor),
                      title: const Text('Library & Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Category sync, default category, unread badges'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LibrarySettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 4. DOWNLOADS & STORAGE
                    ListTile(
                      leading: Icon(Icons.downloading_rounded, color: primaryColor),
                      title: const Text('Download Manager', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Manage active local & server download queues'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () => context.push('/downloads'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 5. STATISTICS
                    ListTile(
                      leading: Icon(Icons.insights_rounded, color: primaryColor),
                      title: const Text('Statistics (Mihon)', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Read counts, reading time, genres & sources breakdown'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () => context.push('/stats'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 6. STORAGE & CACHE
                    ListTile(
                      leading: Icon(Icons.folder_zip_rounded, color: primaryColor),
                      title: const Text('Storage & Cache', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Auto-download, WiFi restrictions, auto-delete, clear cache'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StorageSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 7. EXTENSION REPOSITORIES
                    ListTile(
                      leading: Icon(Icons.extension_rounded, color: primaryColor),
                      title: const Text('Extension Repositories', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Register custom JS repos, auto-update sources'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExtensionReposScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 6. ADVANCED & DIAGNOSTICS
                    ListTile(
                      leading: Icon(Icons.bug_report_rounded, color: primaryColor),
                      title: const Text('Advanced & Diagnostics', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Diagnostic logs, clear logs, system info'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
            ],
          ),
        ),
      ),
    );
  }
}
