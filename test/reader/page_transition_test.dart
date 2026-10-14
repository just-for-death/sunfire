// IMP-014: page transition modes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/page_transition.dart';

Future<PageController> _pump(WidgetTester t) async {
  final c = PageController();
  await t.pumpWidget(MaterialApp(
    home: PageView(controller: c, children: [for (var i = 0; i < 5; i++) Text('p$i')]),
  ));
  return c;
}

void main() {
  test('parse falls back to slide; setting validates and persists', () async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    expect(parsePageTransition(null), PageTransitionMode.slide);
    expect(parsePageTransition('bogus'), PageTransitionMode.slide);
    expect(parsePageTransition('fade'), PageTransitionMode.fade);
    expect(SettingsService.instance.pageTransition, 'slide');
    SettingsService.instance.pageTransition = 'none';
    expect(SettingsService.instance.pageTransition, 'none');
    SettingsService.instance.pageTransition = 'warp';
    expect(SettingsService.instance.pageTransition, 'none');
  });

  testWidgets('none jumps in the same frame', (t) async {
    final c = await _pump(t);
    turnPage(c, forward: true, mode: PageTransitionMode.none);
    await t.pump();
    expect(c.page, 1.0);
    turnPage(c, forward: false, mode: PageTransitionMode.none);
    await t.pump();
    expect(c.page, 0.0);
    turnPage(c, forward: false, mode: PageTransitionMode.none); // stays at 0
    await t.pump();
    expect(c.page, 0.0);
  });

  testWidgets('fade also jumps (the view draws the cross-fade)', (t) async {
    final c = await _pump(t);
    turnPage(c, forward: true, mode: PageTransitionMode.fade);
    await t.pump();
    expect(c.page, 1.0);
  });

  testWidgets('slide animates over kPageSlideDuration', (t) async {
    final c = await _pump(t);
    turnPage(c, forward: true, mode: PageTransitionMode.slide);
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(c.page, inExclusiveRange(0.0, 1.0));
    await t.pumpAndSettle();
    expect(c.page, 1.0);
  });
}
