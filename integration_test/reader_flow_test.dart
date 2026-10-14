// IMP-048 (UIX half): on-device reader flow. Run with
//   flutter test integration_test/reader_flow_test.dart -d linux
// Offline only: chapter pages come from local PNG files through
// NavigationController.debugResolveOverride; incognito keeps sync off.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/db/models/sync_meta.dart';
import 'package:sunfire/src/core/db/models/sync_record.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/reader_screen.dart';

const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late List<String> pages;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('sunfire_it_reader');
    await Isar.initializeIsarCore();
    await Isar.open(
      [MangaSchema, ChapterSchema, CategorySchema, SyncRecordSchema, SyncMetaSchema],
      directory: tempDir.path,
      inspector: false,
    );
    await IsarService.instance.initialize();
    pages = [for (var i = 0; i < 4; i++) '${tempDir.path}/p$i.png'];
    for (final p in pages) {
      File(p).writeAsBytesSync(_png);
    }
  });

  tearDownAll(() async {
    NavigationController.debugResetTestOverrides();
    await IsarService.instance.isar.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    SettingsService.instance.incognitoMode = true;
    SettingsService.instance.keepScreenAwake = false;
    SettingsService.instance.readingMode = 'Paged LTR';
    final isar = IsarService.instance.isar;
    await isar.writeTxn(() => isar.clear());
    await IsarService.instance.saveManga(Manga()
      ..serverId = 7
      ..title = 'Flow'
      ..sourceName = 'local');
    await IsarService.instance.saveChapter(Chapter()
      ..serverId = 70
      ..mangaId = 7
      ..name = 'Ch 1'
      ..chapterNumber = 1
      ..url = '/flow/ch1');
    await IsarService.instance.saveChapter(Chapter()
      ..serverId = 71
      ..mangaId = 7
      ..name = 'Ch 2'
      ..chapterNumber = 2
      ..url = '/flow/ch2');
    NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async =>
        ChapterPagesResult(pageUrls: pages, source: ContentSourceType.localExtension);
  });

  tearDown(NavigationController.debugResetTestOverrides);

  Future<void> settle(WidgetTester t, [int frames = 20]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('open chapter -> pages render -> keyboard next/prev page', (t) async {
    await t.pumpWidget(const MaterialApp(home: ReaderScreen(chapterServerId: 70)));
    await settle(t);
    expect(find.text('Loading Chapter...'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(Image), findsWidgets);

    final pv = t.widget<PageView>(find.byType(PageView));
    final controller = pv.controller!;
    expect(controller.page?.round(), 0);

    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(t, 10);
    expect(controller.page?.round(), 1, reason: 'arrow right turns one page');

    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await settle(t, 10);
    expect(controller.page?.round(), 0, reason: 'arrow left turns back');

    await t.pumpWidget(const SizedBox());
    await settle(t, 4);
  });

  testWidgets('incognito: paging then closing the reader persists no progress', (t) async {
    await t.pumpWidget(const MaterialApp(home: ReaderScreen(chapterServerId: 70)));
    await settle(t);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(t, 10);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(t, 10);
    await t.pumpWidget(const SizedBox()); // dispose flushes progress
    await settle(t, 10);
    final ch = await IsarService.instance.getChapterByServerId(70);
    expect(ch!.lastPageRead, 0, reason: 'incognito must not write progress');
  });
}
