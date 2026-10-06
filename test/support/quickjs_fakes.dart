// Test-only QuickJS fakes (UIX-21).
//
// Production code no longer fabricates results when the QuickJS native
// library is missing. Unit tests that exercise the *routing* around local
// extensions (resolver tiers, offline flows) on a host without
// libflutter_qjs_plugin.so install these fakes instead. They read the string
// literals out of the fixture JS, exactly like the removed shim did, but only
// inside the test that asked for it.
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

/// Installs fake page-list / scrape results for the current test and removes
/// them in its tearDown.
void installQuickJsFixtureFakes() {
  QuickJsService.debugPageListOverride = (sourceName, jsCode, chapterUrl) async => RegExp(r'''["'](https?://[^"']+)["']''')
      .allMatches(jsCode)
      .map((m) => m.group(1)!)
      .where((u) => u.contains('png') || u.contains('jpg') || u.contains('webp') || u.contains('image'))
      .toList();
  QuickJsService.debugScrapeOverride = (sourceName, jsCode) async {
    final titles = RegExp(r'''title:\s*["']([^"']+)["']''').allMatches(jsCode).map((m) => m.group(1)!).toList();
    final urls = RegExp(r'''url:\s*["']([^"']+)["']''').allMatches(jsCode).map((m) => m.group(1)!).toList();
    return [
      for (var i = 0; i < titles.length; i++)
        <String, dynamic>{'name': titles[i], 'title': titles[i], 'url': i < urls.length ? urls[i] : '/series/$i', 'imageUrl': ''},
    ];
  };
  addTearDown(() {
    QuickJsService.debugPageListOverride = null;
    QuickJsService.debugScrapeOverride = null;
  });
}
