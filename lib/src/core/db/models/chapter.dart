import 'package:isar/isar.dart';

part 'chapter.g.dart';

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
