import 'package:catalyst/src/constants/app_breakpoints.dart';
import 'package:catalyst/src/utils/platform/platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders [child] under a synthetic screen and hands back the inner context.
Future<BuildContext> _contextForScreen(
  WidgetTester tester, {
  required Size size,
  double bottomPadding = 0,
  Widget Function(Widget body)? shell,
}) async {
  late BuildContext captured;
  final body = Builder(
    builder: (context) {
      captured = context;
      return const SizedBox.shrink();
    },
  );

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: EdgeInsets.only(bottom: bottomPadding),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: shell?.call(body) ?? body,
      ),
    ),
  );
  return captured;
}

void main() {
  group('AppBreakpoints.usesSideRail', () {
    testWidgets('phone portrait uses the phone shell', (tester) async {
      final context =
          await _contextForScreen(tester, size: const Size(411, 891));
      expect(AppBreakpoints.usesSideRail(context), isFalse);
    });

    testWidgets('large phone in landscape stays on the phone shell',
        (tester) async {
      // Wide enough for a rail, far too short for one.
      final context =
          await _contextForScreen(tester, size: const Size(932, 430));
      expect(AppBreakpoints.usesSideRail(context), isFalse);
    });

    testWidgets('narrow tablet window stays on the phone shell',
        (tester) async {
      final context =
          await _contextForScreen(tester, size: const Size(660, 900));
      expect(AppBreakpoints.usesSideRail(context), isFalse);
    });

    testWidgets('tablet uses the side rail', (tester) async {
      final context =
          await _contextForScreen(tester, size: const Size(1024, 768));
      expect(AppBreakpoints.usesSideRail(context), isTrue);
    });
  });

  group('scrollBottomInset', () {
    testWidgets('reserves nothing extra when no bar overlaps the body',
        (tester) async {
      final context =
          await _contextForScreen(tester, size: const Size(1024, 768));
      expect(scrollBottomInset(context: context), 0);
    });

    testWidgets('reserves whatever the shell reports as bottom padding',
        (tester) async {
      // Scaffold folds an extendBody bottom bar into this padding.
      final context = await _contextForScreen(
        tester,
        size: const Size(411, 891),
        bottomPadding: 80,
      );
      expect(scrollBottomInset(context: context), 80);
    });

    testWidgets('adds FAB clearance on top of the bar', (tester) async {
      final context = await _contextForScreen(
        tester,
        size: const Size(411, 891),
        bottomPadding: 80,
      );
      expect(
        scrollBottomInset(hasFab: true, context: context),
        80 + kFabScrollBottomInset,
      );
    });
  });
}
