// UIS-P2-D: two-pane manga details on landscape tablets only.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/manga_detail/manga_detail_layout.dart';
import 'package:sunfire/src/main_shell.dart' show sunfireDetailTwoPaneMinWidth;
import 'package:sunfire/src/ui/shell/sunfire_breakpoints.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, {double railWidth = 0}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Row(
        children: [
          SizedBox(width: railWidth),
          Expanded(
            child: MangaDetailAdaptiveLayout(
              twoPaneBuilder: (_) => const Row(
                children: [
                  SizedBox(width: 380, child: Text('info')),
                  Expanded(child: Text('chapters')),
                ],
              ),
              singlePaneBuilder: (_) => const CustomScrollView(
                slivers: [SliverToBoxAdapter(child: Text('single'))],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  const twoPane = ValueKey('mangaDetailTwoPane');
  const singlePane = ValueKey('mangaDetailSinglePane');

  test('gate constant matches shell detail breakpoint and sits above narrow tablet', () {
    expect(SunfireBreakpoints.detailTwoPaneMinWidth, sunfireDetailTwoPaneMinWidth);
    expect(SunfireBreakpoints.detailTwoPaneMinWidth,
        greaterThan(SunfireBreakpoints.narrowTabletMaxWidth));
  });

  test('usesTwoPaneDetailsForSize: landscape tablets only', () {
    bool f(Size s, [double? w]) =>
        SunfireBreakpoints.usesTwoPaneDetailsForSize(s, w ?? s.width);
    expect(f(const Size(1194, 834)), isTrue); // iPad Pro 11 landscape
    expect(f(const Size(1280, 800)), isTrue); // Android tablet landscape
    expect(f(const Size(834, 1194)), isFalse); // iPad portrait
    expect(f(const Size(1024, 1366)), isFalse); // iPad Pro 12.9 portrait
    expect(f(const Size(850, 390)), isFalse); // phone landscape
    expect(f(const Size(390, 844)), isFalse); // phone portrait
    expect(f(const Size(1194, 834), 597), isFalse); // narrow content pane
  });

  testWidgets('landscape tablet shows two-pane (info + persistent chapters)', (tester) async {
    await _pumpAt(tester, const Size(1194, 834), railWidth: 80);
    expect(find.byKey(twoPane), findsOneWidget);
    expect(find.byKey(singlePane), findsNothing);
    expect(find.text('info'), findsOneWidget);
    expect(find.text('chapters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portrait tablet keeps single-pane', (tester) async {
    await _pumpAt(tester, const Size(834, 1194), railWidth: 80);
    expect(find.byKey(singlePane), findsOneWidget);
    expect(find.byKey(twoPane), findsNothing);
  });

  testWidgets('phone portrait and landscape keep single-pane', (tester) async {
    await _pumpAt(tester, const Size(390, 844));
    expect(find.byKey(singlePane), findsOneWidget);
    await _pumpAt(tester, const Size(850, 390));
    expect(find.byKey(singlePane), findsOneWidget);
    expect(find.byKey(twoPane), findsNothing);
  });

  testWidgets('rotating a tablet switches layouts', (tester) async {
    await _pumpAt(tester, const Size(1280, 800));
    expect(find.byKey(twoPane), findsOneWidget);
    await _pumpAt(tester, const Size(800, 1280));
    expect(find.byKey(singlePane), findsOneWidget);
  });
}
