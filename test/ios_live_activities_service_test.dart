// I8.3/I8.4: Live Activities + Siri services are best-effort and must not
// throw when the platform channel is absent (desktop / test VM).

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/sync/live_activities_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const liveChannel = MethodChannel('sunfire/live_activities');
  const siriChannel = MethodChannel('sunfire/siri_shortcuts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(liveChannel, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(siriChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(liveChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(siriChannel, null);
    // Ensure no leaked session between tests.
    // ignore: discarded_futures
    LiveActivitiesService.instance.endReading();
  });

  test('start/update/end reading session lifecycle', () async {
    final svc = LiveActivitiesService.instance;
    expect(svc.hasActiveSession, isFalse);

    await svc.startReading(mangaTitle: 'Berserk', chapterName: 'Ch 1');
    expect(svc.hasActiveSession, isTrue);

    await svc.updateProgress(0.4);
    expect(svc.hasActiveSession, isTrue);

    await svc.endReading();
    expect(svc.hasActiveSession, isFalse);
  });

  test('updateProgress is a no-op without an active session', () async {
    final svc = LiveActivitiesService.instance;
    expect(svc.hasActiveSession, isFalse);
    await svc.updateProgress(0.9); // must not throw
    expect(svc.hasActiveSession, isFalse);
  });

  test('Siri donateContinueReading does not throw without plugin', () async {
    await SiriShortcutsService.instance.donateContinueReading(
      mangaTitle: 'One Piece',
      chapterName: 'Ch 1000',
      mangaId: 7,
    );
  });
}
