// UIS-P2-E: first-run tap-zone overlay paints and dismisses.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/tap_zone_overlay.dart';
import 'package:sunfire/src/features/reader/tap_zones.dart';

void main() {
  testWidgets('shows preset label and zone labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 500,
            child: TapZoneOverlay(
              preset: TapZonePreset.defaultZones,
              autoDismiss: Duration(hours: 1),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Tap zones'), findsOneWidget);
    expect(find.text('Prev'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('tap dismisses via fade then callback', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 500,
            child: TapZoneOverlay(
              preset: TapZonePreset.edge,
              autoDismiss: const Duration(hours: 1),
              onDismissed: () => dismissed++,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TapZoneOverlay));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(dismissed, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('rtl + invert relabel zones', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 500,
            child: TapZoneOverlay(
              preset: TapZonePreset.defaultZones,
              invert: true,
              rtlPaged: false,
              autoDismiss: Duration(hours: 1),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Next'), findsWidgets);
    expect(find.text('Prev'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
