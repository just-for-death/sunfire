import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart' show preferServerScrape;
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/sync/cursor_paginator.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_capabilities.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

/// Scripted adapter: each request is answered by [handler] with the decoded
/// GraphQL body. Throwing a [DioException] simulates a transport failure.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);
  final FutureOr<Object> Function(Map<String, dynamic> body, RequestOptions o) handler;
  final List<Map<String, dynamic>> requests = [];
  final List<RequestOptions> options = [];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final raw = o.data is String ? o.data as String : jsonEncode(o.data);
    final body = jsonDecode(raw) as Map<String, dynamic>;
    requests.add(body);
    options.add(o);
    final out = await handler(body, o);
    return ResponseBody.fromString(
      jsonEncode(out),
      200,
      headers: {
        'content-type': [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

GraphQLClientService _client(_ScriptedAdapter a) {
  final c = GraphQLClientService.instance;
  c.initialize('http://mock.invalid');
  c.debugHttpAdapter = a;
  c.retryDelay = (_) => Duration.zero;
  return c;
}

void main() {
  group('ISS-080 B5 dequeue / reorder', () {
    test('dequeueChapterDownloads sends ids; reorder sends chapterId/to', () async {
      final a = _ScriptedAdapter((b, _) => {
            'data': {
              'x': {
                'downloadStatus': {'state': 'STARTED', 'queue': <dynamic>[]},
              },
            },
          });
      final c = _client(a);
      expect(await c.dequeueChapterDownloads([1, 2]), isNotNull);
      expect(a.requests.last['query'], contains('dequeueChapterDownloads'));
      expect(a.requests.last['variables'], {'ids': [1, 2]});
      expect(await c.dequeueChapterDownload(5), isNotNull);
      expect(a.requests.last['variables'], {'id': 5});
      await c.reorderChapterDownload(7, -3);
      expect(a.requests.last['variables'], {'chapterId': 7, 'to': 0});
      await c.reorderChapterDownloads([(chapterId: 1, to: 2), (chapterId: 3, to: 0)]);
      expect(a.requests.last['query'], contains('ChapterDownloadReorderInput'));
      expect(a.requests.last['variables']['reorders'], [
        {'chapterId': 1, 'to': 2},
        {'chapterId': 3, 'to': 0},
      ]);
      // Mutations: not retried.
      expect(a.requests.last['query'], contains('tries'));
    });

    test('download item helpers', () {
      expect(isDownloadItemError({'state': 'ERROR'}), isTrue);
      expect(isDownloadItemError({'state': 'QUEUED'}), isFalse);
      expect(downloadItemTries({'tries': '3'}), 3);
    });
  });

  group('ISS-084 B13 version info', () {
    test('bundle + update check parse', () async {
      final a = _ScriptedAdapter((b, _) {
        final q = b['query'] as String;
        if (q.contains('checkForServerUpdates')) {
          return {
            'data': {
              'checkForServerUpdates': [
                {'channel': 'Preview', 'tag': 'v2.5', 'url': 'https://x'},
              ],
            },
          };
        }
        return {
          'data': {
            'aboutServer': {'name': 'Suwayomi-Server', 'version': 'v2.4.2379', 'buildType': 'Preview'},
            'aboutWebUI': {'channel': 'STABLE', 'tag': 'r2998', 'updateTimestamp': '1773097202133'},
            'getWebUIUpdateStatus': {
              'state': 'IDLE',
              'progress': 0,
              'info': {'channel': 'STABLE', 'tag': ''},
            },
          },
        };
      });
      final c = _client(a);
      final bundle = await c.fetchServerVersionBundle(includeUpdateCheck: true);
      expect(bundle.serverVersion, 'v2.4.2379');
      expect(bundle.webUI!.tag, 'r2998');
      expect(bundle.webUI!.updateTimestamp, 1773097202133);
      expect(bundle.webUIUpdateStatus!.state, 'IDLE');
      expect(bundle.hasServerUpdate, isTrue);
      expect(bundle.serverUpdates!.single.tag, 'v2.5');
      expect(WebUIUpdateCheckInfo.fromMap({'updateAvailable': true}).updateAvailable, isTrue);
    });
  });

  group('ISS-073 B3 server-first', () {
    test('preferServerScrape gates on serverId > 0 and configured', () {
      expect(preferServerScrape(serverId: 42, serverConfigured: true), isTrue);
      expect(preferServerScrape(serverId: 42, serverConfigured: false), isFalse);
      expect(preferServerScrape(serverId: -5, serverConfigured: true), isFalse);
      expect(preferServerScrape(serverId: 0, serverConfigured: true), isFalse);
      expect(preferServerScrape(serverId: 2147483647, serverConfigured: true), isFalse);
    });

    test('clearCookiesAndCache sends the mutation; MClient clears local jar', () async {
      final a = _ScriptedAdapter((b, _) => {
            'data': {
              'clearCookiesAndCache': {'clientMutationId': null},
            },
          });
      final c = _client(a);
      expect(await c.clearCookiesAndCache(), isTrue);
      expect(a.requests.single['query'], contains('clearCookiesAndCache'));
      await MClient.setCookie('https://example.com/x', '', cookie: 'cf=1');
      expect(MClient.debugCookieCount, greaterThan(0));
      MClient.clearSessionCookies();
      expect(MClient.debugCookieCount, 0);
    });
  });

  group('ISS-075 B12 per-op timeouts + retries', () {
    test('policies: scrape covers FlareSolverr 73s+, writes never retry', () {
      final scrape = policyForOp(GraphQLOp.scrapeRead);
      expect(scrape.receive.inSeconds, greaterThanOrEqualTo(103));
      expect(policyForOp(GraphQLOp.scrapeRead, flareSolverrTimeoutSeconds: 120).receive.inSeconds, 150);
      expect(policyForOp(GraphQLOp.write).maxRetries, 0);
      expect(policyForOp(GraphQLOp.read).maxRetries, 2);
      expect(inferGraphQLOp('  mutation { x }'), GraphQLOp.write);
      expect(inferGraphQLOp('{ x }'), GraphQLOp.read);
      final d = jitteredBackoff(2);
      expect(d.inMilliseconds, inInclusiveRange(800, 1099));
    });

    test('idempotent read retried on receive timeout (≤2), then succeeds', () async {
      var calls = 0;
      final a = _ScriptedAdapter((b, o) {
        calls++;
        if (calls < 3) {
          throw DioException(requestOptions: o, type: DioExceptionType.receiveTimeout);
        }
        return {
          'data': {
            'aboutWebUI': {'channel': 'STABLE', 'tag': 'r1'},
          },
        };
      });
      final c = _client(a);
      final info = await c.fetchAboutWebUI();
      expect(info?.tag, 'r1');
      expect(calls, 3);
    });

    test('mutation is NOT retried; refused connection is NOT retried', () async {
      var calls = 0;
      final a = _ScriptedAdapter((b, o) {
        calls++;
        throw DioException(requestOptions: o, type: DioExceptionType.receiveTimeout);
      });
      final c = _client(a);
      expect(await c.dequeueChapterDownload(1), isNull);
      expect(calls, 1);

      calls = 0;
      final a2 = _ScriptedAdapter((b, o) {
        calls++;
        throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        );
      });
      final c2 = _client(a2);
      expect(await c2.fetchAboutWebUI(), isNull);
      expect(calls, 1);
    });

    test('fetchChapterPages uses the long scrape receive timeout', () async {
      final a = _ScriptedAdapter((b, _) => {
            'data': {
              'fetchChapterPages': {'pages': ['/p/1']},
            },
          });
      final c = _client(a);
      c.flareSolverrTimeoutSeconds = 73;
      await c.fetchChapterPages(9);
      expect(a.options.single.receiveTimeout, const Duration(seconds: 103));
    });
  });

  group('ISS-074 B11 cursor pagination', () {
    Map<String, dynamic> page(List<int> ids, {String? end, bool? next, int? total}) => {
          'nodes': [for (final i in ids) {'id': i}],
          'pageInfo': {'endCursor': end, 'hasNextPage': next},
          if (total != null) 'totalCount': total,
        };

    test('follows endCursor to hasNextPage=false', () async {
      final seen = <String?>[];
      final r = await paginateConnection(
        pageSize: 2,
        fetchPage: ({String? after, int? offset, required bool useCursor}) async {
          seen.add(after);
          if (after == null) return page([1, 2], end: 'c1', next: true);
          if (after == 'c1') return page([3, 4], end: 'c2', next: true);
          return page([5], end: 'c3', next: false);
        },
      );
      expect(seen, [null, 'c1', 'c2']);
      expect(r.nodes.length, 5);
      expect(r.complete, isTrue);
      expect(r.usedCursor, isTrue);
    });

    test('empty page with hasNextPage=true is the end (history too)', () async {
      final r = await paginateConnection(
        pageSize: 2,
        fetchPage: ({String? after, int? offset, required bool useCursor}) async =>
            after == null ? page([1, 2], end: 'c1', next: true) : page([], end: 'c1', next: true),
      );
      expect(r.complete, isTrue);
      expect(r.nodes.length, 2);
    });

    test('stuck cursor / failed later page → incomplete; first fail → offset fallback', () async {
      final stuck = await paginateConnection(
        pageSize: 1,
        fetchPage: ({String? after, int? offset, required bool useCursor}) async {
          if (after == null) return page([1], end: 'c', next: true);
          return page([2], end: 'c', next: true);
        },
      );
      expect(stuck.complete, isFalse);

      final failed = await paginateConnection(
        pageSize: 1,
        fetchPage: ({String? after, int? offset, required bool useCursor}) async =>
            after == null ? page([1], end: 'c', next: true) : null,
      );
      expect(failed.complete, isFalse);
      expect(failed.firstPageFailed, isFalse);

      final modes = <bool>[];
      final fallback = await paginateConnection(
        pageSize: 2,
        fetchPage: ({String? after, int? offset, required bool useCursor}) async {
          modes.add(useCursor);
          if (useCursor) return null; // old schema rejects Cursor
          return offset == 0 ? page([1, 2], next: true) : page([3], next: false);
        },
      );
      expect(modes, [true, false, false]);
      expect(fallback.nodes.length, 3);
      expect(fallback.complete, isTrue);
      expect(fallback.usedCursor, isFalse);
    });

    test('fetchHistoryChapters passes after: endCursor and stamps completeness', () async {
      final a = _ScriptedAdapter((b, _) {
        final after = (b['variables'] as Map)['after'];
        final nodes = after == null
            ? [
                {'id': 1, 'isRead': true},
              ]
            : <Map<String, dynamic>>[];
        return {
          'data': {
            'chapters': {
              'totalCount': 9,
              'pageInfo': {'endCursor': 'x1', 'hasNextPage': true},
              'nodes': nodes,
            },
          },
        };
      });
      final c = _client(a);
      final res = await c.fetchHistoryChapters(0);
      expect(a.requests.length, 2);
      expect((a.requests[1]['variables'] as Map)['after'], 'x1');
      expect(a.requests[0]['query'], contains(r'$after: Cursor'));
      expect((res!['chapters'] as Map)['nodes'], hasLength(1));
      expect(isCompleteSnapshot(res), isTrue);
    });

    test('updates time window', () {
      final now = DateTime(2026, 10, 6, 12);
      expect(updatesWindowSince(highWaterFetchedAt: null, lastFullUpdatesPullAt: now, now: now), isNull);
      expect(
        updatesWindowSince(highWaterFetchedAt: 10000, lastFullUpdatesPullAt: now.subtract(const Duration(hours: 1)), now: now),
        10000 - 3600,
      );
      expect(
        updatesWindowSince(highWaterFetchedAt: 10000, lastFullUpdatesPullAt: now.subtract(const Duration(hours: 7)), now: now),
        isNull,
      );
    });

    test('fetchUpdatesChapters(sinceFetchedAt) adds fetchedAt filter', () async {
      final a = _ScriptedAdapter((b, _) => {
            'data': {
              'chapters': {'nodes': <dynamic>[]},
            },
          });
      final c = _client(a);
      await c.fetchUpdatesChapters(first: 10, sinceFetchedAt: 1700000000);
      expect(a.requests.single['query'], contains('fetchedAt: { greaterThan: "1700000000" }'));
      await c.fetchUpdatesChapters(first: 10);
      expect(a.requests.last['query'], isNot(contains('greaterThan')));
    });
  });

  group('ISS-076 B6 targeted chapter refresh', () {
    final node = {
      'id': 2,
      'unreadCount': 51,
      'chaptersLastFetchedAt': '1791275032',
      'latestFetchedChapter': {'id': 4279, 'fetchedAt': '1772013914'},
      'chapterStats': {'totalCount': 51},
      'bookmarkCount': 0,
      'downloadCount': 51,
      'lastReadChapter': {'id': 4229, 'lastPageRead': 0, 'lastReadAt': '1791277964', 'isRead': false},
    };

    test('fingerprint changes with read progress / new chapters; null without markers', () {
      final fp = chapterRefreshFingerprint(node);
      expect(fp, isNotNull);
      expect(chapterRefreshFingerprint({...node}), fp);
      expect(
        chapterRefreshFingerprint({
          ...node,
          'lastReadChapter': {'id': 4229, 'lastPageRead': 5, 'lastReadAt': '1791277999', 'isRead': false},
        }),
        isNot(fp),
      );
      expect(chapterRefreshFingerprint({...node, 'chaptersLastFetchedAt': '1791999999'}), isNot(fp));
      expect(chapterRefreshFingerprint({...node, 'unreadCount': 50}), isNot(fp));
      expect(chapterRefreshFingerprint({'id': 2, 'unreadCount': 1}), isNull);
    });

    test('shouldSkipChapterSnapshot', () {
      final now = DateTime(2026, 10, 6, 12);
      final recent = now.subtract(const Duration(minutes: 10));
      expect(
        shouldSkipChapterSnapshot(currentFingerprint: 'a', previousFingerprint: 'a', lastFullSnapshotAt: recent, localChapterCount: 5, now: now),
        isTrue,
      );
      expect(
        shouldSkipChapterSnapshot(currentFingerprint: 'a', previousFingerprint: 'b', lastFullSnapshotAt: recent, localChapterCount: 5, now: now),
        isFalse,
      );
      expect(
        shouldSkipChapterSnapshot(currentFingerprint: null, previousFingerprint: null, lastFullSnapshotAt: recent, localChapterCount: 5, now: now),
        isFalse,
      );
      expect(
        shouldSkipChapterSnapshot(currentFingerprint: 'a', previousFingerprint: 'a', lastFullSnapshotAt: recent, localChapterCount: 0, now: now),
        isFalse,
      );
      expect(
        shouldSkipChapterSnapshot(
          currentFingerprint: 'a',
          previousFingerprint: 'a',
          lastFullSnapshotAt: now.subtract(const Duration(hours: 7)),
          localChapterCount: 5,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('ISS-066 probe fix', () {
    test('capability probe sends ONE __type per request (Suwayomi good-faith guard)', () async {
      final a = _ScriptedAdapter((b, _) {
        final q = b['query'] as String;
        final n = '__type'.allMatches(q).length;
        if (n > 1) {
          return {
            'errors': [
              {'message': 'not asking for introspection in good faith'},
            ],
          };
        }
        if (q.contains('MangaUserType')) return {'data': {'__type': {'name': 'MangaUserType'}}};
        if (q.contains('"MangaType"')) {
          return {
            'data': {
              '__type': {
                'fields': [
                  {'name': 'chaptersLastFetchedAt'},
                  {'name': 'latestFetchedChapter'},
                ],
              },
            },
          };
        }
        if (q.contains('aboutServer')) return {'data': {'aboutServer': {'version': 'v2.4'}}};
        return {'data': {'__type': null}};
      });
      final c = _client(a);
      final caps = await c.probeServerCapabilities(force: true);
      expect(caps.hasUserField, isTrue);
      expect(caps.hasChapterFetchMarkers, isTrue);
      expect(caps.version, 'v2.4');
      for (final r in a.requests) {
        expect('__type'.allMatches(r['query'] as String).length, lessThanOrEqualTo(1));
      }
      c.capabilities = ServerCapabilities.empty;
    });
  });

  group('ISS-077 B9 meta', () {
    test('lastSync key never null/legacy', () {
      expect(lastSyncMetaKey(null), isNull);
      expect(lastSyncMetaKey(''), isNull);
      expect(lastSyncMetaKey('null'), isNull);
      expect(lastSyncMetaKey('default_device'), isNull);
      expect(lastSyncMetaKey('abc'), 'lastSync_abc');
      expect(kLegacyLastSyncMetaKeys, contains('lastSync_null'));
    });

    test('setMangaMeta namespaces keys; fetch filters to sunfire_*', () async {
      final a = _ScriptedAdapter((b, _) {
        final q = b['query'] as String;
        if (q.contains('setMangaMeta')) {
          return {
            'data': {
              'setMangaMeta': {
                'meta': {'key': 'sunfire_x', 'value': '1'},
              },
            },
          };
        }
        return {
          'data': {
            'manga': {
              'meta': [
                {'key': 'sunfire_x', 'value': '1'},
                {'key': 'webUI_foo', 'value': '2'},
              ],
            },
          },
        };
      });
      final c = _client(a);
      expect(await c.setMangaMeta(2, 'x', '1'), isTrue);
      expect((a.requests.last['variables'] as Map)['key'], 'sunfire_x');
      expect(await c.setMangaMeta(2, 'sunfire_y', '1'), isTrue);
      expect((a.requests.last['variables'] as Map)['key'], 'sunfire_y');
      expect(await c.setMangaMeta(0, 'x', '1'), isFalse);
      expect(await c.fetchSunfireMangaMeta(2), {'sunfire_x': '1'});
    });
  });
}
