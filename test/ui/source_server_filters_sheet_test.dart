import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/source_filters.dart';
import 'package:sunfire/src/features/browse/source_server_filters_sheet.dart';

const _filters = <SourceFilter>[
  SourceFilter(kind: SourceFilterKind.text, position: 0, name: 'Author'),
  SourceFilter(kind: SourceFilterKind.group, position: 1, name: 'Genres', children: [
    SourceFilter(kind: SourceFilterKind.checkBox, position: 0, name: 'Action'),
    SourceFilter(kind: SourceFilterKind.checkBox, position: 1, name: 'Drama'),
  ]),
];

Future<List<SourceFilterChange>?> _open(WidgetTester tester, List<SourceFilterChange> initial) async {
  List<SourceFilterChange>? result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (ctx) => Scaffold(
        body: TextButton(
          onPressed: () async {
            result = await showSourceServerFiltersSheet(ctx,
                sourceId: '1', initialChanges: initial, preloadedFilters: _filters);
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('group (genre) filters come back on reopen', (tester) async {
    await _open(tester, const [SourceFilterChange.group(1, SourceFilterChange.checkBox(1, true))]);
    // Expand group if collapsed.
    if (find.text('Drama').evaluate().isEmpty) {
      await tester.tap(find.text('Genres'));
      await tester.pumpAndSettle();
    }
    final drama = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Drama'));
    final action = tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Action'));
    expect(drama.value, isTrue);
    expect(action.value, isFalse);
  });

  testWidgets('text field keeps controller and cursor across rebuilds', (tester) async {
    await _open(tester, const [SourceFilterChange.text(0, 'Oda')]);
    final field = find.widgetWithText(TextField, 'Author');
    final c1 = tester.widget<TextField>(field).controller!;
    expect(c1.text, 'Oda');
    await tester.enterText(field, 'Odab');
    c1.selection = const TextSelection.collapsed(offset: 2);
    // Trigger a rebuild via another filter.
    if (find.text('Action').evaluate().isEmpty) {
      await tester.tap(find.text('Genres'));
    } else {
      await tester.tap(find.text('Action'));
    }
    await tester.pumpAndSettle();
    final c2 = tester.widget<TextField>(field).controller!;
    expect(identical(c1, c2), isTrue);
    expect(c2.selection.baseOffset, 2);
  });

  testWidgets('apply returns nested group change; closing disposes controllers', (tester) async {
    List<SourceFilterChange>? out;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () async {
              out = await showSourceServerFiltersSheet(ctx,
                  sourceId: '1', initialChanges: const [SourceFilterChange.text(0, 'x')], preloadedFilters: _filters);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final ctrl = tester.widget<TextField>(find.widgetWithText(TextField, 'Author')).controller!;
    if (find.text('Action').evaluate().isEmpty) {
      await tester.tap(find.text('Genres'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(out, isNotNull);
    final g = out!.firstWhere((c) => c.groupChange != null);
    expect(g.position, 1);
    expect(g.groupChange!.position, 0);
    expect(g.groupChange!.checkBoxState, isTrue);
    // Disposed controller throws when listened to.
    expect(() => ctrl.addListener(() {}), throwsFlutterError);
  });

  testWidgets('UIS6-06: nested sort inside a group is restored and emitted', (tester) async {
    const filters = <SourceFilter>[
      SourceFilter(kind: SourceFilterKind.group, position: 0, name: 'Opts', children: [
        SourceFilter(kind: SourceFilterKind.sort, position: 0, name: 'Order', values: ['A', 'B']),
      ]),
    ];
    List<SourceFilterChange>? out;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () async {
              out = await showSourceServerFiltersSheet(ctx, sourceId: '1', preloadedFilters: filters,
                  initialChanges: [SourceFilterChange.group(0, SourceFilterChange.sort(0, index: 1, ascending: false))]);
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    final g = out!.single;
    expect(g.position, 0);
    expect(g.groupChange!.sortState!.index, 1);
    expect(g.groupChange!.sortState!.ascending, isFalse);
  });

  Future<void> openWith(WidgetTester tester, List<SourceFilter> filters) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showSourceServerFiltersSheet(ctx, sourceId: '1', initialChanges: const [], preloadedFilters: filters),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('UIS6-07: empty select/sort render disabled, no assert', (tester) async {
    await openWith(tester, const [
      SourceFilter(kind: SourceFilterKind.select, position: 0, name: 'Type'),
      SourceFilter(kind: SourceFilterKind.sort, position: 1, name: 'Order'),
    ]);
    expect(tester.takeException(), isNull);
    expect(find.text('No options'), findsNWidgets(2));
  });

  testWidgets('UIS6-08: tri-state fits at 360dp with 1.5 text scale', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openWith(tester, const [
      SourceFilter(kind: SourceFilterKind.triState, position: 0, name: 'Completed series only'),
    ]);
    expect(tester.takeException(), isNull);
    expect(find.text('Include'), findsOneWidget);
  });
}
