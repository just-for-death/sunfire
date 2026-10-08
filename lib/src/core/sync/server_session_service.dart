// ISS-078 B2: Suwayomi login sessions (UI_LOGIN JWT + SIMPLE_LOGIN cookie).
//
// Server facts (Suwayomi v2.2+, verified against server source):
//  - UI_LOGIN: `mutation login(input:{username,password})` → accessToken +
//    refreshToken. Must be sent WITHOUT an Authorization header (the server
//    refuses "login while already logged-in"). Requests then carry
//    `Authorization: Bearer <access>`; the WS carries it in the
//    `connection_init` payload. An expired access token degrades the caller
//    to a visitor, so protected fields answer "Unauthorized" (HTTP 200 errors)
//    or 401. `refreshToken(input:{refreshToken})` → new accessToken only.
//    Defaults: access 5m, refresh 60d.
//  - SIMPLE_LOGIN: form POST `/login.html` (`user`, `pass`) → 303 + session
//    cookie (in-memory on the server, ~30m idle, lost on restart). There is no
//    token to refresh, so "refresh" = re-post the stored credentials.
//  - NONE / BASIC_AUTH: no session; this service stays inert and the stored
//    Basic/Bearer header (ServerAuthHelper) is used unchanged.
//
// UI (login form) is owned by UIS; this file only exposes the methods.

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, visibleForTesting, kDebugMode, debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/logger_service.dart';
import '../services/server_tls_trust.dart';
import 'graphql_client_service.dart';
import 'server_auth_helper.dart';
import 'websocket_service.dart';

/// Which interactive login the server expects.
enum ServerLoginMode {
  /// `authMode = UI_LOGIN` — GraphQL `login` / `refreshToken` (JWT).
  uiLogin,

  /// `authMode = SIMPLE_LOGIN` — `/login.html` form + session cookie.
  simpleLogin,
}

/// Maps a server `authMode` enum string to a login mode (null = no login form:
/// NONE or BASIC_AUTH, which keep using the stored header).
ServerLoginMode? loginModeForAuthMode(String? authMode) {
  switch (authMode?.trim().toUpperCase()) {
    case 'UI_LOGIN':
      return ServerLoginMode.uiLogin;
    case 'SIMPLE_LOGIN':
      return ServerLoginMode.simpleLogin;
    default:
      return null;
  }
}

/// Outcome of [ServerSessionService.login].
class ServerLoginResult {
  final bool success;

  /// Human-readable failure (server message or transport error). Null on success.
  final String? error;

  /// True when the server answered and rejected the credentials (vs. network).
  final bool invalidCredentials;

  const ServerLoginResult._(this.success, this.error, this.invalidCredentials);
  const ServerLoginResult.ok() : this._(true, null, false);
  const ServerLoginResult.failed(String message, {bool invalidCredentials = false})
      : this._(false, message, invalidCredentials);

  @override
  String toString() => success ? 'ServerLoginResult.ok' : 'ServerLoginResult.failed($error)';
}

/// Persisted session. Bound to [baseUrl] so switching servers never sends one
/// server's token to another.
class ServerSession {
  final ServerLoginMode mode;
  final String baseUrl;
  final String username;

  /// UI_LOGIN only.
  final String accessToken;
  final String refreshToken;

  /// SIMPLE_LOGIN only: the stored password (needed to silently re-login — the
  /// server session dies after ~30m idle or a restart) and the cookie.
  final String password;
  final String cookie;
  final DateTime? cookieIssuedAt;

  const ServerSession({
    required this.mode,
    required this.baseUrl,
    this.username = '',
    this.accessToken = '',
    this.refreshToken = '',
    this.password = '',
    this.cookie = '',
    this.cookieIssuedAt,
  });

