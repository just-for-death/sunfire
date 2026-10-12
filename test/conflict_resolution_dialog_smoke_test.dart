// test/conflict_resolution_dialog_smoke_test.dart
//
// Smoke: ConflictResolutionDialog renders a conflict and batch action.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/conflict_resolver.dart'
    show ConflictResolutionStrategy;
import 'package:sunfire/src/core/sync/sync_engine.dart' show SyncConflict;
import 'package:sunfire/src/ui/widgets/conflict_resolution_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows conflict and apply-all button', (tester) async {
    ConflictResolutionStrategy? applied;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConflictResolutionDialog(
            conflicts: const [
              SyncConflict(
                entityType: 'manga',
                entityId: 42,
                field: 'title',
                localData: 'Local Title',
                remoteData: 'Remote Title',
              ),
            ],
            onResolve: (_, __) {},
            onResolveAll: (s) => applied = s,
          ),
        ),
      ),
    );

    expect(find.text('Resolve Conflicts'), findsOneWidget);
    expect(find.text('Local Title'), findsOneWidget);
    expect(find.text('Remote Title'), findsOneWidget);
    expect(find.text('Apply strategy to all'), findsOneWidget);

    // Fullscreen dialog often fails hit-tests under suite surface size —
    // invoke the FilledButton.tonalIcon onPressed directly.
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Apply strategy to all'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    button.onPressed?.call();
    await tester.pump();
    expect(applied, ConflictResolutionStrategy.lastWriteWins);
  });
}
