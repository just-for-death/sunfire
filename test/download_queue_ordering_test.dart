import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';

void main() {
  LocalDownloadTask task({
    required int id,
    required int mangaId,
    double chapterNumber = 0,
    LocalDownloadStatus status = LocalDownloadStatus.queued,
  }) {
    return LocalDownloadTask(
      chapterId: id,
      mangaId: mangaId,
      chapterName: 'Chapter $chapterNumber',
      mangaTitle: 'Test Manga',
      chapterNumber: chapterNumber,
      status: status,
    );
  }

  group('DownloadManagerService.sortQueuedTasks', () {
    test('downloads ascending chapter order (1 before 2, not 100 first)', () {
      // Mirrors a source that returns chapters newest-first (100, 99, … 1).
      final tasks = [
        task(id: 3100, mangaId: 3, chapterNumber: 100),
        task(id: 399, mangaId: 3, chapterNumber: 99),
        task(id: 31, mangaId: 3, chapterNumber: 1),
        task(id: 32, mangaId: 3, chapterNumber: 2),
      ];

      final sorted = DownloadManagerService.sortQueuedTasks(tasks);

      expect(sorted.map((t) => t.chapterNumber).toList(), [1, 2, 99, 100]);
    });

    test('groups by manga before chapter order', () {
      final tasks = [
        task(id: 1, mangaId: 1, chapterNumber: 50),
        task(id: 2, mangaId: 2, chapterNumber: 1),
        task(id: 3, mangaId: 1, chapterNumber: 1),
        task(id: 4, mangaId: 2, chapterNumber: 2),
      ];

      final sorted = DownloadManagerService.sortQueuedTasks(tasks);

      // Manga 1 first (chapters 1, 50), then manga 2 (chapters 1, 2).
      expect(sorted.map((t) => t.chapterId).toList(), [3, 1, 2, 4]);
    });

    test('only selects queued tasks', () {
      final tasks = [
        task(id: 1, mangaId: 1, chapterNumber: 10, status: LocalDownloadStatus.completed),
        task(id: 2, mangaId: 1, chapterNumber: 2, status: LocalDownloadStatus.downloading),
        task(id: 3, mangaId: 1, chapterNumber: 1, status: LocalDownloadStatus.queued),
        task(id: 4, mangaId: 1, chapterNumber: 3, status: LocalDownloadStatus.paused),
      ];

      final sorted = DownloadManagerService.sortQueuedTasks(tasks);

      expect(sorted.map((t) => t.chapterId).toList(), [3]);
    });
  });

  group('LocalDownloadTask JSON round-trip', () {
    test('persists chapterNumber (backwards compatible)', () {
      final t = task(id: 7, mangaId: 2, chapterNumber: 7.5, status: LocalDownloadStatus.downloading);

      final restored = LocalDownloadTask.fromJson(t.toJson());

      expect(restored.chapterNumber, 7.5);
      expect(restored.chapterId, 7);
      expect(restored.mangaId, 2);
      expect(restored.status, LocalDownloadStatus.downloading);
    });

    test('missing chapterNumber defaults to 0 (old queues still load)', () {
      final oldJson = {
        'chapterId': 5,
        'mangaId': 1,
        'chapterName': 'Chapter 5',
        'mangaTitle': 'Old Manga',
        'progress': 0.0,
        'status': 'queued',
        'error': null,
      };

      final restored = LocalDownloadTask.fromJson(oldJson);

      expect(restored.chapterNumber, 0);
      expect(restored.chapterId, 5);
      expect(restored.status, LocalDownloadStatus.queued);
    });
  });
}