import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/download_status_merge.dart';
import 'package:sunfire/src/core/sync/server_capabilities.dart';
import 'package:sunfire/src/core/sync/suwayomi_settings_fields.dart';

void main() {
  group('ISS-064 persist routing fields', () {
    test('flareSolverrEnabled is server; opdsItemsPerPage is user', () {
      expect(isServerSettingsInputField('flareSolverrEnabled'), isTrue);
      expect(isUserSettingsInputField('opdsItemsPerPage'), isTrue);
      expect(isServerSettingsInputField('opdsItemsPerPage'), isFalse);
    });
  });

  group('ISS-066 ServerCapabilities', () {
    test('empty defaults', () {
      expect(ServerCapabilities.empty.probed, isFalse);
      expect(ServerCapabilities.empty.hasUserField, isFalse);
      expect(ServerCapabilities.empty.authModes, contains('UI_LOGIN'));
    });

    test('copyWith / toJson', () {
      final c = ServerCapabilities.empty.copyWith(
        version: 'v2.4.2379',
        buildType: 'Preview',
        hasUserSettings: true,
        hasUserField: true,
        probed: true,
      );
      expect(c.version, 'v2.4.2379');
      expect(c.toJson()['hasUserSettings'], isTrue);
      expect(c.toJson()['probed'], isTrue);
    });
  });

  group('ISS-067 download status merge', () {
    test('initial replaces queue', () {
      final merged = mergeDownloadStatusEvent(
        {
          'state': 'STOPPED',
          'queue': [
            {
              'chapter': {'id': 1},
              'progress': 0.1,
            }
          ],
        },
        {
          'state': 'RUNNING',
          'omittedUpdates': false,
          'initial': [
            {
              'position': 0,
              'progress': 0.5,
              'state': 'DOWNLOADING',
              'tries': 0,
              'chapter': {'id': 9, 'name': 'Ch 9'},
              'manga': {'id': 2, 'title': 'X'},
            }
          ],
        },
      );
      expect(merged.needsRefetch, isFalse);
      expect(merged.status['state'], 'RUNNING');
      final queue = merged.status['queue'] as List;
      expect(queue, hasLength(1));
      expect((queue.first as Map)['chapter']['id'], 9);
    });

    test('omittedUpdates requests refetch', () {
      final merged = mergeDownloadStatusEvent(null, {
        'state': 'RUNNING',
        'omittedUpdates': true,
        'updates': <Map<String, dynamic>>[],
      });
      expect(merged.needsRefetch, isTrue);
    });

    test('update upserts by chapter id', () {
      final base = mergeDownloadStatusEvent(null, {
        'state': 'RUNNING',
        'initial': [
          {
            'position': 0,
            'progress': 0.1,
            'state': 'DOWNLOADING',
            'chapter': {'id': 3, 'name': 'A'},
          }
        ],
      });
      final next = mergeDownloadStatusEvent(base.status, {
        'state': 'RUNNING',
        'updates': [
          {
            'type': 'PROGRESS',
            'download': {
              'position': 0,
              'progress': 0.9,
              'state': 'DOWNLOADING',
              'chapter': {'id': 3, 'name': 'A'},
            },
          }
        ],
      });
      final queue = next.status['queue'] as List;
      expect(queue, hasLength(1));
      expect((queue.first as Map)['progress'], 0.9);
    });
  });

  group('ISS-068 library update event parse', () {
    test('extracts jobs and completed manga ids', () {
      final parsed = parseLibraryUpdateEvent({
        'jobsInfo': {
          'isRunning': true,
          'finishedJobs': 2,
          'totalJobs': 5,
          'skippedCategoriesCount': 1,
          'skippedMangasCount': 3,
        },
        'mangaUpdates': [
          {
            'status': 'COMPLETE',
            'manga': {'id': 42},
          },
          {
            'status': 'RUNNING',
            'manga': {'id': 7},
          },
        ],
        'omittedUpdates': false,
      });
      expect(parsed.isRunning, isTrue);
      expect(parsed.finishedJobs, 2);
      expect(parsed.totalJobs, 5);
      expect(parsed.skippedCategoriesCount, 1);
      expect(parsed.skippedMangasCount, 3);
      expect(parsed.completedMangaIds, [42]);
      expect(parsed.omittedUpdates, isFalse);
    });
  });

  group('ISS-086 fetchDownloadStatus selection parity', () {
    test('parseLibraryUpdateEvent defaults skip counts to 0', () {
      final parsed = parseLibraryUpdateEvent({
        'jobsInfo': {'isRunning': false, 'finishedJobs': 0, 'totalJobs': 0},
      });
      expect(parsed.skippedCategoriesCount, 0);
      expect(parsed.skippedMangasCount, 0);
    });
  });
}
