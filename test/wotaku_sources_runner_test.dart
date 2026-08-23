import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  const wotakuDir = '/home/zoro/.gemini/antigravity/brain/15ceb021-fa15-45ff-867a-c00f0e17c171/scratch/wotaku_sources';

  group('WOTAKU SOURCES VALIDATION SUITE', () {
    test('1. Verify downloaded source files exist', () {
      final dir = Directory(wotakuDir);
      expect(dir.existsSync(), isTrue);
      final files = dir.listSync().whereType<File>().toList();
      expect(files.length, greaterThanOrEqualTo(5));
      for (final f in files) {
        expect(f.lengthSync(), greaterThan(1000));
        print('  - ${f.path.split('/').last} (${f.lengthSync()} bytes)');
      }
    });
  });
}
