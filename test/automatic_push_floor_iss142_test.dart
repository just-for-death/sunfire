// ISS-142: a stale device's automatic progress must never rewind the server;
// only explicit actions may lower it. Fake server only.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/read_state_merge.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

class _FakeServer extends GraphQLClientService {
  _FakeServer() : super.forTesting();
  bool isRead = false;
  int page = 0;
  final pushes = <int>[];
  final meta = <int, String>{};
  bool reachable = true;

  @override
  bool get isConfigured => true;
  @override
  Future<bool> checkServerReachable({bool force = false}) async => reachable;
  @override
  Future<({bool isRead, int lastPageRead})?> fetchChapterReadState(int chapterId) async =>
      reachable ? (isRead: isRead, lastPageRead: page) : null;
  @override
  Future<({Map<String, dynamic>? data, bool wasTransportFailure})> updateChapterReadStatusWithClassification(
      int chapterId, bool r, int p) async {
    pushes.add(p);
    isRead = r;
    page = p;
    return (data: <String, dynamic>{'ok': true}, wasTransportFailure: false);
  }

  @override
  Future<bool> setChapterMeta(int chapterId, String key, String value) async {
    meta[chapterId] = value;
    return true;
  }
}

Chapter _device(int page) => Chapter()
  ..serverId = 7
  ..lastPageRead = page
  ..syncedIsRead = false
  ..syncedLastPageRead = page;

void main() {
  late _FakeServer server;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    server = _FakeServer();
    GraphQLClientService.debugInstance = server;
  });

  test('clampAutomaticProgress floors page (max) and read (OR)', () {
    expect(clampAutomaticProgress(isRead: false, lastPageRead: 5, serverIsRead: true, serverPage: 20),
        (isRead: true, lastPageRead: 20));
    expect(clampAutomaticProgress(isRead: false, lastPageRead: 25, serverPage: 20), (isRead: false, lastPageRead: 25));
    expect(clampAutomaticProgress(isRead: false, lastPageRead: 5), (isRead: false, lastPageRead: 5));
  });

  test('A reads to 20; stale B (page 5, automatic) cannot rewind; all end at 20', () async {
    final a = _device(0);
    final b = _device(5);
    await SyncEngine.instance.syncChapterProgress(7, isRead: false, lastPageRead: 20); // A
    a.lastPageRead = 20;
    expect(server.page, 20);

    await SyncEngine.instance.syncChapterProgress(7, isRead: false, lastPageRead: 5); // stale B
    expect(server.page, 20, reason: 'automatic push floored at the server value');
    expect(server.pushes.last, 20);

    for (final d in [a, b]) {
      applyServerReadState(d, serverIsRead: server.isRead, serverPage: server.page, hasPendingMutation: false);
      expect(d.lastPageRead, 20);
    }
  });

  test('an explicit restart from B does lower the server, and A follows', () async {
    server.page = 20;
    final a = _device(20);
    final b = _device(20)
      ..applyReadState(false); // restart: explicit, page 0
    await SyncEngine.instance
        .syncChapterProgress(7, isRead: false, lastPageRead: b.lastPageRead, explicit: true);
    expect(server.page, 0);
    await SyncEngine.instance.pushReadActionMeta([7], b.readStateActionAt!);
    applyServerReadState(a,
        serverIsRead: server.isRead,
        serverPage: server.page,
        serverMetaActionAt: int.parse(server.meta[7]!),
        hasPendingMutation: false);
    expect(a.lastPageRead, 0);
    // B keeps reading after the restart: automatic page 3 is above the new floor.
    await SyncEngine.instance.syncChapterProgress(7, isRead: false, lastPageRead: 3);
    expect(server.page, 3);
  });

  test('server unreachable for the floor fetch: snapshot is the floor', () async {
    final out = await SyncEngine.instance.floorAutomaticProgress(7, isRead: false, lastPageRead: 5);
    expect(out.lastPageRead, 5, reason: 'no fetch result and no local row → unchanged');
    server.reachable = false;
    server.page = 30;
    final out2 = await SyncEngine.instance.floorAutomaticProgress(7, isRead: false, lastPageRead: 5);
    expect(out2.lastPageRead, 5);
  });
}
