import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint, kDebugMode, visibleForTesting;
import '../logging/logger_service.dart';
import '../services/server_tls_trust.dart';
import 'cursor_paginator.dart';
import 'server_api_models.dart';
import 'server_auth_refresher.dart';
import 'server_capabilities.dart';
import 'server_compat_models.dart';
import 'source_filters.dart';
import 'suwayomi_parse_helpers.dart';
import 'suwayomi_settings_fields.dart';

export 'server_api_models.dart';
export 'server_auth_refresher.dart';
export 'server_compat_models.dart';
export 'source_filters.dart';

part 'graphql_server_compat_api.dart';

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

  /// Last successful capability probe (ISS-066). Empty until [probeServerCapabilities].
  ServerCapabilities capabilities = ServerCapabilities.empty;


  /// Login/JWT session hook (ISS-078). Null → stored Basic/Bearer header only.
  ServerAuthRefresher? authRefresher;

  /// Session headers besides Authorization (SIMPLE_LOGIN `Cookie`).
  Map<String, String> _extraHeaders = const {};

  Map<String, String> get authHeaders {
    final out = <String, String>{..._extraHeaders};
    if (_authToken != null && _authToken!.trim().isNotEmpty) {
      final token = _authToken!.trim();
      if (token.startsWith('Basic ') || token.startsWith('Bearer ')) {
        out['Authorization'] = token;
      } else {
        out['Authorization'] = 'Bearer $token';
      }
    }
    return out.isEmpty ? const {} : out;
  }

  /// Current Authorization header value (or null). Used by the WS layer.
  String? get currentAuthHeader => authHeaders['Authorization'];

  /// Swap credentials on the live client without resetting reachability or
  /// capabilities (ISS-078: JWT refresh / login / logout). [extraHeaders]
  /// replaces the previous extra headers when given.
  void updateAuthToken(String? authToken, {Map<String, String>? extraHeaders}) {
    _authToken = authToken;
    if (extraHeaders != null) _extraHeaders = Map.unmodifiable(extraHeaders);
    if (_dioInitialized) {
      _dio.options.headers = <String, dynamic>{
        'Content-Type': 'application/json',
        ...authHeaders,
      };
    }
  }

  void initialize(String baseUrl, {String? authToken}) {
    final clean = baseUrl.trim();
    if (clean.isEmpty) {
      _baseUrl = null;
      _authToken = null;
      _extraHeaders = const {};
      _lastReachableCheck = null;
      _lastReachableStatus = false;
      capabilities = ServerCapabilities.empty;
      clearAuthError();
      return;
    }
    _baseUrl = clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
    // An active login session (ISS-078) outranks the stored Basic/Bearer
    // header, so a settings-screen re-initialize does not drop the JWT.
    final refresher = authRefresher;
    _authToken = refresher?.authHeaderOverride(_baseUrl!) ?? authToken;
    _extraHeaders = Map.unmodifiable(refresher?.extraHeaders(_baseUrl!) ?? const <String, String>{});
    _lastReachableCheck = null;
    _lastReachableStatus = false;
    clearAuthError();
    final headers = <String, dynamic>{'Content-Type': 'application/json', ...authHeaders};
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

  /// Replace the HTTP adapter (tests only — e.g. a scripted mock).
  @visibleForTesting
  set debugHttpAdapter(HttpClientAdapter adapter) => _dio.httpClientAdapter = adapter;

  /// Backoff between retries of idempotent reads (ISS-075). Tests shrink it.
  @visibleForTesting
  Duration Function(int attempt) retryDelay = jitteredBackoff;

  /// Server `flareSolverrTimeout` (seconds); stretches [GraphQLOp.scrapeRead]
  /// receive timeout. Updated from [fetchServerSettings].
  int flareSolverrTimeoutSeconds = kDefaultFlareSolverrTimeoutSeconds;

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
      final res = await _dio.post<Map<String, dynamic>>(
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
        if (_lastReachableStatus) {
          unawaited(probeServerCapabilities());
        }
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
        // ISS-078: an expired JWT / SIMPLE_LOGIN cookie — refresh once and
        // re-probe instead of leaving the reconnect prompt up.
        final refresher = authRefresher;
        if (refresher != null && !_probeRefreshInFlight) {
          _probeRefreshInFlight = true;
          try {
            if (await refresher.onUnauthorized()) {
              _lastReachableCheck = now;
              return await checkServerReachable(force: true);
            }
          } finally {
            _probeRefreshInFlight = false;
          }
        }
      } else {
        _lastReachableStatus = false;
      }
    } catch (_) {
      _lastReachableStatus = false;
    }
    _lastReachableCheck = now;
    return _isServerUsable;
  }

  bool _probeRefreshInFlight = false;

  /// A probe came back 401/403: the transport works, the credentials do not.
  ///
  /// Records the server as REACHABLE (it answered) and raises the auth error.
  /// [_isServerUsable] is what reports it as unusable for sync.
  void _recordAuthRejection() {
    _lastReachableStatus = true;
    notifyAuthError();
  }

  /// Introspect a handful of types + aboutServer (ISS-066).
  ///
  /// Safe to call repeatedly; results are cached on [capabilities]. Failures
  /// leave prior capabilities untouched (or empty on first connect).
  Future<ServerCapabilities> probeServerCapabilities({bool force = false}) async {
    if (!isConfigured) {
      capabilities = ServerCapabilities.empty;
      return capabilities;
    }
    if (capabilities.probed && !force) return capabilities;

    String? version;
    String? buildType;
    String? buildTime;
    try {
      final about = await query(
        '{ aboutServer { version buildType buildTime } }',
        label: 'probeAboutServer',
        op: GraphQLOp.read,
      );
      final a = about?['aboutServer'] as Map?;
      version = a?['version']?.toString();
      buildType = a?['buildType']?.toString();
      buildTime = a?['buildTime']?.toString();
    } catch (_) {}

    // Suwayomi's introspection guard rejects any request that names
    // `__type` more than once ("not asking for introspection in good faith"),
    // so the old single combined probe always failed and every flag stayed
    // false. One `__type` per request instead (verified live, v2.4.x).
    Future<Map<String, dynamic>?> typeProbe(String typeName, String selection) async {
      final res = await query(
        '{ __type(name: "$typeName") { $selection } }',
        label: 'probeServerCapabilities.$typeName',
        op: GraphQLOp.read,
      );
      final t = res?['__type'];
      return t is Map ? Map<String, dynamic>.from(t) : null;
    }

    bool hasField(Map<String, dynamic>? t, String name) {
      final fields = t?['fields'];
      return fields is List && fields.any((f) => f is Map && f['name'] == name);
    }

    var hasUserField = false;
    var hasUserSettings = false;
    var hasExtensionStores = false;
    var hasAddManga = false;
    var hasChapterFetchMarkers = false;
    var hasCategoryIsDefaultCategory = false;
    var authModes = const <String>['NONE', 'BASIC_AUTH', 'SIMPLE_LOGIN', 'UI_LOGIN'];
    try {
      hasUserField = (await typeProbe('MangaUserType', 'name')) != null;
      hasUserSettings = (await typeProbe('PartialUserSettingsTypeInput', 'name')) != null;
      hasExtensionStores = hasField(await typeProbe('Query', 'fields { name }'), 'extensionStores');
      hasAddManga = hasField(await typeProbe('Mutation', 'fields { name }'), 'addManga');
      final mangaType = await typeProbe('MangaType', 'fields { name }');
      hasChapterFetchMarkers = hasField(mangaType, 'chaptersLastFetchedAt') &&
          hasField(mangaType, 'latestFetchedChapter');
      // Server v2.4.2366+. Unknown type name or absent field → false, and
      // callers fall back to the legacy selection set. Never assumed true.
      final categoryType = await typeProbe('CategoryType', 'fields { name }');
      hasCategoryIsDefaultCategory =
          hasField(categoryType, 'isDefaultCategory');
      final enums = (await typeProbe('AuthMode', 'enumValues { name }'))?['enumValues'];
      if (enums is List && enums.isNotEmpty) {
        authModes = [
          for (final e in enums)
            if (e is Map && e['name'] is String) e['name'] as String,
        ];
      }
    } catch (e) {
      await LoggerService.instance.logWarning('Capability probe failed: $e', 'GraphQL');
    }

    capabilities = ServerCapabilities(
      version: version,
      buildType: buildType,
      buildTime: buildTime,
      hasUserField: hasUserField,
      hasUserSettings: hasUserSettings,
      hasExtensionStores: hasExtensionStores,
      hasAddManga: hasAddManga,
      hasChapterFetchMarkers: hasChapterFetchMarkers,
      hasCategoryIsDefaultCategory: hasCategoryIsDefaultCategory,
      authModes: authModes,
      probed: true,
    );
    return capabilities;
  }

  /// Runs a GraphQL [document].
  ///
  /// [op] selects the per-operation timeout/retry policy (ISS-075); when
  /// omitted it is inferred (`mutation` → write, else read). Only idempotent
  /// classes ([GraphQLOp.read], [GraphQLOp.slowRead], [GraphQLOp.scrapeRead])
  /// are retried, at most `policy.maxRetries` times with jittered backoff, and
  /// only on transport failures (timeouts, 5xx, dropped connection — never a
  /// refused connection, 4xx, or a GraphQL `errors` payload).
  Future<Map<String, dynamic>?> query(
    String document, {
    Map<String, dynamic>? variables,
    String? label,
    GraphQLOp? op,
  }) async {
    if (!isConfigured) return null;
    final policy = policyForOp(
      op ?? inferGraphQLOp(document),
      flareSolverrTimeoutSeconds: flareSolverrTimeoutSeconds,
    );
    final refresher = authRefresher;
    if (refresher != null) await refresher.beforeRequest();
    var authRetried = false;
    for (var attempt = 0;; attempt++) {
      final outcome = await _queryOnce(
        document,
        variables: variables,
        label: label,
        policy: policy,
        bypassFastFail: attempt > 0,
      );
      // ISS-078: one transparent retry after the session refreshed. Safe for
      // mutations too — a 401/auth error means the server did not run it.
      if (outcome.unauthorized && !authRetried && refresher != null) {
        authRetried = true;
        if (await refresher.onUnauthorized()) {
          attempt--;
          continue;
        }
      }
      if (!outcome.retryable || attempt >= policy.maxRetries) return outcome.data;
      final delay = retryDelay(attempt + 1);
      if (kDebugMode) {
        debugPrint('[graphql_client_service] retry ${attempt + 1}/${policy.maxRetries} [$label] in ${delay.inMilliseconds}ms');
      }
      await Future<void>.delayed(delay);
    }
  }

  Future<({Map<String, dynamic>? data, bool retryable, bool unauthorized})> _queryOnce(
    String document, {
    Map<String, dynamic>? variables,
    String? label,
    required GraphQLOpPolicy policy,
    bool bypassFastFail = false,
  }) async {
    const noRetry = (data: null, retryable: false, unauthorized: false);
    const unauthorized = (data: null, retryable: false, unauthorized: true);

    // Fast-fail if the transport path was recently proven broken. This tracks
    // reachability ONLY, never auth: a 401 leaves the status reachable, so
    // credentials going bad still lets requests through and report their real
    // 401 instead of being masked as a silent null. (It used to be reachable in
    // the other direction, where a 401 latched here and blackholed every
    // request for 15s without sending any of them.)
    final now = DateTime.now();
    if (!bypassFastFail &&
        !_lastReachableStatus &&
        _lastReachableCheck != null &&
        now.difference(_lastReachableCheck!) < const Duration(seconds: 15)) {
      return noRetry;
    }

    try {
      final response = await _dio.post<dynamic>(
        '',
        data: jsonEncode({
          'query': document,
          'variables': variables ?? {},
        }),
        options: Options(
          sendTimeout: policy.send,
          receiveTimeout: policy.receive,
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
          if (_looksLikeAuthError(errorMsg.toString())) {
            notifyAuthError();
            return unauthorized;
          }
          return noRetry;
        }
        return (data: data['data'] as Map<String, dynamic>?, retryable: false, unauthorized: false);
      }
      return noRetry;
    } on DioException catch (e) {
      if (_isTransportFailure(e)) {
        _lastReachableStatus = false;
        _lastReachableCheck = DateTime.now();
      }
      var wasUnauthorized = false;
      if (e.type == DioExceptionType.badResponse) {
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          notifyAuthError();
          wasUnauthorized = true;
        }
      }
      // Suppress spammy connection refused errors during offline operation
      if (e.message != null && !e.message!.contains('Connection refused')) {
        await LoggerService.instance.logWarning('GraphQL request failed [$label]: ${e.message}', 'GraphQL');
      }
      return (data: null, retryable: isRetryableTransportFailure(e), unauthorized: wasUnauthorized);
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
      return noRetry;
    }
  }

  /// Whether a failed attempt is worth retrying (ISS-075): timeouts, 502/503/504
  /// and dropped connections. A refused connection means the server is down —
  /// retrying only delays the offline path.
  @visibleForTesting
  static bool isRetryableTransportFailure(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return code == 502 || code == 503 || code == 504;
      case DioExceptionType.connectionError:
        final msg = '${e.message} ${e.error}'.toLowerCase();
        return !msg.contains('refused') && !msg.contains('failed host lookup');
      default:
        return false;
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
            isNsfw
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

  Future<Map<String, dynamic>?> fetchLibrary() async {
    final userSel = capabilities.hasUserField ? _mangaUserFields : '';
    final markerSel = capabilities.hasChapterFetchMarkers ? _chapterFetchMarkerFields : '';
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
            inLibrary
            inLibraryAt
            sourceId
            unreadCount
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

  /// Chapter node fields shared by the detail query and the paginated root
  /// `chapters` query, so the two can never drift apart.
  static const String _mangaChapterFieldsBase = '''
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

  static const String _mangaChapterUserFields = '''
        user {
          isRead
          isBookmarked
          isDownloaded
          lastPageRead
          lastReadAt
        }
''';

  /// When [capabilities.hasUserField], also select `chapter.user {…}` (ISS-072).
  String get _mangaChapterFields => capabilities.hasUserField
      ? '$_mangaChapterFieldsBase$_mangaChapterUserFields'
      : _mangaChapterFieldsBase;

  /// Cheap per-manga change markers for targeted chapter refresh (ISS-076).
  /// `chapterStats` is aliased so nothing mistakes it for a chapter list.
  static const String _chapterFetchMarkerFields = '''
        chaptersLastFetchedAt
        latestFetchedChapter { id fetchedAt }
        chapterStats: chapters { totalCount }
        bookmarkCount
        downloadCount
        lastReadChapter { id lastPageRead lastReadAt isRead }
''';

  static const String _mangaUserFields = '''
        user {
          inLibrary
          inLibraryAt
          unreadCount
          bookmarkCount
          downloadCount
        }
''';

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
          inLibrary
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
              inLibraryAt
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
    // Keep selection aligned with downloadStatusChanged WS (ISS-086 / ISS-067)
    // so the Downloads screen has position/tries/manga titles on initial open.
    const queryStr = r'''
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
              isDownloaded
            }
            manga {
              id
              title
            }
          }
        }
      }
    ''';
    return await query(queryStr, label: 'fetchDownloadStatus');
  }

  // ── ISS-080 B5: download queue dequeue / reorder ──────────────────────
  //
  // Each returns the server's resulting `downloadStatus` (same selection as
  // [fetchDownloadStatus]) or null on failure. Per-item `state` is
  // QUEUED | DOWNLOADING | FINISHED | ERROR; `tries` is the retry count.

  static const String _downloadStatusSelection = '''
          downloadStatus {
            state
            queue {
              position
              progress
              state
              tries
              chapter { id name isDownloaded }
              manga { id title }
            }
          }
