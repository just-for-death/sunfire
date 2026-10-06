// ISS-064: every `_update('…')` / `_updateServer('…')` key used by settings
// screens must be a valid PartialSettingsTypeInput or PartialUserSettingsTypeInput
// field (Suwayomi v2.4+).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/suwayomi_settings_fields.dart';

final _updateKeyRe = RegExp(r"""_update(?:Server)?\(\s*'([^']+)'""");

const _settingsScreens = [
  'lib/src/features/settings/server_settings_screen.dart',
  'lib/src/features/settings/browse_settings_screen.dart',
  'lib/src/features/settings/library_settings_screen.dart',
  'lib/src/features/settings/downloads_settings_screen.dart',
  'lib/src/features/settings/backup_settings_screen.dart',
];

Set<String> _keysInFile(String path) {
  final text = File(path).readAsStringSync();
  return _updateKeyRe.allMatches(text).map((m) => m.group(1)!).toSet();
}

void main() {
  test('every settings _update key is a known server or user input field', () {
    final allKeys = <String>{};
    for (final path in _settingsScreens) {
      expect(File(path).existsSync(), isTrue, reason: path);
      allKeys.addAll(_keysInFile(path));
    }
    expect(allKeys, isNotEmpty);

    final unknown = allKeys
        .where(
          (k) =>
              !isServerSettingsInputField(k) && !isUserSettingsInputField(k),
        )
        .toList()
      ..sort();
    expect(
      unknown,
      isEmpty,
      reason: 'Unknown settings keys (likely mangled): $unknown',
    );
  });

  test('user settings keys are not accepted by PartialSettingsTypeInput', () {
    // Guards against routing regressions that send per-user keys to setSettings.
    final overlap = kPartialUserSettingsInputFields.intersection(
      kPartialSettingsInputFields,
    );
    expect(overlap, isEmpty);
  });

  test('opds/syncYomi/autoDownload/exclude/updateMangas are user settings', () {
    for (final key in [
      'opdsItemsPerPage',
      'syncYomiEnabled',
      'syncYomiHost',
      'syncYomiApiKey',
      'autoDownloadNewChapters',
      'autoDownloadNewChaptersLimit',
      'autoDownloadIgnoreReUploads',
      'excludeEntryWithUnreadChapters',
      'excludeCompleted',
      'excludeNotStarted',
      'excludeUnreadChapters',
      'updateMangas',
    ]) {
      expect(isUserSettingsInputField(key), isTrue, reason: key);
      expect(isServerSettingsInputField(key), isFalse, reason: key);
    }
  });

  test('embedded field lists match introspected schema when available', () {
    final candidates = [
      'test/fixtures/suwayomi_schema.json',
      '${Platform.environment['HOME']}/.cache/sunfire_analyzer/schema.json',
      '/workspace/sunfire_audit/suwayomi_schema.json',
    ];
    File? schemaFile;
    for (final p in candidates) {
      final f = File(p);
      if (f.existsSync()) {
        schemaFile = f;
        break;
      }
    }
    if (schemaFile == null) {
      // ignore: avoid_print
      print('schema json not found — skipping live introspection compare');
      return;
    }

    final raw = Map<String, dynamic>.from(jsonDecode(schemaFile.readAsStringSync()) as Map);
    final types = ((raw['data'] as Map<String, dynamic>?)?['__schema'] as Map<String, dynamic>?)?['types'] as List<dynamic>? ??
        (raw['__schema'] as Map<String, dynamic>?)?['types'] as List<dynamic>? ??
        const <dynamic>[];

    Set<String> fieldsOf(String typeName) {
      for (final t in types) {
        if (t is! Map) continue;
        final map = Map<String, dynamic>.from(t);
        if (map['name'] != typeName) continue;
        final fields = map['inputFields'] as List<dynamic>? ?? const <dynamic>[];
        return {
          for (final f in fields)
            if (f is Map) Map<String, dynamic>.from(f)['name'] as String,
        };
      }
      return <String>{};
    }

    final server = fieldsOf('PartialSettingsTypeInput');
    final user = fieldsOf('PartialUserSettingsTypeInput');
    expect(server, isNotEmpty);
    expect(user, isNotEmpty);
    expect(kPartialSettingsInputFields, server);
    expect(kPartialUserSettingsInputFields, user);
  });

  test('fetchServerSettings source does not select secret fields', () {
    final gql = File('lib/src/core/sync/graphql_client_service.dart')
        .readAsStringSync();
    // Narrow to fetchServerSettings body.
    final start = gql.indexOf('Future<Map<String, dynamic>?> fetchServerSettings');
    final end = gql.indexOf('Future<Map<String, dynamic>?> updateServerSettings');
    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));
    final body = gql.substring(start, end);
    for (final secret in [
      'authPassword',
      'socksProxyPassword',
      'syncYomiApiKey',
      'databasePassword',
    ]) {
      expect(
        body.contains(secret),
        isFalse,
        reason: 'fetchServerSettings must not select $secret (ISS-065)',
      );
    }
    expect(body.contains('userSettings'), isTrue);
  });
}
