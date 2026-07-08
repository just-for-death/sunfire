import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// True on iPhone/iPad native builds (not web).
bool get isCupertinoPlatform => !kIsWeb && Platform.isIOS;

/// Bottom inset so scroll content clears the tab bar.
const double kTabBarScrollBottomInset = 96;

/// Extra bottom inset when a FAB floats over the list.
const double kFabScrollBottomInset = 96;

double scrollBottomInset({bool hasFab = false}) =>
    hasFab ? kFabScrollBottomInset : kTabBarScrollBottomInset;

/// Material bottom sheet on Android; Cupertino action sheet on iOS.
Future<T?> showAdaptiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  if (isCupertinoPlatform) {
    return showCupertinoModalPopup<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: builder,
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    showDragHandle: true,
    builder: builder,
  );
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
