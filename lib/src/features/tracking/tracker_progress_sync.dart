import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/tracker_repository.dart';
import 'presentation/controller/tracker_controller.dart';

/// Best-effort sync of bound tracker records when a chapter is finished.
Future<void> syncTrackerProgressOnChapterComplete(
  WidgetRef ref, {
  required int mangaId,
  required double chapterNumber,
}) async {
  if (mangaId <= 0 || chapterNumber <= 0) return;

  try {
    final records =
        await ref.read(trackerRepositoryProvider).getTrackRecords(mangaId);
    if (records.isEmpty) return;

    final repo = ref.read(trackerRepositoryProvider);
    var updated = false;
    for (final record in records) {
      final current = record.lastChapterRead ?? 0;
      if (chapterNumber <= current) continue;
      await repo.updateTrack(
        recordId: record.id,
        lastChapterRead: chapterNumber,
      );
      updated = true;
    }
    if (updated) {
      ref.invalidate(mangaTrackRecordsProvider(mangaId));
    }
  } catch (_) {
    // Non-blocking — reader progress must not fail if trackers are unavailable.
  }
}
