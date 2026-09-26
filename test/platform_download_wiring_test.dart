import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Platform-wiring audit for the v1.5 download overhaul.
///
/// The plugin registrant files and manifests are generated/merged at build
/// time, so these file-level assertions are the only way to catch a dropped
/// permission, missing service declaration, or missing plugin registration
/// without building an APK.
void main() {
  group('Android manifest (downloads + foreground service)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    test('declares notification + foreground-service permissions', () {
      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
      expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
      expect(manifest, contains('android.permission.FOREGROUND_SERVICE_DATA_SYNC'));
      expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
      expect(manifest, contains('android.permission.WAKE_LOCK'));
    });

    test('declares the dataSync foreground service (unsplittable name)', () {
      expect(
        manifest,
        contains('android:name="com.pravera.flutter_foreground_task.service.ForegroundService"'),
      );
      expect(manifest, contains('android:foregroundServiceType="dataSync"'));
      expect(manifest, contains('android:exported="false"'));
    });

    test('no network-security / internet regression', () {
      expect(manifest, contains('android.permission.INTERNET'));
      expect(manifest, contains('android:networkSecurityConfig="@xml/network_security_config"'));
    });
  });

  group('Android build config (downloading deps + SDK)', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();

    test('compileSdk/targetSdk 36 with core library desugaring (fln needs it < API 26)', () {
      expect(gradle, contains('compileSdk 36'));
      expect(gradle, contains('targetSdk 36'));
      expect(gradle, contains('coreLibraryDesugaringEnabled true'));
      expect(gradle, contains('desugar_jdk_libs'));
    });

    test('minSdk pinned to 24 (flutter_local_notifications 22.x hard requirement)', () {
      expect(gradle, contains('minSdk 24'));
    });
  });

  group('iOS wiring (downloads notifications)', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    test('usage description present so the permission prompt is legitimate', () {
      expect(plist, contains('NSUserNotificationsUsageDescription'));
    });

    test('no UIBackgroundModes grant — iOS background downloads are by design '
        'Android-only; downloads resume on foreground', () {
      expect(plist, isNot(contains('UIBackgroundModes')));
    });
  });

  group('iOS plugin registration', () {
    final registrant = File('ios/Runner/GeneratedPluginRegistrant.m').readAsStringSync();

    test('flutter_foreground_task is registered', () {
      expect(registrant, contains('flutter_foreground_task/FlutterForegroundTaskPlugin.h'));
      expect(registrant, contains('FlutterForegroundTaskPlugin registerWithRegistrar'));
    });

    test('flutter_local_notifications is registered', () {
      expect(registrant, contains('flutter_local_notifications/FlutterLocalNotificationsPlugin.h'));
      expect(registrant, contains('FlutterLocalNotificationsPlugin registerWithRegistrar'));
    });
  });

  group('Android plugin registration (GeneratedPluginRegistrant.java)', () {
    test('both plugins are registered at build time', () {
      final files = <String>[];
      final dir = Directory('android/app/src/main/java/com/sunfire/app');
      if (dir.existsSync()) {
        dir.listSync(recursive: true).whereType<File>().forEach((f) => files.add(f.readAsStringSync()));
      }
      if (files.isEmpty) {
        markTestSkipped('GeneratedPluginRegistrant.java is produced at build time, not checked in');
        return;
      }
      for (final content in files) {
        if (content.contains('GeneratedPluginRegistrant')) {
          expect(content, contains('FlutterForegroundTaskPlugin'));
          expect(content, contains('FlutterLocalNotificationsPlugin'));
        }
      }
    });
  });

  group('Dependency versions (pubspec.yaml)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    test('foreground-task and notifications plugins pinned to v11/v22 lines', () {
      expect(pubspec, contains('flutter_foreground_task: ^11.0.3'));
      expect(pubspec, contains('flutter_local_notifications: ^22.3.0'));
    });
  });

  group('main.dart wiring (init order + pause signal)', () {
    final mainDart = File('lib/main.dart').readAsStringSync();

    test('FGS is initialized at startup', () {
      expect(mainDart, contains('DownloadForegroundTask.instance.initialize()'));
    });

    test('FGS "Stop" button pause signal is handled', () {
      expect(mainDart, contains('FlutterForegroundTask.addTaskDataCallback'));
      expect(mainDart, contains("data['action'] == 'pause'"));
      expect(mainDart, contains('pauseLocalQueue()'));
    });

    test('notification service initializes before download manager', () {
      final notifIdx = mainDart.indexOf('NotificationService.instance.initialize()');
      final dlIdx = mainDart.indexOf('DownloadManagerService.instance.initialize()');
      expect(notifIdx, isNot(-1));
      expect(dlIdx, isNot(-1));
      expect(notifIdx, lessThan(dlIdx));
    });
  });

  group('Notification service wiring', () {
    final notif = File('lib/src/core/services/notification_service.dart').readAsStringSync();

    test('downloads channel + notification ids exist', () {
      expect(notif, contains("downloadsChannelId = 'sunfire_downloads'"));
      expect(notif, contains('downloadProgressNotificationId = 4001'));
      expect(notif, contains('downloadSummaryNotificationId = 4003'));
    });

    test('every download notification id is distinct', () {
      // Android keys a notification by (id, tag) and Sunfire posts all of these
      // with no tag, so a shared id means one silently replaces the other.
      // `downloadsResumedNotificationId` and `downloadSummaryNotificationId`
      // were both 4002, which meant the foreground "Downloads resumed" toast
      // ate the batch-completion summary — the user's only confirmation that an
      // overnight download succeeded — so they re-run the batch.
      //
      // This asserts the property rather than the literal values, so adding a
      // notification later cannot silently reintroduce a collision.
      final ids = RegExp(r'static const int (\w+NotificationId) = (\d+);')
          .allMatches(notif)
          .map((m) => (name: m.group(1)!, value: int.parse(m.group(2)!)))
          .toList();

      expect(ids.length, greaterThanOrEqualTo(3),
          reason: 'expected to find the download notification id constants');

      final downloadIds = ids.where((e) => e.name.toLowerCase().contains('download')).toList();
      expect(downloadIds.length, greaterThanOrEqualTo(3));

      final seen = <int, String>{};
      for (final entry in downloadIds) {
        final previous = seen[entry.value];
        expect(
          previous,
          isNull,
          reason: '${entry.name} and $previous both use notification id ${entry.value}; '
              'one will silently replace the other',
        );
        seen[entry.value] = entry.name;
      }
    });

    test('Android 13+ runtime permission is requested at startup', () {
      expect(notif, contains('requestNotificationsPermission()'));
    });

    test('completion notification respects the settings toggle', () {
      expect(notif, contains('downloadNotificationsEnabled'));
    });
  });
}