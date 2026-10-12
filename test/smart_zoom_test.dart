// test/smart_zoom_test.dart
//
// R9.1: smart zoom column-fit scale.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/reader/controller/smart_zoom.dart';

void main() {
  group('smartZoomScale', () {
    test('falls back when aspect unknown', () {
      expect(
          smartZoomScale(
              viewportWidth: 800, viewportHeight: 600),
          kDoubleTapFallbackScale);
    });

    test('falls back on degenerate inputs', () {
      expect(
          smartZoomScale(
              viewportWidth: 0, viewportHeight: 600, imageAspect: 0.7),
          kDoubleTapFallbackScale);
      expect(
          smartZoomScale(
              viewportWidth: 800, viewportHeight: 600, imageAspect: -1),
          kDoubleTapFallbackScale);
    });

    test('falls back when image already fills width (portrait page, portrait phone)', () {
      // viewport 0.5 <= image 0.7: contain-fit already fills the width.
      expect(
          smartZoomScale(
              viewportWidth: 400, viewportHeight: 800, imageAspect: 0.7),
          kDoubleTapFallbackScale);
    });

    test('zooms to fill width (portrait page, landscape tablet)', () {
      // 1200/800 = 1.5 viewport; 1.5/0.7 ~= 2.14.
      final scale = smartZoomScale(
          viewportWidth: 1200, viewportHeight: 800, imageAspect: 0.7);
      expect(scale, closeTo(1.5 / 0.7, 1e-9));
    });

    test('clamps to maxScale for extreme aspects', () {
      final scale = smartZoomScale(
          viewportWidth: 2000,
          viewportHeight: 500,
          imageAspect: 0.5,
          maxScale: 3.0);
      expect(scale, 3.0);
    });

    test('exact fit returns fallback (scale == 1)', () {
      expect(
          smartZoomScale(
              viewportWidth: 700, viewportHeight: 1000, imageAspect: 0.7),
          kDoubleTapFallbackScale);
    });
  });
}
