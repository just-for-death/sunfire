// IMP-002 follow-up: a Local-source series addressed by a negative id goes
// route → chapters → reader pages without any server/GraphQL call.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/app.dart' show parseRouteId;
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/engine/local_source_service.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';

class _FakeStore implements LocalLibraryStore {
  final manga = <int, Manga>{};
  final chapters = <int, Chapter>{};
  @override
  Future<List<Manga>> allManga() async => manga.values.toList();
  @override
  Future<Manga?> mangaByServerId(int serverId) async => manga[serverId];
  @override
  Future<void> saveManga(Manga m) async => manga[m.serverId] = m;
  @override
  Future<List<Chapter>> chaptersFor(int key) async => chapters.values.where((c) => c.mangaId == key).toList();
  @override
  Future<void> saveChapters(List<Chapter> list) async {
    for (final c in list) {
      chapters[c.serverId] = c;
    }
  }

  @override
  Future<void> deleteChapters(List<Chapter> list) async {
    for (final c in list) {
      chapters.remove(c.serverId);
    }
  }
}

/// Configured client that records (and refuses) every server call.
class _SpyClient extends GraphQLClientService {
  _SpyClient() : super.forTesting();
  final calls = <String>[];
  @override
  bool get isConfigured => true;
  @override
  Future<Map<String, dynamic>?> query(String document,
      {Map<String, dynamic>? variables, String? label, GraphQLOp? op}) async {
    calls.add(label ?? document);
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchMangaDetails(int mangaId) async {
    calls.add('fetchMangaDetails($mangaId)');
    return null;
  }

  @override
  Future<Map<String, dynamic>?> enqueueChapterDownloads(List<int> ids) async {
    calls.add('enqueueChapterDownloads($ids)');
    return null;
  }
}

void main() {
  late Directory tmp;
  late _FakeStore store;
  late _SpyClient spy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    tmp = await Directory.systemTemp.createTemp('neg_id_');
    store = _FakeStore();
    spy = _SpyClient();
    GraphQLClientService.debugInstance = spy;
    LocalSourceService.instance
      ..debugStore = store
      ..debugCacheDir = Directory('${tmp.path}/cache');
    DownloadStorage.debugDocumentsDir = () async => Directory('${tmp.path}/docs');
  });
  tearDown(() async => tmp.delete(recursive: true));

  test('parseRouteId accepts negative ids', () {
    expect(parseRouteId('-5'), -5);
    expect(parseRouteId('-549755813887'), -549755813887);
    expect(parseRouteId('12'), 12);
    expect(parseRouteId(null), 0);
    expect(parseRouteId('x'), 0);
  });

  testWidgets('route /manga/<negative> → chapters → file pages, no server calls', (tester) async {
    for (final p in ['Solo/Ch 1/1.jpg', 'Solo/Ch 1/2.jpg', 'Solo/Ch 2/1.jpg']) {
      final f = File('${tmp.path}/lib/$p');
      await tester.runAsync(() async {
        await f.parent.create(recursive: true);
        await f.writeAsBytes([1, 2, 3]);
      });
    }
    final svc = LocalSourceService.instance;
    await tester.runAsync(() async {
      await svc.setRoot('${tmp.path}/lib');
      expect((await svc.scan()).error, isNull);
    });
    final manga = (await tester.runAsync(svc.listLibrary))!.single;
    expect(manga.serverId, lessThan(0));

    // Route with the same pattern + parser the app uses.
    int? routed;
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
      GoRoute(
        path: '/manga/:id',
        builder: (_, s) {
          routed = parseRouteId(s.pathParameters['id']);
          return const SizedBox();
        },
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    unawaited(router.push('/manga/${manga.serverId}'));
    await tester.pumpAndSettle();
    expect(routed, manga.serverId);

    final m = (await tester.runAsync(() => store.mangaByServerId(routed!)))!;
    final chapters = (await tester.runAsync(() => svc.chaptersFor(m)))!;
    expect(chapters.map((c) => c.name), ['Ch 1', 'Ch 2']);

    final res = (await tester.runAsync(() => ContentResolverService.instance.resolveChapterPages(
          chapterServerId: chapters.first.serverId,
          chapterUrl: chapters.first.url,
          sourceName: m.sourceName,
        )))!;
    expect(res.isLocalFiles, isTrue);
    expect(res.pageUrls.map((p) => p.split('/').last), ['1.jpg', '2.jpg']);

    // Server-facing entry points refuse negative ids.
    expect(QuickJsService.instance.getExtensionCode(kLocalSourceName), isNull);
    await tester.runAsync(() async {
      await DownloadManagerService.instance.enqueueServerDownload(chapters.first.serverId);
      await DownloadManagerService.instance.enqueueServerDownloads(chapters.map((c) => c.serverId).toList());
      await expectLater(spy.bindTrack(m.serverId, 1, 'x'), throwsA(isA<ServerMutationException>()));
    });
    expect(spy.calls, isEmpty);
  });
}
