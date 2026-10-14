part of 'graphql_client_service.dart';

// IMP-034: moved verbatim from graphql_client_service.dart.
mixin _GraphQLChaptersTrackingApi on _GraphQLClientCore {
  @override
  Future<Map<String, dynamic>?> fetchChapterPages(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        fetchChapterPages(input: { chapterId: $chapterId }) {
          pages
        }
      }
    ''';
    return await query(mutStr, variables: {'chapterId': chapterId}, label: 'fetchChapterPages', op: GraphQLOp.scrapeRead);
  }

  /// Public version of [updateChapterReadStatus] that returns the transport
  /// failure classification atomically captured from the final attempt.
  /// Use this instead of [updateChapterReadStatus] when the caller needs to
  /// distinguish transport failures from GraphQL rejections for retry logic.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      updateChapterReadStatusWithClassification(
    int chapterId,
    bool isRead,
    int lastPageRead,
  ) async {
    final mutStr = r'''
      mutation($id: Int!, $isRead: Boolean, $lastPageRead: Int) {
        updateChapter(input: { id: $id, patch: { isRead: $isRead, lastPageRead: $lastPageRead } }) {
          chapter {            id            #STATE#          }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isRead', 'lastPageRead']));
    return _queryAndClassify(
      mutStr,
      variables: {'id': chapterId, 'isRead': isRead, 'lastPageRead': lastPageRead},
      label: 'updateChapterReadStatus',
    );
  }

  /// ISS-142: the server's current read state for one chapter (flattened
  /// from `user {}` on multi-user servers). Null when unreachable.
  Future<({bool isRead, int lastPageRead})?> fetchChapterReadState(int chapterId) async {
    if (chapterId <= 0) return null;
    final q = r'''
      query($id: Int!) {
        chapter(id: $id) { id #STATE# }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isRead', 'lastPageRead']));
    final res = await query(q, variables: {'id': chapterId}, label: 'fetchChapterReadState', op: GraphQLOp.read);
    final raw = res?['chapter'];
    if (raw is! Map) return null;
    final node = flattenChapterUserFields(Map<String, dynamic>.from(raw));
    return (isRead: node['isRead'] == true, lastPageRead: (node['lastPageRead'] as num?)?.toInt() ?? 0);
  }

  /// Public version of [updateChapterBookmark] with transport classification.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      updateChapterBookmarkWithClassification(
    int chapterId,
    bool isBookmarked,
  ) async {
    final mutStr = r'''
      mutation($id: Int!, $isBookmarked: Boolean) {
        updateChapter(input: { id: $id, patch: { isBookmarked: $isBookmarked } }) {
          chapter {            id            #STATE#          }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isBookmarked']));
    return _queryAndClassify(
      mutStr,
      variables: {'id': chapterId, 'isBookmarked': isBookmarked},
      label: 'updateChapterBookmark',
    );
  }

  /// Public version of [createCategory] with transport classification.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      createCategoryWithClassification(String name) async {
    const mutStr = r'''
      mutation($name: String!) {
        createCategory(input: { name: $name }) {
          category {
            id
            name
            order
          }
        }
      }
    ''';
    return _queryAndClassify(
      mutStr,
      variables: {'name': name},
      label: 'createCategory',
    );
  }

  /// Public version of [updateCategoryName] with transport classification.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      updateCategoryNameWithClassification(int categoryId, String newName) async {
    const mutStr = r'''
      mutation($id: Int!, $name: String!) {
        updateCategory(input: { id: $id, patch: { name: $name } }) {
          category {
            id
            name
          }
        }
      }
    ''';
    return _queryAndClassify(
      mutStr,
      variables: {'id': categoryId, 'name': newName},
      label: 'updateCategoryName',
    );
  }

  /// Public version of [setMangaCategories] with transport classification.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      setMangaCategoriesWithClassification(
    int mangaId,
    List<int> categoryIds, {
    List<int>? existingCategoryIds,
  }) async {
    if (existingCategoryIds != null) {
      final toAdd = categoryIds.where((c) => !existingCategoryIds.contains(c)).toList();
      final toRemove = existingCategoryIds.where((c) => !categoryIds.contains(c)).toList();
      if (toAdd.isNotEmpty || toRemove.isNotEmpty) {
        const patchMut = r'''
          mutation($id: Int!, $add: [Int!]!, $remove: [Int!]!) {
            updateMangaCategories(input: { id: $id, patch: { addToCategories: $add, removeFromCategories: $remove } }) {
              clientMutationId
            }
          }
        ''';
        final res = await _queryAndClassify(
          patchMut,
          variables: {'id': mangaId, 'add': toAdd, 'remove': toRemove},
          label: 'updateMangaCategories',
        );
        if (res.data != null) return res;
      }
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
    return _queryAndClassify(
      mutStr,
      variables: {'id': mangaId, 'categories': categoryIds},
      label: 'setMangaCategories',
    );
  }

  Future<Map<String, dynamic>?> updateChapterReadStatus(int chapterId, bool isRead, int lastPageRead) async {
    final mutStr = r'''
      mutation($id: Int!, $isRead: Boolean, $lastPageRead: Int) {
        updateChapter(input: { id: $id, patch: { isRead: $isRead, lastPageRead: $lastPageRead } }) {
          chapter {            id            #STATE#          }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isRead', 'lastPageRead']));
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': chapterId, 'isRead': isRead, 'lastPageRead': lastPageRead},
      label: 'updateChapterReadStatus',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> trackProgress(int mangaId) async {
    return await query(
      kTrackProgressMutation,
      variables: {'mangaId': mangaId},
      label: 'trackProgress',
    );
  }

  Future<Map<String, dynamic>?> fetchTrackRecords(int mangaId) async {
    const queryStr = r'''
      query($mangaId: Int!) {
        trackRecords(condition: { mangaId: $mangaId }) {
          nodes {
            id
            mangaId
            trackerId
            remoteId
            remoteUrl
            title
            status
            lastChapterRead
            totalChapters
            score
            startDate
            finishDate
          }
        }
      }
    ''';
    return await query(queryStr, variables: {'mangaId': mangaId}, label: 'fetchTrackRecords');
  }

  Future<Map<String, dynamic>?> searchTracker(int trackerId, String queryStr) async {
    const query = r'''
      query($trackerId: Int!, $query: String!) {
        searchTracker(input: { trackerId: $trackerId, query: $query }) {
          trackSearches {
            id
            title
            totalChapters
            score
            coverUrl
            trackingUrl
            summary
            remoteId
          }
        }
      }
    ''';
    return await this.query(query, variables: {'trackerId': trackerId, 'query': queryStr}, label: 'searchTracker');
  }

  Future<Map<String, dynamic>> bindTrack(int mangaId, int trackerId, dynamic remoteId, {bool? isPrivate}) async {
    // IMP-002: local-only series (negative ids) have no server row to track.
    if (mangaId <= 0) throw const ServerMutationException('bindTrack');
    final privVar = isPrivate == null ? '' : r', $private: Boolean';
    final privArg = isPrivate == null ? '' : r', private: $private';
    final mutStr = '''
      mutation(\$mangaId: Int!, \$trackerId: Int!, \$remoteId: LongString!$privVar) {
        bindTrack(input: { mangaId: \$mangaId, trackerId: \$trackerId, remoteId: \$remoteId$privArg }) {
          clientMutationId
        }
      }
    ''';
    return _mutateOrThrow(mutStr, variables: {
      'mangaId': mangaId,
      'trackerId': trackerId,
      'remoteId': remoteId.toString(),
      if (isPrivate != null) 'private': isPrivate,
    }, label: 'bindTrack');
  }

  Future<Map<String, dynamic>> unbindTrack(int recordId) async {
    const mutStr = r'''
      mutation($recordId: Int!) {
        unbindTrack(input: { recordId: $recordId, deleteRemoteTrack: false }) {
          clientMutationId
        }
      }
    ''';
    return _mutateOrThrow(mutStr, variables: {'recordId': recordId}, label: 'unbindTrack');
  }

  Future<Map<String, dynamic>> updateTrack({
    required int recordId,
    required double lastChapterRead,
    int? status,
    String? scoreString,
    String? startDate,
    String? finishDate,
    bool? isPrivate,
  }) async {
    // `private` (ISS-083) is only named when set, so servers predating
    // private tracking still accept the mutation.
    final privVar = isPrivate == null ? '' : r', $private: Boolean';
    final privArg = isPrivate == null ? '' : r', private: $private';
    final mutStr = '''
      mutation(\$recordId: Int!, \$lastChapterRead: Float, \$status: Int, \$scoreString: String, \$startDate: LongString, \$finishDate: LongString$privVar) {
        updateTrack(input: {
          recordId: \$recordId,
          lastChapterRead: \$lastChapterRead,
          status: \$status,
          scoreString: \$scoreString,
          startDate: \$startDate,
          finishDate: \$finishDate$privArg
        }) {
          clientMutationId
        }
      }
    ''';
    return _mutateOrThrow(mutStr, variables: {
      'recordId': recordId,
      'lastChapterRead': lastChapterRead,
      'status': status,
      'scoreString': scoreString,
      'startDate': startDate,
      'finishDate': finishDate,
      if (isPrivate != null) 'private': isPrivate,
    }, label: 'updateTrack');
  }

  /// Runs a mutation and throws [ServerMutationException] when the server did
  /// not return data (H1: never report a failed write as success).
  Future<Map<String, dynamic>> _mutateOrThrow(
    String document, {
    Map<String, dynamic>? variables,
    required String label,
  }) async {
    if (!isConfigured) throw ServerMutationException(label);
    final r = await _queryAndClassify(document, variables: variables, label: label);
    final data = r.data;
    if (data == null) {
      throw ServerMutationException(label, isTransportFailure: r.wasTransportFailure);
    }
    return data;
  }

  /// Throwing variant of [updateMangaLibraryState].
  /// Throws [ServerMutationException] if the server did not apply it.
  Future<void> setMangaInLibraryOrThrow(int mangaId, bool inLibrary) async {
    final data = await _mutateOrThrow(r'''
      mutation($id: Int!, $inLibrary: Boolean) {
        updateManga(input: { id: $id, patch: { inLibrary: $inLibrary } }) {
          manga { id #STATE# }
        }
      }
    '''.replaceFirst('#STATE#', _mangaState(const ['inLibrary'])), variables: {'id': mangaId, 'inLibrary': inLibrary}, label: 'updateMangaLibraryState');
    final m = data['updateManga'];
    final applied = m is Map ? (m['manga'] is Map ? m['manga']['inLibrary'] : null) : null;
    if (applied is bool && applied != inLibrary) {
      throw const ServerMutationException('updateMangaLibraryState');
    }
  }

  /// Throwing variant of [updateMangaCategories] (adds to [categoryIds]).
  Future<void> addMangaToCategoriesOrThrow(int mangaId, List<int> categoryIds) async {
    await _mutateOrThrow(r'''
      mutation($id: Int!, $categoryIds: [Int!]!) {
        updateMangaCategories(input: { id: $id, patch: { addToCategories: $categoryIds } }) {
          clientMutationId
        }
      }
    ''', variables: {'id': mangaId, 'categoryIds': categoryIds}, label: 'updateMangaCategories');
  }

  /// Adds a manga to the server library (and optional categories) atomically
  /// from the caller's point of view: if the category step fails, the
  /// inLibrary change is reverted best-effort and the error is rethrown.
  /// Throws [ServerMutationException]; on throw, callers must NOT write the
  /// local library state.
  Future<void> addMangaToLibraryOrThrow(int mangaId, {List<int> categoryIds = const []}) async {
    await setMangaInLibraryOrThrow(mangaId, true);
    if (categoryIds.isEmpty) return;
    try {
      await addMangaToCategoriesOrThrow(mangaId, categoryIds);
    } on ServerMutationException {
      try {
        await setMangaInLibraryOrThrow(mangaId, false);
      } on ServerMutationException catch (e) {
        // Best-effort revert only: the category error below is what the
        // caller must see, so a failed revert is logged, not rethrown.
        debugPrint('[graphql_client_service] add-to-library revert failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> updateMangaCategories(int mangaId, List<int> categoryIds) async {
    const mutStr = r'''
      mutation($id: Int!, $categoryIds: [Int!]!) {
        updateMangaCategories(input: { id: $id, patch: { addToCategories: $categoryIds } }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'id': mangaId, 'categoryIds': categoryIds}, label: 'updateMangaCategories');
  }

  Future<Map<String, dynamic>?> updateChapterBookmark(int chapterId, bool isBookmarked) async {
    final mutStr = r'''
      mutation($id: Int!, $isBookmarked: Boolean) {
        updateChapter(input: { id: $id, patch: { isBookmarked: $isBookmarked } }) {
          chapter {            id            #STATE#          }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isBookmarked']));
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': chapterId, 'isBookmarked': isBookmarked},
      label: 'updateChapterBookmark',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> updateMangaLibraryState(int mangaId, bool inLibrary) async {
    final mutStr = r'''
      mutation($id: Int!, $inLibrary: Boolean) {
        updateManga(input: { id: $id, patch: { inLibrary: $inLibrary } }) {
          manga {            id            #STATE#          }
        }
      }
    '''.replaceFirst('#STATE#', _mangaState(const ['inLibrary']));
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': mangaId, 'inLibrary': inLibrary},
      label: 'updateMangaLibraryState',
    )).data;
  }

  Future<Map<String, dynamic>?> createCategory(String name) async {
    const mutStr = r'''
      mutation($name: String!) {
        createCategory(input: { name: $name }) {
          category {
            id
            name
            order
          }
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'name': name},
      label: 'createCategory',
    )).data;
  }

  Future<Map<String, dynamic>?> updateCategoryName(int categoryId, String newName) async {
    const mutStr = r'''
      mutation($id: Int!, $name: String!) {
        updateCategory(input: { id: $id, patch: { name: $name } }) {
          category {
            id
            name
          }
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': categoryId, 'name': newName},
      label: 'updateCategoryName',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> updateCategoryOrder(int categoryId, int position) async {
    const mutStr = r'''
      mutation($id: Int!, $position: Int!) {
        updateCategoryOrder(input: { id: $id, position: $position }) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': categoryId, 'position': position},
      label: 'updateCategoryOrder',
    )).data;
  }


  /// Bulk `updateChapters` (ISS-069). Falls back to per-id `updateChapter*`
  /// when [ids] has a single element or the bulk mutation fails.
  Future<Map<String, dynamic>?> updateChapters(
    List<int> ids, {
    bool? isRead,
    bool? isBookmarked,
    int? lastPageRead,
  }) async {
    if (ids.isEmpty) return {'chapters': <dynamic>[]};
    final patch = <String, dynamic>{};
    if (isRead != null) patch['isRead'] = isRead;
    if (isBookmarked != null) patch['isBookmarked'] = isBookmarked;
    if (lastPageRead != null) patch['lastPageRead'] = lastPageRead;
    if (patch.isEmpty) return null;

    if (ids.length == 1) {
      final id = ids.first;
      if (isBookmarked != null && isRead == null && lastPageRead == null) {
        return updateChapterBookmark(id, isBookmarked);
      }
      if (isRead != null || lastPageRead != null) {
        return updateChapterReadStatus(id, isRead ?? false, lastPageRead ?? 0);
      }
    }

    final mutStr = r'''
      mutation($ids: [Int!]!, $patch: UpdateChapterPatchInput!) {
        updateChapters(input: { ids: $ids, patch: $patch }) {
          chapters { id #STATE# }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isRead', 'isBookmarked', 'lastPageRead']));
    return (await _queryAndClassify(
      mutStr,
      variables: {'ids': ids, 'patch': patch},
      label: 'updateChapters',
    )).data;
  }

  /// Bulk delete downloaded chapters (ISS-069). Per-id fallback on failure.
  @override
  Future<Map<String, dynamic>?> deleteDownloadedChapters(List<int> ids) async {
    if (ids.isEmpty) return {'chapters': <dynamic>[]};
    if (ids.length == 1) {
      return deleteDownloadedChapter(ids.first);
    }
    final mutStr = r'''
      mutation($ids: [Int!]!) {
        deleteDownloadedChapters(input: { ids: $ids }) {
          chapters { id #STATE# }
        }
      }
    '''.replaceFirst('#STATE#', _chapterState(const ['isDownloaded']));
    return (await _queryAndClassify(
      mutStr,
      variables: {'ids': ids},
      label: 'deleteDownloadedChapters',
    )).data;
  }

  /// Mark many chapters read in one round-trip (UIS mark-previous-read).
  Future<bool> markChaptersRead(List<int> ids, {int lastPageRead = 0}) async {
    final res = await updateChapters(ids, isRead: true, lastPageRead: lastPageRead);
    return res != null;
  }

  /// Delete all given downloaded chapter ids (UIS delete-all downloads).
  Future<bool> deleteAllDownloadedChapters(List<int> ids) async {
    final res = await deleteDownloadedChapters(ids);
    return res != null;
  }

  /// Patch category include flags / name (ISS-071). [includeInUpdate] /
  /// [includeInDownload] are INCLUDE | EXCLUDE | UNSET.
  Future<Map<String, dynamic>?> updateCategoryPatch(
    int categoryId, {
    String? name,
    String? includeInUpdate,
    String? includeInDownload,
    bool? isDefault,
  }) async {
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name;
    if (includeInUpdate != null) {
      patch['includeInUpdate'] = parseIncludeOrExclude(includeInUpdate);
    }
    if (includeInDownload != null) {
      patch['includeInDownload'] = parseIncludeOrExclude(includeInDownload);
    }
    if (isDefault != null) patch['default'] = isDefault;
    if (patch.isEmpty) return null;
    const mutStr = r'''
      mutation($id: Int!, $patch: UpdateCategoryPatchInput!) {
        updateCategory(input: { id: $id, patch: $patch }) {
          category {
            id
            name
            default
            includeInUpdate
            includeInDownload
          }
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      variables: {'id': categoryId, 'patch': patch},
      label: 'updateCategoryPatch',
    )).data;
  }

  Future<Map<String, dynamic>?> setCategoryIncludeInUpdate(
    int categoryId,
    String value,
  ) =>
      updateCategoryPatch(categoryId, includeInUpdate: value);

  Future<Map<String, dynamic>?> setCategoryIncludeInDownload(
    int categoryId,
    String value,
  ) =>
      updateCategoryPatch(categoryId, includeInDownload: value);

  /// "Update this category" — thin alias for [triggerServerLibraryUpdate].
  Future<Map<String, dynamic>?> updateLibraryForCategories(List<int> categoryIds) =>
      triggerServerLibraryUpdate(categoryIds: categoryIds);

  @override
  Future<Map<String, dynamic>?> startDownloader() async {
    const mutStr = r'''
      mutation {
        startDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      label: 'startDownloader',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> stopDownloader() async {
    const mutStr = r'''
      mutation {
        stopDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      label: 'stopDownloader',
    )).data;
  }

  @override
  Future<Map<String, dynamic>?> clearDownloader() async {
    const mutStr = r'''
      mutation {
        clearDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return (await _queryAndClassify(
      mutStr,
      label: 'clearDownloader',
    )).data;
  }

  // ── IMP-030: typed results ─────────────────────────────────────────────
  // Each *Result method wraps the legacy nullable-map call and classifies a
  // null as transport (retry) vs rejected (server said no) vs notConfigured.
  // The flag is read with no await after the call, like _queryAndClassify.
}
