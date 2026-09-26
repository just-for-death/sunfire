
import 'package:isar/isar.dart';

part 'chapter.g.dart';

/// Number of freshly-scraped chapters in one batch above which a series is
/// treated as "flooded" (a bulk import / bulk refresh).
const int kFloodThresholdChapters = 4;

/// How many chapters of a flooded series may enter the Updates feed.
const int kFloodCapChapters = 3;

/// Applies the flood gate to a batch of newly-scraped chapters, in place.
///
/// The cap was previously applied only at DISPLAY time, in two places, with a
/// third unrelated threshold (`> 3`) in `cleanupBulkScrapedUpdates`, and the
/// two local-scrape ingestion paths disagreed about whether to stamp
/// `fetchedAt` at all. The result was that one bulk import could make the
/// Library tile read "~400 unread" and a system notification say "400 new
/// chapters are now available" while the Updates feed showed 3 — two screens
/// reporting contradictory facts about the same batch, and the excess chapters
/// only being reaped at the next cold launch.
///
/// [isFirstImport] keeps a series' very first bulk import entirely out of the
/// feed (`fetchedAt = 0`), which is what the library-scrape path had always
/// done via a ternary the update service did not have. For later batches the
/// newest [kFloodCapChapters] keep a real timestamp and the rest are zeroed.
///
/// Chapters are still saved either way: the excess stay in the library, keep
/// their unread status and remain reachable from the series' chapter list.
/// Zeroing `fetchedAt` only removes them from the Updates feed, which is
/// `getRecentChapters`' `fetchedAt > 0` filter.
void applyFloodCapToNewChapters(
  List<Chapter> newChapters, {
  required bool isFirstImport,
}) {
  if (newChapters.isEmpty) return;
  final stamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  if (isFirstImport) {
    // Whole first import stays out of the feed.
    for (final ch in newChapters) {
      ch.fetchedAt = 0;
    }
    return;
  }

  // `newChapters` is built in the source's own order, which is newest-first for
  // every bundled source. Cap from the front so the newest survive.
  final keep = newChapters.length > kFloodThresholdChapters
      ? kFloodCapChapters
      : newChapters.length;
  for (var i = 0; i < newChapters.length; i++) {
    newChapters[i].fetchedAt = i < keep ? stamp : 0;
  }
}

/// Mints a synthetic server id for a locally-scraped chapter of [mangaId]
/// appearing at [index] in the source's chapter list.
///
/// Negative on purpose: real Suwayomi chapter ids are positive and share the
/// unique `serverId` index with them, so a positive synthetic id can alias (and
/// overwrite) a real server chapter, and would also be picked up by the
/// `serverId > 0` guards that push local progress to the server.
///
/// The base value is derived from the *array index*, which is not stable: a
/// source that prepends a new chapter shifts every later chapter down one
/// slot, so the id the newcomer would take is already in use by the chapter
/// that used to sit there. `Chapter.serverId` is `@Index(unique: true,
/// replace: true)` and `saveChapters` uses `putAll`, so writing that id would
/// silently REPLACE the existing row — destroying its read state, bookmark and
/// local download with no error. Hence the probe loop, and hence [takenServerIds]
/// must be seeded with every id already in use for this manga and be updated
/// with each id handed out (both call sites do this).
///
/// Largest `mangaId.abs()` this will multiply by [_kChapterIdStride].
///
/// Dart ints are 64-bit and wrap silently. The product plus any sane `index`
/// must stay under 2^63, so the base is clamped well below that regardless of
/// what the caller passes.
///
/// This is a hard invariant guard, not a nicety: the caller normally passes a
/// `stableLocalMangaServerId` (40 bits), but this function is public and a
/// wider id — or any other large integer — would otherwise wrap to a POSITIVE
/// value. A positive synthetic chapter id aliases a real server chapter in the
/// `unique: true, replace: true` index, is pushed to the server as bogus reading
/// progress, and is picked up by the sync engine's chapter prune.
const int _kMaxMangaIdForChapterStride = 90000000000; // 9e10; 9e10 * 1e5 = 9e15

/// Per-chapter id stride. Wide enough that a series' chapters occupy a
/// contiguous band, narrow enough to keep [mintLocalChapterServerId] far away
/// from Int64 overflow.
const int _kChapterIdStride = 100000;

