import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint, kDebugMode, visibleForTesting;
import '../logging/logger_service.dart';
import '../services/server_tls_trust.dart';
import 'cursor_paginator.dart';
import 'offline_monitor.dart';
import 'server_api_models.dart';
import 'server_auth_refresher.dart';
import 'server_capabilities.dart';
import 'server_compat_models.dart';
import 'server_mutation_exception.dart';
import 'server_result.dart';
import 'source_filters.dart';
import 'suwayomi_parse_helpers.dart';
import 'suwayomi_settings_fields.dart';

export 'server_api_models.dart';
export 'server_auth_refresher.dart';
export 'server_compat_models.dart';
export 'server_mutation_exception.dart';
export 'source_filters.dart';

part 'graphql_server_compat_api.dart';
part 'graphql_sources_library_api.dart';
part 'graphql_updates_downloads_api.dart';
part 'graphql_chapters_tracking_api.dart';
part 'graphql_results_settings_api.dart';

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

/// IMP-034: instance state, transport and query core. Public API lives on
/// [GraphQLClientService]; the endpoint groups are private mixins in parts.
/// Same scheme, host and effective port.
bool isSameOrigin(String a, String b) {
  final ua = Uri.tryParse(a);
  final ub = Uri.tryParse(b);
  if (ua == null || ub == null || ua.host.isEmpty) return false;
  return ua.scheme.toLowerCase() == ub.scheme.toLowerCase() &&
      ua.host.toLowerCase() == ub.host.toLowerCase() &&
      ua.port == ub.port;
}

abstract class _GraphQLClientCore {
  late Dio _dio;

  /// Whether [_dio] has been assigned yet. `late` fields throw on first read,
  /// so this distinguishes "no client yet" from "client failed to close".
  bool _dioInitialized = false;
  String? _baseUrl;

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

