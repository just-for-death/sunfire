import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/download_status_merge.dart';
import 'package:sunfire/src/core/sync/server_api_models.dart';
import 'package:sunfire/src/features/downloads/download_queue_screen.dart';

void main() {
  group('serverDownloadStatusLabel', () {
    test('formats progress and state', () {
      expect(
        serverDownloadStatusLabel(state: 'DOWNLOADING', progress: 0.42),
        'DOWNLOADING • 42%',
      );
    });

    test('includes tries when > 0', () {
      expect(
        serverDownloadStatusLabel(state: 'QUEUED', progress: 0, tries: 3),
        'QUEUED • 0% • 3 tries',
      );
    });

    test('marks ERROR states', () {
      expect(
        serverDownloadStatusLabel(state: 'ERROR', progress: 0.1, tries: 2),
        'ERROR • 10% • 2 tries',
      );
    });
  });

  group('merge + label (Q3 live queue)', () {
    test('merged row carries manga title and tries for UI', () {
      final merged = mergeDownloadStatusEvent(null, {
        'state': 'RUNNING',
        'initial': [
          {
            'position': 0,
            'progress': 0.55,
            'state': 'DOWNLOADING',
            'tries': 1,
            'chapter': {'id': 9, 'name': 'Ch 9'},
            'manga': {'id': 2, 'title': 'One Piece'},
          }
        ],
      });
      final row = (merged.status['queue'] as List).first as Map;
      expect(row['manga']['title'], 'One Piece');
      expect(row['tries'], 1);
      expect(
        serverDownloadStatusLabel(
          state: row['state'] as String,
          progress: (row['progress'] as num).toDouble(),
          tries: row['tries'] as int,
        ),
        'DOWNLOADING • 55% • 1 tries',
      );
    });
  });

  group('downloadStatusFromMutation (B5)', () {
    test('reads nested dequeue payload', () {
      final status = downloadStatusFromMutation({
        'dequeueChapterDownload': {
          'downloadStatus': {
            'state': 'RUNNING',
            'queue': [
              {
                'position': 0,
                'progress': 0.2,
                'state': 'QUEUED',
                'tries': 0,
                'chapter': {'id': 1, 'name': 'Ch 1'},
              },
            ],
          },
        },
      });
      expect(status?['state'], 'RUNNING');
      expect((status?['queue'] as List).length, 1);
    });

    test('reads direct downloadStatus', () {
      final status = downloadStatusFromMutation({
        'downloadStatus': {'state': 'STOPPED', 'queue': <Map<String, dynamic>>[]},
      });
      expect(status?['state'], 'STOPPED');
    });

    test('null on empty', () {
      expect(downloadStatusFromMutation(null), isNull);
      expect(downloadStatusFromMutation({'other': 1}), isNull);
    });
  });

  group('download item helpers (B5)', () {
    test('isDownloadItemError and downloadItemTries', () {
      expect(isDownloadItemError({'state': 'ERROR'}), isTrue);
      expect(isDownloadItemError({'state': 'QUEUED'}), isFalse);
      expect(downloadItemTries({'tries': 4}), 4);
      expect(downloadItemTries({'tries': '2'}), 2);
      expect(downloadItemTries({}), 0);
    });
  });
}
