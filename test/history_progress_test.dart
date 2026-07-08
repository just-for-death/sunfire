import 'package:flutter_test/flutter_test.dart';

import 'package:catalyst/src/features/history/domain/history_group.dart';
import 'package:catalyst/src/features/history/presentation/history_reader_navigation.dart';

void main() {
  test('inProgressHistoryItems returns empty when all completed', () {
    final groups = <HistoryGroup>[];
    expect(inProgressHistoryItems(groups), isEmpty);
  });
}
