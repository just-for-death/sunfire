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
/// Rules:
/// - Both known & equal → allow
/// - One known, one unknown → allow (use the known one)
/// - Both unknown → DENY (can't verify they're the same actual source)
/// - Both known & different → DENY
bool prefetchSourceMatches({required String? prefetchedSource, required String? currentSource}) {
  bool unknown(String? s) => s == null || s.isEmpty || s == 'unknown';
  final pKnown = !unknown(prefetchedSource);
  final cKnown = !unknown(currentSource);
  if (pKnown && cKnown) return prefetchedSource == currentSource;
  if (pKnown || cKnown) return true; // exactly one known → trust it
  return false; // both unknown → can't verify, discard
}

/// Fraction of a chapter after which the next chapter is prefetched (ISS-032).
const double kNextChapterPrefetchThreshold = 0.65;

/// Webtoon: scroll ratio (0..1) past the threshold.
bool shouldPrefetchNextChapterAtRatio(double ratio) => ratio >= kNextChapterPrefetchThreshold;

/// Paged: 1-based [page] of [totalPages] past the threshold.
bool shouldPrefetchNextChapterAtPage(int page, int totalPages) =>
    totalPages > 0 && page >= (totalPages * kNextChapterPrefetchThreshold).round();