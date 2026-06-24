// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../constants/db_keys.dart';
import '../../../../../../constants/enum.dart';
import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../utils/mixin/shared_preferences_client_mixin.dart';
import '../../../../../../widgets/popup_widgets/radio_list_popup.dart';

part 'reader_orientation_tile.g.dart';

@riverpod
class ReaderOrientationLockKey extends _$ReaderOrientationLockKey
    with SharedPreferenceEnumClientMixin<ReaderOrientationLock> {
  @override
  ReaderOrientationLock? build() => initialize(
        DBKeys.readerOrientationLock,
        enumList: ReaderOrientationLock.values,
      );
}

class ReaderOrientationTile extends ConsumerWidget {
  const ReaderOrientationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(readerOrientationLockKeyProvider);
    return ListTile(
      leading: const Icon(Icons.screen_rotation_rounded),
      title: Text(context.l10n.readerOrientationLock),
      subtitle: lock != null ? Text(lock.toLocale(context)) : null,
      onTap: () => showDialog(
        context: context,
        builder: (context) => RadioListPopup<ReaderOrientationLock>(
          title: context.l10n.readerOrientationLock,
          optionList: ReaderOrientationLock.values,
          value: lock ?? ReaderOrientationLock.auto,
          getOptionTitle: (value) => value.toLocale(context),
          onChange: (value) {
            ref.read(readerOrientationLockKeyProvider.notifier).update(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
