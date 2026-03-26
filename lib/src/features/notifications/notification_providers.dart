// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../browse_center/data/extension_repository/extension_repository.dart';
import '../manga_book/data/updates/updates_repository.dart';
import '../manga_book/domain/manga/manga_model.dart';
import '../manga_book/domain/update_status/update_status_model.dart';
import 'notification_service.dart';
import '../../global_providers/global_providers.dart';
import '../settings/presentation/server/widget/credential_popup/credentials_popup.dart';
import '../../constants/enum.dart';
import '../../constants/endpoints.dart';
import '../../constants/db_keys.dart';
import '../settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import '../settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import '../../utils/extensions/custom_extensions.dart';

part 'notification_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Notification service provider
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final svc = NotificationService.instance;
  
  // Get base URL for thumbnails
  final baseUrl = Endpoints.baseApi(
    baseUrl: ref.watch(serverUrlProvider) ?? DBKeys.serverUrl.initial,
    port: ref.watch(serverPortProvider),
    addPort: ref.watch(serverPortToggleProvider).ifNull(),
    appendApiToUrl: false,
  );
  svc.updateBaseUrl(baseUrl);
  
  // Get auth headers from global providers
  final authType = ref.watch(authTypeKeyProvider);
  final credentials = ref.watch(credentialsProvider);
  
  if (authType == AuthType.basic && credentials.isNotBlank) {
    svc.updateHeaders({'Authorization': 'Basic $credentials'});
  } else {
    svc.updateHeaders(null);
  }

  // init() is idempotent — safe to call multiple times
  svc.init();
  return svc;
}

// ---------------------------------------------------------------------------
// 2. Chapter update notifier
//    Watches the live WebSocket stream. When the update run transitions from
//    "in progress" → "finished", it fires a notification for the completed count.
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ChapterUpdateNotifier extends _$ChapterUpdateNotifier {
  bool _wasRunning = false;

  @override
  void build() {
    final stream = ref.watch(updatesSocketProvider);

    stream.whenData((status) {
      if (status == null) return;

      final isRunning = status.isUpdateChecking;

      // Transition: running → completed
      if (_wasRunning && !isRunning) {
        final mangaNodes = status.completeJobs.mangas.nodes;
        
        // Group by manga ID to count chapters per manga
        final mangaGroups = <int, _MangaUpdateGroup>{};
        for (final manga in mangaNodes) {
          final group = mangaGroups.putIfAbsent(
            manga.id, 
            () => _MangaUpdateGroup(manga: manga, count: 0)
          );
          group.count++;
        }

        // Fire notifications for the first 3 unique mangas
        final top3 = mangaGroups.values.take(3).toList();
        for (final group in top3) {
          _fireMangaNotification(group.manga, group.count);
        }

        // If there were more than 3, we could show a summary for the rest, 
        // but the requirements asked for separate ones for "the" mangas.
      }

      _wasRunning = isRunning;
    });
  }

  void _fireMangaNotification(MangaDto manga, int count) {
    final svc = ref.read(notificationServiceProvider);
    svc.showMangaUpdateNotification(manga: manga, chaptersCount: count);
  }

  /// Can be called externally to force a check (e.g., after a manual refresh).
  Future<void> checkNow() async {
    final summary =
        await ref.read(updatesRepositoryProvider).summaryUpdates();
    if (summary == null) return;
    if (!summary.isUpdateChecking) {
      final mangaNodes = summary.completeJobs.mangas.nodes;
      final mangaGroups = <int, _MangaUpdateGroup>{};
      for (final manga in mangaNodes) {
        final group = mangaGroups.putIfAbsent(
          manga.id, 
          () => _MangaUpdateGroup(manga: manga, count: 0)
        );
        group.count++;
      }

      for (final group in mangaGroups.values.take(3)) {
        _fireMangaNotification(group.manga, group.count);
      }
    }
  }
}

class _MangaUpdateGroup {
  final MangaDto manga;
  int count;

  _MangaUpdateGroup({required this.manga, required this.count});
}

// ---------------------------------------------------------------------------
// 3. Extension update notifier
//    Polls periodically (every 6 hours) for extensions that have updates.
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class ExtensionUpdateNotifier extends _$ExtensionUpdateNotifier {
  Timer? _timer;
  int _lastNotifiedCount = 0;

  @override
  void build() {
    // Run once on startup; then start the recurring timer.
    _checkExtensionUpdates();

    _timer = Timer.periodic(const Duration(hours: 6), (_) {
      _checkExtensionUpdates();
    });

    ref.onDispose(() {
      _timer?.cancel();
    });
  }

  Future<void> _checkExtensionUpdates() async {
    try {
      final extensions =
          await ref.read(extensionRepositoryProvider).getExtensionListStream();
      if (extensions == null) return;

      final updateCount = extensions.where((e) => e.hasUpdate).length;

      // Only notify if the count changed since we last notified
      if (updateCount > 0 && updateCount != _lastNotifiedCount) {
        _lastNotifiedCount = updateCount;
        final svc = ref.read(notificationServiceProvider);
        await svc.showExtensionUpdateNotification(updateCount: updateCount);
      }
    } catch (_) {
      // Network errors during background poll should be silent
    }
  }

  /// Force-check immediately (e.g., user navigates to Extensions tab).
  Future<void> checkNow() => _checkExtensionUpdates();
}
