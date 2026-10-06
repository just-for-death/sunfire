// Value types for ISS-081 (extension stores), ISS-082 (backup validate /
// restore), ISS-083 (tracker metadata) and ISS-085 (KOReader sync). Kept free
// of Flutter imports so they are trivially unit-testable.

int _int(Object? v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

double _double(Object? v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}') ?? fallback;
}

String? _strOrNull(Object? v) {
  final s = v?.toString();
  return (s == null || s.isEmpty) ? null : s;
}

// ---------------------------------------------------------------------------
// ISS-081 B7 — extension stores
// ---------------------------------------------------------------------------

/// `ExtensionStoreType`.
class ExtensionStoreInfo {
  final String indexUrl;
  final String name;
  final String badgeLabel;
  final bool isLegacy;
  final String? contactWebsite;
  final String? contactDiscord;
  final String? extensionListUrl;
  final String? signingKey;

  /// `extensions.totalCount` when selected, else null.
  final int? extensionCount;

  const ExtensionStoreInfo({
    required this.indexUrl,
    required this.name,
    this.badgeLabel = '',
    this.isLegacy = false,
    this.contactWebsite,
    this.contactDiscord,
    this.extensionListUrl,
    this.signingKey,
    this.extensionCount,
  });

  factory ExtensionStoreInfo.fromMap(Map<dynamic, dynamic> m) {
    final ext = m['extensions'];
    return ExtensionStoreInfo(
      indexUrl: m['indexUrl']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
      badgeLabel: m['badgeLabel']?.toString() ?? '',
      isLegacy: m['isLegacy'] == true,
      contactWebsite: _strOrNull(m['contactWebsite']),
      contactDiscord: _strOrNull(m['contactDiscord']),
      extensionListUrl: _strOrNull(m['extensionListUrl']),
      signingKey: _strOrNull(m['signingKey']),
      extensionCount: ext is Map && ext['totalCount'] != null ? _int(ext['totalCount']) : null,
    );
  }

  static List<ExtensionStoreInfo> listFrom(Object? raw) => raw is List
      ? [for (final n in raw) if (n is Map) ExtensionStoreInfo.fromMap(n)]
      : const [];
}

/// Result of the `fetchExtensions` mutation (re-reads every store index).
class FetchExtensionsResult {
  final List<ExtensionStoreInfo> stores;

  /// Normalized extension nodes (same keys as `fetchExtensions()` query nodes,
  /// plus `storeIndexUrl` / `repo`).
  final List<Map<String, dynamic>> extensions;
  const FetchExtensionsResult({required this.stores, required this.extensions});
}

// ---------------------------------------------------------------------------
// ISS-082 B8 — backup validate / restore
// ---------------------------------------------------------------------------

/// `ValidateBackupResult`.
class BackupValidationResult {
  /// `(id, name)` of sources referenced by the backup but not installed.
  final List<({String id, String name})> missingSources;
  final List<String> missingTrackers;

  const BackupValidationResult({this.missingSources = const [], this.missingTrackers = const []});

  bool get isClean => missingSources.isEmpty && missingTrackers.isEmpty;

  factory BackupValidationResult.fromMap(Map<dynamic, dynamic> m) => BackupValidationResult(
        missingSources: [
          for (final s in (m['missingSources'] is List ? m['missingSources'] as List : const <dynamic>[]))
            if (s is Map) (id: s['id']?.toString() ?? '', name: s['name']?.toString() ?? ''),
        ],
        missingTrackers: [
          for (final t in (m['missingTrackers'] is List ? m['missingTrackers'] as List : const <dynamic>[]))
            if (t is Map && t['name'] != null) t['name'].toString(),
        ],
      );
}

/// `BackupRestoreState` values.
abstract final class BackupRestoreStates {
  static const idle = 'IDLE';
  static const success = 'SUCCESS';
  static const failure = 'FAILURE';
  static const restoringCategories = 'RESTORING_CATEGORIES';
  static const restoringManga = 'RESTORING_MANGA';
  static const restoringMeta = 'RESTORING_META';
  static const restoringSettings = 'RESTORING_SETTINGS';
  static const restoringUserSettings = 'RESTORING_USER_SETTINGS';
}