  /// Whether [url] points at the configured server: same scheme, host and
  /// effective port. A string prefix check would also accept
  /// `https://srv.com.evil.net` or `:45678` and leak [authHeaders] there.
  bool isServerUrl(String url) {
    if (!isConfigured || _baseUrl == null) return false;
    return isSameOrigin(_baseUrl!, url);
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
    if (clean.isNotEmpty) GraphQLClientService.debugHostGuard?.call(clean);
    if (clean.isEmpty) {
      _baseUrl = null;
      _authToken = null;
      _extraHeaders = const {};
      _lastReachableCheck = null;
      _lastReachableStatus = false;
      lastRequestWasTransportFailure = false;
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
    lastRequestWasTransportFailure = false;
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

  /// Verdict of the most recently completed request: true when it failed at
  /// the transport level, false when the server answered (any HTTP status,
  /// including rejections). Read synchronously by the sync dispatch loop
  /// right after its mutation returns, so a rejection is never misclassified
  /// by a STALE shared flag set by some other subsystem's timeout minutes...
  /// rather seconds ago (`isKnownUnreachable` spans a 15s window and any
  /// concurrent request can poison it). Still theoretically raceable by a
  /// request completing on another stack in the same microtask window, but
  /// strictly fresher than the shared flag. Never null before first request:
  /// false (optimistic) matches the pre-existing default classification.
  bool lastRequestWasTransportFailure = false;

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
          lastRequestWasTransportFailure = false;
          OfflineMonitor.instance.reportTransportSuccess();
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
        // Only real transport failures vote unreachable: a 400/404/422 means
        // the server answered and rejected the request shape, which says
        // nothing about the transport. (Mirrors _queryOnce's classifier.)
        if (GraphQLClientService._isTransportFailure(e)) {
          _lastReachableStatus = false;
          lastRequestWasTransportFailure = true;
          OfflineMonitor.instance.reportTransportFailure();
        }
      }
    } catch (_) {
      // Non-Dio throw after the HTTP exchange completed ( refresh logic,
      // JSON handling): the server answered, so this is not a transport
      // failure — same rule as _queryOnce's success-path catch.
      _lastReachableStatus = true;
      lastRequestWasTransportFailure = false;
      OfflineMonitor.instance.reportTransportSuccess();
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
    lastRequestWasTransportFailure = false;
    // The server answered: transport works regardless of credentials.
    OfflineMonitor.instance.reportTransportSuccess();
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
    } catch (e) { debugPrint('[graphql_client_service] ignored: $e'); }

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
      if (!outcome.retryable || attempt >= policy.maxRetries) {
        return flattenUserScopedFields(outcome.data);
      }
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
    // Fast-fail only if BOTH the 15s cache AND OfflineMonitor agree we're offline.
    // OfflineMonitor uses a 3-failure debounce to avoid UI flicker; the 15s
    // window here prevents hammering a down server. Requiring both avoids the
    // inconsistency where UI shows "online" but sync silently drops requests.
    if (!bypassFastFail &&
        !_lastReachableStatus &&
        _lastReachableCheck != null &&
        now.difference(_lastReachableCheck!) < const Duration(seconds: 15) &&
        OfflineMonitor.instance.isOffline) {
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
      lastRequestWasTransportFailure = false;
      OfflineMonitor.instance.reportTransportSuccess();
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
          if (GraphQLClientService._looksLikeAuthError(errorMsg.toString())) {
            notifyAuthError();
            return unauthorized;
          }
          return noRetry;
        }
        return (data: data['data'] as Map<String, dynamic>?, retryable: false, unauthorized: false);
      }
      return noRetry;
    } on DioException catch (e) {
      if (GraphQLClientService._isTransportFailure(e)) {
        _lastReachableStatus = false;
        _lastReachableCheck = DateTime.now();
        lastRequestWasTransportFailure = true;
        OfflineMonitor.instance.reportTransportFailure();
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
      return (data: null, retryable: GraphQLClientService.isRetryableTransportFailure(e), unauthorized: wasUnauthorized);
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
      lastRequestWasTransportFailure = false;
      await LoggerService.instance.logError(
        'GraphQL response for [$label] was unparseable: $e',
        exception: e,
        stackTrace: stack,
        category: 'GraphQL',
      );
      return noRetry;
    }
  }

  /// UIX6-03: per-user state selections. With `user { … }` support the
  /// deprecated top-level fields are not requested at all; responses are
  /// flattened back onto the parent by [flattenUserScopedFields] in [query],
  /// so callers keep reading `chapter['isRead']` / `manga['inLibrary']`.
  String _userScoped(List<String> keys) =>
      capabilities.hasUserField ? 'user { ${keys.join(' ')} }' : keys.join('\n');

  /// Chapter state (read / bookmark / progress / download).
  /// ISS-141: selections carrying read state also fetch chapter meta (on the
  /// chapter node, never user-scoped) for the `sunfire_read_action_at` stamp.
  String _chapterState([List<String> keys = const ['isRead', 'isBookmarked', 'lastPageRead', 'lastReadAt']]) =>
      keys.contains('isRead') ? '${_userScoped(keys)}\nmeta { key value }' : _userScoped(keys);

  /// Manga library state.
  String _mangaState([List<String> keys = const ['inLibrary', 'inLibraryAt', 'unreadCount']]) =>
      _userScoped(keys);

  /// Test hook: current chapter/manga state selections.
  @visibleForTesting
  String debugStateSelections() => '${_chapterState()}|${_mangaState()}';

  /// Internal helper: calls [query] and captures the transport-failure
  /// classification of the final attempt atomically. Returns a record of
  /// (data, wasTransportFailure). This avoids the race where a concurrent
  /// request overwrites [lastRequestWasTransportFailure] between the caller's
  /// `await query(...)` and its read of the shared flag.
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})>
      _queryAndClassify(
    String document, {
    Map<String, dynamic>? variables,
    String? label,
    GraphQLOp? op,
  }) async {
    final data = await query(
      document,
      variables: variables,
      label: label,
      op: op,
    );
    // Capture immediately: no await between query returning and this read.
    final wasTransportFailure = lastRequestWasTransportFailure;
    return (data: data, wasTransportFailure: wasTransportFailure);
  }


  // IMP-034: cross-group calls; implemented by the mixins on GraphQLClientService.
  Future<Map<String, dynamic>?> fetchLibrary();
  Future<Map<String, dynamic>?> fetchCategories();
  Future<Map<String, dynamic>?> triggerServerLibraryUpdate({List<int>? categoryIds});
  Future<Map<String, dynamic>?> enqueueChapterDownloads(List<int> chapterIds);
  Future<Map<String, dynamic>?> deleteDownloadedChapter(int chapterId);
  Future<Map<String, dynamic>?> dequeueChapterDownloads(List<int> chapterIds);
  Future<Map<String, dynamic>?> fetchChapterPages(int chapterId);
  Future<Map<String, dynamic>?> trackProgress(int mangaId);
  Future<Map<String, dynamic>?> updateMangaCategories(int mangaId, List<int> categoryIds);
  Future<Map<String, dynamic>?> updateMangaLibraryState(int mangaId, bool inLibrary);
  Future<Map<String, dynamic>?> updateCategoryOrder(int categoryId, int position);
  Future<Map<String, dynamic>?> deleteDownloadedChapters(List<int> ids);
  Future<Map<String, dynamic>?> startDownloader();
  Future<Map<String, dynamic>?> stopDownloader();
  Future<Map<String, dynamic>?> clearDownloader();
}

