// Relay-style cursor pagination for Suwayomi connections (ISS-074 B11).
//
// Suwayomi's `endCursor` is opaque and order-dependent (e.g. "22890-1790521915"
// under LAST_READ_AT ordering), so offset paging can skip or duplicate rows
// when the underlying set changes mid-walk (a chapter read on another device
// reshuffles a LAST_READ_AT ordering). `after: endCursor` is stable.
//
// Termination rules, shared by every paginated fetcher:
//  * `hasNextPage == false`             → complete
//  * empty page (even with hasNextPage) → complete (servers that over-report)
//  * a present totalCount reached       → complete
//  * endCursor did not advance          → INCOMPLETE (stuck server)
//  * node ceiling hit                   → INCOMPLETE
//  * a page failing after the first     → INCOMPLETE
// When a server returns no `endCursor`, falls back to offset paging.

/// One fetched connection page. [connection] is the GraphQL connection map
/// (`nodes`, `pageInfo{endCursor hasNextPage}`, optional `totalCount`), or
/// null when the request failed.
typedef CursorPageFetcher = Future<Map<String, dynamic>?> Function({
  String? after,
  int? offset,
  required bool useCursor,
});

class CursorPageResult {
  final List<dynamic> nodes;
  final int? totalCount;
  final bool complete;
  /// True when even the first page failed (callers usually return null then).
  final bool firstPageFailed;
  /// Whether cursor mode was used (false → offset fallback).
  final bool usedCursor;
  const CursorPageResult({
    required this.nodes,
    required this.totalCount,
    required this.complete,
    required this.firstPageFailed,
    required this.usedCursor,
  });
}

Future<CursorPageResult> paginateConnection({
  required CursorPageFetcher fetchPage,
  required int pageSize,
  int maxNodes = 25000,
  int? startOffset,
}) async {
  final nodes = <dynamic>[];
  int? totalCount;
  var useCursor = startOffset == null || startOffset == 0;
  String? after;
  var offset = startOffset ?? 0;
  var first = true;
  Object? prevFirstId;

  while (true) {
    var conn = await fetchPage(after: after, offset: useCursor ? null : offset, useCursor: useCursor);
    if (conn == null && first && useCursor) {
      // Older schema without `Cursor`/`after`: retry the first page in offset mode.
      useCursor = false;
      conn = await fetchPage(after: null, offset: offset, useCursor: false);
    }
    if (conn == null) {
      return CursorPageResult(
        nodes: nodes,
        totalCount: totalCount,
        complete: false,
        firstPageFailed: first,
        usedCursor: useCursor,
      );
    }
    first = false;
    final pageNodes = conn['nodes'] is List ? conn['nodes'] as List : const <dynamic>[];
    final tc = conn['totalCount'];
    if (tc is num && tc > 0) totalCount ??= tc.toInt();
    if (pageNodes.isEmpty) {
      return CursorPageResult(nodes: nodes, totalCount: totalCount, complete: true, firstPageFailed: false, usedCursor: useCursor);
    }
    final firstId = pageNodes.first is Map ? (pageNodes.first as Map)['id'] : null;
    if (prevFirstId != null && firstId == prevFirstId) {
      // Server ignored after/offset and replayed the same page.
      return CursorPageResult(nodes: nodes, totalCount: totalCount, complete: false, firstPageFailed: false, usedCursor: useCursor);
    }
    prevFirstId = firstId;
    nodes.addAll(pageNodes);

    final pageInfo = conn['pageInfo'] is Map ? conn['pageInfo'] as Map : null;
    final hasNextRaw = pageInfo?['hasNextPage'];
    final hasNext = hasNextRaw is bool ? hasNextRaw : pageNodes.length >= pageSize;
    if (!hasNext || (totalCount != null && nodes.length >= totalCount)) {
      return CursorPageResult(nodes: nodes, totalCount: totalCount, complete: true, firstPageFailed: false, usedCursor: useCursor);
    }
    if (nodes.length >= maxNodes) {
      return CursorPageResult(nodes: nodes, totalCount: totalCount, complete: false, firstPageFailed: false, usedCursor: useCursor);
    }

    final endCursor = pageInfo?['endCursor']?.toString();
    if (useCursor && endCursor != null && endCursor.isNotEmpty) {
      if (endCursor == after) {
        return CursorPageResult(nodes: nodes, totalCount: totalCount, complete: false, firstPageFailed: false, usedCursor: true);
      }
      after = endCursor;
    } else {
      // No cursor from the server — offset mode from here on.
      if (useCursor) {
        useCursor = false;
        offset = (startOffset ?? 0) + nodes.length;
      } else {
        offset += pageNodes.length;
      }
    }
  }
}
