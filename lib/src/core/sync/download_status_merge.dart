/// Helpers to merge `downloadStatusChanged` subscription payloads into a
/// queue map shaped like `downloadStatus { state queue }` (ISS-067).
library;

/// Convert a DownloadType node into the queue-row shape used by fetchDownloadStatus.
Map<String, dynamic> downloadRowFromNode(Map<String, dynamic> download) {
  return {
    'progress': download['progress'],
    'state': download['state'],
    'position': download['position'],
    'tries': download['tries'],
    'chapter': download['chapter'],
    'manga': download['manga'],
  };
}

/// Merge a downloadStatusChanged event into [current].
///
/// Returns `(status, needsRefetch)` — when [omittedUpdates] is true the
/// caller should re-query `downloadStatus`.
({Map<String, dynamic> status, bool needsRefetch}) mergeDownloadStatusEvent(
  Map<String, dynamic>? current,
  Map<String, dynamic> event,
) {
  final state = (event['state'] as String?) ??
      (current?['state'] as String?) ??
      'STOPPED';
  final omitted = event['omittedUpdates'] == true;

  final queue = <Map<String, dynamic>>[];
  final existing = current?['queue'];
  if (existing is List) {
    for (final row in existing) {
      if (row is Map) {
        queue.add(Map<String, dynamic>.from(row.cast<String, dynamic>()));
      }
    }
  }

  void upsert(Map<String, dynamic> download) {
    final row = downloadRowFromNode(download);
    final chapterId = (download['chapter'] as Map?)?['id'];
    if (chapterId == null) {
      queue.add(row);
      return;
    }
    final idx = queue.indexWhere((r) => (r['chapter'] as Map?)?['id'] == chapterId);
    if (idx >= 0) {
      queue[idx] = row;
    } else {
      queue.add(row);
    }
  }

  void removeByChapterId(dynamic chapterId) {
    if (chapterId == null) return;
    queue.removeWhere((r) => (r['chapter'] as Map?)?['id'] == chapterId);
  }

  final initial = event['initial'];
  if (initial is List) {
    queue.clear();
    for (final node in initial) {
      if (node is Map) {
        upsert(Map<String, dynamic>.from(node.cast<String, dynamic>()));
      }
    }
  }

  final updates = event['updates'];
  if (updates is List) {
    for (final u in updates) {
      if (u is! Map) continue;
      final type = (u['type'] as String?)?.toUpperCase() ?? '';
      final download = u['download'];
      if (download is! Map) continue;
      final d = Map<String, dynamic>.from(download.cast<String, dynamic>());
      final chapterId = (d['chapter'] as Map?)?['id'];
      if (type.contains('REMOVE') || type.contains('DEQUEU') || type == 'FINISHED') {
        // FINISHED may still want to leave the row briefly; remove completed.
        if (type.contains('REMOVE') || type.contains('DEQUEU')) {
          removeByChapterId(chapterId);
        } else {
          upsert(d);
        }
      } else {
        upsert(d);
      }
    }
  }

  // Sort by position when present.
  queue.sort((a, b) {
    final pa = a['position'];
    final pb = b['position'];
    if (pa is num && pb is num) return pa.compareTo(pb);
    return 0;
  });

  return (
    status: {
      'state': state,
      'queue': queue,
      if (event.containsKey('omittedUpdates')) 'omittedUpdates': omitted,
    },
    needsRefetch: omitted,
  );
}

/// Extract finished/total/isRunning (+ skip counts) from a libraryUpdateStatusChanged event.
({
  bool isRunning,
  int finishedJobs,
  int totalJobs,
  int skippedCategoriesCount,
  int skippedMangasCount,
  List<int> completedMangaIds,
  bool omittedUpdates,
}) parseLibraryUpdateEvent(Map<String, dynamic> event) {
  final jobs = event['jobsInfo'] as Map?;
  final isRunning = jobs?['isRunning'] == true;
  int asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  final finished = asInt(jobs?['finishedJobs']);
  final total = asInt(jobs?['totalJobs']);
  final skippedCategories = asInt(jobs?['skippedCategoriesCount']);
  final skippedMangas = asInt(jobs?['skippedMangasCount']);
  final completed = <int>[];
  final mangaUpdates = event['mangaUpdates'];
  if (mangaUpdates is List) {
    for (final u in mangaUpdates) {
      if (u is! Map) continue;
      final status = (u['status'] as String?)?.toUpperCase() ?? '';
      if (status == 'COMPLETE' || status == 'FINISHED' || status == 'SUCCESS') {
        final id = (u['manga'] as Map?)?['id'];
        if (id is int) {
          completed.add(id);
        } else if (id is num) {
          completed.add(id.toInt());
        }
      }
    }
  }
  return (
    isRunning: isRunning,
    finishedJobs: finished,
    totalJobs: total,
    skippedCategoriesCount: skippedCategories,
    skippedMangasCount: skippedMangas,
    completedMangaIds: completed,
    omittedUpdates: event['omittedUpdates'] == true,
  );
}
