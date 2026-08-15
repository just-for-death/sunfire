import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app.dart';
import 'src/core/db/isar_service.dart';
import 'src/core/engine/image_transport_service.dart';
import 'src/core/engine/quickjs_service.dart';
import 'src/core/logging/logger_service.dart';
import 'src/core/services/download_manager_service.dart';
import 'src/core/services/settings_service.dart';
import 'src/core/sync/graphql_client_service.dart';
import 'src/core/sync/sync_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      QuickJsService.instance.initialize();
      ImageTransportService.instance.initialize();

      // Configure Suwayomi GraphQL client and SyncEngine
      GraphQLClientService.instance.initialize(SettingsService.instance.serverUrl);
      SyncEngine.instance.initialize();
      await DownloadManagerService.instance.initialize();

      runApp(const SunfireApp());
    },
  );
}
