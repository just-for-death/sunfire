// test/updates_stable_diff_test.dart
//
// S6.2: stable diffing lookup for the Updates slivers.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/features/updates/updates_screen.dart';

void main() {
  List<Map<String, dynamic>> items(List<String> keys) =>
      [for (final k in keys) {'key': k}];

  group('UpdatesScreen.findSeriesItemIndex', () {
    test('finds index by card key', () {
      final list = items(['a', 'b', 'c']);
      expect(UpdatesScreen.findSeriesItemIndex(list, const ValueKey('b')), 1);
      expect(UpdatesScreen.findSeriesItemIndex(list, const ValueKey('a')), 0);
      expect(UpdatesScreen.findSeriesItemIndex(list, const ValueKey('c')), 2);
    });

    test('returns null for unknown key', () {
      expect(UpdatesScreen.findSeriesItemIndex(items(['a']), const ValueKey('z')),
          isNull);
    });

    test('returns null for non-ValueKey or null', () {
      final list = items(['a']);
      expect(UpdatesScreen.findSeriesItemIndex(list, UniqueKey()), isNull);
      expect(UpdatesScreen.findSeriesItemIndex(list, null), isNull);
      expect(UpdatesScreen.findSeriesItemIndex([], const ValueKey('a')),
          isNull);
    });
  });
}
