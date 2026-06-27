import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/settings/settings_subpage_scaffold.dart';
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
    return SettingsSubpageScaffold(
      title: context.l10n.appearance,
      body: ListView(
        children: [
          if (!kIsWeb && !Platform.isIOS) ...[
            _SectionHeader(label: context.l10n.appearanceMaterialYou),
            const UseDynamicColorTile(),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          _SectionHeader(label: context.l10n.appearanceTheme),
          const AppThemeModeTile(),
          if (themeMode != ThemeMode.light) const IsTrueBlackTile(),

          _SectionHeader(label: context.l10n.appearanceColorScheme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              context.l10n.appearanceColorSchemeHint,
              style: TextStyle(
                fontSize: 12,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const AppThemeSelector(),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _SectionHeader(label: context.l10n.display),
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
