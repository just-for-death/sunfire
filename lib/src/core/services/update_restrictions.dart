// IMP-003: smart library-update restrictions (Mihon-style), applied to the
// locally scraped titles. Server-linked titles follow Suwayomi's own updater.
import '../db/models/manga.dart';

/// Status strings that mean the series has ended (Suwayomi enum names and
/// common extension spellings, compared case-insensitively).
const Set<String> kCompletedMangaStatuses = {'completed', 'finished', 'publishing_finished', 'cancelled', 'canceled'};

bool isCompletedMangaStatus(String? status) =>
    status != null && kCompletedMangaStatuses.contains(status.trim().toLowerCase());

/// Splits [manga] into the titles to update and the number skipped.
/// - [skipCompleted]: series whose status is completed/finished/cancelled.
/// - [skipWithUnread]: titles that still have unread chapters.
/// - [skipNotStarted]: titles never opened (no lastReadAt).
({List<Manga> keep, int skipped}) applyUpdateRestrictions(
  Iterable<Manga> manga, {
  bool skipCompleted = false,
  bool skipWithUnread = false,
  bool skipNotStarted = false,
}) {
  final keep = <Manga>[];
  var skipped = 0;
  for (final m in manga) {
    final skip = (skipCompleted && isCompletedMangaStatus(m.status)) ||
        (skipWithUnread && (m.unreadCount ?? 0) > 0) ||
        (skipNotStarted && (m.lastReadAt ?? 0) <= 0);
    if (skip) {
      skipped++;
    } else {
      keep.add(m);
    }
  }
  return (keep: keep, skipped: skipped);
}
