import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'advanced_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'extension_repos_screen.dart';
import 'library_settings_screen.dart';
import 'reader_settings_screen.dart';
import 'server_settings_screen.dart';
import 'storage_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _buildLeadingIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: MediaQuery.of(context).size.width >= 720 ? 36.0 : 120.0),
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
                      leading: _buildLeadingIcon(Icons.chrome_reader_mode_rounded, Colors.purpleAccent),
                      title: const Text('Reader Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Reading mode, direction, tap zones, volume keys & crop', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReaderSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 2. APPEARANCE & THEMES
                    ListTile(
                      leading: _buildLeadingIcon(Icons.palette_rounded, Colors.pinkAccent),
                      title: const Text('Appearance & Themes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Accent colors, OLED Pure Black, Material You dynamic color', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppearanceSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 3. LIBRARY & CATEGORIES
                    ListTile(
                      leading: _buildLeadingIcon(Icons.collections_bookmark_rounded, Colors.cyanAccent),
                      title: const Text('Library & Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Category sync, default category, unread badges', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LibrarySettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 4. DOWNLOADS & STORAGE
                    ListTile(
                      leading: _buildLeadingIcon(Icons.downloading_rounded, Colors.greenAccent),
                      title: const Text('Download Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Manage active local & server download queues', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () => context.push('/downloads'),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 5. STATISTICS
                    ListTile(
                      leading: _buildLeadingIcon(Icons.insights_rounded, Colors.amberAccent),
                      title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Read counts, reading time, genres & sources breakdown', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () => context.push('/stats'),
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 6. STORAGE & CACHE
                    ListTile(
                      leading: _buildLeadingIcon(Icons.folder_zip_rounded, Colors.orangeAccent),
                      title: const Text('Storage & Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Auto-download, WiFi restrictions, auto-delete, clear cache', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StorageSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 7. EXTENSION REPOSITORIES
                    ListTile(
                      leading: _buildLeadingIcon(Icons.extension_rounded, Colors.lightBlueAccent),
                      title: const Text('Extension Repositories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Register custom JS repos, auto-update sources', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExtensionReposScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0x1AFFFFFF)),

                    // 8. ADVANCED & DIAGNOSTICS
                    ListTile(
                      leading: _buildLeadingIcon(Icons.bug_report_rounded, Colors.redAccent),
                      title: const Text('Advanced & Diagnostics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Diagnostic logs, clear logs, system info', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
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
