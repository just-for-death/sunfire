import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_providers/global_providers.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/mobile_permissions.dart';
import '../../utils/platform/platform_ui.dart';

const String _kNotificationBannerDismissedPrefKey =
    'notification_permission_banner_dismissed';

/// Prompts the user when notification permission is missing on mobile.
class NotificationPermissionBanner extends HookConsumerWidget {
  const NotificationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isPermanentlyDismissed =
        prefs.getBool(_kNotificationBannerDismissedPrefKey) ?? false;
    final dismissed = useState(isPermanentlyDismissed);
    final granted = useState<bool?>(null);
    final needsSettings = useState(false);

    Future<void> refresh() async {
      granted.value = await MobilePermissions.isNotificationGranted();
      needsSettings.value = await MobilePermissions.needsNotificationSettings();
    }

    useEffect(() {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        granted.value = true;
        return null;
      }
      refresh();

      void onLifecycleChange(AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
          refresh();
        }
      }

      final observer = _LifecycleObserver(onLifecycleChange);
      WidgetsBinding.instance.addObserver(observer);
      return () => WidgetsBinding.instance.removeObserver(observer);
    }, const []);

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }
    if (dismissed.value || isPermanentlyDismissed || granted.value != false) {
      return const SizedBox.shrink();
    }

    final cs = context.theme.colorScheme;
    return Material(
      color: cs.tertiaryContainer,
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
                      ? CupertinoIcons.bell_slash
                      : Icons.notifications_off_outlined,
                  size: 18,
                  color: cs.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.notificationsDisabledBanner,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.textTheme.labelMedium?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (needsSettings.value)
                  IconButton(
                    onPressed: () async {
                      await MobilePermissions.openNotificationSettings();
                      await refresh();
                    },
                    icon: Icon(
                      isCupertinoPlatform
                          ? CupertinoIcons.settings
                          : Icons.settings_outlined,
                      color: cs.onTertiaryContainer,
                    ),
                    tooltip: context.l10n.notificationsOpenSettingsA11y,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                  )
                else
                  IconButton(
                    onPressed: () async {
                      await MobilePermissions.ensureNotificationPermission();
                      await refresh();
                    },
                    icon: Icon(
                      isCupertinoPlatform
                          ? CupertinoIcons.bell
                          : Icons.notifications_active_outlined,
                      color: cs.onTertiaryContainer,
                    ),
                    tooltip: context.l10n.notificationsEnableA11y,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: EdgeInsets.zero,
                  ),
                IconButton(
                  onPressed: () {
                    prefs.setBool(_kNotificationBannerDismissedPrefKey, true);
                    dismissed.value = true;
                  },
                  icon: Icon(
                    isCupertinoPlatform
                        ? CupertinoIcons.xmark
                        : Icons.close_rounded,
                    color: cs.onTertiaryContainer,
                  ),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this.onChange);
  final void Function(AppLifecycleState state) onChange;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => onChange(state);
}
