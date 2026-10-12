// lib/src/ui/shell/desktop_menus.dart
//
// SunfireMenuBar - native platform menus (D9.1).
//
// Uses Flutter's PlatformMenuBar: truly native on macOS, correct no-op
// elsewhere. Menu actions route through MainShell.selectedTabNotifier and
// services so they need no BuildContext - the shell syncs URL + state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/library_update_service.dart';
import '../../main_shell.dart';

/// Native platform menu bar wrapper (D9.1). No-op where the platform has
/// no native menu support; harmless on mobile.
class SunfireMenuBar extends StatelessWidget {
  const SunfireMenuBar({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    ('Library', 0),
    ('Updates', 1),
    ('History', 2),
    ('Browse', 3),
    ('Settings', 4),
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'Library',
          menus: [
            for (final (label, index) in _tabs)
              PlatformMenuItem(
                label: label,
                shortcut: SingleActivator(
                  [
                    LogicalKeyboardKey.digit1,
                    LogicalKeyboardKey.digit2,
                    LogicalKeyboardKey.digit3,
                    LogicalKeyboardKey.digit4,
                    LogicalKeyboardKey.digit5,
                  ][index],
                  control: true,
                ),
                onSelected: () => MainShell.switchToTab(index),
              ),
          ],
        ),
        PlatformMenu(
          label: 'Actions',
          menus: [
            PlatformMenuItem(
              label: 'Sync Now',
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyR,
                control: true,
              ),
              onSelected: () => LibraryUpdateService.instance
                  .checkForNewChapters(isManual: true),
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
