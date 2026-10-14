part of 'graphql_client_service.dart';

// IMP-034: moved verbatim from graphql_client_service.dart.
mixin _GraphQLResultsSettingsApi on _GraphQLClientCore {
  /// Runs [call] and turns its nullable map into a [ServerResult].
  @visibleForTesting
  Future<ServerResult<Map<String, dynamic>>> classifyCall(
    Future<Map<String, dynamic>?> Function() call, {
    String? label,
  }) async {
    if (!isConfigured) return ServerErr(ServerFailure(ServerFailureKind.notConfigured, label));
    final data = await call();
    return classifyServerResponse(
      (data: data, wasTransportFailure: lastRequestWasTransportFailure),
      label: label,
    );
  }

  Future<ServerResult<Map<String, dynamic>>> deleteCategoryResult(int categoryId) =>
      classifyCall(() => deleteCategory(categoryId), label: 'deleteCategory');
  Future<ServerResult<Map<String, dynamic>>> updateCategoryOrderResult(int categoryId, int position) =>
      classifyCall(() => updateCategoryOrder(categoryId, position), label: 'updateCategoryOrder');
  Future<ServerResult<Map<String, dynamic>>> updateMangaLibraryStateResult(int mangaId, bool inLibrary) =>
      classifyCall(() => updateMangaLibraryState(mangaId, inLibrary), label: 'updateMangaLibraryState');
  Future<ServerResult<Map<String, dynamic>>> updateMangaCategoriesResult(int mangaId, List<int> categoryIds) =>
      classifyCall(() => updateMangaCategories(mangaId, categoryIds), label: 'updateMangaCategories');
  Future<ServerResult<Map<String, dynamic>>> enqueueChapterDownloadsResult(List<int> chapterIds) =>
      classifyCall(() => enqueueChapterDownloads(chapterIds), label: 'enqueueChapterDownloads');
  Future<ServerResult<Map<String, dynamic>>> dequeueChapterDownloadsResult(List<int> chapterIds) =>
      classifyCall(() => dequeueChapterDownloads(chapterIds), label: 'dequeueChapterDownloads');
  Future<ServerResult<Map<String, dynamic>>> deleteDownloadedChaptersResult(List<int> ids) =>
      classifyCall(() => deleteDownloadedChapters(ids), label: 'deleteDownloadedChapters');
  Future<ServerResult<Map<String, dynamic>>> startDownloaderResult() =>
      classifyCall(() => startDownloader(), label: 'startDownloader');
  Future<ServerResult<Map<String, dynamic>>> stopDownloaderResult() =>
      classifyCall(() => stopDownloader(), label: 'stopDownloader');
  Future<ServerResult<Map<String, dynamic>>> clearDownloaderResult() =>
      classifyCall(() => clearDownloader(), label: 'clearDownloader');
  Future<ServerResult<Map<String, dynamic>>> setGlobalMetaResult(String key, String value) =>
      classifyCall(() => setGlobalMeta(key, value), label: 'setGlobalMeta');
  Future<ServerResult<Map<String, dynamic>>> updateServerSettingsResult(Map<String, dynamic> partialSettings) =>
      classifyCall(() => updateServerSettings(partialSettings), label: 'updateServerSettings');
  Future<ServerResult<Map<String, dynamic>>> trackProgressResult(int mangaId) =>
      classifyCall(() => trackProgress(mangaId), label: 'trackProgress');
  Future<ServerResult<Map<String, dynamic>>> fetchChapterPagesResult(int chapterId) =>
      classifyCall(() => fetchChapterPages(chapterId), label: 'fetchChapterPages');
  Future<ServerResult<Map<String, dynamic>>> fetchCategoriesResult() =>
      classifyCall(() => fetchCategories(), label: 'fetchCategories');
  Future<ServerResult<Map<String, dynamic>>> fetchLibraryResult() =>
      classifyCall(() => fetchLibrary(), label: 'fetchLibrary');

  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    const mutStr = r'''
      mutation($categoryId: Int!) {
        deleteCategory(input: { categoryId: $categoryId }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'categoryId': categoryId},
      label: 'deleteCategory',
    )).data;
  }

  Future<Map<String, dynamic>?> setMangaCategories(
    int mangaId,
    List<int> categoryIds, {
    List<int>? existingCategoryIds,
  }) async {
    if (existingCategoryIds != null) {
      final toAdd = categoryIds.where((c) => !existingCategoryIds.contains(c)).toList();
      final toRemove = existingCategoryIds.where((c) => !categoryIds.contains(c)).toList();
      const patchMut = r'''
        mutation($id: Int!, $add: [Int!], $remove: [Int!]) {
          updateMangaCategories(input: { id: $id, patch: { addToCategories: $add, removeFromCategories: $remove } }) {
            clientMutationId
          }
        }
      ''';
      final res = await _queryAndClassify(patchMut, variables: {'id': mangaId, 'add': toAdd, 'remove': toRemove}, label: 'updateMangaCategories');
      if (res.data != null) return res.data;
    }
    // Modern Suwayomi's UpdateMangaCategoriesPatchInput has no `categories`
    // field — only addToCategories / clearCategories / removeFromCategories.
    // "Replace all" is therefore a clear + add (verified against live schema).
    const mutStr = r'''
      mutation($id: Int!, $categories: [Int!]!) {
        updateMangaCategories(input: { id: $id, patch: { clearCategories: true, addToCategories: $categories } }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': mangaId, 'categories': categoryIds},
      label: 'setMangaCategories',
    )).data;
  }

  // ── ISS-077 B9: per-manga meta (sunfire_* namespace) ───────────────────

  /// `setMangaMeta` with the key forced into the `sunfire_` namespace.
  /// Returns true on success.
  Future<bool> setMangaMeta(int mangaId, String key, String value) async {
    if (mangaId <= 0 || key.trim().isEmpty) return false;
    const mutStr = r'''
      mutation($mangaId: Int!, $key: String!, $value: String!) {
        setMangaMeta(input: { meta: { mangaId: $mangaId, key: $key, value: $value } }) {
          meta { key value }
        }
      }
    ''';
    final res = await _queryAndClassify(
      mutStr,
      variables: {'mangaId': mangaId, 'key': GraphQLClientService.sunfireMetaKey(key.trim()), 'value': value},
      label: 'setMangaMeta',
    );
    return res.data != null;
  }

  /// ISS-141: `setChapterMeta` with the key forced into the `sunfire_`
  /// namespace. Returns true on success.
  Future<bool> setChapterMeta(int chapterId, String key, String value) async {
    if (chapterId <= 0 || key.trim().isEmpty) return false;
    const mutStr = r'''
      mutation($chapterId: Int!, $key: String!, $value: String!) {
        setChapterMeta(input: { meta: { chapterId: $chapterId, key: $key, value: $value } }) {
          meta { key value }
        }
      }
    ''';
    final res = await _queryAndClassify(
      mutStr,
      variables: {'chapterId': chapterId, 'key': GraphQLClientService.sunfireMetaKey(key.trim()), 'value': value},
      label: 'setChapterMeta',
    );
    return res.data != null;
  }

  /// `deleteMangaMeta` (key namespaced like [setMangaMeta]).
  Future<bool> deleteMangaMeta(int mangaId, String key) async {
    if (mangaId <= 0 || key.trim().isEmpty) return false;
    const mutStr = r'''
      mutation($mangaId: Int!, $key: String!) {
        deleteMangaMeta(input: { mangaId: $mangaId, key: $key }) {
          clientMutationId
        }
      }
    ''';
    final res = await _queryAndClassify(
      mutStr,
      variables: {'mangaId': mangaId, 'key': GraphQLClientService.sunfireMetaKey(key.trim())},
      label: 'deleteMangaMeta',
    );
    return res.data != null;
  }

  /// All `sunfire_*` meta for a manga as `{key: value}` (prefix kept).
  /// Null on failure.
  Future<Map<String, String>?> fetchSunfireMangaMeta(int mangaId) async {
    const q = r'''
      query($id: Int!) {
        manga(id: $id) { meta { key value } }
      }
    ''';
    final res = await query(q, variables: {'id': mangaId}, label: 'fetchSunfireMangaMeta', op: GraphQLOp.read);
    final metas = (res?['manga'] as Map?)?['meta'];
    if (metas is! List) return null;
    return {
      for (final m in metas)
        if (m is Map && (m['key']?.toString() ?? '').startsWith(GraphQLClientService.kSunfireMetaPrefix))
          m['key'].toString(): m['value']?.toString() ?? '',
    };
  }

  /// `deleteGlobalMeta(key)`. Returns true on success.
  Future<bool> deleteGlobalMeta(String key) async {
    const mutStr = r'''
      mutation($key: String!) {
        deleteGlobalMeta(input: { key: $key }) {
          clientMutationId
        }
      }
    ''';
    final res = await query(mutStr, variables: {'key': key}, label: 'deleteGlobalMeta');
    return res != null;
  }

  Future<Map<String, dynamic>?> setGlobalMeta(String key, String value) async {
    try {
      const mutStr = r'''
        mutation($key: String!, $value: String!) {
          setGlobalMeta(input: { meta: { key: $key, value: $value } }) {
            meta {
              key
              value
            }
          }
        }
      ''';
      return await query(mutStr, variables: {'key': key, 'value': value}, label: 'setGlobalMeta');
    } catch (_) {
      return null;
    }
  }

  // ── SERVER SETTINGS INTEGRATION ────────────────────────────────────────

  /// Fetch server + per-user settings (ISS-064/065).
  ///
  /// Secrets (`authPassword`, `socksProxyPassword`, `syncYomiApiKey`,
  /// `databasePassword`) are intentionally not selected — screens show
  /// set/not-set from empty placeholders. Per-user keys are read from
  /// `userSettings` and merged into the returned `settings` map for
  /// existing callers.
  Future<Map<String, dynamic>?> fetchServerSettings() async {
    const queryStr = '''
      query {
        settings {
          authMode
          authUsername
          autoBackupIncludeCategories
          autoBackupIncludeChapters
          autoBackupIncludeClientData
          autoBackupIncludeHistory
          autoBackupIncludeManga
          autoBackupIncludeServerSettings
          autoBackupIncludeTracking
          backupInterval
          backupPath
          backupTTL
          backupTime
          debugLogsEnabled
          downloadAsCbz
          downloadsPath
          electronPath
          flareSolverrAsResponseFallback
          flareSolverrEnabled
          flareSolverrSessionName
          flareSolverrSessionTtl
          flareSolverrTimeout
          flareSolverrUrl
          globalUpdateInterval
          initialOpenInBrowserEnabled
          ip
          kcefEnabled
          localSourcePath
          maxLogFiles
          maxLogFileSize
          maxLogFolderSize
          maxSourcesInParallel
          port
          socksProxyEnabled
          socksProxyHost
          socksProxyPort
          socksProxyUsername
          socksProxyVersion
          systemTrayEnabled
          useHikariConnectionPool
          webUIChannel
          webUIFlavor
          webUIInterface
          webUIUpdateCheckInterval
        }
        userSettings {
          autoDownloadIgnoreReUploads
          autoDownloadNewChapters
          autoDownloadNewChaptersLimit
          excludeCompleted
          excludeEntryWithUnreadChapters
          excludeNotStarted
          excludeUnreadChapters
          opdsEnablePageReadProgress
          opdsItemsPerPage
          opdsMarkAsReadOnDownload
          opdsShowOnlyDownloadedChapters
          opdsShowOnlyUnreadChapters
          opdsSkipChapterMetadataFeed
          opdsUseBinaryFileSizes
          syncDataCategories
          syncDataChapters
          syncDataHistory
          syncDataManga
          syncDataTracking
          syncYomiEnabled
          syncYomiHost
          updateMangas
        }
        aboutServer {
          version
          buildTime
        }
      }
    ''';
    final res = await query(queryStr, label: 'fetchServerSettings');
    if (res == null) return null;
    final settings = Map<String, dynamic>.from(
      (res['settings'] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final fsTimeout = settings['flareSolverrTimeout'];
    if (fsTimeout is num && fsTimeout > 0) {
      flareSolverrTimeoutSeconds = fsTimeout.toInt();
    }
    final user = (res['userSettings'] as Map?)?.cast<String, dynamic>();
    if (user != null) {
      settings.addAll(user);
    }
    return {
      'settings': settings,
      if (user != null) 'userSettings': user,
      if (res['aboutServer'] != null) 'aboutServer': res['aboutServer'],
    };
  }

  /// Update server-wide settings via `setSettings` (PartialSettingsTypeInput).
  Future<Map<String, dynamic>?> updateServerSettings(Map<String, dynamic> partialSettings) async {
    // Reject accidental per-user or unknown keys before they hit GraphQL validation.
    final cleaned = <String, dynamic>{};
    for (final e in partialSettings.entries) {
      if (isServerSettingsInputField(e.key)) {
        cleaned[e.key] = e.value;
      }
    }
    if (cleaned.isEmpty) return null;
    const mutStr = r'''
      mutation SetServerSettings($settings: PartialSettingsTypeInput!) {
        setSettings(input: { settings: $settings }) {
          settings {
            authMode
            authUsername
            debugLogsEnabled
            downloadAsCbz
            downloadsPath
            flareSolverrEnabled
            globalUpdateInterval
            ip
            localSourcePath
            maxSourcesInParallel
            port
            socksProxyEnabled
            systemTrayEnabled
            webUIChannel
            webUIFlavor
            webUIInterface
            webUIUpdateCheckInterval
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'settings': cleaned}, label: 'updateServerSettings');
  }

  /// Update per-user settings via `setUserSettings` (PartialUserSettingsTypeInput).
  Future<Map<String, dynamic>?> updateUserSettings(Map<String, dynamic> partialSettings) async {
    final cleaned = <String, dynamic>{};
    for (final e in partialSettings.entries) {
      if (isUserSettingsInputField(e.key)) {
        cleaned[e.key] = e.value;
      }
    }
    if (cleaned.isEmpty) return null;
    const mutStr = r'''
      mutation SetUserSettings($userSettings: PartialUserSettingsTypeInput!) {
        setUserSettings(input: { userSettings: $userSettings }) {
          userSettings {
            autoDownloadIgnoreReUploads
            autoDownloadNewChapters
            autoDownloadNewChaptersLimit
            excludeCompleted
            excludeEntryWithUnreadChapters
            excludeNotStarted
            excludeUnreadChapters
            opdsEnablePageReadProgress
            opdsItemsPerPage
            opdsMarkAsReadOnDownload
            opdsShowOnlyDownloadedChapters
            opdsShowOnlyUnreadChapters
            opdsSkipChapterMetadataFeed
            opdsUseBinaryFileSizes
            syncYomiEnabled
            syncYomiHost
            updateMangas
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'userSettings': cleaned}, label: 'updateUserSettings');
  }

  /// Route a single key to setSettings or setUserSettings (ISS-064).
  /// Returns the GraphQL data map on success, or null on failure.
  Future<Map<String, dynamic>?> persistSetting(String key, dynamic val) async {
    if (isUserSettingsInputField(key)) {
      return updateUserSettings({key: val});
    }
    if (isServerSettingsInputField(key)) {
      return updateServerSettings({key: val});
    }
    await LoggerService.instance.logWarning(
      'persistSetting: unknown settings key "$key"',
      'GraphQL',
    );
    return null;
  }

  /// Trigger global library update on server
  Future<Map<String, dynamic>?> triggerGlobalLibraryUpdate() async {
    const mutStr = '''
      mutation {
        updateLibrary(input: {}) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      label: 'updateLibrary',
    )).data;
  }

  /// Clear cached images on server
  Future<Map<String, dynamic>?> clearServerCachedImages() async {
    const mutStr = '''
      mutation {
        clearCachedImages(input: {}) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      label: 'clearCachedImages',
    )).data;
  }

  /// Create immediate backup on server with options
  Future<Map<String, dynamic>?> createServerBackup({
    bool includeCategories = true,
    bool includeChapters = true,
    bool includeHistory = true,
    bool includeTracking = true,
    bool includeClientData = true,
  }) async {
    const mutStr = r'''
      mutation CreateBackup($flags: PartialBackupFlagsInput) {
        createBackup(input: { flags: $flags }) {
          clientMutationId
          url
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {
        'flags': {
          'includeManga': true,
          'includeCategories': includeCategories,
          'includeChapters': includeChapters,
          'includeHistory': includeHistory,
          'includeTracking': includeTracking,
          'includeClientData': includeClientData,
        },
      },
      label: 'createBackup',
    )).data;
  }

  /// Query restore status for ongoing backup restoration
  Future<Map<String, dynamic>?> fetchRestoreStatus(String restoreId) async {
    const queryStr = r'''
      query RestoreStatus($restoreId: String!) {
        restoreStatus(id: $restoreId) {
          mangaProgress
          state
          totalManga
        }
      }
    ''';
    return await query(queryStr, variables: {'restoreId': restoreId}, label: 'fetchRestoreStatus');
  }

  /// Fetch library changes since [since] using real Suwayomi filters.
  ///
  /// There is no `delta` / `mangaByIds` root field on Suwayomi. This uses
  /// `mangas(filter: lastFetchedAt/chaptersLastFetchedAt > since)` and
  /// `chapters(filter: fetchedAt > since, inLibrary)` — the same filter
  /// surface as [fetchUpdatesChapters].
  ///
  /// Returns `{ manga: [...nodes], chapters: [...nodes], categories: [...] }`.
  Future<Map<String, dynamic>?> fetchDelta({
    required DateTime since,
    Set<int>? mangaIds,
    Set<int>? categoryIds,
  }) async {
    final sinceSec = since.millisecondsSinceEpoch ~/ 1000;
    if (sinceSec <= 0) {
      // Epoch zero means "full sync" — refuse invent-delta theater; callers
      // should use the existing full library sync path instead.
      await LoggerService.instance.logWarning(
        'fetchDelta: since=$since is a full-history request; use fetchLibrary',
        'GraphQL',
      );
      return null;
    }

    final mangaIdFilter = (mangaIds != null && mangaIds.isNotEmpty)
        ? ', id: { in: [${mangaIds.join(',')}] }'
        : '';
    final chapterMangaIdFilter = (mangaIds != null && mangaIds.isNotEmpty)
        ? ', mangaId: { in: [${mangaIds.join(',')}] }'
        : '';
    final categoryFilter = (categoryIds != null && categoryIds.isNotEmpty)
        ? ', categoryId: { in: [${categoryIds.join(',')}] }'
        : '';

    final mangaQuery = '''
      {
        mangas(
          filter: {
            inLibrary: { equalTo: true }
            or: [
              { lastFetchedAt: { greaterThan: "$sinceSec" } }
              { chaptersLastFetchedAt: { greaterThan: "$sinceSec" } }
            ]
            $mangaIdFilter
            $categoryFilter
          }
          first: 200
        ) {
          nodes {
            id
            title
            author
            artist
            description
            thumbnailUrl
            status
            ${_mangaState()}
            url
            realUrl
            source { displayName name }
            categories { nodes { id } }
          }
        }
      }
    ''';

    final chapterQuery = '''
      {
        chapters(
          filter: {
            inLibrary: { equalTo: true }
            fetchedAt: { greaterThan: "$sinceSec" }
            $chapterMangaIdFilter
          }
          order: [{ by: FETCHED_AT, byType: DESC }]
          first: 500
        ) {
          nodes {
            id
            name
            chapterNumber
            url
            realUrl
            pageCount
            ${_chapterState(const ['isRead', 'isBookmarked', 'lastPageRead', 'lastReadAt', 'isDownloaded'])}
            uploadDate
            fetchedAt
            mangaId
          }
        }
      }
    ''';

    final mangaData = await query(mangaQuery, label: 'fetchDelta.mangas', op: GraphQLOp.read);
    final chapterData =
        await query(chapterQuery, label: 'fetchDelta.chapters', op: GraphQLOp.read);

    if (mangaData == null && chapterData == null) return null;

    final mangaNodes = (mangaData?['mangas'] is Map)
        ? ((mangaData!['mangas'] as Map)['nodes'] as List? ?? const <dynamic>[])
        : const <dynamic>[];
    final chapterNodes = (chapterData?['chapters'] is Map)
        ? ((chapterData!['chapters'] as Map)['nodes'] as List? ??
            const <dynamic>[])
        : const <dynamic>[];

    return {
      'manga': mangaNodes
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList(),
      'chapters': chapterNodes
          .whereType<Map<dynamic, dynamic>>()
          .map((c) => Map<String, dynamic>.from(c))
          .toList(),
      'categories': <Map<String, dynamic>>[],
    };
  }

  /// Fetch specific manga by IDs via `mangas(filter: { id: { in: ... } })`.
  Future<List<Map<String, dynamic>>?> fetchMangaByIds(List<int> mangaIds) async {
    if (mangaIds.isEmpty) return [];
    final ids = mangaIds.where((id) => id > 0).toList();
    if (ids.isEmpty) return [];

    final queryStr = '''
      {
        mangas(filter: { id: { in: [${ids.join(',')}] } }, first: ${ids.length}) {
          nodes {
            id
            title
            author
            artist
            description
            thumbnailUrl
            status
            ${_mangaState()}
            url
            realUrl
            source { displayName name }
            categories { nodes { id } }
          }
        }
      }
    ''';

    final data = await query(queryStr, label: 'fetchMangaByIds', op: GraphQLOp.read);
    if (data == null || data['mangas'] == null) return null;
    final nodes = (data['mangas'] as Map)['nodes'] as List?;
    return nodes
        ?.whereType<Map<dynamic, dynamic>>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Fetch specific categories by IDs via `categories(filter: { id: { in: ... } })`.
  Future<List<Map<String, dynamic>>?> fetchCategoriesByIds(List<int> categoryIds) async {
    if (categoryIds.isEmpty) return [];
    final ids = categoryIds.where((id) => id > 0).toList();
    if (ids.isEmpty) return [];

    final queryStr = '''
      {
        categories(filter: { id: { in: [${ids.join(',')}] } }, first: ${ids.length}) {
          nodes {
            id
            name
            order
            default
            includeInUpdate
            includeInDownload
            isDefaultCategory
          }
        }
      }
    ''';

    final data =
        await query(queryStr, label: 'fetchCategoriesByIds', op: GraphQLOp.read);
    if (data == null || data['categories'] == null) return null;
    final nodes = (data['categories'] as Map)['nodes'] as List?;
    return nodes
        ?.whereType<Map<dynamic, dynamic>>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
}
