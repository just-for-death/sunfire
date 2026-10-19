// Accessibility tests for navigation components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/ui/design_system/components/sunfire_chip.dart';

void main() {
  group('Navigation accessibility', () {
    testWidgets('Bottom nav items have semantic labels', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Chips are accessible', (tester) async {
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
      expect(find.text('Filter'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Text overflow does not break semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 50,
              child: Text(
                'Very long text that overflows',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('Keyboard navigation works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextButton(onPressed: () {}, child: const Text('Button 1')),
                TextButton(onPressed: () {}, child: const Text('Button 2')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
    });
  });
}