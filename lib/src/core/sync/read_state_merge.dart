// ISS-141: read-state merge where explicit actions beat automatic progress.
//
// * Automatic progress (paging) only moves forward: the higher lastPageRead
//   wins, so a stale device can't roll progress back.
// * Explicit actions (Mark read/unread, reset, restart) are stamped in
//   Chapter.readStateActionAt (epoch seconds). Sunfire also writes the stamp to
//   the server as chapter meta [kReadActionMetaKey]. The NEWEST action wins
//   outright, even when it lowers the position.
// * Suwayomi has no read-state timestamp. On a pull, server values that differ
//   from the last-synced snapshot (Chapter.syncedIsRead/syncedLastPageRead)
//   without newer Sunfire meta are an outside change (Suwayomi web, another
//   client), stamped at detection time, so they beat older device actions.
//   Values equal to the snapshot mean nothing new happened on the server.
import '../db/models/chapter.dart';

/// Chapter meta key (already in the `sunfire_` namespace).
const String kReadActionMetaKey = 'sunfire_read_action_at';

class ReadStateMerge {
  const ReadStateMerge({required this.isRead, required this.lastPageRead, this.actionAt});
  final bool isRead;
  final int lastPageRead;
  final int? actionAt;
}

int _nowSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// Reads [kReadActionMetaKey] from a chapter node's `meta { key value }`.
int? readActionAtFromNode(Map<String, dynamic> node) {
  final meta = node['meta'];
  if (meta is! List) return null;
  for (final m in meta) {
    if (m is Map && m['key'] == kReadActionMetaKey) return int.tryParse('${m['value']}');
  }
  return null;
}

/// Pull-side merge. All times are epoch seconds.
ReadStateMerge mergeServerReadState({
  required bool localIsRead,
  required int localPage,
  int? localActionAt,
  bool? snapshotIsRead,
  int? snapshotPage,
  required bool serverIsRead,
  required int serverPage,
  int? serverMetaActionAt,
  required bool hasPendingMutation,
  int? nowSeconds,
}) {
  final local = ReadStateMerge(isRead: localIsRead, lastPageRead: localPage, actionAt: localActionAt);
  // An unsynced local change stays until it replays.
  if (hasPendingMutation) return local;

  final hasSnapshot = snapshotIsRead != null && snapshotPage != null;
  final changedSinceSnapshot =
      hasSnapshot && (serverIsRead != snapshotIsRead || serverPage != snapshotPage);
  final localAt = localActionAt ?? 0;

  int? serverActionAt;
  if (serverMetaActionAt != null && serverMetaActionAt > localAt) {
    serverActionAt = serverMetaActionAt; // a newer Sunfire action elsewhere
  } else if (changedSinceSnapshot) {
    serverActionAt = nowSeconds ?? _nowSeconds(); // outside change
  }

  if (serverActionAt != null && serverActionAt > localAt) {
    return ReadStateMerge(isRead: serverIsRead, lastPageRead: serverPage, actionAt: serverActionAt);
  }
  if (hasSnapshot && !changedSinceSnapshot) {
    return local; // nothing new on the server
  }
  // Automatic merge (first pull with no snapshot, or an older action): the
  // server's read flag (previous behaviour) and the furthest page.
  return ReadStateMerge(
    isRead: serverIsRead,
    lastPageRead: serverPage > localPage ? serverPage : localPage,
    actionAt: localActionAt,
  );
}

/// Applies [mergeServerReadState] to [chapter] from a server chapter node and
/// records the server values as the new snapshot (unless a local mutation is
/// still pending, in which case the snapshot is left for the next pull).
void applyServerReadState(
  Chapter chapter, {
  required bool serverIsRead,
  required int serverPage,
  int? serverMetaActionAt,
  required bool hasPendingMutation,
  int? nowSeconds,
}) {
  final m = mergeServerReadState(
    localIsRead: chapter.isRead,
    localPage: chapter.lastPageRead,
    localActionAt: chapter.readStateActionAt,
    snapshotIsRead: chapter.syncedIsRead,
    snapshotPage: chapter.syncedLastPageRead,
    serverIsRead: serverIsRead,
    serverPage: serverPage,
    serverMetaActionAt: serverMetaActionAt,
    hasPendingMutation: hasPendingMutation,
    nowSeconds: nowSeconds,
  );
  chapter
    ..isRead = m.isRead
    ..lastPageRead = m.lastPageRead
    ..readStateActionAt = m.actionAt;
  if (!hasPendingMutation) {
    chapter
      ..syncedIsRead = serverIsRead
      ..syncedLastPageRead = serverPage;
  }
}

/// Device-vs-device merge (ConflictResolver.resolveChapter). The newest
/// explicit action wins outright; with no actions, or equal ones, the
/// automatic rules apply (read OR, furthest page), so a stale device can't
/// roll progress back.
ReadStateMerge mergeChapterReadState(Chapter local, Chapter remote) {
  final la = local.readStateActionAt ?? 0;
  final ra = remote.readStateActionAt ?? 0;
  if (ra > la) {
    return ReadStateMerge(isRead: remote.isRead, lastPageRead: remote.lastPageRead, actionAt: ra);
  }
  if (la > ra) {
    return ReadStateMerge(isRead: local.isRead, lastPageRead: local.lastPageRead, actionAt: la);
  }
  return ReadStateMerge(
    // Automatic merge: use lastReadAt timestamp (newer wins) to allow "mark unread"
      isRead: (local.lastReadAt ?? 0) >= (remote.lastReadAt ?? 0) ? local.isRead : remote.isRead,
    lastPageRead: local.lastPageRead > remote.lastPageRead ? local.lastPageRead : remote.lastPageRead,
    actionAt: la == 0 ? null : la,
  );
}
