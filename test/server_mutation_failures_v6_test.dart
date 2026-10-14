import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/services/library_update_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_capabilities.dart';
import 'package:sunfire/src/core/sync/server_session_service.dart';
import 'package:sunfire/src/core/sync/suwayomi_parse_helpers.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

class _Reply {
  _Reply(this.body, {this.status = 200});
  final Object body;
  final int status;
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
    });
  }

  @override
  void close({bool force = false}) {}
}

const _base = 'http://mock.invalid';

GraphQLClientService _client(_Adapter a, {String? auth}) {
  final c = GraphQLClientService.instance;
  c.initialize(_base, authToken: auth);
  c.debugHttpAdapter = a;
  c.retryDelay = (_) => Duration.zero;
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ServerSessionService.instance.debugReset();
  });
  tearDown(() {
    GraphQLClientService.instance.capabilities = ServerCapabilities.empty;
    GraphQLClientService.instance.initialize('');
  });

  _Reply gqlError() => _Reply({'data': null, 'errors': [{'message': 'boom'}]});

  group('H1 server mutations surface failures', () {
    test('bindTrack / unbindTrack / updateTrack throw ServerMutationException on GraphQL error', () async {
      final a = _Adapter((r) => r.gql.contains('Track') ? gqlError() : _Reply({'data': <String, dynamic>{}}));
      final c = _client(a);
      await expectLater(c.bindTrack(1, 2, 3), throwsA(isA<ServerMutationException>()
          .having((e) => e.operation, 'op', 'bindTrack')
          .having((e) => e.isTransportFailure, 'transport', isFalse)));
      await expectLater(c.unbindTrack(9), throwsA(isA<ServerMutationException>()));
      await expectLater(c.updateTrack(recordId: 9, lastChapterRead: 1), throwsA(isA<ServerMutationException>()));
    });

    test('bindTrack returns data on success', () async {
      final a = _Adapter((r) => _Reply({'data': {'bindTrack': {'clientMutationId': null}}}));
      final c = _client(a);
      final d = await c.bindTrack(1, 2, 3);
      expect(d.containsKey('bindTrack'), isTrue);
    });

    test('unconfigured client throws instead of silently succeeding', () async {
      GraphQLClientService.instance.initialize('');
      await expectLater(GraphQLClientService.instance.unbindTrack(1), throwsA(isA<ServerMutationException>()));
    });

    test('addMangaToLibraryOrThrow rolls back inLibrary when categories fail', () async {
      final a = _Adapter((r) {
        if (r.gql.contains('updateMangaCategories')) return gqlError();
        if (r.gql.contains('updateManga(')) {
          final v = r.json['variables'] as Map;
          return _Reply({'data': {'updateManga': {'manga': {'id': v['id'], 'inLibrary': v['inLibrary']}}}});
        }
        return _Reply({'data': <String, dynamic>{}});
      });
      final c = _client(a);
      await expectLater(c.addMangaToLibraryOrThrow(5, categoryIds: [2]), throwsA(isA<ServerMutationException>()));
      final libCalls = a.log.where((r) => r.gql.contains('updateManga(')).map((r) => r.json['variables']['inLibrary']).toList();
      expect(libCalls, [true, false]);
    });

    test('addMangaToLibraryOrThrow fails when updateManga errors (no category call)', () async {
      final a = _Adapter((r) => r.gql.contains('mutation') ? gqlError() : _Reply({'data': <String, dynamic>{}}));
      final c = _client(a);
      await expectLater(c.addMangaToLibraryOrThrow(5, categoryIds: [2]), throwsA(isA<ServerMutationException>()));
      expect(a.log.where((r) => r.gql.contains('updateMangaCategories')), isEmpty);
    });

    test('addMangaToLibraryOrThrow succeeds', () async {
      final a = _Adapter((r) => _Reply({'data': {
            'updateManga': {'manga': {'id': 5, 'inLibrary': true}},
            'updateMangaCategories': {'clientMutationId': null},
          }}));
      await _client(a).addMangaToLibraryOrThrow(5, categoryIds: [2]);
    });

    test('userMessage differs by failure kind', () {
      expect(const ServerMutationException('x', isTransportFailure: true).userMessage, contains('reach'));
      expect(const ServerMutationException('x').userMessage, contains('rejected'));
    });
  });

  group('M3 hasNextPage', () {
    test('server flag wins over page size', () {
      expect(ContentResolverService.computeHasNextPage(serverHasNextPage: true, pageLength: 3), isTrue);
      expect(ContentResolverService.computeHasNextPage(serverHasNextPage: false, pageLength: 50), isFalse);
    });
    test('empty page always ends', () {
      expect(ContentResolverService.computeHasNextPage(serverHasNextPage: true, pageLength: 0), isFalse);
    });
    test('local heuristic only when server flag is null', () {
      expect(ContentResolverService.computeHasNextPage(serverHasNextPage: null, pageLength: 9), isFalse);
      expect(ContentResolverService.computeHasNextPage(serverHasNextPage: null, pageLength: 10), isTrue);
    });
  });

  group('M5 deprecated MangaType fields', () {
    test('user-scoped selection avoids deprecated top-level counters', () {
      final c = GraphQLClientService.instance;
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true, hasChapterFetchMarkers: true);
      final sel = c.debugLibrarySelection();
      expect(sel, isNot(contains('lastReadChapter { id lastPageRead')));
      final markerPart = sel.substring(sel.indexOf('chaptersLastFetchedAt'));
      expect(markerPart, isNot(matches(RegExp(r'^\s*(bookmarkCount|downloadCount)\s*$', multiLine: true))));
    });
    test('fetchLibrary omits top-level inLibrary/unreadCount when user field exists', () async {
      final a = _Adapter((r) => _Reply({'data': {'mangas': {'totalCount': 0, 'pageInfo': {'endCursor': null, 'hasNextPage': false}, 'nodes': <dynamic>[]}}}));
      final c = _client(a);
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true, hasChapterFetchMarkers: true);
      await c.fetchLibrary();
      final q = a.log.firstWhere((r) => r.gql.contains('mangas(condition')).gql;
      final beforeUser = q.substring(0, q.indexOf('user {'));
      expect(beforeUser, isNot(contains('unreadCount')));
      expect(beforeUser, isNot(contains('inLibraryAt')));
    });
    test('flatten exposes nested lastReadChapter.user fields', () {
      final m = flattenMangaUserFields({
        'id': 1,
        'user': {
          'unreadCount': 4,
          'lastReadChapter': {'id': 7, 'user': {'lastPageRead': 3, 'isRead': false}},
        },
      });
      expect(m['unreadCount'], 4);
      expect((m['lastReadChapter'] as Map)['lastPageRead'], 3);
    });
  });

  group('L1 aboutServer.platformInfo', () {
    test('first request uses platformInfo and succeeds (no legacy retry)', () async {
      final a = _Adapter((r) => _Reply({'data': {
            'aboutServer': {'name': 'Suwayomi', 'version': 'v2.4.2379', 'platformInfo': {'os': 'linux', 'arch': 'amd64', 'jvm': '21', 'headless': true}},
          }}));
      final c = _client(a);
      final b = await c.fetchServerVersionBundle();
      final calls = a.log.where((r) => r.gql.contains('aboutServer')).toList();
      expect(calls, hasLength(1));
      expect(calls.single.gql, contains('platformInfo {'));
      expect(calls.single.gql, isNot(matches(RegExp(r'\bplatform\b'))));
      expect(b.serverPlatform, 'linux (amd64)');
    });
    test('schema fixture has platformInfo subfields and no platform', () {
      final d = jsonDecode(File('test/fixtures/suwayomi_schema.json').readAsStringSync()) as Map<String, dynamic>;
      final schema = (d['data'] ?? d)['__schema'] as Map;
      final types = {for (final t in schema['types'] as List) t['name']: t};
      final about = (types['AboutServerPayload']['fields'] as List).map((f) => f['name']).toSet();
      expect(about, contains('platformInfo'));
      expect(about, isNot(contains('platform')));
      final pi = (types['PlatformInfo']['fields'] as List).map((f) => f['name']).toSet();
      expect(pi, containsAll(['os', 'arch', 'jvm', 'headless']));
    });
    test('legacy server without platformInfo falls back', () {
      const b = ServerVersionBundle(aboutServer: {'version': 'v1'});
      expect(b.serverPlatform, isNull);
    });
  });

  group('UIX6-01 transport classification', () {
    test('503 → ServerMutationException(isTransportFailure: true)', () async {
      final a = _Adapter((r) => _Reply('<html>503</html>', status: 503));
      await expectLater(_client(a).bindTrack(1, 2, 3),
          throwsA(isA<ServerMutationException>().having((e) => e.isTransportFailure, 'transport', isTrue)));
    });
    test('timeout → ServerMutationException(isTransportFailure: true)', () async {
      final a = _Adapter((r) => throw DioException(requestOptions: r.options, type: DioExceptionType.receiveTimeout));
      await expectLater(_client(a).unbindTrack(4),
          throwsA(isA<ServerMutationException>().having((e) => e.isTransportFailure, 'transport', isTrue)));
    });
    test('isTransientSyncError honours ServerMutationException', () {
      expect(isTransientSyncError(const ServerMutationException('x', isTransportFailure: true)), isTrue);
      expect(isTransientSyncError(const ServerMutationException('x')), isFalse);
    });
  });

  group('UIX6-03 / ISS-072 user-scoped chapter + manga state', () {
    Map<String, Set<String>> userTypeFields() {
      final d = jsonDecode(File('test/fixtures/suwayomi_schema.json').readAsStringSync()) as Map<String, dynamic>;
      final schema = (d['data'] ?? d)['__schema'] as Map;
      final out = <String, Set<String>>{};
      for (final t in schema['types'] as List) {
        if (t['name'] == 'MangaUserType' || t['name'] == 'ChapterUserType') {
          out[t['name'] as String] = {
            for (final f in t['fields'] as List)
              if (f['isDeprecated'] != true) f['name'] as String,
          };
        }
      }
      return out;
    }

    test('hasUserField: selections are user{} and every key exists in the schema fixture', () {
      final c = GraphQLClientService.instance;
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true);
      final parts = c.debugStateSelections().split('|');
      expect(parts[0], startsWith('user {'));
      expect(parts[1], startsWith('user {'));
      final types = userTypeFields();
      // ISS-141: chapter meta rides on the chapter node, outside user{}.
      expect(parts[0], endsWith('meta { key value }'));
      List<String> keys(String sel) => sel
          .replaceAll('meta { key value }', ' ')
          .replaceAll(RegExp(r'user \{|\}'), ' ')
          .trim()
          .split(RegExp(r'\s+'));
      expect(types['ChapterUserType'], containsAll(keys(parts[0])));
      expect(types['MangaUserType'], containsAll(keys(parts[1])));
    });

    test('legacy server keeps top-level fields', () {
      final c = GraphQLClientService.instance;
      c.capabilities = ServerCapabilities.empty;
      expect(c.debugStateSelections(), isNot(contains('user {')));
      expect(c.debugStateSelections(), contains('isRead'));
    });

    test('fetchUpdatesChapters / downloadStatus / updateChapter docs avoid deprecated top-level state', () async {
      final a = _Adapter((r) => _Reply({'data': <String, dynamic>{}}));
      final c = _client(a);
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true);
      await c.fetchUpdatesChapters();
      await c.fetchDownloadStatus();
      await c.updateChapterReadStatus(1, true, 2);
      final deprecated = RegExp(r'^\s*(isRead|isBookmarked|lastPageRead|lastReadAt|isDownloaded|inLibrary|inLibraryAt|unreadCount)\s*$', multiLine: true);
      for (final r in a.log.where((r) => r.gql.contains('chapter'))) {
        final stripped = r.gql.replaceAll(RegExp(r'user \{[^}]*\}'), '');
        expect(stripped, isNot(matches(deprecated)), reason: r.gql);
        expect(r.gql, isNot(contains('#STATE#')));
      }
    });

    test('responses are flattened from user{} onto the parent', () async {
      final a = _Adapter((r) => _Reply({'data': {'chapters': {'nodes': [
            {'id': 1, 'user': {'isRead': true, 'lastPageRead': 7}, 'manga': {'id': 2, 'user': {'inLibrary': true}}},
          ]}}}));
      final c = _client(a);
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true);
      final d = await c.fetchUpdatesChapters();
      final n = (d!['chapters']['nodes'] as List).single as Map;
      expect(n['isRead'], isTrue);
      expect(n['lastPageRead'], 7);
      expect((n['manga'] as Map)['inLibrary'], isTrue);
    });
  });

  group('ISS-070 NSFW', () {
    test('contentWarning wins, then isNsfw, then name heuristic', () {
      expect(isSourceNsfw({'name': 'Hentai X', 'contentWarning': 'SAFE'}), isFalse);
      expect(isSourceNsfw({'name': 'Plain', 'contentWarning': 'MIXED'}), isTrue);
      expect(isSourceNsfw({'name': 'Plain', 'isNsfw': true}), isTrue);
      expect(isSourceNsfw({'name': 'Adult (18+)'}), isTrue);
      expect(isSourceNsfw({'name': 'Webtoons'}), isFalse);
    });
    test('fetchSources / fetchExtensions no longer select deprecated isNsfw', () async {
      final a = _Adapter((r) => _Reply({'data': <String, dynamic>{}}));
      final c = _client(a);
      await c.fetchSources();
      await c.fetchExtensions();
      for (final r in a.log.where((r) => r.gql.contains('contentWarning'))) {
        expect(r.gql, isNot(contains('isNsfw')));
      }
    });
  });

  group('ISS-068 / UIX6-07', () {
    test('poll interval is slow once WS is delivering', () {
      expect(libraryUpdatePollInterval(sawWsEvent: true), greaterThanOrEqualTo(const Duration(seconds: 10)));
      expect(libraryUpdatePollInterval(sawWsEvent: false), greaterThan(const Duration(milliseconds: 1500)));
    });
    test('debounceLazyStream collapses bursts', () async {
      final src = StreamController<void>();
      final events = <void>[];
      final sub = IsarService.debounceLazyStream(src.stream, const Duration(milliseconds: 30)).listen(events.add);
      for (var i = 0; i < 5; i++) {
        src.add(null);
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(events, hasLength(1));
      src.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(events, hasLength(2));
      await sub.cancel();
      await src.close();
    });
  });

  group('UIX6-03 follow-up: remaining deprecated spots (schema fixture)', () {
    Set<String> deprecatedFields() {
      final d = jsonDecode(File('test/fixtures/suwayomi_schema.json').readAsStringSync()) as Map<String, dynamic>;
      final schema = (d['data'] ?? d)['__schema'] as Map;
      final out = <String>{};
      for (final t in schema['types'] as List) {
        if (t['name'] == 'MangaType' || t['name'] == 'ChapterType') {
          for (final f in t['fields'] as List) {
            if (f['isDeprecated'] == true && f['name'] != 'isNsfw') out.add(f['name'] as String);
          }
        }
      }
      return out;
    }

    /// Deprecated field names selected outside `user { … }` (arguments like
    /// `isRead: $isRead` and variables are ignored).
    List<String> offenders(String gql, Set<String> deprecated) {
      var doc = gql;
      final userBlock = RegExp(r'user \{[^{}]*(\{[^{}]*\}[^{}]*)*\}');
      while (userBlock.hasMatch(doc)) {
        doc = doc.replaceAll(userBlock, '');
      }
      return [
        for (final f in deprecated)
          if (RegExp('(?<![\\\$\\w])$f\\b(?!\\s*:)').hasMatch(doc)) f,
      ];
    }

    test('legacy details, download queue, bulk chapters, koSync use user{}', () async {
      final a = _Adapter((r) {
        // Fail the primary manga query so the legacy fallback runs.
        if (r.gql.contains('manga(id') && !r.gql.contains('chapters {')) {
          return _Reply({'data': null, 'errors': [{'message': 'x'}]});
        }
        return _Reply({'data': <String, dynamic>{}});
      });
      final c = _client(a);
      c.capabilities = ServerCapabilities.empty.copyWith(hasUserField: true);
      await c.fetchMangaDetails(1);
      await c.dequeueChapterDownload(1);
      await c.updateChapters([1, 2], isRead: true);
      await c.deleteDownloadedChapters([1, 2]);
      await c.pullKoSyncProgress(1);
      final deprecated = deprecatedFields();
      expect(deprecated, containsAll(['isRead', 'isDownloaded', 'inLibrary', 'unreadCount']));
      final checked = <String>[];
      for (final r in a.log) {
        if (!r.path.endsWith('/api/graphql') || r.gql.isEmpty) continue;
        expect(r.gql, isNot(contains('#')), reason: 'unreplaced placeholder');
        final bad = offenders(r.gql, deprecated);
        expect(bad, isEmpty, reason: r.gql);
        checked.add(r.gql);
      }
      expect(checked.any((g) => g.contains('chapters {') && g.contains('manga(id')), isTrue, reason: 'legacy ran');
      expect(checked.any((g) => g.contains('dequeueChapterDownload')), isTrue);
      expect(checked.any((g) => g.contains('updateChapters(')), isTrue);
      expect(checked.any((g) => g.contains('deleteDownloadedChapters(')), isTrue);
      expect(checked.any((g) => g.contains('pullKoSyncProgress')), isTrue);
    });

    test('old servers keep the legacy top-level fields', () async {
      final a = _Adapter((r) => _Reply({'data': <String, dynamic>{}}));
      final c = _client(a);
      c.capabilities = ServerCapabilities.empty;
      await c.updateChapters([1, 2], isRead: true);
      expect(a.log.last.gql, contains('chapters { id isRead'));
    });
  });

  group('ISS-068 follow-ups', () {
    final t0 = DateTime(2026, 10, 14, 2, 0);
    test('poll drives progress before any WS event', () {
      expect(shouldApplyPolledStatus(sawWsEvent: false, lastWsAt: null, now: t0), isTrue);
    });
    test('fresh WS suppresses polled progress', () {
      expect(shouldApplyPolledStatus(sawWsEvent: true, lastWsAt: t0, now: t0.add(const Duration(seconds: 3))), isFalse);
    });
    test('WS dropped mid-run → poll takes over (no frozen bar)', () {
      expect(shouldApplyPolledStatus(sawWsEvent: true, lastWsAt: t0, now: t0.add(const Duration(seconds: 16))), isTrue);
      // ...and the fallback interval drops back to the fast one.
      expect(libraryUpdatePollInterval(sawWsEvent: false), lessThan(libraryUpdatePollInterval(sawWsEvent: true)));
    });
    test('wait loop checks cancel and wakes on cancel', () {
      final src = File('lib/src/core/services/library_update_service.dart').readAsStringSync();
      final loop = src.substring(src.indexOf('while (DateTime.now().isBefore(deadline))'));
      final body = loop.substring(0, loop.indexOf('} finally {'));
      expect('_checkCancelled()'.allMatches(body).length, greaterThanOrEqualTo(2));
      expect(body, contains('_cancelCompleter!.future'));
    });
  });
}