/// Chapter node fields shared by the detail query and the paginated root
/// `chapters` query, so the two can never drift apart.
const String _mangaChapterFieldsBase = '''
      id
      name
      chapterNumber
      url
      realUrl
      pageCount
      fetchedAt
      uploadDate
      scanlator
''';

const String _mangaChapterUserFields = '''
      user {
        isRead
        isBookmarked
        isDownloaded
        lastPageRead
        lastReadAt
      }
''';

/// Cheap per-manga change markers for targeted chapter refresh (ISS-076).
/// `chapterStats` is aliased so nothing mistakes it for a chapter list.
const String _chapterFetchMarkerFields = '''
      chaptersLastFetchedAt
      latestFetchedChapter { id fetchedAt }
      chapterStats: chapters { totalCount }
      bookmarkCount
      downloadCount
      lastReadChapter { id lastPageRead lastReadAt isRead }
''';

/// M5: marker fields without the deprecated `MangaType` counters /
/// `lastReadChapter`; those come from `user { … }` instead (merged with
/// [_mangaUserFields] by GraphQL field merging, flattened client-side).
const String _chapterFetchMarkerFieldsUserScoped = '''
      chaptersLastFetchedAt
      latestFetchedChapter { id fetchedAt }
      chapterStats: chapters { totalCount }
      user { lastReadChapter { id user { lastPageRead lastReadAt isRead } } }
''';

const String _mangaUserFields = '''
      user {
        inLibrary
        inLibraryAt
        unreadCount
        bookmarkCount
        downloadCount
      }
''';


class GraphQLClientService extends _GraphQLClientCore
    with _GraphQLSourcesLibraryApi, _GraphQLUpdatesDownloadsApi, _GraphQLChaptersTrackingApi, _GraphQLResultsSettingsApi {
  static GraphQLClientService? _instance;
  GraphQLClientService._();

  /// Test-only constructor so tests can subclass with a fake
  /// (`class _Fake extends GraphQLClientService { _Fake() : super.forTesting(); }`).
  @visibleForTesting
  GraphQLClientService.forTesting();

  static GraphQLClientService? _debugInstance;

  /// Test-only: when set, [instance] returns [v] instead of the real
  /// singleton. Set back to null in tearDown. The ISS-134 [debugHostGuard]
  /// still applies: it runs in [initialize], which a fake inherits, and it is
  /// checked here against the fake's base URL when the fake is installed.
  @visibleForTesting
  static set debugInstance(GraphQLClientService? v) {
    final url = v?._baseUrl;
    if (url != null && url.isNotEmpty) debugHostGuard?.call(url);
    _debugInstance = v;
  }

  @visibleForTesting
  static GraphQLClientService? get debugInstance => _debugInstance;

  /// Test isolation (ISS-140): clears the injected fake. [debugHostGuard]
  /// (the ISS-134 real-server deny hook) is deliberately kept.
  @visibleForTesting
  static void debugResetTestOverrides() {
    _debugInstance = null;
  }

  static GraphQLClientService get instance {
    final fake = _debugInstance;
    if (fake != null) return fake;
    _instance ??= GraphQLClientService._();
    return _instance!;
  }

  /// ISS-134: test-only host guard. `flutter_test_config.dart` installs one
  /// that throws for Jane's real server (100.71.46.98 / any :4567), so no
  /// test can ever point the client at production. Null in the app.
  @visibleForTesting
  static void Function(String baseUrl)? debugHostGuard;

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

  /// Namespace for every key Sunfire writes into Suwayomi manga meta, so it
  /// never collides with the WebUI's `webUI_*` / other clients' keys.
  static const String kSunfireMetaPrefix = 'sunfire_';

  /// Prefixes [key] with [kSunfireMetaPrefix] unless already present.
  static String sunfireMetaKey(String key) =>
      key.startsWith(kSunfireMetaPrefix) ? key : '$kSunfireMetaPrefix$key';

}
