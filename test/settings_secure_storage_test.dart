// UIX-01: SettingsService.initialize() must never abort because secure
// storage (keychain / keystore / libsecret) throws.
// UIX-10: the proxy URL never stays in plaintext prefs once it has been
// migrated, and a URL set while secure storage is unavailable is kept for the
// current session only (no plaintext fallback).
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/repo_manager.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

const _secureStorageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
const _proxyUrl = 'http://proxy.local:8191/v1';
const _repoUrl = 'https://example.com/sunfire-repo/index.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService secure storage guard', () {
    final secureCalls = <String>[];

    setUp(() async {
      await _resetSettingsProxyState();
      secureCalls.clear();
      MClient.cfProxyUrl = '';
      // flutter_test_config.dart installs an in-memory mock; route this test
      // through the real method channel so the platform failure is exercised.
      FlutterSecureStoragePlatform.instance = MethodChannelFlutterSecureStorage();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_secureStorageChannel, (call) async {
        secureCalls.add(call.method);
        throw PlatformException(code: 'KeychainLocked', message: 'keychain is locked');
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_secureStorageChannel, null);
      FlutterSecureStorage.setMockInitialValues({});
      MClient.cfProxyUrl = '';
    });

    test('initialize() completes and applies the legacy prefs proxy when secure read throws', () async {
      SharedPreferences.setMockInitialValues({
        'cf_proxy_url': _proxyUrl,
        'custom_repos': [_repoUrl],
      });

      await expectLater(SettingsService.instance.initialize(), completes);

      expect(secureCalls, contains('read'), reason: 'secure storage must actually have been hit');
      expect(SettingsService.instance.cfProxyUrl, _proxyUrl);
      expect(MClient.cfProxyUrl, _proxyUrl);
      final normalized = RepoManager.normalizeRepoUrl(_repoUrl);
      expect(
        RepoManager.instance.userConfiguredRepos.any((r) => r['url'] == normalized),
        isTrue,
        reason: 'custom repo registration must still run after a secure storage failure',
      );
    });

    test('initialize() completes with no proxy when secure storage throws and prefs are empty', () async {
      SharedPreferences.setMockInitialValues({});

      await expectLater(SettingsService.instance.initialize(), completes);

      expect(secureCalls, contains('read'));
      expect(SettingsService.instance.cfProxyUrl, isEmpty);
      expect(MClient.cfProxyUrl, isEmpty);
    });
  });

  group('UIX-10 proxy URL storage (working secure storage)', () {
    setUp(() async {
      await _resetSettingsProxyState();
      MClient.cfProxyUrl = '';
    });
    tearDown(() {
      FlutterSecureStorage.setMockInitialValues({});
      MClient.cfProxyUrl = '';
    });

    test('legacy plaintext is migrated, verified, then cleared from prefs', () async {
      SharedPreferences.setMockInitialValues({'cf_proxy_url': _credProxyUrl});
      FlutterSecureStorage.setMockInitialValues({});

      await SettingsService.instance.initialize();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), '');
      expect(await _secure.read(key: _secureKey), _credProxyUrl);
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
      expect(MClient.cfProxyUrl, _credProxyUrl);
    });

    test('when prefs and secure copies differ the prefs (older source of truth) wins', () async {
      SharedPreferences.setMockInitialValues({'cf_proxy_url': _credProxyUrl});
      FlutterSecureStorage.setMockInitialValues({_secureKey: 'http://stale:8191/v1'});

      await SettingsService.instance.initialize();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), '');
      expect(await _secure.read(key: _secureKey), _credProxyUrl);
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
    });

    test('setting a new URL never writes it to prefs', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      await SettingsService.instance.initialize();

      SettingsService.instance.cfProxyUrl = _credProxyUrl;
      await SettingsService.instance.pendingProxyPersist;

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), isNot(contains('8191')));
      expect(await _secure.read(key: _secureKey), _credProxyUrl);
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
      expect(MClient.cfProxyUrl, _credProxyUrl);

      // Survives a "restart" via secure storage.
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
    });

    test("setting 'off' disables the proxy and deletes the secure key", () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({_secureKey: _credProxyUrl});
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);

      SettingsService.instance.cfProxyUrl = 'off';
      await SettingsService.instance.pendingProxyPersist;

      expect(SettingsService.instance.cfProxyUrl, isEmpty);
      expect(MClient.cfProxyUrl, isEmpty);
      expect(await _secure.read(key: _secureKey), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), 'off');
    });
  });

  group('UIX-10 proxy URL storage (secure write fails)', () {
    final secureCalls = <String>[];

    setUp(() async {
      await _resetSettingsProxyState();
      secureCalls.clear();
      MClient.cfProxyUrl = '';
      FlutterSecureStoragePlatform.instance = MethodChannelFlutterSecureStorage();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_secureStorageChannel, (call) async {
        secureCalls.add(call.method);
        if (call.method == 'write') {
          throw PlatformException(code: 'NoKeyring', message: 'no secret service');
        }
        return null; // read → nothing stored; delete → ok
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_secureStorageChannel, null);
      FlutterSecureStorage.setMockInitialValues({});
      MClient.cfProxyUrl = '';
    });

    test('migration keeps the legacy plaintext (retry next launch) when the secure write throws', () async {
      SharedPreferences.setMockInitialValues({'cf_proxy_url': _credProxyUrl});

      await expectLater(SettingsService.instance.initialize(), completes);

      expect(secureCalls, contains('write'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), _credProxyUrl);
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
      expect(MClient.cfProxyUrl, _credProxyUrl);
    });

    test('a new URL is session-only with no plaintext fallback', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();

      SettingsService.instance.cfProxyUrl = _credProxyUrl;
      await expectLater(SettingsService.instance.pendingProxyPersist, completes);

      expect(secureCalls, contains('write'));
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl, reason: 'usable this session');
      expect(MClient.cfProxyUrl, _credProxyUrl);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), isNot(contains('8191')),
          reason: 'no plaintext fallback (Jane decision)');

      // Next launch: nothing persisted anywhere.
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.cfProxyUrl, isEmpty);
    });

    test('a new URL replaces (and clears) an unmigrated legacy plaintext URL', () async {
      SharedPreferences.setMockInitialValues({'cf_proxy_url': 'http://old:8191/v1'});
      await SettingsService.instance.initialize();
      expect(SettingsService.instance.cfProxyUrl, 'http://old:8191/v1');

      SettingsService.instance.cfProxyUrl = _credProxyUrl;
      await SettingsService.instance.pendingProxyPersist;

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cf_proxy_url'), '');
      expect(SettingsService.instance.cfProxyUrl, _credProxyUrl);
    });
  });
}

const _credProxyUrl = 'http://u:p@h:8191/v1';
const _secureKey = 'cf_proxy_url_secure';
const _secure = FlutterSecureStorage(
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

/// SettingsService is a singleton; clear its in-memory proxy cache between
/// tests (in-memory secure storage, so the delete cannot fail).
Future<void> _resetSettingsProxyState() async {
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});
  await SettingsService.instance.initialize();
  SettingsService.instance.cfProxyUrl = '';
  await SettingsService.instance.pendingProxyPersist;
}
