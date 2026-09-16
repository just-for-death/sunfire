import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/core/db/isar_service.dart';
import 'src/core/engine/image_transport_service.dart';
import 'src/core/engine/javascript/m_client.dart';
import 'src/core/engine/quickjs_service.dart';
import 'src/core/engine/source_preferences.dart';
import 'src/core/logging/logger_service.dart';
import 'src/core/metron/metron_service.dart';
import 'src/core/services/download_manager_service.dart';
import 'src/core/services/image_cache_helper.dart';
import 'src/core/services/notification_service.dart';
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

  try {
    await LoggerService.instance.initialize();
  } catch (e) {
    debugPrint('LoggerService init error: $e');
  }

  try {
    await IsarService.instance.initialize();
    // One-time startup cleanup: removes excess bulk-scraped standalone chapters.
    // This MUST NOT be called on every screen load — only here at startup.
    unawaited(IsarService.instance.cleanupBulkScrapedUpdates());
  } catch (e) {
    debugPrint('IsarService init error: $e');
  }

  try {
    await SettingsService.instance.initialize();
  } catch (e) {
    debugPrint('SettingsService init error: $e');
  }

  try {
    await MetronService.instance.initialize();
  } catch (e) {
    debugPrint('MetronService init error: $e');
  }

  try {
    await SourcePreferences.hydrate();
  } catch (e) {
    debugPrint('SourcePreferences hydrate error: $e');
  }

  try {
    await ImageCacheHelper.initialize();
  } catch (e) {
    debugPrint('ImageCacheHelper init error: $e');
  }

  try {
    await QuickJsService.instance.initialize();
  } catch (e) {
    debugPrint('QuickJsService init error: $e');
  }

  try {
    ImageTransportService.instance.initialize();
  } catch (e) {
    debugPrint('ImageTransportService init error: $e');
  }

  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // Configure Suwayomi GraphQL client and SyncEngine only after onboarding
  if (SettingsService.instance.onboardingCompleted) {
    try {
      final authToken = await ServerAuthHelper.getRawAuthHeader();
      GraphQLClientService.instance.initialize(SettingsService.instance.serverUrl, authToken: authToken);
      WebSocketService.instance.initialize(SettingsService.instance.serverUrl, authToken: authToken);
      SyncEngine.instance.initialize();
      await BackgroundService.instance.initialize();
    } catch (e) {
      debugPrint('SyncEngine/Network init error: $e');
    }
  }

  // Load saved FlareSolverr / Byparr URL into MClient so Cloudflare-protected
  // sources work immediately on startup.
  try {
    final savedCfProxy = SettingsService.instance.cfProxyUrl;
    if (savedCfProxy.isNotEmpty) {
      MClient.cfProxyUrl = savedCfProxy;
    }
  } catch (_) {}

  try {
    await DownloadManagerService.instance.initialize();
  } catch (e) {
    debugPrint('DownloadManagerService init error: $e');
  }

  runApp(const SunfireApp());
}
