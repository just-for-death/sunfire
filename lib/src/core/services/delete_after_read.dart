// IMP-038: "delete after read" target selection (offset + exclude bookmarked).
import '../db/models/chapter.dart';

/// Which downloaded chapter to delete after [finished] was read.
///
/// [sortedSiblings] is the manga's chapter list in reading order (ascending).
/// [offset] 0 deletes [finished] itself; N deletes the chapter N places
/// before it, so the N most recently read chapters stay on disk (that target
/// must itself be read). [excludeBookmarked] never deletes a bookmarked one.
/// Returns null when nothing qualifies.
Chapter? chapterToDeleteAfterRead({
  required Chapter finished,
  required List<Chapter> sortedSiblings,
  required int offset,
  required bool excludeBookmarked,
}) {
  Chapter? target;
  if (offset <= 0) {
    target = finished;
  } else {
    final idx = _indexOf(sortedSiblings, finished);
    if (idx < 0 || idx - offset < 0) return null;
    target = sortedSiblings[idx - offset];
    if (!target.isRead) return null;
  }
  if (excludeBookmarked && target.isBookmarked) return null;
  return target;
}

int _indexOf(List<Chapter> sorted, Chapter c) {
  int key(Chapter x) => x.serverId != 0 ? x.serverId : x.id;
  final k = key(c);
  return sorted.indexWhere((x) => key(x) == k);
}
