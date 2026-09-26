import 'package:isar/isar.dart';

part 'manga.g.dart';

@collection
class Manga {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int serverId = 0;

  /// The one canonical key for this manga everywhere in the app.
  ///
  /// Always [serverId]. For a local-only entry that is a negative synthetic
  /// value (minted on first save); for a server-linked entry it is the
  /// Suwayomi id. It is never zero for a persisted row.
  ///
  /// It must never be the local Isar auto-increment [id]. Both id spaces are
  /// small integers, so keying a query on a local id matches whichever *other*
  /// series happens to have that serverId — which silently returned a stranger
  /// series' chapters, let batch mark-read write to them, and pushed those
  /// chapters to the server as if they belonged to the target series.
  ///
  /// Use this instead of the `serverId > 0 ? serverId : id` pattern, which
  /// switched id space for local entries and reintroduced exactly that
  /// collision.
  @ignore
  int get canonicalKey => serverId;

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

  /// Optional per-series reading mode override (`Long Strip`, `Paged RTL (Manga)`, …).
  /// Null/empty means fall back to the global Settings reading mode.
  String? readingModeOverride;

  /// Unix ms of the most recent chapter open for this series (library “Last Read” sort).
  int? lastReadAt;

  /// Metron.cloud series ID for comic tracking and metadata enrichment.
  @Index()
  int? metronSeriesId;

  /// Comic publisher from Metron (e.g. Marvel, DC, Image).
  String? publisher;

  /// When true, prevents background Suwayomi sync from overwriting Metron-enriched
  /// description, author, publisher, and clean genres.
  bool isMetadataLocked = false;

  /// Cached JSON string mapping issue numbers to Metron issue IDs (e.g. {"1": 10243, "2": 10244}).
  String? metronIssuesJson;

  Manga();
}
