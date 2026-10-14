// IMP-004: "More like this" query (UIX half; UIS renders the row).
//
// Local-first and offline: ranks series Sunfire already knows (library and
// cached browse results) against a target by genre overlap (Jaccard) plus
// shared author/artist. No tracker or network call, so it also works for
// local-only series.
import '../db/isar_service.dart';
import '../db/models/manga.dart';
import 'library_matching.dart' show normalizeMangaTitle;

class MangaRecommendation {
  const MangaRecommendation(this.manga, this.score, this.reasons);
  final Manga manga;
  final double score;

  /// Short labels UIS may show ("Same author", "4 shared genres").
  final List<String> reasons;
}

Set<String> _genres(Manga m) => {
      for (final g in m.genres)
        if (g.trim().isNotEmpty) g.trim().toLowerCase(),
    };

Set<String> _people(Manga m) => {
      for (final p in [m.author, m.artist])
        for (final part in (p ?? '').split(RegExp(r'[,;&/]')))
          if (part.trim().isNotEmpty) part.trim().toLowerCase(),
    };

/// Pure ranking. Excludes [target] itself and other copies of the same title
/// (another source of the same series is not a recommendation).
List<MangaRecommendation> rankRecommendations(
  Manga target,
  Iterable<Manga> candidates, {
  int limit = 12,
  double minScore = 0.2,
}) {
  final tg = _genres(target);
  final tp = _people(target);
  final tTitle = normalizeMangaTitle(target.title);
  final out = <MangaRecommendation>[];
  final seenTitles = <String>{tTitle};
  for (final c in candidates) {
    if (c.serverId == target.serverId) continue;
    final title = normalizeMangaTitle(c.title);
    if (title.isEmpty || seenTitles.contains(title)) continue;
    final cg = _genres(c);
    final shared = tg.intersection(cg).length;
    final union = tg.union(cg).length;
    final jaccard = union == 0 ? 0.0 : shared / union;
    final samePeople = tp.isNotEmpty && tp.intersection(_people(c)).isNotEmpty;
    final score = jaccard + (samePeople ? 0.5 : 0.0);
    if (score < minScore) continue;
    seenTitles.add(title);
    out.add(MangaRecommendation(c, score, [
      if (samePeople) 'Same author',
      if (shared > 0) '$shared shared genre${shared == 1 ? '' : 's'}',
    ]));
  }
  out.sort((a, b) {
    final s = b.score.compareTo(a.score);
    if (s != 0) return s;
    // Prefer titles already in the library, then alphabetical.
    final l = (b.manga.inLibrary ? 1 : 0) - (a.manga.inLibrary ? 1 : 0);
    return l != 0 ? l : a.manga.title.compareTo(b.manga.title);
  });
  return out.length > limit ? out.sublist(0, limit) : out;
}

/// UIS hook: recommendations for [target] from the local database.
Future<List<MangaRecommendation>> moreLikeThis(Manga target, {int limit = 12}) async {
  final all = await IsarService.instance.getAllManga();
  return rankRecommendations(target, all, limit: limit);
}
