// lib/src/core/sync/server_type.dart
//
// Server type definitions and multi-server configuration.
// Part of S4.1: Multi-server support — simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Supported server types.
enum ServerType {
  /// Suwayomi / Tachidesk (GraphQL-based, primary target)
  suwayomi,

  /// Kavita (REST API + GraphQL, read-only manga)
  kavita,

  /// Mihon / Tachiyomi extensions (local scraping, no server sync)
  mihon,

  /// Generic OPDS server
  opds,

  /// Custom/unknown server
  custom,
}

/// Server authentication mode.
enum AuthMode {
  none,
  basicAuth,
  bearerToken,
  cookie,
  jwt,
  apiKey,
}

/// Configuration for a single server connection.
class ServerConfig {
  const ServerConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.baseUrl,
    this.authMode = AuthMode.none,
    this.authToken,
    this.extraHeaders = const {},
    this.isEnabled = true,
    this.isPrimary = false,
    this.syncCategories = true,
    this.syncManga = true,
    this.syncChapters = true,
    this.syncProgress = true,
    this.syncReadingProgress = true,
    this.autoSyncInterval = const Duration(hours: 4),
    this.wifiOnly = false,
    this.maxParallelDownloads = 4,
    this.capabilities,
    this.lastSyncTimestamp,
    this.lastProbeTimestamp,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ServerType.values.byName(json['type'] as String),
      baseUrl: json['baseUrl'] as String,
      authMode: AuthMode.values.byName(json['authMode'] as String? ?? 'none'),
      authToken: json['authToken'] as String?,
      extraHeaders: Map<String, String>.from(json['extraHeaders'] as Map? ?? {}),
      isEnabled: json['isEnabled'] as bool? ?? true,
      isPrimary: json['isPrimary'] as bool? ?? false,
      syncCategories: json['syncCategories'] as bool? ?? true,
      syncManga: json['syncManga'] as bool? ?? true,
      syncChapters: json['syncChapters'] as bool? ?? true,
      syncProgress: json['syncProgress'] as bool? ?? true,
      syncReadingProgress: json['syncReadingProgress'] as bool? ?? true,
      autoSyncInterval: Duration(hours: json['autoSyncIntervalHours'] as int? ?? 4),
      wifiOnly: json['wifiOnly'] as bool? ?? false,
      maxParallelDownloads: json['maxParallelDownloads'] as int? ?? 4,
      capabilities: json['capabilities'] != null
          ? Map<String, dynamic>.from(json['capabilities'] as Map)
          : null,
      lastSyncTimestamp: json['lastSyncTimestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSyncTimestamp'] as int)
          : null,
      lastProbeTimestamp: json['lastProbeTimestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastProbeTimestamp'] as int)
          : null,
    );
  }

  final String id;
  final String name;
  final ServerType type;
  final String baseUrl;
  final AuthMode authMode;
  final String? authToken;
  final Map<String, String> extraHeaders;
  final bool isEnabled;
  final bool isPrimary;
  final bool syncCategories;
  final bool syncManga;
  final bool syncChapters;
  final bool syncProgress;
  final bool syncReadingProgress;
  final Duration autoSyncInterval;
  final bool wifiOnly;
  final int maxParallelDownloads;
  final Map<String, dynamic>? capabilities;
  final DateTime? lastSyncTimestamp;
  final DateTime? lastProbeTimestamp;

  ServerConfig copyWith({
    String? id,
    String? name,
    ServerType? type,
    String? baseUrl,
    AuthMode? authMode,
    String? authToken,
    Map<String, String>? extraHeaders,
    bool? isEnabled,
    bool? isPrimary,
    bool? syncCategories,
    bool? syncManga,
    bool? syncChapters,
    bool? syncProgress,
    bool? syncReadingProgress,
    Duration? autoSyncInterval,
    bool? wifiOnly,
    int? maxParallelDownloads,
    Map<String, dynamic>? capabilities,
    DateTime? lastSyncTimestamp,
    DateTime? lastProbeTimestamp,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      baseUrl: baseUrl ?? this.baseUrl,
      authMode: authMode ?? this.authMode,
      authToken: authToken ?? this.authToken,
      extraHeaders: extraHeaders ?? this.extraHeaders,
      isEnabled: isEnabled ?? this.isEnabled,
      isPrimary: isPrimary ?? this.isPrimary,
      syncCategories: syncCategories ?? this.syncCategories,
      syncManga: syncManga ?? this.syncManga,
      syncChapters: syncChapters ?? this.syncChapters,
      syncProgress: syncProgress ?? this.syncProgress,
      syncReadingProgress: syncReadingProgress ?? this.syncReadingProgress,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      maxParallelDownloads: maxParallelDownloads ?? this.maxParallelDownloads,
      capabilities: capabilities ?? this.capabilities,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      lastProbeTimestamp: lastProbeTimestamp ?? this.lastProbeTimestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'baseUrl': baseUrl,
      'authMode': authMode.name,
      'authToken': authToken,
      'extraHeaders': extraHeaders,
      'isEnabled': isEnabled,
      'isPrimary': isPrimary,
      'syncCategories': syncCategories,
      'syncManga': syncManga,
      'syncChapters': syncChapters,
      'syncProgress': syncProgress,
      'syncReadingProgress': syncReadingProgress,
      'autoSyncIntervalHours': autoSyncInterval.inHours,
      'wifiOnly': wifiOnly,
      'maxParallelDownloads': maxParallelDownloads,
      'capabilities': capabilities,
      'lastSyncTimestamp': lastSyncTimestamp?.millisecondsSinceEpoch,
      'lastProbeTimestamp': lastProbeTimestamp?.millisecondsSinceEpoch,
    };
  }

  /// Generate auth headers for requests.
  Map<String, String> getAuthHeaders() {
    final headers = <String, String>{...extraHeaders};
    if (authToken != null && authToken!.trim().isNotEmpty) {
      final token = authToken!.trim();
      switch (authMode) {
        case AuthMode.basicAuth:
          if (token.startsWith('Basic ') || token.startsWith('Bearer ')) {
            headers['Authorization'] = token;
          } else {
            headers['Authorization'] = 'Basic $token';
          }
          break;
        case AuthMode.bearerToken:
          if (token.startsWith('Bearer ')) {
            headers['Authorization'] = token;
          } else {
            headers['Authorization'] = 'Bearer $token';
          }
          break;
        case AuthMode.cookie:
          headers['Cookie'] = token;
          break;
        case AuthMode.jwt:
          if (token.startsWith('Bearer ')) {
            headers['Authorization'] = token;
          } else {
            headers['Authorization'] = 'Bearer $token';
          }
          break;
        case AuthMode.apiKey:
          headers['X-API-Key'] = token;
          break;
        case AuthMode.none:
          break;
      }
    }
    return headers;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ServerConfig(id: $id, name: $name, type: ${type.name}, baseUrl: $baseUrl, '
      'enabled: $isEnabled, primary: $isPrimary)';
}

/// Manager for multiple server configurations.
class ServerConfigManager {
  ServerConfigManager._();
  static final ServerConfigManager instance = ServerConfigManager._();

  static const String _prefsKey = 'server_configs';

  List<ServerConfig> _servers = [];
  bool _initialized = false;

  List<ServerConfig> get servers => List.unmodifiable(_servers);

  List<ServerConfig> get enabledServers =>
      _servers.where((s) => s.isEnabled).toList();

  ServerConfig? get primaryServer {
    try {
      return _servers.firstWhere((s) => s.isPrimary && s.isEnabled);
    } catch (_) {
      return _servers.firstWhere((s) => s.isEnabled, orElse: () => _servers.first);
    }
  }

  /// Initialize from persisted storage.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_prefsKey);
      if (jsonList != null) {
        _servers = jsonList
            .map((s) => ServerConfig.fromJson(
                Map<String, dynamic>.from(jsonDecode(s) as Map)))
            .toList();
      }
    } catch (_) {
      _servers = [];
    }
    _initialized = true;
  }

  /// Save configurations to persistent storage.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, _servers.map((s) => jsonEncode(s.toJson())).toList());
  }

  /// Add a new server configuration.
  Future<void> addServer(ServerConfig config) async {
    // Ensure only one primary
    if (config.isPrimary) {
      _servers = _servers.map((s) => s.copyWith(isPrimary: false)).toList();
    }
    _servers.add(config);
    await _save();
  }

  /// Update an existing server configuration.
  Future<void> updateServer(ServerConfig config) async {
    final index = _servers.indexWhere((s) => s.id == config.id);
    if (index >= 0) {
      // Ensure only one primary
      if (config.isPrimary) {
        _servers = _servers.map((s) => s.copyWith(isPrimary: s.id == config.id)).toList();
      }
      _servers[index] = config;
      await _save();
    }
  }

  /// Remove a server configuration.
  Future<void> removeServer(String id) async {
    _servers.removeWhere((s) => s.id == id);
    await _save();
  }

  /// Set a server as primary.
  Future<void> setPrimary(String id) async {
    _servers = _servers.map((s) => s.copyWith(isPrimary: s.id == id)).toList();
    await _save();
  }

  /// Get server by ID.
  ServerConfig? getServer(String id) {
    try {
      return _servers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update server capabilities after probe.
  Future<void> updateCapabilities(String id, Map<String, dynamic> capabilities) async {
    final server = getServer(id);
    if (server != null) {
      await updateServer(server.copyWith(
        capabilities: capabilities,
        lastProbeTimestamp: DateTime.now(),
      ));
    }
  }

  /// Update last sync timestamp.
  Future<void> updateLastSync(String id) async {
    final server = getServer(id);
    if (server != null) {
      await updateServer(server.copyWith(lastSyncTimestamp: DateTime.now()));
    }
  }

  /// Create a default Suwayomi server config for first-time setup.
  static ServerConfig createDefaultSuwayomi({
    String? baseUrl,
    String? authToken,
  }) {
    return ServerConfig(
      id: 'suwayomi_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Suwayomi Server',
      type: ServerType.suwayomi,
      baseUrl: baseUrl ?? '',
      authToken: authToken,
      isPrimary: true,
      isEnabled: true,
    );
  }
}