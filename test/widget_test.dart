// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:catalyst/src/catalyst_app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // ProviderScope is required for Riverpod
    await tester.pumpWidget(const ProviderScope(child: CatalystApp()));

    // Basic check to ensure the app builds without crashing
    expect(find.byType(CatalystApp), findsOneWidget);
  });
}
