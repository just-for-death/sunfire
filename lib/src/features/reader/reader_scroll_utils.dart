import 'dart:math' as math;
import 'dart:ui' show Size;

/// Estimated webtoon page height before the real image size is known.
double estimateWebtoonPlaceholderHeight(double contentWidth, {double? cachedHeight}) {
  if (cachedHeight != null && cachedHeight > 0) return cachedHeight;
  return math.max(contentWidth * 1.5, 1.0);
}

/// Pick the page nearest the viewport center among candidates intersecting the band.
///
/// When the list is scrolled to its end and [lastPage] is on screen, that page
/// wins: a short last page (credits) never reaches the viewport center, so
/// the chapter stayed unread at the second-to-last page.
int? detectBestVisiblePage({
  required double viewportHeight,
  required List<({int page, double top, double bottom})> pages,
  bool scrolledToEnd = false,
  int? lastPage,
}) {
  if (pages.isEmpty) return null;
  if (scrolledToEnd && lastPage != null &&
      pages.any((p) => p.page == lastPage && p.bottom > 0 && p.top < viewportHeight)) {
    return lastPage;
  }
  final centerY = viewportHeight * 0.5;
  int? bestPage;
  double bestScore = -1;
  for (final p in pages) {
    final visibleTop = math.max(p.top, 0.0);
    final visibleBottom = math.min(p.bottom, viewportHeight);
    final visible = math.max(0.0, visibleBottom - visibleTop);
    if (visible <= 0) continue;
    final pageCenter = (p.top + p.bottom) / 2.0;
    final dist = (pageCenter - centerY).abs();
    final score = visible * 2.0 - dist;
    if (score > bestScore) {
      bestScore = score;
      bestPage = p.page;
    }
  }
  return bestPage;
}

/// Cumulative offset to the top of [targetPage] (1-based) using cached/estimated heights.
double resumeOffsetForPage({
  required int targetPage,
  required int pageCount,
  required double Function(int index) heightForIndex,
  required double Function(int index) gapAfterIndex,
}) {
  if (targetPage <= 1 || pageCount <= 0) return 0.0;
  final last = math.min(targetPage - 1, pageCount);
  double offset = 0.0;
  for (int i = 0; i < last; i++) {
    offset += heightForIndex(i);
    offset += gapAfterIndex(i);
  }
  return offset;
}

/// Whether persisted progress should regress to [page].
///
/// A [rereading] chapter (already read, reopened at page 1) records its
/// lower pages: otherwise nothing was saved until the last page, so History
/// and Continue Reading never showed the re-read. It stays read.
bool shouldPersistProgressPage({
  required int page,
  required int previousSaved,
  bool rereading = false,
}) {
  if (page <= 0) return false;
  if (!rereading && previousSaved > 0 && page < previousSaved) return false;
  return true;
}

double fittedHeightForWidth(Size intrinsic, double width) {
  if (intrinsic.width <= 0 || width <= 0) return estimateWebtoonPlaceholderHeight(width);
  return intrinsic.height * (width / intrinsic.width);
}
