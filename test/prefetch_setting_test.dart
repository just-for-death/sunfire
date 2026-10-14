// ISS-130: "Prefetch next chapter" setting (always / wifiOnly / off) gating
// both next-chapter prefetch and upcoming-page prefetch.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/engine/content_resolver_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';

import 'reader_controller_test.mocks.dart';

final _png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, ...List.filled(64, 0)]);
const _urls = ['https://i/0', 'https://i/1', 'https://i/2', 'https://i/3'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService.prefetchNextChapter', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.initialize();
    });

    test('defaults to always; persists valid values; ignores invalid', () async {
      final s = SettingsService.instance;
      expect(s.prefetchNextChapter, SettingsService.prefetchAlways);
      s.prefetchNextChapter = SettingsService.prefetchWifiOnly;
      expect(s.prefetchNextChapter, SettingsService.prefetchWifiOnly);
      await Future<void>.delayed(Duration.zero);
      expect((await SharedPreferences.getInstance()).getString('prefetch_next_chapter'), 'wifiOnly');
      s.prefetchNextChapter = 'bogus';
      expect(s.prefetchNextChapter, SettingsService.prefetchWifiOnly);
      s.prefetchNextChapter = SettingsService.prefetchOff;
      expect(s.prefetchNextChapter, SettingsService.prefetchOff);
      s.prefetchNextChapter = SettingsService.prefetchAlways;
    });
  });

  group('PageLoader upcoming-page prefetch gate', () {
    Future<List<String>> run(String mode, {bool wifi = true}) async {
      final fetched = <String>[];
      final l = PageLoader(
        sourceName: 'S',
        mangaId: 1,
        chapterTargetId: 1,
        prefetchMode: () => mode,
        isOnWifi: () async => wifi,
        fetchOverride: (u) async {
          fetched.add(u);
          return PageLoadResult(bytes: _png);
        },
      );
      l.prefetchUpcoming(_urls, 0, count: 2);
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      l.dispose();
      return fetched;
    }

    test('always: unchanged (fetches upcoming pages)', () async {
      expect((await run(SettingsService.prefetchAlways))..sort(), ['https://i/1', 'https://i/2']);
    });
    test('wifiOnly on Wi-Fi: fetches', () async {
      expect((await run(SettingsService.prefetchWifiOnly, wifi: true))..sort(), ['https://i/1', 'https://i/2']);
    });
    test('wifiOnly on mobile data: none', () async {
      expect(await run(SettingsService.prefetchWifiOnly, wifi: false), isEmpty);
    });
    test('off: none', () async {
      expect(await run(SettingsService.prefetchOff), isEmpty);
    });
    test('isPrefetchAllowed: connectivity error in wifiOnly → not allowed', () async {
      final l = PageLoader(
          sourceName: 'S', mangaId: 1, chapterTargetId: 1,
          prefetchMode: () => SettingsService.prefetchWifiOnly,
          isOnWifi: () async => throw StateError('no plugin'));
      expect(await l.isPrefetchAllowed(), isFalse);
      l.dispose();
    });
  });

  group('NavigationController next-chapter prefetch gate', () {
    Future<int> run(String mode, {bool wifi = true}) async {
      var calls = 0;
      NavigationController.debugResetTestOverrides();
      NavigationController.debugResolveOverride = ({required chapterServerId, chapterUrl, sourceName}) async {
        calls++;
        return ChapterPagesResult(pageUrls: const ['/p/1'], source: ContentSourceType.localExtension);
      };
      final loader = PageLoader(
          sourceName: 'S', mangaId: 7, chapterTargetId: 1, prefetchMode: () => mode, isOnWifi: () async => wifi);
      final nav = NavigationController(
        isarService: MockIsarService(),
        pageLoader: loader,
        positionManager: MockPositionManager(),
        settings: MockSettingsService(),
      );
      await nav.prefetchChapter(Chapter()
        ..serverId = 2
        ..mangaId = 7
        ..url = 'https://src.invalid/c/2');
      NavigationController.debugResetTestOverrides();
      loader.dispose();
      return calls;
    }

    test('always → resolves next chapter', () async => expect(await run(SettingsService.prefetchAlways), 1));
    test('wifiOnly on Wi-Fi → resolves', () async => expect(await run(SettingsService.prefetchWifiOnly), 1));
    test('wifiOnly off Wi-Fi → skipped', () async =>
        expect(await run(SettingsService.prefetchWifiOnly, wifi: false), 0));
    test('off → skipped', () async => expect(await run(SettingsService.prefetchOff), 0));
  });
}
