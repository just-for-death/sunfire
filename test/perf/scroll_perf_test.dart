// Performance benchmarks for scroll and list rendering.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scroll performance', () {
    testWidgets('ListView with 100 items builds within budget', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
                subtitle: Text('Subtitle for item $index'),
                leading: const Icon(Icons.article),
              ),
            ),
          ),
        ),
      );
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(400));
    });

    testWidgets('GridView with 50 items builds within budget', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
              ),
              itemCount: 50,
              itemBuilder: (context, index) => Card(
                child: Column(
                  children: [
                    Expanded(child: Container(color: Colors.grey)),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Item $index', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    testWidgets('Nested scroll does not cause layout errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  5,
                  (i) => SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, j) => ListTile(
                        title: Text('Section $i, Item $j'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}