// UIX-13 (Jane decision a): settings that nothing reads must not be shown.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Downloads settings no longer offers the no-op auto-download category filter', () {
    final src = File('lib/src/features/settings/downloads_settings_screen.dart').readAsStringSync();
    expect(src, isNot(contains('autoDownloadCategoriesInclude')));
    expect(src, isNot(contains('autoDownloadCategoriesExclude')));
    expect(src, isNot(contains("'Auto-Download Categories'")));
  });

  test('Tracking settings no longer offers the no-op Metron auto-match switch', () {
    final src = File('lib/src/features/settings/tracking_settings_screen.dart').readAsStringSync();
    expect(src, isNot(contains('metronAutoMatch')));
    expect(src, isNot(contains("Text('Auto-Match Comic Metadata')")));
  });
}
