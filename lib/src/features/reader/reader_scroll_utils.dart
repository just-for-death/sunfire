import 'dart:math' as math;
import 'dart:ui' show Size;
import 'package:flutter/painting.dart' show ImageInfo;

/// Estimated webtoon page height before the real image size is known.
double estimateWebtoonPlaceholderHeight(double contentWidth, {double? cachedHeight}) {
  if (cachedHeight != null && cachedHeight > 0) return cachedHeight;
  return math.max(contentWidth * 1.5, 1.0);
}

/// Pick the page nearest the viewport center among candidates intersecting the band.
int? detectBestVisiblePage({
  required double viewportHeight,
  required List<({int page, double top, double bottom})> pages,
}) {
  if (pages.isEmpty) return null;
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
bool shouldPersistProgressPage({
  required int page,
  required int previousSaved,
}) {
  if (page <= 0) return false;
  if (previousSaved > 0 && page < previousSaved) return false;
  return true;
}

Size? sizeFromImageInfo(ImageInfo info) {
  final img = info.image;
  return Size(img.width.toDouble(), img.height.toDouble());
}

double fittedHeightForWidth(Size intrinsic, double width) {
  if (intrinsic.width <= 0 || width <= 0) return estimateWebtoonPlaceholderHeight(width);
  return intrinsic.height * (width / intrinsic.width);
}
