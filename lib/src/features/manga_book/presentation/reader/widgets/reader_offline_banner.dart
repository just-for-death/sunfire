import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../settings/presentation/server/server_connectivity.dart';
import '../../../../../utils/extensions/custom_extensions.dart';

/// Compact offline notice shown at the top of the reader when the server is down.
class ReaderOfflineBanner extends ConsumerWidget {
  const ReaderOfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverConnectivityProvider);
    if (status != ServerStatus.offline) return const SizedBox.shrink();

    final cs = context.theme.colorScheme;
    return Material(
      color: cs.errorContainer.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 16,
                color: cs.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.serverOfflineBanner,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.textTheme.labelSmall?.copyWith(
                    color: cs.onErrorContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(serverConnectivityProvider.notifier).checkServer(),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: cs.onErrorContainer,
                ),
                tooltip: context.l10n.serverOfflineRetryA11y,
                constraints:
                    const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
