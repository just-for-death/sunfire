import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/settings/presentation/server/server_connectivity.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/platform_ui.dart';
import 'notification_permission_banner.dart';
import 'top_state_banners.dart';

/// Inline banners for the navigation shell (server status + library updates).
class ShellBannerStack extends HookConsumerWidget {
  const ShellBannerStack({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerDismissed = useState(false);
    final status = ref.watch(serverConnectivityProvider);

    ref.listen(serverConnectivityProvider, (previous, next) {
      if (next == ServerStatus.online) bannerDismissed.value = false;
    });

    final showOffline =
        status == ServerStatus.offline && !bannerDismissed.value;

    if (!showOffline) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NotificationPermissionBanner(),
          TopStateBanners(),
        ],
      );
    }

    final cs = context.theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NotificationPermissionBanner(),
        Material(
          color: cs.errorContainer,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      isCupertinoPlatform
                          ? CupertinoIcons.wifi_slash
                          : Icons.cloud_off_rounded,
                      size: 18,
                      color: cs.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.serverOfflineBanner,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.textTheme.labelMedium?.copyWith(
                          color: cs.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(serverConnectivityProvider.notifier)
                          .checkServer(),
                      icon: Icon(
                        isCupertinoPlatform
                            ? CupertinoIcons.refresh
                            : Icons.refresh_rounded,
                        color: cs.onErrorContainer,
                      ),
                      tooltip: context.l10n.serverOfflineRetryA11y,
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      onPressed: () => bannerDismissed.value = true,
                      icon: Icon(
                        isCupertinoPlatform
                            ? CupertinoIcons.xmark
                            : Icons.close_rounded,
                        color: cs.onErrorContainer,
                      ),
                      tooltip: context.l10n.serverOfflineDismissA11y,
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const TopStateBanners(),
      ],
    );
  }
}
