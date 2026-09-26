import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint, kDebugMode;
import '../logging/logger_service.dart';
import '../services/server_tls_trust.dart';

int parseIntSafe(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double parseDoubleSafe(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool parseBoolSafe(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return fallback;
}

bool chapterMutationNeedsBookmark(Map<String, dynamic> payload) =>
    payload.containsKey('isBookmarked');

bool chapterMutationNeedsReadProgress(Map<String, dynamic> payload) =>
    payload.containsKey('isRead') || payload.containsKey('lastPageRead');

/// Suwayomi `TrackProgressInput` is only `mangaId`. The server copies local
/// chapter-read state onto every bound MAL/AniList/etc. record. Score, status,
/// and dates go through [GraphQLClientService.updateTrack] (`UpdateTrackInput`).
const String kTrackProgressMutation = r'''
      mutation($mangaId: Int!) {
        trackProgress(input: { mangaId: $mangaId }) {
          trackRecords {
            id
            trackerId
            lastChapterRead
          }
        }
      }
    ''';

/// Sentinel key marking a paginated response as a COMPLETE server snapshot.
///
/// The guard philosophy in this codebase is strong at the network boundary —
/// reachability is separated from authentication, a 401 is never treated as a
/// transport drop — and absent at the completeness boundary. Every destructive
/// sync operation is driven by "whatever the server returned this cycle", and
/// nothing distinguished a complete response from a partial one.
///
/// That made one timed-out page indistinguishable from a mass deletion.
/// `fetchLibrary` returns 400 of 500 manga when page 3 fails; the caller's
/// ratio guard compares that against the local count, and because 400 still
/// clears the floor, the missing 100 get soft-removed from the user's library.
/// The same shape hard-deleted chapter rows along with their read state.
///
/// Every paginated fetcher stamps this key, and every destructive caller must
/// consult [isCompleteSnapshot] before removing anything.
const String kSnapshotCompleteKey = '__complete';

/// Whether [data] is a paginated response that reached a genuine end.
///
/// Defaults to false for an unmarked map, so a new paginated fetcher that
/// forgets to stamp this fails safe — keeping local data — rather than open.
bool isCompleteSnapshot(Map<String, dynamic>? data) => data?[kSnapshotCompleteKey] == true;

class GraphQLClientService {
  static GraphQLClientService? _instance;
  late Dio _dio;

  /// Whether [_dio] has been assigned yet. `late` fields throw on first read,
  /// so this distinguishes "no client yet" from "client failed to close".
  bool _dioInitialized = false;
  String? _baseUrl;

  GraphQLClientService._();

  static GraphQLClientService get instance {
    _instance ??= GraphQLClientService._();
    return _instance!;
  }

  String? _authToken;

  /// Set to true when the server answers 401/403 (bad or expired token). Cleared
  /// on a successful authenticated request or when the user reconnects. UI layers
  /// listen to this to offer a "Reconnect to server" surface.
  final ValueNotifier<bool> authErrorNotifier = ValueNotifier(false);

  bool get hasAuthError => authErrorNotifier.value;

  void notifyAuthError() => authErrorNotifier.value = true;

  void clearAuthError() => authErrorNotifier.value = false;

  Map<String, String> get authHeaders {
    if (_authToken != null && _authToken!.trim().isNotEmpty) {
      final token = _authToken!.trim();
      if (token.startsWith('Basic ') || token.startsWith('Bearer ')) {
        return {'Authorization': token};
      } else {
        return {'Authorization': 'Bearer $token'};
      }
    }
    return const {};
  }

  void initialize(String baseUrl, {String? authToken}) {
    final clean = baseUrl.trim();
    if (clean.isEmpty) {
      _baseUrl = null;
      _authToken = null;
      _lastReachableCheck = null;
      _lastReachableStatus = false;
      clearAuthError();
      return;
    }
    _baseUrl = clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
    _authToken = authToken;
    _lastReachableCheck = null;
    _lastReachableStatus = false;
    clearAuthError();
    final headers = <String, dynamic>{'Content-Type': 'application/json'};
    if (authToken != null && authToken.trim().isNotEmpty) {
      final token = authToken.trim();
      if (token.startsWith('Basic ') || token.startsWith('Bearer ')) {
        headers['Authorization'] = token;
      } else {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    // Close the previous client, if there is one. Guarded rather than left to a
    // try/catch: `_dio` is `late`, so on the very first initialize() it throws
    // LateInitializationError, and swallowing that printed a confusing
    // "ignored error: LateInitializationError" on startup — inside the
    // connect/reconnect path, which is exactly where someone is reading logs
    // because something is already going wrong.
    if (_dioInitialized) {
      try {
        _dio.close(force: true);
      } catch (ignoredError) { if (kDebugMode) debugPrint('[graphql_client_service] ignored error: $ignoredError'); }
    }
    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/api/graphql',
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 90),
      headers: headers,
    ));
    _dioInitialized = true;
    // Accept a self-signed cert for the configured server only (same rule as
    // image loading and downloads) — without this, HTTPS servers with a
    // private cert work for images/downloads but every sync request fails.
    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () => createServerTrustingHttpClient(() => _baseUrl);
    }
  }

  bool get isConfigured => _baseUrl != null && _baseUrl!.trim().isNotEmpty;
  String? get baseUrl => _baseUrl;

  DateTime? _lastReachableCheck;
  bool _lastReachableStatus = false;

  /// True when the most recent request or probe failed at the transport level
  /// (timeout, dropped connection, 5xx, DNS) and left the server marked
  /// unreachable. [query] swallows every failure and returns null, so callers
  /// use this after a null result to tell "the network dropped" apart from
  /// "the server understood and rejected the request" (GraphQL/4xx errors
  /// leave the status reachable). False before any request has been made.
  ///
  /// A 401/403 is emphatically NOT one of those: the server answered, which is
  /// the strongest possible proof the transport path works. See
  /// [_isServerUsable] for the separate question this getter deliberately does
  /// not answer.
  bool get isKnownUnreachable => _lastReachableCheck != null && !_lastReachableStatus;

  /// Whether the server is worth sending real work to right now.
  ///
  /// Two independent conditions, deliberately not collapsed into a single flag:
  /// the transport path has to work, *and* our credentials have to be accepted.
  ///
  /// This is the getter the ~12 sync call sites should gate on, NOT
  /// [isKnownUnreachable]. Collapsing the two (which is what the 401/403 branch
  /// of [checkServerReachable] used to do) made `isKnownUnreachable` lie, and
  /// lied in the direction that cost the most:
  ///
  ///  - A 401 marked the reachability cache "unreachable", so for the next 15s
  ///    [query] took its fast-fail branch and returned null *without sending
  ///    anything*. Since `clearAuthError()` lives past that branch, the auth
  ///    error could never clear itself: a 15s request blackout that a successful
  ///    re-auth could not end. Recovering required `initialize()`.
  ///  - Callers using `isKnownUnreachable` to classify a failure could no longer
  ///    distinguish a dropped connection from a server that understood us and
  ///    said no — the exact distinction the getter exists to make.
  bool get _isServerUsable => _lastReachableStatus && !authErrorNotifier.value;

  Future<bool> checkServerReachable({bool force = false}) async {
    if (!isConfigured) return false;
    final now = DateTime.now();
    if (!force && _lastReachableCheck != null && now.difference(_lastReachableCheck!) < const Duration(seconds: 8)) {
      return _isServerUsable;
    }
    try {
      final res = await _dio.post(
        '',
        data: jsonEncode({'query': '{ aboutServer { version } }'}),
        options: Options(
          sendTimeout: const Duration(milliseconds: 3000),
          receiveTimeout: const Duration(milliseconds: 3000),
        ),
      );
      // Only reached for 2xx under Dio's default `validateStatus`; a 401/403
      // arrives as a thrown DioException instead. Kept so the handling stays
      // correct if a permissive validateStatus is ever configured.
      if (res.statusCode == 401 || res.statusCode == 403) {
        _recordAuthRejection();
      } else {
        _lastReachableStatus = (res.statusCode == 200);
      }
    } on DioException catch (e) {
      // This is where a 401/403 actually lands: Dio throws
      // DioExceptionType.badResponse for any non-2xx, so the status check above
      // never saw one. The old code had a bare `catch (_)` here that lumped a
      // credential rejection in with connection refused, which cost two things:
      //
      //  - The "Server rejected your login (401/403). Reconnect" prompt was
      //    never raised by a probe, because notifyAuthError() lived in a branch
      //    that could not execute. On a cold start with a dead token the app
      //    stayed silent until some unrelated request happened to 401.
      //  - Reachability was poisoned, and because this probe and query()'s
      //    fast-fail share the same flag, every request for the next 15s
      //    returned null WITHOUT being sent — including the one that would have
      //    proven fixed credentials work. clearAuthError() sits past that
      //    fast-fail, so the state could not self-heal; only initialize() broke
      //    the jam.
      //
      // A server that answers 401/403 did answer, so the transport path is
      // proven good and has to be recorded as reachable.
      final code = e.response?.statusCode ?? 0;
      if (code == 401 || code == 403) {
        _recordAuthRejection();
      } else {
        _lastReachableStatus = false;
      }
    } catch (_) {
      _lastReachableStatus = false;
    }
    _lastReachableCheck = now;
    return _isServerUsable;
  }

  /// A probe came back 401/403: the transport works, the credentials do not.
  ///
  /// Records the server as REACHABLE (it answered) and raises the auth error.
  /// [_isServerUsable] is what reports it as unusable for sync.
  void _recordAuthRejection() {
    _lastReachableStatus = true;
    notifyAuthError();
  }

  Future<Map<String, dynamic>?> query(String document, {Map<String, dynamic>? variables, String? label}) async {
    if (!isConfigured) return null;

    // Fast-fail if the transport path was recently proven broken. This tracks
    // reachability ONLY, never auth: a 401 leaves the status reachable, so
    // credentials going bad still lets requests through and report their real
    // 401 instead of being masked as a silent null. (It used to be reachable in
    // the other direction, where a 401 latched here and blackholed every
    // request for 15s without sending any of them.)
    final now = DateTime.now();
    if (!_lastReachableStatus && _lastReachableCheck != null && now.difference(_lastReachableCheck!) < const Duration(seconds: 15)) {
      return null;
    }

    try {
      final response = await _dio.post(
        '',
        data: jsonEncode({
          'query': document,
          'variables': variables ?? {},
        }),
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      _lastReachableStatus = true;
      _lastReachableCheck = DateTime.now();
      // A successful authenticated response means credentials are valid again.
      clearAuthError();

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is Map<String, dynamic>) {
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          final errorMsg = (errors is List && errors.isNotEmpty && errors[0] is Map)
              ? errors[0]['message']
              : errors.toString();
          await LoggerService.instance.logWarning('GraphQL Error [$label]: $errorMsg', 'GraphQL');
          // A GraphQL-level auth/credentials error (server replies HTTP 200
          // with an `errors` payload) must surface the reconnect prompt just
          // like an HTTP 401/403 does. Without this, bad credentials silently
          // null-out every mutation while the UI claims the server is fine.
          if (_looksLikeAuthError(errorMsg)) {
            notifyAuthError();
          }
          return null;
        }
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      if (_isTransportFailure(e)) {
        _lastReachableStatus = false;
        _lastReachableCheck = DateTime.now();
      }
      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          notifyAuthError();
        }
      }
      // Suppress spammy connection refused errors during offline operation
      if (e.message != null && !e.message!.contains('Connection refused')) {
        await LoggerService.instance.logWarning('GraphQL request failed [$label]: ${e.message}', 'GraphQL');
      }
      return null;
    } catch (e, stack) {
      // The server ANSWERED — we are inside the success path of the HTTP
      // exchange, and reachability was already set true a few lines above.
      // Reaching this catch means the *body* was unusable: a proxy HTML error
      // page served with a 200, a non-JSON payload, or a `data` value of an
      // unexpected shape (our own `as Map<String, dynamic>?` cast can throw).
      //
      // Marking the server unreachable here was the mirror image of the 401
      // problem this file is otherwise careful about: a parse failure is not a
      // transport failure. It blackholed a perfectly reachable server for the
      // full 15s window, and — unlike the DioException branch above — logged
      // absolutely nothing, so it was completely undiagnosable.
      await LoggerService.instance.logError(
        'GraphQL response for [$label] was unparseable: $e',
        exception: e,
        stackTrace: stack,
        category: 'GraphQL',
      );
      return null;
    }
  }

  /// 4xx GraphQL validation errors mean the server is up; only transport
  /// failures should poison the reachability cache.
  static bool _isTransportFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return code == 0 || code >= 500;
      default:
        return e.response == null;
    }
  }

  /// Heuristic for Suwayomi/GraphQL-Java auth rejection messages that arrive
  /// inside an HTTP-200 `errors` payload (e.g. "Authentication required",
  /// "Invalid credentials", "Forbidden", "Not authorized").
  static bool _looksLikeAuthError(String message) {
    final m = message.toLowerCase();
    return m.contains('authenticat') ||
        m.contains('credential') ||
        m.contains('forbidden') ||
        m.contains('not authorized') ||
        m.contains('unauthoriz') ||
        m.contains('access denied') ||
        m.contains('invalid token') ||
        m.contains('bearer token');
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
            isNsfw
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

  Future<Map<String, dynamic>?> fetchSourceManga(String sourceId, {bool isLatest = false, int page = 1, String? searchQuery}) async {
    final isSearch = searchQuery != null && searchQuery.trim().isNotEmpty;
    final typeStr = isLatest ? 'LATEST' : (isSearch ? 'SEARCH' : 'POPULAR');

    if (isSearch) {
      const searchMutation = r'''
        mutation($source: LongString!, $page: Int!, $query: String!) {
          fetchSourceManga(input: {
            source: $source,
            type: SEARCH,
            page: $page,
            query: $query
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
      return await query(searchMutation, variables: {
        'source': sourceId,
        'page': page,
        'query': searchQuery.trim(),
      }, label: 'fetchSourceManga');
    } else {
      const browseMutation = r'''
        mutation($source: LongString!, $type: FetchSourceMangaType!, $page: Int!) {
          fetchSourceManga(input: {
            source: $source,
            type: $type,
            page: $page
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
      return await query(browseMutation, variables: {
        'source': sourceId,
        'type': typeStr,
        'page': page,
      }, label: 'fetchSourceManga');
    }
  }

  Future<Map<String, dynamic>?> fetchLibrary() async {
    const pageQuery = r'''
      query($first: Int!, $offset: Int!) {
        mangas(condition: { inLibrary: true }, first: $first, offset: $offset) {
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
    int offset = 0;
    int? totalCount;
    final List<dynamic> allNodes = [];
    // Whether pagination ran to a genuine end. A page failing after the first
    // is NOT a short library — it is a transport failure, and the caller must
    // not treat the pages it did get as the complete server state.
    var complete = false;

    while (true) {
      final res = await query(pageQuery, variables: {'first': pageSize, 'offset': offset}, label: 'fetchLibrary');
      if (res == null || !res.containsKey('mangas')) {
        if (allNodes.isNotEmpty) {
          await LoggerService.instance.logWarning(
            'fetchLibrary: page at offset $offset failed after ${allNodes.length} nodes; '
            'reporting an INCOMPLETE snapshot',
            'GraphQL',
          );
          return {
            'mangas': {
              'totalCount': totalCount ?? allNodes.length,
              'nodes': allNodes,
            },
            kSnapshotCompleteKey: false,
          };
        }
        return null;
      }

      final mangasMap = res['mangas'] as Map<String, dynamic>;
      totalCount = parseIntSafe(mangasMap['totalCount']);
      final nodes = mangasMap['nodes'] as List<dynamic>? ?? [];
      allNodes.addAll(nodes);

      // Break only when the page shortfall proves we've reached the end, or
      // when a *present* totalCount is satisfied. totalCount is 0 when the
      // server omits the field — trusting it then would truncate an entire
      // library to one 200-item page (and, downstream, poison the wipe-guard
      // ratio). The `offset` progress check guards against offset-ignoring
      // servers that would otherwise loop forever.
      if (nodes.length < pageSize || (totalCount > 0 && allNodes.length >= totalCount)) {
        complete = true;
        break;
      }
      if (offset == allNodes.length) {
        await LoggerService.instance.logWarning(
          'fetchLibrary: server did not advance offset ($offset) — stopping to avoid an infinite loop.',
          'GraphQL',
        );
        break;
      }
      offset = allNodes.length;
    }

    return {
      'mangas': {
        'totalCount': totalCount,
        'nodes': allNodes,
      },
      kSnapshotCompleteKey: complete,
    };
  }

  /// Chapter node fields shared by the detail query and the paginated root
  /// `chapters` query, so the two can never drift apart.
  static const String _mangaChapterFields = '''
        id
        name
        chapterNumber
        url
        realUrl
        isRead
        isBookmarked
        lastPageRead
        lastReadAt
        pageCount
        fetchedAt
        uploadDate
        scanlator
''';

  Future<Map<String, dynamic>?> fetchMangaDetails(int mangaServerId) async {
    // Manga block first, WITHOUT chapters: the nested `manga.chapters`
    // connection takes no pagination args on most Suwayomi builds, so very
    // long series silently truncate there. Chapters are fetched from the root
    // paginated `chapters` query, then merged into the same response shape.
    const mangaQueryStr = r'''
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
            lang
          }
        }
      }
    ''';
    final mangaRes = await query(mangaQueryStr, variables: {'id': mangaServerId}, label: 'fetchMangaDetails');
    if (mangaRes == null || mangaRes['manga'] == null) {
      return _fetchMangaDetailsLegacy(mangaServerId);
    }

    const pageSize = 500;
    final allNodes = <dynamic>[];
    var offset = 0;
    // See kSnapshotCompleteKey: a page failing after the first must not be
    // mistaken for "the server deleted these chapters", because the caller
    // hard-deletes chapters the server no longer reports.
    var chaptersComplete = false;
    while (true) {
      final pageQueryStr = '''
        query {
          chapters(condition: { mangaId: $mangaServerId }, first: $pageSize, offset: $offset) {
            pageInfo { hasNextPage }
            nodes { $_mangaChapterFields }
          }
        }
      ''';
      final pageRes = await query(pageQueryStr, label: 'fetchMangaDetails.chapters');
      if (pageRes == null || pageRes['chapters'] == null) {
        // Schema without the paginated root `chapters` query (older/alternate
        // Suwayomi builds): fall back to the single combined query. Best-effort
        // — such servers may still truncate very long series.
        if (offset == 0) return _fetchMangaDetailsLegacy(mangaServerId);
        await LoggerService.instance.logWarning(
          'fetchMangaDetails: chapter page at offset $offset failed for manga $mangaServerId '
          'after ${allNodes.length} nodes; reporting an INCOMPLETE snapshot',
          'GraphQL',
        );
        break;
      }
      final chapterMap = pageRes['chapters'] as Map<String, dynamic>;
      final pageNodes = chapterMap['nodes'] as List? ?? const [];
      if (pageNodes.isEmpty) {
        chaptersComplete = true;
        break;
      }
      final prevCount = allNodes.length;
      allNodes.addAll(pageNodes);
      final pageInfo = chapterMap['pageInfo'] as Map<String, dynamic>?;
      final hasNextPage = pageInfo != null
          ? pageInfo['hasNextPage'] == true
          : pageNodes.length >= pageSize;
      offset += pageNodes.length;
      if (!hasNextPage || pageNodes.length < pageSize) {
        chaptersComplete = true;
        break;
      }
      // A misbehaving server may ignore `offset` and return the same page
      // forever with hasNextPage: true. Cap the loop so a broken server can't
      // hang sync or balloon `allNodes` into an OOM. Not "complete" — we never
      // reached a proven end.
      if (allNodes.length == prevCount || allNodes.length > 25000) {
        await LoggerService.instance.logWarning(
          'fetchMangaDetails: chapter pagination did not terminate cleanly for manga '
          '$mangaServerId at ${allNodes.length} nodes; reporting an INCOMPLETE snapshot',
          'GraphQL',
        );
        break;
      }
    }

    // Reassemble data['manga']['chapters']['nodes'] — the shape all callers
    // (detail screen, full chapter snapshot) consume.
    final mangaMap = Map<String, dynamic>.from(mangaRes['manga'] as Map<String, dynamic>);
    mangaMap['chapters'] = {'nodes': allNodes};
    return {'manga': mangaMap, kSnapshotCompleteKey: chaptersComplete};
  }

  /// Single-query fallback used when the root paginated `chapters` query (or
  /// the manga query) is unavailable. Kept byte-for-byte identical to the
  /// original combined query.
  Future<Map<String, dynamic>?> _fetchMangaDetailsLegacy(int mangaServerId) async {
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
            lang
          }
          chapters {
            nodes {
              id
              name
              chapterNumber
              url
              realUrl
              isRead
              isBookmarked
              lastPageRead
              lastReadAt
              pageCount
              fetchedAt
              uploadDate
              scanlator
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

    // 2) Modern Suwayomi: search the source and pick the best match by URL/title.
    // Title-first — URL-slug words often fuzzy-match unrelated series (e.g.
    // webtoons indexes series under their localized titles, not their slugs).
    try {
      final queries = <String>{};
      if (title != null && title.trim().length >= 3) queries.add(title.trim());
      final derived = urlToSearchQuery(url);
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

  /// Derives a search query from a manga URL: strips scheme/host/query, keeps the
  /// last meaningful path segment, and turns separators into spaces
  /// (e.g. ".../tower-of-god/list?title_no=95" -> "tower of god").
  static String urlToSearchQuery(String url) {
    var u = url.split('?').first.split('#').first;
    u = u.replaceAll(RegExp(r'^https?://[^/]+'), '');
    final segments =
        u.split('/').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();
    // Trailing husk segments that are meaningless as search terms.
    const husks = {'list', 'all', 'seasons', 'season', 'genre', 'index', 'main', 'detail'};
    while (segments.isNotEmpty &&
        (husks.contains(segments.last.toLowerCase()) ||
            RegExp(r'^title[_-]?no[=:]?\d*$').hasMatch(segments.last.toLowerCase()))) {
      segments.removeLast();
    }
    if (segments.isEmpty) return '';
    final q = segments.last.replaceAll(RegExp(r'[-_+.]+'), ' ').trim();
    return q.length >= 3 ? q : '';
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

  Future<Map<String, dynamic>?> fetchCategories() async {
    const queryStr = '''
      {
        categories {
          totalCount
          nodes {
            id
            name
            order
            default
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

  Future<Map<String, dynamic>?> fetchHistoryChapters(int offset) async {
    // Paginate the whole read history (not just the first 500) and order by
    // last-read so the most recent history is always kept when the server
    // truncates. The naive single-shot query with no order directive let the
    // server default ordering hide the newest activity beyond the first page.
    const pageSize = 500;
    int cursor = offset < 0 ? 0 : offset;
    final allNodes = <dynamic>[];
    int? totalCount;
    const pageQueryStr = '''
      {
        chapters(
          condition: { isRead: true }
          order: [{ by: LAST_READ_AT, byType: DESC }]
          first: $pageSize
          offset: PLACEHOLDER
        ) {
          totalCount
          nodes {
            id
            name
            chapterNumber
            isRead
            isBookmarked
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

    while (true) {
      final queryStr = pageQueryStr.replaceFirst('PLACEHOLDER', '$cursor');
      final res = await query(queryStr, label: 'fetchHistoryChapters');
      if (res == null || !res.containsKey('chapters')) {
        if (allNodes.isNotEmpty) {
          return {'chapters': {'totalCount': totalCount ?? allNodes.length, 'nodes': allNodes}};
        }
        return res;
      }
      final chapterMap = res['chapters'] as Map<String, dynamic>?;
      final pageNodes = chapterMap?['nodes'] as List? ?? const <dynamic>[];
      totalCount ??= parseIntSafe(chapterMap?['totalCount']);
      if (pageNodes.isEmpty) {
        if (allNodes.isEmpty) return res;
        break;
      }
      final prevCount = allNodes.length;
      allNodes.addAll(pageNodes);
      if (allNodes.length == prevCount) break; // server ignored offset — stop looping
      // totalCount is non-null here: line 906 ran on the first page of this loop.
      if (allNodes.length >= totalCount) break;
      cursor += pageNodes.length;
      if (allNodes.length >= 5000) break; // hard ceiling: never balloon memory
    }

    return {
      'chapters': {'totalCount': totalCount, 'nodes': allNodes},
    };
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
            isBookmarked
            lastPageRead
            isDownloaded
            fetchedAt
            uploadDate
            scanlator
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
      final res = await query(patchMut, variables: {'id': mangaId, 'add': toAdd, 'remove': toRemove}, label: 'updateMangaCategories');
      if (res != null) return res;
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

  // ── SERVER SETTINGS INTEGRATION ────────────────────────────────────────

  /// Fetch complete categorized settings from Suwayomi server (all 69 fields)
  Future<Map<String, dynamic>?> fetchServerSettings() async {
    const queryStr = '''
      query {
        settings {
          authMode
          authPassword
          authUsername
          autoBackupIncludeCategories
          autoBackupIncludeChapters
          autoBackupIncludeClientData
          autoBackupIncludeHistory
          autoBackupIncludeManga
          autoBackupIncludeServerSettings
          autoBackupIncludeTracking
          autoDownloadIgnoreReUploads
          autoDownloadNewChapters
          autoDownloadNewChaptersLimit
          backupInterval
          backupPath
          backupTTL
          backupTime
          debugLogsEnabled
          downloadAsCbz
          downloadsPath
          electronPath
          excludeCompleted
          excludeEntryWithUnreadChapters
          excludeNotStarted
          excludeUnreadChapters
          extensionRepos
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
          opdsEnablePageReadProgress
          opdsItemsPerPage
          opdsMarkAsReadOnDownload
          opdsShowOnlyDownloadedChapters
          opdsShowOnlyUnreadChapters
          opdsSkipChapterMetadataFeed
          opdsUseBinaryFileSizes
          port
          socksProxyEnabled
          socksProxyHost
          socksProxyPassword
          socksProxyPort
          socksProxyUsername
          socksProxyVersion
          syncDataCategories
          syncDataChapters
          syncDataHistory
          syncDataManga
          syncDataTracking
          syncYomiApiKey
          syncYomiEnabled
          syncYomiHost
          systemTrayEnabled
          updateMangas
          useHikariConnectionPool
          webUIChannel
          webUIFlavor
          webUIInterface
          webUIUpdateCheckInterval
        }
        aboutServer {
          version
          buildTime
        }
      }
    ''';
    return await query(queryStr, label: 'fetchServerSettings');
  }

  /// Update any partial settings on Suwayomi server
  Future<Map<String, dynamic>?> updateServerSettings(Map<String, dynamic> partialSettings) async {
    const mutStr = r'''
      mutation SetServerSettings($settings: PartialSettingsTypeInput!) {
        setSettings(input: { settings: $settings }) {
          settings {
            authMode
            authPassword
            authUsername
            autoBackupIncludeCategories
            autoBackupIncludeChapters
            autoBackupIncludeClientData
            autoBackupIncludeHistory
            autoBackupIncludeManga
            autoBackupIncludeServerSettings
            autoBackupIncludeTracking
            autoDownloadIgnoreReUploads
            autoDownloadNewChapters
            autoDownloadNewChaptersLimit
            backupInterval
            backupPath
            backupTTL
            backupTime
            debugLogsEnabled
            downloadAsCbz
            downloadsPath
            electronPath
            excludeCompleted
            excludeEntryWithUnreadChapters
            excludeNotStarted
            excludeUnreadChapters
            extensionRepos
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
            opdsEnablePageReadProgress
            opdsItemsPerPage
            opdsMarkAsReadOnDownload
            opdsShowOnlyDownloadedChapters
            opdsShowOnlyUnreadChapters
            opdsSkipChapterMetadataFeed
            opdsUseBinaryFileSizes
            port
            socksProxyEnabled
            socksProxyHost
            socksProxyPassword
            socksProxyPort
            socksProxyUsername
            socksProxyVersion
            syncDataCategories
            syncDataChapters
            syncDataHistory
            syncDataManga
            syncDataTracking
            syncYomiApiKey
            syncYomiEnabled
            syncYomiHost
            systemTrayEnabled
            updateMangas
            useHikariConnectionPool
            webUIChannel
            webUIFlavor
            webUIInterface
            webUIUpdateCheckInterval
          }
        }
      }
    ''';
    return await query(mutStr, variables: {'settings': partialSettings}, label: 'updateServerSettings');
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
    return await query(mutStr, label: 'updateLibrary');
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
    return await query(mutStr, label: 'clearCachedImages');
  }

  /// Create immediate backup on server with options
  Future<Map<String, dynamic>?> createServerBackup({bool includeCategories = true, bool includeChapters = true}) async {
    const mutStr = r'''
      mutation CreateBackup($flags: PartialBackupFlagsInput) {
        createBackup(input: { flags: $flags }) {
          clientMutationId
          url
        }
      }
    ''';
    return await query(
      mutStr,
      variables: {
        'flags': {
          'includeManga': true,
          'includeCategories': includeCategories,
          'includeChapters': includeChapters,
        },
      },
      label: 'createBackup',
    );
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
}