/// `BackupRestoreStatus`.
class BackupRestoreStatusInfo {
  final String state;
  final int mangaProgress;
  final int totalManga;

  const BackupRestoreStatusInfo({required this.state, this.mangaProgress = 0, this.totalManga = 0});

  factory BackupRestoreStatusInfo.fromMap(Map<dynamic, dynamic> m) => BackupRestoreStatusInfo(
        state: m['state']?.toString().toUpperCase() ?? BackupRestoreStates.idle,
        mangaProgress: _int(m['mangaProgress']),
        totalManga: _int(m['totalManga']),
      );

  bool get isSuccess => state == BackupRestoreStates.success;
  bool get isFailure => state == BackupRestoreStates.failure;
  bool get isTerminal => isSuccess || isFailure;
  bool get isRestoring => state.startsWith('RESTORING_');

  /// 0..1 manga progress (0 when the total is unknown).
  double get progress => totalManga <= 0 ? 0 : (mangaProgress / totalManga).clamp(0, 1).toDouble();

  @override
  String toString() => 'BackupRestoreStatusInfo($state $mangaProgress/$totalManga)';
}

/// `restoreBackup` payload: the restore job id + first status.
class BackupRestoreStart {
  final String id;
  final BackupRestoreStatusInfo? status;
  const BackupRestoreStart({required this.id, this.status});
}

/// `PartialBackupFlagsInput` (all optional; null = server default).
class BackupFlags {
  final bool? includeManga;
  final bool? includeCategories;
  final bool? includeChapters;
  final bool? includeTracking;
  final bool? includeHistory;
  final bool? includeClientData;
  final bool? includeServerSettings;
  final bool? includeUserSettings;

  const BackupFlags({
    this.includeManga,
    this.includeCategories,
    this.includeChapters,
    this.includeTracking,
    this.includeHistory,
    this.includeClientData,
    this.includeServerSettings,
    this.includeUserSettings,
  });

  Map<String, dynamic> toInput() => {
        if (includeManga != null) 'includeManga': includeManga,
        if (includeCategories != null) 'includeCategories': includeCategories,
        if (includeChapters != null) 'includeChapters': includeChapters,
        if (includeTracking != null) 'includeTracking': includeTracking,
        if (includeHistory != null) 'includeHistory': includeHistory,
        if (includeClientData != null) 'includeClientData': includeClientData,
        if (includeServerSettings != null) 'includeServerSettings': includeServerSettings,
        if (includeUserSettings != null) 'includeUserSettings': includeUserSettings,
      };
}

// ---------------------------------------------------------------------------
// ISS-083 B10 — tracker metadata from the server
// ---------------------------------------------------------------------------

/// `TrackStatusType`.
class TrackerStatusOption {
  final int value;
  final String name;
  const TrackerStatusOption({required this.value, required this.name});
}

/// `TrackerType` incl. server-provided statuses / scores / token state.
class TrackerInfo {
  final int id;
  final String name;
  final String? icon;
  final String? authUrl;
  final bool isLoggedIn;
  final bool isTokenExpired;
  final bool supportsPrivateTracking;
  final bool supportsReadingDates;
  final bool supportsTrackDeletion;

  /// Server order; use [TrackerStatusOption.value] for `updateTrack(status:)`.
  final List<TrackerStatusOption> statuses;

  /// Server score strings; pass one verbatim as `updateTrack(scoreString:)`.
  final List<String> scores;

  const TrackerInfo({
    required this.id,
    required this.name,
    this.icon,
    this.authUrl,
    this.isLoggedIn = false,
    this.isTokenExpired = false,
    this.supportsPrivateTracking = false,
    this.supportsReadingDates = false,
    this.supportsTrackDeletion = false,
    this.statuses = const [],
    this.scores = const [],
  });

  /// Logged in but the OAuth token expired → UI should offer re-login.
  bool get needsReLogin => isLoggedIn && isTokenExpired;

