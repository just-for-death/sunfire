// test/desktop_shortcuts_test.dart
//
// D9.2: keyboard shortcuts map + invocation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/shell/keyboard_shortcuts.dart';

void main() {
  test('shortcutMap has 5 tab shortcuts + sync + search', () {
    final map = SunfireShortcuts.shortcutMap();
    expect(map.length, 7);
    expect(
        map.values.whereType<SwitchTabIntent>().length, 5);
    expect(map.values.whereType<QuickSyncIntent>().length, 1);
    expect(map.values.whereType<FocusSearchIntent>().length, 1);
  });

  test('shortcutMap omits sync/search when callbacks absent', () {
    final map = SunfireShortcuts.shortcutMap(
        includeSync: false, includeSearch: false);
    expect(map.length, 5);
  });

  testWidgets('Ctrl+3 switches to tab 2', (tester) async {
    var tab = -1;
    await tester.pumpWidget(MaterialApp(
      home: SunfireShortcuts(
        onSwitchTab: (i) => tab = i,
        child: const Scaffold(body: TextField()),
      ),
    ));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();
    expect(tab, 2);
  });

  testWidgets('Ctrl+R triggers quick sync', (tester) async {
    var synced = false;
    await tester.pumpWidget(MaterialApp(
      home: SunfireShortcuts(
        onSwitchTab: (_) {},
        onQuickSync: () => synced = true,
        child: const Scaffold(body: TextField()),
      ),
    ));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
    await tester.pump();
    expect(synced, isTrue);
  });

  testWidgets('no crash without optional callbacks', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SunfireShortcuts(
        onSwitchTab: (_) {},
        child: const Text('plain'),
      ),
    ));
    expect(find.text('plain'), findsOneWidget);
  });
}
