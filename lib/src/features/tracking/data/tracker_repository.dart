// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:graphql/client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../global_providers/global_providers.dart';
import '../domain/tracker_model.dart';

part 'tracker_repository.g.dart';

// ─── GraphQL documents ───────────────────────────────────────────────────────

const _kGetTrackers = r'''
query GetTrackers {
  trackers {
    nodes {
      id
      name
      icon
      isLoggedIn
      authUrl
      isTokenExpired
      scores
      statuses {
        value
        name
      }
    }
  }
}
''';

const _kGetTrackRecords = r'''
query GetTrackRecords($mangaId: Int!) {
  trackRecords(condition: { mangaId: $mangaId }) {
    nodes {
      id
      mangaId
      trackerId
      remoteId
      title
      remoteUrl
      status
      lastChapterRead
      totalChapters
      score
      displayScore
      startDate
      finishDate
      tracker {
        name
        scores
        statuses {
          value
          name
        }
      }
    }
  }
}
''';

const _kSearchTracker = r'''
query SearchTracker($trackerId: Int!, $query: String!) {
  searchTracker(input: { trackerId: $trackerId, query: $query }) {
    trackSearches {
      remoteId
      trackerId
      title
      coverUrl
      summary
      publishingStatus
      publishingType
      startDate
      totalChapters
      trackingUrl
    }
  }
}
''';

const _kBindTrack = r'''
mutation BindTrack($mangaId: Int!, $trackerId: Int!, $remoteId: LongString!) {
  bindTrack(input: { mangaId: $mangaId, trackerId: $trackerId, remoteId: $remoteId }) {
    trackRecord {
      id
      mangaId
      trackerId
      remoteId
      title
      remoteUrl
      status
      lastChapterRead
      totalChapters
      score
      startDate
      finishDate
    }
  }
}
''';

const _kUnbindTrack = r'''
mutation UnbindTrack($recordId: Int!, $deleteRemoteTrack: Boolean) {
  unbindTrack(input: { recordId: $recordId, deleteRemoteTrack: $deleteRemoteTrack }) {
    trackRecord {
      id
    }
  }
}
''';

const _kUpdateTrack = r'''
mutation UpdateTrack(
  $recordId: Int!
  $status: Int
  $lastChapterRead: Float
  $scoreString: String
  $startDate: LongString
  $finishDate: LongString
) {
  updateTrack(input: {
    recordId: $recordId
    status: $status
    lastChapterRead: $lastChapterRead
    scoreString: $scoreString
    startDate: $startDate
    finishDate: $finishDate
  }) {
    trackRecord {
      id
      status
      lastChapterRead
      score
      startDate
      finishDate
    }
  }
}
''';

const _kLoginTrackerCredentials = r'''
mutation LoginTrackerCredentials($trackerId: Int!, $username: String!, $password: String!) {
  loginTrackerCredentials(input: { trackerId: $trackerId, username: $username, password: $password }) {
    isLoggedIn
    tracker {
      id
      name
      isLoggedIn
    }
  }
}
''';

const _kLoginTrackerOAuth = r'''
mutation LoginTrackerOAuth($trackerId: Int!, $callbackUrl: String!) {
  loginTrackerOAuth(input: { trackerId: $trackerId, callbackUrl: $callbackUrl }) {
    isLoggedIn
    tracker {
      id
      name
      isLoggedIn
    }
  }
}
''';

const _kLogoutTracker = r'''
mutation LogoutTracker($trackerId: Int!) {
  logoutTracker(input: { trackerId: $trackerId }) {
    tracker {
      id
      name
      isLoggedIn
    }
  }
}
''';

const _kFetchTrack = r'''
mutation FetchTrack($recordId: Int!) {
  fetchTrack(input: { recordId: $recordId }) {
    trackRecord {
      id
      status
      lastChapterRead
      totalChapters
      score
      startDate
      finishDate
    }
  }
}
''';

// ─── Repository ──────────────────────────────────────────────────────────────

