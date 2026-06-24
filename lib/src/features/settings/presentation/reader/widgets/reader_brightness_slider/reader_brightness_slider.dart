// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../constants/db_keys.dart';
import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../../../../../../widgets/settings/adaptive_list_tile.dart';

part 'reader_brightness_slider.g.dart';

@riverpod
class ReaderBrightnessOverlay extends _$ReaderBrightnessOverlay
    with SharedPreferenceClientMixin<double> {
  @override
  double? build() => initialize(DBKeys.readerBrightnessOverlay);
}

class ReaderBrightnessSlider extends HookConsumerWidget {
  const ReaderBrightnessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value =
        ref.watch(readerBrightnessOverlayProvider) ?? DBKeys.readerBrightnessOverlay.initial;
    return AdaptiveListTile(
      leading: const Icon(Icons.brightness_4_rounded),
      title: Text(context.l10n.readerBrightnessOverlay),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.readerBrightnessOverlaySubtitle),
          Slider(
            value: value.clamp(0.0, 0.6),
            min: 0,
            max: 0.6,
            divisions: 6,
            label: '${(value * 100).round()}%',
            onChanged: ref.read(readerBrightnessOverlayProvider.notifier).update,
          ),
        ],
      ),
    );
  }
}
