// test/multi_window_service_test.dart
//
// D9.4: multi-window route parsing + guards.

import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/services/multi_window_service.dart';

void main() {
  test('non-desktop guards return safe defaults', () async {
    // In the test environment there is no window plugin channel and the
    // platform is not desktop; every entry must fail closed, never throw.
    final svc = MultiWindowService.instance;
    expect(await svc.subWindowRoute(), isNull);
    expect(await svc.openMangaWindow(42), isFalse);
    expect(await svc.openReaderWindow(7), isFalse);
    expect(await svc.openMangaWindow(0), isFalse);
    expect(await svc.openReaderWindow(0), isFalse);
  });
}