''';

  /// Remove one chapter from the server download queue.
  Future<Map<String, dynamic>?> dequeueChapterDownload(int chapterId) async {
    const mutStr = '''
      mutation(\$id: Int!) {
        dequeueChapterDownload(input: { id: \$id }) {
          $_downloadStatusSelection
        }
      }
    ''';
    return await query(mutStr, variables: {'id': chapterId}, label: 'dequeueChapterDownload');
  }

  /// Remove many chapters from the server download queue in one round-trip.
  /// Falls back to per-id [dequeueChapterDownload] when the bulk call fails.
  Future<Map<String, dynamic>?> dequeueChapterDownloads(List<int> chapterIds) async {
    if (chapterIds.isEmpty) return null;
    if (chapterIds.length == 1) return dequeueChapterDownload(chapterIds.first);
    const mutStr = '''
      mutation(\$ids: [Int!]!) {
        dequeueChapterDownloads(input: { ids: \$ids }) {
          $_downloadStatusSelection
        }
      }
    ''';
    final res = await query(mutStr, variables: {'ids': chapterIds}, label: 'dequeueChapterDownloads');
    if (res != null) return res;
    Map<String, dynamic>? last;
    for (final id in chapterIds) {
      last = await dequeueChapterDownload(id);
    }
    return last;
  }

  /// Move [chapterId] to queue index [to] (0-based, clamped at 0).
  Future<Map<String, dynamic>?> reorderChapterDownload(int chapterId, int to) async {
    const mutStr = '''
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
    const mutStr = '''
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
    // `platform` exists only on server v2.4.2366+. An unknown field fails the
    // whole query (validation error → null data), so retry without it: one
    // extra round trip on old servers, full data on new ones.
    const withPlatform = '''
      {
        aboutServer { name version buildType buildTime github discord platform }
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

  Future<Map<String, dynamic>?> bindTrack(int mangaId, int trackerId, dynamic remoteId, {bool? isPrivate}) async {
    final privVar = isPrivate == null ? '' : r', $private: Boolean';
    final privArg = isPrivate == null ? '' : r', private: $private';
    final mutStr = '''
      mutation(\$mangaId: Int!, \$trackerId: Int!, \$remoteId: LongString!$privVar) {
        bindTrack(input: { mangaId: \$mangaId, trackerId: \$trackerId, remoteId: \$remoteId$privArg }) {
          clientMutationId
        }
      }
    ''';
    return await query(mutStr, variables: {
      'mangaId': mangaId,
      'trackerId': trackerId,
      'remoteId': remoteId.toString(),
      if (isPrivate != null) 'private': isPrivate,
    }, label: 'bindTrack');
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
    return await query(mutStr, variables: {
      'recordId': recordId,
      'lastChapterRead': lastChapterRead,
      'status': status,
      'scoreString': scoreString,
      'startDate': startDate,
      'finishDate': finishDate,
      if (isPrivate != null) 'private': isPrivate,
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

    const mutStr = r'''
      mutation($ids: [Int!]!, $patch: UpdateChapterPatchInput!) {
        updateChapters(input: { ids: $ids, patch: $patch }) {
          chapters { id isRead isBookmarked lastPageRead }
        }
      }
    ''';
    final res = await query(
      mutStr,
      variables: {'ids': ids, 'patch': patch},
      label: 'updateChapters',
    );
    if (res != null) return res;

    // Per-id fallback when bulk is unsupported / failed.
    Map<String, dynamic>? last;
    for (final id in ids) {
      if (isBookmarked != null && isRead == null && lastPageRead == null) {
        last = await updateChapterBookmark(id, isBookmarked);
      } else {
        last = await updateChapterReadStatus(id, isRead ?? false, lastPageRead ?? 0);
      }
    }
    return last;
  }

  /// Bulk delete downloaded chapters (ISS-069). Per-id fallback on failure.
  Future<Map<String, dynamic>?> deleteDownloadedChapters(List<int> ids) async {
    if (ids.isEmpty) return {'chapters': <dynamic>[]};
    if (ids.length == 1) {
      return deleteDownloadedChapter(ids.first);
    }
    const mutStr = r'''
      mutation($ids: [Int!]!) {
        deleteDownloadedChapters(input: { ids: $ids }) {
          chapters { id isDownloaded }
        }
      }
    ''';
    final res = await query(
      mutStr,
      variables: {'ids': ids},
      label: 'deleteDownloadedChapters',
    );
    if (res != null) return res;
    Map<String, dynamic>? last;
    for (final id in ids) {
      last = await deleteDownloadedChapter(id);
    }
    return last;
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
    return await query(
      mutStr,
      variables: {'id': categoryId, 'patch': patch},
      label: 'updateCategoryPatch',
    );
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

  // ── ISS-077 B9: per-manga meta (sunfire_* namespace) ───────────────────

  /// Namespace for every key Sunfire writes into Suwayomi manga meta, so it
  /// never collides with the WebUI's `webUI_*` / other clients' keys.
  static const String kSunfireMetaPrefix = 'sunfire_';

  /// Prefixes [key] with [kSunfireMetaPrefix] unless already present.
  static String sunfireMetaKey(String key) =>
      key.startsWith(kSunfireMetaPrefix) ? key : '$kSunfireMetaPrefix$key';

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
    final res = await query(
      mutStr,
      variables: {'mangaId': mangaId, 'key': sunfireMetaKey(key.trim()), 'value': value},
      label: 'setMangaMeta',
    );
    return res != null;
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
    final res = await query(
      mutStr,
      variables: {'mangaId': mangaId, 'key': sunfireMetaKey(key.trim())},
      label: 'deleteMangaMeta',
    );
    return res != null;
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
        if (m is Map && (m['key']?.toString() ?? '').startsWith(kSunfireMetaPrefix))
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