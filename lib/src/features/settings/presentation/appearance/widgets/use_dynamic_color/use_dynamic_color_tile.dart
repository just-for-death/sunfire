import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../constants/db_keys.dart';
import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/mixin/shared_preferences_client_mixin.dart';

part 'use_dynamic_color_tile.g.dart';

@riverpod
class UseDynamicColor extends _$UseDynamicColor
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.useDynamicColor);
}

class UseDynamicColorTile extends ConsumerWidget {
  const UseDynamicColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(useDynamicColorProvider).ifNull(true);
    return SwitchListTile(
      secondary: Icon(
        Icons.palette_outlined,
        color: enabled
            ? context.theme.colorScheme.primary
            : context.theme.colorScheme.onSurfaceVariant,
      ),
      title: const Text('Dynamic Color'),
      subtitle: const Text('Use wallpaper colors (Android 12+)'),
      onChanged: ref.read(useDynamicColorProvider.notifier).update,
      value: enabled,
    );
  }
}