  ServerSession copyWith({String? accessToken, String? cookie, DateTime? cookieIssuedAt}) => ServerSession(
        mode: mode,
        baseUrl: baseUrl,
        username: username,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken,
        password: password,
        cookie: cookie ?? this.cookie,
        cookieIssuedAt: cookieIssuedAt ?? this.cookieIssuedAt,
      );

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'baseUrl': baseUrl,
        'username': username,
        if (accessToken.isNotEmpty) 'accessToken': accessToken,
        if (refreshToken.isNotEmpty) 'refreshToken': refreshToken,
        if (password.isNotEmpty) 'password': password,
        if (cookie.isNotEmpty) 'cookie': cookie,
        if (cookieIssuedAt != null) 'cookieIssuedAt': cookieIssuedAt!.millisecondsSinceEpoch,
      };

  static ServerSession? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final mode = ServerLoginMode.values.where((m) => m.name == raw['mode']).firstOrNull;
    final base = raw['baseUrl'];
    if (mode == null || base is! String || base.isEmpty) return null;
    final issued = raw['cookieIssuedAt'];
    return ServerSession(
      mode: mode,
      baseUrl: base,
      username: raw['username']?.toString() ?? '',
      accessToken: raw['accessToken']?.toString() ?? '',
      refreshToken: raw['refreshToken']?.toString() ?? '',
      password: raw['password']?.toString() ?? '',
      cookie: raw['cookie']?.toString() ?? '',
      cookieIssuedAt: issued is int ? DateTime.fromMillisecondsSinceEpoch(issued) : null,
    );
  }
}

/// Storage seam (tests inject [InMemoryServerSessionStore]).
abstract class ServerSessionStore {
  Future<String?> read();
  Future<void> write(String? value);
}

/// Secure storage, with the same prefs fallback rule as [ServerAuthHelper]:
/// plaintext is used only when the keystore write fails, and removed once a
/// secure write succeeds.
class SecureServerSessionStore implements ServerSessionStore {
  static const String storageKey = 'sunfire_server_session';

  /// Same insecure-fallback visibility as [ServerAuthHelper]: true once a
  /// session has been read from or written to plaintext prefs.
  static bool insecureFallbackActive = false;
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  const SecureServerSessionStore();

  @override
  Future<String?> read() async {
    try {
      final v = await _storage.read(key: storageKey);
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(storageKey);
      if (v != null && v.isNotEmpty) {
        insecureFallbackActive = true;
      }
      return v;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String? value) async {
    var secureOk = false;
    try {
      if (value == null) {
        await _storage.delete(key: storageKey);
      } else {
        await _storage.write(key: storageKey, value: value);
      }
      secureOk = true;
    } on Exception catch (e) {
      if (kDebugMode) debugPrint('[SecureServerSessionStore] secure write failed: $e');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (secureOk || value == null) {
        if (secureOk && value != null) insecureFallbackActive = false;
        await prefs.remove(storageKey);
      } else {
        insecureFallbackActive = true;
        await prefs.setString(storageKey, value);
      }
    } on Exception catch (e) {
      if (!secureOk) {
        throw StateError('Both secure storage and SharedPreferences failed to save session: $e');
      }
      if (kDebugMode) debugPrint('[SecureServerSessionStore] prefs cleanup failed: $e');
    }
  }
}

class InMemoryServerSessionStore implements ServerSessionStore {
  String? value;
  InMemoryServerSessionStore([this.value]);
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? v) async => value = v;
}

/// Decodes the `exp` claim (seconds) of a JWT. Null when absent/unparseable.
DateTime? jwtExpiry(String token) {
  final raw = token.startsWith('Bearer ') ? token.substring(7) : token;
  final parts = raw.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = payload is Map ? payload['exp'] : null;
    if (exp is num) return DateTime.fromMillisecondsSinceEpoch((exp * 1000).toInt(), isUtc: true);
  } catch (_) {}
  return null;
}

/// Login + JWT refresh (ISS-078). Singleton; attach with [attach] after the
/// transports are initialized (main.dart / background isolate do this via
/// [restore]).
class ServerSessionService implements ServerAuthRefresher {
  ServerSessionService._();
  static final ServerSessionService instance = ServerSessionService._();

  @visibleForTesting
  ServerSessionStore store = const SecureServerSessionStore();

  /// Replace the HTTP adapter of the login client (tests only).
  @visibleForTesting
  HttpClientAdapter? debugHttpAdapter;

  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  /// Refresh this long before the access token's `exp`.
  @visibleForTesting
  Duration refreshSkew = const Duration(seconds: 60);

  /// SIMPLE_LOGIN cookies are re-issued after this age (server idle ~30m).
  @visibleForTesting
  Duration simpleLoginMaxAge = const Duration(minutes: 25);

  /// After a failed refresh, do not retry for this long (no 401 storms).
  @visibleForTesting
  Duration failedRefreshCooldown = const Duration(seconds: 15);

  ServerSession? _session;
  Future<bool>? _refreshInFlight;
  DateTime? _lastFailedRefreshAt;

  /// True while a session exists for the configured server.
  final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

