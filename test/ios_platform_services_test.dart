// test/ios_platform_services_test.dart
//
// I8.3/I8.4: Live Activities + Siri Shortcuts channel contracts.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/live_activities_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const liveChannel = MethodChannel('sunfire/live_activities');
  const siriChannel = MethodChannel('sunfire/siri_shortcuts');

  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(liveChannel, (call) async {
      calls.add(call.method);
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(siriChannel, (call) async {
      calls.add(call.method);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(liveChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(siriChannel, null);
  });

  test('start/update/end reading session calls channel in order', () async {
    final svc = LiveActivitiesService.instance;
    expect(svc.hasActiveSession, isFalse);
    await svc.startReading(mangaTitle: 'Berserk', chapterName: 'Ch 1');
    expect(svc.hasActiveSession, isTrue);
    await svc.updateProgress(0.5);
    await svc.endReading();
    expect(svc.hasActiveSession, isFalse);
    expect(calls, ['startReading', 'updateReading', 'endReading']);
  });

  test('update without session is a no-op', () async {
    await LiveActivitiesService.instance.endReading();
    calls.clear();
    await LiveActivitiesService.instance.updateProgress(0.9);
    expect(calls, isEmpty);
  });

  test('end without session is a no-op', () async {
    await LiveActivitiesService.instance.endReading();
    calls.clear();
    await LiveActivitiesService.instance.endReading();
    expect(calls, isEmpty);
  });

  test('siri donate calls channel', () async {
    await SiriShortcutsService.instance.donateContinueReading(
      mangaTitle: 'Berserk',
      chapterName: 'Ch 1',
      mangaId: 42,
    );
    expect(calls, ['donateContinueReading']);
  });

  test('services survive absent channel', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(liveChannel, (call) async {
      throw PlatformException(code: 'no_channel');
    });
    // Must not throw.
    await LiveActivitiesService.instance.startReading(
        mangaTitle: 'X', chapterName: 'Y');
    await LiveActivitiesService.instance.updateProgress(0.1);
    await LiveActivitiesService.instance.endReading();
  });
}
