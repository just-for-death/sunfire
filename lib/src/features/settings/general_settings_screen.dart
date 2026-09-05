import 'package:flutter/material.dart';

import '../../core/engine/quickjs_service.dart';
import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;

  void _showRadioDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt),
                trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.greenAccent) : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return SettingsSubpageScaffold(
          title: 'General',
          body: ListView(
            children: [
              // ── 1. DISPLAY & LOCALE ──
              const SectionTitle(title: 'Display & Locale'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.language_rounded),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('App Language', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(
                  _settings.appLocale == 'en' ? 'English' : _settings.appLocale,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  _showRadioDialog(
                    title: 'App Language',
                    options: const ['System Default', 'English', 'Spanish', 'French', 'German', 'Japanese'],
                    currentValue: _settings.appLocale == 'en' ? 'English' : _settings.appLocale,
                    onSelected: (val) {
                      _settings.appLocale = val == 'System Default' ? 'en' : val.toLowerCase().substring(0, 2);
                    },
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.calendar_today_rounded),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Date Format', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.dateFormat, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Date Format',
                    options: const ['YYYY-MM-DD', 'MM/DD/YYYY', 'DD/MM/YYYY', 'DD.MM.YYYY'],
                    currentValue: _settings.dateFormat,
                    onSelected: (val) => _settings.dateFormat = val,
                  );
                },
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 2. LAUNCH & NAVIGATION ──
              const SectionTitle(title: 'Launch & Navigation'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.home_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Start Screen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.startScreen, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Start Screen',
                    options: const ['Library', 'Updates', 'History', 'Browse'],
                    currentValue: _settings.startScreen,
                    onSelected: (val) => _settings.startScreen = val,
                  );
                },
              ),
              SettingsPropTile(
                title: 'Confirm Exit',
                subtitle: 'Show confirmation prompt when exiting the application',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.confirmExit,
                onBoolChanged: (val) => _settings.confirmExit = val,
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 3. PRIVACY & SECURITY ──
              const SectionTitle(title: 'Privacy & Security'),
              SettingsPropTile(
                title: 'Incognito Mode',
                subtitle: 'Pause reading history recording and suppress unread progress updates',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.incognitoMode,
                onBoolChanged: (val) => _settings.incognitoMode = val,
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 4. NETWORK & CONNECTION ──
              const SectionTitle(title: 'Network & Timeouts'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.timer_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Network Timeout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text('${_settings.networkTimeoutSeconds} seconds', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Network Request Timeout',
                    options: const ['15 seconds', '30 seconds', '45 seconds', '60 seconds'],
                    currentValue: '${_settings.networkTimeoutSeconds} seconds',
                    onSelected: (val) {
                      final sec = int.tryParse(val.split(' ').first) ?? 30;
                      _settings.networkTimeoutSeconds = sec;
                    },
                  );
                },
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 5. CACHE MANAGEMENT ──
              const SectionTitle(title: 'Cache & Storage'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orangeAccent),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Clear Image Disk Cache', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: const Text('Purge cached cover thumbnails and page images', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () async {
                  await ImageCacheHelper.clearCache();
                  imageCache.clear();
                  imageCache.clearLiveImages();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image disk & memory cache cleared!')),
                    );
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.cleaning_services_rounded, color: Colors.amberAccent),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Clear Extension Headers Cache', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: const Text('Reset in-memory extension headers and referrer caches', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  QuickJsService.clearHeadersCache();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Extension headers cache cleared!')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
