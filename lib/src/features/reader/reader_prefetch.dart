// Pure helpers for the reader's next-chapter prefetch cache (UIX-12).

/// The single prefetch cache key. Both the writer (`_prefetchChapter`) and the
/// reader (`_loadPages`) MUST use it.
///
/// It is deliberately **source-free**. The writer only knows the parent
/// manga's stored `sourceName` (often null → `'unknown'`), while the reader may
/// have auto-detected the source from the chapter URL. Folding either into the
/// key made the two sides disagree, so prefetched pages were never used. The
/// target id + manga id are already unique per manga row (including negative
/// local ids); source mismatches are handled on the value side by
/// [prefetchSourceMatches].
String readerPrefetchKey({required int chapterTargetId, required int mangaId}) =>
    '$chapterTargetId|$mangaId';

/// Whether a prefetched entry resolved against [prefetchedSource] may be served
/// while the reader's current source is [currentSource].
///
/// Discards only a *known* conflict (e.g. after a migration). If either side
/// does not know its source (`null`, empty, or the writer's `'unknown'`
/// placeholder) the entry is kept: the URLs were resolved for this exact
/// chapter row.
bool prefetchSourceMatches({required String? prefetchedSource, required String? currentSource}) {
  bool unknown(String? s) => s == null || s.isEmpty || s == 'unknown';
  if (unknown(prefetchedSource) || unknown(currentSource)) return true;
  return prefetchedSource == currentSource;
}
