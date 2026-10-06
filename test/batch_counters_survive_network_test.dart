// UIX-15 (Jane decision): download batch counters survive a network/charger
// interruption; the no-op "save before purge" in _finishBatch is gone.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final src = File('lib/src/core/services/download_manager_service.dart').readAsStringSync();

  test('network-gate interruption no longer purges batch counters', () {
    expect(src, isNot(contains('if (stoppedForNetwork && !_isQueuePaused) {')));
    // The only purge left is in _finishBatch (plus the method itself).
    final finishStart = src.indexOf('Future<void> _finishBatch() async {');
    expect(finishStart, greaterThan(0));
    final before = src.substring(0, finishStart);
    expect(RegExp(r'_purgeBatchCounters\(\);').allMatches(before).length, 0,
        reason: 'no purge call outside _finishBatch');
  });

  test('_finishBatch does not save batch state right before purging it', () {
    final finishStart = src.indexOf('Future<void> _finishBatch() async {');
    final body = src.substring(finishStart, src.indexOf('Future<void> _downloadChapterLocally', finishStart));
    expect(body, contains('_purgeBatchCounters();'));
    expect(body, isNot(contains('_saveBatchState()')));
  });
}
