// test/design_components_test.dart
//
// Phase 2 Epic 5: component library widget tests (C5.1-C5.6).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/design_system/components/components.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('C5.1 SunfireButton', () {
    testWidgets('primary renders label and responds to tap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(SunfireButton.primary(
        label: 'Save',
        onPressed: () => tapped = true,
      )));
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      expect(tapped, isTrue);
    });

    testWidgets('all variants render with icon', (tester) async {
      await tester.pumpWidget(wrap(Column(
        children: const [
          SunfireButton.primary(label: 'P', icon: Icons.save),
          SunfireButton.secondary(label: 'S', icon: Icons.edit),
          SunfireButton.tertiary(label: 'T', icon: Icons.info),
          SunfireButton.ghost(label: 'G', icon: Icons.close),
        ],
      )));
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
          wrap(const SunfireButton(label: 'Nope')));
      final btn = tester.widget<FilledButton>(
          find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('C5.2 SunfireCard', () {
    testWidgets('all variants render child', (tester) async {
      await tester.pumpWidget(wrap(Column(
        children: const [
          SunfireCard(variant: SunfireCardVariant.elevated, child: Text('E')),
          SunfireCard(variant: SunfireCardVariant.outlined, child: Text('O')),
          SunfireCard(variant: SunfireCardVariant.filled, child: Text('F')),
        ],
      )));
      expect(find.text('E'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('onTap fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(SunfireCard(
        onTap: () => tapped = true,
        child: const Text('Tap me'),
      )));
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });

  group('C5.3 SunfireChip', () {
    testWidgets('filter chip toggles selection', (tester) async {
      var selected = false;
      await tester.pumpWidget(wrap(StatefulBuilder(
        builder: (context, setState) => SunfireChip(
          label: 'Ongoing',
          selected: selected,
          onSelected: (v) => setState(() => selected = v),
        ),
      )));
      await tester.tap(find.text('Ongoing'));
      await tester.pump();
      expect(selected, isTrue);
    });

    testWidgets('choice and input variants render', (tester) async {
      await tester.pumpWidget(wrap(Column(
        children: [
          const SunfireChip(
              label: 'Choice',
              variant: SunfireChipVariant.choice,
              selected: true),
          SunfireChip(
              label: 'Input',
              variant: SunfireChipVariant.input,
              onDeleted: () {}),
        ],
      )));
      expect(find.text('Choice'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);
    });
  });

  group('C5.4 dialogs', () {
    testWidgets('confirm helper returns true on confirm',
        (tester) async {
      bool? result;
      await tester.pumpWidget(wrap(Builder(
        builder: (context) => SunfireButton.primary(
          label: 'Open',
          onPressed: () async {
            result = await showSunfireConfirmDialog(
              context: context,
              title: 'Delete?',
              message: 'Sure?',
              destructive: true,
            );
          },
        ),
      )));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('fullscreen dialog shows title and body',
        (tester) async {
      await tester.pumpWidget(wrap(const SunfireFullscreenDialog(
        title: 'Sync Progress',
        subtitle: 'Live',
        body: Text('Body content'),
      )));
      expect(find.text('Sync Progress'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });
  });

  group('C5.5 sheets', () {
    testWidgets('bottom sheet shows title and body', (tester) async {
      await tester.pumpWidget(wrap(const SunfireBottomSheet(
        title: 'Options',
        body: Text('Sheet body'),
      )));
      expect(find.text('Options'), findsOneWidget);
      expect(find.text('Sheet body'), findsOneWidget);
    });
  });

  group('C5.6 navigation', () {
    const destinations = [
      SunfireNavDestination(label: 'Library', icon: Icons.book),
      SunfireNavDestination(
          label: 'Updates', icon: Icons.update, badge: '3'),
    ];

    testWidgets('bottom nav selects destination', (tester) async {
      var index = 0;
      await tester.pumpWidget(wrap(StatefulBuilder(
        builder: (context, setState) => SunfireBottomNav(
          destinations: destinations,
          selectedIndex: index,
          onDestinationSelected: (v) => setState(() => index = v),
        ),
      )));
      await tester.tap(find.text('Updates'));
      await tester.pump();
      expect(index, 1);
    });

    testWidgets('rail renders with badge', (tester) async {
      await tester.pumpWidget(wrap(SunfireNavRail(
        destinations: destinations,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
      )));
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
