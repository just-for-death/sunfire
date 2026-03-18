// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/tracker_repository.dart';
import '../../domain/tracker_model.dart';

part 'tracker_controller.g.dart';

/// All available tracker services
@riverpod
Future<List<TrackerDto>> trackers(Ref ref) =>
    ref.watch(trackerRepositoryProvider).getTrackers();

/// Track records for a given manga (plain old FutureProvider.family — no codegen)
final mangaTrackRecordsProvider =
    FutureProvider.autoDispose.family<List<TrackRecordDto>, int>(
  (ref, mangaId) =>
      ref.watch(trackerRepositoryProvider).getTrackRecords(mangaId),
);

/// Search results from a tracker
final trackerSearchProvider = FutureProvider.autoDispose
    .family<List<TrackerSearchResultDto>, ({int trackerId, String query})>(
  (ref, args) {
    if (args.query.trim().isEmpty) return Future.value([]);
    return ref
        .watch(trackerRepositoryProvider)
        .searchTracker(args.trackerId, args.query);
  },
);

/// Notifier that handles tracker login/logout mutations and refreshes state
@riverpod
class TrackerAuthNotifier extends _$TrackerAuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> loginCredentials(
      int trackerId, String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(trackerRepositoryProvider)
          .loginTrackerCredentials(trackerId, username, password);
      ref.invalidate(trackersProvider);
    });
  }

  Future<void> loginOAuth(int trackerId, String callbackUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(trackerRepositoryProvider)
          .loginTrackerOAuth(trackerId, callbackUrl);
      ref.invalidate(trackersProvider);
    });
  }

  Future<void> logout(int trackerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(trackerRepositoryProvider).logoutTracker(trackerId);
      ref.invalidate(trackersProvider);
    });
  }
}
