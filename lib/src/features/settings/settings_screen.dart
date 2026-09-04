import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/sunfire_badge.dart';
import 'advanced_settings_screen.dart';
import 'appearance_settings_screen.dart';
import 'backup_settings_screen.dart';
import 'browse_settings_screen.dart';
import 'downloads_settings_screen.dart';
import 'extension_repos_screen.dart';
import 'library_settings_screen.dart';
import 'reader_settings_screen.dart';
import 'server_settings_screen.dart';

class _SettingSearchItem {
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final List<String> keywords;
  final Widget Function(BuildContext) destination;

  const _SettingSearchItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.keywords,
    required this.destination,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final List<_SettingSearchItem> _searchRegistry = [
    // ── SERVER ──
    _SettingSearchItem(
      title: 'Server URL & Connection',
      subtitle: 'Configure target address of your Suwayomi server',
      category: 'Server',
      icon: Icons.dns_outlined,
      keywords: ['server', 'url', 'host', 'port', 'ip', 'suwayomi', 'remote'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Client Credentials (Basic Auth / Bearer)',
      subtitle: 'HTTP Basic username & password or reverse proxy token',
      category: 'Server',
      icon: Icons.key_rounded,
      keywords: ['auth', 'authentication', 'basic', 'username', 'password', 'token', 'bearer', 'credentials'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Server FlareSolverr Cloudflare Bypass',
      subtitle: 'Configure remote Suwayomi server FlareSolverr endpoint',
      category: 'Server',
      icon: Icons.shield_outlined,
      keywords: ['cloudflare', 'flaresolverr', 'proxy', 'turnstile', 'challenge', 'bypass', 'server', 'suwayomi'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'SOCKS Proxy Tunnel',
      subtitle: 'Route all server traffic through SOCKS proxy tunnel',
      category: 'Server',
      icon: Icons.vpn_lock_rounded,
      keywords: ['socks', 'proxy', 'tunnel', 'tor', 'privacy'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'OPDS Feeds',
      subtitle: 'OPDS feed items per page, unread filters, binary sizes',
      category: 'Server',
      icon: Icons.rss_feed_rounded,
      keywords: ['opds', 'feed', 'ereader', 'kobo', 'sync'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'SyncYomi Cloud Sync',
      subtitle: 'Sync reading progress across multi-device Suwayomi instances',
      category: 'Server',
      icon: Icons.cloud_sync_rounded,
      keywords: ['syncyomi', 'sync', 'cloud', 'backup'],
      destination: (context) => const ServerSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'WebUI & System Tray',
      subtitle: 'Suwayomi browser interface flavor and desktop system tray',
      category: 'Server',
      icon: Icons.web_rounded,
      keywords: ['webui', 'browser', 'tray', 'desktop', 'interface'],
      destination: (context) => const ServerSettingsScreen(),
    ),

    // ── LIBRARY ──
    _SettingSearchItem(
      title: 'Library Categories & Badges',
      subtitle: 'Organize manga in custom categories and unread count badges',
      category: 'Library',
      icon: Icons.collections_bookmark_outlined,
      keywords: ['categories', 'tags', 'library', 'folders', 'badges', 'unread'],
      destination: (context) => const LibrarySettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Global Library Update Interval',
      subtitle: 'Automatic background update frequency for library titles',
      category: 'Library',
      icon: Icons.update_rounded,
      keywords: ['update', 'refresh', 'interval', 'schedule', 'cron', 'automatic'],
      destination: (context) => const LibrarySettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Skip Update Rules',
      subtitle: 'Exclude completed titles, unread entries, or unstarted manga',
      category: 'Library',
      icon: Icons.filter_alt_outlined,
      keywords: ['skip', 'exclude', 'completed', 'unread', 'filter', 'rules'],
      destination: (context) => const LibrarySettingsScreen(),
    ),

    // ── DOWNLOADS ──
    _SettingSearchItem(
      title: 'Download as CBZ Archive',
      subtitle: 'Save downloaded chapters as standard Comic Book Zip files',
      category: 'Downloads',
      icon: Icons.archive_outlined,
      keywords: ['cbz', 'zip', 'archive', 'comic book', 'format', 'compression'],
      destination: (context) => const DownloadsSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Downloads Directory Path',
      subtitle: 'Storage location on disk for offline downloaded chapters',
      category: 'Downloads',
      icon: Icons.folder_open_rounded,
      keywords: ['path', 'directory', 'folder', 'storage', 'disk', 'save'],
      destination: (context) => const DownloadsSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Auto-Download New Chapters',
      subtitle: 'Automatically download new chapters when updates are found',
      category: 'Downloads',
      icon: Icons.download_for_offline_outlined,
      keywords: ['auto', 'automatic', 'download', 'new chapters', 'limit'],
      destination: (context) => const DownloadsSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Wi-Fi Only Downloads',
      subtitle: 'Restrict chapter downloads to Wi-Fi to preserve mobile data',
      category: 'Downloads',
      icon: Icons.wifi_rounded,
      keywords: ['wifi', 'cellular', 'mobile data', 'network', 'offline'],
      destination: (context) => const DownloadsSettingsScreen(),
    ),

    // ── BROWSE ──
    _SettingSearchItem(
      title: 'Show NSFW Sources',
      subtitle: 'Display 18+ and adult extensions in browse feeds',
      category: 'Browse',
      icon: Icons.explicit_rounded,
      keywords: ['nsfw', '18+', 'adult', 'hentai', 'filter', 'mature'],
      destination: (context) => const BrowseSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Extension Repositories',
      subtitle: 'Add community MangaYomi JSON repository links for scrapers',
      category: 'Browse',
      icon: Icons.hub_rounded,
      keywords: ['extension', 'repo', 'repository', 'mangayomi', 'scrapers', 'js', 'plugins'],
      destination: (context) => const ExtensionReposScreen(),
    ),
    _SettingSearchItem(
      title: 'Parallel Scrapers Concurrency',
      subtitle: 'Number of simultaneous workers for faster source queries',
      category: 'Browse',
      icon: Icons.speed_rounded,
      keywords: ['workers', 'parallel', 'concurrency', 'threads', 'speed'],
      destination: (context) => const BrowseSettingsScreen(),
    ),

    // ── BACKUP ──
    _SettingSearchItem(
      title: 'Create Suwayomi Backup',
      subtitle: 'Generate full JSON backup of library, history & categories',
      category: 'Backup',
      icon: Icons.backup_rounded,
      keywords: ['backup', 'export', 'save', 'json', 'data'],
      destination: (context) => const BackupSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Restore Backup File',
      subtitle: 'Import a previously exported Suwayomi backup file',
      category: 'Backup',
      icon: Icons.settings_backup_restore_rounded,
      keywords: ['restore', 'import', 'load', 'recovery'],
      destination: (context) => const BackupSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Automatic Scheduled Backups',
      subtitle: 'Configure automated backup intervals and file retention TTL',
      category: 'Backup',
      icon: Icons.schedule_rounded,
      keywords: ['schedule', 'auto', 'automatic', 'ttl', 'retention', 'interval'],
      destination: (context) => const BackupSettingsScreen(),
    ),

    // ── READER ──
    _SettingSearchItem(
      title: 'Reading Mode (Webtoon / LTR / RTL)',
      subtitle: 'Continuous vertical strip, single page, or horizontal paginated',
      category: 'Reader',
      icon: Icons.chrome_reader_mode_outlined,
      keywords: ['mode', 'webtoon', 'paged', 'vertical', 'horizontal', 'rtl', 'ltr', 'manga', 'manhwa'],
      destination: (context) => const ReaderSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Reader Navigation & Tap Zones',
      subtitle: 'Configure tap zones, volume key paging, and inverted touches',
      category: 'Reader',
      icon: Icons.touch_app_rounded,
      keywords: ['tap', 'zones', 'touch', 'gestures', 'volume', 'invert', 'navigation'],
      destination: (context) => const ReaderSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Crop Image Borders',
      subtitle: 'Automatically remove white borders from scanned pages',
      category: 'Reader',
      icon: Icons.crop_rounded,
      keywords: ['crop', 'borders', 'margins', 'whitespace', 'trim'],
      destination: (context) => const ReaderSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Invert Page Colors',
      subtitle: 'Invert black and white manga pages for comfortable night reading',
      category: 'Reader',
      icon: Icons.invert_colors_rounded,
      keywords: ['invert', 'color', 'night', 'dark', 'black', 'contrast'],
      destination: (context) => const ReaderSettingsScreen(),
    ),

    // ── APPEARANCE ──
    _SettingSearchItem(
      title: 'Theme Mode (System / Light / Dark)',
      subtitle: 'Switch between dark theme, light theme, or pure black OLED',
      category: 'Appearance',
      icon: Icons.dark_mode_outlined,
      keywords: ['theme', 'dark', 'light', 'oled', 'black', 'amoled', 'mode'],
      destination: (context) => const AppearanceSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Accent Color Palette',
      subtitle: 'Sunfire Orange, Catppuccin Blue, Emerald Green, Amethyst Purple',
      category: 'Appearance',
      icon: Icons.palette_outlined,
      keywords: ['accent', 'color', 'orange', 'blue', 'green', 'purple', 'palette'],
      destination: (context) => const AppearanceSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Tablet Sidebar Layout',
      subtitle: 'Configure responsive side navigation rail for iPad and tablets',
      category: 'Appearance',
      icon: Icons.tablet_rounded,
      keywords: ['tablet', 'ipad', 'sidebar', 'rail', 'navigation', 'layout'],
      destination: (context) => const AppearanceSettingsScreen(),
    ),

    // ── ADVANCED ──
    _SettingSearchItem(
      title: 'Local FlareSolverr (App Cloudflare Bypass)',
      subtitle: 'Bypass Cloudflare Turnstile for ReadComicOnline & local extensions',
      category: 'Advanced',
      icon: Icons.shield_outlined,
      keywords: ['cloudflare', 'flaresolverr', 'proxy', 'turnstile', 'challenge', 'bypass', 'local', 'readcomiconline', 'mangago'],
      destination: (context) => const AdvancedSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Live Diagnostic Console',
      subtitle: 'Stream real-time app events, JS scrapers, network & errors',
      category: 'Advanced',
      icon: Icons.terminal_rounded,
      keywords: ['console', 'logs', 'diagnostic', 'terminal', 'telemetry', 'debug'],
      destination: (context) => const AdvancedSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Clear Image Disk Cache',
      subtitle: 'Free cached cover thumbnails and downloaded manga page images',
      category: 'Advanced',
      icon: Icons.delete_sweep_rounded,
      keywords: ['cache', 'clear', 'storage', 'disk', 'memory', 'free', 'clean'],
      destination: (context) => const AdvancedSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Database Statistics (Isar)',
      subtitle: 'Cached manga entries, offline chapters, and categories count',
      category: 'Advanced',
      icon: Icons.storage_rounded,
      keywords: ['isar', 'database', 'stats', 'manga count', 'storage', 'metrics'],
      destination: (context) => const AdvancedSettingsScreen(),
    ),
    _SettingSearchItem(
      title: 'Sunfire Client Version',
      subtitle: 'Installed app version, build number, and host platform details',
      category: 'Advanced',
      icon: Icons.info_outline_rounded,
      keywords: ['version', 'build', 'about', 'platform', 'os', 'info'],
      destination: (context) => const AdvancedSettingsScreen(),
    ),
  ];

  List<_SettingSearchItem> get _filteredSettings {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _searchRegistry.where((item) {
      if (item.title.toLowerCase().contains(query)) return true;
      if (item.subtitle.toLowerCase().contains(query)) return true;
      if (item.category.toLowerCase().contains(query)) return true;
      return item.keywords.any((k) => k.toLowerCase().contains(query));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isTablet ? 64.0 : kToolbarHeight,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search settings, proxy, auth...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search settings',
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _isSearching && _searchQuery.trim().isNotEmpty
              ? _buildSearchResults(primaryColor)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    // 1. SERVER (PRIMARY)
                    _buildTile(
                      icon: Icons.dns_outlined,
                      title: 'Server',
                      subtitle: 'Connection, bindings, SOCKS proxy, FlareSolverr (Server & Local), OPDS, SyncYomi',
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
                      subtitle: 'NSFW sources, extension repos, local FlareSolverr, scrapers concurrency',
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
                      subtitle: 'Diagnostic logs, FlareSolverr proxy, system information',
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

  Widget _buildSearchResults(Color primaryColor) {
    final results = _filteredSettings;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.withAlpha(120)),
            const SizedBox(height: 12),
            Text('No settings found for "$_searchQuery"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Try searching for proxy, auth, download, or theme', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120, top: 8),
      itemCount: results.length,
      itemBuilder: (context, idx) {
        final item = results[idx];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: primaryColor, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SunfireBadge(
                label: item.category.toUpperCase(),
                color: Colors.white60,
                fontSize: 9.0,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          subtitle: Text(
            item.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: item.destination),
            );
          },
        );
      },
    );
  }
}
