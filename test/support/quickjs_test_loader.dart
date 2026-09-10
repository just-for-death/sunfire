import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

const int _rtldNow = 2;
const int _rtldGlobal = 0x100;

typedef _DlopenNative = Pointer Function(Pointer<Utf8> filename, Int32 flag);
typedef _DlopenDart = Pointer Function(Pointer<Utf8> filename, int flag);

/// Candidate locations for the flutter_qjs native plugin after a Linux build.
List<String> quickJsPluginCandidatePaths() {
  final cwd = Directory.current.path;
  return [
    '$cwd/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
    '$cwd/build/linux/x64/release/bundle/lib/libflutter_qjs_plugin.so',
    '/home/zoro/Documents/Projects/manga/sunfire/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
  ];
}

String? findQuickJsPluginPath() {
  for (final path in quickJsPluginCandidatePaths()) {
    if (File(path).existsSync()) return path;
  }
  return null;
}

/// Load QuickJS with RTLD_GLOBAL so `jsNewRuntime` is visible to flutter_tester.
/// Returns false when the native plugin is missing (e.g. after `flutter clean`).
bool tryLoadQuickJsPluginGlobally() {
  final path = findQuickJsPluginPath();
  if (path == null) return false;
  final libc = DynamicLibrary.process();
  final dlopen = libc.lookupFunction<_DlopenNative, _DlopenDart>('dlopen');
  final pathPtr = path.toNativeUtf8();
  try {
    final handle = dlopen(pathPtr, _rtldNow | _rtldGlobal);
    return handle != nullptr;
  } finally {
    calloc.free(pathPtr);
  }
}
