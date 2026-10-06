part of 'graphql_client_service.dart';

// ISS-079 / 081 / 082 / 083 / 085 service APIs. Lives in a part file so it can
// reuse the private Dio for multipart uploads while keeping the main client
// file readable. All methods are reachable as
// `GraphQLClientService.instance.<name>` for any importer of
// graphql_client_service.dart.

extension GraphQLServerCompatApi on GraphQLClientService {
  // ---------------------------------------------------------------------------
  // ISS-079 B4 — source filters / preferences
  // ---------------------------------------------------------------------------

  /// Filters + preferences of one server source (aliased union selections).
  Future<SourceFiltersAndPreferences?> fetchSourceFiltersAndPreferences(String sourceId) async {
    final doc = '''
      query SourceFiltersAndPreferences(\$id: LongString!) {
        source(id: \$id) {
          id
          name
          displayName
          isConfigurable
          supportsLatest
          $kSourceFiltersSelection
          $kSourcePreferencesSelection
        }
      }
    ''';
    final res = await query(doc, variables: {'id': sourceId}, label: 'fetchSourceFiltersAndPreferences', op: GraphQLOp.read);
    final src = res?['source'];
    return src is Map ? SourceFiltersAndPreferences.fromMap(src) : null;
  }

  /// Filters only (cheaper; for the filter sheet).
  Future<List<SourceFilter>?> fetchSourceFilters(String sourceId) async {
    final doc = '''
      query SourceFilters(\$id: LongString!) {
        source(id: \$id) { id $kSourceFiltersSelection }
      }
    ''';
    final res = await query(doc, variables: {'id': sourceId}, label: 'fetchSourceFilters', op: GraphQLOp.read);
    final src = res?['source'];
    return src is Map ? parseSourceFilters(src['filters']) : null;
  }

  /// Preferences only.
  Future<List<SourcePreference>?> fetchSourcePreferences(String sourceId) async {
    final doc = '''
      query SourcePreferences(\$id: LongString!) {
        source(id: \$id) { id $kSourcePreferencesSelection }
      }
    ''';
    final res = await query(doc, variables: {'id': sourceId}, label: 'fetchSourcePreferences', op: GraphQLOp.read);
    final src = res?['source'];
    return src is Map ? parseSourcePreferences(src['preferences']) : null;
  }

  /// Writes one preference; returns the server's refreshed preference list
  /// (positions can shift visibility, so re-render from this), or null on failure.
  Future<List<SourcePreference>?> updateSourcePreference(String sourceId, SourcePreferenceChange change) async {
    final doc = '''
      mutation UpdateSourcePreference(\$source: LongString!, \$change: SourcePreferenceChangeInput!) {
        updateSourcePreference(input: { source: \$source, change: \$change }) {
          $kSourcePreferencesSelection
        }
      }
    ''';
    final res = await query(
      doc,
      variables: {'source': sourceId, 'change': change.toInput()},
      label: 'updateSourcePreference',
      op: GraphQLOp.write,
    );
    final payload = res?['updateSourcePreference'];
    return payload is Map ? parseSourcePreferences(payload['preferences']) : null;
  }

  // ---------------------------------------------------------------------------
  // ISS-081 B7 — extension stores
  // ---------------------------------------------------------------------------

  static const String _storeFields =
      'indexUrl name badgeLabel isLegacy contactWebsite contactDiscord extensionListUrl signingKey';

  /// All configured extension stores (`extensionStores`). [includeCounts]
  /// adds `extensions { totalCount }` per store.
  Future<List<ExtensionStoreInfo>?> fetchExtensionStores({bool includeCounts = false}) async {
    final doc = '{ extensionStores { nodes { $_storeFields${includeCounts ? ' extensions { totalCount }' : ''} } } }';
    final res = await query(doc, label: 'fetchExtensionStores', op: GraphQLOp.read);
    final list = res?['extensionStores'];
    if (list is! Map) return null;
    return ExtensionStoreInfo.listFrom(list['nodes']);
  }

