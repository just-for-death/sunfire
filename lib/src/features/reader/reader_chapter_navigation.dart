import '../../core/db/models/chapter.dart';
import 'chapter_number_utils.dart' as utils;

/// Numeric reading order for a chapter: prefer the explicit [Chapter.chapterNumber],
/// otherwise parse it from the display name ("Chapter 12", "Ep. 7", "#3", or a
/// bare number). Returns 0.0 when nothing can be extracted.
///
/// Re-exported from [chapter_number_utils] for backward compatibility.
double chapterSortNumber(Chapter c) => utils.chapterSortNumber(c);

/// Sorts a manga's chapter list into reading order (ascending number,
/// name as tie-break). The source's newest-first order is reversed here so
/// "next chapter" means chapter N+1, not the newest one.
List<Chapter> sortSiblingChapters(List<Chapter> chapters) {
  final sorted = List<Chapter>.from(chapters);
  sorted.sort((a, b) {
    final numA = chapterSortNumber(a);
    final numB = chapterSortNumber(b);
    if (numA != numB) return numA.compareTo(numB);
    return a.name.compareTo(b.name);
  });
  return sorted;
}

/// Index of [chapter] in an already-sorted sibling list, matching by id,
/// serverId, url, then trimmed name. Returns -1 when not found (in which
/// case there is no reliable next/previous chapter).
int findSiblingChapterIndex(List<Chapter> sorted, Chapter chapter) {
  // Match in strict priority tiers so a weaker key (name) can never win over
  // a stronger one (id / serverId) that sits later in the list. Duplicate
  // display names ("Chapter 10" released twice) are common, so name is only
  // a last resort and only when it is unambiguous.
  if (chapter.id != 0) {
    final i = sorted.indexWhere((c) => c.id != 0 && c.id == chapter.id);
    if (i != -1) return i;
  }
  if (chapter.serverId != 0) {
    final i = sorted.indexWhere((c) => c.serverId != 0 && c.serverId == chapter.serverId);
    if (i != -1) return i;
  }
  if (chapter.url.isNotEmpty) {
    final i = sorted.indexWhere((c) => c.url.isNotEmpty && c.url == chapter.url);
    if (i != -1) return i;
  }
  final name = chapter.name.trim().toLowerCase();
  final byName = <int>[];
  for (var i = 0; i < sorted.length; i++) {
    if (sorted[i].name.trim().toLowerCase() == name) byName.add(i);
  }
  return byName.length == 1 ? byName.first : -1;
}

/// The chapter [offset] slots away from [index] in [sorted], or null when the
/// slot is out of range. offset = 1 → next chapter, offset = -1 → previous.
Chapter? siblingChapterAt(List<Chapter> sorted, int index, int offset) {
  if (index < 0) return null;
  final target = index + offset;
  if (target < 0 || target >= sorted.length) return null;
  return sorted[target];
}

/// Whether the end-of-chapter dialog may be shown: enabled by the user, the
/// chapter has pages, and it hasn't already been shown for [chapterId] this
/// session. Pure so the reader's gating logic is unit-testable.
bool shouldShowEndOfChapterDialog({
  required bool enabled,
  required bool hasPages,
  required int? lastDialogChapterId,
  required int chapterId,
}) {
  return enabled && hasPages && lastDialogChapterId != chapterId;
}