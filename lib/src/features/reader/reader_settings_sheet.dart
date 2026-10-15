// R1.8: reader settings bottom sheet extracted from reader_screen.
import 'package:flutter/material.dart';

import '../../core/services/settings_service.dart';
import '../../ui/design_system/tokens/sunfire_colors.dart';
import '../../ui/design_system/tokens/sunfire_spacing.dart';
import 'controller/reader_theme.dart';
import 'double_page_layout.dart';
import 'reader_settings_scope.dart';
import 'reading_mode.dart';
import 'tap_zones.dart';

/// Mutable view of reader presentation settings for the sheet UI.
class ReaderSettingsSheetModel {
  ReaderSettingsSheetModel({
    required this.settings,
    required this.hasParentManga,
    required this.scope,
    required this.readingMode,
    required this.readerTheme,
    required this.colorFilter,
    required this.scaleType,
    required this.invertTaps,
    required this.cropBorders,
    required this.onScopeChanged,
    required this.onApplyReadingMode,
    required this.onThemeChanged,
    required this.onColorFilterChanged,
    required this.onScaleTypeChanged,
    required this.onInvertTapsChanged,
    required this.onCropBordersChanged,
    required this.onKeepScreenAwakeChanged,
  });

  final SettingsService settings;
  final bool hasParentManga;
  ReaderSettingsScope scope;
  ReadingMode readingMode;
  ReaderThemeMode readerTheme;
  ReaderColorFilter colorFilter;
  ImageScaleType scaleType;
  bool invertTaps;
  bool cropBorders;

  final ValueChanged<ReaderSettingsScope> onScopeChanged;
  final ValueChanged<ReadingMode> onApplyReadingMode;
  final ValueChanged<ReaderThemeMode> onThemeChanged;
  final ValueChanged<ReaderColorFilter> onColorFilterChanged;
  final ValueChanged<ImageScaleType> onScaleTypeChanged;
  final ValueChanged<bool> onInvertTapsChanged;
  final ValueChanged<bool> onCropBordersChanged;
  final ValueChanged<bool> onKeepScreenAwakeChanged;
}

/// Modal reader settings sheet.
class ReaderSettingsSheet {
  ReaderSettingsSheet._();

