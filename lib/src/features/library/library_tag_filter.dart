// Pure helpers for L10.2 library custom-tag filtering (testable, no Flutter).

/// True when [mangaTagIds] includes [selectedTagId].
///
/// A null/zero [selectedTagId] means "no tag filter" (always matches).
bool mangaMatchesTagFilter({
  required List<int> mangaTagIds,
  int? selectedTagId,
}) {
  if (selectedTagId == null || selectedTagId == 0) return true;
  return mangaTagIds.contains(selectedTagId);
}

/// Count library titles carrying [tagId].
int countMangaWithTag(Iterable<List<int>> mangaTagIdLists, int tagId) {
  var n = 0;
  for (final ids in mangaTagIdLists) {
    if (ids.contains(tagId)) n++;
  }
  return n;
}
