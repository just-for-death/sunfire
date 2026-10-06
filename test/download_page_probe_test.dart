// UIX-11: header-only async page validation in the download completion path.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/download_manager_service.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('uix11_'));
  tearDown(() => dir.deleteSync(recursive: true));

  File write(String name, List<int> bytes) => File('${dir.path}/$name')..writeAsBytesSync(bytes);

  const jpegHeader = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01];

  test('JPEG header + padding is valid', () async {
    final f = write('page_001.jpg', [...jpegHeader, ...List.filled(1000, 0)]);
    expect(await DownloadManagerService.looksLikeValidPageFile(f), isTrue);
  });

  test('100-byte JPEG is invalid (<= 500 bytes)', () async {
    final f = write('page_002.jpg', [...jpegHeader, ...List.filled(88, 0)]);
    expect(await DownloadManagerService.looksLikeValidPageFile(f), isFalse);
  });

  test('HTML stub is invalid', () async {
    final f = write('page_003.jpg', ('<html>' * 600).codeUnits);
    expect(await DownloadManagerService.looksLikeValidPageFile(f), isFalse);
  });

  test('zero-byte and missing files are invalid', () async {
    expect(await DownloadManagerService.looksLikeValidPageFile(write('z.jpg', [])), isFalse);
    expect(await DownloadManagerService.looksLikeValidPageFile(File('${dir.path}/nope.jpg')), isFalse);
  });

  test('page extension filter', () {
    for (final ok in ['a.jpg', 'a.JPEG', 'a.png', 'a.webp', 'a.gif', 'a.bmp']) {
      expect(DownloadManagerService.hasDownloadPageExtension(ok), isTrue, reason: ok);
    }
    for (final bad in ['a.jpg.part', '.sunfire_complete', 'a.txt']) {
      expect(DownloadManagerService.hasDownloadPageExtension(bad), isFalse, reason: bad);
    }
  });

  test('download_manager_service has no *Sync file I/O left', () {
    final src = File('lib/src/core/services/download_manager_service.dart').readAsStringSync();
    expect(RegExp(r'\b\w+Sync\(').hasMatch(src), isFalse);
  });
}
