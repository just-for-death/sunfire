// Pure helpers for Updates feed grouping (UIS-P2-F / J2K–Komikku style).

/// One series cluster inside a date section.
class SeriesUpdateGroup {
  const SeriesUpdateGroup({
    required this.mangaId,
    required this.title,
    required this.items,
  });

  final int mangaId;
  final String title;
  final List<Map<String, dynamic>> items;
}

/// Date section containing series groups (order preserved).
class DateUpdateSection {
  const DateUpdateSection({
    required this.dateHeader,
    required this.series,
  });

  final String dateHeader;
  final List<SeriesUpdateGroup> series;

  int get chapterCount =>
      series.fold<int>(0, (sum, s) => sum + s.items.length);
}

/// Groups flat update maps by [dateHeader], then by [mangaId].
///
/// Order of first appearance is preserved for both dates and series.
List<DateUpdateSection> groupUpdatesByDateThenSeries(
  List<Map<String, dynamic>> items,
) {
  final sections = <DateUpdateSection>[];
  final sectionIndex = <String, int>{};

  for (final item in items) {
    final header = (item['dateHeader'] as String?) ?? 'Recent';
    final mangaId = item['mangaId'] as int? ?? 0;
    final title = (item['title'] as String?) ?? 'Manga';

    var si = sectionIndex[header];
    if (si == null) {
      si = sections.length;
      sectionIndex[header] = si;
      sections.add(DateUpdateSection(dateHeader: header, series: []));
    }

    final seriesList = sections[si].series;
    final existing = seriesList.indexWhere((s) => s.mangaId == mangaId);
    if (existing >= 0) {
      seriesList[existing].items.add(item);
    } else {
      seriesList.add(
        SeriesUpdateGroup(
          mangaId: mangaId,
          title: title,
          items: [item],
        ),
      );
    }
  }

  return sections;
}
