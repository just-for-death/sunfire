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
  if (mangaUri == null ||
      chapterUri == null ||
      !mangaUri.hasScheme ||
      !mangaUri.hasAuthority ||
      !chapterUri.hasScheme ||
      !chapterUri.hasAuthority) {
    return true;
  }
  if (mangaUri.host.toLowerCase() != chapterUri.host.toLowerCase()) return true;

  // readcomicsonline shape: manga `/comic/<slug>`, chapter `/comic/<slug>/...`.
  final mangaSegs = mangaUri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (mangaSegs.length >= 2 && mangaSegs[0].toLowerCase() == 'comic') {
    final slug = mangaSegs[1].toLowerCase();
    final chSegs = chapterUri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (chSegs.length >= 3 &&
        chSegs[0].toLowerCase() == 'comic' &&
        chSegs[1].toLowerCase() == slug) {
      return true;
    }
    return false;
  }

  return true;
}
