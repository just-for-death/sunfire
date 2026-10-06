import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/design_system/sunfire_theme.dart';
import '../../ui/shell/sunfire_breakpoints.dart';
import '../../ui/shell/tablet_ui_prefs.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  /// Dynamic colour is Android-only; tests can force the option on/off.
  @visibleForTesting
  static bool? debugShowDynamicOption;

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;

  bool get _showDynamicOption =>
      AppearanceSettingsScreen.debugShowDynamicOption ??
      (!kIsWeb && Platform.isAndroid);

  void _showRadioDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    unawaited(showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_settings, TabletUiPrefs.listenable]),
      builder: (context, _) {
        return SettingsSubpageScaffold(
          title: 'Appearance',
          body: ListView(
            padding: EdgeInsets.only(bottom: SunfireBreakpoints.scrollBottomPadding(context)),
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
                subtitle: Text(SunfireTheme.themeModeLabel(_settings.themeMode),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Theme Mode',
                    options: SunfireTheme.themeModeOptions,
                    currentValue: SunfireTheme.themeModeLabel(_settings.themeMode),
                    onSelected: (val) => _settings.themeMode = val,
                  );
                },
              ),
              // UIS-P2-C: Pure black is its own switch (works with Dark,
              // System and Dynamic colour; Light is unaffected).
              SettingsPropTile(
                key: const ValueKey('pure_black_toggle'),
                title: 'Pure black (AMOLED)',
                subtitle: 'Black background, surfaces and bars in dark mode',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.pureBlackEnabled,
                onBoolChanged: (val) => _settings.pureBlackEnabled = val,
              ),
              if (_showDynamicOption) ...[
                SettingsPropTile(
                  key: const ValueKey('dynamic_color_toggle'),
                  title: 'Dynamic colour (Material You)',
                  subtitle: 'Use your wallpaper colours (Android 12+). '
                      'Replaces the accent palette below.',
                  scope: SettingScope.local,
                  kind: SettingsPropKind.switchTile,
                  boolValue: _settings.materialYouEnabled,
                  onBoolChanged: (val) => _settings.materialYouEnabled = val,
                ),
              ],
              const Divider(height: 1),

              const SectionTitle(title: 'Accent Color Palette'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  _showDynamicOption && _settings.materialYouEnabled
                      ? 'Dynamic colour is on — accent applies when it is off '
                          'or unsupported'
                      : 'Current: ${_settings.accentColorName}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _settings.accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: SettingsService.accentColors.entries.map((entry) {
                    final isSelected = entry.key == _settings.accentColorName;
                    return Tooltip(
                      message: entry.key,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _settings.accentColorName = entry.key,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: entry.value.withValues(alpha: 0.55),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 1),
              const SectionTitle(title: 'Tablet Layout'),
              SettingsPropTile(
                title: 'Expanded Sidebar',
                subtitle: 'Show labels on the tablet navigation rail (iPad and Android)',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.tabletSidebarExpanded,
                onBoolChanged: (val) => _settings.tabletSidebarExpanded = val,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.tablet_mac_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Tablet UI mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(
                  '${TabletUiPrefs.mode} — rail vs bottom bar for large windows',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  _showRadioDialog(
                    title: 'Tablet UI mode',
                    options: SunfireBreakpoints.tabletUiModeOptions,
                    currentValue: TabletUiPrefs.mode,
                    onSelected: (val) => TabletUiPrefs.setMode(val),
                  );
                },
              ),
              // Date Format lives in General settings only (UIS-10).
            ],
          ),
        );
      },
    );
  }
}
