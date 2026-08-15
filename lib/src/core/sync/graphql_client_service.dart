import 'dart:convert';
import 'package:dio/dio.dart';
import '../logging/logger_service.dart';

class GraphQLClientService {
  static GraphQLClientService? _instance;
  late Dio _dio;
  String? _baseUrl;

  GraphQLClientService._();

  static GraphQLClientService get instance {
    _instance ??= GraphQLClientService._();
    return _instance!;
  }

  void initialize(String baseUrl) {
    _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/api/graphql',
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 90),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  bool get isConfigured => _baseUrl != null;
  String? get baseUrl => _baseUrl;

  Future<Map<String, dynamic>?> query(String document, {Map<String, dynamic>? variables, String? label}) async {
    if (!isConfigured) throw Exception('GraphQLClientService not configured with server URL');
    try {
      final response = await _dio.post('', data: jsonEncode({
        'query': document,
        'variables': variables ?? {},
      }));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors')) {
          final errorMsg = data['errors'][0]['message'];
          await LoggerService.instance.logError('GraphQL Error [$label]: $errorMsg', category: 'GraphQL');
          throw Exception('GraphQL Error: $errorMsg');
        }
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e, stack) {
      await LoggerService.instance.logError('Dio Exception [$label]: ${e.message}', exception: e, stackTrace: stack, category: 'GraphQL');
      rethrow;
    }
  }

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
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchSources');
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
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchExtensions');
  }

  Future<Map<String, dynamic>?> updateExtension(String pkgName, String action) async {
    const mutStr = r'''
      mutation($pkgName: String!, $action: ExtensionAction!) {
        updateExtension(input: { pkgName: $pkgName, action: $action }) {
          extension {
            pkgName
            isInstalled
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'pkgName': pkgName, 'action': action}, label: 'updateExtension');
  }

  Future<Map<String, dynamic>?> fetchSourceManga(String sourceId, {bool isLatest = false, int page = 1, String? searchQuery}) async {
    final typeStr = isLatest ? 'LATEST' : ((searchQuery != null && searchQuery.trim().isNotEmpty) ? 'SEARCH' : 'POPULAR');
    const mutationStr = r'''
      mutation($source: LongString!, $type: FetchSourceMangaType!, $page: Int!, $query: String) {
        fetchSourceManga(input: {
          source: $source,
          type: $type,
          page: $page,
          query: $query
        }) {
          mangas {
            id
            title
            thumbnailUrl
          }
          hasNextPage
        }
      }
    ''';
    return await query(mutationStr, variables: {
      'source': sourceId,
      'type': typeStr,
      'page': page,
      'query': searchQuery,
    }, label: 'fetchSourceManga');
  }

  Future<Map<String, dynamic>?> fetchLibrary() async {
    const queryStr = '''
      { mangas(condition: { inLibrary: true }, first: 500) {
          totalCount
          nodes {
            id
            title
            thumbnailUrl
            inLibrary
            inLibraryAt
            sourceId
            unreadCount
            url
            realUrl
            source {
              id
              name
              displayName
              iconUrl
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
    return await query(queryStr, label: 'fetchLibrary');
  }

  Future<Map<String, dynamic>?> fetchMangaDetails(int mangaServerId) async {
    const queryStr = r'''
      query($id: Int!) {
        manga(id: $id) {
          id
          title
          artist
          author
          description
          genre
          status
          inLibrary
          thumbnailUrl
          url
          realUrl
          source {
            id
            name
            displayName
          }
          chapters {
            nodes {
              id
              name
              chapterNumber
              url
              realUrl
              isRead
              lastPageRead
              lastReadAt
              pageCount
              fetchedAt
            }
          }
        }
      }
    ''';
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
    return await query(mutStr, variables: {'id': mangaServerId}, label: 'fetchMangaAndChapters');
  }

  Future<Map<String, dynamic>?> fetchCategories() async {
    const queryStr = '''
      {
        categories {
          nodes {
            id
            name
            order
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchCategories');
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

  Future<Map<String, dynamic>?> fetchHistoryChapters(int offset) async {
    final queryStr = '''
      {
        chapters(condition: { isRead: true }, first: 500, offset: $offset) {
          totalCount
          nodes {
            id
            name
            chapterNumber
            isRead
            lastPageRead
            lastReadAt
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
    return await query(queryStr, label: 'fetchHistoryChapters');
  }

  Future<Map<String, dynamic>?> fetchUpdatesChapters({int first = 100}) async {
    final queryStr = '''
      {
        chapters(
          filter: { inLibrary: { equalTo: true } }
          order: [{ by: FETCHED_AT, byType: DESC }]
          first: $first
        ) {
          totalCount
          nodes {
            id
            name
            chapterNumber
            isRead
            lastPageRead
            isDownloaded
            fetchedAt
            mangaId
            manga {
              id
              title
              thumbnailUrl
              inLibrary
              source {
                displayName
              }
            }
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchUpdatesChapters');
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

  Future<Map<String, dynamic>?> triggerServerLibraryUpdate() async {
    const mutStr = r'''
      mutation {
        updateLibrary(input: {}) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, label: 'triggerServerLibraryUpdate');
  }

  Future<Map<String, dynamic>?> enqueueChapterDownload(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        enqueueChapterDownload(input: { id: $chapterId }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'chapterId': chapterId}, label: 'enqueueChapterDownload');
  }

  Future<Map<String, dynamic>?> enqueueChapterDownloads(List<int> chapterIds) async {
    const mutStr = r'''
      mutation($chapterIds: [Int!]!) {
        enqueueChapterDownloads(input: { ids: $chapterIds }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'chapterIds': chapterIds}, label: 'enqueueChapterDownloads');
  }

  Future<Map<String, dynamic>?> deleteDownloadedChapter(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        deleteDownloadedChapter(input: { id: $chapterId }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'chapterId': chapterId}, label: 'deleteDownloadedChapter');
  }

  Future<Map<String, dynamic>?> fetchDownloadStatus() async {
    const queryStr = r'''
      {
        downloadStatus {
          state
          queue {
            progress
            state
            chapter {
              id
              name
              isDownloaded
            }
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchDownloadStatus');
  }

  Future<Map<String, dynamic>?> fetchChapterPages(int chapterId) async {
    const mutStr = r'''
      mutation($chapterId: Int!) {
        fetchChapterPages(input: { chapterId: $chapterId }) {
          pages
        }
      }
    ''';
    return await query(mutStr, variables: {'chapterId': chapterId}, label: 'fetchChapterPages');
  }

  Future<Map<String, dynamic>?> updateChapterReadStatus(int chapterId, bool isRead, int lastPageRead) async {
    const mutStr = r'''
      mutation($id: Int!, $isRead: Boolean, $lastPageRead: Int) {
        updateChapter(input: { id: $id, patch: { isRead: $isRead, lastPageRead: $lastPageRead } }) {
          chapter {
            id
            isRead
            lastPageRead
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'id': chapterId, 'isRead': isRead, 'lastPageRead': lastPageRead}, label: 'updateChapterReadStatus');
  }

  Future<Map<String, dynamic>?> trackProgress(int mangaId, [int trackerId = 1, double chapterNumber = 1.0]) async {
    const mutStr = r'''
      mutation($trackerId: Int!, $mangaId: Int!, $lastChapterRead: Float) {
        trackProgress(input: { trackerId: $trackerId, mangaId: $mangaId, lastChapterRead: $lastChapterRead }) {
          track {
            id
            lastChapterRead
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'trackerId': trackerId, 'mangaId': mangaId, 'lastChapterRead': chapterNumber}, label: 'trackProgress');
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

  Future<Map<String, dynamic>?> bindTrack(int mangaId, int trackerId, dynamic remoteId) async {
    const mutStr = r'''
      mutation($mangaId: Int!, $trackerId: Int!, $remoteId: LongString!) {
        bindTrack(input: { mangaId: $mangaId, trackerId: $trackerId, remoteId: $remoteId }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'mangaId': mangaId, 'trackerId': trackerId, 'remoteId': remoteId.toString()}, label: 'bindTrack');
  }

  Future<Map<String, dynamic>?> unbindTrack(int recordId) async {
    const mutStr = r'''
      mutation($recordId: Int!) {
        unbindTrack(input: { recordId: $recordId, deleteRemoteTrack: false }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'recordId': recordId}, label: 'unbindTrack');
  }

  Future<Map<String, dynamic>?> updateTrack({
    required int recordId,
    required double lastChapterRead,
    int? status,
    String? scoreString,
    String? startDate,
    String? finishDate,
  }) async {
    const mutStr = r'''
      mutation($recordId: Int!, $lastChapterRead: Float, $status: Int, $scoreString: String, $startDate: LongString, $finishDate: LongString) {
        updateTrack(input: {
          recordId: $recordId,
          lastChapterRead: $lastChapterRead,
          status: $status,
          scoreString: $scoreString,
          startDate: $startDate,
          finishDate: $finishDate
        }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {
      'recordId': recordId,
      'lastChapterRead': lastChapterRead,
      'status': status,
      'scoreString': scoreString,
      'startDate': startDate,
      'finishDate': finishDate,
    }, label: 'updateTrack');
  }

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
    const mutStr = r'''
      mutation($id: Int!, $isBookmarked: Boolean) {
        updateChapter(input: { id: $id, patch: { isBookmarked: $isBookmarked } }) {
          chapter {
            id
            isBookmarked
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'id': chapterId, 'isBookmarked': isBookmarked}, label: 'updateChapterBookmark');
  }

  Future<Map<String, dynamic>?> updateMangaLibraryState(int mangaId, bool inLibrary) async {
    const mutStr = r'''
      mutation($id: Int!, $inLibrary: Boolean) {
        updateManga(input: { id: $id, patch: { inLibrary: $inLibrary } }) {
          manga {
            id
            inLibrary
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'id': mangaId, 'inLibrary': inLibrary}, label: 'updateMangaLibraryState');
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
    return await query(mutStr, variables: {'name': name}, label: 'createCategory');
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
    return await query(mutStr, variables: {'id': categoryId, 'name': newName}, label: 'updateCategoryName');
  }

  Future<Map<String, dynamic>?> updateCategoryOrder(int categoryId, int position) async {
    const mutStr = r'''
      mutation($id: Int!, $position: Int!) {
        updateCategoryOrder(input: { id: $id, position: $position }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'id': categoryId, 'position': position}, label: 'updateCategoryOrder');
  }

  Future<Map<String, dynamic>?> startDownloader() async {
    const mutStr = r'''
      mutation {
        startDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, label: 'startDownloader');
  }

  Future<Map<String, dynamic>?> stopDownloader() async {
    const mutStr = r'''
      mutation {
        stopDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, label: 'stopDownloader');
  }

  Future<Map<String, dynamic>?> clearDownloader() async {
    const mutStr = r'''
      mutation {
        clearDownloader(input: {}) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, label: 'clearDownloader');
  }

  Future<Map<String, dynamic>?> deleteCategory(int categoryId) async {
    const mutStr = r'''
      mutation($categoryId: Int!) {
        deleteCategory(input: { categoryId: $categoryId }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'categoryId': categoryId}, label: 'deleteCategory');
  }

  Future<Map<String, dynamic>?> setMangaCategories(int mangaId, List<int> categoryIds) async {
    const mutStr = r'''
      mutation($id: Int!, $categories: [Int!]!) {
        updateMangaCategories(input: { id: $id, patch: { categories: $categories } }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {'id': mangaId, 'categories': categoryIds}, label: 'setMangaCategories');
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
}
