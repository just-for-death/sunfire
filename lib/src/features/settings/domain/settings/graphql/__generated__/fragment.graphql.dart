import '../../../../../../graphql/__generated__/schema.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$SettingsDto
    implements
        Fragment$AutomaticBackupSettingsDto,
        Fragment$ServerBindingDto,
        Fragment$SocksProxyDto,
        Fragment$CloudFlareBypassDto,
        Fragment$MiscSettingsDto,
        Fragment$BrowserSettingsDto,
        Fragment$LibrarySettingsDto,
        Fragment$DownloadsSettingsDto {
  Fragment$SettingsDto({
    required this.backupInterval,
    required this.backupPath,
    required this.backupTTL,
    required this.backupTime,
    this.$__typename = 'SettingsType',
    required this.ip,
    required this.port,
    required this.socksProxyEnabled,
    required this.socksProxyHost,
    required this.socksProxyPassword,
    required this.socksProxyPort,
    required this.socksProxyUsername,
    required this.socksProxyVersion,
    required this.flareSolverrEnabled,
    required this.flareSolverrSessionName,
    required this.flareSolverrSessionTtl,
    required this.flareSolverrTimeout,
    required this.flareSolverrUrl,
    required this.debugLogsEnabled,
    required this.systemTrayEnabled,
    required this.extensionRepos,
    required this.maxSourcesInParallel,
    required this.localSourcePath,
    required this.globalUpdateInterval,
    required this.updateMangas,
    required this.excludeCompleted,
    required this.excludeNotStarted,
    required this.excludeUnreadChapters,
    required this.downloadAsCbz,
    required this.downloadsPath,
    required this.autoDownloadNewChapters,
    required this.autoDownloadNewChaptersLimit,
    required this.excludeEntryWithUnreadChapters,
  });

  factory Fragment$SettingsDto.fromJson(Map<String, dynamic> json) {
    final l$backupInterval = json['backupInterval'];
    final l$backupPath = json['backupPath'];
    final l$backupTTL = json['backupTTL'];
    final l$backupTime = json['backupTime'];
    final l$$__typename = json['__typename'];
    final l$ip = json['ip'];
    final l$port = json['port'];
    final l$socksProxyEnabled = json['socksProxyEnabled'];
    final l$socksProxyHost = json['socksProxyHost'];
    final l$socksProxyPassword = json['socksProxyPassword'];
    final l$socksProxyPort = json['socksProxyPort'];
    final l$socksProxyUsername = json['socksProxyUsername'];
    final l$socksProxyVersion = json['socksProxyVersion'];
    final l$flareSolverrEnabled = json['flareSolverrEnabled'];
    final l$flareSolverrSessionName = json['flareSolverrSessionName'];
    final l$flareSolverrSessionTtl = json['flareSolverrSessionTtl'];
    final l$flareSolverrTimeout = json['flareSolverrTimeout'];
    final l$flareSolverrUrl = json['flareSolverrUrl'];
    final l$debugLogsEnabled = json['debugLogsEnabled'];
    final l$systemTrayEnabled = json['systemTrayEnabled'];
    final l$extensionRepos = json['extensionRepos'];
    final l$maxSourcesInParallel = json['maxSourcesInParallel'];
    final l$localSourcePath = json['localSourcePath'];
    final l$globalUpdateInterval = json['globalUpdateInterval'];
    final l$updateMangas = json['updateMangas'];
    final l$excludeCompleted = json['excludeCompleted'];
    final l$excludeNotStarted = json['excludeNotStarted'];
    final l$excludeUnreadChapters = json['excludeUnreadChapters'];
    final l$downloadAsCbz = json['downloadAsCbz'];
    final l$downloadsPath = json['downloadsPath'];
    final l$autoDownloadNewChapters = json['autoDownloadNewChapters'];
    final l$autoDownloadNewChaptersLimit = json['autoDownloadNewChaptersLimit'];
    final l$excludeEntryWithUnreadChapters =
        json['excludeEntryWithUnreadChapters'];
    return Fragment$SettingsDto(
      backupInterval: (l$backupInterval as int),
      backupPath: (l$backupPath as String),
      backupTTL: (l$backupTTL as int),
      backupTime: (l$backupTime as String),
      $__typename: (l$$__typename as String),
      ip: (l$ip as String),
      port: (l$port as int),
      socksProxyEnabled: (l$socksProxyEnabled as bool),
      socksProxyHost: (l$socksProxyHost as String),
      socksProxyPassword: (l$socksProxyPassword as String),
      socksProxyPort: (l$socksProxyPort as String),
      socksProxyUsername: (l$socksProxyUsername as String),
      socksProxyVersion: (l$socksProxyVersion as int),
      flareSolverrEnabled: (l$flareSolverrEnabled as bool),
      flareSolverrSessionName: (l$flareSolverrSessionName as String),
      flareSolverrSessionTtl: (l$flareSolverrSessionTtl as int),
      flareSolverrTimeout: (l$flareSolverrTimeout as int),
      flareSolverrUrl: (l$flareSolverrUrl as String),
      debugLogsEnabled: (l$debugLogsEnabled as bool),
      systemTrayEnabled: (l$systemTrayEnabled as bool),
      extensionRepos: (l$extensionRepos as List<dynamic>)
          .map((e) => (e as String))
          .toList(),
      maxSourcesInParallel: (l$maxSourcesInParallel as int),
      localSourcePath: (l$localSourcePath as String),
      globalUpdateInterval: (l$globalUpdateInterval as num).toDouble(),
      updateMangas: (l$updateMangas as bool),
      excludeCompleted: (l$excludeCompleted as bool),
      excludeNotStarted: (l$excludeNotStarted as bool),
      excludeUnreadChapters: (l$excludeUnreadChapters as bool),
      downloadAsCbz: (l$downloadAsCbz as bool),
      downloadsPath: (l$downloadsPath as String),
      autoDownloadNewChapters: (l$autoDownloadNewChapters as bool),
      autoDownloadNewChaptersLimit: (l$autoDownloadNewChaptersLimit as int),
      excludeEntryWithUnreadChapters:
          (l$excludeEntryWithUnreadChapters as bool),
    );
  }

  final int backupInterval;

  final String backupPath;

  final int backupTTL;

  final String backupTime;

  final String $__typename;

  final String ip;

  final int port;

  final bool socksProxyEnabled;

  final String socksProxyHost;

  final String socksProxyPassword;

  final String socksProxyPort;

  final String socksProxyUsername;

  final int socksProxyVersion;

  final bool flareSolverrEnabled;

  final String flareSolverrSessionName;

  final int flareSolverrSessionTtl;

  final int flareSolverrTimeout;

  final String flareSolverrUrl;

  final bool debugLogsEnabled;

  final bool systemTrayEnabled;

  final List<String> extensionRepos;

  final int maxSourcesInParallel;

  final String localSourcePath;

  final double globalUpdateInterval;

  final bool updateMangas;

  final bool excludeCompleted;

  final bool excludeNotStarted;

  final bool excludeUnreadChapters;

  final bool downloadAsCbz;

  final String downloadsPath;

  final bool autoDownloadNewChapters;

  final int autoDownloadNewChaptersLimit;

  final bool excludeEntryWithUnreadChapters;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$backupInterval = backupInterval;
    _resultData['backupInterval'] = l$backupInterval;
    final l$backupPath = backupPath;
    _resultData['backupPath'] = l$backupPath;
    final l$backupTTL = backupTTL;
    _resultData['backupTTL'] = l$backupTTL;
    final l$backupTime = backupTime;
    _resultData['backupTime'] = l$backupTime;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$ip = ip;
    _resultData['ip'] = l$ip;
    final l$port = port;
    _resultData['port'] = l$port;
    final l$socksProxyEnabled = socksProxyEnabled;
    _resultData['socksProxyEnabled'] = l$socksProxyEnabled;
    final l$socksProxyHost = socksProxyHost;
    _resultData['socksProxyHost'] = l$socksProxyHost;
    final l$socksProxyPassword = socksProxyPassword;
    _resultData['socksProxyPassword'] = l$socksProxyPassword;
    final l$socksProxyPort = socksProxyPort;
    _resultData['socksProxyPort'] = l$socksProxyPort;
    final l$socksProxyUsername = socksProxyUsername;
    _resultData['socksProxyUsername'] = l$socksProxyUsername;
    final l$socksProxyVersion = socksProxyVersion;
    _resultData['socksProxyVersion'] = l$socksProxyVersion;
    final l$flareSolverrEnabled = flareSolverrEnabled;
    _resultData['flareSolverrEnabled'] = l$flareSolverrEnabled;
    final l$flareSolverrSessionName = flareSolverrSessionName;
    _resultData['flareSolverrSessionName'] = l$flareSolverrSessionName;
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    _resultData['flareSolverrSessionTtl'] = l$flareSolverrSessionTtl;
    final l$flareSolverrTimeout = flareSolverrTimeout;
    _resultData['flareSolverrTimeout'] = l$flareSolverrTimeout;
    final l$flareSolverrUrl = flareSolverrUrl;
    _resultData['flareSolverrUrl'] = l$flareSolverrUrl;
    final l$debugLogsEnabled = debugLogsEnabled;
    _resultData['debugLogsEnabled'] = l$debugLogsEnabled;
    final l$systemTrayEnabled = systemTrayEnabled;
    _resultData['systemTrayEnabled'] = l$systemTrayEnabled;
    final l$extensionRepos = extensionRepos;
    _resultData['extensionRepos'] = l$extensionRepos.map((e) => e).toList();
    final l$maxSourcesInParallel = maxSourcesInParallel;
    _resultData['maxSourcesInParallel'] = l$maxSourcesInParallel;
    final l$localSourcePath = localSourcePath;
    _resultData['localSourcePath'] = l$localSourcePath;
    final l$globalUpdateInterval = globalUpdateInterval;
    _resultData['globalUpdateInterval'] = l$globalUpdateInterval;
    final l$updateMangas = updateMangas;
    _resultData['updateMangas'] = l$updateMangas;
    final l$excludeCompleted = excludeCompleted;
    _resultData['excludeCompleted'] = l$excludeCompleted;
    final l$excludeNotStarted = excludeNotStarted;
    _resultData['excludeNotStarted'] = l$excludeNotStarted;
    final l$excludeUnreadChapters = excludeUnreadChapters;
    _resultData['excludeUnreadChapters'] = l$excludeUnreadChapters;
    final l$downloadAsCbz = downloadAsCbz;
    _resultData['downloadAsCbz'] = l$downloadAsCbz;
    final l$downloadsPath = downloadsPath;
    _resultData['downloadsPath'] = l$downloadsPath;
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    _resultData['autoDownloadNewChapters'] = l$autoDownloadNewChapters;
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    _resultData['autoDownloadNewChaptersLimit'] =
        l$autoDownloadNewChaptersLimit;
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    _resultData['excludeEntryWithUnreadChapters'] =
        l$excludeEntryWithUnreadChapters;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$backupInterval = backupInterval;
    final l$backupPath = backupPath;
    final l$backupTTL = backupTTL;
    final l$backupTime = backupTime;
    final l$$__typename = $__typename;
    final l$ip = ip;
    final l$port = port;
    final l$socksProxyEnabled = socksProxyEnabled;
    final l$socksProxyHost = socksProxyHost;
    final l$socksProxyPassword = socksProxyPassword;
    final l$socksProxyPort = socksProxyPort;
    final l$socksProxyUsername = socksProxyUsername;
    final l$socksProxyVersion = socksProxyVersion;
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final l$flareSolverrUrl = flareSolverrUrl;
    final l$debugLogsEnabled = debugLogsEnabled;
    final l$systemTrayEnabled = systemTrayEnabled;
    final l$extensionRepos = extensionRepos;
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final l$localSourcePath = localSourcePath;
    final l$globalUpdateInterval = globalUpdateInterval;
    final l$updateMangas = updateMangas;
    final l$excludeCompleted = excludeCompleted;
    final l$excludeNotStarted = excludeNotStarted;
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final l$downloadAsCbz = downloadAsCbz;
    final l$downloadsPath = downloadsPath;
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    return Object.hashAll([
      l$backupInterval,
      l$backupPath,
      l$backupTTL,
      l$backupTime,
      l$$__typename,
      l$ip,
      l$port,
      l$socksProxyEnabled,
      l$socksProxyHost,
      l$socksProxyPassword,
      l$socksProxyPort,
      l$socksProxyUsername,
      l$socksProxyVersion,
      l$flareSolverrEnabled,
      l$flareSolverrSessionName,
      l$flareSolverrSessionTtl,
      l$flareSolverrTimeout,
      l$flareSolverrUrl,
      l$debugLogsEnabled,
      l$systemTrayEnabled,
      Object.hashAll(l$extensionRepos.map((v) => v)),
      l$maxSourcesInParallel,
      l$localSourcePath,
      l$globalUpdateInterval,
      l$updateMangas,
      l$excludeCompleted,
      l$excludeNotStarted,
      l$excludeUnreadChapters,
      l$downloadAsCbz,
      l$downloadsPath,
      l$autoDownloadNewChapters,
      l$autoDownloadNewChaptersLimit,
      l$excludeEntryWithUnreadChapters,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SettingsDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$backupInterval = backupInterval;
    final lOther$backupInterval = other.backupInterval;
    if (l$backupInterval != lOther$backupInterval) {
      return false;
    }
    final l$backupPath = backupPath;
    final lOther$backupPath = other.backupPath;
    if (l$backupPath != lOther$backupPath) {
      return false;
    }
    final l$backupTTL = backupTTL;
    final lOther$backupTTL = other.backupTTL;
    if (l$backupTTL != lOther$backupTTL) {
      return false;
    }
    final l$backupTime = backupTime;
    final lOther$backupTime = other.backupTime;
    if (l$backupTime != lOther$backupTime) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$ip = ip;
    final lOther$ip = other.ip;
    if (l$ip != lOther$ip) {
      return false;
    }
    final l$port = port;
    final lOther$port = other.port;
    if (l$port != lOther$port) {
      return false;
    }
    final l$socksProxyEnabled = socksProxyEnabled;
    final lOther$socksProxyEnabled = other.socksProxyEnabled;
    if (l$socksProxyEnabled != lOther$socksProxyEnabled) {
      return false;
    }
    final l$socksProxyHost = socksProxyHost;
    final lOther$socksProxyHost = other.socksProxyHost;
    if (l$socksProxyHost != lOther$socksProxyHost) {
      return false;
    }
    final l$socksProxyPassword = socksProxyPassword;
    final lOther$socksProxyPassword = other.socksProxyPassword;
    if (l$socksProxyPassword != lOther$socksProxyPassword) {
      return false;
    }
    final l$socksProxyPort = socksProxyPort;
    final lOther$socksProxyPort = other.socksProxyPort;
    if (l$socksProxyPort != lOther$socksProxyPort) {
      return false;
    }
    final l$socksProxyUsername = socksProxyUsername;
    final lOther$socksProxyUsername = other.socksProxyUsername;
    if (l$socksProxyUsername != lOther$socksProxyUsername) {
      return false;
    }
    final l$socksProxyVersion = socksProxyVersion;
    final lOther$socksProxyVersion = other.socksProxyVersion;
    if (l$socksProxyVersion != lOther$socksProxyVersion) {
      return false;
    }
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final lOther$flareSolverrEnabled = other.flareSolverrEnabled;
    if (l$flareSolverrEnabled != lOther$flareSolverrEnabled) {
      return false;
    }
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final lOther$flareSolverrSessionName = other.flareSolverrSessionName;
    if (l$flareSolverrSessionName != lOther$flareSolverrSessionName) {
      return false;
    }
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final lOther$flareSolverrSessionTtl = other.flareSolverrSessionTtl;
    if (l$flareSolverrSessionTtl != lOther$flareSolverrSessionTtl) {
      return false;
    }
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final lOther$flareSolverrTimeout = other.flareSolverrTimeout;
    if (l$flareSolverrTimeout != lOther$flareSolverrTimeout) {
      return false;
    }
    final l$flareSolverrUrl = flareSolverrUrl;
    final lOther$flareSolverrUrl = other.flareSolverrUrl;
    if (l$flareSolverrUrl != lOther$flareSolverrUrl) {
      return false;
    }
    final l$debugLogsEnabled = debugLogsEnabled;
    final lOther$debugLogsEnabled = other.debugLogsEnabled;
    if (l$debugLogsEnabled != lOther$debugLogsEnabled) {
      return false;
    }
    final l$systemTrayEnabled = systemTrayEnabled;
    final lOther$systemTrayEnabled = other.systemTrayEnabled;
    if (l$systemTrayEnabled != lOther$systemTrayEnabled) {
      return false;
    }
    final l$extensionRepos = extensionRepos;
    final lOther$extensionRepos = other.extensionRepos;
    if (l$extensionRepos.length != lOther$extensionRepos.length) {
      return false;
    }
    for (int i = 0; i < l$extensionRepos.length; i++) {
      final l$extensionRepos$entry = l$extensionRepos[i];
      final lOther$extensionRepos$entry = lOther$extensionRepos[i];
      if (l$extensionRepos$entry != lOther$extensionRepos$entry) {
        return false;
      }
    }
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final lOther$maxSourcesInParallel = other.maxSourcesInParallel;
    if (l$maxSourcesInParallel != lOther$maxSourcesInParallel) {
      return false;
    }
    final l$localSourcePath = localSourcePath;
    final lOther$localSourcePath = other.localSourcePath;
    if (l$localSourcePath != lOther$localSourcePath) {
      return false;
    }
    final l$globalUpdateInterval = globalUpdateInterval;
    final lOther$globalUpdateInterval = other.globalUpdateInterval;
    if (l$globalUpdateInterval != lOther$globalUpdateInterval) {
      return false;
    }
    final l$updateMangas = updateMangas;
    final lOther$updateMangas = other.updateMangas;
    if (l$updateMangas != lOther$updateMangas) {
      return false;
    }
    final l$excludeCompleted = excludeCompleted;
    final lOther$excludeCompleted = other.excludeCompleted;
    if (l$excludeCompleted != lOther$excludeCompleted) {
      return false;
    }
    final l$excludeNotStarted = excludeNotStarted;
    final lOther$excludeNotStarted = other.excludeNotStarted;
    if (l$excludeNotStarted != lOther$excludeNotStarted) {
      return false;
    }
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final lOther$excludeUnreadChapters = other.excludeUnreadChapters;
    if (l$excludeUnreadChapters != lOther$excludeUnreadChapters) {
      return false;
    }
    final l$downloadAsCbz = downloadAsCbz;
    final lOther$downloadAsCbz = other.downloadAsCbz;
    if (l$downloadAsCbz != lOther$downloadAsCbz) {
      return false;
    }
    final l$downloadsPath = downloadsPath;
    final lOther$downloadsPath = other.downloadsPath;
    if (l$downloadsPath != lOther$downloadsPath) {
      return false;
    }
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final lOther$autoDownloadNewChapters = other.autoDownloadNewChapters;
    if (l$autoDownloadNewChapters != lOther$autoDownloadNewChapters) {
      return false;
    }
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final lOther$autoDownloadNewChaptersLimit =
        other.autoDownloadNewChaptersLimit;
    if (l$autoDownloadNewChaptersLimit != lOther$autoDownloadNewChaptersLimit) {
      return false;
    }
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    final lOther$excludeEntryWithUnreadChapters =
        other.excludeEntryWithUnreadChapters;
    if (l$excludeEntryWithUnreadChapters !=
        lOther$excludeEntryWithUnreadChapters) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SettingsDto on Fragment$SettingsDto {
  CopyWith$Fragment$SettingsDto<Fragment$SettingsDto> get copyWith =>
      CopyWith$Fragment$SettingsDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$SettingsDto<TRes> {
  factory CopyWith$Fragment$SettingsDto(
    Fragment$SettingsDto instance,
    TRes Function(Fragment$SettingsDto) then,
  ) = _CopyWithImpl$Fragment$SettingsDto;

  factory CopyWith$Fragment$SettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SettingsDto;

  TRes call({
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    String? $__typename,
    String? ip,
    int? port,
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    bool? debugLogsEnabled,
    bool? systemTrayEnabled,
    List<String>? extensionRepos,
    int? maxSourcesInParallel,
    String? localSourcePath,
    double? globalUpdateInterval,
    bool? updateMangas,
    bool? excludeCompleted,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    bool? downloadAsCbz,
    String? downloadsPath,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    bool? excludeEntryWithUnreadChapters,
  });
}

class _CopyWithImpl$Fragment$SettingsDto<TRes>
    implements CopyWith$Fragment$SettingsDto<TRes> {
  _CopyWithImpl$Fragment$SettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$SettingsDto _instance;

  final TRes Function(Fragment$SettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? backupInterval = _undefined,
    Object? backupPath = _undefined,
    Object? backupTTL = _undefined,
    Object? backupTime = _undefined,
    Object? $__typename = _undefined,
    Object? ip = _undefined,
    Object? port = _undefined,
    Object? socksProxyEnabled = _undefined,
    Object? socksProxyHost = _undefined,
    Object? socksProxyPassword = _undefined,
    Object? socksProxyPort = _undefined,
    Object? socksProxyUsername = _undefined,
    Object? socksProxyVersion = _undefined,
    Object? flareSolverrEnabled = _undefined,
    Object? flareSolverrSessionName = _undefined,
    Object? flareSolverrSessionTtl = _undefined,
    Object? flareSolverrTimeout = _undefined,
    Object? flareSolverrUrl = _undefined,
    Object? debugLogsEnabled = _undefined,
    Object? systemTrayEnabled = _undefined,
    Object? extensionRepos = _undefined,
    Object? maxSourcesInParallel = _undefined,
    Object? localSourcePath = _undefined,
    Object? globalUpdateInterval = _undefined,
    Object? updateMangas = _undefined,
    Object? excludeCompleted = _undefined,
    Object? excludeNotStarted = _undefined,
    Object? excludeUnreadChapters = _undefined,
    Object? downloadAsCbz = _undefined,
    Object? downloadsPath = _undefined,
    Object? autoDownloadNewChapters = _undefined,
    Object? autoDownloadNewChaptersLimit = _undefined,
    Object? excludeEntryWithUnreadChapters = _undefined,
  }) =>
      _then(Fragment$SettingsDto(
        backupInterval: backupInterval == _undefined || backupInterval == null
            ? _instance.backupInterval
            : (backupInterval as int),
        backupPath: backupPath == _undefined || backupPath == null
            ? _instance.backupPath
            : (backupPath as String),
        backupTTL: backupTTL == _undefined || backupTTL == null
            ? _instance.backupTTL
            : (backupTTL as int),
        backupTime: backupTime == _undefined || backupTime == null
            ? _instance.backupTime
            : (backupTime as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        ip: ip == _undefined || ip == null ? _instance.ip : (ip as String),
        port:
            port == _undefined || port == null ? _instance.port : (port as int),
        socksProxyEnabled:
            socksProxyEnabled == _undefined || socksProxyEnabled == null
                ? _instance.socksProxyEnabled
                : (socksProxyEnabled as bool),
        socksProxyHost: socksProxyHost == _undefined || socksProxyHost == null
            ? _instance.socksProxyHost
            : (socksProxyHost as String),
        socksProxyPassword:
            socksProxyPassword == _undefined || socksProxyPassword == null
                ? _instance.socksProxyPassword
                : (socksProxyPassword as String),
        socksProxyPort: socksProxyPort == _undefined || socksProxyPort == null
            ? _instance.socksProxyPort
            : (socksProxyPort as String),
        socksProxyUsername:
            socksProxyUsername == _undefined || socksProxyUsername == null
                ? _instance.socksProxyUsername
                : (socksProxyUsername as String),
        socksProxyVersion:
            socksProxyVersion == _undefined || socksProxyVersion == null
                ? _instance.socksProxyVersion
                : (socksProxyVersion as int),
        flareSolverrEnabled:
            flareSolverrEnabled == _undefined || flareSolverrEnabled == null
                ? _instance.flareSolverrEnabled
                : (flareSolverrEnabled as bool),
        flareSolverrSessionName: flareSolverrSessionName == _undefined ||
                flareSolverrSessionName == null
            ? _instance.flareSolverrSessionName
            : (flareSolverrSessionName as String),
        flareSolverrSessionTtl: flareSolverrSessionTtl == _undefined ||
                flareSolverrSessionTtl == null
            ? _instance.flareSolverrSessionTtl
            : (flareSolverrSessionTtl as int),
        flareSolverrTimeout:
            flareSolverrTimeout == _undefined || flareSolverrTimeout == null
                ? _instance.flareSolverrTimeout
                : (flareSolverrTimeout as int),
        flareSolverrUrl:
            flareSolverrUrl == _undefined || flareSolverrUrl == null
                ? _instance.flareSolverrUrl
                : (flareSolverrUrl as String),
        debugLogsEnabled:
            debugLogsEnabled == _undefined || debugLogsEnabled == null
                ? _instance.debugLogsEnabled
                : (debugLogsEnabled as bool),
        systemTrayEnabled:
            systemTrayEnabled == _undefined || systemTrayEnabled == null
                ? _instance.systemTrayEnabled
                : (systemTrayEnabled as bool),
        extensionRepos: extensionRepos == _undefined || extensionRepos == null
            ? _instance.extensionRepos
            : (extensionRepos as List<String>),
        maxSourcesInParallel:
            maxSourcesInParallel == _undefined || maxSourcesInParallel == null
                ? _instance.maxSourcesInParallel
                : (maxSourcesInParallel as int),
        localSourcePath:
            localSourcePath == _undefined || localSourcePath == null
                ? _instance.localSourcePath
                : (localSourcePath as String),
        globalUpdateInterval:
            globalUpdateInterval == _undefined || globalUpdateInterval == null
                ? _instance.globalUpdateInterval
                : (globalUpdateInterval as double),
        updateMangas: updateMangas == _undefined || updateMangas == null
            ? _instance.updateMangas
            : (updateMangas as bool),
        excludeCompleted:
            excludeCompleted == _undefined || excludeCompleted == null
                ? _instance.excludeCompleted
                : (excludeCompleted as bool),
        excludeNotStarted:
            excludeNotStarted == _undefined || excludeNotStarted == null
                ? _instance.excludeNotStarted
                : (excludeNotStarted as bool),
        excludeUnreadChapters:
            excludeUnreadChapters == _undefined || excludeUnreadChapters == null
                ? _instance.excludeUnreadChapters
                : (excludeUnreadChapters as bool),
        downloadAsCbz: downloadAsCbz == _undefined || downloadAsCbz == null
            ? _instance.downloadAsCbz
            : (downloadAsCbz as bool),
        downloadsPath: downloadsPath == _undefined || downloadsPath == null
            ? _instance.downloadsPath
            : (downloadsPath as String),
        autoDownloadNewChapters: autoDownloadNewChapters == _undefined ||
                autoDownloadNewChapters == null
            ? _instance.autoDownloadNewChapters
            : (autoDownloadNewChapters as bool),
        autoDownloadNewChaptersLimit:
            autoDownloadNewChaptersLimit == _undefined ||
                    autoDownloadNewChaptersLimit == null
                ? _instance.autoDownloadNewChaptersLimit
                : (autoDownloadNewChaptersLimit as int),
        excludeEntryWithUnreadChapters:
            excludeEntryWithUnreadChapters == _undefined ||
                    excludeEntryWithUnreadChapters == null
                ? _instance.excludeEntryWithUnreadChapters
                : (excludeEntryWithUnreadChapters as bool),
      ));
}

class _CopyWithStubImpl$Fragment$SettingsDto<TRes>
    implements CopyWith$Fragment$SettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$SettingsDto(this._res);

  TRes _res;

  call({
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    String? $__typename,
    String? ip,
    int? port,
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    bool? debugLogsEnabled,
    bool? systemTrayEnabled,
    List<String>? extensionRepos,
    int? maxSourcesInParallel,
    String? localSourcePath,
    double? globalUpdateInterval,
    bool? updateMangas,
    bool? excludeCompleted,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    bool? downloadAsCbz,
    String? downloadsPath,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    bool? excludeEntryWithUnreadChapters,
  }) =>
      _res;
}

const fragmentDefinitionSettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'SettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FragmentSpreadNode(
      name: NameNode(value: 'AutomaticBackupSettingsDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'ServerBindingDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'SocksProxyDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'CloudFlareBypassDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'MiscSettingsDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'BrowserSettingsDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'LibrarySettingsDto'),
      directives: [],
    ),
    FragmentSpreadNode(
      name: NameNode(value: 'DownloadsSettingsDto'),
      directives: [],
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentSettingsDto = DocumentNode(definitions: [
  fragmentDefinitionSettingsDto,
  fragmentDefinitionAutomaticBackupSettingsDto,
  fragmentDefinitionServerBindingDto,
  fragmentDefinitionSocksProxyDto,
  fragmentDefinitionCloudFlareBypassDto,
  fragmentDefinitionMiscSettingsDto,
  fragmentDefinitionBrowserSettingsDto,
  fragmentDefinitionLibrarySettingsDto,
  fragmentDefinitionDownloadsSettingsDto,
]);

extension ClientExtension$Fragment$SettingsDto on graphql.GraphQLClient {
  void writeFragment$SettingsDto({
    required Fragment$SettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SettingsDto',
            document: documentNodeFragmentSettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SettingsDto? readFragment$SettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SettingsDto',
          document: documentNodeFragmentSettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SettingsDto.fromJson(result);
  }
}

class Fragment$AutomaticBackupSettingsDto {
  Fragment$AutomaticBackupSettingsDto({
    required this.backupInterval,
    required this.backupPath,
    required this.backupTTL,
    required this.backupTime,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$AutomaticBackupSettingsDto.fromJson(
      Map<String, dynamic> json) {
    final l$backupInterval = json['backupInterval'];
    final l$backupPath = json['backupPath'];
    final l$backupTTL = json['backupTTL'];
    final l$backupTime = json['backupTime'];
    final l$$__typename = json['__typename'];
    return Fragment$AutomaticBackupSettingsDto(
      backupInterval: (l$backupInterval as int),
      backupPath: (l$backupPath as String),
      backupTTL: (l$backupTTL as int),
      backupTime: (l$backupTime as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int backupInterval;

  final String backupPath;

  final int backupTTL;

  final String backupTime;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$backupInterval = backupInterval;
    _resultData['backupInterval'] = l$backupInterval;
    final l$backupPath = backupPath;
    _resultData['backupPath'] = l$backupPath;
    final l$backupTTL = backupTTL;
    _resultData['backupTTL'] = l$backupTTL;
    final l$backupTime = backupTime;
    _resultData['backupTime'] = l$backupTime;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$backupInterval = backupInterval;
    final l$backupPath = backupPath;
    final l$backupTTL = backupTTL;
    final l$backupTime = backupTime;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$backupInterval,
      l$backupPath,
      l$backupTTL,
      l$backupTime,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$AutomaticBackupSettingsDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$backupInterval = backupInterval;
    final lOther$backupInterval = other.backupInterval;
    if (l$backupInterval != lOther$backupInterval) {
      return false;
    }
    final l$backupPath = backupPath;
    final lOther$backupPath = other.backupPath;
    if (l$backupPath != lOther$backupPath) {
      return false;
    }
    final l$backupTTL = backupTTL;
    final lOther$backupTTL = other.backupTTL;
    if (l$backupTTL != lOther$backupTTL) {
      return false;
    }
    final l$backupTime = backupTime;
    final lOther$backupTime = other.backupTime;
    if (l$backupTime != lOther$backupTime) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$AutomaticBackupSettingsDto
    on Fragment$AutomaticBackupSettingsDto {
  CopyWith$Fragment$AutomaticBackupSettingsDto<
          Fragment$AutomaticBackupSettingsDto>
      get copyWith => CopyWith$Fragment$AutomaticBackupSettingsDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AutomaticBackupSettingsDto<TRes> {
  factory CopyWith$Fragment$AutomaticBackupSettingsDto(
    Fragment$AutomaticBackupSettingsDto instance,
    TRes Function(Fragment$AutomaticBackupSettingsDto) then,
  ) = _CopyWithImpl$Fragment$AutomaticBackupSettingsDto;

  factory CopyWith$Fragment$AutomaticBackupSettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AutomaticBackupSettingsDto;

  TRes call({
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AutomaticBackupSettingsDto<TRes>
    implements CopyWith$Fragment$AutomaticBackupSettingsDto<TRes> {
  _CopyWithImpl$Fragment$AutomaticBackupSettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$AutomaticBackupSettingsDto _instance;

  final TRes Function(Fragment$AutomaticBackupSettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? backupInterval = _undefined,
    Object? backupPath = _undefined,
    Object? backupTTL = _undefined,
    Object? backupTime = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AutomaticBackupSettingsDto(
        backupInterval: backupInterval == _undefined || backupInterval == null
            ? _instance.backupInterval
            : (backupInterval as int),
        backupPath: backupPath == _undefined || backupPath == null
            ? _instance.backupPath
            : (backupPath as String),
        backupTTL: backupTTL == _undefined || backupTTL == null
            ? _instance.backupTTL
            : (backupTTL as int),
        backupTime: backupTime == _undefined || backupTime == null
            ? _instance.backupTime
            : (backupTime as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$AutomaticBackupSettingsDto<TRes>
    implements CopyWith$Fragment$AutomaticBackupSettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$AutomaticBackupSettingsDto(this._res);

  TRes _res;

  call({
    int? backupInterval,
    String? backupPath,
    int? backupTTL,
    String? backupTime,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionAutomaticBackupSettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'AutomaticBackupSettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'backupInterval'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'backupPath'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'backupTTL'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'backupTime'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentAutomaticBackupSettingsDto =
    DocumentNode(definitions: [
  fragmentDefinitionAutomaticBackupSettingsDto,
]);

extension ClientExtension$Fragment$AutomaticBackupSettingsDto
    on graphql.GraphQLClient {
  void writeFragment$AutomaticBackupSettingsDto({
    required Fragment$AutomaticBackupSettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'AutomaticBackupSettingsDto',
            document: documentNodeFragmentAutomaticBackupSettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$AutomaticBackupSettingsDto? readFragment$AutomaticBackupSettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'AutomaticBackupSettingsDto',
          document: documentNodeFragmentAutomaticBackupSettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$AutomaticBackupSettingsDto.fromJson(result);
  }
}

class Fragment$BrowserSettingsDto {
  Fragment$BrowserSettingsDto({
    required this.extensionRepos,
    required this.maxSourcesInParallel,
    required this.localSourcePath,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$BrowserSettingsDto.fromJson(Map<String, dynamic> json) {
    final l$extensionRepos = json['extensionRepos'];
    final l$maxSourcesInParallel = json['maxSourcesInParallel'];
    final l$localSourcePath = json['localSourcePath'];
    final l$$__typename = json['__typename'];
    return Fragment$BrowserSettingsDto(
      extensionRepos: (l$extensionRepos as List<dynamic>)
          .map((e) => (e as String))
          .toList(),
      maxSourcesInParallel: (l$maxSourcesInParallel as int),
      localSourcePath: (l$localSourcePath as String),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String> extensionRepos;

  final int maxSourcesInParallel;

  final String localSourcePath;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$extensionRepos = extensionRepos;
    _resultData['extensionRepos'] = l$extensionRepos.map((e) => e).toList();
    final l$maxSourcesInParallel = maxSourcesInParallel;
    _resultData['maxSourcesInParallel'] = l$maxSourcesInParallel;
    final l$localSourcePath = localSourcePath;
    _resultData['localSourcePath'] = l$localSourcePath;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$extensionRepos = extensionRepos;
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final l$localSourcePath = localSourcePath;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$extensionRepos.map((v) => v)),
      l$maxSourcesInParallel,
      l$localSourcePath,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$BrowserSettingsDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$extensionRepos = extensionRepos;
    final lOther$extensionRepos = other.extensionRepos;
    if (l$extensionRepos.length != lOther$extensionRepos.length) {
      return false;
    }
    for (int i = 0; i < l$extensionRepos.length; i++) {
      final l$extensionRepos$entry = l$extensionRepos[i];
      final lOther$extensionRepos$entry = lOther$extensionRepos[i];
      if (l$extensionRepos$entry != lOther$extensionRepos$entry) {
        return false;
      }
    }
    final l$maxSourcesInParallel = maxSourcesInParallel;
    final lOther$maxSourcesInParallel = other.maxSourcesInParallel;
    if (l$maxSourcesInParallel != lOther$maxSourcesInParallel) {
      return false;
    }
    final l$localSourcePath = localSourcePath;
    final lOther$localSourcePath = other.localSourcePath;
    if (l$localSourcePath != lOther$localSourcePath) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$BrowserSettingsDto
    on Fragment$BrowserSettingsDto {
  CopyWith$Fragment$BrowserSettingsDto<Fragment$BrowserSettingsDto>
      get copyWith => CopyWith$Fragment$BrowserSettingsDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$BrowserSettingsDto<TRes> {
  factory CopyWith$Fragment$BrowserSettingsDto(
    Fragment$BrowserSettingsDto instance,
    TRes Function(Fragment$BrowserSettingsDto) then,
  ) = _CopyWithImpl$Fragment$BrowserSettingsDto;

  factory CopyWith$Fragment$BrowserSettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$BrowserSettingsDto;

  TRes call({
    List<String>? extensionRepos,
    int? maxSourcesInParallel,
    String? localSourcePath,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$BrowserSettingsDto<TRes>
    implements CopyWith$Fragment$BrowserSettingsDto<TRes> {
  _CopyWithImpl$Fragment$BrowserSettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$BrowserSettingsDto _instance;

  final TRes Function(Fragment$BrowserSettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extensionRepos = _undefined,
    Object? maxSourcesInParallel = _undefined,
    Object? localSourcePath = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$BrowserSettingsDto(
        extensionRepos: extensionRepos == _undefined || extensionRepos == null
            ? _instance.extensionRepos
            : (extensionRepos as List<String>),
        maxSourcesInParallel:
            maxSourcesInParallel == _undefined || maxSourcesInParallel == null
                ? _instance.maxSourcesInParallel
                : (maxSourcesInParallel as int),
        localSourcePath:
            localSourcePath == _undefined || localSourcePath == null
                ? _instance.localSourcePath
                : (localSourcePath as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$BrowserSettingsDto<TRes>
    implements CopyWith$Fragment$BrowserSettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$BrowserSettingsDto(this._res);

  TRes _res;

  call({
    List<String>? extensionRepos,
    int? maxSourcesInParallel,
    String? localSourcePath,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionBrowserSettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'BrowserSettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'extensionRepos'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'maxSourcesInParallel'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'localSourcePath'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentBrowserSettingsDto = DocumentNode(definitions: [
  fragmentDefinitionBrowserSettingsDto,
]);

extension ClientExtension$Fragment$BrowserSettingsDto on graphql.GraphQLClient {
  void writeFragment$BrowserSettingsDto({
    required Fragment$BrowserSettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'BrowserSettingsDto',
            document: documentNodeFragmentBrowserSettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$BrowserSettingsDto? readFragment$BrowserSettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'BrowserSettingsDto',
          document: documentNodeFragmentBrowserSettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$BrowserSettingsDto.fromJson(result);
  }
}

class Fragment$CloudFlareBypassDto {
  Fragment$CloudFlareBypassDto({
    required this.flareSolverrEnabled,
    required this.flareSolverrSessionName,
    required this.flareSolverrSessionTtl,
    required this.flareSolverrTimeout,
    required this.flareSolverrUrl,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$CloudFlareBypassDto.fromJson(Map<String, dynamic> json) {
    final l$flareSolverrEnabled = json['flareSolverrEnabled'];
    final l$flareSolverrSessionName = json['flareSolverrSessionName'];
    final l$flareSolverrSessionTtl = json['flareSolverrSessionTtl'];
    final l$flareSolverrTimeout = json['flareSolverrTimeout'];
    final l$flareSolverrUrl = json['flareSolverrUrl'];
    final l$$__typename = json['__typename'];
    return Fragment$CloudFlareBypassDto(
      flareSolverrEnabled: (l$flareSolverrEnabled as bool),
      flareSolverrSessionName: (l$flareSolverrSessionName as String),
      flareSolverrSessionTtl: (l$flareSolverrSessionTtl as int),
      flareSolverrTimeout: (l$flareSolverrTimeout as int),
      flareSolverrUrl: (l$flareSolverrUrl as String),
      $__typename: (l$$__typename as String),
    );
  }

  final bool flareSolverrEnabled;

  final String flareSolverrSessionName;

  final int flareSolverrSessionTtl;

  final int flareSolverrTimeout;

  final String flareSolverrUrl;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$flareSolverrEnabled = flareSolverrEnabled;
    _resultData['flareSolverrEnabled'] = l$flareSolverrEnabled;
    final l$flareSolverrSessionName = flareSolverrSessionName;
    _resultData['flareSolverrSessionName'] = l$flareSolverrSessionName;
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    _resultData['flareSolverrSessionTtl'] = l$flareSolverrSessionTtl;
    final l$flareSolverrTimeout = flareSolverrTimeout;
    _resultData['flareSolverrTimeout'] = l$flareSolverrTimeout;
    final l$flareSolverrUrl = flareSolverrUrl;
    _resultData['flareSolverrUrl'] = l$flareSolverrUrl;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final l$flareSolverrUrl = flareSolverrUrl;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$flareSolverrEnabled,
      l$flareSolverrSessionName,
      l$flareSolverrSessionTtl,
      l$flareSolverrTimeout,
      l$flareSolverrUrl,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CloudFlareBypassDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$flareSolverrEnabled = flareSolverrEnabled;
    final lOther$flareSolverrEnabled = other.flareSolverrEnabled;
    if (l$flareSolverrEnabled != lOther$flareSolverrEnabled) {
      return false;
    }
    final l$flareSolverrSessionName = flareSolverrSessionName;
    final lOther$flareSolverrSessionName = other.flareSolverrSessionName;
    if (l$flareSolverrSessionName != lOther$flareSolverrSessionName) {
      return false;
    }
    final l$flareSolverrSessionTtl = flareSolverrSessionTtl;
    final lOther$flareSolverrSessionTtl = other.flareSolverrSessionTtl;
    if (l$flareSolverrSessionTtl != lOther$flareSolverrSessionTtl) {
      return false;
    }
    final l$flareSolverrTimeout = flareSolverrTimeout;
    final lOther$flareSolverrTimeout = other.flareSolverrTimeout;
    if (l$flareSolverrTimeout != lOther$flareSolverrTimeout) {
      return false;
    }
    final l$flareSolverrUrl = flareSolverrUrl;
    final lOther$flareSolverrUrl = other.flareSolverrUrl;
    if (l$flareSolverrUrl != lOther$flareSolverrUrl) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$CloudFlareBypassDto
    on Fragment$CloudFlareBypassDto {
  CopyWith$Fragment$CloudFlareBypassDto<Fragment$CloudFlareBypassDto>
      get copyWith => CopyWith$Fragment$CloudFlareBypassDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$CloudFlareBypassDto<TRes> {
  factory CopyWith$Fragment$CloudFlareBypassDto(
    Fragment$CloudFlareBypassDto instance,
    TRes Function(Fragment$CloudFlareBypassDto) then,
  ) = _CopyWithImpl$Fragment$CloudFlareBypassDto;

  factory CopyWith$Fragment$CloudFlareBypassDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CloudFlareBypassDto;

  TRes call({
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$CloudFlareBypassDto<TRes>
    implements CopyWith$Fragment$CloudFlareBypassDto<TRes> {
  _CopyWithImpl$Fragment$CloudFlareBypassDto(
    this._instance,
    this._then,
  );

  final Fragment$CloudFlareBypassDto _instance;

  final TRes Function(Fragment$CloudFlareBypassDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? flareSolverrEnabled = _undefined,
    Object? flareSolverrSessionName = _undefined,
    Object? flareSolverrSessionTtl = _undefined,
    Object? flareSolverrTimeout = _undefined,
    Object? flareSolverrUrl = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CloudFlareBypassDto(
        flareSolverrEnabled:
            flareSolverrEnabled == _undefined || flareSolverrEnabled == null
                ? _instance.flareSolverrEnabled
                : (flareSolverrEnabled as bool),
        flareSolverrSessionName: flareSolverrSessionName == _undefined ||
                flareSolverrSessionName == null
            ? _instance.flareSolverrSessionName
            : (flareSolverrSessionName as String),
        flareSolverrSessionTtl: flareSolverrSessionTtl == _undefined ||
                flareSolverrSessionTtl == null
            ? _instance.flareSolverrSessionTtl
            : (flareSolverrSessionTtl as int),
        flareSolverrTimeout:
            flareSolverrTimeout == _undefined || flareSolverrTimeout == null
                ? _instance.flareSolverrTimeout
                : (flareSolverrTimeout as int),
        flareSolverrUrl:
            flareSolverrUrl == _undefined || flareSolverrUrl == null
                ? _instance.flareSolverrUrl
                : (flareSolverrUrl as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$CloudFlareBypassDto<TRes>
    implements CopyWith$Fragment$CloudFlareBypassDto<TRes> {
  _CopyWithStubImpl$Fragment$CloudFlareBypassDto(this._res);

  TRes _res;

  call({
    bool? flareSolverrEnabled,
    String? flareSolverrSessionName,
    int? flareSolverrSessionTtl,
    int? flareSolverrTimeout,
    String? flareSolverrUrl,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionCloudFlareBypassDto = FragmentDefinitionNode(
  name: NameNode(value: 'CloudFlareBypassDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'flareSolverrEnabled'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'flareSolverrSessionName'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'flareSolverrSessionTtl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'flareSolverrTimeout'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'flareSolverrUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentCloudFlareBypassDto = DocumentNode(definitions: [
  fragmentDefinitionCloudFlareBypassDto,
]);

extension ClientExtension$Fragment$CloudFlareBypassDto
    on graphql.GraphQLClient {
  void writeFragment$CloudFlareBypassDto({
    required Fragment$CloudFlareBypassDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'CloudFlareBypassDto',
            document: documentNodeFragmentCloudFlareBypassDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$CloudFlareBypassDto? readFragment$CloudFlareBypassDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'CloudFlareBypassDto',
          document: documentNodeFragmentCloudFlareBypassDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$CloudFlareBypassDto.fromJson(result);
  }
}

class Fragment$DownloadsSettingsDto {
  Fragment$DownloadsSettingsDto({
    required this.downloadAsCbz,
    required this.downloadsPath,
    required this.autoDownloadNewChapters,
    required this.autoDownloadNewChaptersLimit,
    required this.excludeEntryWithUnreadChapters,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$DownloadsSettingsDto.fromJson(Map<String, dynamic> json) {
    final l$downloadAsCbz = json['downloadAsCbz'];
    final l$downloadsPath = json['downloadsPath'];
    final l$autoDownloadNewChapters = json['autoDownloadNewChapters'];
    final l$autoDownloadNewChaptersLimit = json['autoDownloadNewChaptersLimit'];
    final l$excludeEntryWithUnreadChapters =
        json['excludeEntryWithUnreadChapters'];
    final l$$__typename = json['__typename'];
    return Fragment$DownloadsSettingsDto(
      downloadAsCbz: (l$downloadAsCbz as bool),
      downloadsPath: (l$downloadsPath as String),
      autoDownloadNewChapters: (l$autoDownloadNewChapters as bool),
      autoDownloadNewChaptersLimit: (l$autoDownloadNewChaptersLimit as int),
      excludeEntryWithUnreadChapters:
          (l$excludeEntryWithUnreadChapters as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool downloadAsCbz;

  final String downloadsPath;

  final bool autoDownloadNewChapters;

  final int autoDownloadNewChaptersLimit;

  final bool excludeEntryWithUnreadChapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$downloadAsCbz = downloadAsCbz;
    _resultData['downloadAsCbz'] = l$downloadAsCbz;
    final l$downloadsPath = downloadsPath;
    _resultData['downloadsPath'] = l$downloadsPath;
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    _resultData['autoDownloadNewChapters'] = l$autoDownloadNewChapters;
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    _resultData['autoDownloadNewChaptersLimit'] =
        l$autoDownloadNewChaptersLimit;
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    _resultData['excludeEntryWithUnreadChapters'] =
        l$excludeEntryWithUnreadChapters;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$downloadAsCbz = downloadAsCbz;
    final l$downloadsPath = downloadsPath;
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$downloadAsCbz,
      l$downloadsPath,
      l$autoDownloadNewChapters,
      l$autoDownloadNewChaptersLimit,
      l$excludeEntryWithUnreadChapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$DownloadsSettingsDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$downloadAsCbz = downloadAsCbz;
    final lOther$downloadAsCbz = other.downloadAsCbz;
    if (l$downloadAsCbz != lOther$downloadAsCbz) {
      return false;
    }
    final l$downloadsPath = downloadsPath;
    final lOther$downloadsPath = other.downloadsPath;
    if (l$downloadsPath != lOther$downloadsPath) {
      return false;
    }
    final l$autoDownloadNewChapters = autoDownloadNewChapters;
    final lOther$autoDownloadNewChapters = other.autoDownloadNewChapters;
    if (l$autoDownloadNewChapters != lOther$autoDownloadNewChapters) {
      return false;
    }
    final l$autoDownloadNewChaptersLimit = autoDownloadNewChaptersLimit;
    final lOther$autoDownloadNewChaptersLimit =
        other.autoDownloadNewChaptersLimit;
    if (l$autoDownloadNewChaptersLimit != lOther$autoDownloadNewChaptersLimit) {
      return false;
    }
    final l$excludeEntryWithUnreadChapters = excludeEntryWithUnreadChapters;
    final lOther$excludeEntryWithUnreadChapters =
        other.excludeEntryWithUnreadChapters;
    if (l$excludeEntryWithUnreadChapters !=
        lOther$excludeEntryWithUnreadChapters) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$DownloadsSettingsDto
    on Fragment$DownloadsSettingsDto {
  CopyWith$Fragment$DownloadsSettingsDto<Fragment$DownloadsSettingsDto>
      get copyWith => CopyWith$Fragment$DownloadsSettingsDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$DownloadsSettingsDto<TRes> {
  factory CopyWith$Fragment$DownloadsSettingsDto(
    Fragment$DownloadsSettingsDto instance,
    TRes Function(Fragment$DownloadsSettingsDto) then,
  ) = _CopyWithImpl$Fragment$DownloadsSettingsDto;

  factory CopyWith$Fragment$DownloadsSettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$DownloadsSettingsDto;

  TRes call({
    bool? downloadAsCbz,
    String? downloadsPath,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    bool? excludeEntryWithUnreadChapters,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$DownloadsSettingsDto<TRes>
    implements CopyWith$Fragment$DownloadsSettingsDto<TRes> {
  _CopyWithImpl$Fragment$DownloadsSettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$DownloadsSettingsDto _instance;

  final TRes Function(Fragment$DownloadsSettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? downloadAsCbz = _undefined,
    Object? downloadsPath = _undefined,
    Object? autoDownloadNewChapters = _undefined,
    Object? autoDownloadNewChaptersLimit = _undefined,
    Object? excludeEntryWithUnreadChapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$DownloadsSettingsDto(
        downloadAsCbz: downloadAsCbz == _undefined || downloadAsCbz == null
            ? _instance.downloadAsCbz
            : (downloadAsCbz as bool),
        downloadsPath: downloadsPath == _undefined || downloadsPath == null
            ? _instance.downloadsPath
            : (downloadsPath as String),
        autoDownloadNewChapters: autoDownloadNewChapters == _undefined ||
                autoDownloadNewChapters == null
            ? _instance.autoDownloadNewChapters
            : (autoDownloadNewChapters as bool),
        autoDownloadNewChaptersLimit:
            autoDownloadNewChaptersLimit == _undefined ||
                    autoDownloadNewChaptersLimit == null
                ? _instance.autoDownloadNewChaptersLimit
                : (autoDownloadNewChaptersLimit as int),
        excludeEntryWithUnreadChapters:
            excludeEntryWithUnreadChapters == _undefined ||
                    excludeEntryWithUnreadChapters == null
                ? _instance.excludeEntryWithUnreadChapters
                : (excludeEntryWithUnreadChapters as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$DownloadsSettingsDto<TRes>
    implements CopyWith$Fragment$DownloadsSettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$DownloadsSettingsDto(this._res);

  TRes _res;

  call({
    bool? downloadAsCbz,
    String? downloadsPath,
    bool? autoDownloadNewChapters,
    int? autoDownloadNewChaptersLimit,
    bool? excludeEntryWithUnreadChapters,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionDownloadsSettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'DownloadsSettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'downloadAsCbz'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'downloadsPath'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'autoDownloadNewChapters'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'autoDownloadNewChaptersLimit'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'excludeEntryWithUnreadChapters'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentDownloadsSettingsDto = DocumentNode(definitions: [
  fragmentDefinitionDownloadsSettingsDto,
]);

extension ClientExtension$Fragment$DownloadsSettingsDto
    on graphql.GraphQLClient {
  void writeFragment$DownloadsSettingsDto({
    required Fragment$DownloadsSettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'DownloadsSettingsDto',
            document: documentNodeFragmentDownloadsSettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$DownloadsSettingsDto? readFragment$DownloadsSettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'DownloadsSettingsDto',
          document: documentNodeFragmentDownloadsSettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$DownloadsSettingsDto.fromJson(result);
  }
}

class Fragment$LibrarySettingsDto {
  Fragment$LibrarySettingsDto({
    required this.globalUpdateInterval,
    required this.updateMangas,
    required this.excludeCompleted,
    required this.excludeNotStarted,
    required this.excludeUnreadChapters,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$LibrarySettingsDto.fromJson(Map<String, dynamic> json) {
    final l$globalUpdateInterval = json['globalUpdateInterval'];
    final l$updateMangas = json['updateMangas'];
    final l$excludeCompleted = json['excludeCompleted'];
    final l$excludeNotStarted = json['excludeNotStarted'];
    final l$excludeUnreadChapters = json['excludeUnreadChapters'];
    final l$$__typename = json['__typename'];
    return Fragment$LibrarySettingsDto(
      globalUpdateInterval: (l$globalUpdateInterval as num).toDouble(),
      updateMangas: (l$updateMangas as bool),
      excludeCompleted: (l$excludeCompleted as bool),
      excludeNotStarted: (l$excludeNotStarted as bool),
      excludeUnreadChapters: (l$excludeUnreadChapters as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final double globalUpdateInterval;

  final bool updateMangas;

  final bool excludeCompleted;

  final bool excludeNotStarted;

  final bool excludeUnreadChapters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$globalUpdateInterval = globalUpdateInterval;
    _resultData['globalUpdateInterval'] = l$globalUpdateInterval;
    final l$updateMangas = updateMangas;
    _resultData['updateMangas'] = l$updateMangas;
    final l$excludeCompleted = excludeCompleted;
    _resultData['excludeCompleted'] = l$excludeCompleted;
    final l$excludeNotStarted = excludeNotStarted;
    _resultData['excludeNotStarted'] = l$excludeNotStarted;
    final l$excludeUnreadChapters = excludeUnreadChapters;
    _resultData['excludeUnreadChapters'] = l$excludeUnreadChapters;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$globalUpdateInterval = globalUpdateInterval;
    final l$updateMangas = updateMangas;
    final l$excludeCompleted = excludeCompleted;
    final l$excludeNotStarted = excludeNotStarted;
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$globalUpdateInterval,
      l$updateMangas,
      l$excludeCompleted,
      l$excludeNotStarted,
      l$excludeUnreadChapters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$LibrarySettingsDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$globalUpdateInterval = globalUpdateInterval;
    final lOther$globalUpdateInterval = other.globalUpdateInterval;
    if (l$globalUpdateInterval != lOther$globalUpdateInterval) {
      return false;
    }
    final l$updateMangas = updateMangas;
    final lOther$updateMangas = other.updateMangas;
    if (l$updateMangas != lOther$updateMangas) {
      return false;
    }
    final l$excludeCompleted = excludeCompleted;
    final lOther$excludeCompleted = other.excludeCompleted;
    if (l$excludeCompleted != lOther$excludeCompleted) {
      return false;
    }
    final l$excludeNotStarted = excludeNotStarted;
    final lOther$excludeNotStarted = other.excludeNotStarted;
    if (l$excludeNotStarted != lOther$excludeNotStarted) {
      return false;
    }
    final l$excludeUnreadChapters = excludeUnreadChapters;
    final lOther$excludeUnreadChapters = other.excludeUnreadChapters;
    if (l$excludeUnreadChapters != lOther$excludeUnreadChapters) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$LibrarySettingsDto
    on Fragment$LibrarySettingsDto {
  CopyWith$Fragment$LibrarySettingsDto<Fragment$LibrarySettingsDto>
      get copyWith => CopyWith$Fragment$LibrarySettingsDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$LibrarySettingsDto<TRes> {
  factory CopyWith$Fragment$LibrarySettingsDto(
    Fragment$LibrarySettingsDto instance,
    TRes Function(Fragment$LibrarySettingsDto) then,
  ) = _CopyWithImpl$Fragment$LibrarySettingsDto;

  factory CopyWith$Fragment$LibrarySettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$LibrarySettingsDto;

  TRes call({
    double? globalUpdateInterval,
    bool? updateMangas,
    bool? excludeCompleted,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$LibrarySettingsDto<TRes>
    implements CopyWith$Fragment$LibrarySettingsDto<TRes> {
  _CopyWithImpl$Fragment$LibrarySettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$LibrarySettingsDto _instance;

  final TRes Function(Fragment$LibrarySettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? globalUpdateInterval = _undefined,
    Object? updateMangas = _undefined,
    Object? excludeCompleted = _undefined,
    Object? excludeNotStarted = _undefined,
    Object? excludeUnreadChapters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$LibrarySettingsDto(
        globalUpdateInterval:
            globalUpdateInterval == _undefined || globalUpdateInterval == null
                ? _instance.globalUpdateInterval
                : (globalUpdateInterval as double),
        updateMangas: updateMangas == _undefined || updateMangas == null
            ? _instance.updateMangas
            : (updateMangas as bool),
        excludeCompleted:
            excludeCompleted == _undefined || excludeCompleted == null
                ? _instance.excludeCompleted
                : (excludeCompleted as bool),
        excludeNotStarted:
            excludeNotStarted == _undefined || excludeNotStarted == null
                ? _instance.excludeNotStarted
                : (excludeNotStarted as bool),
        excludeUnreadChapters:
            excludeUnreadChapters == _undefined || excludeUnreadChapters == null
                ? _instance.excludeUnreadChapters
                : (excludeUnreadChapters as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$LibrarySettingsDto<TRes>
    implements CopyWith$Fragment$LibrarySettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$LibrarySettingsDto(this._res);

  TRes _res;

  call({
    double? globalUpdateInterval,
    bool? updateMangas,
    bool? excludeCompleted,
    bool? excludeNotStarted,
    bool? excludeUnreadChapters,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionLibrarySettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'LibrarySettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'globalUpdateInterval'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'updateMangas'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'excludeCompleted'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'excludeNotStarted'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'excludeUnreadChapters'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentLibrarySettingsDto = DocumentNode(definitions: [
  fragmentDefinitionLibrarySettingsDto,
]);

extension ClientExtension$Fragment$LibrarySettingsDto on graphql.GraphQLClient {
  void writeFragment$LibrarySettingsDto({
    required Fragment$LibrarySettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'LibrarySettingsDto',
            document: documentNodeFragmentLibrarySettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$LibrarySettingsDto? readFragment$LibrarySettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'LibrarySettingsDto',
          document: documentNodeFragmentLibrarySettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$LibrarySettingsDto.fromJson(result);
  }
}

class Fragment$MiscSettingsDto {
  Fragment$MiscSettingsDto({
    required this.debugLogsEnabled,
    required this.systemTrayEnabled,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$MiscSettingsDto.fromJson(Map<String, dynamic> json) {
    final l$debugLogsEnabled = json['debugLogsEnabled'];
    final l$systemTrayEnabled = json['systemTrayEnabled'];
    final l$$__typename = json['__typename'];
    return Fragment$MiscSettingsDto(
      debugLogsEnabled: (l$debugLogsEnabled as bool),
      systemTrayEnabled: (l$systemTrayEnabled as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool debugLogsEnabled;

  final bool systemTrayEnabled;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$debugLogsEnabled = debugLogsEnabled;
    _resultData['debugLogsEnabled'] = l$debugLogsEnabled;
    final l$systemTrayEnabled = systemTrayEnabled;
    _resultData['systemTrayEnabled'] = l$systemTrayEnabled;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$debugLogsEnabled = debugLogsEnabled;
    final l$systemTrayEnabled = systemTrayEnabled;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$debugLogsEnabled,
      l$systemTrayEnabled,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$MiscSettingsDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$debugLogsEnabled = debugLogsEnabled;
    final lOther$debugLogsEnabled = other.debugLogsEnabled;
    if (l$debugLogsEnabled != lOther$debugLogsEnabled) {
      return false;
    }
    final l$systemTrayEnabled = systemTrayEnabled;
    final lOther$systemTrayEnabled = other.systemTrayEnabled;
    if (l$systemTrayEnabled != lOther$systemTrayEnabled) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$MiscSettingsDto
    on Fragment$MiscSettingsDto {
  CopyWith$Fragment$MiscSettingsDto<Fragment$MiscSettingsDto> get copyWith =>
      CopyWith$Fragment$MiscSettingsDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MiscSettingsDto<TRes> {
  factory CopyWith$Fragment$MiscSettingsDto(
    Fragment$MiscSettingsDto instance,
    TRes Function(Fragment$MiscSettingsDto) then,
  ) = _CopyWithImpl$Fragment$MiscSettingsDto;

  factory CopyWith$Fragment$MiscSettingsDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MiscSettingsDto;

  TRes call({
    bool? debugLogsEnabled,
    bool? systemTrayEnabled,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$MiscSettingsDto<TRes>
    implements CopyWith$Fragment$MiscSettingsDto<TRes> {
  _CopyWithImpl$Fragment$MiscSettingsDto(
    this._instance,
    this._then,
  );

  final Fragment$MiscSettingsDto _instance;

  final TRes Function(Fragment$MiscSettingsDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? debugLogsEnabled = _undefined,
    Object? systemTrayEnabled = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MiscSettingsDto(
        debugLogsEnabled:
            debugLogsEnabled == _undefined || debugLogsEnabled == null
                ? _instance.debugLogsEnabled
                : (debugLogsEnabled as bool),
        systemTrayEnabled:
            systemTrayEnabled == _undefined || systemTrayEnabled == null
                ? _instance.systemTrayEnabled
                : (systemTrayEnabled as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$MiscSettingsDto<TRes>
    implements CopyWith$Fragment$MiscSettingsDto<TRes> {
  _CopyWithStubImpl$Fragment$MiscSettingsDto(this._res);

  TRes _res;

  call({
    bool? debugLogsEnabled,
    bool? systemTrayEnabled,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionMiscSettingsDto = FragmentDefinitionNode(
  name: NameNode(value: 'MiscSettingsDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'debugLogsEnabled'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'systemTrayEnabled'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentMiscSettingsDto = DocumentNode(definitions: [
  fragmentDefinitionMiscSettingsDto,
]);

extension ClientExtension$Fragment$MiscSettingsDto on graphql.GraphQLClient {
  void writeFragment$MiscSettingsDto({
    required Fragment$MiscSettingsDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'MiscSettingsDto',
            document: documentNodeFragmentMiscSettingsDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$MiscSettingsDto? readFragment$MiscSettingsDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'MiscSettingsDto',
          document: documentNodeFragmentMiscSettingsDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$MiscSettingsDto.fromJson(result);
  }
}

class Fragment$RestoreStatusDto {
  Fragment$RestoreStatusDto({
    required this.mangaProgress,
    required this.state,
    required this.totalManga,
    this.$__typename = 'BackupRestoreStatus',
  });

  factory Fragment$RestoreStatusDto.fromJson(Map<String, dynamic> json) {
    final l$mangaProgress = json['mangaProgress'];
    final l$state = json['state'];
    final l$totalManga = json['totalManga'];
    final l$$__typename = json['__typename'];
    return Fragment$RestoreStatusDto(
      mangaProgress: (l$mangaProgress as int),
      state: fromJson$Enum$BackupRestoreState((l$state as String)),
      totalManga: (l$totalManga as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int mangaProgress;

  final Enum$BackupRestoreState state;

  final int totalManga;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$mangaProgress = mangaProgress;
    _resultData['mangaProgress'] = l$mangaProgress;
    final l$state = state;
    _resultData['state'] = toJson$Enum$BackupRestoreState(l$state);
    final l$totalManga = totalManga;
    _resultData['totalManga'] = l$totalManga;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$mangaProgress = mangaProgress;
    final l$state = state;
    final l$totalManga = totalManga;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$mangaProgress,
      l$state,
      l$totalManga,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$RestoreStatusDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mangaProgress = mangaProgress;
    final lOther$mangaProgress = other.mangaProgress;
    if (l$mangaProgress != lOther$mangaProgress) {
      return false;
    }
    final l$state = state;
    final lOther$state = other.state;
    if (l$state != lOther$state) {
      return false;
    }
    final l$totalManga = totalManga;
    final lOther$totalManga = other.totalManga;
    if (l$totalManga != lOther$totalManga) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$RestoreStatusDto
    on Fragment$RestoreStatusDto {
  CopyWith$Fragment$RestoreStatusDto<Fragment$RestoreStatusDto> get copyWith =>
      CopyWith$Fragment$RestoreStatusDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$RestoreStatusDto<TRes> {
  factory CopyWith$Fragment$RestoreStatusDto(
    Fragment$RestoreStatusDto instance,
    TRes Function(Fragment$RestoreStatusDto) then,
  ) = _CopyWithImpl$Fragment$RestoreStatusDto;

  factory CopyWith$Fragment$RestoreStatusDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$RestoreStatusDto;

  TRes call({
    int? mangaProgress,
    Enum$BackupRestoreState? state,
    int? totalManga,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$RestoreStatusDto<TRes>
    implements CopyWith$Fragment$RestoreStatusDto<TRes> {
  _CopyWithImpl$Fragment$RestoreStatusDto(
    this._instance,
    this._then,
  );

  final Fragment$RestoreStatusDto _instance;

  final TRes Function(Fragment$RestoreStatusDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mangaProgress = _undefined,
    Object? state = _undefined,
    Object? totalManga = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$RestoreStatusDto(
        mangaProgress: mangaProgress == _undefined || mangaProgress == null
            ? _instance.mangaProgress
            : (mangaProgress as int),
        state: state == _undefined || state == null
            ? _instance.state
            : (state as Enum$BackupRestoreState),
        totalManga: totalManga == _undefined || totalManga == null
            ? _instance.totalManga
            : (totalManga as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$RestoreStatusDto<TRes>
    implements CopyWith$Fragment$RestoreStatusDto<TRes> {
  _CopyWithStubImpl$Fragment$RestoreStatusDto(this._res);

  TRes _res;

  call({
    int? mangaProgress,
    Enum$BackupRestoreState? state,
    int? totalManga,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionRestoreStatusDto = FragmentDefinitionNode(
  name: NameNode(value: 'RestoreStatusDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'BackupRestoreStatus'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'mangaProgress'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'state'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'totalManga'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentRestoreStatusDto = DocumentNode(definitions: [
  fragmentDefinitionRestoreStatusDto,
]);

extension ClientExtension$Fragment$RestoreStatusDto on graphql.GraphQLClient {
  void writeFragment$RestoreStatusDto({
    required Fragment$RestoreStatusDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'RestoreStatusDto',
            document: documentNodeFragmentRestoreStatusDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$RestoreStatusDto? readFragment$RestoreStatusDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'RestoreStatusDto',
          document: documentNodeFragmentRestoreStatusDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$RestoreStatusDto.fromJson(result);
  }
}

class Fragment$ServerBindingDto {
  Fragment$ServerBindingDto({
    required this.ip,
    required this.port,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$ServerBindingDto.fromJson(Map<String, dynamic> json) {
    final l$ip = json['ip'];
    final l$port = json['port'];
    final l$$__typename = json['__typename'];
    return Fragment$ServerBindingDto(
      ip: (l$ip as String),
      port: (l$port as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String ip;

  final int port;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$ip = ip;
    _resultData['ip'] = l$ip;
    final l$port = port;
    _resultData['port'] = l$port;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$ip = ip;
    final l$port = port;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$ip,
      l$port,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ServerBindingDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ip = ip;
    final lOther$ip = other.ip;
    if (l$ip != lOther$ip) {
      return false;
    }
    final l$port = port;
    final lOther$port = other.port;
    if (l$port != lOther$port) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$ServerBindingDto
    on Fragment$ServerBindingDto {
  CopyWith$Fragment$ServerBindingDto<Fragment$ServerBindingDto> get copyWith =>
      CopyWith$Fragment$ServerBindingDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ServerBindingDto<TRes> {
  factory CopyWith$Fragment$ServerBindingDto(
    Fragment$ServerBindingDto instance,
    TRes Function(Fragment$ServerBindingDto) then,
  ) = _CopyWithImpl$Fragment$ServerBindingDto;

  factory CopyWith$Fragment$ServerBindingDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ServerBindingDto;

  TRes call({
    String? ip,
    int? port,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ServerBindingDto<TRes>
    implements CopyWith$Fragment$ServerBindingDto<TRes> {
  _CopyWithImpl$Fragment$ServerBindingDto(
    this._instance,
    this._then,
  );

  final Fragment$ServerBindingDto _instance;

  final TRes Function(Fragment$ServerBindingDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? ip = _undefined,
    Object? port = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ServerBindingDto(
        ip: ip == _undefined || ip == null ? _instance.ip : (ip as String),
        port:
            port == _undefined || port == null ? _instance.port : (port as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ServerBindingDto<TRes>
    implements CopyWith$Fragment$ServerBindingDto<TRes> {
  _CopyWithStubImpl$Fragment$ServerBindingDto(this._res);

  TRes _res;

  call({
    String? ip,
    int? port,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionServerBindingDto = FragmentDefinitionNode(
  name: NameNode(value: 'ServerBindingDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'ip'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'port'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentServerBindingDto = DocumentNode(definitions: [
  fragmentDefinitionServerBindingDto,
]);

extension ClientExtension$Fragment$ServerBindingDto on graphql.GraphQLClient {
  void writeFragment$ServerBindingDto({
    required Fragment$ServerBindingDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ServerBindingDto',
            document: documentNodeFragmentServerBindingDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ServerBindingDto? readFragment$ServerBindingDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ServerBindingDto',
          document: documentNodeFragmentServerBindingDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ServerBindingDto.fromJson(result);
  }
}

class Fragment$SocksProxyDto {
  Fragment$SocksProxyDto({
    required this.socksProxyEnabled,
    required this.socksProxyHost,
    required this.socksProxyPassword,
    required this.socksProxyPort,
    required this.socksProxyUsername,
    required this.socksProxyVersion,
    this.$__typename = 'SettingsType',
  });

  factory Fragment$SocksProxyDto.fromJson(Map<String, dynamic> json) {
    final l$socksProxyEnabled = json['socksProxyEnabled'];
    final l$socksProxyHost = json['socksProxyHost'];
    final l$socksProxyPassword = json['socksProxyPassword'];
    final l$socksProxyPort = json['socksProxyPort'];
    final l$socksProxyUsername = json['socksProxyUsername'];
    final l$socksProxyVersion = json['socksProxyVersion'];
    final l$$__typename = json['__typename'];
    return Fragment$SocksProxyDto(
      socksProxyEnabled: (l$socksProxyEnabled as bool),
      socksProxyHost: (l$socksProxyHost as String),
      socksProxyPassword: (l$socksProxyPassword as String),
      socksProxyPort: (l$socksProxyPort as String),
      socksProxyUsername: (l$socksProxyUsername as String),
      socksProxyVersion: (l$socksProxyVersion as int),
      $__typename: (l$$__typename as String),
    );
  }

  final bool socksProxyEnabled;

  final String socksProxyHost;

  final String socksProxyPassword;

  final String socksProxyPort;

  final String socksProxyUsername;

  final int socksProxyVersion;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$socksProxyEnabled = socksProxyEnabled;
    _resultData['socksProxyEnabled'] = l$socksProxyEnabled;
    final l$socksProxyHost = socksProxyHost;
    _resultData['socksProxyHost'] = l$socksProxyHost;
    final l$socksProxyPassword = socksProxyPassword;
    _resultData['socksProxyPassword'] = l$socksProxyPassword;
    final l$socksProxyPort = socksProxyPort;
    _resultData['socksProxyPort'] = l$socksProxyPort;
    final l$socksProxyUsername = socksProxyUsername;
    _resultData['socksProxyUsername'] = l$socksProxyUsername;
    final l$socksProxyVersion = socksProxyVersion;
    _resultData['socksProxyVersion'] = l$socksProxyVersion;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$socksProxyEnabled = socksProxyEnabled;
    final l$socksProxyHost = socksProxyHost;
    final l$socksProxyPassword = socksProxyPassword;
    final l$socksProxyPort = socksProxyPort;
    final l$socksProxyUsername = socksProxyUsername;
    final l$socksProxyVersion = socksProxyVersion;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$socksProxyEnabled,
      l$socksProxyHost,
      l$socksProxyPassword,
      l$socksProxyPort,
      l$socksProxyUsername,
      l$socksProxyVersion,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SocksProxyDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$socksProxyEnabled = socksProxyEnabled;
    final lOther$socksProxyEnabled = other.socksProxyEnabled;
    if (l$socksProxyEnabled != lOther$socksProxyEnabled) {
      return false;
    }
    final l$socksProxyHost = socksProxyHost;
    final lOther$socksProxyHost = other.socksProxyHost;
    if (l$socksProxyHost != lOther$socksProxyHost) {
      return false;
    }
    final l$socksProxyPassword = socksProxyPassword;
    final lOther$socksProxyPassword = other.socksProxyPassword;
    if (l$socksProxyPassword != lOther$socksProxyPassword) {
      return false;
    }
    final l$socksProxyPort = socksProxyPort;
    final lOther$socksProxyPort = other.socksProxyPort;
    if (l$socksProxyPort != lOther$socksProxyPort) {
      return false;
    }
    final l$socksProxyUsername = socksProxyUsername;
    final lOther$socksProxyUsername = other.socksProxyUsername;
    if (l$socksProxyUsername != lOther$socksProxyUsername) {
      return false;
    }
    final l$socksProxyVersion = socksProxyVersion;
    final lOther$socksProxyVersion = other.socksProxyVersion;
    if (l$socksProxyVersion != lOther$socksProxyVersion) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SocksProxyDto on Fragment$SocksProxyDto {
  CopyWith$Fragment$SocksProxyDto<Fragment$SocksProxyDto> get copyWith =>
      CopyWith$Fragment$SocksProxyDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$SocksProxyDto<TRes> {
  factory CopyWith$Fragment$SocksProxyDto(
    Fragment$SocksProxyDto instance,
    TRes Function(Fragment$SocksProxyDto) then,
  ) = _CopyWithImpl$Fragment$SocksProxyDto;

  factory CopyWith$Fragment$SocksProxyDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SocksProxyDto;

  TRes call({
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SocksProxyDto<TRes>
    implements CopyWith$Fragment$SocksProxyDto<TRes> {
  _CopyWithImpl$Fragment$SocksProxyDto(
    this._instance,
    this._then,
  );

  final Fragment$SocksProxyDto _instance;

  final TRes Function(Fragment$SocksProxyDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? socksProxyEnabled = _undefined,
    Object? socksProxyHost = _undefined,
    Object? socksProxyPassword = _undefined,
    Object? socksProxyPort = _undefined,
    Object? socksProxyUsername = _undefined,
    Object? socksProxyVersion = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SocksProxyDto(
        socksProxyEnabled:
            socksProxyEnabled == _undefined || socksProxyEnabled == null
                ? _instance.socksProxyEnabled
                : (socksProxyEnabled as bool),
        socksProxyHost: socksProxyHost == _undefined || socksProxyHost == null
            ? _instance.socksProxyHost
            : (socksProxyHost as String),
        socksProxyPassword:
            socksProxyPassword == _undefined || socksProxyPassword == null
                ? _instance.socksProxyPassword
                : (socksProxyPassword as String),
        socksProxyPort: socksProxyPort == _undefined || socksProxyPort == null
            ? _instance.socksProxyPort
            : (socksProxyPort as String),
        socksProxyUsername:
            socksProxyUsername == _undefined || socksProxyUsername == null
                ? _instance.socksProxyUsername
                : (socksProxyUsername as String),
        socksProxyVersion:
            socksProxyVersion == _undefined || socksProxyVersion == null
                ? _instance.socksProxyVersion
                : (socksProxyVersion as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SocksProxyDto<TRes>
    implements CopyWith$Fragment$SocksProxyDto<TRes> {
  _CopyWithStubImpl$Fragment$SocksProxyDto(this._res);

  TRes _res;

  call({
    bool? socksProxyEnabled,
    String? socksProxyHost,
    String? socksProxyPassword,
    String? socksProxyPort,
    String? socksProxyUsername,
    int? socksProxyVersion,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionSocksProxyDto = FragmentDefinitionNode(
  name: NameNode(value: 'SocksProxyDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SettingsType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'socksProxyEnabled'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'socksProxyHost'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'socksProxyPassword'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'socksProxyPort'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'socksProxyUsername'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'socksProxyVersion'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentSocksProxyDto = DocumentNode(definitions: [
  fragmentDefinitionSocksProxyDto,
]);

extension ClientExtension$Fragment$SocksProxyDto on graphql.GraphQLClient {
  void writeFragment$SocksProxyDto({
    required Fragment$SocksProxyDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SocksProxyDto',
            document: documentNodeFragmentSocksProxyDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SocksProxyDto? readFragment$SocksProxyDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SocksProxyDto',
          document: documentNodeFragmentSocksProxyDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SocksProxyDto.fromJson(result);
  }
}
