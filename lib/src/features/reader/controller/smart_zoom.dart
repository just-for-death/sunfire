// lib/src/features/reader/controller/smart_zoom.dart
//
// R9.1: Smart zoom - double-tap zooms to fit the content column width.
//
// Pages render with BoxFit.contain: the image fills the viewport width iff
// viewportAspect <= imageAspect. Otherwise (e.g. portrait page on a wide
// landscape viewport) a fixed 2.5x zoom overshoots or undershoots. This
// computes the exact scale that fills the width, clamped to a sane range,
// falling back to the legacy fixed scale when dimensions are unknown.

library;

/// Legacy fixed double-tap scale (used when dimensions are unknown).
const double kDoubleTapFallbackScale = 2.5;

/// Upper bound for computed column-fit scales.
const double kMaxSmartZoomScale = 4.0;

/// Compute the double-tap zoom scale that fits the content column width.
///
/// - Returns [fallback] when [imageAspect] is unknown/non-positive or the
///   viewport is degenerate.
/// - Returns [fallback] when the image already fills the width
///   (viewportAspect <= imageAspect): a fixed zoom still applies, matching
///   legacy behaviour.
/// - Otherwise returns viewportAspect/imageAspect clamped to
///   [1.0, maxScale].
double smartZoomScale({
  required double viewportWidth,
  required double viewportHeight,
  double? imageAspect,
  double fallback = kDoubleTapFallbackScale,
  double maxScale = kMaxSmartZoomScale,
}) {
  if (viewportWidth <= 0 ||
      viewportHeight <= 0 ||
      imageAspect == null ||
      imageAspect <= 0) {
    return fallback;
  }
  final viewportAspect = viewportWidth / viewportHeight;
  final scale = viewportAspect / imageAspect;
  if (scale <= 1.0) return fallback;
  return scale.clamp(1.0, maxScale);
}
