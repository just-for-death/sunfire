import 'package:flutter_test/flutter_test.dart';

import 'package:sunfire/src/core/sync/sync_engine.dart';

void main() {
  group('mergeLastPageRead — critical fix for progress rewind', () {
    test('local read (page 50), server unread (page 0) → keeps local 50', () {
      // User read to page 50 locally, another device marked unread (server page=0)
      // Should NOT rewind to 0
      final result = mergeLastPageRead(
        local: 50,
        server: 0,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 50, reason: 'Local progress should not be rewound when server has less progress');
    });

    test('local read (page 50), server read (page 60) → takes server 60', () {
      // Server has more progress
      final result = mergeLastPageRead(
        local: 50,
        server: 60,
        localWasRead: true,
        serverIsRead: true,
        hasPendingMutation: false,
      );
      expect(result, 60, reason: 'Should take server progress when it is greater');
    });

    test('local read (page 50), server unread (page 10) → keeps local 50', () {
      // Server unread but has some progress (e.g., page 10), local has 50
      final result = mergeLastPageRead(
        local: 50,
        server: 10,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 50, reason: 'Local progress should win when greater than server');
    });

    test('local unread (page 5), server read (page 50) → takes server 50', () {
      // Server has more progress
      final result = mergeLastPageRead(
        local: 5,
        server: 50,
        localWasRead: false,
        serverIsRead: true,
        hasPendingMutation: false,
      );
      expect(result, 50);
    });

    test('hasPendingMutation=true → always returns local', () {
      // Pending mutation should always preserve local value
      final result = mergeLastPageRead(
        local: 10,
        server: 100,
        localWasRead: true,
        serverIsRead: true,
        hasPendingMutation: true,
      );
      expect(result, 10);
    });

    test('both unread, local 10, server 5 → returns 10 (max)', () {
      final result = mergeLastPageRead(
        local: 10,
        server: 5,
        localWasRead: false,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 10);
    });

    test('local read (page 1), server unread (page 0) → keeps local 1', () {
      // Edge case: user just started reading (page 1), server says unread (page 0)
      final result = mergeLastPageRead(
        local: 1,
        server: 0,
        localWasRead: true,
        serverIsRead: false,
        hasPendingMutation: false,
      );
      expect(result, 1, reason: 'Even page 1 should not be rewound to 0');
    });
  });
}