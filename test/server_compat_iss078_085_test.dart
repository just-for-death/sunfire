import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_session_service.dart';

class _Reply {
  _Reply(this.body, {this.status = 200, this.headers = const {}});
  final Object body;
  final int status;
  final Map<String, List<String>> headers;
}

class _Req {
  _Req(this.options, this.raw);
  final RequestOptions options;
  final String raw;
  String get path => options.uri.path;
  String? get auth => options.headers['Authorization']?.toString();
  Map<String, dynamic> get json => jsonDecode(raw) as Map<String, dynamic>;
  String get gql => (json['query'] as String?) ?? '';
}

/// Scripted adapter shared by the GraphQL client and the login client.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final FutureOr<_Reply> Function(_Req r) handler;
  final List<_Req> log = [];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    String raw;
    if (o.data is String) {
      raw = o.data as String;
    } else if (requestStream != null) {
      final bytes = <int>[];
      await for (final c in requestStream) {
        bytes.addAll(c);
      }
      raw = utf8.decode(bytes, allowMalformed: true);
    } else {
      raw = o.data == null ? '' : jsonEncode(o.data);
    }
    final r = _Req(o, raw);
    log.add(r);
    final reply = await handler(r);
    final body = reply.body is String ? reply.body as String : jsonEncode(reply.body);
    return ResponseBody.fromString(body, reply.status, headers: {
      'content-type': [reply.body is String ? 'text/html' : Headers.jsonContentType],
      ...reply.headers,
    });
  }

  @override
  void close({bool force = false}) {}
}

