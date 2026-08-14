// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../constants/app_sizes.dart';
import '../../../../../global_providers/tablet_selection_providers.dart';
import '../../../../../routes/router_config.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../widgets/layout/tablet_split_layout.dart';
import '../../../../../widgets/server_image.dart';
import '../../../domain/source/source_model.dart';
import '../controller/source_controller.dart';

/// Opens a source in the tablet detail pane when there is one, and as a
/// full-screen route otherwise.
///
/// `SourceTypeRoute` sits on the root navigator, so going there on a tablet
/// would cover the split layout instead of filling its detail side.
void openSource(
  BuildContext context,
  WidgetRef ref, {
  required String sourceId,
  required SourceType sourceType,
}) {
  ref.read(sourceLastUsedProvider.notifier).update(sourceId);
  if (TabletSplitLayout.shouldUse(context)) {
    ref.read(tabletBrowseSourceSelectionProvider.notifier).state = (
      sourceId: sourceId,
      sourceType: sourceType,
      query: null,
    );
    return;
  }
  SourceTypeRoute(sourceId: sourceId, sourceType: sourceType).go(context);
}

class SourceListTile extends ConsumerWidget {
  const SourceListTile({super.key, required this.source});

  final SourceDto source;

  void _openSource(
    BuildContext context,
    WidgetRef ref,
    SourceType sourceType,
  ) =>
      openSource(
        context,
        ref,
        sourceId: source.id,
        sourceType: sourceType,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(tabletBrowseSourceSelectionProvider);
    final isSelected = TabletSplitLayout.shouldUse(context) &&
        selection?.sourceId == source.id;

    return ListTile(
      selected: isSelected,
      onTap: () => _openSource(context, ref, SourceType.POPULAR),
      leading: ClipRRect(
        borderRadius: KBorderRadius.r8.radius,
        child: ServerImage(
          imageUrl: source.iconUrl,
          size: const Size.square(48),
        ),
      ),
      title: Text(source.name),
      subtitle: (source.language?.displayName).isNotBlank
          ? Text(source.language?.displayName ?? "")
          : null,
      trailing: (source.supportsLatest.ifNull())
          ? TextButton(
              onPressed: () =>
                  _openSource(context, ref, SourceType.LATEST),
              child: Text(context.l10n.latest),
            )
          : null,
    );
  }
}
