// IMP-005: per-series reader settings roam through Suwayomi manga meta.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';

class _FakeMetaClient extends GraphQLClientService {
  _FakeMetaClient({this.configured = true}) : super.forTesting();
  final bool configured;
  Map<String, String>? meta = {};
  final sets = <String>[];
  final deletes = <String>[];
  int fetches = 0;

  @override
  bool get isConfigured => configured;
  @override
  Future<Map<String, String>?> fetchSunfireMangaMeta(int mangaId) async {
    fetches++;
    return meta == null ? null : Map.of(meta!);
  }

  @override
  Future<bool> setMangaMeta(int mangaId, String key, String value) async {
    sets.add('$mangaId:$key');
    meta?[key] = value;
    return true;
  }

  @override
  Future<bool> deleteMangaMeta(int mangaId, String key) async {
    deletes.add('$mangaId:$key');
    meta?.remove(key);
    return true;
  }
}

void main() {
  late SettingsService s;
  final manga = Manga()
    ..id = 7
    ..serverId = 99;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = SettingsService.instance;
    await s.initialize();
  });

  test('newer local override is pushed under the sunfire_ key', () async {
    final c = _FakeMetaClient();
    await s.setReaderOverrideJson(7, {'readingMode': 'webtoon'});
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.pushed);
    expect(c.sets, ['99:$kReaderSettingsMetaKey']);
    final env = decodeReaderSettingsMeta(c.meta![kReaderSettingsMetaKey])!;
    expect(env.o, {'readingMode': 'webtoon'});
    expect(env.t, s.readerOverrideUpdatedAt(7));
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.none);
    expect(c.sets, hasLength(1));
  });

  test('newer server override is pulled with its timestamp', () async {
    final c = _FakeMetaClient()
      ..meta = {kReaderSettingsMetaKey: encodeReaderSettingsMeta({'readingMode': 'rtl'}, 1 << 50)};
    await s.setReaderOverrideJson(7, {'readingMode': 'webtoon'});
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.pulled);
    expect(s.readerOverrideJson(7), {'readingMode': 'rtl'});
    expect(s.readerOverrideUpdatedAt(7), 1 << 50);
    expect(c.sets, isEmpty);
  });

  test('local reset to "All" deletes server meta; empty server value clears local', () async {
    final c = _FakeMetaClient()
      ..meta = {kReaderSettingsMetaKey: encodeReaderSettingsMeta({'readingMode': 'rtl'}, 1)};
    await s.setReaderOverrideJson(7, null);
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.pushed);
    expect(c.deletes, ['99:$kReaderSettingsMetaKey']);

    c.meta = {kReaderSettingsMetaKey: jsonEncode({'v': 1, 't': 1 << 50, 'o': <String, Object>{}})};
    await s.setReaderOverrideJson(7, {'readingMode': 'webtoon'}, updatedAtMs: 5);
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.pulled);
    expect(s.readerOverrideJson(7), isNull);
  });

  test('no network in incognito, unconfigured, local-only manga; offline is a no-op', () async {
    await s.setReaderOverrideJson(7, {'readingMode': 'webtoon'});
    final off = _FakeMetaClient(configured: false);
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: off), ReaderSettingsMetaSync.none);
    expect(off.fetches, 0);

    final c = _FakeMetaClient();
    expect(await syncReaderSettingsMeta(manga: Manga()..id = 7, settings: s, client: c), ReaderSettingsMetaSync.none);
    s.incognitoMode = true;
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.none);
    expect(c.fetches, 0);
    s.incognitoMode = false;

    c.meta = null; // server unreachable
    expect(await syncReaderSettingsMeta(manga: manga, settings: s, client: c), ReaderSettingsMetaSync.none);
    expect(c.sets, isEmpty);
  });

  test('garbled meta is ignored', () {
    expect(decodeReaderSettingsMeta('nope'), isNull);
    expect(decodeReaderSettingsMeta('{"t":"x","o":{}}'), isNull);
    expect(decodeReaderSettingsMeta(null), isNull);
  });
}