  /// Adds a store by its index URL (e.g. `…/repo/index.pb` or legacy
  /// `index.min.json`). Returns the server's store, or null on failure
  /// (invalid URL / unreachable index → GraphQL error, logged).
  Future<ExtensionStoreInfo?> addExtensionStore(String indexUrl) async {
    final url = indexUrl.trim();
    if (url.isEmpty) return null;
    final doc = '''
      mutation AddExtensionStore(\$indexUrl: String!) {
        addExtensionStore(input: { indexUrl: \$indexUrl }) { extensionStore { $_storeFields } }
      }
    ''';
    final res = await query(doc, variables: {'indexUrl': url}, label: 'addExtensionStore', op: GraphQLOp.write);
    final store = (res?['addExtensionStore'] as Map?)?['extensionStore'];
    return store is Map ? ExtensionStoreInfo.fromMap(store) : null;
  }

  /// Removes a store. True when the server acknowledged the mutation.
  Future<bool> removeExtensionStore(String indexUrl) async {
    final url = indexUrl.trim();
    if (url.isEmpty) return false;
    const doc = r'''
      mutation RemoveExtensionStore($indexUrl: String!) {
        removeExtensionStore(input: { indexUrl: $indexUrl }) { extensionStore { indexUrl } }
      }
    ''';
    final res = await query(doc, variables: {'indexUrl': url}, label: 'removeExtensionStore', op: GraphQLOp.write);
    return res != null && res.containsKey('removeExtensionStore');
  }

  /// `fetchExtensions` mutation: server re-downloads every store index and
  /// returns the refreshed stores + extensions. Idempotent (slowRead policy).
  Future<FetchExtensionsResult?> refreshExtensionStores() async {
    const doc = '''
      mutation RefreshExtensions {
        fetchExtensions(input: {}) {
          extensionStores { $_storeFields }
          extensions {
            pkgName name versionName lang isInstalled isObsolete hasUpdate
            iconUrl isNsfw contentWarning repo storeIndexUrl
          }
        }
      }
    ''';
    final res = await query(doc, label: 'refreshExtensionStores', op: GraphQLOp.slowRead);
    final payload = res?['fetchExtensions'];
    if (payload is! Map) return null;
    final normalized = _normalizeSourceOrExtensionNodes(
      {'x': {'nodes': payload['extensions'] is List ? payload['extensions'] : const <dynamic>[]}},
      rootKey: 'x',
    );
    final nodes = (normalized?['x'] as Map?)?['nodes'];
    return FetchExtensionsResult(
      stores: ExtensionStoreInfo.listFrom(payload['extensionStores']),
      extensions: [
        if (nodes is List)
          for (final n in nodes)
            if (n is Map) Map<String, dynamic>.from(n),
      ],
    );
  }

  /// Extensions of one store (`extensions(condition: {storeIndexUrl})`),
  /// same shape as `fetchExtensions()` plus `storeIndexUrl`.
  Future<Map<String, dynamic>?> fetchExtensionsForStore(String indexUrl) async {
    const doc = r'''
      query ExtensionsForStore($url: String!) {
        extensions(condition: { storeIndexUrl: $url }) {
          nodes {
            pkgName name versionName lang isInstalled isObsolete hasUpdate
            iconUrl isNsfw contentWarning storeIndexUrl
          }
        }
      }
    ''';
    final data = await query(doc, variables: {'url': indexUrl}, label: 'fetchExtensionsForStore', op: GraphQLOp.read);
    return _normalizeSourceOrExtensionNodes(data, rootKey: 'extensions');
  }

  // ---------------------------------------------------------------------------
  // ISS-082 B8 — backup validate / restore (GraphQL multipart upload)
  // ---------------------------------------------------------------------------

  /// Uploads [bytes] to `validateBackup` (read-only on the server).
  Future<BackupValidationResult?> validateBackup(List<int> bytes, {String filename = 'backup.tachibk'}) async {
    const doc = r'''
      query ValidateBackup($backup: Upload!) {
        validateBackup(input: { backup: $backup }) {
          missingSources { id name }
          missingTrackers { name }
        }
      }
    ''';
    final res = await _multipartUpload(doc, fileVariable: 'backup', bytes: bytes, filename: filename, label: 'validateBackup');
    final v = res?['validateBackup'];
    return v is Map ? BackupValidationResult.fromMap(v) : null;
  }

