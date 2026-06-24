// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/extensions/custom_extensions.dart';

/// Material [Scaffold] on Android/desktop; Cupertino chrome on iOS.
class SettingsSubpageScaffold extends StatelessWidget {
  const SettingsSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  static bool get _useCupertino => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (_useCupertino) {
      final isDark = context.isDarkMode;
      return CupertinoPageScaffold(
        backgroundColor:
            isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7),
        navigationBar: CupertinoNavigationBar(
          leading: context.canPop()
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: const Icon(CupertinoIcons.back),
                )
              : null,
          middle: Text(title),
          trailing: actions != null && actions!.isNotEmpty
              ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
              : null,
          backgroundColor: isDark
              ? Colors.black.withValues(alpha: 0.72)
              : Colors.white.withValues(alpha: 0.72),
        ),
        child: SafeArea(
          child: floatingActionButton == null
              ? body
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    body,
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: floatingActionButton!,
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
