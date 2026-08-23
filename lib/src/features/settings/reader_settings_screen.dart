import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/settings_service.dart';

class ReaderSettingsScreen extends StatefulWidget {
  const ReaderSettingsScreen({super.key});

  @override
  State<ReaderSettingsScreen> createState() => _ReaderSettingsScreenState();
}

class _ReaderSettingsScreenState extends State<ReaderSettingsScreen> {
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
            title: const Text('Reader Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
            children: [
              Text('VIEWER & MODES', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                      leading: Icon(Icons.view_day_rounded, color: primaryColor),
                      title: const Text('Default Reading Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.readingMode),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Default Reading Mode',
                          options: const ['Webtoon', 'Continuous Vertical', 'Paged LTR', 'Paged RTL (Manga)'],
                          currentValue: _settings.readingMode,
                          onSelected: (val) => _settings.readingMode = val,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.palette_outlined, color: primaryColor),
                      title: const Text('Reader Background Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.readerTheme),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Background Theme',
                          options: const ['Black', 'Dark Gray', 'White'],
                          currentValue: _settings.readerTheme,
                          onSelected: (val) => _settings.readerTheme = val,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.filter_b_and_w_rounded, color: primaryColor),
                      title: const Text('Color Filter / Night Tint', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.colorFilter),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Color Filter',
                          options: const ['None', 'Invert Colors', 'Grayscale', 'Amber Tint'],
                          currentValue: _settings.colorFilter,
                          onSelected: (val) => _settings.colorFilter = val,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.aspect_ratio_rounded, color: primaryColor),
                      title: const Text('Default Image Scale', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.scaleType),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Default Image Scale',
                          options: const ['Fit Width', 'Fit Height', 'Fit Screen', 'Original'],
                          currentValue: _settings.scaleType,
                          onSelected: (val) => _settings.scaleType = val,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('NAVIGATION & INTERACTION', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                      secondary: Icon(Icons.touch_app_rounded, color: primaryColor),
                      title: const Text('3-Zone Tap Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tap left/right sides to turn pages, middle for menu'),
                      value: _settings.tapZonesEnabled,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => _settings.tapZonesEnabled = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.swap_horiz_rounded, color: primaryColor),
                      title: const Text('Invert Tap Zones', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Swap previous and next page tap areas'),
                      value: _settings.invertTapZones,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => _settings.invertTapZones = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.crop_free_rounded, color: primaryColor),
                      title: const Text('Crop White Borders', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Trim page whitespace margins automatically'),
                      value: _settings.cropBorders,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => _settings.cropBorders = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.volume_up_rounded, color: primaryColor),
                      title: const Text('Volume Key Page Turn', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Use hardware volume keys to flip pages on Android/Linux'),
                      value: _settings.volumeKeyTurn,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => _settings.volumeKeyTurn = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.auto_stories_rounded, color: primaryColor),
                      title: const Text('Seamless Chapter Transitions', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Show next chapter transition preview card at end of chapters'),
                      value: _settings.seamlessTransitions,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => _settings.seamlessTransitions = val,
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
