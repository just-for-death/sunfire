import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
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

const _kSyncTaskName = 'sunfire_background_sync';
const _kSyncTaskTag = 'sunfire_sync';

/// Top-level callback invoked by WorkManager in an isolated background process.
/// Must be a top-level or static function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Logger first, on its own, so every later failure has somewhere to go.
      await LoggerService.instance.initialize();

      // Settings and Isar SEQUENTIALLY, before anything that reads or writes
      // them.
      //
      // These were in a `Future.wait`, so `onboardingCompleted` on the very next
      // line could be read while `SettingsService.initialize()` had not yet
      // assigned `_prefs`. That getter then falls through its `??` chain to
      // `false`, the task returned `true`, and WorkManager recorded SUCCESS —
      // so a fully on-boarded user silently got no background library update and
      // no notification, and would not be retried for another `freqHours` (up to
      // a week). Nothing distinguished it from "no new chapters".
      //
      // `Future.wait(...).timeout()` also does not cancel its futures, so a
      // timeout left the rest of the bootstrap running unattended underneath a
      // task that had already given up.
      await SettingsService.instance.initialize();
      await IsarService.instance.initialize();

      // The remainder is genuinely independent, so it can still go in parallel —
      // with a timeout, which is now a genuine "we could not start in time"
      // rather than a way to observe half-initialised state.
      await Future.wait([
        QuickJsService.instance.initialize(),
        ImageCacheHelper.initialize(),
        NotificationService.instance.initialize(),
      ]).timeout(const Duration(seconds: 20));

      // Belt and braces: the sequential awaits above have completed, so these
      // cannot be false for a real user. If they somehow are, the task did NOT
      // do its work, so it must not report success.
      if (!SettingsService.instance.onboardingCompleted) {
        await LoggerService.instance.logInfo(
          'Background sync skipped: onboarding is not marked complete',
          'BackgroundService',
        );
        return true; // Genuinely nothing to do for a new install.
      }
      if (!IsarService.instance.isInitialized) {
        await LoggerService.instance.logWarning(
          'Background sync skipped: the local database did not initialise, so '
          'there is nothing to reconcile against',
          'BackgroundService',
        );
        return false; // Retry, do not record a no-op as success.
      }

      final authToken = await ServerAuthHelper.getRawAuthHeader();
      GraphQLClientService.instance.initialize(
        SettingsService.instance.serverUrl,
        authToken: authToken,
      );

      // Check for new chapters and dispatch notification if discovered
      // Note: checkForNewChapters automatically invokes SyncEngine.triggerSync()
      await LibraryUpdateService.instance.checkForNewChapters(isManual: false);

      // Update extensions if repos are configured AND auto-update is enabled.
      final repos = SettingsService.instance.customRepos;
      if (repos.isNotEmpty && SettingsService.instance.autoUpdateJsSources) {
        await RepoManager.instance.updateInstalledExtensions(repos, requireIntegrity: true);
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
      return false;
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
      } else {
        // Frequency disabled (0 = off): make sure no stale periodic task from a
        // previous boot survives. Without this, a task registered when the user
        // had auto-update enabled keeps running after they disable it and the
        // app is restarted.
        await cancelAll();
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
    } catch (ignoredError) { if (kDebugMode) debugPrint('[background_service] ignored error: $ignoredError'); }
  }
}
