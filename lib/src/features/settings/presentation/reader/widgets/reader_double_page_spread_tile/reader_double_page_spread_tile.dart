// Copyright (c) 2026 Contributors to the Suwayomi project
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
import '../../../../../../widgets/settings/adaptive_list_tile.dart';

part 'reader_double_page_spread_tile.g.dart';

@riverpod
class ReaderDoublePageSpreadKey extends _$ReaderDoublePageSpreadKey
    with SharedPreferenceEnumClientMixin<ReaderDoublePageSpread> {
  @override
  ReaderDoublePageSpread? build() => initialize(
        DBKeys.readerDoublePageSpread,
        enumList: ReaderDoublePageSpread.values,
      );
}

class ReaderDoublePageSpreadTile extends ConsumerWidget {
  const ReaderDoublePageSpreadTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spread = ref.watch(readerDoublePageSpreadKeyProvider);
    return AdaptiveListTile(
      leading: const Icon(Icons.menu_book_rounded),
      title: Text(context.l10n.readerDoublePageSpread),
      subtitle: spread != null ? Text(spread.toLocale(context)) : null,
      onTap: () => showDialog(
        context: context,
        builder: (context) => RadioListPopup<ReaderDoublePageSpread>(
          title: context.l10n.readerDoublePageSpread,
          optionList: ReaderDoublePageSpread.values,
          value: spread ?? ReaderDoublePageSpread.auto,
          getOptionTitle: (value) => value.toLocale(context),
          onChange: (value) {
            ref.read(readerDoublePageSpreadKeyProvider.notifier).update(value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