  String? statusName(int value) {
    for (final s in statuses) {
      if (s.value == value) return s.name;
    }
    return null;
  }

  factory TrackerInfo.fromMap(Map<dynamic, dynamic> m) => TrackerInfo(
        id: _int(m['id']),
        name: m['name']?.toString() ?? '',
        icon: _strOrNull(m['icon']),
        authUrl: _strOrNull(m['authUrl']),
        isLoggedIn: m['isLoggedIn'] == true,
        isTokenExpired: m['isTokenExpired'] == true,
        supportsPrivateTracking: m['supportsPrivateTracking'] == true,
        supportsReadingDates: m['supportsReadingDates'] == true,
        supportsTrackDeletion: m['supportsTrackDeletion'] == true,
        statuses: [
          for (final s in (m['statuses'] is List ? m['statuses'] as List : const <dynamic>[]))
            if (s is Map) TrackerStatusOption(value: _int(s['value']), name: s['name']?.toString() ?? ''),
        ],
        scores: [
          for (final s in (m['scores'] is List ? m['scores'] as List : const <dynamic>[]))
            if (s != null) s.toString(),
        ],
      );

  static List<TrackerInfo> listFrom(Object? raw) =>
      raw is List ? [for (final n in raw) if (n is Map) TrackerInfo.fromMap(n)] : const [];
}

/// `TrackRecordType` incl. `private` and `displayScore`.
class TrackRecordInfo {
  final int id;
  final int mangaId;
  final int trackerId;
  final String remoteId;
  final String? remoteUrl;
  final String title;
  final int status;
  final double lastChapterRead;
  final int totalChapters;
  final double score;
  final String displayScore;
  final String startDate;
  final String finishDate;
  final bool isPrivate;

  const TrackRecordInfo({
    required this.id,
    required this.mangaId,
    required this.trackerId,
    this.remoteId = '',
    this.remoteUrl,
    this.title = '',
    this.status = 0,
    this.lastChapterRead = 0,
    this.totalChapters = 0,
    this.score = 0,
    this.displayScore = '',
    this.startDate = '0',
    this.finishDate = '0',
    this.isPrivate = false,
  });

  factory TrackRecordInfo.fromMap(Map<dynamic, dynamic> m) => TrackRecordInfo(
        id: _int(m['id']),
        mangaId: _int(m['mangaId']),
        trackerId: _int(m['trackerId']),
        remoteId: m['remoteId']?.toString() ?? '',
        remoteUrl: _strOrNull(m['remoteUrl']),
        title: m['title']?.toString() ?? '',
        status: _int(m['status']),
        lastChapterRead: _double(m['lastChapterRead']),
        totalChapters: _int(m['totalChapters']),
        score: _double(m['score']),
        displayScore: m['displayScore']?.toString() ?? '',
        startDate: m['startDate']?.toString() ?? '0',
        finishDate: m['finishDate']?.toString() ?? '0',
        isPrivate: m['private'] == true,
      );
}

// ---------------------------------------------------------------------------
// ISS-085 B14 — KOReader sync
// ---------------------------------------------------------------------------

/// `KoSyncStatusPayload`.
class KoSyncStatus {
  final bool isLoggedIn;
  final String? serverAddress;
  final String? username;

  /// `KoSyncConnectPayload.message` (connect only).
  final String? message;

  const KoSyncStatus({required this.isLoggedIn, this.serverAddress, this.username, this.message});

  factory KoSyncStatus.fromMap(Map<dynamic, dynamic> m, {String? message}) => KoSyncStatus(
        isLoggedIn: m['isLoggedIn'] == true,
        serverAddress: _strOrNull(m['serverAddress']),
        username: _strOrNull(m['username']),
        message: message,
      );
}

/// `pullKoSyncProgress` result.
class KoSyncPullResult {
  /// Updated chapter fields (`id`, `lastPageRead`, `isRead`, `lastReadAt`) or null.
  final Map<String, dynamic>? chapter;

  /// Non-null when the remote progress conflicts (PROMPT strategy).
  final ({String deviceName, int remotePage})? conflict;

  const KoSyncPullResult({this.chapter, this.conflict});
}
