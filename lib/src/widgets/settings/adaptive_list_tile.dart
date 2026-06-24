// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/extensions/custom_extensions.dart';

/// [ListTile] on Material; [CupertinoListTile] on iOS.
class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  static bool get _useCupertino => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      final isDark = context.isDarkMode;
      final subColor =
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.45);
      return CupertinoListTile(
        onTap: enabled ? onTap : null,
        leading: leading,
        title: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            color: enabled
                ? (isDark ? Colors.white : Colors.black)
                : subColor,
          ),
          child: title,
        ),
        subtitle: subtitle != null
            ? DefaultTextStyle(
                style: TextStyle(fontSize: 13, color: subColor),
                child: subtitle!,
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(CupertinoIcons.chevron_right, size: 15, color: subColor)
                : null),
      );
    }

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}

/// [SwitchListTile] on Material; [CupertinoListTile] + switch on iOS.
class AdaptiveSwitchListTile extends StatelessWidget {
  const AdaptiveSwitchListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  static bool get _useCupertino => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      return CupertinoListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
        onTap: onChanged == null ? null : () => onChanged!(!value),
      );
    }

    return SwitchListTile(
      secondary: leading,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
    );
  }
}
