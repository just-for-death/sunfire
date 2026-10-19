// Golden baselines for the DB-backed feature screens at phone and tablet
// widths.
//
// The library and manga-detail screens read real rows out of Isar, so each
// golden seeds a throwaway database (see test/support/isar_harness.dart) and
// renders with the shipped dark theme. No thumbnails are seeded, so covers
// resolve to the deterministic placeholder instead of a network image.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/library/library_screen.dart';
import 'package:sunfire/src/features/manga_detail/manga_detail_screen.dart';
import 'package:sunfire/src/ui/design_system/sunfire_theme.dart';

import '../support/isar_harness.dart';

Future<void> _seed() async {
  for (var i = 1; i <= 4; i++) {
    await IsarService.instance.saveManga(
      Manga()
        ..serverId = 100 + i
        ..title = 'Sample Series $i'
        ..author = 'Author $i'
        ..inLibrary = true
        ..inLibraryAt = DateTime(2026, 1, i).millisecondsSinceEpoch
        ..genres = const ['Action', 'Adventure']
        ..lang = 'en'
        ..chapterCount = 3,
    );
    for (var c = 1; c <= 3; c++) {
      await IsarService.instance.saveChapter(
        Chapter()
          ..serverId = 1000 + (i * 10) + c
          ..mangaId = 100 + i
          ..name = 'Chapter $c'
          ..chapterNumber = c.toDouble()
          ..url = '/sample/$i/ch$c'
          ..pageCount = 20,
      );
    }
  }
}

Future<void> _pump(WidgetTester tester, Widget screen, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(theme: SunfireTheme.buildDarkTheme(), home: screen),
    );
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await tester.pump();
    }
  });
  // Let any entrance/refresh animations settle to a stable frame.
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => '/tmp/sunfire_test',
  );

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in const [
    'dev.fluttercommunity.plus/connectivity',
    'dev.fluttercommunity.plus/connectivity_status',
    'dev.fluttercommunity.plus/battery',
    'dev.fluttercommunity.plus/charging',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), (call) async => null);
  }

  setUpAll(() async {
    await bootIsarHarness();
  });

  tearDownAll(() async {
    await teardownIsarHarness();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SettingsService.instance.incognitoMode = true;
    await clearIsarHarness();
    await _seed();
  });

  testWidgets('library screen — phone golden', (tester) async {
    await _pump(tester, const LibraryScreen(), const Size(390, 844));
    await expectLater(
      find.byType(LibraryScreen),
      matchesGoldenFile('goldens/library_screen_phone.png'),
    );
  });

  testWidgets('library screen — tablet golden', (tester) async {
    await _pump(tester, const LibraryScreen(), const Size(1024, 768));
    await expectLater(
      find.byType(LibraryScreen),
      matchesGoldenFile('goldens/library_screen_tablet.png'),
    );
  });

  testWidgets('manga detail screen — phone golden', (tester) async {
    await _pump(
      tester,
      const MangaDetailScreen(mangaServerId: 101),
      const Size(390, 844),
    );
    await expectLater(
      find.byType(MangaDetailScreen),
      matchesGoldenFile('goldens/manga_detail_phone.png'),
    );
  });

  testWidgets('manga detail screen — tablet two-pane golden', (tester) async {
    await _pump(
      tester,
      const MangaDetailScreen(mangaServerId: 101),
      const Size(1024, 768),
    );
    await expectLater(
      find.byType(MangaDetailScreen),
      matchesGoldenFile('goldens/manga_detail_tablet.png'),
    );
  });
}
