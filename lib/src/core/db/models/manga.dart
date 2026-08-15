import 'package:isar/isar.dart';

part 'manga.g.dart';

@collection
class Manga {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  String title = '';
  String? artist;
  String? author;
  String? description;
  List<String> genres = [];
  String? status;

  bool inLibrary = false;
  int? inLibraryAt;

  List<int> categoryIds = [];

  String sourceName = '';
  String lang = '';

  /// The URL of this manga on the source website — used by local QuickJS extensions
  /// to browse chapters directly without going through the server.
  String url = '';
  String? thumbnailUrl;

  int? lastFetchedAt;
  int? unreadCount;

  /// Total number of chapters known for this manga (denormalized from last sync).
  /// Used for progress display fully offline.
  int chapterCount = 0;

  Manga();
}
