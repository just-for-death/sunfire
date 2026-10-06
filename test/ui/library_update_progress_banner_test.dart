import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/library_update_service.dart';
import 'package:sunfire/src/ui/widgets/library_update_progress_banner.dart';

void main() {
  group('libraryUpdateSkippedLabel', () {
    test('null when both zero', () {
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 0, skippedMangasCount: 0),
        isNull,
      );
    });

    test('categories only', () {
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 5, skippedMangasCount: 0),
        '5 categories skipped',
      );
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 1, skippedMangasCount: 0),
        '1 category skipped',
      );
    });

    test('manga only', () {
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 0, skippedMangasCount: 76),
        '76 manga skipped',
      );
    });

    test('both', () {
      expect(
        libraryUpdateSkippedLabel(skippedCategoriesCount: 2, skippedMangasCount: 10),
        '2 categories skipped · 10 manga skipped',
      );
    });
  });

  testWidgets('banner hidden when idle', (tester) async {
    expect(LibraryUpdateService.instance.isUpdating, isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LibraryUpdateProgressBanner()),
      ),
    );
    expect(find.byKey(const Key('library_update_progress_banner')), findsNothing);
    expect(find.byKey(const Key('library_update_skipped_label')), findsNothing);
  });

  testWidgets('asSliver mounts in CustomScrollView without error when idle', (tester) async {
    expect(LibraryUpdateService.instance.isUpdating, isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              LibraryUpdateProgressBanner(asSliver: true),
              // Keep a real sliver so the scroll view has extent.
              SliverToBoxAdapter(child: SizedBox(height: 8, child: Text('below'))),
            ],
          ),
        ),
      ),
    );
    expect(find.text('below'), findsOneWidget);
    expect(find.byKey(const Key('library_update_progress_banner')), findsNothing);
  });
}
