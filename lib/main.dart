import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/core/db/isar_service.dart';
import 'src/core/engine/image_transport_service.dart';
import 'src/core/engine/javascript/m_client.dart';
import 'src/core/engine/quickjs_service.dart';
import 'src/core/logging/logger_service.dart';
import 'src/core/services/download_manager_service.dart';
import 'src/core/services/image_cache_helper.dart';
import 'src/core/services/settings_service.dart';
import 'src/core/sync/background_service.dart';
import 'src/core/sync/graphql_client_service.dart';
import 'src/core/sync/server_auth_helper.dart';
import 'src/core/sync/sync_engine.dart';
import 'src/core/sync/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Modern Edge-to-Edge System Navigation Styling for Android & iOS
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await LoggerService.instance.initialize();
  await IsarService.instance.initialize();
  await SettingsService.instance.initialize();
  await ImageCacheHelper.initialize();
  await QuickJsService.instance.initialize();
  ImageTransportService.instance.initialize();

  // Configure Suwayomi GraphQL client and SyncEngine only after onboarding
  if (SettingsService.instance.onboardingCompleted) {
    final authToken = await ServerAuthHelper.getRawAuthHeader();
    GraphQLClientService.instance.initialize(SettingsService.instance.serverUrl, authToken: authToken);
    WebSocketService.instance.initialize(SettingsService.instance.serverUrl, authToken: authToken);
    SyncEngine.instance.initialize();
    await BackgroundService.instance.initialize();
  }

  // Load saved FlareSolverr / Byparr URL into MClient so Cloudflare-protected
  // sources (Mangago, ReadComicOnline, etc.) work immediately on startup.
  final savedCfProxy = SettingsService.instance.cfProxyUrl;
  if (savedCfProxy.isNotEmpty) {
    MClient.cfProxyUrl = savedCfProxy;
  }

  await DownloadManagerService.instance.initialize();

  runApp(const SunfireApp());
}
