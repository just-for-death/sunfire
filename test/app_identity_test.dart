// IMP-052: the Linux application id stays the one in use, everywhere.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/utils/app_identity.dart';

void main() {
  test('linux/CMakeLists.txt APPLICATION_ID matches kLinuxApplicationId', () {
    final cmake = File('linux/CMakeLists.txt').readAsStringSync();
    final m = RegExp(r'set\(APPLICATION_ID "([^"]+)"\)').firstMatch(cmake);
    expect(m?.group(1), kLinuxApplicationId);
    expect(kLinuxApplicationId, 'com.sunfire.sunfire');
  });

  test('no other hard-coded Linux app id in lib/', () {
    final hits = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart') || f.path.endsWith('app_identity.dart')) continue;
      if (f.readAsStringSync().contains('com.sunfire.sunfire')) hits.add(f.path);
    }
    expect(hits, isEmpty, reason: 'use kLinuxApplicationId');
  });
}
