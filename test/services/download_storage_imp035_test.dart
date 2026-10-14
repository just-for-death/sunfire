// IMP-035: download location + free-space guard.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

void main() {
  late Directory tmp;
  late SettingsService s;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    s = SettingsService.instance;
    await s.initialize();
    tmp = await Directory.systemTemp.createTemp('imp035_');
    DownloadStorage.debugDocumentsDir = () async => Directory('${tmp.path}/docs');
  });
  tearDown(() async {
    await tmp.delete(recursive: true);
  });

  test('parses df -Pk output (including wrapped filesystem names)', () {
    const out = 'Filesystem     1024-blocks      Used Available Capacity Mounted on\n'
        '/dev/nvme0n1p2   479151816 300000000 154737424      66% /\n';
    expect(parseDfAvailableBytes(out), 154737424 * 1024);
    const wrapped = 'Filesystem 1024-blocks Used Available Capacity Mounted on\n'
        '/dev/mapper/very-long-name\n 100 40 60 40% /data\n';
    expect(parseDfAvailableBytes(wrapped), 60 * 1024);
    expect(parseDfAvailableBytes('garbage'), isNull);
  });

  test('unknown free space never blocks; known space must meet the reserve', () {
    expect(hasRoomForDownload(null, reserveBytes: 1 << 30), isTrue);
    expect(hasRoomForDownload(100, reserveBytes: 200), isFalse);
    expect(hasRoomForDownload(200, reserveBytes: 200), isTrue);
  });

  test('default root vs custom location; reads/deletes see both roots', () async {
    expect((await DownloadStorage.downloadDirectory()).path, '${tmp.path}/docs/downloads');
    await Directory('${tmp.path}/docs/downloads/5').create(recursive: true);

    s.localDownloadDirectory = '${tmp.path}/sd';
    expect((await DownloadStorage.downloadDirectory()).path, '${tmp.path}/sd');
    expect((await DownloadStorage.chapterDirForWrite(9)).path, '${tmp.path}/sd/9');
    await Directory('${tmp.path}/sd/5').create(recursive: true);
    final found = await DownloadStorage.existingChapterDirs(5);
    expect(found.map((d) => d.path), ['${tmp.path}/sd/5', '${tmp.path}/docs/downloads/5']);
    expect(await DownloadStorage.roots(), hasLength(2));

    s.localDownloadDirectory = '  ';
    expect(await DownloadStorage.roots(), hasLength(1));
  });

  test('ensureFreeSpace throws below the reserve and flags lowStorage', () async {
    s.downloadMinFreeSpaceMb = 500;
    DownloadStorage.debugRunProcess = (e, a) async => ProcessResult(0, 0,
        'Filesystem 1024-blocks Used Available Capacity Mounted on\n/dev/x 1000 900 1024 90% /\n', '');
    await expectLater(DownloadStorage.ensureFreeSpace(), throwsA(isA<InsufficientStorageException>()));
    expect(DownloadStorage.lowStorage.value, isTrue);

    DownloadStorage.debugRunProcess = (e, a) async => ProcessResult(0, 1, '', 'df: not found');
    await DownloadStorage.ensureFreeSpace();
    expect(DownloadStorage.lowStorage.value, isFalse);
  });

  test('reserve setting clamps', () {
    expect(s.downloadMinFreeSpaceMb, 200);
    s.downloadMinFreeSpaceMb = 999999;
    expect(s.downloadMinFreeSpaceMb, 10240);
  });
}
