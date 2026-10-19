// UIS-15: DB-backed feature screens at narrow widths, large text, and with
// semantics enabled.
//
// Unlike the settings screens, the library and manga-detail screens read real
// rows out of Isar, so these tests boot a throwaway database and seed it. They
// are genuine layout/a11y guards: a RenderFlex overflow surfaces through
// `tester.takeException()`, and unlabeled controls surface through the shared
// semantics auditor.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/db/models/category.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/library/library_screen.dart';
import 'package:sunfire/src/features/manga_detail/manga_detail_screen.dart';

import '../support/a11y_semantics_audit.dart';
import '../support/isar_harness.dart';

const _longTitle =
    'A Very Long Manga Title That Has No Business Fitting On One Line In A '
    'Narrow Phone With Large Accessibility Text Enabled';

Future<void> _seed() async {
  await IsarService.instance.saveCategory(
    Category()
      ..serverId = 1
      ..name = 'Favourites With An Unnecessarily Long Category Name'
      ..isDefault = true,
  );
  await IsarService.instance.saveManga(
    Manga()
      ..serverId = 101
      ..title = _longTitle
      ..author = 'An Author With A Fairly Long Name'
      ..artist = 'An Artist With A Fairly Long Name'
      ..description = 'A long description. ' * 20
      ..inLibrary = true
      ..inLibraryAt = DateTime.now().millisecondsSinceEpoch
      ..categoryIds = [1]
      ..genres = ['Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Sci-Fi']
      ..lang = 'en'
      ..chapterCount = 3,
  );
  for (var i = 1; i <= 3; i++) {
    await IsarService.instance.saveChapter(
      Chapter()
        ..serverId = 1000 + i
        ..mangaId = 101
        ..name = 'Chapter $i — A Chapter Title That Is Long Enough To Need '
            'Ellipsis On A Narrow Phone'
        ..chapterNumber = i.toDouble()
        ..url = '/test/ch$i'
        ..pageCount = 20,
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(320, 640),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.runAsync(() async {
    await tester.pumpWidget(MaterialApp(home: screen));
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await tester.pump();
    }
  });
  await tester.pump();
}

Future<void> _drainScrollables(WidgetTester tester) async {
  for (var pass = 0; pass < 12; pass++) {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) break;
    await tester.drag(scrollables.first, const Offset(0, -600));
    await tester.pump();
  }
  await tester.pump();
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(const SizedBox());
    await Future<void>.delayed(const Duration(milliseconds: 60));
  });
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => '/tmp/sunfire_test',
  );

  // The library screen subscribes to connectivity/battery platform streams.
  // Neither plugin exists in the test host, so stub their channels to a no-op
  // instead of letting a MissingPluginException fail the layout assertions.
  setUp(() {
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
  });

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

  final screens = <String, Widget>{
    'LibraryScreen': const LibraryScreen(),
    'MangaDetailScreen': const MangaDetailScreen(mangaServerId: 101),
  };
  const sizes = <String, Size>{
    'narrow phone 320x640': Size(320, 640),
    'small phone 360x640': Size(360, 640),
  };
  const scales = <String, double>{'1.0x': 1.0, '1.3x': 1.3, '1.5x': 1.5};

  for (final entry in screens.entries) {
    for (final s in sizes.entries) {
      for (final sc in scales.entries) {
        testWidgets(
          '${entry.key} @ ${s.key} ${sc.key} has no overflow',
          (tester) async {
            await _pump(
              tester,
              entry.value,
              size: s.value,
              textScale: sc.value,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} initial layout at ${s.key} ${sc.key}',
            );
            await _drainScrollables(tester);
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} scrolled layout at ${s.key} ${sc.key}',
            );
            await _unmount(tester);
          },
        );
      }
    }
  }

  for (final entry in screens.entries) {
    testWidgets('${entry.key} exposes labels on every actionable node',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, entry.value);
      await _drainScrollables(tester);

      // The test binding owns a single view; its pipeline owner is the correct
      // semantics root here.
      // ignore: deprecated_member_use
      final owner = tester.binding.pipelineOwner.semanticsOwner;
      expect(owner, isNotNull, reason: 'semantics owner unavailable');
      final root = owner!.rootSemanticsNode;
      expect(root, isNotNull, reason: 'no semantics root');

      final issues = <String>[];
      collectUnlabeledActionable(root!, issues);
      expect(
        issues,
        isEmpty,
        reason: '${entry.key} a11y:\n${issues.join('\n')}',
      );
      handle.dispose();
      await _unmount(tester);
    });
  }
}
