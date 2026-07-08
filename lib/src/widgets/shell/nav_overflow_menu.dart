import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/platform_ui.dart';

/// Bottom sheet for compact bottom nav: open Downloads (branch 4) or More (branch 5).
void showCompactNavOverflowMenu(
  BuildContext context,
  StatefulNavigationShell shell,
) {
  showAdaptiveBottomSheet<void>(
    context: context,
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
            if (isCupertinoPlatform) ...[
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.arrow_down_circle),
                title: Text(ctx.l10n.downloads),
                onTap: () {
                  Navigator.pop(ctx);
                  shell.goBranch(4, initialLocation: 4 == shell.currentIndex);
                },
              ),
              CupertinoListTile(
                leading: const Icon(CupertinoIcons.ellipsis_circle),
                title: Text(ctx.l10n.more),
                onTap: () {
                  Navigator.pop(ctx);
                  shell.goBranch(5, initialLocation: 5 == shell.currentIndex);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: Text(ctx.l10n.downloads),
                onTap: () {
                  Navigator.pop(ctx);
                  shell.goBranch(4, initialLocation: 4 == shell.currentIndex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.more_horiz_rounded),
                title: Text(ctx.l10n.more),
                onTap: () {
                  Navigator.pop(ctx);
                  shell.goBranch(5, initialLocation: 5 == shell.currentIndex);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
