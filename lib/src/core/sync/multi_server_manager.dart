// lib/src/core/sync/multi_server_manager.dart
//
// MultiServerManager - coordinates multiple server adapters.
// Part of S4.1: Multi-server support - simultaneous Suwayomi/Kavita/Mihon

import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, debugPrint;

import '../db/models/category.dart';
import '../db/models/manga.dart';
import 'kavita_adapter.dart' show KavitaAdapter;
import 'mihon_adapter.dart' show MihonAdapter;
import 'server_adapter.dart' show ServerAdapter, LibrarySnapshot, SyncOperation;
import 'server_type.dart' show ServerConfig, ServerConfigManager, ServerType;
import 'suwayomi_adapter.dart' show SuwayomiAdapter;

/// MultiServerManager - coordinates multiple server adapters.
///
/// Provides:
/// - Unified access to all configured servers
/// - Primary server routing (single-server callers transparent)
/// - Multi-server merge (library from all servers)
/// - Per-server capability tracking
class MultiServerManager extends ChangeNotifier {
  MultiServerManager._();
  static final MultiServerManager instance = MultiServerManager._();

  final Map<String, ServerAdapter> _adapters = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;
  List<ServerAdapter> get adapters => List.unmodifiable(_adapters.values);
  List<ServerConfig> get servers => ServerConfigManager.instance.servers;

  /// Get adapter for a specific server.
  ServerAdapter? getAdapter(String serverId) => _adapters[serverId];

  /// Get primary adapter (for single-server callers).
  ServerAdapter? get primaryAdapter {
    final primary = ServerConfigManager.instance.primaryServer;
    if (primary != null) {
      return _adapters[primary.id];
    }
    for (final adapter in _adapters.values) {
      if (adapter.config.isEnabled) return adapter;
    }
    return null;
  }

  /// Initialize all configured servers.
  Future<void> initialize() async {
    if (_initialized) return;

    await ServerConfigManager.instance.initialize();
    final servers = ServerConfigManager.instance.servers;

    for (final config in servers) {
      if (config.isEnabled) {
        await addAdapter(config);
      }
    }

    _initialized = true;
    notifyListeners();
  }

  /// Add an adapter for a server config.
  Future<ServerAdapter?> addAdapter(ServerConfig config) async {
    try {
      final adapter = _createAdapter(config);
      if (adapter == null) {
        debugPrint('[MultiServerManager] Unsupported server type: ${config.type}');
        return null;
      }

      await adapter.initialize();
      _adapters[config.id] = adapter;
      notifyListeners();
      return adapter;
    } catch (e) {
      debugPrint('[MultiServerManager] Failed to add adapter ${config.id}: $e');
      return null;
    }
  }

  /// Remove an adapter.
  Future<void> removeAdapter(String serverId) async {
    final adapter = _adapters.remove(serverId);
    if (adapter != null) {
      await adapter.close();
      notifyListeners();
    }
  }

  /// Reload all adapters from config.
  Future<void> reload() async {
    for (final adapter in _adapters.values) {
      await adapter.close();
    }
    _adapters.clear();

    final servers = ServerConfigManager.instance.servers;
    for (final config in servers) {
      if (config.isEnabled) {
        await addAdapter(config);
      }
    }
    notifyListeners();
  }

  ServerAdapter? _createAdapter(ServerConfig config) {
    switch (config.type) {
      case ServerType.suwayomi:
        return SuwayomiAdapter(config);
      case ServerType.kavita:
        return KavitaAdapter(config);
      case ServerType.mihon:
        return MihonAdapter(config);
      case ServerType.opds:
      case ServerType.custom:
        return null;
    }
  }

  /// Fetch library from all enabled servers, merged.
  Future<LibrarySnapshot> fetchMergedLibrary({bool forceRefresh = false}) async {
    final allManga = <Manga>[];
    final allCategories = <Category>[];
    final seenIds = <String>{};

    for (final adapter in _adapters.values) {
      if (!adapter.config.isEnabled) continue;
      if (!adapter.supports(SyncOperation.fetchLibrary)) continue;

      try {
        final snapshot = await adapter.fetchLibrary(forceRefresh: forceRefresh);
        if (!snapshot.isComplete) continue;

        for (final manga in snapshot.manga) {
          final key = '${adapter.config.id}:${manga.serverId}';
          if (!seenIds.contains(key)) {
            seenIds.add(key);
            allManga.add(manga);
          }
        }

        for (final cat in snapshot.categories) {
          if (!allCategories.any((c) => c.name == cat.name)) {
            allCategories.add(cat);
          }
        }
      } catch (e) {
        debugPrint('[MultiServerManager] fetchLibrary from ${adapter.name} failed: $e');
      }
    }

    return LibrarySnapshot(
      manga: allManga,
      categories: allCategories,
      timestamp: DateTime.now(),
      isComplete: true,
      totalCount: allManga.length,
    );
  }

  /// Search across all servers.
  Future<List<Manga>> searchAllServers(String query, {int limit = 20}) async {
    final results = <Manga>[];
    final perServer = (limit / (_adapters.isNotEmpty ? _adapters.length : 1)).ceil();

    for (final adapter in _adapters.values) {
      if (!adapter.config.isEnabled) continue;
      if (!adapter.supports(SyncOperation.searchManga)) continue;

      try {
        final found = await adapter.searchManga(query, limit: perServer);
        results.addAll(found);
      } catch (e) {
        debugPrint('[MultiServerManager] search on ${adapter.name} failed: $e');
      }
    }

    return results.take(limit).toList();
  }

  /// Check reachability of all servers.
  Future<Map<String, bool>> checkAllReachable() async {
    final results = <String, bool>{};
    for (final entry in _adapters.entries) {
      try {
        results[entry.key] = await entry.value.isReachable();
      } catch (_) {
        results[entry.key] = false;
      }
    }
    return results;
  }

  /// Get sync summary across all servers.
  Future<MultiServerSyncSummary> getSyncSummary() async {
    final summaries = <String, ServerSyncSummary>{};
    for (final entry in _adapters.entries) {
      final adapter = entry.value;
      bool reachable = false;
      try {
        reachable = await adapter.isReachable();
      } catch (_) {}
      summaries[entry.key] = ServerSyncSummary(
        serverId: entry.key,
        serverName: adapter.name,
        serverType: adapter.type.name,
        isReachable: reachable,
        lastSync: adapter.config.lastSyncTimestamp,
        lastProbe: adapter.config.lastProbeTimestamp,
      );
    }
    return MultiServerSyncSummary(servers: summaries);
  }
}

/// Per-server sync summary.
class ServerSyncSummary {
  const ServerSyncSummary({
    required this.serverId,
    required this.serverName,
    required this.serverType,
    required this.isReachable,
    this.lastSync,
    this.lastProbe,
  });

  final String serverId;
  final String serverName;
  final String serverType;
  final bool isReachable;
  final DateTime? lastSync;
  final DateTime? lastProbe;
}

/// Summary across all servers.
class MultiServerSyncSummary {
  const MultiServerSyncSummary({required this.servers});

  final Map<String, ServerSyncSummary> servers;

  int get totalServers => servers.length;
  int get reachableServers => servers.values.where((s) => s.isReachable).length;
  bool get allReachable => totalServers > 0 && reachableServers == totalServers;
  bool get anyReachable => reachableServers > 0;
}
