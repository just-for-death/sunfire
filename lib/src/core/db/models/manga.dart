import 'dart:convert';

import 'package:crypto/crypto.dart';
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

/// A stable, collision-resistant negative id for a locally-scraped series.
///
/// `String.hashCode` is NOT stable across process runs — Dart seeds it per
/// isolate — so it cannot back anything persisted. It used to back
/// `Manga.serverId`, which is `@Index(unique: true, replace: true)`: every cold
/// start gave the same series a brand-new identity, `getMangaByServerId` then
/// missed, a duplicate row was inserted, and the previous identity's chapters
/// (keyed on the old id) were orphaned along with their read state, bookmarks
/// and downloads. Re-browsing a local source a few times a week quietly filled
/// the library with duplicates of the same title.
///
/// sha256 over the source name and the series URL is deterministic, and two
/// distinct series cannot realistically collide. Case and whitespace are
/// normalised so the same series browsed twice agrees.
///
/// The result is always negative: positive ids are the server's namespace, and
/// every writer treats a negative `serverId` as "local-only, never push this".
///
/// WIDTH IS LOAD-BEARING — do not widen this. `mintLocalChapterServerId`
/// derives per-chapter ids as `mangaId.abs() * 100000 + index`, and Dart ints
/// are 64-bit, so the product must stay under 2^63. At 52 bits (4.5e15) the
/// product is 4.5e20 and wraps: only the bottom 2% of the range is safe, so ~98%
/// of local series would have been handed POSITIVE chapter ids — which alias
/// real server chapters in the unique index, get pushed to the server as bogus
/// progress, and become eligible for the sync prune. 40 bits keeps the product
/// at ~1.1e17, an ~84x margin, and is still collision-free at any library size a
/// person can actually accumulate.
int stableLocalMangaServerId({required String sourceName, required String url, required String title}) {
  final normalisedUrl = url.trim();
  final identity = '$sourceName|${normalisedUrl.isNotEmpty ? normalisedUrl : title.trim()}'.toLowerCase();
  final digest = sha256.convert(utf8.encode(identity)).bytes;
  // 5 bytes = 40 bits. See the width note above before changing this.
  var value = 0;
  for (var i = 0; i < 5; i++) {
    value = (value << 8) | digest[i];
  }
  value &= 0xFFFFFFFFFF; // 40 bits
  if (value == 0) value = 1;
  return -value;
}
