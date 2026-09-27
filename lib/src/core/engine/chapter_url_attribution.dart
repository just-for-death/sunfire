/// Guards against misattributed scraped chapters.
///
/// Some source pages link to *other* series (related comics, "you may also
/// like"). An over-broad chapter selector — e.g. readcomicsonline's old
/// `a[href*='/comic/']` catch-all — then returns foreign chapters, and the
/// ingestion paths save them under the manga being scraped: the Updates feed
/// shows "Absolute Superman" with an "Absolute Batman" chapter, tapping it
/// opens the wrong series' pages, and progress/downloads attach wrongly.
///
/// The check is deliberately conservative: it only rejects when BOTH urls are
/// parseable same-host HTTP(S) urls AND the manga page has the
/// `/comic/<slug>` shape AND the chapter url does not nest under it. Anything
/// else returns true (cannot judge — preserve old behavior). Sources with
/// opaque chapter urls (WeebCentral ULIDs, MangaHere query keys) always pass.
bool chapterUrlBelongsToMangaPage(String mangaUrl, String chapterUrl) {
  if (mangaUrl.isEmpty || chapterUrl.isEmpty) return true;
  final mangaUri = Uri.tryParse(mangaUrl.trim());
  final chapterUri = Uri.tryParse(chapterUrl.trim());
  if (mangaUri == null || chapterUri == null) return true;
  // The chapter pointer must be an absolute page url; otherwise there is
  // nothing to judge (opaque ids, query keys).
  if (!chapterUri.hasScheme || !chapterUri.hasAuthority) return true;
  // Stored manga urls are often relative page paths (`/comic/<slug>` from
  // the tap flow). Compare paths, and only enforce the host when the manga
  // url actually carries one.
  if (mangaUri.hasAuthority &&
      mangaUri.host.toLowerCase() != chapterUri.host.toLowerCase()) {
    return true;
  }

  // readcomicsonline shape: manga `/comic/<slug>`, chapter `/comic/<slug>/...`.
  List<String> segs(Uri u) =>
      u.pathSegments.where((s) => s.isNotEmpty).toList();
  final mangaSegs = segs(mangaUri);
  if (mangaSegs.length >= 2 && mangaSegs[0].toLowerCase() == 'comic') {
    final slug = mangaSegs[1].toLowerCase();
    final chSegs = segs(chapterUri);
    if (chSegs.length >= 3 &&
        chSegs[0].toLowerCase() == 'comic' &&
        chSegs[1].toLowerCase() == slug) {
      return true;
    }
    return false;
  }

  return true;
}
