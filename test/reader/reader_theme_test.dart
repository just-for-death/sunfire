// R1.7: reader_theme pure helpers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/features/reader/controller/reader_theme.dart';

void main() {
  group('parseReaderTheme', () {
    test('parses known labels', () {
      expect(parseReaderTheme('White'), ReaderThemeMode.white);
      expect(parseReaderTheme('Dark Gray'), ReaderThemeMode.darkGray);
      expect(parseReaderTheme('Black'), ReaderThemeMode.black);
      expect(parseReaderTheme('unknown'), ReaderThemeMode.black);
    });
  });

  group('canvasBackgroundColor', () {
    test('matches live reader slate/black/white', () {
      expect(canvasBackgroundColor(ReaderThemeMode.black), const Color(0xFF000000));
      expect(canvasBackgroundColor(ReaderThemeMode.darkGray), const Color(0xFF1A1A20));
      expect(canvasBackgroundColor(ReaderThemeMode.white), const Color(0xFFFFFFFF));
    });
  });

  group('activeColorFilter', () {
    test('none is null', () {
      expect(activeColorFilter(ReaderColorFilter.none), isNull);
    });

    test('invert returns a matrix filter', () {
      expect(activeColorFilter(ReaderColorFilter.invert), isA<ColorFilter>());
    });

    test('nightAmber uses soft amber burn', () {
      final filter = activeColorFilter(ReaderColorFilter.nightAmber);
      expect(filter, isNotNull);
    });
  });

  group('imageBoxFit', () {
    test('maps scale types', () {
      expect(imageBoxFit(ImageScaleType.fitWidth), BoxFit.fitWidth);
      expect(imageBoxFit(ImageScaleType.fitHeight), BoxFit.fitHeight);
      expect(imageBoxFit(ImageScaleType.fitScreen), BoxFit.contain);
      expect(imageBoxFit(ImageScaleType.original), BoxFit.none);
    });
  });
}