  /// True when the session could not be refreshed (refresh token expired /
  /// revoked, password changed). UIS shows the login form when this flips.
  final ValueNotifier<bool> needsLoginNotifier = ValueNotifier(false);

  ServerSession? get session => _session;
  bool get isLoggedIn => _session != null;
  ServerLoginMode? get mode => _session?.mode;
  String? get username => _session?.username;

  /// Access-token expiry (UI_LOGIN), from the JWT `exp` claim.
  DateTime? get accessTokenExpiry {
    final s = _session;
    if (s == null || s.mode != ServerLoginMode.uiLogin || s.accessToken.isEmpty) return null;
    return jwtExpiry(s.accessToken);
  }

  /// Whether the access token (or SIMPLE_LOGIN cookie) should be refreshed now.
  bool get isNearExpiry {
    final s = _session;
    if (s == null) return false;
    final now = clock().toUtc();
    switch (s.mode) {
      case ServerLoginMode.uiLogin:
        final exp = accessTokenExpiry;
        return exp != null && !now.isBefore(exp.subtract(refreshSkew));
      case ServerLoginMode.simpleLogin:
        final at = s.cookieIssuedAt;
        return at == null || now.difference(at.toUtc()) >= simpleLoginMaxAge;
    }
  }

  static String _normalizeBase(String url) {
    final t = url.trim();
    return t.endsWith('/') ? t.substring(0, t.length - 1) : t;
  }

