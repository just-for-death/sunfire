import 'dart:math' as math;

/// IMP-009: decode reader pages near display size instead of full resolution.
///
/// Returns the `cacheWidth` (physical pixels) for an image shown [logicalWidth]
/// wide, with [zoomHeadroom] extra so pinch-zoom stays sharp. Returns null when
/// the width is unknown, so callers decode at full size as before. Flutter's
/// ResizeImage never upscales, so small sources stay at their own size.
int? readerDecodeCacheWidth(
  double? logicalWidth,
  double devicePixelRatio, {
  double zoomHeadroom = 2.0,
  int maxCacheWidth = 4096,
}) {
  if (logicalWidth == null || !logicalWidth.isFinite || logicalWidth <= 0) return null;
  final dpr = devicePixelRatio > 0 ? devicePixelRatio : 1.0;
  final px = (logicalWidth * dpr * zoomHeadroom).ceil();
  return math.min(px, maxCacheWidth);
}
