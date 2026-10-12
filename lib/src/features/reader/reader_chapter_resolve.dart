// R1.8: shared chapter + sibling resolve used by live ReaderScreen and
// NavigationController (dedupe the duplicated Isar lookup paths).
import '../../core/db/isar_service.dart';
import '../../core/db/models/chapter.dart';
import '../../core/db/models/manga.dart';
import 'reader_chapter_navigation.dart';

/// Resolve a chapter by server id, with local-id fallback for imported chapters
/// that have no positive server id.
Future<Chapter?> resolveChapterRecord(
  IsarService isar,
  int chapterId,
) async {
  Chapter? loaded = await isar.getChapterByServerId(chapterId);
  if (loaded != null) return loaded;

  final byLocalId = await isar.getChapterByLocalId(chapterId);
  if (byLocalId != null &&
      byLocalId.id == chapterId &&
      byLocalId.serverId <= 0) {
    return byLocalId;
  }
  return null;
}

/// Sorted siblings plus next/prev for [chapter].
class SiblingChapterNav {
  const SiblingChapterNav({
    required this.siblings,
    required this.next,
    required this.prev,
  });

  final List<Chapter> siblings;
  final Chapter? next;
  final Chapter? prev;
}

/// Load and sort sibling chapters for [chapter], resolving next/prev.
Future<SiblingChapterNav> resolveSiblingChapterNav({
  required IsarService isar,
  required Chapter chapter,
  Manga? parentManga,
}) async {
  final mId = chapter.mangaId > 0
      ? chapter.mangaId
      : (parentManga?.serverId ?? parentManga?.id ?? 0);
  var siblings = await isar.getChaptersForManga(mId);
  if (siblings.isEmpty && parentManga != null) {
    if (parentManga.id > 0 && parentManga.id != mId) {
      siblings = await isar.getChaptersForManga(parentManga.id);
    }
    if (siblings.isEmpty &&
        parentManga.serverId > 0 &&
        parentManga.serverId != mId) {
      siblings = await isar.getChaptersForManga(parentManga.serverId);
    }
  }

  final sorted = sortSiblingChapters(siblings);
  final idx = findSiblingChapterIndex(sorted, chapter);
  Chapter? nextCh;
  Chapter? prevCh;
  if (idx != -1) {
    nextCh = siblingChapterAt(sorted, idx, 1);
    prevCh = siblingChapterAt(sorted, idx, -1);
  }
  return SiblingChapterNav(siblings: sorted, next: nextCh, prev: prevCh);
}
