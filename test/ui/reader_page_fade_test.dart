import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/controller/reader_canvas.dart';

void main() {
  testWidgets('IMP-014 ReaderPageFadeIn fades from 0 to 1', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: ReaderPageFadeIn(child: Text('p')),
    ));
    FadeTransition ft() => tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(ft().opacity.value, 0);
    await tester.pumpAndSettle();
    expect(ft().opacity.value, 1);
  });
}
