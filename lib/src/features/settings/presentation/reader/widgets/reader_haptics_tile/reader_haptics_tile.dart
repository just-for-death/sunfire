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

part 'reader_haptics_tile.g.dart';

@riverpod
class ReaderHapticsEnabled extends _$ReaderHapticsEnabled
    with SharedPreferenceClientMixin<bool> {
  @override
  bool? build() => initialize(DBKeys.readerHapticsEnabled);
}

class ReaderHapticsTile extends HookConsumerWidget {
  const ReaderHapticsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveSwitchListTile(
      leading: const Icon(Icons.vibration_rounded),
      title: Text(context.l10n.readerHaptics),
      subtitle: Text(context.l10n.readerHapticsSubtitle),
      onChanged: ref.read(readerHapticsEnabledProvider.notifier).update,
      value: ref.watch(readerHapticsEnabledProvider).ifNull(),
    );
  }
}
