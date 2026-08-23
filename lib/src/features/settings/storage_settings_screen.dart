import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/image_cache_helper.dart';
import '../../core/services/settings_service.dart';
import '../../core/sync/graphql_client_service.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
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
        final primaryColor = Theme.of(context).colorScheme.primary;
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt, style: TextStyle(fontSize: 14, color: isSelected ? primaryColor : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primaryColor) : null,
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Downloads & Storage'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              Text('DOWNLOAD CONTROLS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.wifi_rounded, color: primaryColor),
                      title: const Text('Download Only On WiFi', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Pause auto-downloads when connected to cellular data'),
                      value: _settings.downloadOnlyOnWifi,
                      onChanged: (val) => _settings.downloadOnlyOnWifi = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.download_rounded, color: primaryColor),
                      title: const Text('Auto-Download Unread Chapters', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatically download next unread chapters on WiFi'),
                      value: _settings.autoDownloadEnabled,
                      onChanged: (val) => _settings.autoDownloadEnabled = val,
                    ),
                    if (_settings.autoDownloadEnabled)
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('Chapters to Download', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${_settings.autoDownloadCount} chapters'),
                        onTap: () {
                          _showRadioDialog(
                            title: 'Chapters to Auto-Download',
                            options: const ['1', '3', '5'],
                            currentValue: _settings.autoDownloadCount.toString(),
                            onSelected: (val) => _settings.autoDownloadCount = parseIntSafe(val, 1),
                          );
                        },
                      ),
                    SwitchListTile(
                      secondary: Icon(Icons.delete_sweep_rounded, color: primaryColor),
                      title: const Text('Auto-Delete Read Chapters', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Delete local download after finishing chapter'),
                      value: _settings.autoDeleteRead,
                      onChanged: (val) => _settings.autoDeleteRead = val,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('STORAGE MANAGEMENT', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1F2A2A32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.cleaning_services_rounded, color: primaryColor),
                      title: const Text('Clear Image Disk Cache', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Free cached cover thumbnails & manga page images'),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