  /// Starts a restore. Returns the job id (poll with [watchRestoreStatus]) or
  /// null on failure. Never retried (not idempotent).
  Future<BackupRestoreStart?> restoreBackup(
    List<int> bytes, {
    String filename = 'backup.tachibk',
    BackupFlags? flags,
  }) async {
    const doc = r'''
      mutation RestoreBackup($backup: Upload!, $flags: PartialBackupFlagsInput) {
        restoreBackup(input: { backup: $backup, flags: $flags }) {
          id
          status { state mangaProgress totalManga }
        }
      }
    ''';
    final res = await _multipartUpload(
      doc,
      fileVariable: 'backup',
      bytes: bytes,
      filename: filename,
      label: 'restoreBackup',
      variables: {if (flags != null) 'flags': flags.toInput()},
    );
    final p = res?['restoreBackup'];
    if (p is! Map || p['id'] == null) return null;
    final st = p['status'];
    return BackupRestoreStart(
      id: p['id'].toString(),
      status: st is Map ? BackupRestoreStatusInfo.fromMap(st) : null,
    );
  }

  /// Typed `restoreStatus(id)`; null when unknown/unreachable.
  Future<BackupRestoreStatusInfo?> getRestoreStatus(String restoreId) async {
    final res = await fetchRestoreStatus(restoreId);
    final st = res?['restoreStatus'];
    return st is Map ? BackupRestoreStatusInfo.fromMap(st) : null;
  }

  /// Polls `restoreStatus` every [interval] until SUCCESS / FAILURE, [timeout],
  /// or [maxConsecutiveFailures] null polls in a row (stream then closes
  /// without a terminal event — treat as "unknown", not failure).
  Stream<BackupRestoreStatusInfo> watchRestoreStatus(
    String restoreId, {
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(minutes: 30),
    int maxConsecutiveFailures = 10,
  }) async* {
    final deadline = DateTime.now().add(timeout);
    var misses = 0;
    BackupRestoreStatusInfo? last;
    while (DateTime.now().isBefore(deadline)) {
      final st = await getRestoreStatus(restoreId);
      if (st == null) {
        if (++misses >= maxConsecutiveFailures) return;
      } else {
        misses = 0;
        if (last == null || st.state != last.state || st.mangaProgress != last.mangaProgress || st.totalManga != last.totalManga) {
          yield st;
        }
        last = st;
        if (st.isTerminal) return;
      }
      await Future<void>.delayed(interval);
    }
  }

  /// [restoreBackup] + [watchRestoreStatus]; returns the last status seen
  /// (terminal on completion) or null when the restore could not start.
  Future<BackupRestoreStatusInfo?> restoreBackupAndWait(
    List<int> bytes, {
    String filename = 'backup.tachibk',
    BackupFlags? flags,
    void Function(BackupRestoreStatusInfo status)? onProgress,
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(minutes: 30),
  }) async {
    final start = await restoreBackup(bytes, filename: filename, flags: flags);
    if (start == null) return null;
    var last = start.status;
    if (last != null) onProgress?.call(last);
    if (last != null && last.isTerminal) return last;
    await for (final st in watchRestoreStatus(start.id, interval: interval, timeout: timeout)) {
      last = st;
      onProgress?.call(st);
    }
    return last;
  }

