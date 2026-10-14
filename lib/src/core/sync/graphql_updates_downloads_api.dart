part of 'graphql_client_service.dart';

// IMP-034: moved verbatim from graphql_client_service.dart.
mixin _GraphQLUpdatesDownloadsApi on _GraphQLClientCore {
  Future<Map<String, dynamic>?> fetchHistoryChapters(int offset) async {
    // Paginate the whole read history (not just the first 500) and order by
    // last-read so the most recent history is always kept when the server
    // truncates. Cursor-paginated (ISS-074): LAST_READ_AT ordering reshuffles
    // while another device reads, which made offset paging skip/duplicate.
    // An empty page is the end even when hasNextPage claims otherwise.
    const pageSize = 500;
    String pageQuery(bool useCursor) => '''
      query(\$first: Int!, ${useCursor ? '\$after: Cursor' : '\$offset: Int!'}) {
        chapters(
          condition: { isRead: true }
          order: [{ by: LAST_READ_AT, byType: DESC }]
          first: \$first
          ${useCursor ? 'after: \$after' : 'offset: \$offset'}
        ) {
          totalCount
          pageInfo { endCursor hasNextPage }
          nodes {
            id
            name
            chapterNumber
            ${_chapterState()}
            mangaId
            manga {
              id
              title
              thumbnailUrl
            }
          }
        }
      }
    ''';
    final page = await paginateConnection(
      pageSize: pageSize,
      maxNodes: 5000, // hard ceiling: never balloon memory
      startOffset: offset < 0 ? 0 : offset,
      fetchPage: ({String? after, int? offset, required bool useCursor}) async {
        final res = await query(
          pageQuery(useCursor),
          variables: {
            'first': pageSize,
            if (useCursor) 'after': after else 'offset': offset ?? 0,
          },
          label: 'fetchHistoryChapters',
          op: GraphQLOp.read,
        );
        final m = res?['chapters'];
        return m is Map ? Map<String, dynamic>.from(m) : null;
      },
    );
    if (page.firstPageFailed) return null;
    return {
      'chapters': {'totalCount': page.totalCount ?? page.nodes.length, 'nodes': page.nodes},
      kSnapshotCompleteKey: page.complete,
    };
  }

  /// Updates feed, newest `fetchedAt` first.
  ///
  /// [sinceFetchedAt] (epoch seconds) narrows to a time window
  /// (`fetchedAt > since`, ISS-074) so incremental syncs only pull what is new
  /// instead of re-reading the top-N every cycle.
  Future<Map<String, dynamic>?> fetchUpdatesChapters({int first = 100, int? sinceFetchedAt}) async {
    final windowFilter = sinceFetchedAt != null && sinceFetchedAt > 0
        ? ', fetchedAt: { greaterThan: "$sinceFetchedAt" }'
        : '';
    final queryStr = '''
      {
        chapters(
          filter: { inLibrary: { equalTo: true }$windowFilter }
          order: [{ by: FETCHED_AT, byType: DESC }]
          first: $first
        ) {
          totalCount
          pageInfo { endCursor hasNextPage }
          nodes {
            id
            name
            chapterNumber
            ${_chapterState(const ['isRead', 'isBookmarked', 'lastPageRead', 'isDownloaded'])}
            fetchedAt
            uploadDate
            scanlator
            mangaId
            manga {
              id
              title
              thumbnailUrl
              ${_mangaState(const ['inLibrary', 'inLibraryAt'])}
              source {
                displayName
              }
            }
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchUpdatesChapters', op: GraphQLOp.read);
  }

  Future<String?> fetchLastUpdateTimestamp() async {
    const queryStr = '''
      {
        lastUpdateTimestamp {
          timestamp
        }
      }
    ''';
    final data = await query(queryStr, label: 'fetchLastUpdateTimestamp');
    if (data != null && data.containsKey('lastUpdateTimestamp')) {
      final payload = data['lastUpdateTimestamp'] as Map<String, dynamic>?;
      return payload?['timestamp']?.toString();
    }
    return null;
  }

  /// Triggers a server library update.
  ///
  /// When [categoryIds] is non-null/non-empty, only those categories are
  /// updated (`updateLibrary(input: { categories: [...] })`) — ISS-071
  /// "Update this category".
  @override
  Future<Map<String, dynamic>?> triggerServerLibraryUpdate({
    List<int>? categoryIds,
  }) async {
    if (categoryIds != null && categoryIds.isNotEmpty) {
      const mutStr = r'''
        mutation($categories: [Int!]!) {
          updateLibrary(input: { categories: $categories }) {
            clientMutationId
          }
        }
      ''';
      return await query(
        mutStr,
        variables: {'categories': categoryIds},
        label: 'triggerServerLibraryUpdate.categories',
      );
    }
    const mutStr = r'''
      mutation {
        updateLibrary(input: {}) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, label: 'triggerServerLibraryUpdate');
  }

  Future<Map<String, dynamic>?> fetchServerUpdateStatus() async {
    // `updateStatus` is deprecated server-side; `libraryUpdateStatus.jobsInfo`
    // exposes the equivalent counters (isRunning / totalJobs / finishedJobs).
    const queryStr = r'''
      {
        libraryUpdateStatus {
          jobsInfo {
            isRunning
            finishedJobs
            totalJobs
            skippedCategoriesCount
            skippedMangasCount
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchServerUpdateStatus');
  }

  Future<Map<String, dynamic>?> enqueueChapterDownload(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        enqueueChapterDownload(input: { id: $chapterId }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'chapterId': chapterId},
      label: 'enqueueChapterDownload',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> enqueueChapterDownloads(List<int> chapterIds) async {
    const mutStr = r'''
      mutation($chapterIds: [Int!]!) {
        enqueueChapterDownloads(input: { ids: $chapterIds }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'chapterIds': chapterIds},
      label: 'enqueueChapterDownloads',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> deleteDownloadedChapter(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        deleteDownloadedChapter(input: { id: $chapterId }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'chapterId': chapterId},
      label: 'deleteDownloadedChapter',
    )).data;
  }

  Future<Map<String, dynamic>?> fetchDownloadStatus() async {
    // Keep selection aligned with downloadStatusChanged WS (ISS-086 / ISS-067)
    // so the Downloads screen has position/tries/manga titles on initial open.
    final queryStr = r'''
      {
        downloadStatus {
          state
          queue {
            position
            progress
            state
            tries
            chapter {
              id
              name
              #STATE#
            }
            manga {
              id
              title
            }
          }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isDownloaded']));
    return await query(queryStr, label: 'fetchDownloadStatus');
  }

  // ── ISS-080 B5: download queue dequeue / reorder ──────────────────────
  //
  // Each returns the server's resulting `downloadStatus` (same selection as
  // [fetchDownloadStatus]) or null on failure. Per-item `state` is
  // QUEUED | DOWNLOADING | FINISHED | ERROR; `tries` is the retry count.

  String get _downloadStatusSelection => '''
          downloadStatus {
            state
            queue {
              position
              progress
              state
              tries
              chapter { id name ${_chapterState(const ['isDownloaded'])} }
              manga { id title }
            }
          }
''';

  /// Remove one chapter from the server download queue.
  Future<Map<String, dynamic>?> dequeueChapterDownload(int chapterId) async {
    final mutStr = '''
      mutation(\$id: Int!) {
        dequeueChapterDownload(input: { id: \$id }) {
          $_downloadStatusSelection
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': chapterId},
      label: 'dequeueChapterDownload',
    )).data;
  }

  /// Remove many chapters from the server download queue in one round-trip.
  /// Falls back to per-id [dequeueChapterDownload] when the bulk call fails.
  @override
  Future<Map<String, dynamic>?> dequeueChapterDownloads(List<int> chapterIds) async {
    if (chapterIds.isEmpty) return null;
    if (chapterIds.length == 1) return dequeueChapterDownload(chapterIds.first);
    final mutStr = '''
      mutation(\$ids: [Int!]!) {
        dequeueChapterDownloads(input: { ids: \$ids }) {
          $_downloadStatusSelection
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'ids': chapterIds},
      label: 'dequeueChapterDownloads',
    )).data;
  }

  /// Move [chapterId] to queue index [to] (0-based, clamped at 0).
  Future<Map<String, dynamic>?> reorderChapterDownload(int chapterId, int to) async {
    final mutStr = '''
      mutation(\$chapterId: Int!, \$to: Int!) {
        reorderChapterDownload(input: { chapterId: \$chapterId, to: \$to }) {
          $_downloadStatusSelection
        }
      }
    ''';
    return await query(
      mutStr,
      variables: {'chapterId': chapterId, 'to': to < 0 ? 0 : to},
      label: 'reorderChapterDownload',
    );
  }

  /// Bulk reorder; each record is `(chapterId: id, to: index)`. Falls back to
  /// sequential [reorderChapterDownload] calls when the bulk mutation fails.
  Future<Map<String, dynamic>?> reorderChapterDownloads(
    List<({int chapterId, int to})> reorders,
  ) async {
    if (reorders.isEmpty) return null;
    if (reorders.length == 1) {
      return reorderChapterDownload(reorders.first.chapterId, reorders.first.to);
    }
    final mutStr = '''
      mutation(\$reorders: [ChapterDownloadReorderInput!]!) {
        reorderChapterDownloads(input: { reorders: \$reorders }) {
          $_downloadStatusSelection
        }
      }
    ''';
    final res = await query(
      mutStr,
      variables: {'reorders': buildDownloadReorderVariables(reorders)},
      label: 'reorderChapterDownloads',
    );
    if (res != null) return res;
    Map<String, dynamic>? last;
    for (final r in reorders) {
      last = await reorderChapterDownload(r.chapterId, r.to);
    }
    return last;
  }

  // ── ISS-084 B13: server / WebUI version + update info ─────────────────

  /// `checkForServerUpdates` → list of `{channel, tag, url}` (empty when up
  /// to date). Null on failure. Server calls GitHub, so uses the slow timeout.
  Future<List<ServerUpdateInfo>?> checkForServerUpdates() async {
    const q = '{ checkForServerUpdates { channel tag url } }';
    final res = await query(q, label: 'checkForServerUpdates', op: GraphQLOp.slowRead);
    final list = res?['checkForServerUpdates'];
    if (list is! List) return null;
    return [
      for (final e in list)
        if (e is Map) ServerUpdateInfo.fromMap(Map<String, dynamic>.from(e)),
    ];
  }

  /// `aboutWebUI` → `{channel, tag, updateTimestamp}`.
  Future<WebUIInfo?> fetchAboutWebUI() async {
    const q = '{ aboutWebUI { channel tag updateTimestamp } }';
    final res = await query(q, label: 'aboutWebUI', op: GraphQLOp.read);
    final m = res?['aboutWebUI'];
    return m is Map ? WebUIInfo.fromMap(Map<String, dynamic>.from(m)) : null;
  }

  /// `getWebUIUpdateStatus` → `{state, progress, info{channel, tag}}`.
  /// state: IDLE | DOWNLOADING | FINISHED | ERROR.
  Future<WebUIUpdateStatusInfo?> getWebUIUpdateStatus() async {
    const q = '{ getWebUIUpdateStatus { state progress info { channel tag } } }';
    final res = await query(q, label: 'getWebUIUpdateStatus', op: GraphQLOp.read);
    final m = res?['getWebUIUpdateStatus'];
    return m is Map ? WebUIUpdateStatusInfo.fromMap(Map<String, dynamic>.from(m)) : null;
  }

  /// `checkForWebUIUpdate` → `{channel, tag, updateAvailable}`.
  Future<WebUIUpdateCheckInfo?> checkForWebUIUpdate() async {
    const q = '{ checkForWebUIUpdate { channel tag updateAvailable } }';
    final res = await query(q, label: 'checkForWebUIUpdate', op: GraphQLOp.slowRead);
    final m = res?['checkForWebUIUpdate'];
    return m is Map ? WebUIUpdateCheckInfo.fromMap(Map<String, dynamic>.from(m)) : null;
  }

  /// One-shot bundle for About / Server settings: aboutServer + aboutWebUI +
  /// WebUI update status (+ optional server update check). Failing parts are null.
  Future<ServerVersionBundle> fetchServerVersionBundle({bool includeUpdateCheck = false}) async {
    Map<String, dynamic>? res;
    // L1: v2.4.x exposes `aboutServer.platformInfo { os arch jvm headless }`
    // (there is no `platform` field). An unknown field fails the whole query
    // (validation error → null data), so older servers retry without it.
    const withPlatform = '''
      {
        aboutServer { name version buildType buildTime github discord platformInfo { os arch jvm headless } }
        aboutWebUI { channel tag updateTimestamp }
        getWebUIUpdateStatus { state progress info { channel tag } }
      }
    ''';
    const legacy = '''
      {
        aboutServer { name version buildType buildTime github discord }
        aboutWebUI { channel tag updateTimestamp }
        getWebUIUpdateStatus { state progress info { channel tag } }
      }
    ''';
    res = await query(withPlatform, label: 'fetchServerVersionBundle', op: GraphQLOp.read);
    res ??= await query(legacy, label: 'fetchServerVersionBundle.legacy', op: GraphQLOp.read);
    final about = res?['aboutServer'];
    final web = res?['aboutWebUI'];
    final st = res?['getWebUIUpdateStatus'];
    return ServerVersionBundle(
      aboutServer: about is Map ? Map<String, dynamic>.from(about) : null,
      webUI: web is Map ? WebUIInfo.fromMap(Map<String, dynamic>.from(web)) : null,
      webUIUpdateStatus:
          st is Map ? WebUIUpdateStatusInfo.fromMap(Map<String, dynamic>.from(st)) : null,
      serverUpdates: includeUpdateCheck ? await checkForServerUpdates() : null,
    );
  }

  // ── ISS-073 B3: clear server cookies + cache ──────────────────────────

  /// `clearCookiesAndCache` — for the reader/source "Clear cookies" button
  /// (e.g. after a Cloudflare loop). Returns true on success.
  Future<bool> clearCookiesAndCache() async {
    const mutStr = '''
      mutation {
        clearCookiesAndCache(input: {}) {
          clientMutationId
        }
      }
    ''';
    final res = await query(mutStr, label: 'clearCookiesAndCache');
    return res != null;
  }
}
