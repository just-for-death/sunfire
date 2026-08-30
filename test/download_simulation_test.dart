// ignore_for_file: avoid_print
// Simulates a real "download chapter" pass for every installed extension,
// exactly like DownloadManagerService._downloadChapterLocally does:
//   1. getPopular -> pick a manga
//   2. getDetail -> pick a chapter
//   3. getPageList -> get page image URLs (+ any per-image headers extensions provide)
//   4. Download every page with QuickJsService.getImageHeaders() headers,
//      Dio first then a curl fallback (mirrors the production desktop path)
//   5. Validate each downloaded file is a real image (magic-byte sniffing,
//      not an HTML error/interstitial page) and report size + timing.
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/javascript/js_extension_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

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

String? _sniffImageType(List<int> bytes) {
  if (bytes.length < 12) return null;
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return 'JPEG';
  if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return 'PNG';
  if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return 'GIF';
  if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
      bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
    return 'WEBP';
  }
  return null;
}

Future<List<int>?> _downloadPage(Dio dio, String url, Map<String, String> headers) async {
  try {
    final response = await dio.get<List<int>>(
      url,
      options: Options(headers: headers, responseType: ResponseType.bytes),
    );
    if (response.data != null && response.data!.isNotEmpty) return response.data;
  } catch (_) {}

  // Desktop TLS-fingerprint fallback, exactly like DownloadManagerService does.
  try {
    final args = <String>['-s', '-L', '--max-time', '20'];
    headers.forEach((k, v) => args.addAll(['-H', '$k: $v']));
    args.add(url);
    final res = await Process.run('curl', args, stdoutEncoding: null);
    if (res.exitCode == 0) {
      final bytes = res.stdout as List<int>;
      if (bytes.length > 200) return bytes;
    }
  } catch (_) {}
  return null;
}

void main() {
  test(
    'Download a chapter from every extension and validate images',
    () async {
      _loadQuickJsPluginGlobally(
        '/home/zoro/Documents/Projects/manga/sunfire/build/linux/x64/debug/bundle/lib/libflutter_qjs_plugin.so',
      );
      MClient.cfProxyUrl = 'http://100.85.171.6:8191';

      final extDir = Directory('/home/zoro/Documents/Projects/manga/mangayomi-extensions/javascript/manga/src/en');
      final outDir = Directory('/tmp/sunfire_download_sim');
      if (outDir.existsSync()) outDir.deleteSync(recursive: true);
      outDir.createSync(recursive: true);

      final files = extDir.listSync().where((f) => f.path.endsWith('.js')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(minutes: 2)));
      final summary = <String>[];

      for (final file in files) {
        final name = file.path.split('/').last.replaceAll('.js', '');
        print('\n==================================================');
        print('CHAPTER DOWNLOAD TEST: $name');
        print('==================================================');

        final swTotal = Stopwatch()..start();
        JsExtensionService? service;
        try {
          final code = File(file.path).readAsStringSync();
          final meta = QuickJsService.instance.extractSourceMetadata(code);
          final sourceName = (meta['name'] ?? name).toString();
          service = JsExtensionService(sourceMeta: meta, sourceCode: code);

          final popData = await service.getPopular(1).timeout(const Duration(seconds: 40));
          final list = popData['list'] as List<dynamic>? ?? [];
          if (list.isEmpty) {
            summary.add('$name: FAIL (no popular results)');
            continue;
          }
          final link = list.first['link'] ?? list.first['url'];

          final details = await service.getDetail(link).timeout(const Duration(seconds: 40));
          final chapters = details['chapters'] as List<dynamic>? ?? [];
          if (chapters.isEmpty) {
            summary.add('$name: FAIL (no chapters)');
            continue;
          }
          // Pick the last chapter (usually chapter 1 / oldest) for a lighter, stable download.
          final chapter = chapters.last;
          final chLink = chapter['url'];
          print('  Chapter: ${chapter['name']} -> $chLink');

          final pages = await service.getPageList(chLink).timeout(const Duration(seconds: 40));
          if (pages.isEmpty) {
            summary.add('$name: FAIL (no pages)');
            continue;
          }
          print('  Pages found: ${pages.length}');

          final chapterDir = Directory('${outDir.path}/$name');
          chapterDir.createSync(recursive: true);

          var success = 0;
          var failed = 0;
          var totalBytes = 0;
          final perPageMs = <int>[];
          // Cap at 5 pages per chapter to keep the whole suite's runtime reasonable.
          final pagesToTest = pages.take(5).toList();

          for (var i = 0; i < pagesToTest.length; i++) {
            final pageUrl = pagesToTest[i];
            final headers = QuickJsService.getImageHeaders(sourceName, pageUrl);

            final sw = Stopwatch()..start();
            final bytes = await _downloadPage(dio, pageUrl, headers);
            sw.stop();
            perPageMs.add(sw.elapsedMilliseconds);

            if (bytes == null || bytes.isEmpty) {
              print('  [${i + 1}] FAIL  (no bytes)                          ${sw.elapsedMilliseconds}ms  $pageUrl');
              failed++;
              continue;
            }
            final type = _sniffImageType(bytes);
            if (type == null) {
              print('  [${i + 1}] FAIL  (not an image, ${bytes.length}B)    ${sw.elapsedMilliseconds}ms  $pageUrl');
              failed++;
              continue;
            }
            final file2 = File('${chapterDir.path}/page_${(i + 1).toString().padLeft(3, '0')}.${type.toLowerCase()}');
            file2.writeAsBytesSync(bytes);
            totalBytes += bytes.length;
            success++;
            print('  [${i + 1}] OK    $type  ${(bytes.length / 1024).toStringAsFixed(1)}KB  ${sw.elapsedMilliseconds}ms  $pageUrl');
          }

          swTotal.stop();
          final avgMs = perPageMs.isEmpty ? 0 : perPageMs.reduce((a, b) => a + b) / perPageMs.length;
          final verdict = failed == 0 ? 'PASS' : (success > 0 ? 'PARTIAL' : 'FAIL');
          summary.add(
            '$name: $verdict  ok=$success fail=$failed  totalKB=${(totalBytes / 1024).toStringAsFixed(1)}  '
            'avgPageMs=${avgMs.toStringAsFixed(0)}  totalMs=${swTotal.elapsedMilliseconds}',
          );
        } catch (e) {
          swTotal.stop();
          summary.add('$name: ERROR $e');
        } finally {
          service?.dispose();
        }
      }

      print('\n\n================ DOWNLOAD SIMULATION SUMMARY ================');
      for (final line in summary) {
        print(line);
      }
      print('===============================================================');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
