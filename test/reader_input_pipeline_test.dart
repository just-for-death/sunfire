// ISS-132: unit tests for the screen-owned ReaderInputPipeline (moved out of
// the _ReaderGestures extension) and its single GesturePipeline (IMP-049a).
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/isar_service.dart';
import 'package:sunfire/src/core/metron/metron_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/sync_engine.dart';
import 'package:sunfire/src/features/reader/controller/gesture_pipeline.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/reader/controller/position_manager.dart';
import 'package:sunfire/src/features/reader/controller/reader_input_pipeline.dart';
import 'package:sunfire/src/features/reader/controller/reader_theme.dart';
import 'package:sunfire/src/features/reader/double_page_layout.dart';
import 'package:sunfire/src/features/reader/reading_mode.dart';

class _FakeHost implements ReaderInputHost {
  int rebuilds = 0;
  @override
  bool mounted = true;
  BuildContext? debugContext;
  @override
  BuildContext get context => debugContext ?? (throw UnimplementedError('no context in unit tests'));
  @override
  TickerProvider get vsync => const TestVSync();
  @override
  void rebuild(VoidCallback fn) {
    rebuilds++;
    fn();
  }

  @override
  ReadingMode readingMode = ReadingMode.values.last;
  @override
  ReaderThemeMode readerTheme = ReaderThemeMode.values.first;
  @override
  ReaderColorFilter colorFilter = ReaderColorFilter.values.first;
  @override
  ImageScaleType scaleType = ImageScaleType.values.first;
  @override
  bool cropBorders = false;
  @override
  bool invertTaps = false;
  @override
  int currentPage = 1;
  @override
  bool showControls = true;
  @override
  bool isDraggingSlider = false;
  @override
  final ScrollController scrollController = ScrollController();
  @override
  final PageController pageController = PageController();
  @override
  final TransformationController transformationController = TransformationController();
  @override
  AnimationController? zoomAnimController;
  @override
  final Map<int, TransformationController> webtoonZoomControllers = {};
  @override
  final Map<String, double> cachedPageHeights = {};
  @override
  final Map<String, double> cachedPageAspects = {};
  @override
  final ValueNotifier<int> pageIndicator = ValueNotifier(1);
  @override
  final ValueNotifier<bool> scrollIndicatorVisible = ValueNotifier(false);
  @override
  List<SpreadSlot> currentSpreadSlots() => const [];
  @override
  Future<void> persistReadingMode(ReadingMode mode) async {}
  final List<int> fetched = [];
  @override
  void fetchPagesAround(int page) => fetched.add(page);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeHost host;
  late NavigationController nav;
  late ReaderInputPipeline input;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    final pm = PositionManager(
      settings: SettingsService.instance,
      isarService: IsarService.instance,
      syncEngine: SyncEngine.instance,
      metronService: MetronService.instance,
    );
    nav = NavigationController(
      isarService: IsarService.instance,
      pageLoader: PageLoader(sourceName: '', mangaId: 0, chapterTargetId: 0),
      positionManager: pm,
      settings: SettingsService.instance,
    );
    host = _FakeHost();
    input = ReaderInputPipeline(
      host: host,
      navigationController: nav,
      positionManager: pm,
      settings: SettingsService.instance,
    );
  });

  tearDown(() => nav.pageLoader.dispose());

  test('owns exactly one GesturePipeline; an injected one is used as-is', () {
    expect(input.gesturePipeline, isA<GesturePipeline>());
    expect(identical(input.gesturePipeline, input.gesturePipeline), isTrue);
    final injected = GesturePipeline(
        navigationController: nav, positionManager: nav.positionManager, settings: SettingsService.instance);
    final other = ReaderInputPipeline(
      host: host,
      navigationController: nav,
      positionManager: nav.positionManager,
      settings: SettingsService.instance,
      gesturePipeline: injected,
    );
    expect(identical(other.gesturePipeline, injected), isTrue);
  });

  test('wirePipelineCallbacks binds the pipeline callbacks to the host state', () {
    input.wirePipelineCallbacks();
    final gp = input.gesturePipeline;
    expect(gp.onToggleControls, isNotNull);
    expect(gp.onGoToNextPage, isNotNull);
    expect(gp.onGoToPrevPage, isNotNull);
    expect(gp.onLoadNextChapter, isNotNull);

    gp.onTapZoneOverlayChanged!(true);
    expect(input.showTapZoneOverlay, isTrue);
    gp.onZoomStateChanged!(true);
    expect(input.isZoomed, isTrue);
    gp.onUserTouchingChanged!(true);
    expect(input.isUserTouching, isTrue);
    expect(host.rebuilds, 3);

    // No scroll clients yet: getters fall back instead of throwing.
    expect(gp.getMaxScrollExtent!(), 0.0);
    expect(gp.getCurrentScrollOffset!(), 0.0);
    expect(gp.scrollControllerHasClients!(), isFalse);
  });

  test('unmounted host: callbacks do not rebuild', () {
    input.wirePipelineCallbacks();
    host.mounted = false;
    input.gesturePipeline.onZoomStateChanged!(true);
    expect(host.rebuilds, 0);
    expect(input.isZoomed, isFalse);
  });

  test('resetZoom clears every zoom matrix and the zoomed flag', () {
    host.transformationController.value = Matrix4.diagonal3Values(2, 2, 1);
    input.webtoonZoomControllerFor(3).value = Matrix4.diagonal3Values(2, 2, 1);
    input.isZoomed = true;
    input.resetZoom();
    expect(host.transformationController.value, Matrix4.identity());
    expect(host.webtoonZoomControllers[3]!.value, Matrix4.identity());
    expect(input.isZoomed, isFalse);
    expect(host.rebuilds, 1);
  });

  test('webtoonZoomControllerFor reuses; pruneWebtoonZoomState evicts outside the window', () {
    final c0 = input.webtoonZoomControllerFor(0);
    expect(identical(input.webtoonZoomControllerFor(0), c0), isTrue);
    input.webtoonZoomControllerFor(100);
    input.pruneWebtoonZoomState(90);
    expect(host.webtoonZoomControllers.keys, [100]);
  });

  test('setPageIndicator updates the host page and indicator', () {
    input.setPageIndicator(7);
    expect(host.currentPage, 7);
    expect(host.pageIndicator.value, 7);
  });

  test('dismissTapZoneOverlay only rebuilds when the overlay is shown', () {
    input.dismissTapZoneOverlay();
    expect(host.rebuilds, 0);
    input.showTapZoneOverlay = true;
    input.dismissTapZoneOverlay();
    expect(input.showTapZoneOverlay, isFalse);
    expect(host.rebuilds, 1);
  });

  test('syncGesturePipelineState with an unmounted host stops before MediaQuery', () {
    host.mounted = false;
    expect(() => input.syncGesturePipelineState(), returnsNormally);
  });

  test('stopAutoScroll / disposeAutoScrollTicker leave no ticker behind', () {
    input.stopAutoScroll();
    input.disposeAutoScrollTicker();
    expect(input.hasAutoScrollTicker, isFalse);
  });

  test('held-key auto-repeat is swallowed without navigating', () {
    input.wirePipelineCallbacks();
    final node = FocusNode();
    final r = input.handleKeyEvent(
      node,
      KeyRepeatEvent(
        logicalKey: LogicalKeyboardKey.space,
        physicalKey: PhysicalKeyboardKey.space,
        timeStamp: Duration.zero,
      ),
    );
    expect(r, KeyEventResult.handled);
    expect(host.currentPage, 1);
    node.dispose();
  });

  group('tap / double-tap disambiguation', () {
    TapUpDetails tapAt(double dx, double dy) => TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: Offset(dx, dy),
          localPosition: Offset(dx, dy),
        );
    const constraints = BoxConstraints.tightFor(width: 300, height: 600);

    Future<void> pumpHost(WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
          home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      host.debugContext = ctx;
      host.readingMode = ReadingMode.pagedLtr;
      input.wirePipelineCallbacks();
    }

    testWidgets('prev/next taps wait out the double-tap window', (tester) async {
      await pumpHost(tester);
      var next = 0;
      input.gesturePipeline.onGoToNextPage = () => next++;
      input.handleTapZone(tapAt(280, 300), constraints); // right third -> next
      expect(next, 0, reason: 'page turn waits for double-tap timeout');
      await tester.pump(const Duration(milliseconds: 300));
      expect(next, 1);
    });

    testWidgets('menu-zone tap toggles immediately', (tester) async {
      await pumpHost(tester);
      final before = host.showControls;
      input.handleTapZone(tapAt(150, 300), constraints); // center -> menu
      expect(host.showControls, isNot(before));
    });

    testWidgets('cancelPendingTap suppresses the delayed turn (double-tap wins)', (tester) async {
      await pumpHost(tester);
      var next = 0;
      input.gesturePipeline.onGoToNextPage = () => next++;
      input.handleTapZone(tapAt(280, 300), constraints);
      input.cancelPendingTap();
      await tester.pump(const Duration(milliseconds: 300));
      expect(next, 0);
    });
  });
}