class TrackerRepository {
  const TrackerRepository(this._client);
  final GraphQLClient _client;

  Future<List<TrackerDto>> getTrackers() async {
    final result = await _client.query(
      QueryOptions(document: gql(_kGetTrackers)),
    );
    if (result.hasException) throw result.exception!;
    final nodes =
        result.data?['trackers']?['nodes'] as List<dynamic>? ?? [];
    return nodes
        .map((e) => TrackerDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrackRecordDto>> getTrackRecords(int mangaId) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_kGetTrackRecords),
        variables: {'mangaId': mangaId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final nodes =
        result.data?['trackRecords']?['nodes'] as List<dynamic>? ?? [];
    return nodes
        .map((e) => TrackRecordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TrackerSearchResultDto>> searchTracker(
      int trackerId, String query) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_kSearchTracker),
        variables: {'trackerId': trackerId, 'query': query},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final searches = result.data?['searchTracker']?['trackSearches']
            as List<dynamic>? ??
        [];
    return searches
        .map((e) => TrackerSearchResultDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TrackRecordDto?> bindTrack(
      int mangaId, int trackerId, String remoteId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kBindTrack),
        variables: {
          'mangaId': mangaId,
          'trackerId': trackerId,
          'remoteId': remoteId,
        },
      ),
    );
    if (result.hasException) throw result.exception!;
    final record =
        result.data?['bindTrack']?['trackRecord'] as Map<String, dynamic>?;
    if (record == null) return null;
    return TrackRecordDto.fromJson(Map<String, dynamic>.from(record));
  }

  Future<void> unbindTrack(int recordId,
      {bool deleteRemoteTrack = false}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kUnbindTrack),
        variables: {
          'recordId': recordId,
          'deleteRemoteTrack': deleteRemoteTrack,
        },
      ),
    );
    if (result.hasException) throw result.exception!;
  }

  Future<TrackRecordDto?> updateTrack({
    required int recordId,
    int? status,
    double? lastChapterRead,
    String? scoreString,
    String? startDate,
    String? finishDate,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kUpdateTrack),
        variables: {
          'recordId': recordId,
          if (status != null) 'status': status,
          if (lastChapterRead != null) 'lastChapterRead': lastChapterRead,
          if (scoreString != null) 'scoreString': scoreString,
          if (startDate != null) 'startDate': startDate,
          if (finishDate != null) 'finishDate': finishDate,
        },
      ),
    );
    if (result.hasException) throw result.exception!;
    final record = result.data?['updateTrack']?['trackRecord']
        as Map<String, dynamic>?;
    if (record == null) return null;
    // updateTrack returns partial record - minimal fields only
    return null;
  }

  Future<bool> loginTrackerCredentials(
      int trackerId, String username, String password) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kLoginTrackerCredentials),
        variables: {
          'trackerId': trackerId,
          'username': username,
          'password': password,
        },
      ),
    );
    if (result.hasException) throw result.exception!;
    return result.data?['loginTrackerCredentials']?['isLoggedIn'] == true;
  }

  Future<bool> loginTrackerOAuth(int trackerId, String callbackUrl) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kLoginTrackerOAuth),
        variables: {
          'trackerId': trackerId,
          'callbackUrl': callbackUrl,
        },
      ),
    );
    if (result.hasException) throw result.exception!;
    return result.data?['loginTrackerOAuth']?['isLoggedIn'] == true;
  }

  Future<void> logoutTracker(int trackerId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kLogoutTracker),
        variables: {'trackerId': trackerId},
      ),
    );
    if (result.hasException) throw result.exception!;
  }

  Future<void> fetchTrack(int recordId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_kFetchTrack),
        variables: {'recordId': recordId},
      ),
    );
    if (result.hasException) throw result.exception!;
  }
}

@riverpod
TrackerRepository trackerRepository(Ref ref) =>
    TrackerRepository(ref.watch(trackerGraphQlClientProvider));
