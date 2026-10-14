// IMP-015: rotate wide pages (paged modes only, behind a setting).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/reader/controller/reader_page_widget.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

const _url = '/nonexistent/imp015_page.png';

ReaderPageWidgetConfig _config({required bool isPaged, double? aspect}) => ReaderPageWidgetConfig(
      url: _url,
      index: 0,
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 800),
      isPaged: isPaged,
      contentWidth: 400,
      enablePerPageZoom: false,
      readingMode: isPaged ? ReadingMode.pagedLtr : ReadingMode.longStrip,
      colorFilter: ReaderColorFilter.none,
      cropBorders: false,
      scaleType: ImageScaleType.fitScreen,
      readerTheme: ReaderThemeMode.black,
      pageLoader: null,
      sourceName: '',
      settings: SettingsService.instance,
      cachedPageHeights: {},
      cachedPageAspects: {if (aspect != null) _url: aspect},
      recoveringUrls: {},
      failedImageUrls: {},
      canvasBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(),
      onRecoverImage: (url, i, {bool manual = false}) async {},
      onScheduleHeightCache: (_, __, ___) {},
      onDoubleTapDown: (_) {},
      onDoubleTapZoom: ({controllerOverride, pageIndex}) {},
      onPruneZoomState: (_) {},
      webtoonZoomControllerFor: (_) => TransformationController(),
      transformationController: TransformationController(),
      minZoomScale: 1,
      maxZoomScale: 3,
      isZoomed: false,
      onInteractionUpdate: (_) {},
      onInteractionEnd: (_) {},
    );

Future<void> _pump(WidgetTester tester, ReaderPageWidgetConfig c) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 400, height: 800, child: buildReaderPageWidget(c)))));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
  });

  test('setting defaults to off and persists', () {
    expect(SettingsService.instance.rotateWidePages, isFalse);
    SettingsService.instance.rotateWidePages = true;
    expect(SettingsService.instance.rotateWidePages, isTrue);
  });

  test('shouldRotateWidePage: only wide pages, only paged, only when enabled', () {
    expect(shouldRotateWidePage(enabled: true, isPaged: true, aspectRatio: 1.6), isTrue);
    expect(shouldRotateWidePage(enabled: false, isPaged: true, aspectRatio: 1.6), isFalse);
    expect(shouldRotateWidePage(enabled: true, isPaged: false, aspectRatio: 1.6), isFalse);
    expect(shouldRotateWidePage(enabled: true, isPaged: true, aspectRatio: 0.7), isFalse);
    expect(shouldRotateWidePage(enabled: true, isPaged: true, aspectRatio: null), isFalse);
  });

  testWidgets('paged wide page is rotated a quarter turn when enabled', (tester) async {
    SettingsService.instance.rotateWidePages = true;
    await _pump(tester, _config(isPaged: true, aspect: 1.6));
    final box = tester.widget<RotatedBox>(find.byType(RotatedBox));
    expect(box.quarterTurns, 1);
  });

  testWidgets('no rotation when off, for tall pages, or in webtoon', (tester) async {
    await _pump(tester, _config(isPaged: true, aspect: 1.6));
    expect(find.byType(RotatedBox), findsNothing);
    SettingsService.instance.rotateWidePages = true;
    await _pump(tester, _config(isPaged: true, aspect: 0.7));
    expect(find.byType(RotatedBox), findsNothing);
    await _pump(tester, _config(isPaged: false, aspect: 1.6));
    expect(find.byType(RotatedBox), findsNothing);
  });
}
