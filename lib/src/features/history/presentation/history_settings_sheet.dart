import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/custom_extensions.dart';
import '../../../utils/platform/platform_ui.dart';
import '../../../widgets/settings/adaptive_list_tile.dart';
import 'history_controller.dart';

void showHistorySettingsSheet(BuildContext context, WidgetRef ref) {
  showAdaptiveBottomSheet<void>(
    context: context,
    builder: (ctx) => Consumer(
      builder: (context, ref, _) {
        final enabled = ref.watch(historyEnabledProvider) ?? true;
        final retention = ref.watch(historyRetentionDaysProvider) ?? 0;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdaptiveSwitchListTile(
                title: Text(context.l10n.historyEnabledLabel),
                subtitle: Text(context.l10n.historyEnabledDescription),
                value: enabled,
                onChanged: (v) =>
                    ref.read(historyEnabledProvider.notifier).setEnabled(v),
              ),
              AdaptiveListTile(
                title: Text(context.l10n.historyRetentionLabel),
                subtitle: Text(_retentionLabel(context, retention)),
              ),
              ...([0, 30, 90, 180, 365].map(
                (days) => AdaptiveListTile(
                  title: Text(_retentionLabel(context, days)),
                  trailing: retention == days
                      ? Icon(
                          isCupertinoPlatform
                              ? CupertinoIcons.check_mark
                              : Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  enabled: enabled,
                  onTap: enabled
                      ? () => ref
                          .read(historyRetentionDaysProvider.notifier)
                          .updateRetentionDays(days)
                      : null,
                ),
              )),
            ],
          ),
        );
      },
    ),
  );
}

String _retentionLabel(BuildContext context, int days) {
  if (days <= 0) return context.l10n.historyRetentionNever;
  return context.l10n.historyRetentionDays(days);
}
