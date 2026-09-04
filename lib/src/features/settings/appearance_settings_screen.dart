import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

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
          title: 'Appearance',
          body: ListView(
            children: [
              const SectionTitle(title: 'Theme & Palette'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.palette_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Theme Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.themeMode, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Theme Mode',
                    options: const ['OLED Black', 'Dark Theme', 'System Default'],
                    currentValue: _settings.themeMode,
                    onSelected: (val) => _settings.themeMode = val,
                  );
                },
              ),
              SettingsPropTile(
                title: 'Material You Dynamic Color',
                subtitle: 'Extract theme accent colors from OS wallpaper (Android)',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.materialYouEnabled,
                onBoolChanged: (val) => _settings.materialYouEnabled = val,
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              const SectionTitle(title: 'Accent Color Palette'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: SettingsService.accentColors.entries.map((entry) {
                    final isSelected = entry.key == _settings.accentColorName;
                    return GestureDetector(
                      onTap: () => _settings.accentColorName = entry.key,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: entry.value,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 22) : null,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),
              const SectionTitle(title: 'Date & Time Formatting'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.calendar_month_outlined),
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
                    options: const ['YYYY-MM-DD', 'DD/MM/YYYY', 'MM/DD/YYYY'],
                    currentValue: _settings.dateFormat,
                    onSelected: (val) => _settings.dateFormat = val,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
