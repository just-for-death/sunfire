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
              Text('READING CONTROLS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                          options: const ['Webtoon', 'Single Page', 'Double Page'],
                          currentValue: _settings.readingMode,
                          onSelected: (val) => _settings.readingMode = val,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.swap_horiz_rounded, color: primaryColor),
                      title: const Text('Reading Direction', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_settings.readingDirection),
                      onTap: () {
                        _showRadioDialog(
                          title: 'Reading Direction',
                          options: const ['Vertical', 'RTL (Right to Left)', 'LTR (Left to Right)'],
                          currentValue: _settings.readingDirection,
                          onSelected: (val) => _settings.readingDirection = val,
                        );
                      },
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.touch_app_rounded, color: primaryColor),
                      title: const Text('Enable Page Tap Zones', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Tap left/right edges to turn pages'),
                      value: _settings.tapZonesEnabled,
                      onChanged: (val) => _settings.tapZonesEnabled = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.volume_up_rounded, color: primaryColor),
                      title: const Text('Volume Keys Page Turn', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Use hardware volume keys to navigate'),
                      value: _settings.volumeKeyTurn,
                      onChanged: (val) => _settings.volumeKeyTurn = val,
                    ),
                    SwitchListTile(
                      secondary: Icon(Icons.crop_rounded, color: primaryColor),
                      title: const Text('Crop Image Borders', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Auto-trim white padding on manga pages'),
                      value: _settings.cropBorders,
                      onChanged: (val) => _settings.cropBorders = val,
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
