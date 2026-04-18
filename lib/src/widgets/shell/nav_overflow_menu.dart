// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/extensions/custom_extensions.dart';

/// Bottom sheet for compact bottom nav: open Downloads (branch 4) or More (branch 5).
void showCompactNavOverflowMenu(
  BuildContext context,
  StatefulNavigationShell shell,
) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Text(
                ctx.l10n.navOverflowSheetTitle,
                style: ctx.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text(ctx.l10n.downloads),
              onTap: () {
                Navigator.pop(ctx);
                shell.goBranch(
                  4,
                  initialLocation: 4 == shell.currentIndex,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz_rounded),
              title: Text(ctx.l10n.more),
              onTap: () {
                Navigator.pop(ctx);
                shell.goBranch(
                  5,
                  initialLocation: 5 == shell.currentIndex,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