/// Returns the first free NEGATIVE id in [mangaId]'s band.
///
/// Negative on purpose: real Suwayomi chapter ids are positive and share the
/// unique `serverId` index with them, so a positive synthetic id can alias (and
/// overwrite) a real server chapter, and would also be picked up by the
/// `serverId > 0` guards that push local progress to the server and by
/// `deleteChapters` in the sync prune.
///
/// Probing moves AWAY from zero (`--`). A `++` probe walks a negative id toward
/// the positive namespace and eventually crosses it.
int mintLocalChapterServerId({
  required int mangaId,
  required int index,
  required Set<int> takenServerIds,
}) {
  final base = mangaId.abs() % _kMaxMangaIdForChapterStride;
  final offset = index.abs() % _kChapterIdStride;
  var candidate = -(base * _kChapterIdStride + offset + 1);
  // Belt and braces: if the clamp above is ever mis-tuned, never hand back a
  // value that could alias the server namespace.
  if (candidate >= 0) candidate = -1 - (takenServerIds.length);
  while (takenServerIds.contains(candidate)) {
    candidate--;
  }
  takenServerIds.add(candidate);
  return candidate;
}

@collection
class Chapter {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  @Index()
  int mangaId = 0;

  String name = '';
  double chapterNumber = 0.0;

  bool isRead = false;
  int lastPageRead = 0;

  @Index()
  int? lastReadAt;

  int pageCount = 0;
  bool isBookmarked = false;

  String? scanlator;
  String? localPath;
  bool isDownloadedLocally = false;
  bool isDownloadedOnServer = false;

  /// Unix timestamp (seconds) when the chapter was published / uploaded by source.
  int? uploadDate;

  /// The authentic published date string provided directly by the extension or source site
  /// (e.g. "May 6, 2026", "2026-05-26", "26 Aug 2026", "Nov 14, 2024").
  String? dateUpload;

  /// Unix timestamp (seconds) when Suwayomi discovered this chapter.
  /// Indexed for fast Updates tab ordering (ORDER BY fetchedAt DESC).
  @Index()
  int? fetchedAt;

  /// Denormalized parent manga title — allows Updates & History to render
  /// without any Isar join when the server is offline.
  String mangaTitle = '';

  /// Denormalized parent manga cover URL — same rationale as mangaTitle.
  String? mangaThumbnailUrl;

  /// The chapter URL (e.g. /read/one-piece-chapter-1/) on the source website.
  /// Used by local Mangayomi / QuickJS extensions to scrape chapter pages directly.
  String url = '';

  /// The full absolute URL if different from relative url.
  String realUrl = '';

  bool get isDownloaded => isDownloadedLocally || isDownloadedOnServer;
  set isDownloaded(bool val) {
    isDownloadedLocally = val;
    if (!val) {
      isDownloadedOnServer = false;
    }
  }

  /// Aligns local progress with the reader complete-chapter path.
  void applyReadState(bool read) {
    isRead = read;
    if (read) {
      if (pageCount > 0) lastPageRead = pageCount;
    } else {
      lastPageRead = 0;
    }
  }

  /// Clears history feed membership without changing read/unread status.
  void clearHistoryTimestamp() {
    lastReadAt = null;
  }

  Chapter();
}

/// Picks the chapter Continue Reading should open (in-progress → next unread → last read).
Chapter? pickContinueReadingChapter(List<Chapter> chapters) {
  if (chapters.isEmpty) return null;
  final inProgress = chapters.where((c) => !c.isRead && c.lastPageRead > 0).toList();
  if (inProgress.isNotEmpty) {
    inProgress.sort((a, b) => (b.lastReadAt ?? 0).compareTo(a.lastReadAt ?? 0));
    return inProgress.first;
  }
  final sortedByNum = List<Chapter>.from(chapters)..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
  final hasUnread = sortedByNum.any((c) => !c.isRead);
  if (hasUnread) {
    return sortedByNum.firstWhere((c) => !c.isRead);
  }
  final byLastRead = List<Chapter>.from(chapters)
    ..sort((a, b) => (b.lastReadAt ?? 0).compareTo(a.lastReadAt ?? 0));
  return byLastRead.first;
}
