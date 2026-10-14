import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/recommendations.dart';
import 'package:sunfire/src/features/manga_detail/more_like_this_row.dart';

void main() {
  final target = Manga()
    ..serverId = 1
    ..title = 'Target';

  testWidgets('IMP-004 row hidden when no recommendations', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MoreLikeThisRow(manga: target, loader: (_) async => const [])),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('moreLikeThisRow')), findsNothing);
  });

  testWidgets('IMP-004 row shows titles and reason', (tester) async {
    final other = Manga()
      ..serverId = 2
      ..title = 'Similar One';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MoreLikeThisRow(
          manga: target,
          loader: (_) async => [MangaRecommendation(other, 3, const ['Same author'])],
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();
    expect(find.text('More like this'), findsOneWidget);
    expect(find.text('Similar One'), findsOneWidget);
    expect(find.text('Same author'), findsOneWidget);
  });
}
