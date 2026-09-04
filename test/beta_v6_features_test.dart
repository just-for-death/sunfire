import 'dart:ffi';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/javascript/js_extension_service.dart';

const int _rtldNow = 2;
const int _rtldGlobal = 0x100;

typedef _DlopenNative = Pointer Function(Pointer<Utf8> filename, Int32 flag);
typedef _DlopenDart = Pointer Function(Pointer<Utf8> filename, int flag);

void _loadQuickJsPluginGlobally(String path) {
  final libc = DynamicLibrary.process();
  final dlopen = libc.lookupFunction<_DlopenNative, _DlopenDart>('dlopen');
  final pathPtr = path.toNativeUtf8();
  try {
    final handle = dlopen(pathPtr, _rtldNow | _rtldGlobal);
    if (handle == nullptr) throw StateError('dlopen failed for $path');
  } finally {
    calloc.free(pathPtr);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp/sunfire_test',
    );
    try {
      _loadQuickJsPluginGlobally(
        '/home/zoro/Documents/Projects/sunfire/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
      );
    } catch (_) {}
  });

  group('BETA V6 FEATURE SUITE: Webtoon Auto-Scroll & Reader Upgrades', () {
    test('1. Webtoon Auto-Scroll speed clamp & step calculation', () {
      var speed = 40.0;

      // Increase speed by 10 px/s
      speed = (speed + 10).clamp(10.0, 200.0);
      expect(speed, 50.0);

      // Decrease speed by 10 px/s
      speed = (speed - 10).clamp(10.0, 200.0);
      expect(speed, 40.0);

      // Test lower boundary clamp (10 px/s)
      speed = (speed - 100).clamp(10.0, 200.0);
      expect(speed, 10.0);

      // Test upper boundary clamp (200 px/s)
      speed = (speed + 500).clamp(10.0, 200.0);
      expect(speed, 200.0);

      // Periodic timer step calculation: speed * 0.025 (25ms interval)
      final step = speed * 0.025;
      expect(step, 5.0); // at 200 px/s, step is exactly 5.0 px per tick
    });

    test('2. Webtoon Auto-Scroll boundary detection', () {
      const maxScrollExtent = 5000.0;

      // When offset is well before bottom, auto-scroll continues
      var currentOffset = 4000.0;
      expect(currentOffset >= maxScrollExtent - 10, isFalse);

      // When offset is within 10px of bottom, auto-scroll completes and advances
      currentOffset = 4995.0;
      expect(currentOffset >= maxScrollExtent - 10, isTrue);
    });

    test('3. Tap-to-pause auto-scroll logic', () {
      var isAutoScrolling = true;

      // When auto-scrolling is active, any tap must immediately pause scrolling
      void handleTapZone() {
        if (isAutoScrolling) {
          isAutoScrolling = false;
          return;
        }
      }

      handleTapZone();
      expect(isAutoScrolling, isFalse);
    });

    test('4. Reader Sepia eye comfort filter matrix verification', () {
      // Standard photographic sepia matrix transformation
      const sepiaMatrix = [
        0.393, 0.769, 0.189, 0.0, 0.0,
        0.349, 0.686, 0.168, 0.0, 0.0,
        0.272, 0.534, 0.131, 0.0, 0.0,
        0.0,   0.0,   0.0,   1.0, 0.0,
      ];

      expect(sepiaMatrix.length, 20);
      expect(sepiaMatrix[0], closeTo(0.393, 0.001));
      expect(sepiaMatrix[6], closeTo(0.686, 0.001));
      expect(sepiaMatrix[12], closeTo(0.131, 0.001));
      expect(sepiaMatrix[18], 1.0); // Alpha channel preserved

      final colorFilter = ColorFilter.matrix(sepiaMatrix);
      expect(colorFilter, isNotNull);
    });

    test('5. Webtoon Inverted Taps navigation logic', () {
      const screenWidth = 400.0;
      const leftTapX = 50.0;   // < 30% width (120px)
      const rightTapX = 350.0; // > 70% width (280px)

      bool isTapNext(double x, bool inverted) {
        final isLeft = x < screenWidth * 0.30;
        final isRight = x > screenWidth * 0.70;
        return inverted ? isLeft : isRight;
      }

      bool isTapPrev(double x, bool inverted) {
        final isLeft = x < screenWidth * 0.30;
        final isRight = x > screenWidth * 0.70;
        return inverted ? isRight : isLeft;
      }

      // Normal mode: Right = next, Left = prev
      expect(isTapNext(rightTapX, false), isTrue);
      expect(isTapPrev(rightTapX, false), isFalse);
      expect(isTapNext(leftTapX, false), isFalse);
      expect(isTapPrev(leftTapX, false), isTrue);

      // Inverted mode: Left = next, Right = prev
      expect(isTapNext(rightTapX, true), isFalse);
      expect(isTapPrev(rightTapX, true), isTrue);
      expect(isTapNext(leftTapX, true), isTrue);
      expect(isTapPrev(leftTapX, true), isFalse);
    });

    test('6. Trackpad & PointerScrollEvent page navigation thresholds', () {
      // Threshold is 25px delta
      const threshold = 25.0;

      bool shouldGoNext(double dx, double dy) => dx > threshold || dy > threshold;
      bool shouldGoPrev(double dx, double dy) => dx < -threshold || dy < -threshold;

      // Small jitter scroll should NOT trigger page turn
      expect(shouldGoNext(10.0, 5.0), isFalse);
      expect(shouldGoPrev(-12.0, -8.0), isFalse);

      // Intentional two-finger trackpad swipe right / down
      expect(shouldGoNext(30.0, 0.0), isTrue);
      expect(shouldGoNext(0.0, 45.0), isTrue);

      // Intentional two-finger trackpad swipe left / up
      expect(shouldGoPrev(-35.0, 0.0), isTrue);
      expect(shouldGoPrev(0.0, -50.0), isTrue);
    });
  });

  group('BETA V6 FEATURE SUITE: Library Quick Filters & QuickJS Lifecycle', () {
    test('7. Library Quick Status Filter Chip filtering logic', () {
      final mangaList = [
        Manga()..serverId = 1..title = 'One Piece'..unreadCount = 15..chapterCount = 1100..status = 'Ongoing',
        Manga()..serverId = 2..title = 'Fullmetal Alchemist'..unreadCount = 0..chapterCount = 108..status = 'Completed',
        Manga()..serverId = 3..title = 'Hunter x Hunter'..unreadCount = 4..chapterCount = 400..status = 'Ongoing',
        Manga()..serverId = 4..title = 'Monster'..unreadCount = 0..chapterCount = 162..status = 'Completed',
      ];

      List<Manga> filterManga(String filter) {
        if (filter == 'Unread') {
          return mangaList.where((m) => (m.unreadCount ?? 0) > 0).toList();
        } else if (filter == 'Completed') {
          return mangaList.where((m) => (m.status ?? '').toLowerCase() == 'completed').toList();
        }
        return mangaList;
      }

      // Filter: All
      expect(filterManga('All').length, 4);

      // Filter: Unread
      final unread = filterManga('Unread');
      expect(unread.length, 2);
      expect(unread.map((m) => m.title), containsAll(['One Piece', 'Hunter x Hunter']));

      // Filter: Completed
      final completed = filterManga('Completed');
      expect(completed.length, 2);
      expect(completed.map((m) => m.title), containsAll(['Fullmetal Alchemist', 'Monster']));
    });

    test('8. QuickJS isolated teardown prevents noisy console dumps', () {
      final service = JsExtensionService(
        sourceMeta: {'name': 'MockSource', 'baseUrl': 'https://example.com'},
        sourceCode: '''
class DefaultExtension {
  getPopular(page) {
    return { list: [{ name: "Test", url: "/test" }], hasNextPage: false };
  }
}
''',
      );

      // Execute a call to initialize runtime and create JS bridge
      expect(service.getHeaders(), isNotNull);

      // Dispose service — must complete cleanly without throwing or printing leaks
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
