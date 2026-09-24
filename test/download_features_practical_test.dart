import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';
import 'package:sunfire/src/core/services/notification_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/download_foreground_task.dart';

/// Practical behaviour tests for the v1.5 download overhaul:
/// reading-order queueing, batch accounting, notification copy, settings
/// gating, and the Android foreground-service snapshot lifecycle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LocalDownloadTask task({
    required int id,
    required int mangaId,
    double chapterNumber = 0,
    LocalDownloadStatus status = LocalDownloadStatus.queued,
    String? error,
  }) {
    return LocalDownloadTask(
      chapterId: id,
      mangaId: mangaId,
      chapterName: 'Chapter $chapterNumber',
      mangaTitle: 'Test Manga',
      chapterNumber: chapterNumber,
      status: status,
      error: error,
    );
  }

  group('Queue ordering (practical: source returns newest-first like real sites)', () {
    test('a 100-chapter manga downloads 1 → 2 → … → 100, starting at chapter 1', () {
      // Mirrors what a real scraper returns: newest-first, e.g. chapters 100..1.
      final newestFirst = List.generate(100, (i) => 100 - i)
          .map((n) => task(id: n, mangaId: 1, chapterNumber: n.toDouble()))
          .toList();

      final sorted = DownloadManagerService.sortQueuedTasks(newestFirst);

      expect(sorted.first.chapterNumber, 1);
      expect(sorted.last.chapterNumber, 100);
      final numbers = sorted.map((t) => t.chapterNumber).toList();
      for (var i = 1; i < numbers.length; i++) {
        expect(numbers[i], greaterThan(numbers[i - 1]));
      }
    });

    test('mixed mangas in one queue stay grouped by manga, ordered by chapter', () {
      final tasks = [
        task(id: 301, mangaId: 3, chapterNumber: 1),
        task(id: 101, mangaId: 1, chapterNumber: 50),
        task(id: 102, mangaId: 1, chapterNumber: 1),
        task(id: 201, mangaId: 2, chapterNumber: 3),
        task(id: 103, mangaId: 1, chapterNumber: 2),
      ];
      final sorted = DownloadManagerService.sortQueuedTasks(tasks);
      expect(sorted.map((t) => t.mangaId).toList(), [1, 1, 1, 2, 3]);
      expect(sorted.map((t) => t.chapterId).toList(), [102, 103, 101, 201, 301]);
    });

    test('equal chapter numbers resolve deterministically by chapterId (stable order)', () {
      // Some sources duplicate numbers (releases/redraws). Dart's sort isn't
      // stable, so a deterministic tiebreak is required to avoid random order.
      final tasks = [
        task(id: 3, mangaId: 1, chapterNumber: 1),
        task(id: 1, mangaId: 1, chapterNumber: 1),
        task(id: 2, mangaId: 1, chapterNumber: 1),
      ];
      final sorted = DownloadManagerService.sortQueuedTasks(tasks);
      expect(sorted.map((t) => t.chapterId).toList(), [1, 2, 3]);
    });

    test('failed/cancelled leftovers never block or reorder a new batch', () {
      final tasks = [
        task(id: 1, mangaId: 1, chapterNumber: 9, status: LocalDownloadStatus.failed),
        task(id: 2, mangaId: 1, chapterNumber: 1, status: LocalDownloadStatus.queued),
        task(id: 3, mangaId: 1, chapterNumber: 8, status: LocalDownloadStatus.failed),
      ];
      // Only fresh queued items are processed; failures from earlier runs are
      // excluded entirely (they can't stall the head of the queue).
      final sorted = DownloadManagerService.sortQueuedTasks(tasks);
      expect(sorted.map((t) => t.chapterId).toList(), [2]);
    });
  });

  group('Batch accounting (mirrors the running queue)', () {
    test('countRetryableTasks counts queued + paused + downloading only', () {
      final tasks = [
        task(id: 1, mangaId: 1, chapterNumber: 1, status: LocalDownloadStatus.queued),
        task(id: 2, mangaId: 1, chapterNumber: 2, status: LocalDownloadStatus.paused),
        task(id: 3, mangaId: 1, chapterNumber: 3, status: LocalDownloadStatus.downloading),
        task(id: 4, mangaId: 1, chapterNumber: 4, status: LocalDownloadStatus.completed),
        task(id: 5, mangaId: 1, chapterNumber: 5, status: LocalDownloadStatus.failed),
      ];
      expect(DownloadManagerService.countRetryableTasks(tasks), 3);
    });

    test('completion summary strings match what the notification shows (all succeeded)', () {
      final s = NotificationService.downloadsCompletionSummary(succeeded: 12, failed: 0, total: 12);
      expect(s.title, 'Downloads Completed');
      expect(s.body, '12 chapters downloaded');
    });

    test('single-chapter batch reads naturally', () {
      final s = NotificationService.downloadsCompletionSummary(succeeded: 1, failed: 0, total: 1);
      expect(s.title, 'Downloads Completed');
      expect(s.body, '1 chapter downloaded');
    });

    test('partial failure reports how many succeeded/failed', () {
      final s = NotificationService.downloadsCompletionSummary(succeeded: 8, failed: 2, total: 10);
      expect(s.title, '10 Chapters Downloaded');
      expect(s.body, '8 succeeded, 2 failed. Check the Downloads queue for details.');
    });

    test('total failure is unambiguous', () {
      final s = NotificationService.downloadsCompletionSummary(succeeded: 0, failed: 5, total: 5);
      expect(s.title, '5 Downloads Failed');
      expect(s.body, 'All 5 downloads failed. Check the Downloads queue for details.');
    });
  });

  group('LocalDownloadTask persistence (survives app restarts)', () {
    test('full JSON round-trip preserves every field', () {
      final t = task(
        id: 42,
        mangaId: 7,
        chapterNumber: 6.5,
        status: LocalDownloadStatus.failed,
        error: 'No pages found for chapter',
      )..progress = 0.4;

      final restored = LocalDownloadTask.fromJson(t.toJson());

      expect(restored.chapterId, 42);
      expect(restored.mangaId, 7);
      expect(restored.chapterNumber, 6.5);
      expect(restored.progress, 0.4);
      expect(restored.status, LocalDownloadStatus.failed);
      expect(restored.error, 'No pages found for chapter');
    });

    test('malformed/unknown status falls back to queued instead of crashing', () {
      final restored = LocalDownloadTask.fromJson({
        'chapterId': 1,
        'mangaId': 1,
        'status': 'totally-bogus',
      });
      expect(restored.status, LocalDownloadStatus.queued);
    });
  });

  group('Settings gating (downloadNotificationsEnabled / backgroundDownloadsEnabled)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
    });

    test('both new settings default to ON (feature-parity out of the box)', () {
      expect(SettingsService.instance.downloadNotificationsEnabled, isTrue);
      expect(SettingsService.instance.backgroundDownloadsEnabled, isTrue);
    });

    test('toggling off persists and reads back', () async {
      SettingsService.instance.downloadNotificationsEnabled = false;
      SettingsService.instance.backgroundDownloadsEnabled = false;
      expect(SettingsService.instance.downloadNotificationsEnabled, isFalse);
      expect(SettingsService.instance.backgroundDownloadsEnabled, isFalse);
    });

    test('Wi-Fi-only gate: cellular is blocked, wifi/ethernet/vpn allowed', () async {
      SettingsService.instance.downloadOnlyOnWifi = true;
      final svc = DownloadManagerService.instance;
      expect(svc.isNetworkAllowed([ConnectivityResult.mobile]), isFalse);
      expect(svc.isNetworkAllowed([ConnectivityResult.wifi]), isTrue);
      expect(svc.isNetworkAllowed([ConnectivityResult.ethernet]), isTrue);
      expect(svc.isNetworkAllowed([ConnectivityResult.vpn]), isTrue);
      expect(svc.isNetworkAllowed([ConnectivityResult.none]), isFalse);

      SettingsService.instance.downloadOnlyOnWifi = false;
      expect(svc.isNetworkAllowed([ConnectivityResult.mobile]), isTrue);
    });
  });

  group('Android foreground-service snapshot lifecycle', () {
    test('fresh snapshot payload contains all fields the background isolate reads', () {
      final raw = DownloadForegroundTask.buildSnapshot(
        mangaTitle: 'One Piece',
        currentChapter: 'Chapter 3',
        completed: 2,
        total: 10,
        active: true,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      expect(decoded['mangaTitle'], 'One Piece');
      expect(decoded['currentChapter'], 'Chapter 3');
      expect(decoded['completed'], 2);
      expect(decoded['total'], 10);
      expect(decoded['active'], isTrue);
      expect(decoded['updatedAt'], greaterThan(0));
    });

    test('a freshly written snapshot is not stale', () {
      final raw = jsonEncode({'active': true, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
      expect(DownloadForegroundTask.isSnapshotStale(raw), isFalse);
    });

    test('an old snapshot (main isolate died) is stale → service must stop', () {
      final old = DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch;
      final raw = jsonEncode({'active': true, 'updatedAt': old});
      expect(DownloadForegroundTask.isSnapshotStale(raw), isTrue);
    });

    test('unparseable / missing-timestamp snapshots are treated as stale', () {
      expect(DownloadForegroundTask.isSnapshotStale('not-json'), isTrue);
      expect(DownloadForegroundTask.isSnapshotStale('{}'), isTrue);
      expect(DownloadForegroundTask.isSnapshotStale(''), isTrue);
    });

    test('inactive snapshot is handled by the stale guard too (safety net)', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final raw = jsonEncode({'active': false, 'updatedAt': now});
      expect(DownloadForegroundTask.isSnapshotStale(raw), isFalse);
    });
  });

  group('App versioning fix (beta v11 → stable v1 must NOT be a downgrade)', () {
    test('current pubspec version is 3.0.0', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(r'^version:\s*(.+)$', multiLine: true).firstMatch(pubspec);
      expect(match, isNotNull);
      expect(match!.group(1)!.trim(), startsWith('3.0.0'));
    });

    test('compareAppVersions: stable 1.0.0 beats prerelease 11.0.0-beta', () {
      expect(RepoManager.compareAppVersions('1.0.0', '11.0.0-beta'), greaterThan(0));
      expect(RepoManager.compareAppVersions('11.0.0-beta', '1.0.0'), lessThan(0));
    });

    test('compareAppVersions still orders stable releases numerically', () {
      expect(RepoManager.compareAppVersions('1.5.0', '1.0.0'), greaterThan(0));
      expect(RepoManager.compareAppVersions('1.0.0', '1.5.0'), lessThan(0));
      expect(RepoManager.compareAppVersions('1.5.0', '1.5.0'), 0);
    });

    test('compareAppVersions orders prereleases among themselves by number', () {
      expect(RepoManager.compareAppVersions('11.0.0-beta', '10.0.0-beta'), greaterThan(0));
    });

    test('extension semver is NOT affected: pure semver still wins numerically', () {
      // Critical guard: repository/extension comparisons must keep treating
      // 11.0.0-beta as newer than 1.0.0 (extensions never restarted numbering).
      expect(RepoManager.compareVersions('11.0.0-beta', '1.0.0'), greaterThan(0));
      expect(RepoManager.compareVersions('1.0.0-beta', '1.0.0'), lessThan(0));
      expect(RepoManager.compareVersions('1.0.0+1', '1.0.0'), 0);
    });
  });
}