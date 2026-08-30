// ignore_for_file: avoid_print
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/js_extension_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

const int _rtldNow = 2;
const int _rtldGlobal = 0x100;

typedef _DlopenNative = Pointer Function(Pointer<Utf8> filename, Int32 flag);
typedef _DlopenDart = Pointer Function(Pointer<Utf8> filename, int flag);

/// flutter_tester does not auto-load Linux plugin .so files the way the
/// real GTK desktop embedder does, and `DynamicLibrary.open` alone loads
/// with RTLD_LOCAL so its symbols stay invisible to `DynamicLibrary.process()`
/// (used internally by package:flutter_qjs). Call the real libc `dlopen`
/// with RTLD_GLOBAL so `jsNewRuntime` etc. become process-wide visible.
void _loadQuickJsPluginGlobally(String path) {
  final libc = DynamicLibrary.process();
  final dlopen = libc.lookupFunction<_DlopenNative, _DlopenDart>('dlopen');
  final pathPtr = path.toNativeUtf8();
  try {
    final handle = dlopen(pathPtr, _rtldNow | _rtldGlobal);
    if (handle == nullptr) {
      throw StateError('dlopen failed for $path');
    }
  } finally {
    calloc.free(pathPtr);
  }
}

void main() {
  test(
    'Test extensions without path_provider hangs',
    () async {
    _loadQuickJsPluginGlobally(
      '/home/zoro/Documents/Projects/manga/sunfire/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
    );

    // Personal FlareSolverr instance used for local diagnostic runs only.
    MClient.cfProxyUrl = 'http://100.85.171.6:8191';

    final extDir = Directory('/home/zoro/Documents/Projects/manga/mangayomi-extensions/javascript/manga/src/en');
    if (!extDir.existsSync()) {
      print("ERROR: App extension directory not found");
      return;
    }

    final files = extDir.listSync().where((f) => f.path.endsWith('.js')).toList();

    for (final file in files) {
      final name = file.path.split('/').last.replaceAll('.js', '');
      print("\n==================================================");
      print("🔍 TESTING EXTENSION: $name");
      print("==================================================");

      JsExtensionService? service;
      try {
        final code = File(file.path).readAsStringSync();
        final meta = QuickJsService.instance.extractSourceMetadata(code);
        service = JsExtensionService(sourceMeta: meta, sourceCode: code);

        print("  [1] Testing getPopular(1)...");
        final popData = await service.getPopular(1).timeout(const Duration(seconds: 40));
        final list = popData['list'] as List<dynamic>? ?? [];
        print("      Found ${list.length} manga.");

        if (list.isNotEmpty) {
          final first = list.first;
          final link = first['link'] ?? first['url'];
          final mangaName = first['name'];
          print("      -> Selected: $mangaName");

          print("  [2] Testing getDetail(url)...");
          final details = await service.getDetail(link).timeout(const Duration(seconds: 40));
          final chapters = details['chapters'] as List<dynamic>? ?? [];
          print("      Found ${chapters.length} chapters.");

          if (chapters.isNotEmpty) {
            final chLink = chapters.first['url'];
            print("  [3] Testing getPageList(chapterUrl)...");
            final pages = await service.getPageList(chLink).timeout(const Duration(seconds: 40));
            print("      Found ${pages.length} pages.");
            if (pages.isNotEmpty) {
               final p = pages.first;
               String firstUrl = (p is Map ? (p as Map)['url'] : p).toString();
               print("      -> First Image: $firstUrl");
            }
          }
        }

        print("  [4] Testing search('action')...");
        final searchData = await service.search("action", 1, []).timeout(const Duration(seconds: 40));
        final sList = searchData['list'] as List<dynamic>? ?? [];
        print("      Found ${sList.length} search results.");
        print("  ✅ EXTENSION $name PASSED");

      } catch (e) {
        print("  ❌ CRITICAL ERROR: $e");
      } finally {
        service?.dispose();
      }
    }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
