import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app.dart';
import 'src/core/db/isar_service.dart';
import 'src/core/engine/image_transport_service.dart';
import 'src/core/engine/javascript/m_client.dart';
import 'src/core/engine/quickjs_service.dart';
import 'src/core/logging/logger_service.dart';
import 'src/core/services/download_manager_service.dart';
import 'src/core/services/image_cache_helper.dart';
import 'src/core/services/settings_service.dart';
import 'src/core/sync/graphql_client_service.dart';
import 'src/core/sync/sync_engine.dart';

class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _AppHttpOverrides();

  await SentryFlutter.init(
    (options) {
      options.dsn = '';
      options.tracesSampleRate = 1.0;
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      await LoggerService.instance.initialize();
      await IsarService.instance.initialize();
      await SettingsService.instance.initialize();
      await ImageCacheHelper.initialize();
      await QuickJsService.instance.initialize();
      ImageTransportService.instance.initialize();

      // Configure Suwayomi GraphQL client and SyncEngine only after onboarding
      if (SettingsService.instance.onboardingCompleted) {
        GraphQLClientService.instance.initialize(SettingsService.instance.serverUrl);
        SyncEngine.instance.initialize();
      }

      // Load saved FlareSolverr / Byparr URL into MClient so Cloudflare-protected
      // sources (Mangago, ReadComicOnline, etc.) work immediately on startup.
      final savedCfProxy = SettingsService.instance.cfProxyUrl;
      if (savedCfProxy.isNotEmpty) {
        MClient.cfProxyUrl = savedCfProxy;
      }

      await DownloadManagerService.instance.initialize();

      runApp(const SunfireApp());
    },
  );
}
