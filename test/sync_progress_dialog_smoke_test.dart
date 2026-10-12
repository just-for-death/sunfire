// test/sync_progress_dialog_smoke_test.dart
//
// Smoke: SyncProgressDialog builds without SyncEngine / Isar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/widgets/sync_progress_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SyncProgressDialog shows title and cancel', (tester) async {
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SyncProgressDialog(
            title: 'Delta Sync',
            onCancel: () => cancelled = true,
          ),
        ),
      ),
    );

    expect(find.text('Delta Sync'), findsOneWidget);
    expect(find.text('Preparing…'), findsOneWidget);
    // S1.5: initial SyncProgress is 0/100 — dialog shows counts + percent.
    expect(find.textContaining('0 / 100'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel (Esc)'));
    await tester.pump();
    expect(cancelled, isTrue);
  });
}
