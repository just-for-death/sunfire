import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// True on iPhone/iPad native builds (not web).
bool get isCupertinoPlatform => !kIsWeb && Platform.isIOS;

/// Bottom inset so scroll content clears the tab bar.
const double kTabBarScrollBottomInset = 96;

/// Extra bottom inset when a FAB floats over the list.
const double kFabScrollBottomInset = 96;

double scrollBottomInset({
  bool hasFab = false,
  BuildContext? context,
}) {
  final base = hasFab ? kFabScrollBottomInset : kTabBarScrollBottomInset;
  if (context == null) return base;
  return base + MediaQuery.paddingOf(context).bottom;
}

/// Scroll padding that includes safe-area and tab bar clearance.
EdgeInsets scrollBottomPadding(
  BuildContext context, {
  bool hasFab = false,
  double horizontal = 0,
}) {
  return EdgeInsets.fromLTRB(
    horizontal,
    0,
    horizontal,
    scrollBottomInset(hasFab: hasFab, context: context),
  );
}

/// Material bottom sheet on Android; Cupertino modal on iOS.
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool isScrollControlled = false,
  double scrollControlledHeightFactor = 0.92,
  bool? useSafeArea,
}) {
  final effectiveUseSafeArea = useSafeArea ?? isScrollControlled;

  if (isCupertinoPlatform) {
    if (isScrollControlled) {
      return showCupertinoModalPopup<T>(
        context: context,
        useRootNavigator: useRootNavigator,
        builder: (ctx) => Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: scrollControlledHeightFactor,
            widthFactor: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Material(
                color: CupertinoColors.systemBackground.resolveFrom(ctx),
                child: effectiveUseSafeArea
                    ? SafeArea(child: builder(ctx))
                    : builder(ctx),
              ),
            ),
          ),
        ),
      );
    }
    return showCupertinoModalPopup<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: builder,
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    useSafeArea: effectiveUseSafeArea,
    showDragHandle: true,
    builder: builder,
  );
}

/// Material dialog for custom content (popups, forms). Uses Material on all
/// platforms so shared popup widgets render correctly.
Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}

/// Platform-styled confirmation dialog. Returns `true` when confirmed.
Future<bool> showAdaptiveConfirmDialog({
  required BuildContext context,
  required String title,
  String? content,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructive = false,
}) async {
  final l10n = MaterialLocalizations.of(context);
  final confirm = confirmLabel ?? l10n.okButtonLabel;
  final cancel = cancelLabel ?? l10n.cancelButtonLabel;

  final Future<bool?> dialogFuture;
  if (isCupertinoPlatform) {
    dialogFuture = showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            isDefaultAction: !isDestructive,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
  } else {
    dialogFuture = showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancel),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirm),
          ),
        ],
      ),
    );
  }

  final result = await dialogFuture;
  return result ?? false;
}

/// Primary filled action button styled for the current platform.
Widget adaptivePrimaryButton({
  required BuildContext context,
  required VoidCallback? onPressed,
  required Widget child,
}) {
  if (isCupertinoPlatform) {
    return CupertinoButton.filled(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: child,
    );
  }
  return FilledButton(onPressed: onPressed, child: child);
}

/// Light haptic on tab / selection changes (mobile only).
void adaptiveSelectionHaptic() {
  if (kIsWeb) return;
  if (Platform.isIOS || Platform.isAndroid) {
    HapticFeedback.selectionClick();
  }
}
