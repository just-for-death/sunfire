import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

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
          title: 'Reader',
          body: ListView(
            children: [
              // ── 1. VIEWER & MODES ──
              const SectionTitle(title: 'Viewer & Modes'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.view_day_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Default Reading Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.readingMode, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Reading Mode',
                    options: const ['Long Strip', 'Long Strip (Gaps)', 'Paged LTR', 'Paged RTL (Manga)'],
                    currentValue: _settings.readingMode,
                    onSelected: (val) => _settings.readingMode = val,
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.palette_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Reader Background Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.readerTheme, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.filter_b_and_w_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Color Filter / Night Tint', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.colorFilter, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Color Filter',
                    options: const ['None', 'Invert Colors', 'Grayscale', 'Amber Tint', 'Sepia'],
                    currentValue: _settings.colorFilter,
                    onSelected: (val) => _settings.colorFilter = val,
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.aspect_ratio_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Default Image Scale', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.scaleType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Image Scale',
                    options: const ['Fit Width', 'Fit Height', 'Fit Screen', 'Original'],
                    currentValue: _settings.scaleType,
                    onSelected: (val) => _settings.scaleType = val,
                  );
                },
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 2. NAVIGATION & INTERACTION ──
              const SectionTitle(title: 'Navigation & Gestures'),
              SettingsPropTile(
                title: '3-Zone Tap Navigation',
                subtitle: 'Tap left/right sides to turn pages, middle for reader overlay',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.tapZonesEnabled,
                onBoolChanged: (val) => _settings.tapZonesEnabled = val,
              ),
              SettingsPropTile(
                title: 'Invert Tap Zones',
                subtitle: 'Swap previous and next page tap areas',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.invertTapZones,
                onBoolChanged: (val) => _settings.invertTapZones = val,
              ),
              SettingsPropTile(
                title: 'Crop White Borders',
                subtitle: 'Trim page whitespace margins automatically',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.cropBorders,
                onBoolChanged: (val) => _settings.cropBorders = val,
              ),
              SettingsPropTile(
                title: 'Volume Key Page Turn',
                subtitle: 'Use physical volume rocker keys to flip pages',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.volumeKeyTurn,
                onBoolChanged: (val) => _settings.volumeKeyTurn = val,
              ),
              SettingsPropTile(
                title: 'Seamless Chapter Transitions',
                subtitle: 'Show transition cards between consecutive chapters',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.seamlessTransitions,
                onBoolChanged: (val) => _settings.seamlessTransitions = val,
              ),
              SettingsPropTile(
                title: 'Keep Screen Awake',
                subtitle: 'Prevent device display from sleeping while reading',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.keepScreenAwake,
                onBoolChanged: (val) => _settings.keepScreenAwake = val,
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 3. AUTO-SCROLL (WEBTOON / LONG STRIP) ──
              const SectionTitle(title: 'Auto-Scroll (Webtoon & Long Strip)'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.speed_rounded),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Default Auto-Scroll Speed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(
                  '${_settings.defaultAutoScrollSpeed.round()} px/s',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Auto-Scroll Speed',
                    options: const [
                      'Slow (25 px/s)',
                      'Normal (50 px/s)',
                      'Fast (120 px/s)',
                      'Faster (250 px/s)',
                      'Turbo (450 px/s)',
                      'Hyper (750 px/s)',
                    ],
                    currentValue: _settings.defaultAutoScrollSpeed <= 30
                        ? 'Slow (25 px/s)'
                        : _settings.defaultAutoScrollSpeed <= 80
                            ? 'Normal (50 px/s)'
                            : _settings.defaultAutoScrollSpeed <= 180
                                ? 'Fast (120 px/s)'
                                : _settings.defaultAutoScrollSpeed <= 350
                                    ? 'Faster (250 px/s)'
                                    : _settings.defaultAutoScrollSpeed <= 600
                                        ? 'Turbo (450 px/s)'
                                        : 'Hyper (750 px/s)',
                    onSelected: (val) {
                      if (val.contains('25')) _settings.defaultAutoScrollSpeed = 25.0;
                      if (val.contains('50')) _settings.defaultAutoScrollSpeed = 50.0;
                      if (val.contains('120')) _settings.defaultAutoScrollSpeed = 120.0;
                      if (val.contains('250')) _settings.defaultAutoScrollSpeed = 250.0;
                      if (val.contains('450')) _settings.defaultAutoScrollSpeed = 450.0;
                      if (val.contains('750')) _settings.defaultAutoScrollSpeed = 750.0;
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text('10 px/s', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Expanded(
                      child: Slider(
                        value: _settings.defaultAutoScrollSpeed.clamp(10.0, 1000.0),
                        min: 10.0,
                        max: 1000.0,
                        divisions: 99,
                        label: '${_settings.defaultAutoScrollSpeed.round()} px/s',
                        onChanged: (val) => _settings.defaultAutoScrollSpeed = val,
                      ),
                    ),
                    const Text('1000 px/s', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
