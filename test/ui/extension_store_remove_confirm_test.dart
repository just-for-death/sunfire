import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/settings/extension_repos_screen.dart';

Future<bool?> _open(WidgetTester tester, String button) async {
  bool? result;
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await confirmRemoveStore(context, 'Keiyoushi'),
        child: const Text('go'),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
  expect(find.text('Remove store?'), findsOneWidget);
  expect(find.textContaining('Keiyoushi'), findsOneWidget);
  await tester.tap(find.text(button));
  await tester.pumpAndSettle();
  expect(find.text('Remove store?'), findsNothing);
  return result;
}

void main() {
  testWidgets('ISS-099 Cancel keeps the store', (tester) async {
    expect(await _open(tester, 'Cancel'), isFalse);
  });
  testWidgets('ISS-099 Remove confirms', (tester) async {
    expect(await _open(tester, 'Remove'), isTrue);
  });
}
