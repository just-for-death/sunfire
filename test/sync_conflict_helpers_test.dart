// test/sync_conflict_helpers_test.dart
//
// Pure helpers for SyncManager conflict UI wiring.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/sync_conflict_helpers.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart' show ConflictResolution;

void main() {
  group('pickConflictValue', () {
    test('localWins returns local', () {
      expect(
        pickConflictValue(
          resolution: ConflictResolution.localWins,
          localData: 'L',
          remoteData: 'R',
          entityType: 'manga',
          field: 'title',
        ),
        'L',
      );
    });

    test('remoteWins returns remote', () {
      expect(
        pickConflictValue(
          resolution: ConflictResolution.remoteWins,
          localData: 'L',
          remoteData: 'R',
          entityType: 'manga',
          field: 'title',
        ),
        'R',
      );
    });

    test('userChoice returns null', () {
      expect(
        pickConflictValue(
          resolution: ConflictResolution.userChoice,
          localData: 1,
          remoteData: 2,
          entityType: 'chapter',
          field: 'lastPageRead',
        ),
        isNull,
      );
    });

    test('merge uses CRDT max for lastPageRead', () {
      expect(
        pickConflictValue(
          resolution: ConflictResolution.merge,
          localData: 3,
          remoteData: 7,
          entityType: 'chapter',
          field: 'lastPageRead',
        ),
        7,
      );
    });
  });

  group('syncPhaseLabel', () {
    test('maps known phases', () {
      expect(syncPhaseLabel('fetchingDelta'), 'Fetching changes…');
      expect(syncPhaseLabel('completed'), 'Done');
      expect(syncPhaseLabel('unknown_x'), 'unknown_x');
    });
  });
}
