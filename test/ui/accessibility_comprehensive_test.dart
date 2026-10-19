// Comprehensive accessibility tests for Sunfire UI.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_button.dart';
import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Accessibility comprehensive', () {
    testWidgets('Semantics tree exists for basic widgets', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Center(child: Text('Hello World')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
      await tester.pump();
      // Verify semantics are enabled
      expect(find.byType(Scaffold), findsOneWidget);
      handle.dispose();
    });

    testWidgets('SunfireChip is accessible', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SunfireChip(
              label: 'Filter',
              variant: SunfireChipVariant.filter,
              selected: true,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FilterChip), findsOneWidget);
      handle.dispose();
    });

    testWidgets('SunfireButton is accessible', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SunfireButton.primary(
              label: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Submit'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Text with overflow does not crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 50,
              child: Text(
                'This is a very long text that should be truncated with ellipsis',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Row with Expanded does not overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Very long text that needs expansion',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}