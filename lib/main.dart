import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'src/app.dart';
import 'src/core/db/isar_service.dart';
import 'src/core/engine/image_transport_service.dart';
import 'src/core/engine/quickjs_service.dart';
import 'src/core/engine/source_preferences.dart';
import 'src/core/logging/logger_service.dart';
import 'src/core/metron/metron_service.dart';
import 'src/core/services/download_manager_service.dart';
import 'src/core/services/image_cache_helper.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/services/settings_service.dart';
import 'src/core/sync/background_service.dart';
import 'src/core/sync/download_foreground_task.dart';
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
  } catch (e, st) {
    // The most consequential of the three: a failed Isar init means the local
    // library, reading history, bookmarks and download flags are all unreadable,
    // and the app presents as an empty install. Previously invisible in release.
    await LoggerService.instance.logError(
      'IsarService failed to initialise — local library, history and download '
      'state are unavailable',
      exception: e,
      stackTrace: st,
      category: 'Startup',
    );
  }

  try {
    await SettingsService.instance.initialize();
  } catch (e, st) {
    // Logged, not debugPrint'd.
    //
    // `debugPrint` is stripped in release, so a SharedPreferences failure was
    // completely invisible. Every settings read and write goes through the
    // `_prefs?.` null guard, so with `_prefs` left null the app did not throw —
    // it silently reverted to defaults: server URL empty, incognito off, every
    // stored preference gone, and every toggle a no-op that snapped straight
    // back. The user saw an app that had forgotten all their configuration with
    // no way to tell that from installing it fresh, and no diagnostic to send.
    //
    // LoggerService is initialised above and also keeps an in-memory log, so
    // this is safe to call even when its own file init failed.
    await LoggerService.instance.logError(
      'SettingsService failed to initialise — the app is running with DEFAULT '
      'settings and any change the user makes now will be silently discarded',
      exception: e,
      stackTrace: st,
      category: 'Startup',
    );
  }

  try {
    await MetronService.instance.initialize();
  } catch (e, st) {
    // Release-visible for the same reason as the settings init above: a silent
    // Metron failure means tracking-linked scrobbles stop working with no
    // indication that anything is wrong.
    await LoggerService.instance.logError(
      'MetronService failed to initialise — tracker integration is unavailable',
      exception: e,
      stackTrace: st,
      category: 'Startup',
    );
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
      // If the server rejects the socket's credentials (close 4401/4403),
      // re-read the stored token — a re-login elsewhere in the app may have
      // already rotated it — and reconnect immediately. Without this the
      // reconnect loop retried the same dead token forever.
      WebSocketService.instance.onAuthExpired = () async {
        final refreshed = await ServerAuthHelper.getRawAuthHeader();
        return refreshed.trim().isEmpty ? null : refreshed;
      };
      SyncEngine.instance.initialize();
      await BackgroundService.instance.initialize();
    } catch (e) {
      debugPrint('SyncEngine/Network init error: $e');
    }
  }

  // NOTE: the saved FlareSolverr / Byparr URL is applied to MClient by
  // SettingsService.initialize() above. Doing it here instead meant the
  // WorkManager background isolate — which never runs this file — silently
  // bypassed the Cloudflare bypass and failed on protected sources.

  // Android foreground service that keeps the download queue alive while the
  // app is backgrounded. No-op on other platforms. Initialised BEFORE the
  // download manager so the "Stop" (pause) callback is registered before the
  // queue can start the service — a tap during the very first seconds is
  // never lost.
  try {
    DownloadForegroundTask.instance.initialize();
    // Handle pause signal sent from the background isolate when the user taps
    // "Stop" on the foreground-service notification.
    FlutterForegroundTask.addTaskDataCallback(_onForegroundTaskData);
  } catch (e) {
    debugPrint('DownloadForegroundTask init error: $e');
  }

  try {
    await DownloadManagerService.instance.initialize();
  } catch (e) {
    debugPrint('DownloadManagerService init error: $e');
  }

  runApp(const SunfireApp());
}

/// Handles messages from the foreground-service background isolate.
void _onForegroundTaskData(Object data) {
  if (data is Map<String, dynamic> && data['action'] == 'pause') {
    DownloadManagerService.instance.pauseLocalQueue();
  }
}
