import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/settings_service.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
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
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt, style: TextStyle(fontSize: 14, color: isSelected ? theme.colorScheme.primary : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Appearance & Themes'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              Text('ACCENT COLOR PALETTE', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                      leading: Icon(Icons.color_lens_rounded, color: primaryColor),
                      title: const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.accentColorName),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Select Accent Color',
                          options: SettingsService.accentColors.keys.toList(),
                          currentValue: _settings.accentColorName,
                          onSelected: (val) => _settings.accentColorName = val,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: SettingsService.accentColors.entries.map((entry) {
                          final isSelected = entry.key == _settings.accentColorName;
                          return GestureDetector(
                            onTap: () => _settings.accentColorName = entry.key,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                              ),
                              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('THEMES & MATERIAL YOU', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                      leading: Icon(Icons.palette_rounded, color: primaryColor),
                      title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.themeMode),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Theme Mode',
                          options: const ['OLED Black', 'Dark Theme', 'System Default'],
                          currentValue: _settings.themeMode,
                          onSelected: (val) => _settings.themeMode = val,
                        );
                      },
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.android_rounded, color: primaryColor),
                      title: const Text('Android Material You (Dynamic Color)', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Extract accent color dynamically from Android wallpaper'),
                      value: _settings.materialYouEnabled,
                      onChanged: (val) => _settings.materialYouEnabled = val,
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_month_rounded, color: primaryColor),
                      title: const Text('Date Format', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.dateFormat),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Date Format',
                          options: const ['YYYY-MM-DD', 'DD/MM/YYYY', 'MM/DD/YYYY'],
                          currentValue: _settings.dateFormat,
                          onSelected: (val) => _settings.dateFormat = val,
                        );
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
