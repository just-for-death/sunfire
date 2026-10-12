// lib/src/ui/shell/keyboard_shortcuts.dart
//
// SunfireShortcuts - app-level keyboard shortcuts (D9.2).
//
// Wraps the shell: Ctrl/Cmd+1..5 switch tabs, Ctrl/Cmd+R triggers a manual
// library sync, Ctrl/Cmd+F focuses search (via callback). Desktop-first but
// harmless on mobile (no keyboard -> no-op).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Intent: switch to tab [index].
class SwitchTabIntent extends Intent {
  const SwitchTabIntent(this.index);
  final int index;
}

/// Intent: trigger a manual library sync.
class QuickSyncIntent extends Intent {
  const QuickSyncIntent();
}

/// Intent: focus the search field.
class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

/// App-level keyboard shortcuts wrapper (D9.2).
class SunfireShortcuts extends StatelessWidget {
  const SunfireShortcuts({
    super.key,
    required this.child,
    required this.onSwitchTab,
    this.onQuickSync,
    this.onFocusSearch,
  });

  final Widget child;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback? onQuickSync;
  final VoidCallback? onFocusSearch;

  /// Shared shortcut map (also used by tests).
  static Map<ShortcutActivator, Intent> shortcutMap({
    bool includeSync = true,
    bool includeSearch = true,
  }) {
    const digits = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
    ];
    return {
      for (var i = 0; i < digits.length; i++)
        SingleActivator(digits[i], control: true): SwitchTabIntent(i),
      if (includeSync)
        const SingleActivator(LogicalKeyboardKey.keyR, control: true):
            const QuickSyncIntent(),
      if (includeSearch)
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            const FocusSearchIntent(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcutMap(
        includeSync: onQuickSync != null,
        includeSearch: onFocusSearch != null,
      ),
      child: Actions(
        actions: {
          SwitchTabIntent:
              CallbackAction<SwitchTabIntent>(onInvoke: (i) {
            onSwitchTab(i.index);
            return null;
          }),
          if (onQuickSync != null)
            QuickSyncIntent: CallbackAction<QuickSyncIntent>(onInvoke: (_) {
              onQuickSync!();
              return null;
            }),
          if (onFocusSearch != null)
            FocusSearchIntent:
                CallbackAction<FocusSearchIntent>(onInvoke: (_) {
              onFocusSearch!();
              return null;
            }),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
