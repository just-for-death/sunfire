// UIS-13: real accessibility audit of shipped screens.
//
// Pumps the actual settings screens with semantics enabled, then walks the
// semantics tree and asserts every actionable node (button / tap / long-press)
// exposes a non-empty label or tooltip. An unlabeled control is invisible to
// TalkBack/VoiceOver, so this is a genuine a11y regression guard — not a smoke
// test of synthetic widgets.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/settings/appearance_settings_screen.dart';
import 'package:sunfire/src/features/settings/downloads_settings_screen.dart';
import 'package:sunfire/src/features/settings/extension_repos_screen.dart';
import 'package:sunfire/src/features/settings/library_settings_screen.dart';
import 'package:sunfire/src/features/settings/reader_settings_screen.dart';
import 'package:sunfire/src/features/settings/sync_health_screen.dart';

void _collectUnlabeled(SemanticsNode node, List<String> issues) {
  // A node merged into its parent contributes its data upward; it is not a
  // separate focus target, so auditing it in isolation is a false positive.
  if (node.isMergedIntoParent || node.isInvisible) return;
  final data = node.getSemanticsData();
  final actionable = data.hasAction(SemanticsAction.tap) ||
      data.hasAction(SemanticsAction.longPress) ||
      data.flagsCollection.isButton;
  if (actionable) {
    final label = data.label.trim();
    final tooltip = data.tooltip.trim();
    if (label.isEmpty && tooltip.isEmpty) {
      issues.add(
        'unlabeled actionable node ${node.id} rect=${node.rect} '
        'hint="${data.hint}" value="${data.value}" '
        'flags=${data.flagsCollection}',
      );
    }
  }
  node.visitChildren((child) {
    _collectUnlabeled(child, issues);
    return true;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => '/tmp/sunfire_test',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  final screens = <String, Widget>{
    'AppearanceSettingsScreen': const AppearanceSettingsScreen(),
    'DownloadsSettingsScreen': const DownloadsSettingsScreen(),
    'LibrarySettingsScreen': const LibrarySettingsScreen(),
    'ExtensionReposScreen': const ExtensionReposScreen(),
    'ReaderSettingsScreen': const ReaderSettingsScreen(),
    'SyncHealthScreen': const SyncHealthScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} exposes labels on every actionable node', (tester) async {
      final handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await SettingsService.instance.initialize();
      await tester.pumpWidget(MaterialApp(home: entry.value));
      await tester.pump();

      // Lay out every lazily-built child before auditing.
      for (var i = 0; i < 12; i++) {
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isEmpty) break;
        await tester.drag(scrollables.first, const Offset(0, -600));
        await tester.pump();
      }

      // The test binding owns a single view; its pipeline owner is the correct
      // semantics root here. The newer rootPipelineOwner tree API does not
      // expose the test view's owner.
      // ignore: deprecated_member_use
      final owner = tester.binding.pipelineOwner.semanticsOwner;
      expect(owner, isNotNull, reason: 'semantics owner unavailable');
      final root = owner!.rootSemanticsNode;
      expect(root, isNotNull, reason: 'no semantics root');

      final issues = <String>[];
      _collectUnlabeled(root!, issues);
      expect(issues, isEmpty, reason: '${entry.key} a11y:\n${issues.join('\n')}');
      handle.dispose();
    });
  }
}
