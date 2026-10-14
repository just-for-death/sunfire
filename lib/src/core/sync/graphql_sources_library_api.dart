part of 'graphql_client_service.dart';

// IMP-034: moved verbatim from graphql_client_service.dart.
mixin _GraphQLSourcesLibraryApi on _GraphQLClientCore {
  Future<Map<String, dynamic>?> fetchSources() async {
    const queryStr = '''
      {
        sources {
          nodes {
            id
            name
            displayName
            lang
            supportsLatest
            iconUrl
            isConfigurable
            contentWarning
          }
        }
      }
    ''';
    final data = await query(queryStr, label: 'fetchSources');
    return _normalizeSourceOrExtensionNodes(data, rootKey: 'sources');
  }

  Future<Map<String, dynamic>?> fetchExtensions() async {
    const queryStr = '''
      {
        extensions {
          nodes {
            pkgName
            name
            versionName
            lang
            isInstalled
            isObsolete
            hasUpdate
            iconUrl
            contentWarning
          }
        }
      }
    ''';
    final data = await query(queryStr, label: 'fetchExtensions');
    return _normalizeSourceOrExtensionNodes(data, rootKey: 'extensions');
  }

  /// ISS-070: stamp `isNsfw` from `contentWarning` (fallback `isNsfw`); no name heuristic.
  Map<String, dynamic>? _normalizeSourceOrExtensionNodes(
    Map<String, dynamic>? data, {
    required String rootKey,
  }) {
    if (data == null || data[rootKey] is! Map) return data;
    final nodes = (data[rootKey] as Map)['nodes'];
    if (nodes is! List) return data;
    final normalized = <dynamic>[];
    for (final n in nodes) {
      if (n is! Map) {
        normalized.add(n);
        continue;
      }
      final m = Map<String, dynamic>.from(n);
      m['isNsfw'] = isNsfwFromSourceNode(m);
      final cw = parseContentWarning(m['contentWarning']);
      if (cw != null) m['contentWarning'] = cw;
      normalized.add(m);
    }
    return {
      ...data,
      rootKey: {
        ...(data[rootKey] as Map),
        'nodes': normalized,
      },
    };
  }

  Future<bool> installServerExtension(String pkgName) async {
    const mutStr = r'''
      mutation($id: String!, $patch: UpdateExtensionPatchInput!) {
        updateExtension(input: { id: $id, patch: $patch }) {
          extension {
            pkgName
            isInstalled
          }
        }
      }
    ''';
    final res = await query(mutStr, variables: {
      'id': pkgName,
      'patch': {'install': true},
    }, label: 'installServerExtension');
    return res != null;
  }

  Future<bool> uninstallServerExtension(String pkgName) async {
    const mutStr = r'''
      mutation($id: String!, $patch: UpdateExtensionPatchInput!) {
        updateExtension(input: { id: $id, patch: $patch }) {
          extension {
            pkgName
            isInstalled
          }
        }
      }
    ''';
    final res = await query(mutStr, variables: {
      'id': pkgName,
      'patch': {'uninstall': true},
    }, label: 'uninstallServerExtension');
    return res != null;
  }

  Future<bool> updateServerExtension(String pkgName) async {
    const mutStr = r'''
      mutation($id: String!, $patch: UpdateExtensionPatchInput!) {
        updateExtension(input: { id: $id, patch: $patch }) {
          extension {
            pkgName
            isInstalled
          }
        }
      }
    ''';
    final res = await query(mutStr, variables: {
      'id': pkgName,
      'patch': {'update': true},
    }, label: 'updateServerExtension');
    return res != null;
  }

  Future<Map<String, dynamic>?> updateExtension(String pkgName, String action) async {
    final act = action.toUpperCase();
    bool success;
    if (act == 'INSTALL') {
      success = await installServerExtension(pkgName);
    } else if (act == 'UNINSTALL') {
      success = await uninstallServerExtension(pkgName);
    } else if (act == 'UPDATE') {
      success = await updateServerExtension(pkgName);
    } else {
      return null;
    }
    // Propagate failure (null on a swallowed network/GraphQL error) so the
    // caller can roll back its optimistic UI instead of reporting success.
    return success ? {'status': 'ok'} : null;
  }

  /// Browse / search a server source.
  ///
  /// [filters] (ISS-079) are `FilterChangeInput`s built from
  /// [fetchSourceFilters]; when present the request is a SEARCH (that is how
  /// Suwayomi applies filters) with [searchQuery] as an optional query.
  Future<Map<String, dynamic>?> fetchSourceManga(
    String sourceId, {
    bool isLatest = false,
    int page = 1,
    String? searchQuery,
    List<SourceFilterChange>? filters,
  }) async {
    final q = searchQuery?.trim() ?? '';
    final hasFilters = filters != null && filters.isNotEmpty;
    final isSearch = q.isNotEmpty || hasFilters;
    final typeStr = isSearch ? 'SEARCH' : (isLatest ? 'LATEST' : 'POPULAR');
    const doc = r'''
      mutation($source: LongString!, $type: FetchSourceMangaType!, $page: Int!, $query: String, $filters: [FilterChangeInput!]) {
        fetchSourceManga(input: {
          source: $source,
          type: $type,
          page: $page,
          query: $query,
          filters: $filters
        }) {
          mangas {
            id
            title
            thumbnailUrl
            url
          }
          hasNextPage
        }
      }
    ''';
    return await query(doc, variables: {
      'source': sourceId,
      'type': typeStr,
      'page': page,
      if (q.isNotEmpty) 'query': q,
      if (hasFilters) 'filters': filterChangesToInput(filters),
    }, label: 'fetchSourceManga', op: GraphQLOp.scrapeRead);
  }

  @override
  Future<Map<String, dynamic>?> fetchLibrary() async {
    final userSel = capabilities.hasUserField ? _mangaUserFields : '';
    final markerSel = _markerSelection;
    final legacySel = capabilities.hasUserField ? '' : 'inLibrary\n            inLibraryAt\n            unreadCount';
    String pageQuery(bool useCursor) => '''
      query(\$first: Int!, ${useCursor ? '\$after: Cursor' : '\$offset: Int!'}) {
        mangas(condition: { inLibrary: true }, first: \$first, ${useCursor ? 'after: \$after' : 'offset: \$offset'}) {
          totalCount
          pageInfo { endCursor hasNextPage }
          nodes {
            id
            title
            author
            description
            thumbnailUrl
            sourceId
            $legacySel
            url
            realUrl
            $userSel
            $markerSel
            source {
              id
              name
              displayName
              iconUrl
              lang
            }
            categories {
              nodes {
                id
                name
              }
            }
          }
        }
      }
    ''';

    const pageSize = 200;
    // Cursor pagination (ISS-074). Whether pagination ran to a genuine end:
    // a page failing after the first is NOT a short library — it is a
    // transport failure, and the caller must not treat the pages it did get
    // as the complete server state.
    final page = await paginateConnection(
      pageSize: pageSize,
      fetchPage: ({String? after, int? offset, required bool useCursor}) async {
        final res = await query(
          pageQuery(useCursor),
          variables: {
            'first': pageSize,
            if (useCursor) 'after': after else 'offset': offset ?? 0,
          },
          label: 'fetchLibrary',
          op: GraphQLOp.read,
        );
        final m = res?['mangas'];
        return m is Map ? Map<String, dynamic>.from(m) : null;
      },
    );
    if (page.firstPageFailed) return null;
    if (!page.complete) {
      await LoggerService.instance.logWarning(
        'fetchLibrary: pagination stopped after ${page.nodes.length} nodes; '
        'reporting an INCOMPLETE snapshot',
        'GraphQL',
      );
    }

    final flatNodes = <dynamic>[
      for (final n in page.nodes)
        if (n is Map)
          flattenMangaUserFields(Map<String, dynamic>.from(n))
        else
          n,
    ];
    return {
      'mangas': {
        'totalCount': page.totalCount ?? flatNodes.length,
        'nodes': flatNodes,
      },
      kSnapshotCompleteKey: page.complete,
    };
  }

  /// When [capabilities.hasUserField], also select `chapter.user {…}` (ISS-072).
  String get _mangaChapterFields => capabilities.hasUserField
      ? '$_mangaChapterFieldsBase$_mangaChapterUserFields'
      : '$_mangaChapterFieldsBase${_chapterState()}\n';

  /// Marker selection for the current server (empty when unsupported).
  String get _markerSelection {
    if (!capabilities.hasChapterFetchMarkers) return '';
    return capabilities.hasUserField
        ? _chapterFetchMarkerFieldsUserScoped
        : _chapterFetchMarkerFields;
  }

  /// Test hook: the library page query for the current capabilities.
  @visibleForTesting
  String debugLibrarySelection() =>
      '${capabilities.hasUserField ? _mangaUserFields : ''}$_markerSelection';

  Future<Map<String, dynamic>?> fetchMangaDetails(int mangaServerId) async {
    // Manga block first, WITHOUT chapters: the nested `manga.chapters`
    // connection takes no pagination args on most Suwayomi builds, so very
    // long series silently truncate there. Chapters are fetched from the root
    // paginated `chapters` query, then merged into the same response shape.
    final userSel = capabilities.hasUserField ? _mangaUserFields : '';
    final mangaQueryStr = '''
      query(\$id: Int!) {
        manga(id: \$id) {
          id
          title
          artist
          author
          description
          genre
          status
          ${capabilities.hasUserField ? '' : 'inLibrary'}
          thumbnailUrl
          url
          realUrl
          $userSel
          source {
            id
            name
            displayName
            lang
          }
        }
      }
    ''';
    final mangaResRaw = await query(mangaQueryStr, variables: {'id': mangaServerId}, label: 'fetchMangaDetails');
    Map<String, dynamic>? mangaRes;
    if (mangaResRaw != null && mangaResRaw['manga'] is Map) {
      mangaRes = {
        ...mangaResRaw,
        'manga': flattenMangaUserFields(
          Map<String, dynamic>.from(mangaResRaw['manga'] as Map),
        ),
      };
    } else {
      mangaRes = mangaResRaw;
    }
    if (mangaRes == null || mangaRes['manga'] == null) {
      return _fetchMangaDetailsLegacy(mangaServerId);
    }

    const pageSize = 500;
    // See kSnapshotCompleteKey: a page failing after the first must not be
    // mistaken for "the server deleted these chapters", because the caller
    // hard-deletes chapters the server no longer reports. Cursor-paginated
    // (ISS-074); an empty page with hasNextPage: true is treated as the end.
    final chapterPage = await paginateConnection(
      pageSize: pageSize,
      fetchPage: ({String? after, int? offset, required bool useCursor}) async {
        final pageQueryStr = '''
          query(\$mangaId: Int!, \$first: Int!, ${useCursor ? '\$after: Cursor' : '\$offset: Int!'}) {
            chapters(condition: { mangaId: \$mangaId }, first: \$first, ${useCursor ? 'after: \$after' : 'offset: \$offset'}) {
              pageInfo { endCursor hasNextPage }
              nodes { $_mangaChapterFields }
            }
          }
        ''';
        final pageRes = await query(
          pageQueryStr,
          variables: {
            'mangaId': mangaServerId,
            'first': pageSize,
            if (useCursor) 'after': after else 'offset': offset ?? 0,
          },
          label: 'fetchMangaDetails.chapters',
          op: GraphQLOp.read,
        );
        final m = pageRes?['chapters'];
        return m is Map ? Map<String, dynamic>.from(m) : null;
      },
    );
    // Schema without the paginated root `chapters` query (older/alternate
    // Suwayomi builds): fall back to the single combined query. Best-effort
    // — such servers may still truncate very long series.
    if (chapterPage.firstPageFailed) return _fetchMangaDetailsLegacy(mangaServerId);
    final allNodes = chapterPage.nodes;
    final chaptersComplete = chapterPage.complete;
    if (!chaptersComplete) {
      await LoggerService.instance.logWarning(
        'fetchMangaDetails: chapter pagination for manga $mangaServerId stopped '
        'after ${allNodes.length} nodes; reporting an INCOMPLETE snapshot',
        'GraphQL',
      );
    }

    // Reassemble data['manga']['chapters']['nodes'] — the shape all callers
    // (detail screen, full chapter snapshot) consume.
    final mangaMap = Map<String, dynamic>.from(mangaRes['manga'] as Map<String, dynamic>);
    final flatNodes = <dynamic>[
      for (final n in allNodes)
        if (n is Map)
          flattenChapterUserFields(Map<String, dynamic>.from(n))
        else
          n,
    ];
    mangaMap['chapters'] = {'nodes': flatNodes};
    return {
      'manga': flattenMangaUserFields(mangaMap),
      kSnapshotCompleteKey: chaptersComplete,
    };
  }

  /// Single-query fallback used when the root paginated `chapters` query (or
  /// the manga query) is unavailable. Kept byte-for-byte identical to the
  /// original combined query.
  Future<Map<String, dynamic>?> _fetchMangaDetailsLegacy(int mangaServerId) async {
    final queryStr = r'''
      query($id: Int!) {
        manga(id: $id) {
          id
          title
          artist
          author
          description
          genre
          status
          #MSTATE#
          thumbnailUrl
          url
          realUrl
          source {
            id
            name
            displayName
            lang
          }
          chapters {
            nodes {
              id
              name
              chapterNumber
              url
              realUrl
              #CSTATE#
              pageCount
              fetchedAt
              uploadDate
              scanlator
            }
          }
        }
      }
    '''
        .replaceFirst('#MSTATE#', _mangaState(const ['inLibrary']))
        .replaceFirst('#CSTATE#', _chapterState());
    return await query(queryStr, variables: {'id': mangaServerId}, label: 'fetchMangaDetails');
  }

  Future<Map<String, dynamic>?> fetchMangaAndChapters(int mangaServerId) async {
    const mutStr = r'''
      mutation($id: Int!) {
        fetchMangaAndChapters(input: { id: $id, fetchManga: true, fetchChapters: true }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'id': mangaServerId}, label: 'fetchMangaAndChapters', op: GraphQLOp.scrapeRead);
  }

  /// Resolves the server manga id for a series URL on [sourceId] — the path
  /// used by source migration and `.tachibk` restore to keep a local-only
  /// series server-synced. Modern Suwayomi dropped the `addManga` mutation, so
  /// this first tries legacy `addManga` (older servers), then falls back to
  /// searching the source — preferring the caller's [title], then a query
  /// derived from [url] — and matching the best result by normalized URL or
  /// title. Returns the server manga id, or null when the series cannot be
  /// resolved on this server.
  Future<int?> fetchMangaIdByUrl(String sourceId, String url, {String? title}) async {
    if (url.trim().isEmpty) return null;

    // 1) Legacy Tachidesk/Suwayomi servers still expose the addManga mutation.
    // Skip when the capability probe already proved it missing (ISS-066).
    if (!capabilities.probed || capabilities.hasAddManga) {
      try {
        const mutStr = r'''
          mutation($sourceId: LongString!, $url: String!) {
            addManga(input: { sourceId: $sourceId, url: $url }) {
              id
            }
          }
        ''';
        final res = await query(mutStr, variables: {'sourceId': sourceId, 'url': url}, label: 'addMangaByUrl');
        final id = res?['addManga']?['id'];
        if (id is int && id > 0) return id;
        if (id is num && id.toInt() > 0) return id.toInt();
      } catch (e) {
        await LoggerService.instance
            .logWarning('addManga unsupported on this server, falling back to search: $e', 'GraphQL');
      }
    }


    // 2) Modern Suwayomi: search the source and pick the best match by URL/title.
    // Title-first — URL-slug words often fuzzy-match unrelated series (e.g.
    // webtoons indexes series under their localized titles, not their slugs).
    try {
      final queries = <String>{};
      if (title != null && title.trim().length >= 3) queries.add(title.trim());
      final derived = GraphQLClientService.urlToSearchQuery(url);
      if (derived.isNotEmpty) queries.add(derived);
      for (final q in queries) {
        final searchRes = await fetchSourceManga(sourceId, searchQuery: q);
        final mangas = searchRes?['fetchSourceManga']?['mangas'] as List<dynamic>?;
        final id = pickBestSourceMangaId(mangas, url: url, title: q);
        if (id != null) return id;
      }
      return null;
    } catch (e) {
      await LoggerService.instance.logWarning('Source search fallback failed for $url: $e', 'GraphQL');
      return null;
    }
  }

  /// Picks the best id from a [fetchSourceManga] `mangas` list for [url]/[title]:
  /// exact normalized URL, URL path-alias (containment), then normalized-title
  /// equality. Returns null when nothing is a confident match.
  int? pickBestSourceMangaId(List<dynamic>? mangas, {required String url, required String title}) {
    if (mangas == null || mangas.isEmpty) return null;
    final normTargetUrl = url
        .toLowerCase()
        .replaceAll(RegExp(r'^https?://[^/]+'), '')
        .replaceAll(RegExp(r'[/?#]+$'), '');
    final normAlphaTitle = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    int? titleFallbackId;
    for (final m in mangas) {
      final mMap = m is Map<String, dynamic> ? m : null;
      if (mMap == null) continue;
      final rawId = mMap['id'];
      final sid = rawId is int ? rawId : (rawId is num ? rawId.toInt() : null);
      if (sid == null || sid <= 0) continue;

      final mUrl = (mMap['url'] ?? '').toString().toLowerCase();
      final mTitle = (mMap['title'] ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final normMUrl = mUrl.replaceAll(RegExp(r'^https?://[^/]+'), '').replaceAll(RegExp(r'[/?#]+$'), '');
      if (normTargetUrl.isNotEmpty && normMUrl.isNotEmpty) {
        if (normMUrl == normTargetUrl ||
            (normMUrl.length >= 6 && (normMUrl.contains(normTargetUrl) || normTargetUrl.contains(normMUrl)))) {
          return sid;
        }
      }
      if (mTitle.isNotEmpty && mTitle == normAlphaTitle) {
        titleFallbackId ??= sid;
      }
    }
    return titleFallbackId;
  }

  /// Fuzzy-matches [sourceName] (display name from a local JS extension) against
  /// installed Suwayomi server sources and returns the matching server source ID
  /// string, or null when no match is found.
  Future<String?> resolveServerSourceId(String sourceName) async {
    try {
      final sourcesData = await fetchSources();
      final nodes = sourcesData?['sources']?['nodes'] as List<dynamic>?;
      if (nodes == null) return null;

      String normalize(String n) => n
          .toLowerCase()
          .replaceAll(RegExp(r'[\(\[{].*?[\)\]}]'), '')
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      final targetNorm = normalize(sourceName);
      if (targetNorm.isEmpty) return null;

      for (final n in nodes) {
        final map = n as Map<String, dynamic>;
        final nameNorm = normalize(map['name'] as String? ?? '');
        final dispNorm = normalize(map['displayName'] as String? ?? '');
        if (nameNorm == targetNorm ||
            dispNorm == targetNorm ||
            nameNorm.contains(targetNorm) ||
            targetNorm.contains(nameNorm)) {
          return map['id'].toString();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchCategories() async {
    // `isDefaultCategory` exists only on server v2.4.2366+. Requesting an
    // unknown field fails the whole query (validation error → null data),
    // which would silently stop category sync on older servers — so it is
    // interpolated only when the capability probe saw it.
    final defaultCatSel =
        capabilities.hasCategoryIsDefaultCategory ? 'isDefaultCategory' : '';
    final queryStr = '''
      {
        categories {
          totalCount
          nodes {
            id
            name
            order
            default
            includeInUpdate
            includeInDownload
            $defaultCatSel
          }
        }
      }
    ''';
    final data = await query(queryStr, label: 'fetchCategories');
    if (data == null || data['categories'] is! Map) return data;
    // This query is not paginated, so reaching here means the server answered
    // in full. Stamping it lets `_syncCategories` distinguish "the user deleted
    // a category" from "the response was short" before running the
    // `replaceAll` delete — the category path had no completeness guard at all,
    // so a truncated response erased the user's shelf and orphaned every
    // `Manga.categoryIds` entry pointing at it.
    final catMap = data['categories'] as Map<String, dynamic>;
    final nodes = catMap['nodes'];
    final total = parseIntSafe(catMap['totalCount']);
    final list = nodes is List ? nodes : const <dynamic>[];
    if (total > 0) {
      data[kSnapshotCompleteKey] = list.length >= total;
    }
    // If the server omitted `totalCount`, deliberately leave the key UNSET.
    // `isCompleteSnapshot` defaults to false for an unmarked map, so the caller
    // keeps its local categories. Marking a non-empty-but-possibly-truncated
    // list "complete" would let the `replaceAll` delete run — which is the
    // catastrophe the guard exists to prevent. Failing safe here costs one
    // sync cycle of category refresh; guessing wrong costs the user's shelf.
    return data;
  }

  Future<Map<String, dynamic>?> fetchTrackers() async {
    const queryStr = '''
      {
        trackers {
          nodes {
            id
            name
            isLoggedIn
            authUrl
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchTrackers');
  }
}
