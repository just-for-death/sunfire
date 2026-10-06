// UIS-11/12 + ISS-021: dialog title rows, controller disposal, proxy masking.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/ui/widgets/dialog_controllers.dart';
import 'package:sunfire/src/ui/widgets/dialog_title.dart';
import 'package:sunfire/src/ui/widgets/proxy_url_display.dart';

class _TrackingController extends TextEditingController {
  bool disposed = false;
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  const titles = [
    'Exit Sunfire',
    'Remove from Library',
    'Migrate Manga',
    'Client Credentials',
    'FlareSolverr Proxy',
  ];

  for (final t in titles) {
    testWidgets('"$t" title fits at 320px and 2.0x text', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(
          body: AlertDialog(
            title: DialogTitle(icon: Icons.shield_outlined, text: t),
            content: const Text('Body'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DialogTitle), findsOneWidget);
    });
  }

  testWidgets('dialog controllers are disposed after the dialog closes',
      (tester) async {
    final c = _TrackingController();
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      }),
    ));
    unawaited(showDialog<void>(
      context: ctx,
      builder: (d) => AlertDialog(
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Close')),
        ],
      ),
    ).then((_) => disposeAfterDialog([c])));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Close'));
    await tester.pump();
    expect(c.disposed, isFalse, reason: 'still animating out');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(c.disposed, isTrue);
    expect(tester.takeException(), isNull);
  });

  test('proxy URL credentials are masked for display', () {
    expect(maskProxyUrlForDisplay('http://user:pa55@10.0.0.2:8191/v1'),
        'http://•••@10.0.0.2:8191/v1');
    expect(maskProxyUrlForDisplay('http://10.0.0.2:8191/v1'),
        'http://10.0.0.2:8191/v1');
    expect(maskProxyUrlForDisplay(''), '');
  });
}
