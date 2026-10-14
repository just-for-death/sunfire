// ISS-140: reset every process-global singleton / static test seam after each
// test, so no state (fakes, timing knobs, cookies, caches, settings) leaks
// into the next test of the same file. Called from flutter_test_config.dart.
import 'package:flutter/painting.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:sunfire/src/core/engine/local_source_service.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/services/download_storage.dart';
import 'package:sunfire/src/core/services/image_cache_helper.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/offline_monitor.dart';
import 'package:sunfire/src/core/sync/websocket_service.dart';
import 'package:sunfire/src/features/reader/controller/navigation_controller.dart';
import 'package:sunfire/src/features/reader/controller/page_loader.dart';
import 'package:sunfire/src/features/settings/appearance_settings_screen.dart';

/// Every reset is independent; one failing never skips the others.
void resetAllSingletonsForTest() {
  LocalSourceService.instance.debugReset();
  DownloadStorage.debugReset();
  void run(void Function() f) {
    try {
      f();
    } catch (_) {}
  }

  run(GraphQLClientService.debugResetTestOverrides); // debugInstance
  run(QuickJsService.debugResetTestOverrides);
  run(WebSocketService.debugResetTestOverrides);
  run(NavigationController.debugResetTestOverrides);
  run(PageLoader.debugResetTestOverrides);
  run(MClient.debugClearCookies);
  run(ImageCacheHelper.debugClearLocalPathCache);
  run(OfflineMonitor.instance.debugReset);
  run(() => AppearanceSettingsScreen.debugShowDynamicOption = null);
  // Page (image) cache shared by every widget test.
  run(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  });
  run(SettingsService.debugResetInstance);
}
