import 'package:catalyst/src/features/history/domain/history_group.dart';
import 'package:catalyst/src/features/history/presentation/history_reader_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inProgressHistoryItems returns empty when all completed', () {
    final groups = <HistoryGroup>[];
    expect(inProgressHistoryItems(groups), isEmpty);
  });

  test('historyGroupsExcludingCarousel returns empty for empty input', () {
    expect(historyGroupsExcludingCarousel(const []), isEmpty);
  });
}