  /// GraphQL multipart request (graphql-multipart-request-spec):
  /// `operations` + `map` + file part `0` → `variables.<fileVariable>`.
  Future<Map<String, dynamic>?> _multipartUpload(
    String document, {
    required String fileVariable,
    required List<int> bytes,
    required String filename,
    required String label,
    Map<String, dynamic> variables = const {},
  }) async {
    if (!isConfigured) return null;
    final refresher = authRefresher;
    if (refresher != null) await refresher.beforeRequest();
    for (var attempt = 0; attempt < 2; attempt++) {
      final form = FormData.fromMap({
        'operations': jsonEncode({
          'query': document,
          'variables': {...variables, fileVariable: null},
        }),
        'map': jsonEncode({
          '0': ['variables.$fileVariable'],
        }),
        '0': MultipartFile.fromBytes(bytes, filename: filename),
      });
      try {
        final response = await _dio.post<dynamic>(
          '',
          data: form,
          options: Options(
            contentType: 'multipart/form-data; boundary=${form.boundary}',
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 5),
          ),
        );
        _lastReachableStatus = true;
        _lastReachableCheck = DateTime.now();
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        if (data is! Map) return null;
        if (data['errors'] != null) {
          final errors = data['errors'];
          final msg = (errors is List && errors.isNotEmpty && errors.first is Map)
              ? (errors.first as Map)['message']?.toString() ?? ''
              : errors.toString();
          await LoggerService.instance.logWarning('GraphQL Error [$label]: $msg', 'GraphQL');
          if (GraphQLClientService._looksLikeAuthError(msg)) {
            notifyAuthError();
            if (attempt == 0 && refresher != null && await refresher.onUnauthorized()) continue;
          }
          return null;
        }
        clearAuthError();
        final d = data['data'];
        return d is Map ? Map<String, dynamic>.from(d) : null;
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          notifyAuthError();
          if (attempt == 0 && refresher != null && await refresher.onUnauthorized()) continue;
        } else if (GraphQLClientService._isTransportFailure(e)) {
          _lastReachableStatus = false;
          _lastReachableCheck = DateTime.now();
        }
        await LoggerService.instance.logWarning('GraphQL upload failed [$label]: ${e.message}', 'GraphQL');
        return null;
      } catch (e) {
        await LoggerService.instance.logWarning('GraphQL upload [$label] unparseable: $e', 'GraphQL');
        return null;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // ISS-083 B10 — tracker metadata from the server
  // ---------------------------------------------------------------------------

  /// Trackers with server-provided `statuses`, `scores`, `isTokenExpired`,
  /// `supportsPrivateTracking`, `supportsReadingDates`, `supportsTrackDeletion`.
  /// Use these instead of hard-coded per-tracker tables.
  Future<List<TrackerInfo>?> fetchTrackerInfos() async {
    const doc = '''
      {
        trackers {
          nodes {
            id name icon authUrl isLoggedIn isTokenExpired
            supportsPrivateTracking supportsReadingDates supportsTrackDeletion
            scores
            statuses { name value }
          }
        }
      }
    ''';
    final res = await query(doc, label: 'fetchTrackerInfos', op: GraphQLOp.read);
    final t = res?['trackers'];
    return t is Map ? TrackerInfo.listFrom(t['nodes']) : null;
  }

  /// Track records for [mangaId] incl. `private` and `displayScore`.
  Future<List<TrackRecordInfo>?> fetchTrackRecordInfos(int mangaId) async {
    const doc = r'''
      query TrackRecordInfos($mangaId: Int!) {
        trackRecords(condition: { mangaId: $mangaId }) {
          nodes {
            id mangaId trackerId remoteId remoteUrl title status lastChapterRead
            totalChapters score displayScore startDate finishDate private
          }
        }
      }
    ''';
    final res = await query(doc, variables: {'mangaId': mangaId}, label: 'fetchTrackRecordInfos', op: GraphQLOp.read);
    final t = res?['trackRecords'];
    if (t is! Map || t['nodes'] is! List) return null;
    return [
      for (final n in t['nodes'] as List)
        if (n is Map) TrackRecordInfo.fromMap(n),
    ];
  }

  /// Sets only the `private` flag of a record (trackers with
  /// `supportsPrivateTracking`).
  Future<bool> setTrackRecordPrivate(int recordId, bool isPrivate) async {
    const doc = r'''
      mutation SetTrackPrivate($recordId: Int!, $private: Boolean) {
        updateTrack(input: { recordId: $recordId, private: $private }) {
          trackRecord { id private }
        }
      }
    ''';
    final res = await query(doc, variables: {'recordId': recordId, 'private': isPrivate}, label: 'setTrackRecordPrivate', op: GraphQLOp.write);
    return res != null;
  }

  // ---------------------------------------------------------------------------
  // ISS-085 B14 — KOReader sync + SyncYomi
  // ---------------------------------------------------------------------------

  static const String _koStatusFields = 'isLoggedIn serverAddress username';

  Future<KoSyncStatus?> fetchKoSyncStatus() async {
    final res = await query('{ koSyncStatus { $_koStatusFields } }', label: 'fetchKoSyncStatus', op: GraphQLOp.read);
    final s = res?['koSyncStatus'];
    return s is Map ? KoSyncStatus.fromMap(s) : null;
  }

  /// Connects the server to a KOReader sync server. [KoSyncStatus.message]
  /// carries the server's explanation when the login was refused.
  Future<KoSyncStatus?> connectKoSyncAccount({
    required String serverAddress,
    required String username,
    required String password,
  }) async {
    const doc = '''
      mutation ConnectKoSync(\$serverAddress: String!, \$username: String!, \$password: String!) {
        connectKoSyncAccount(input: { serverAddress: \$serverAddress, username: \$username, password: \$password }) {
          message
          status { $_koStatusFields }
        }
      }
    ''';
    final res = await query(
      doc,
      variables: {'serverAddress': serverAddress.trim(), 'username': username.trim(), 'password': password},
      label: 'connectKoSyncAccount',
      op: GraphQLOp.write,
    );
    final p = res?['connectKoSyncAccount'];
    if (p is! Map || p['status'] is! Map) return null;
    return KoSyncStatus.fromMap(p['status'] as Map, message: p['message']?.toString());
  }

  Future<KoSyncStatus?> logoutKoSyncAccount() async {
    const doc = '''
      mutation LogoutKoSync { logoutKoSyncAccount(input: {}) { status { $_koStatusFields } } }
    ''';
    final res = await query(doc, label: 'logoutKoSyncAccount', op: GraphQLOp.write);
    final s = (res?['logoutKoSyncAccount'] as Map?)?['status'];
    return s is Map ? KoSyncStatus.fromMap(s) : null;
  }

  /// Pulls remote KOReader progress for [chapterId] into the server.
  Future<KoSyncPullResult?> pullKoSyncProgress(int chapterId) async {
    const doc = r'''
      mutation PullKoSync($chapterId: Int!) {
        pullKoSyncProgress(input: { chapterId: $chapterId }) {
          chapter { id lastPageRead isRead lastReadAt }
          syncConflict { deviceName remotePage }
        }
      }
    ''';
    final res = await query(doc, variables: {'chapterId': chapterId}, label: 'pullKoSyncProgress', op: GraphQLOp.write);
    if (res == null || !res.containsKey('pullKoSyncProgress')) return null;
    final p = res['pullKoSyncProgress'];
    if (p is! Map) return const KoSyncPullResult();
    final ch = p['chapter'];
    final c = p['syncConflict'];
    return KoSyncPullResult(
      chapter: ch is Map ? Map<String, dynamic>.from(ch) : null,
      conflict: c is Map ? (deviceName: c['deviceName']?.toString() ?? '', remotePage: parseIntSafe(c['remotePage'])) : null,
    );
  }

  /// Pushes the server's progress for [chapterId] to KOReader sync.
  Future<bool> pushKoSyncProgress(int chapterId) async {
    const doc = r'''
      mutation PushKoSync($chapterId: Int!) {
        pushKoSyncProgress(input: { chapterId: $chapterId }) { success }
      }
    ''';
    final res = await query(doc, variables: {'chapterId': chapterId}, label: 'pushKoSyncProgress', op: GraphQLOp.write);
    return (res?['pushKoSyncProgress'] as Map?)?['success'] == true;
  }

  /// Triggers a SyncYomi sync. Returns `SUCCESS` | `SYNC_IN_PROGRESS` |
  /// `SYNC_DISABLED` (SyncYomi off in user settings), or null on failure.
  Future<String?> startSyncYomi() async {
    const doc = 'mutation StartSync { startSync(input: {}) { result } }';
    final res = await query(doc, label: 'startSyncYomi', op: GraphQLOp.write);
    return (res?['startSync'] as Map?)?['result']?.toString();
  }

  /// `lastSyncStatus` (`state`, `startDate`, `endDate`, `errorMessage`,
  /// `backupRestoreId`) or null when the server never synced / unreachable.
  Future<Map<String, dynamic>?> fetchLastSyncStatus() async {
    const doc = '{ lastSyncStatus { state startDate endDate errorMessage backupRestoreId } }';
    final res = await query(doc, label: 'fetchLastSyncStatus', op: GraphQLOp.read);
    final s = res?['lastSyncStatus'];
    return s is Map ? Map<String, dynamic>.from(s) : null;
  }
}
