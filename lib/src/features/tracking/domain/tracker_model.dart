// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

class TrackStatusDto {
  const TrackStatusDto({required this.value, required this.name});
  factory TrackStatusDto.fromJson(Map<String, dynamic> json) => TrackStatusDto(
        value: json['value'] as int,
        name: json['name'] as String,
      );
  final int value;
  final String name;
}

class TrackerDto {
  const TrackerDto({
    required this.id,
    required this.name,
    required this.icon,
    required this.isLoggedIn,
    this.authUrl,
    this.isTokenExpired,
    this.scores,
    this.statuses,
  });

  factory TrackerDto.fromJson(Map<String, dynamic> json) => TrackerDto(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String,
        isLoggedIn: json['isLoggedIn'] as bool,
        authUrl: json['authUrl'] as String?,
        isTokenExpired: json['isTokenExpired'] as bool?,
        scores: (json['scores'] as List<dynamic>?)?.cast<String>(),
        statuses: (json['statuses'] as List<dynamic>?)
            ?.map((e) => TrackStatusDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String name;
  final String icon;
  final bool isLoggedIn;
  final String? authUrl;
  final bool? isTokenExpired;
  final List<String>? scores;
  final List<TrackStatusDto>? statuses;
}

class TrackRecordDto {
  const TrackRecordDto({
    required this.id,
    required this.mangaId,
    required this.trackerId,
    required this.remoteId,
    required this.title,
    this.remoteUrl,
    this.status,
    this.lastChapterRead,
    this.totalChapters,
    this.score,
    this.displayScore,
    this.startDate,
    this.finishDate,
    this.trackerName,
    this.trackerScores,
    this.trackerStatuses,
  });

  factory TrackRecordDto.fromJson(Map<String, dynamic> json) {
    final tracker = json['tracker'] as Map<String, dynamic>?;
    return TrackRecordDto(
      id: json['id'] as int,
      mangaId: json['mangaId'] as int,
      trackerId: json['trackerId'] as int,
      remoteId: json['remoteId'] as String,
      title: json['title'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String?,
      status: json['status'] as int?,
      lastChapterRead: (json['lastChapterRead'] as num?)?.toDouble(),
      totalChapters: json['totalChapters'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      displayScore: json['displayScore'] as String?,
      startDate: json['startDate'] as String?,
      finishDate: json['finishDate'] as String?,
      trackerName: tracker?['name'] as String?,
      trackerScores: (tracker?['scores'] as List<dynamic>?)?.cast<String>(),
      trackerStatuses: (tracker?['statuses'] as List<dynamic>?)
          ?.map((e) => TrackStatusDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final int mangaId;
  final int trackerId;
  final String remoteId;
  final String title;
  final String? remoteUrl;
  final int? status;
  final double? lastChapterRead;
  final int? totalChapters;
  final double? score;
  final String? displayScore;
  final String? startDate;
  final String? finishDate;
  final String? trackerName;
  final List<String>? trackerScores;
  final List<TrackStatusDto>? trackerStatuses;
}

class TrackerSearchResultDto {
  const TrackerSearchResultDto({
    required this.remoteId,
    required this.trackerId,
    required this.title,
    this.coverUrl,
    this.summary,
    this.publishingStatus,
    this.publishingType,
    this.startDate,
    this.totalChapters,
    this.trackingUrl,
  });

  factory TrackerSearchResultDto.fromJson(Map<String, dynamic> json) =>
      TrackerSearchResultDto(
        remoteId: json['remoteId'].toString(),
        trackerId: json['trackerId'] as int,
        title: json['title'] as String? ?? '',
        coverUrl: json['coverUrl'] as String?,
        summary: json['summary'] as String?,
        publishingStatus: json['publishingStatus'] as String?,
        publishingType: json['publishingType'] as String?,
        startDate: json['startDate'] as String?,
        totalChapters: json['totalChapters'] != null
            ? (json['totalChapters'] as num).toInt()
            : null,
        trackingUrl: json['trackingUrl'] as String?,
      );

  final String remoteId;
  final int trackerId;
  final String title;
  final String? coverUrl;
  final String? summary;
  final String? publishingStatus;
  final String? publishingType;
  final String? startDate;
  final int? totalChapters;
  final String? trackingUrl;
}
