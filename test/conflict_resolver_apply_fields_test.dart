// ConflictResolver is production-callable (no longer @visibleForTesting).

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver.resolve', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver(
        strategy: ConflictResolutionStrategy.lastWriteWins,
      );
    });

    test('LWW picks newer remote', () {
      final value = resolver.resolve(
        entityType: 'chapter',
        entityId: 1,
        field: 'lastPageRead',
        localValue: 3,
        remoteValue: 8,
        localTimestamp: DateTime.fromMillisecondsSinceEpoch(1000),
        remoteTimestamp: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      expect(value, 8);
    });

    test('LWW keeps newer local', () {
      final value = resolver.resolve(
        entityType: 'chapter',
        entityId: 1,
        field: 'lastPageRead',
        localValue: 9,
        remoteValue: 2,
        localTimestamp: DateTime.fromMillisecondsSinceEpoch(3000),
        remoteTimestamp: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      expect(value, 9);
    });

    test('CRDT max for lastPageRead', () {
      final crdt = ConflictResolver(
        strategy: ConflictResolutionStrategy.crdt,
      );
      final value = crdt.resolve(
        entityType: 'chapter',
        entityId: 1,
        field: 'lastPageRead',
        localValue: 5,
        remoteValue: 2,
        localTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
        remoteTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(value, 5);
    });

    test('userChoice returns marker', () {
      final choice = ConflictResolver(
        strategy: ConflictResolutionStrategy.userChoice,
      );
      final value = choice.resolve(
        entityType: 'manga',
        entityId: 1,
        field: 'title',
        localValue: 'A',
        remoteValue: 'B',
        localTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
        remoteTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(value, isA<UserChoiceMarker>());
    });
  });
}
