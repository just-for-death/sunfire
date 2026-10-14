import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/library_settings_screen.dart';

void main() {
  testWidgets('IMP-003 local update skip toggles persist', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    await tester.pumpWidget(const MaterialApp(home: LibrarySettingsScreen()));
    await tester.pump();
    for (final k in ['updateSkipCompleted', 'updateSkipWithUnread', 'updateSkipNotStarted']) {
      final f = find.byKey(ValueKey(k));
      await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(f);
      await tester.pump();
    }
    final s = SettingsService.instance;
    expect([s.updateSkipCompleted, s.updateSkipWithUnread, s.updateSkipNotStarted], [true, true, true]);
  });
}
