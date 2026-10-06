import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/updates/updates_feed_grouping.dart';

void main() {
  group('groupUpdatesByDateThenSeries', () {
    test('groups by date then mangaId preserving order', () {
      final items = [
        {'dateHeader': 'Today', 'mangaId': 1, 'title': 'A'},
        {'dateHeader': 'Today', 'mangaId': 2, 'title': 'B'},
        {'dateHeader': 'Today', 'mangaId': 1, 'title': 'A'},
        {'dateHeader': 'Yesterday', 'mangaId': 1, 'title': 'A'},
      ];
      final sections = groupUpdatesByDateThenSeries(items);
      expect(sections.length, 2);
      expect(sections[0].dateHeader, 'Today');
      expect(sections[0].series.length, 2);
      expect(sections[0].series[0].mangaId, 1);
      expect(sections[0].series[0].items.length, 2);
      expect(sections[0].series[1].mangaId, 2);
      expect(sections[0].series[1].items.length, 1);
      expect(sections[0].chapterCount, 3);
      expect(sections[1].dateHeader, 'Yesterday');
      expect(sections[1].series.single.mangaId, 1);
    });

    test('empty input yields empty sections', () {
      expect(groupUpdatesByDateThenSeries(const []), isEmpty);
    });
  });
}