  static Future<void> show({
    required BuildContext context,
    required ReaderSettingsSheetModel model,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: SunfireColors.surface2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SunfireRadius.sheet)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void touch(VoidCallback fn) {
              fn();
              setSheetState(() {});
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: SunfireColors.contentSecondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: SunfireSpacing.lg),
                    const Text(
                      'Reader Settings',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: SunfireSpacing.md),
                    if (model.hasParentManga) ...[
                      SegmentedButton<ReaderSettingsScope>(
                        segments: const [
                          ButtonSegment(
                            value: ReaderSettingsScope.manga,
                            label: Text('This series'),
                            icon: Icon(Icons.menu_book_rounded, size: SunfireIconSize.sm),
                          ),
                          ButtonSegment(
                            value: ReaderSettingsScope.global,
                            label: Text('All'),
                            icon: Icon(Icons.public_rounded, size: SunfireIconSize.sm),
                          ),
                        ],
                        selected: {model.scope},
                        onSelectionChanged: (sel) {
                          touch(() {
                            model.scope = sel.first;
                            model.onScopeChanged(sel.first);
                          });
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SunfireColors.contentPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SunfireSpacing.sm),
                      Text(
                        model.scope == ReaderSettingsScope.manga
                            ? 'Mode, scale, crop and tap zones apply to this series only'
                            : 'Mode, scale, crop and tap zones apply to all series',
                        style: TextStyle(fontSize: 11, color: SunfireColors.contentTertiary),
                      ),
                      const SizedBox(height: SunfireSpacing.lg),
                    ] else
                      const SizedBox(height: SunfireSpacing.sm),
                    _sectionHeader('READING MODE'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final mode in ReadingMode.values)
                          _filterChip(
                            readingModeSettingsValue(mode),
                            model.readingMode == mode,
                            () => touch(() {
                              model.readingMode = mode;
                              model.onApplyReadingMode(mode);
                            }),
                            primaryColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader('BACKGROUND COLOR'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _filterChip(
                          'OLED Black',
                          model.readerTheme == ReaderThemeMode.black,
                          () => touch(() {
                            model.readerTheme = ReaderThemeMode.black;
                            model.onThemeChanged(ReaderThemeMode.black);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Dark Slate',
                          model.readerTheme == ReaderThemeMode.darkGray,
                          () => touch(() {
                            model.readerTheme = ReaderThemeMode.darkGray;
                            model.onThemeChanged(ReaderThemeMode.darkGray);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Paper White',
                          model.readerTheme == ReaderThemeMode.white,
                          () => touch(() {
                            model.readerTheme = ReaderThemeMode.white;
                            model.onThemeChanged(ReaderThemeMode.white);
                          }),
                          primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader('COLOR FILTER / NIGHT MODE'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _filterChip(
                          'None',
                          model.colorFilter == ReaderColorFilter.none,
                          () => touch(() {
                            model.colorFilter = ReaderColorFilter.none;
                            model.onColorFilterChanged(ReaderColorFilter.none);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Invert Colors',
                          model.colorFilter == ReaderColorFilter.invert,
                          () => touch(() {
                            model.colorFilter = ReaderColorFilter.invert;
                            model
                                .onColorFilterChanged(ReaderColorFilter.invert);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Grayscale',
                          model.colorFilter == ReaderColorFilter.grayscale,
                          () => touch(() {
                            model.colorFilter = ReaderColorFilter.grayscale;
                            model.onColorFilterChanged(
                                ReaderColorFilter.grayscale);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Amber Night',
                          model.colorFilter == ReaderColorFilter.nightAmber,
                          () => touch(() {
                            model.colorFilter = ReaderColorFilter.nightAmber;
                            model.onColorFilterChanged(
                                ReaderColorFilter.nightAmber);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Sepia',
                          model.colorFilter == ReaderColorFilter.sepia,
                          () => touch(() {
                            model.colorFilter = ReaderColorFilter.sepia;
                            model
                                .onColorFilterChanged(ReaderColorFilter.sepia);
                          }),
                          primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader('SCALE TYPE'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _filterChip(
                          'Fit Width',
                          model.scaleType == ImageScaleType.fitWidth,
                          () => touch(() {
                            model.scaleType = ImageScaleType.fitWidth;
                            model.onScaleTypeChanged(ImageScaleType.fitWidth);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Fit Height',
                          model.scaleType == ImageScaleType.fitHeight,
                          () => touch(() {
                            model.scaleType = ImageScaleType.fitHeight;
                            model.onScaleTypeChanged(ImageScaleType.fitHeight);
                          }),
                          primaryColor,
                        ),
                        _filterChip(
                          'Fit Screen',
                          model.scaleType == ImageScaleType.fitScreen,
                          () => touch(() {
                            model.scaleType = ImageScaleType.fitScreen;
                            model.onScaleTypeChanged(ImageScaleType.fitScreen);
                          }),
                          primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionHeader('NAVIGATION & GESTURES'),
                    SwitchListTile(
                      title: const Text('3-Zone Tap Navigation'),
                      subtitle:
                          const Text('Tap left/right edges to turn pages'),
                      value: model.settings.tapZonesEnabled,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(
                          () => model.settings.tapZonesEnabled = val),
                    ),
                    SwitchListTile(
                      title: const Text('Invert Tap Zones'),
                      subtitle: const Text(
                          'Swap previous and next page tap areas'),
                      value: model.invertTaps,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(() {
                        model.invertTaps = val;
                        model.onInvertTapsChanged(val);
                      }),
                    ),
                    ListTile(
                      title: const Text('Tap Zones (Paged)'),
                      subtitle: Text(model.settings.tapZonePresetPaged),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: SunfireColors.contentSecondary),
                      onTap: () async {
                        final choice = await showDialog<String>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Tap Zones (Paged)'),
                            children: [
                              for (final p in TapZonePreset.values)
                                SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(ctx, p.settingsLabel),
                                  child: Text(p.settingsLabel),
                                ),
                            ],
                          ),
                        );
                        if (choice != null) {
                          touch(() =>
                              model.settings.tapZonePresetPaged = choice);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Tap Zones (Webtoon)'),
                      subtitle: Text(model.settings.tapZonePresetWebtoon),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: SunfireColors.contentSecondary),
                      onTap: () async {
                        final choice = await showDialog<String>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Tap Zones (Webtoon)'),
                            children: [
                              for (final p in TapZonePreset.values)
                                SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(ctx, p.settingsLabel),
                                  child: Text(p.settingsLabel),
                                ),
                            ],
                          ),
                        );
                        if (choice != null) {
                          touch(() =>
                              model.settings.tapZonePresetWebtoon = choice);
                        }
                      },
                    ),
                    _sectionHeader('DOUBLE-PAGE SPREADS'),
                    ListTile(
                      title: const Text('Display Mode'),
                      subtitle: Text(model.settings.doublePageDisplayMode),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: SunfireColors.contentSecondary),
                      onTap: () async {
                        final choice = await showDialog<String>(
                          context: context,
                          builder: (ctx) => SimpleDialog(
                            title: const Text('Double-Page Display'),
                            children: [
                              for (final m in DoublePageDisplayMode.values)
                                SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(ctx, m.settingsLabel),
                                  child: Text(m.settingsLabel),
                                ),
                            ],
                          ),
                        );
                        if (choice != null) {
                          touch(() =>
                              model.settings.doublePageDisplayMode = choice);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Page Offset'),
                      subtitle:
                          const Text('First page alone before pairing'),
                      value: model.settings.doublePageOffset,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(
                          () => model.settings.doublePageOffset = val),
                    ),
                    SwitchListTile(
                      title: const Text('Invert Double Pages'),
                      subtitle:
                          const Text('Swap left/right pairing (RTL)'),
                      value: model.settings.invertDoublePages,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(
                          () => model.settings.invertDoublePages = val),
                    ),
                    SwitchListTile(
                      title: const Text('Volume Key Page Turn'),
                      subtitle: const Text(
                          'Turn pages with physical volume rocker'),
                      value: model.settings.volumeKeyTurn,
                      activeThumbColor: primaryColor,
                      onChanged: (val) =>
                          touch(() => model.settings.volumeKeyTurn = val),
                    ),
                    SwitchListTile(
                      title: const Text('Keep Screen Awake'),
                      subtitle: const Text(
                          'Prevent device display from sleeping'),
                      value: model.settings.keepScreenAwake,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(() {
                        model.settings.keepScreenAwake = val;
                        model.onKeepScreenAwakeChanged(val);
                      }),
                    ),
                    SwitchListTile(
                      title: const Text('Crop White Borders'),
                      subtitle: const Text(
                          'Trim page whitespace margins automatically'),
                      value: model.cropBorders,
                      activeThumbColor: primaryColor,
                      onChanged: (val) => touch(() {
                        model.cropBorders = val;
                        model.onCropBordersChanged(val);
                      }),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: SunfireColors.contentTertiary,
        letterSpacing: 1,
      ),
    ),
  );
}

Widget _filterChip(
  String label,
  bool isSelected,
  VoidCallback onTap,
  Color primaryColor,
) {
  return ChoiceChip(
    label: Text(label),
    selected: isSelected,
    selectedColor: primaryColor,
    backgroundColor: SunfireColors.borderSubtle,
    labelStyle: TextStyle(
      color: isSelected ? SunfireColors.contentPrimary : SunfireColors.contentTertiary,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      fontSize: 12,
    ),
    onSelected: (_) => onTap(),
  );
}
