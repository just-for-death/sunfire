// Download-ahead selection, extracted from ReaderScreen (v6 Step 9). Pure.
import '../../core/db/models/chapter.dart';

/// The next [count] unread, not-yet-downloaded chapters after [current] in
/// [siblings] (reading order). Empty when [current] is not in the list.
List<Chapter> downloadAheadCandidates({
  required List<Chapter> siblings,
  required Chapter current,
  required int count,
  required bool Function(Chapter chapter) isDownloaded,
}) {
  if (count <= 0) return const [];
  final idx = siblings.indexWhere(
      (c) => c.id == current.id || (c.serverId != 0 && c.serverId == current.serverId));
  if (idx == -1) return const [];
  return siblings.skip(idx + 1).where((c) => !c.isRead && !isDownloaded(c)).take(count).toList();
}
