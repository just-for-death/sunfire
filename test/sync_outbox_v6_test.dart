// UIX6-06 / ISS-098: outbox + dispatch classification (Isar-backed).
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

String? _findIsarNative() {
  // Prefer isar_community_flutter_libs (3.3.2); fall back to legacy isar_flutter_libs.
  String? legacy;
  // 1) pub-cache hosted layout: .pub-cache/hosted/pub.dev/isar_community_flutter_libs-*/linux/libisar.so
  final hosted = Directory('${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev');
  if (hosted.existsSync()) {
    for (final d in hosted.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 2) legacy flat pub-cache layout.
  final rootDir = Directory('${Platform.environment['HOME']}/.pub-cache');
  if (rootDir.existsSync()) {
    for (final d in rootDir.listSync().whereType<Directory>()) {
      final isCommunity = d.path.contains('isar_community_flutter_libs');
      final isLegacy = d.path.contains('isar_flutter_libs') && !isCommunity;
      if (isCommunity || isLegacy) {
        final f = File('${d.path}/linux/libisar.so');
        if (f.existsSync()) {
          if (isCommunity) return f.path;
          legacy ??= f.path;
        }
      }
    }
  }
  // 3) flutter test build output (rebuilt via `flutter build linux --debug`).
  final buildLib = File(
    '${Directory.current.path}/build/linux/x64/debug/bundle/lib/libisar.so',
  );
  if (buildLib.existsSync()) return buildLib.path;
  return legacy;
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  ({Object body, int status}) Function(String gql) handler;
  final List<String> log = [];
  Future<void>? hold; // ISS-051 test: park requests until released

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    var raw = '';
    if (o.data is String) {
      raw = o.data as String;
    } else if (requestStream != null) {
      final bytes = <int>[];
      await for (final c in requestStream) {
        bytes.addAll(c);
      }
      raw = utf8.decode(bytes, allowMalformed: true);
    } else if (o.data != null) {
      raw = jsonEncode(o.data);
    }
    final gql = raw.startsWith('{') ? ((jsonDecode(raw) as Map)['query'] as String? ?? '') : '';
    log.add(gql);
    if (hold != null) await hold;
    final r = handler(gql);
    final body = r.body is String ? r.body as String : jsonEncode(r.body);
    return ResponseBody.fromString(body, r.status, headers: {
      'content-type': [r.body is String ? 'text/html' : Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _ok = (body: {'data': {'updateManga': {'manga': {'id': 5, 'inLibrary': true}}, 'bindTrack': {'clientMutationId': null}, 'unbindTrack': {'clientMutationId': null}, 'updateMangaCategories': {'manga': {'id': 5}}, 'removeExtensionStore': {'extensionStore': {'indexUrl': 'https://s/index.json'}}}}, status: 200);
const _down = (body: '<html>503</html>', status: 503);
const _rejected = (body: {'data': null, 'errors': [{'message': 'nope'}]}, status: 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late _Adapter adapter;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_outbox');
    final native = _findIsarNative();
    if (native == null) fail('libisar.so not found');
    await Isar.initializeIsarCore(libraries: {Abi.linuxX64: native});
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
  });

  tearDownAll(() async {
    GraphQLClientService.instance.initialize('');
    await IsarService.instance.isar.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SettingsService.instance.incognitoMode = false;
    await IsarService.instance.isar.writeTxn(() => IsarService.instance.isar.clear());
    adapter = _Adapter((_) => _ok);
    final c = GraphQLClientService.instance;
    c.initialize('http://mock.invalid');
    c.debugHttpAdapter = adapter;
    c.retryDelay = (_) => Duration.zero;
  });

  Future<List<SyncRecord>> pending() => IsarService.instance.getPendingSyncRecords();

  group('outbox API', () {
    test('transport failure → queued with undo token; undo removes it', () async {
      adapter.handler = (_) => _down;
      final r = await SyncEngine.instance.setMangaInLibraryWithOutbox(5, true);
      expect(r.queued, isTrue);
      expect(r.applied, isFalse);
      final recs = await pending();
      expect(recs, hasLength(1));
      expect(jsonDecode(recs.single.payloadJson), {'mangaId': 5, 'inLibrary': true});
      expect(await SyncEngine.instance.undoQueuedMutation(r.undoToken!), isTrue);
      expect(await pending(), isEmpty);
      expect(await SyncEngine.instance.undoQueuedMutation(r.undoToken!), isFalse);
    });

    test('server rejection → throws, nothing queued', () async {
      adapter.handler = (_) => _rejected;
      await expectLater(SyncEngine.instance.setMangaInLibraryWithOutbox(5, true),
          throwsA(isA<ServerMutationException>()));
      expect(await pending(), isEmpty);
    });

    test('success → applied, nothing queued', () async {
      final r = await SyncEngine.instance.bindTrackWithOutbox(5, 1, 99);
      expect(r.applied, isTrue);
      expect(await pending(), isEmpty);
    });

    test('queued tracker bind replays on reconnect', () async {
      adapter.handler = (_) => _down;
      final r = await SyncEngine.instance.bindTrackWithOutbox(5, 1, 99, isPrivate: true);
      expect(r.queued, isTrue);
      adapter.handler = (_) => _ok;
      await SyncEngine.instance.debugFlushPendingMutations();
      expect(await IsarService.instance.getSyncRecord(r.undoToken!), isNull, reason: 'dispatched + completed');
      expect(adapter.log.where((g) => g.contains('bindTrack')).length, 2);
    });

    group('ISS-105 add-categories / remove-store outbox', () {
      test('add-to-categories: queued with undo, replays add-only patch', () async {
        adapter.handler = (_) => _down;
        final r = await SyncEngine.instance.addMangaToCategoriesWithOutbox(5, [3, 4]);
        expect(r.queued, isTrue);
        final rec = (await pending()).single;
        expect(jsonDecode(rec.payloadJson), {'op': 'addTo', 'mangaId': 5, 'categoryIds': [3, 4]});
        adapter.handler = (_) => _ok;
        adapter.log.clear();
        await SyncEngine.instance.debugFlushPendingMutations();
        expect(await IsarService.instance.getSyncRecord(r.undoToken!), isNull);
        expect(adapter.log.where((g) => g.contains('addToCategories')).length, 1);
        expect(adapter.log.any((g) => g.contains('clearCategories') || g.contains('categoryIds: \$')), isFalse);
      });

      test('add-to-categories: undo removes the queued record', () async {
        adapter.handler = (_) => _down;
        final r = await SyncEngine.instance.addMangaToCategoriesWithOutbox(5, [3]);
        expect(await SyncEngine.instance.undoQueuedMutation(r.undoToken!), isTrue);
        expect(await pending(), isEmpty);
      });

      test('add-to-categories: rejection throws, nothing queued; success applied', () async {
        adapter.handler = (_) => _rejected;
        await expectLater(SyncEngine.instance.addMangaToCategoriesWithOutbox(5, [3]),
            throwsA(isA<ServerMutationException>()));
        expect(await pending(), isEmpty);
        adapter.handler = (_) => _ok;
        expect((await SyncEngine.instance.addMangaToCategoriesWithOutbox(5, [3])).applied, isTrue);
      });

      test('remove-store: queued with undo; replay sends removeExtensionStore', () async {
        adapter.handler = (_) => _down;
        final r = await SyncEngine.instance.removeExtensionStoreWithOutbox(' https://s/index.json ');
        expect(r.queued, isTrue);
        expect(jsonDecode((await pending()).single.payloadJson), {'op': 'removeStore', 'indexUrl': 'https://s/index.json'});
        adapter.handler = (_) => _ok;
        adapter.log.clear();
        await SyncEngine.instance.debugFlushPendingMutations();
        expect(await IsarService.instance.getSyncRecord(r.undoToken!), isNull);
        expect(adapter.log.where((g) => g.contains('removeExtensionStore')).length, 1);
      });

      test('remove-store: undo, rejection throws, success applied', () async {
        adapter.handler = (_) => _down;
        final q = await SyncEngine.instance.removeExtensionStoreWithOutbox('https://s/index.json');
        expect(await SyncEngine.instance.undoQueuedMutation(q.undoToken!), isTrue);
        adapter.handler = (_) => _rejected;
        await expectLater(SyncEngine.instance.removeExtensionStoreWithOutbox('https://s/index.json'),
            throwsA(isA<ServerMutationException>()));
        expect(await pending(), isEmpty);
        adapter.handler = (_) => _ok;
        expect((await SyncEngine.instance.removeExtensionStoreWithOutbox('https://s/index.json')).applied, isTrue);
      });

      test('remove-store replay: transport failure transient, rejection spends budget', () async {
        adapter.handler = (_) => _down;
        final r = await SyncEngine.instance.removeExtensionStoreWithOutbox('https://s/index.json');
        await SyncEngine.instance.debugFlushPendingMutations();
        expect((await IsarService.instance.getSyncRecord(r.undoToken!))!.retryCount, 0);
        adapter.handler = (_) => _rejected;
        await SyncEngine.instance.debugFlushPendingMutations();
        expect((await IsarService.instance.getSyncRecord(r.undoToken!))?.retryCount, 1);
      });
    });

    group('categoryIds (default category on replay)', () {
      bool isAddPatch(String g) => g.contains('updateMangaCategories') && g.contains('addToCategories');

      test('queued add stores categoryIds and replays with add-to-categories', () async {
        adapter.handler = (_) => _down;
        final r = await SyncEngine.instance.setMangaInLibraryWithOutbox(5, true, categoryIds: [3]);
        expect(r.queued, isTrue);
        final recs = await pending();
        expect(jsonDecode(recs.single.payloadJson), {'mangaId': 5, 'inLibrary': true, 'categoryIds': [3]});
        adapter.log.clear();
        adapter.handler = (_) => _ok;
        await SyncEngine.instance.debugFlushPendingMutations();
        expect(await IsarService.instance.getSyncRecord(r.undoToken!), isNull);
        expect(adapter.log.where(isAddPatch), hasLength(1));
        expect(adapter.log.any((g) => g.contains('clearCategories')), isFalse, reason: 'never the set-list assign');
      });

      test('direct success applies inLibrary then add-to-categories', () async {
        final r = await SyncEngine.instance.setMangaInLibraryWithOutbox(5, true, categoryIds: [3]);
        expect(r.applied, isTrue);
        expect(adapter.log.where(isAddPatch), hasLength(1));
        expect(await pending(), isEmpty);
      });

      test('remove ignores categoryIds; no categoryIds → no category call', () async {
        adapter.handler = (_) => _down;
        await SyncEngine.instance.setMangaInLibraryWithOutbox(5, false, categoryIds: [3]);
        expect(jsonDecode((await pending()).single.payloadJson), {'mangaId': 5, 'inLibrary': false});
        adapter.log.clear();
        adapter.handler = (_) => _ok;
        await SyncEngine.instance.debugFlushPendingMutations();
        await SyncEngine.instance.setMangaInLibraryWithOutbox(5, true);
        expect(adapter.log.any((g) => g.contains('updateMangaCategories')), isFalse);
      });
    });
  });

  group('dispatch classification (ISS-098)', () {
    Future<SyncRecord> queue(SyncEntityType t, Map<String, dynamic> payload) async {
      final r = SyncRecord()
        ..recordId = 'v6-${DateTime.now().microsecondsSinceEpoch}'
        ..entityType = t
        ..entityId = '1'
        ..action = SyncAction.update
        ..payloadJson = jsonEncode(payload)
        ..timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000
        ..state = SyncRecordState.pending;
      await IsarService.instance.saveSyncRecord(r);
      return r;
    }

    for (final kind in ['tracker-unbind', 'manga', 'category-delete']) {
      SyncEntityType type() => kind == 'manga'
          ? SyncEntityType.manga
          : kind == 'category-delete'
              ? SyncEntityType.category
              : SyncEntityType.tracker;
      Map<String, dynamic> payload() => kind == 'manga'
          ? {'mangaId': 5, 'inLibrary': true}
          : kind == 'category-delete'
              ? {'op': 'delete', 'categoryId': 7}
              : {'op': 'unbind', 'recordId': 3};

      test('$kind: transport failure is transient (no retry budget spent)', () async {
        adapter.handler = (_) => _down;
        final r = await queue(type(), payload());
        await SyncEngine.instance.debugFlushPendingMutations();
        final after = await IsarService.instance.getSyncRecord(r.id);
        expect(after, isNotNull);
        expect(after!.retryCount, 0);
      });

      test('$kind: server rejection is permanent (retry budget spent)', () async {
        adapter.handler = (_) => _rejected;
        final r = await queue(type(), payload());
        await SyncEngine.instance.debugFlushPendingMutations();
        final after = await IsarService.instance.getSyncRecord(r.id);
        expect(after?.retryCount, 1);
      });
    }
  });

  group('ISS-051 one-deep follow-up', () {
    test('forceReconcile while a cycle runs is queued and replayed, not dropped', () async {
      adapter.handler = (_) => _down;
      final release = Completer<void>();
      adapter.hold = release.future;
      final cycle = SyncEngine.instance.triggerSync();
      for (var i = 0; i < 200 && !SyncEngine.instance.isSyncing; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      final busyAtCall = SyncEngine.instance.isSyncing;
      var reconcileDone = false;
      final reconcile = SyncEngine.instance.forceReconcileWithServer().then((_) => reconcileDone = true);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(reconcileDone, isFalse, reason: 'busy reconcile must wait, not return dropped');
      final beforeRelease = adapter.log.length;
      adapter.hold = null;
      release.complete();
      await cycle.timeout(const Duration(seconds: 10));
      await reconcile.timeout(const Duration(seconds: 10));
      expect(adapter.log.length, greaterThan(beforeRelease),
          reason: 'queued reconcile ran its own reachability check after the cycle');
      expect(SyncEngine.instance.isSyncing, isFalse);
      expect(busyAtCall, isTrue, reason: 'test precondition: cycle was running');
    });
  });

  group('ISS-069 bulk chapters', () {
    test('syncChaptersProgressBulk uses one updateChapters call', () async {
      adapter.handler = (_) => (body: {'data': {'updateChapters': {'chapters': <dynamic>[]}}}, status: 200);
      await SyncEngine.instance.syncChaptersProgressBulk([1, 2, 3, 3], isRead: true);
      final bulk = adapter.log.where((g) => g.contains('updateChapters(')).toList();
      expect(bulk, hasLength(1));
      expect(adapter.log.where((g) => g.contains('updateChapter(')), isEmpty);
      expect(await pending(), isEmpty);
    });
    test('Incognito: bulk path sends nothing', () async {
      SettingsService.instance.incognitoMode = true;
      await SyncEngine.instance.syncChaptersProgressBulk([1, 2], isRead: true);
      expect(adapter.log.where((g) => g.contains('updateChapters')), isEmpty);
    });
  });
}
