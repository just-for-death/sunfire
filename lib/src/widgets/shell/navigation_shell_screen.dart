import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pub_semver/pub_semver.dart';

import '../../constants/app_breakpoints.dart';
import '../../features/about/data/about_repository.dart';
import '../../features/about/presentation/about/controllers/about_controller.dart';
import '../../features/about/presentation/about/widget/app_update_dialog.dart';
import '../../features/settings/presentation/server/server_connectivity.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/misc/toast/toast.dart';
import 'big_screen_navigation_bar.dart';
import 'ios/ios_navigation_shell.dart';
import 'shell_banner_stack.dart';
import 'small_screen_navigation_bar.dart';

class NavigationShellScreen extends HookConsumerWidget {
  const NavigationShellScreen({super.key, required this.child});
  final StatefulNavigationShell child;

  Future<void> checkForUpdate({
    required String? title,
    required BuildContext context,
    required Future<AsyncValue<Version?>> Function() updateCallback,
    required Toast? toast,
  }) async {
    final AsyncValue<Version?> versionResult = await updateCallback();
    toast?.close();
    if (!context.mounted) return;
    versionResult.whenOrNull(
      data: (version) {
        if (version != null) {
          appUpdateDialog(
            title: title ?? context.l10n.appTitle,
            newRelease: "v${version.canonicalizedVersion}",
            context: context,
            toast: toast,
          );
        }
      },
      error: (error, _) {
        versionResult.showToastOnError(toast);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateChecked = useRef(false);

    useEffect(() {
      if (updateChecked.value) return null;
      updateChecked.value = true;
      Future.microtask(() async {
        if (!context.mounted) return;
        await checkForUpdate(
          title: ref.read(packageInfoProvider).appName,
          context: context,
          updateCallback: ref.read(aboutRepositoryProvider).checkUpdate,
          toast: ref.read(toastProvider),
        );
      });
      return null;
    }, []);

    void onDestinationSelected(int index) =>
        child.goBranch(index, initialLocation: index == child.currentIndex);

    // iOS / iPadOS → glass UI
    final isIOS = !kIsWeb && Platform.isIOS;
    if (isIOS) {
      return ServerAwareWrapper(
        showOfflineBanner: false,
        child: IOSNavigationShell(
          onDestinationSelected: onDestinationSelected,
          compactBottomNav: AppBreakpoints.isCompactNav(context) ||
              AppBreakpoints.useCompactShellOnIPad(context),
          child: child,
        ),
      );
    }

    // Android tablet → rail
    if (AppBreakpoints.isTabletLayout(context)) {
      return ServerAwareWrapper(
        showOfflineBanner: false,
        child: Scaffold(
          body: Row(
            children: [
              BigScreenNavigationBar(
                selectedIndex: child.currentIndex,
                onDestinationSelected: onDestinationSelected,
              ),
              Expanded(
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topCenter,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: ShellBannerStack(),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Android phone → Material You bottom nav
    final compactBottomNav = AppBreakpoints.isCompactNav(context);
    return ServerAwareWrapper(
      showOfflineBanner: false,
      child: Scaffold(
        body: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                alignment: Alignment.topCenter,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: ShellBannerStack(),
            ),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: SmallScreenNavigationBar(
          selectedBranchIndex: child.currentIndex,
          compact: compactBottomNav,
          shell: compactBottomNav ? child : null,
          onBranchSelected: onDestinationSelected,
        ),
      ),
    );
  }
}
