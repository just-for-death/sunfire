// IMP-025: QuickJS loads off the startup path; callers await whenReady.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    dir = await Directory.systemTemp.createTemp('sunfire_imp025');
    QuickJsService.testOnlyExtensionDirs = [dir.path];
    QuickJsService.instance.deferAutoInstall = true; // no network
  });

  tearDownAll(() async {
    QuickJsService.testOnlyExtensionDirs = null;
    await dir.delete(recursive: true);
  });

  test('initialize is tracked: isStarting while loading, whenReady completes after', () async {
    final qjs = QuickJsService.instance;
    final f = qjs.initialize();
    expect(qjs.isStarting, isTrue);
    await qjs.whenReady;
    await f;
    expect(qjs.isStarting, isFalse);
    expect(qjs.isInitialized, isTrue);
  });

  test('local-source calls wait for an in-flight initialize instead of racing it', () async {
    final qjs = QuickJsService.instance;
    var initDone = false;
    final init = qjs.initialize().then((_) => initDone = true);
    final filters = await qjs.fetchSourceFiltersLocal('not_installed');
    expect(initDone, isTrue, reason: 'fetch resumed only after whenReady');
    expect(filters, isEmpty);
    await init;
  });

  test('startup failure: whenReady never throws; callers see unavailable', () async {
    final qjs = QuickJsService.instance;
    QuickJsService.debugInitLoadOverride = () async => throw StateError('disk gone');
    addTearDown(() => QuickJsService.debugInitLoadOverride = null);
    await qjs.initialize().catchError((Object _) {});
    await expectLater(qjs.whenReady, completes);
    expect(qjs.isStarting, isFalse);
    expect(qjs.isInitialized, isFalse);
    expect(qjs.availabilityError, contains('failed to initialize'));
  });
}