  Dio _client(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
    ));
    final injected = debugHttpAdapter;
    if (injected != null) {
      dio.httpClientAdapter = injected;
    } else {
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () => createServerTrustingHttpClient(() => baseUrl);
      }
    }
    return dio;
  }

  // ---------------------------------------------------------------------------
  // Public API (UIS login form)
  // ---------------------------------------------------------------------------

  /// Loads a persisted session for the configured server and attaches it to
  /// the GraphQL + WebSocket transports. Call once after they are initialized.
  Future<void> restore() async {
    attach();
    final base = GraphQLClientService.instance.baseUrl;
    ServerSession? loaded;
    try {
      final raw = await store.read();
      if (raw != null && raw.isNotEmpty) loaded = ServerSession.fromJson(jsonDecode(raw));
    } catch (_) {}
    if (loaded == null || base == null || _normalizeBase(loaded.baseUrl) != _normalizeBase(base)) {
      _session = null;
      isLoggedInNotifier.value = false;
      return;
    }
    _session = loaded;
    isLoggedInNotifier.value = true;
    _applyToTransports();
  }

  /// Registers this service as the transports' auth hook (idempotent).
  void attach() {
    GraphQLClientService.instance.authRefresher = this;
    WebSocketService.instance.authRefresher = this;
  }

  /// Logs in against the configured server (or [baseUrl]).
  ///
  /// [mode] defaults to the probed/known authMode via [loginModeForAuthMode];
  /// pass it explicitly from the form when the server cannot be queried yet.
  /// On success the session is persisted (secure storage), applied to GraphQL
  /// + WS (WS reconnects with the new credentials), and the auth error clears.
  Future<ServerLoginResult> login({
    required String username,
    required String password,
    ServerLoginMode mode = ServerLoginMode.uiLogin,
    String? baseUrl,
  }) async {
    final base = _normalizeBase(baseUrl ?? GraphQLClientService.instance.baseUrl ?? '');
    if (base.isEmpty) return const ServerLoginResult.failed('No server configured');
    if (username.trim().isEmpty || password.isEmpty) {
      return const ServerLoginResult.failed('Username and password are required', invalidCredentials: true);
    }
    final ServerLoginResult result;
    final ServerSession? session;
    switch (mode) {
      case ServerLoginMode.uiLogin:
        (result, session) = await _jwtLogin(base, username.trim(), password);
      case ServerLoginMode.simpleLogin:
        (result, session) = await _simpleLogin(base, username.trim(), password);
    }
    if (!result.success || session == null) return result;
    attach();
    _session = session;
    _lastFailedRefreshAt = null;
    needsLoginNotifier.value = false;
    isLoggedInNotifier.value = true;
    await _persist();
    _applyToTransports();
    GraphQLClientService.instance.clearAuthError();
    return result;
  }

  /// Forces a refresh now (JWT refresh / SIMPLE_LOGIN re-login). Single-flight.
  /// Returns false when there is no session or it could not be renewed.
  Future<bool> refresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;
    final f = _doRefresh();
    _refreshInFlight = f;
    return f.whenComplete(() => _refreshInFlight = null);
  }

  /// Drops the session (local only — Suwayomi has no server-side logout for
  /// JWTs) and restores the stored Basic/Bearer header on both transports.
  Future<void> logout() async {
    _session = null;
    isLoggedInNotifier.value = false;
    needsLoginNotifier.value = false;
    await store.write(null);
    final stored = await ServerAuthHelper.getRawAuthHeader();
    final header = stored.trim().isEmpty ? null : stored.trim();
    GraphQLClientService.instance.updateAuthToken(header, extraHeaders: const {});
    WebSocketService.instance.updateAuth(header, extraHeaders: const {});
  }

  // ---------------------------------------------------------------------------
  // ServerAuthRefresher
  // ---------------------------------------------------------------------------

  @override
  String? authHeaderOverride(String baseUrl) {
    final s = _sessionFor(baseUrl);
    if (s == null || s.mode != ServerLoginMode.uiLogin || s.accessToken.isEmpty) return null;
    return 'Bearer ${s.accessToken}';
  }

  @override
  Map<String, String> extraHeaders(String baseUrl) {
    final s = _sessionFor(baseUrl);
    if (s == null || s.mode != ServerLoginMode.simpleLogin || s.cookie.isEmpty) return const {};
    return {'Cookie': s.cookie};
  }

  @override
  Future<void> beforeRequest() async {
    if (_session == null || !isNearExpiry || _inCooldown) return;
    try {
      await refresh();
    } catch (_) {}
  }

  @override
  Future<bool> onUnauthorized() async {
    if (_session == null || _inCooldown) return false;
    try {
      return await refresh();
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  bool get _inCooldown {
    final at = _lastFailedRefreshAt;
    return at != null && clock().difference(at) < failedRefreshCooldown;
  }

  ServerSession? _sessionFor(String baseUrl) {
    final s = _session;
    if (s == null) return null;
    return _normalizeBase(s.baseUrl) == _normalizeBase(baseUrl) ? s : null;
  }

  Future<void> _persist() async {
    final s = _session;
    try {
      await store.write(s == null ? null : jsonEncode(s.toJson()));
    } catch (_) {}
  }

  void _applyToTransports() {
    final s = _session;
    if (s == null) return;
    final gql = GraphQLClientService.instance;
    final current = gql.baseUrl;
    if (current == null || _normalizeBase(current) != _normalizeBase(s.baseUrl)) return;
    final header = authHeaderOverride(s.baseUrl) ?? gql.currentAuthHeader;
    final extra = extraHeaders(s.baseUrl);
    gql.updateAuthToken(header, extraHeaders: extra);
    WebSocketService.instance.updateAuth(header, extraHeaders: extra);
  }

  Future<bool> _doRefresh() async {
    final s = _session;
    if (s == null) return false;
    var ok = false;
    String? failure;
    var credentialsDead = false;
    switch (s.mode) {
      case ServerLoginMode.uiLogin:
        if (s.refreshToken.isEmpty) {
          credentialsDead = true;
          break;
        }
        try {
          final res = await _client(s.baseUrl).post<dynamic>(
            '/api/graphql',
            data: jsonEncode({
              'query': r'mutation($t: String!) { refreshToken(input: { refreshToken: $t }) { accessToken } }',
              'variables': {'t': s.refreshToken},
            }),
            options: Options(headers: {'Content-Type': 'application/json'}),
          );
          final body = _decode(res.data);
          final token = ((body?['data'] as Map?)?['refreshToken'] as Map?)?['accessToken'];
          if (token is String && token.isNotEmpty) {
            _session = s.copyWith(accessToken: token);
            ok = true;
          } else {
            failure = _graphQLError(body) ?? 'refreshToken returned no token';
            // The server answered and refused: refresh token expired/revoked.
            credentialsDead = body?['errors'] != null;
          }
        } on DioException catch (e) {
          failure = e.message ?? e.type.name;
          final code = e.response?.statusCode ?? 0;
          credentialsDead = code == 400 || code == 401 || code == 403;
        } catch (e) {
          failure = '$e';
        }
      case ServerLoginMode.simpleLogin:
        final (result, renewed) = await _simpleLogin(s.baseUrl, s.username, s.password);
        if (result.success && renewed != null) {
          _session = renewed;
          ok = true;
        } else {
          failure = result.error;
          credentialsDead = result.invalidCredentials;
        }
    }
    if (ok) {
      _lastFailedRefreshAt = null;
      needsLoginNotifier.value = false;
      await _persist();
      _applyToTransports();
      return true;
    }
    _lastFailedRefreshAt = clock();
    if (credentialsDead) needsLoginNotifier.value = true;
    unawaited(LoggerService.instance.logWarning(
      'Server session refresh failed (${s.mode.name}): ${failure ?? 'unknown'}',
      'ServerSession',
    ));
    return false;
  }

  Future<(ServerLoginResult, ServerSession?)> _jwtLogin(String base, String username, String password) async {
    try {
      // No Authorization header on purpose: Suwayomi rejects `login` from an
      // already-authenticated caller.
      final res = await _client(base).post<dynamic>(
        '/api/graphql',
        data: jsonEncode({
          'query': r'mutation($u: String!, $p: String!) { login(input: { username: $u, password: $p }) { accessToken refreshToken } }',
          'variables': {'u': username, 'p': password},
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final body = _decode(res.data);
      final payload = (body?['data'] as Map?)?['login'] as Map?;
      final access = payload?['accessToken'];
      final refresh = payload?['refreshToken'];
      if (access is String && access.isNotEmpty && refresh is String && refresh.isNotEmpty) {
        return (
          const ServerLoginResult.ok(),
          ServerSession(
            mode: ServerLoginMode.uiLogin,
            baseUrl: base,
            username: username,
            accessToken: access,
            refreshToken: refresh,
          ),
        );
      }
      final err = _graphQLError(body);
      return (
        ServerLoginResult.failed(err ?? 'Login failed', invalidCredentials: err != null),
        null,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return (const ServerLoginResult.failed('Server rejected the login', invalidCredentials: true), null);
      }
      return (ServerLoginResult.failed('Could not reach the server: ${e.message ?? e.type.name}'), null);
    } catch (e) {
      return (ServerLoginResult.failed('Login failed: $e'), null);
    }
  }

  Future<(ServerLoginResult, ServerSession?)> _simpleLogin(String base, String username, String password) async {
    try {
      final res = await _client(base).post<dynamic>(
        '/login.html',
        data: {'user': username, 'pass': password},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (c) => c != null && c < 500,
          responseType: ResponseType.plain,
        ),
      );
      // Success = 303 See Other + session cookie. A 200 re-renders the form
      // with "Invalid username or password".
      final cookies = res.headers.map['set-cookie'] ?? const <String>[];
      final cookie = cookies
          .map((c) => c.split(';').first.trim())
          .where((c) => c.contains('=') && c.split('=').last.isNotEmpty)
          .join('; ');
      final redirected = (res.statusCode ?? 0) >= 300 && (res.statusCode ?? 0) < 400;
      if (redirected && cookie.isNotEmpty) {
        return (
          const ServerLoginResult.ok(),
          ServerSession(
            mode: ServerLoginMode.simpleLogin,
            baseUrl: base,
            username: username,
            password: password,
            cookie: cookie,
            cookieIssuedAt: clock(),
          ),
        );
      }
      return (const ServerLoginResult.failed('Invalid username or password', invalidCredentials: true), null);
    } on DioException catch (e) {
      return (ServerLoginResult.failed('Could not reach the server: ${e.message ?? e.type.name}'), null);
    } catch (e) {
      return (ServerLoginResult.failed('Login failed: $e'), null);
    }
  }

  static Map<String, dynamic>? _decode(Object? data) {
    Object? d = data;
    if (d is String) {
      try {
        d = jsonDecode(d);
      } catch (_) {
        return null;
      }
    }
    return d is Map ? Map<String, dynamic>.from(d) : null;
  }

  static String? _graphQLError(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      return first is Map ? first['message']?.toString() : first.toString();
    }
    return null;
  }

  /// Test reset.
  @visibleForTesting
  void debugReset() {
    _session = null;
    _refreshInFlight = null;
    _lastFailedRefreshAt = null;
    isLoggedInNotifier.value = false;
    needsLoginNotifier.value = false;
    debugHttpAdapter = null;
    store = InMemoryServerSessionStore();
    clock = DateTime.now;
    if (identical(GraphQLClientService.instance.authRefresher, this)) {
      GraphQLClientService.instance.authRefresher = null;
    }
    if (identical(WebSocketService.instance.authRefresher, this)) {
      WebSocketService.instance.authRefresher = null;
    }
  }
}
