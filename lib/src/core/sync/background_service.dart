import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../db/isar_service.dart';
import '../engine/quickjs_service.dart';
import '../engine/repo_manager.dart';
import '../logging/logger_service.dart';
import '../services/image_cache_helper.dart';
import '../services/library_update_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import 'graphql_client_service.dart';
import 'server_auth_helper.dart';
import 'sync_engine.dart';

const _kSyncTaskName = 'sunfire_background_sync';
const _kSyncTaskTag = 'sunfire_sync';

/// Top-level callback invoked by WorkManager in an isolated background process.
/// Must be a top-level or static function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Minimal bootstrap — only what is needed for sync.
      await LoggerService.instance.initialize();
      await IsarService.instance.initialize();
      await SettingsService.instance.initialize();
      await QuickJsService.instance.initialize();
      await ImageCacheHelper.initialize();
      await NotificationService.instance.initialize();

      if (!SettingsService.instance.onboardingCompleted) return true;

      final authToken = await ServerAuthHelper.getRawAuthHeader();
      GraphQLClientService.instance.initialize(
        SettingsService.instance.serverUrl,
        authToken: authToken,
      );

      // Check for new chapters and dispatch notification if discovered
      await LibraryUpdateService.instance.checkForNewChapters(isManual: false);

      await SyncEngine.instance.triggerSync();

      // Update extensions if repos are configured.
      final repos = SettingsService.instance.customRepos;
      if (repos.isNotEmpty) {
        await RepoManager.instance.updateInstalledExtensions(repos);
      }

      await LoggerService.instance.logInfo(
        'Background sync task completed successfully',
        'BackgroundService',
      );
    } catch (e, st) {
      await LoggerService.instance.logError(
        'Background sync task failed: $e',
        exception: e,
        stackTrace: st,
        category: 'BackgroundService',
      );
    }
    return true;
  });
}

class BackgroundService {
  BackgroundService._();
  static final BackgroundService instance = BackgroundService._();

  /// Call once during app start (after onboarding) to register the periodic task.
  Future<void> initialize() async {
    // WorkManager background scheduling is Android-only.
    // On iOS, sideloaded environments (LiveContainer, AltStore, TrollStore) crash if BGTaskScheduler is called,
    // and sync is cleanly handled on app resume via AppLifecycleState.resumed.
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Register periodic sync according to user settings
      final onlyWifi = SettingsService.instance.libraryUpdateOnlyOnWifi;
      final onlyCharging = SettingsService.instance.libraryUpdateOnlyCharging;
      final freqHours = SettingsService.instance.libraryUpdateFrequencyHours;

      if (freqHours > 0) {
        await Workmanager().registerPeriodicTask(
          _kSyncTaskName,
          _kSyncTaskName,
          tag: _kSyncTaskTag,
          frequency: Duration(hours: freqHours.clamp(1, 168)),
          constraints: Constraints(
            networkType: onlyWifi ? NetworkType.unmetered : NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: onlyCharging,
          ),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
          backoffPolicy: BackoffPolicy.exponential,
          backoffPolicyDelay: const Duration(minutes: 2),
        );

        await LoggerService.instance.logInfo(
          'BackgroundService: periodic sync registered (every ${freqHours}h, unmetered: $onlyWifi, charging: $onlyCharging)',
          'BackgroundService',
        );
      }
    } catch (e) {
      await LoggerService.instance.logWarning(
        'BackgroundService init failed (non-critical): $e',
        'BackgroundService',
      );
    }
  }

  /// Reconfigures periodic background task constraints according to user's Mihon settings.
  Future<void> rescheduleTask() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final freqHours = SettingsService.instance.libraryUpdateFrequencyHours;
      if (freqHours <= 0) {
        await cancelAll();
        return;
      }

      final onlyWifi = SettingsService.instance.libraryUpdateOnlyOnWifi;
      final onlyCharging = SettingsService.instance.libraryUpdateOnlyCharging;

      await Workmanager().registerPeriodicTask(
        _kSyncTaskName,
        _kSyncTaskName,
        tag: _kSyncTaskTag,
        frequency: Duration(hours: freqHours.clamp(1, 168)),
        constraints: Constraints(
          networkType: onlyWifi ? NetworkType.unmetered : NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: onlyCharging,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 2),
      );
    } catch (e) {
      debugPrint('[BackgroundService] rescheduleTask error: $e');
    }
  }

  /// Cancel all scheduled background tasks (e.g. on sign-out or reset).
  Future<void> cancelAll() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await Workmanager().cancelAll();
    } catch (_) {}
  }
}