String _jwt(DateTime exp, {String type = 'access'}) {
  String b64(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${b64({'alg': 'HS256'})}.${b64({'exp': exp.millisecondsSinceEpoch ~/ 1000, 'token_type': type})}.sig';
}

const _base = 'http://mock.invalid';

GraphQLClientService _client(_Adapter a, {String? auth}) {
  final c = GraphQLClientService.instance;
  c.initialize(_base, authToken: auth);
  c.debugHttpAdapter = a;
  c.retryDelay = (_) => Duration.zero;
  return c;
}

final _captured = <String>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ServerSessionService.instance.debugReset();
  });

  tearDown(() {
    ServerSessionService.instance.debugReset();
    GraphQLClientService.instance.initialize('');
  });

  tearDownAll(() {
    final path = Platform.environment['SUNFIRE_DUMP_GQL'];
    if (path != null) File(path).writeAsStringSync(jsonEncode(_captured));
  });

  void capture(_Adapter a) {
    for (final r in a.log) {
      if (r.path.endsWith('/api/graphql') && r.raw.startsWith('{')) _captured.add(r.gql);
    }
  }

  group('ISS-078 B2 login + JWT refresh', () {
    test('jwtExpiry decodes exp; loginModeForAuthMode maps enums', () {
      final exp = DateTime.utc(2030, 1, 2, 3, 4, 5);
      expect(jwtExpiry(_jwt(exp)), exp);
      expect(jwtExpiry('Bearer ${_jwt(exp)}'), exp);
      expect(jwtExpiry('garbage'), isNull);
      expect(loginModeForAuthMode('UI_LOGIN'), ServerLoginMode.uiLogin);
      expect(loginModeForAuthMode('SIMPLE_LOGIN'), ServerLoginMode.simpleLogin);
      expect(loginModeForAuthMode('NONE'), isNull);
      expect(loginModeForAuthMode('BASIC_AUTH'), isNull);
    });

    test('UI_LOGIN login sends no Authorization, stores tokens, applies Bearer', () async {
      final access = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      final a = _Adapter((r) {
        if (r.gql.contains('login(')) {
          return _Reply({
            'data': {
              'login': {'accessToken': access, 'refreshToken': 'R1'},
            },
          });
        }
        return _Reply({
          'data': {'aboutServer': {'version': 'v'}},
        });
      });
      final c = _client(a, auth: 'Basic dTpw');
      final store = InMemoryServerSessionStore();
      final s = ServerSessionService.instance
        ..store = store
        ..debugHttpAdapter = a;
      final res = await s.login(username: 'jane', password: 'pw');
      expect(res.success, isTrue);
      final loginReq = a.log.firstWhere((r) => r.gql.contains('login('));
      expect(loginReq.auth, isNull, reason: 'server refuses login from an authenticated caller');
      expect(loginReq.json['variables'], {'u': 'jane', 'p': 'pw'});
      expect(s.isLoggedIn, isTrue);
      expect(s.isLoggedInNotifier.value, isTrue);
      expect(c.authHeaders['Authorization'], 'Bearer $access');
      final saved = jsonDecode(store.value!) as Map<String, dynamic>;
      expect(saved['refreshToken'], 'R1');
      expect(saved['baseUrl'], _base);
      // Next GraphQL call carries the JWT.
      await c.query('{ aboutServer { version } }');
      expect(a.log.last.auth, 'Bearer $access');
      // Re-initialize (settings screen) keeps the session header.
      c.initialize(_base, authToken: 'Basic dTpw');
      c.debugHttpAdapter = a;
      expect(c.authHeaders['Authorization'], 'Bearer $access');
      capture(a);
    });

    test('bad credentials → invalidCredentials, no session', () async {
      final a = _Adapter((r) => _Reply({
            'errors': [
              {'message': 'Incorrect username or password.'},
            ],
          }));
      _client(a);
      final s = ServerSessionService.instance..debugHttpAdapter = a;
      final res = await s.login(username: 'jane', password: 'nope');
      expect(res.success, isFalse);
      expect(res.invalidCredentials, isTrue);
      expect(res.error, contains('Incorrect'));
      expect(s.isLoggedIn, isFalse);
    });

    test('401 → refreshToken → transparent retry with new token', () async {
      final oldAccess = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      final newAccess = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 10)));
      var refreshes = 0;
      final a = _Adapter((r) {
        if (r.gql.contains('refreshToken(')) {
          refreshes++;
          expect(r.json['variables'], {'t': 'R1'});
          return _Reply({
            'data': {
              'refreshToken': {'accessToken': newAccess},
            },
          });
        }
        if (r.auth == 'Bearer $oldAccess') return _Reply('Unauthorized', status: 401);
        return _Reply({
          'data': {
            'categories': {'nodes': <dynamic>[]},
          },
        });
      });
      final c = _client(a);
      final store = InMemoryServerSessionStore(jsonEncode(ServerSession(
        mode: ServerLoginMode.uiLogin,
        baseUrl: _base,
        username: 'jane',
        accessToken: oldAccess,
        refreshToken: 'R1',
      ).toJson()));
      final s = ServerSessionService.instance
        ..store = store
        ..debugHttpAdapter = a;
      await s.restore();
      expect(c.authHeaders['Authorization'], 'Bearer $oldAccess');
      final res = await c.query('mutation { x }', label: 'm');
      expect(res, isNotNull);
      expect(refreshes, 1);
      expect(a.log.last.auth, 'Bearer $newAccess');
      expect(c.hasAuthError, isFalse);
      expect((jsonDecode(store.value!) as Map)['accessToken'], newAccess);
      capture(a);
    });

    test('GraphQL "Unauthorized" error (expired token → visitor) also refreshes', () async {
      final oldAccess = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      final newAccess = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 10)));
      final a = _Adapter((r) {
        if (r.gql.contains('refreshToken(')) {
          return _Reply({
            'data': {
              'refreshToken': {'accessToken': newAccess},
            },
          });
        }
        if (r.auth == 'Bearer $oldAccess') {
          return _Reply({
            'errors': [
              {'message': 'Unauthorized'},
            ],
          });
        }
        return _Reply({
          'data': {'ok': true},
        });
      });
      final c = _client(a);
      final s = ServerSessionService.instance
        ..store = InMemoryServerSessionStore(jsonEncode(ServerSession(
          mode: ServerLoginMode.uiLogin,
          baseUrl: _base,
          accessToken: oldAccess,
          refreshToken: 'R1',
        ).toJson()))
        ..debugHttpAdapter = a;
      await s.restore();
      expect(await c.query('{ ok }'), {'ok': true});
    });

    test('near expiry refreshes proactively before the request', () async {
      final expiring = _jwt(DateTime.now().toUtc().add(const Duration(seconds: 20)));
      final fresh = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      final a = _Adapter((r) {
        if (r.gql.contains('refreshToken(')) {
          return _Reply({
            'data': {
              'refreshToken': {'accessToken': fresh},
            },
          });
        }
        return _Reply({
          'data': {'ok': true},
        });
      });
      final c = _client(a);
      final s = ServerSessionService.instance
        ..store = InMemoryServerSessionStore(jsonEncode(ServerSession(
          mode: ServerLoginMode.uiLogin,
          baseUrl: _base,
          accessToken: expiring,
          refreshToken: 'R1',
        ).toJson()))
        ..debugHttpAdapter = a;
      await s.restore();
      expect(s.isNearExpiry, isTrue);
      await c.query('{ ok }');
      expect(a.log.where((r) => r.gql.contains('refreshToken(')).length, 1);
      expect(a.log.last.auth, 'Bearer $fresh');
      expect(s.isNearExpiry, isFalse);
    });

    test('refresh rejected → needsLogin, no retry storm (single-flight + cooldown)', () async {
      final oldAccess = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      var refreshes = 0;
      final a = _Adapter((r) {
        if (r.gql.contains('refreshToken(')) {
          refreshes++;
          return _Reply({
            'errors': [
              {'message': 'The Token has expired'},
            ],
          });
        }
        return _Reply('Unauthorized', status: 401);
      });
      final c = _client(a);
      final s = ServerSessionService.instance
        ..store = InMemoryServerSessionStore(jsonEncode(ServerSession(
          mode: ServerLoginMode.uiLogin,
          baseUrl: _base,
          accessToken: oldAccess,
          refreshToken: 'R1',
        ).toJson()))
        ..debugHttpAdapter = a;
      await s.restore();
      final results = await Future.wait([c.query('{ a }'), c.query('{ b }'), c.query('{ c }')]);
      expect(results, everyElement(isNull));
      expect(refreshes, 1);
      expect(s.needsLoginNotifier.value, isTrue);
      expect(c.hasAuthError, isTrue);
    });

    test('session for another server is ignored on restore', () async {
      final a = _Adapter((r) => _Reply({'data': <String, dynamic>{}}));
      final c = _client(a, auth: 'Basic dTpw');
      final s = ServerSessionService.instance
        ..store = InMemoryServerSessionStore(jsonEncode(const ServerSession(
          mode: ServerLoginMode.uiLogin,
          baseUrl: 'http://other.invalid',
          accessToken: 'A',
          refreshToken: 'R',
        ).toJson()));
      await s.restore();
      expect(s.isLoggedIn, isFalse);
      expect(c.authHeaders['Authorization'], 'Basic dTpw');
    });

    test('SIMPLE_LOGIN posts form, keeps cookie, re-logins on 401', () async {
      var logins = 0;
      final a = _Adapter((r) {
        if (r.path.endsWith('/login.html')) {
          logins++;
          expect(r.options.contentType, contains('x-www-form-urlencoded'));
          expect(r.raw, contains('user=jane'));
          expect(r.raw, contains('pass=pw'));
          return _Reply('', status: 303, headers: {
            'set-cookie': ['JSESSIONID=node0abc$logins; Path=/; HttpOnly'],
            'location': ['/'],
          });
        }
        if (r.options.headers['Cookie'] == 'JSESSIONID=node0abc1') {
          return _Reply({
            'errors': [
              {'message': 'Unauthorized'},
            ],
          });
        }
        return _Reply({
          'data': {'ok': true},
        });
      });
      final c = _client(a, auth: null);
      final s = ServerSessionService.instance..debugHttpAdapter = a;
      final res = await s.login(username: 'jane', password: 'pw', mode: ServerLoginMode.simpleLogin);
      expect(res.success, isTrue);
      expect(c.authHeaders['Cookie'], 'JSESSIONID=node0abc1');
      expect(c.authHeaders.containsKey('Authorization'), isFalse);
      expect(await c.query('{ ok }'), {'ok': true});
      expect(logins, 2);
      expect(a.log.last.options.headers['Cookie'], 'JSESSIONID=node0abc2');
    });

    test('SIMPLE_LOGIN wrong password (200 login page) → invalidCredentials', () async {
      final a = _Adapter((r) => _Reply('<html>Invalid username or password</html>'));
      _client(a);
      final s = ServerSessionService.instance..debugHttpAdapter = a;
      final res = await s.login(username: 'jane', password: 'x', mode: ServerLoginMode.simpleLogin);
      expect(res.success, isFalse);
      expect(res.invalidCredentials, isTrue);
    });

    test('logout drops session and restores stored header', () async {
      final access = _jwt(DateTime.now().toUtc().add(const Duration(minutes: 5)));
      final a = _Adapter((r) => _Reply({
            'data': {
              'login': {'accessToken': access, 'refreshToken': 'R'},
            },
          }));
      final c = _client(a);
      final store = InMemoryServerSessionStore();
      final s = ServerSessionService.instance
        ..store = store
        ..debugHttpAdapter = a;
      expect((await s.login(username: 'u', password: 'p')).success, isTrue);
      await s.logout();
      expect(s.isLoggedIn, isFalse);
      expect(store.value, isNull);
      expect(c.authHeaders.containsKey('Authorization'), isFalse);
    });

    test('no session → refresher inert, Basic untouched (authMode NONE/BASIC)', () async {
      final a = _Adapter((r) => _Reply('nope', status: 401));
      final c = _client(a, auth: 'Basic dTpw');
      ServerSessionService.instance.attach();
      expect(await c.query('{ x }'), isNull);
      expect(a.log.length, 1, reason: 'no refresh/retry without a session');
      expect(a.log.single.auth, 'Basic dTpw');
    });
  });

  group('ISS-079 B4 source filters / preferences', () {
    final filtersJson = [
      {'__typename': 'HeaderFilter', 'name': 'Note'},
      {'__typename': 'SelectFilter', 'name': 'Type', 'selectDefault': 1, 'values': ['A', 'B']},
      {'__typename': 'TextFilter', 'name': 'Author', 'textDefault': ''},
      {
        '__typename': 'SortFilter',
        'name': 'Sort',
        'sortDefault': {'index': 2, 'ascending': false},
        'values': ['x', 'y', 'z'],
      },
      {
        '__typename': 'GroupFilter',
        'name': 'Genres',
        'filters': [
          {'__typename': 'TriStateFilter', 'name': 'Action', 'triStateDefault': 'IGNORE'},
          {'__typename': 'CheckBoxFilter', 'name': 'Completed', 'checkBoxDefault': true},
        ],
      },
      {'__typename': 'SeparatorFilter', 'name': ''},
    ];
    final prefsJson = [
      {'__typename': 'CheckBoxPreference', 'key': 'a', 'title': 'A', 'visible': true, 'enabled': true, 'checkBoxCurrent': null, 'checkBoxDefault': true},
      {'__typename': 'SwitchPreference', 'key': 'b', 'visible': true, 'enabled': true, 'switchCurrent': false, 'switchDefault': true},
      {'__typename': 'EditTextPreference', 'key': 'c', 'visible': true, 'enabled': true, 'editTextCurrent': 'hi', 'editTextDefault': ''},
      {
        '__typename': 'ListPreference',
        'key': 'd',
        'visible': true,
        'enabled': true,
        'entries': ['One', 'Two'],
        'entryValues': ['1', '2'],
        'listCurrent': '2',
        'listDefault': '1',
      },
      {
        '__typename': 'MultiSelectListPreference',
        'key': 'e',
        'visible': false,
        'enabled': true,
        'entries': ['X', 'Y'],
        'entryValues': ['x', 'y'],
        'multiCurrent': null,
        'multiDefault': ['x'],
      },
    ];

    test('parse filters (positions, group children, defaults)', () {
      final f = parseSourceFilters(filtersJson);
      expect(f.map((e) => e.kind).toList(), [
        SourceFilterKind.header,
        SourceFilterKind.select,
        SourceFilterKind.text,
        SourceFilterKind.sort,
        SourceFilterKind.group,
        SourceFilterKind.separator,
      ]);
      expect(f[1].selectDefault, 1);
      expect(f[1].values, ['A', 'B']);
      expect(f[3].sortDefault, const SortSelectionValue(index: 2, ascending: false));
      expect(f[4].children[0].triStateDefault, TriStateValue.ignore);
      expect(f[4].children[1].position, 1);
      expect(f[4].children[1].checkBoxDefault, isTrue);
      expect(f[0].isInteractive, isFalse);
    });

    test('FilterChangeInput builders incl. groupChange', () {
      expect(const SourceFilterChange.select(1, 0).toInput(), {'position': 1, 'selectState': 0});
      expect(SourceFilterChange.sort(3, index: 1, ascending: true).toInput(), {
        'position': 3,
        'sortState': {'index': 1, 'ascending': true},
      });
      expect(const SourceFilterChange.group(4, SourceFilterChange.triState(0, TriStateValue.exclude)).toInput(), {
        'position': 4,
        'groupChange': {'position': 0, 'triState': 'EXCLUDE'},
      });
    });

    test('parse preferences + change builders', () {
      final p = parseSourcePreferences(prefsJson);
      expect(p[0].boolValue, isTrue, reason: 'null current falls back to default');
      expect(p[1].boolValue, isFalse);
      expect(p[2].stringValue, 'hi');
      expect(p[3].selectedEntryLabel, 'Two');
      expect(p[4].listValue, ['x']);
      expect(p[4].visible, isFalse);
      expect(SourcePreferenceChange.forPreference(p[1], true).toInput(), {'position': 1, 'switchState': true});
      expect(SourcePreferenceChange.forPreference(p[4], {'y'}).toInput(), {
        'position': 4,
        'multiSelectState': ['y'],
      });
      expect(() => SourcePreferenceChange.forPreference(p[0], 'x'), throwsArgumentError);
    });

    test('fetchSourceFiltersAndPreferences / updateSourcePreference / fetchSourceManga(filters:)', () async {
      final a = _Adapter((r) {
        if (r.gql.contains('updateSourcePreference')) {
          return _Reply({
            'data': {
              'updateSourcePreference': {'preferences': prefsJson},
            },
          });
        }
        if (r.gql.contains('fetchSourceManga')) {
          return _Reply({
            'data': {
              'fetchSourceManga': {'mangas': <dynamic>[], 'hasNextPage': false},
            },
          });
        }
        return _Reply({
          'data': {
            'source': {
              'id': '42',
              'name': 'S',
              'displayName': 'S (EN)',
              'isConfigurable': true,
              'supportsLatest': true,
              'filters': filtersJson,
              'preferences': prefsJson,
            },
          },
        });
      });
      final c = _client(a);
      final fp = await c.fetchSourceFiltersAndPreferences('42');
      expect(fp!.name, 'S (EN)');
      expect(fp.filters.length, 6);
      expect(fp.preferences.length, 5);
      expect(a.log.last.gql, contains('checkBoxDefault: default'));
      expect(a.log.last.json['variables'], {'id': '42'});
      expect(await c.fetchSourceFilters('42'), hasLength(6));
      expect(await c.fetchSourcePreferences('42'), hasLength(5));

      final prefs = await c.updateSourcePreference('42', const SourcePreferenceChange.list(3, '1'));
      expect(prefs, hasLength(5));
      expect(a.log.last.json['variables'], {
        'source': '42',
        'change': {'position': 3, 'listState': '1'},
      });

      await c.fetchSourceManga('42', filters: [const SourceFilterChange.select(1, 0)]);
      expect(a.log.last.json['variables'], {
        'source': '42',
        'type': 'SEARCH',
        'page': 1,
        'filters': [
          {'position': 1, 'selectState': 0},
        ],
      });
      await c.fetchSourceManga('42', isLatest: true, page: 2);
      expect(a.log.last.json['variables'], {'source': '42', 'type': 'LATEST', 'page': 2});
      await c.fetchSourceManga('42', searchQuery: ' one ');
      expect(a.log.last.json['variables'], {'source': '42', 'type': 'SEARCH', 'page': 1, 'query': 'one'});
      capture(a);
    });
  });

  group('ISS-081 B7 extension stores', () {
    test('fetch / add / remove / refresh / per-store', () async {
      final store = {
        'indexUrl': 'https://x/index.pb',
        'name': 'Keiyoushi',
        'badgeLabel': 'KEI',
        'isLegacy': false,
        'contactWebsite': 'https://k',
        'contactDiscord': null,
        'extensionListUrl': null,
        'signingKey': 'abc',
        'extensions': {'totalCount': 3},
      };
      final a = _Adapter((r) {
        final q = r.gql;
        if (q.contains('addExtensionStore')) {
          return _Reply({
            'data': {
              'addExtensionStore': {'extensionStore': store},
            },
          });
        }
        if (q.contains('removeExtensionStore')) {
          return _Reply({
            'data': {
              'removeExtensionStore': {'extensionStore': {'indexUrl': 'https://x/index.pb'}},
            },
          });
        }
        if (q.contains('fetchExtensions(')) {
          return _Reply({
            'data': {
              'fetchExtensions': {
                'extensionStores': [store],
                'extensions': [
                  {'pkgName': 'p', 'name': 'n', 'contentWarning': 'NSFW', 'storeIndexUrl': 'https://x/index.pb'},
                ],
              },
            },
          });
        }
        if (q.contains('ExtensionsForStore')) {
          return _Reply({
            'data': {
              'extensions': {
                'nodes': [
                  {'pkgName': 'p', 'contentWarning': 'SAFE'},
                ],
              },
            },
          });
        }
        return _Reply({
          'data': {
            'extensionStores': {'nodes': [store]},
          },
        });
      });
      final c = _client(a);
      final stores = await c.fetchExtensionStores(includeCounts: true);
      expect(stores!.single.badgeLabel, 'KEI');
      expect(stores.single.extensionCount, 3);
      expect(a.log.last.gql, contains('totalCount'));

      final added = await c.addExtensionStore('  https://x/index.pb ');
      expect(added!.name, 'Keiyoushi');
      expect(a.log.last.json['variables'], {'indexUrl': 'https://x/index.pb'});
      expect(await c.addExtensionStore('  '), isNull);

      expect(await c.removeExtensionStore('https://x/index.pb'), isTrue);

      final refreshed = await c.refreshExtensionStores();
      expect(refreshed!.stores.single.indexUrl, 'https://x/index.pb');
      expect(refreshed.extensions.single['isNsfw'], isTrue);
      expect(refreshed.extensions.single['storeIndexUrl'], 'https://x/index.pb');

      final per = await c.fetchExtensionsForStore('https://x/index.pb');
      expect(((per!['extensions'] as Map)['nodes'] as List).single['isNsfw'], isFalse);
      expect(a.log.last.json['variables'], {'url': 'https://x/index.pb'});
      capture(a);
    });

    test('remove failure → false; add GraphQL error → null', () async {
      final a = _Adapter((r) => _Reply({
            'errors': [
              {'message': 'Invalid index'},
            ],
          }));
      final c = _client(a);
      expect(await c.addExtensionStore('https://bad'), isNull);
      expect(await c.removeExtensionStore('https://bad'), isFalse);
    });
  });

  group('ISS-082 B8 backup validate / restore', () {
    test('validateBackup uses GraphQL multipart spec', () async {
      final a = _Adapter((r) => _Reply({
            'data': {
              'validateBackup': {
                'missingSources': [
                  {'id': '123', 'name': 'MangaDex'},
                ],
                'missingTrackers': [
                  {'name': 'MyAnimeList'},
                ],
              },
            },
          }));
      final c = _client(a);
      final v = await c.validateBackup([1, 2, 3], filename: 'b.tachibk');
      expect(v!.isClean, isFalse);
      expect(v.missingSources.single, (id: '123', name: 'MangaDex'));
      expect(v.missingTrackers, ['MyAnimeList']);
      final req = a.log.single;
      expect(req.options.contentType, startsWith('multipart/form-data; boundary='));
      expect(req.raw, contains('name="operations"'));
      expect(req.raw, contains('"variables":{"backup":null}'));
      expect(req.raw, contains('name="map"'));
      expect(req.raw, contains('{"0":["variables.backup"]}'));
      expect(req.raw, contains('filename="b.tachibk"'));
      final ops = RegExp(r'name="operations"\r\n\r\n(.*?)\r\n', dotAll: true).firstMatch(req.raw)!.group(1)!;
      _captured.add((jsonDecode(ops) as Map)['query'] as String);
    });

    test('restoreBackupAndWait polls restoreStatus to SUCCESS', () async {
      final states = [
        {'state': 'RESTORING_CATEGORIES', 'mangaProgress': 0, 'totalManga': 10},
        {'state': 'RESTORING_MANGA', 'mangaProgress': 5, 'totalManga': 10},
        {'state': 'RESTORING_MANGA', 'mangaProgress': 5, 'totalManga': 10},
        {'state': 'SUCCESS', 'mangaProgress': 10, 'totalManga': 10},
      ];
      var poll = 0;
      final a = _Adapter((r) {
        if (r.raw.contains('restoreBackup')) {
          expect(r.raw, contains('"flags":{"includeTracking":false}'));
          return _Reply({
            'data': {
              'restoreBackup': {
                'id': 'job-1',
                'status': {'state': 'IDLE', 'mangaProgress': 0, 'totalManga': 0},
              },
            },
          });
        }
        expect(r.json['variables'], {'restoreId': 'job-1'});
        return _Reply({
          'data': {'restoreStatus': states[poll++]},
        });
      });
      final c = _client(a);
      final seen = <BackupRestoreStatusInfo>[];
      final last = await c.restoreBackupAndWait(
        [9, 9],
        flags: const BackupFlags(includeTracking: false),
        onProgress: seen.add,
        interval: Duration.zero,
      );
      expect(last!.isSuccess, isTrue);
      expect(seen.map((s) => s.state).toList(), ['IDLE', 'RESTORING_CATEGORIES', 'RESTORING_MANGA', 'SUCCESS']);
      expect(seen[2].progress, 0.5);
      expect(poll, 4);
      final restoreReq = a.log.first;
      final ops = RegExp(r'name="operations"\r\n\r\n(.*?)\r\n', dotAll: true).firstMatch(restoreReq.raw)!.group(1)!;
      _captured.add((jsonDecode(ops) as Map)['query'] as String);
      capture(a);
    });

    test('watchRestoreStatus stops after repeated null polls', () async {
      final a = _Adapter((r) => _Reply({
            'data': {'restoreStatus': null},
          }));
      final c = _client(a);
      final events = await c.watchRestoreStatus('x', interval: Duration.zero, maxConsecutiveFailures: 3).toList();
      expect(events, isEmpty);
    });

    test('restoreBackup failure → null', () async {
      final a = _Adapter((r) => _Reply('boom', status: 500));
      final c = _client(a);
      expect(await c.restoreBackup([1]), isNull);
    });
  });

  group('ISS-083 B10 trackers', () {
    test('fetchTrackerInfos / fetchTrackRecordInfos / private flags', () async {
      final a = _Adapter((r) {
        final q = r.gql;
        if (q.contains('trackers')) {
          return _Reply({
            'data': {
              'trackers': {
                'nodes': [
                  {
                    'id': 1,
                    'name': 'MyAnimeList',
                    'icon': 'i',
                    'authUrl': 'https://auth',
                    'isLoggedIn': true,
                    'isTokenExpired': true,
                    'supportsPrivateTracking': true,
                    'supportsReadingDates': true,
                    'supportsTrackDeletion': false,
                    'scores': ['10', '9', '0'],
                    'statuses': [
                      {'name': 'Reading', 'value': 1},
                      {'name': 'Completed', 'value': 2},
                    ],
                  },
                ],
              },
            },
          });
        }
        if (q.contains('TrackRecordInfos')) {
          return _Reply({
            'data': {
              'trackRecords': {
                'nodes': [
                  {'id': 7, 'mangaId': 3, 'trackerId': 1, 'status': 2, 'score': 9.0, 'displayScore': '9', 'private': true, 'lastChapterRead': 12.5},
                ],
              },
            },
          });
        }
        return _Reply({
          'data': {
            'updateTrack': {'clientMutationId': null},
            'bindTrack': {'clientMutationId': null},
          },
        });
      });
      final c = _client(a);
      final t = (await c.fetchTrackerInfos())!.single;
      expect(t.needsReLogin, isTrue);
      expect(t.scores, ['10', '9', '0']);
      expect(t.statusName(2), 'Completed');
      expect(t.supportsPrivateTracking, isTrue);
      final rec = (await c.fetchTrackRecordInfos(3))!.single;
      expect(rec.isPrivate, isTrue);
      expect(rec.displayScore, '9');
      expect(rec.lastChapterRead, 12.5);

      expect(await c.setTrackRecordPrivate(7, false), isTrue);
      expect(a.log.last.json['variables'], {'recordId': 7, 'private': false});

      await c.updateTrack(recordId: 7, lastChapterRead: 3, status: 2);
      expect(a.log.last.gql, isNot(contains('private')), reason: 'old servers lack UpdateTrackInput.private');
      await c.updateTrack(recordId: 7, lastChapterRead: 3, isPrivate: true);
      expect(a.log.last.gql, contains(r'private: $private'));
      expect(a.log.last.json['variables']['private'], isTrue);
      await c.bindTrack(3, 1, 99, isPrivate: true);
      expect(a.log.last.json['variables'], {'mangaId': 3, 'trackerId': 1, 'remoteId': '99', 'private': true});
      await c.bindTrack(3, 1, 99);
      expect(a.log.last.gql, isNot(contains('private')));
      capture(a);
    });
  });

  group('ISS-085 B14 KOReader / SyncYomi', () {
    test('koSync status/connect/logout/pull/push + startSync/lastSyncStatus', () async {
      final a = _Adapter((r) {
        final q = r.gql;
        if (q.contains('connectKoSyncAccount')) {
          return _Reply({
            'data': {
              'connectKoSyncAccount': {
                'message': 'ok',
                'status': {'isLoggedIn': true, 'serverAddress': 'https://ko', 'username': 'jane'},
              },
            },
          });
        }
        if (q.contains('logoutKoSyncAccount')) {
          return _Reply({
            'data': {
              'logoutKoSyncAccount': {
                'status': {'isLoggedIn': false},
              },
            },
          });
        }
        if (q.contains('pullKoSyncProgress')) {
          return _Reply({
            'data': {
              'pullKoSyncProgress': {
                'chapter': {'id': 5, 'lastPageRead': 7, 'isRead': false, 'lastReadAt': '1'},
                'syncConflict': {'deviceName': 'Kobo', 'remotePage': 9},
              },
            },
          });
        }
        if (q.contains('pushKoSyncProgress')) {
          return _Reply({
            'data': {
              'pushKoSyncProgress': {'success': true},
            },
          });
        }
        if (q.contains('startSync')) {
          return _Reply({
            'data': {
              'startSync': {'result': 'SYNC_DISABLED'},
            },
          });
        }
        if (q.contains('lastSyncStatus')) {
          return _Reply({
            'data': {
              'lastSyncStatus': {'state': 'SUCCESS', 'startDate': '1'},
            },
          });
        }
        return _Reply({
          'data': {
            'koSyncStatus': {'isLoggedIn': false, 'serverAddress': null, 'username': null},
          },
        });
      });
      final c = _client(a);
      expect((await c.fetchKoSyncStatus())!.isLoggedIn, isFalse);
      final conn = await c.connectKoSyncAccount(serverAddress: ' https://ko ', username: 'jane', password: 'pw');
      expect(conn!.isLoggedIn, isTrue);
      expect(conn.message, 'ok');
      expect(a.log.last.json['variables'], {'serverAddress': 'https://ko', 'username': 'jane', 'password': 'pw'});
      expect((await c.logoutKoSyncAccount())!.isLoggedIn, isFalse);
      final pull = await c.pullKoSyncProgress(5);
      expect(pull!.chapter!['lastPageRead'], 7);
      expect(pull.conflict, (deviceName: 'Kobo', remotePage: 9));
      expect(await c.pushKoSyncProgress(5), isTrue);
      expect(await c.startSyncYomi(), 'SYNC_DISABLED');
      expect((await c.fetchLastSyncStatus())!['state'], 'SUCCESS');
      capture(a);
    });
  });
}
