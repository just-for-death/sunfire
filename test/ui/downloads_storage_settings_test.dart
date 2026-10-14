import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/downloads_settings_screen.dart';

void main() {
  testWidgets('IMP-035 storage rows and low-space banner', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    await tester.pumpWidget(const MaterialApp(home: DownloadsSettingsScreen()));
    await tester.pump();
    final folder = find.byKey(const ValueKey('downloadFolderTile'));
    await tester.scrollUntilVisible(folder, 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('App default'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Keep free space'), 100, scrollable: find.byType(Scrollable).first);
    expect(find.text('Keep free space'), findsOneWidget);
    expect(find.byKey(const ValueKey('lowFreeSpaceBanner')), findsNothing);
    DownloadStorage.lowStorage.value = true;
    await tester.pump();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('lowFreeSpaceBanner')), -100, scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const ValueKey('lowFreeSpaceBanner')), findsOneWidget);
    DownloadStorage.lowStorage.value = false;
  });

  testWidgets('IMP-036 local CBZ toggle saves', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    await tester.pumpWidget(const MaterialApp(home: DownloadsSettingsScreen()));
    await tester.pump();
    final t = find.text('Save on-device downloads as CBZ');
    await tester.scrollUntilVisible(t, 100, scrollable: find.byType(Scrollable).first);
    await tester.tap(t);
    await tester.pump();
    expect(SettingsService.instance.downloadAsCbz, isTrue);
  });
}
