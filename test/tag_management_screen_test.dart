// L10.2: Tag management empty-state UI (no Isar writes).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/library/tag_management_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows empty state when there are no tags', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TagManagementScreen()),
    );
    // First frame is loading spinner; after microtasks Isar is uninitialized
    // so getAllTags returns [] and empty state appears.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No tags yet'), findsOneWidget);
    expect(find.text('Create tag'), findsOneWidget);
  });
}
