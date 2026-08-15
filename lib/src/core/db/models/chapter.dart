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
  }

  Chapter();
}
