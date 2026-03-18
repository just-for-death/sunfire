import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'widgets/app_theme_selector/app_theme_selector.dart';
import 'widgets/grid_cover_width_slider/grid_cover_width_slider.dart';
import 'widgets/is_true_black/is_true_black_tile.dart';
import 'widgets/use_dynamic_color/use_dynamic_color_tile.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(context, ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appearance)),
      body: ListView(
        children: [
          // Material You — dynamic color from wallpaper (Android 12+)
          const _SectionHeader(label: 'Material You'),
          const UseDynamicColorTile(),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Theme
          const _SectionHeader(label: 'Theme'),
          const AppThemeModeTile(),
          if (themeMode != ThemeMode.light) const IsTrueBlackTile(),

          // Color scheme (fallback when dynamic color is off)
          const _SectionHeader(label: 'Color Scheme'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Used when Dynamic Color is off or unavailable',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const AppThemeSelector(),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Display
          const _SectionHeader(label: 'Display'),
          const GridCoverWidthSlider(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          label,
          style: context.theme.textTheme.labelLarge?.copyWith(
            color: context.theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
}
