import 'dart:async';

import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import 'tachibk_parser.dart';

/// A source that exists on the Suwayomi server (from `sources { nodes }`).
class ServerSourceInfo {
  final String id;
  final String name;
  final String displayName;
  final String lang;

  const ServerSourceInfo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.lang,
  });

  factory ServerSourceInfo.fromGraph(Map<String, dynamic> node) => ServerSourceInfo(
        id: (node['id'] ?? '').toString(),
        name: (node['name'] as String? ?? '').trim(),
        displayName: (node['displayName'] as String? ?? '').trim(),
        lang: (node['lang'] as String? ?? '').trim().toLowerCase(),
      );
}

enum TachiBkPlanEntryStatus { ready, sourceMissing }

/// One manga in the import plan, resolved against the live server's sources.
class TachiBkImportPlanEntry {
  final TachiBkManga manga;
  final TachiBkPlanEntryStatus status;
  final ServerSourceInfo? matchedSource;
  bool include;

  TachiBkImportPlanEntry({
    required this.manga,
    required this.status,
    required this.matchedSource,
    this.include = true,
  });
}

/// Synchronous, pure planning result for a parsed backup against a server
/// source list. Kept side-effect free so it is trivially unit-testable.
class TachiBkImportPlan {
  final List<TachiBkImportPlanEntry> entries;

  /// Category names from the backup that do not exist on the server yet.
  final List<String> categoriesToCreate;

  TachiBkImportPlan({required this.entries, required this.categoriesToCreate});

  List<TachiBkImportPlanEntry> get readyEntries =>
      entries.where((e) => e.status == TachiBkPlanEntryStatus.ready && e.include).toList();
  List<TachiBkImportPlanEntry> get skippedEntries =>
      entries.where((e) => e.status != TachiBkPlanEntryStatus.ready || !e.include).toList();
}

/// Outcome of applying a plan.
class TachiBkImportResult {
  final int imported;
  final int failed;
  final List<String> messages;

  const TachiBkImportResult({required this.imported, required this.failed, required this.messages});
}

/// Client-side `.tachibk` restore: maps backup entries to installed server
/// sources and applies them (add to library + categories) via GraphQL.
class TachiBkImportService {
  TachiBkImportService._();

  static final TachiBkImportService instance = TachiBkImportService._();

  /// Resolves each backup manga against the given server sources.
  ///
  /// Matching is by normalized (name, lang) — Tachiyomi source ids are their
  /// own numbering and do not map to Suwayomi source ids, but names and
  /// languages line up.
  static TachiBkImportPlan planImport(TachiBkBackup backup, List<ServerSourceInfo> serverSources) {
    final entries = <TachiBkImportPlanEntry>[];
    final missingCategoryNames = <String>{};

    for (final m in backup.manga) {
      final source = _matchSource(backup, m, serverSources);
      entries.add(TachiBkImportPlanEntry(
        manga: m,
        status: source == null ? TachiBkPlanEntryStatus.sourceMissing : TachiBkPlanEntryStatus.ready,
        matchedSource: source,
      ));
      if (source == null) continue;
      for (final c in m.categories) {
        missingCategoryNames.add(c);
      }
    }
    for (final c in backup.categories) {
      missingCategoryNames.add(c);
    }

    return TachiBkImportPlan(
      entries: entries,
      categoriesToCreate: missingCategoryNames.toList()..sort(),
    );
  }

  /// Fetches server sources and builds a plan. Requires a configured server.
  Future<TachiBkImportPlan?> planImportFromServer(TachiBkBackup backup) async {
    if (!GraphQLClientService.instance.isConfigured) return null;
    final raw = await GraphQLClientService.instance.fetchSources();
    if (raw == null) return null;
    final nodes = (raw['sources']?['nodes'] as List? ?? const []);
    final serverSources = [
      for (final n in nodes.whereType<Map<String, dynamic>>()) ServerSourceInfo.fromGraph(n),
    ];
    return planImport(backup, serverSources);
  }

  /// Applies a plan: creates missing categories, adds each included manga via
  /// Suwayomi's url-based `addManga` mutation and assigns its categories.
  Future<TachiBkImportResult> applyPlan(TachiBkImportPlan plan) async {
    final messages = <String>[];
    var imported = 0;
    var failed = 0;

    // 1. Category name → id map from the server.
    final categoryIds = <String, int>{};
    final existing = await GraphQLClientService.instance.fetchCategories();
    if (existing != null) {
      for (final n in (existing['categories']?['nodes'] as List? ?? const []).whereType<Map<String, dynamic>>()) {
        final name = (n['name'] as String? ?? '').trim();
        final id = n['id'];
        if (name.isNotEmpty && id is int) categoryIds[name] = id;
      }
    }
    for (final name in plan.categoriesToCreate) {
      if (categoryIds.containsKey(name)) continue;
      final created = await GraphQLClientService.instance.createCategory(name);
      if (created != null) {
        final id = created['createCategory']?['id'];
        if (id is int) categoryIds[name] = id;
      }
    }

    // 2. Restore each chosen manga.
    for (final entry in plan.readyEntries) {
      final src = entry.matchedSource!;
      final manga = entry.manga;
      try {
        final serverId = await GraphQLClientService.instance
            .fetchMangaIdByUrl(src.id, manga.url, title: manga.title);
        if (serverId == null) {
          failed++;
          messages.add('✗ ${manga.title}: could not resolve on ${src.name}');
          continue;
        }
        final wanted = [
          for (final c in manga.categories)
            if (categoryIds.containsKey(c)) categoryIds[c]!,
        ];
        if (wanted.isNotEmpty) {
          await GraphQLClientService.instance.setMangaCategories(serverId, wanted);
        }
        imported++;
        messages.add('✓ ${manga.title} restored (${src.name})');
      } catch (e) {
        failed++;
        messages.add('✗ ${manga.title}: $e');
        await LoggerService.instance.logWarning('TachiBk import failed for ${manga.title}: $e', 'TachiBkImport');
      }
    }

    return TachiBkImportResult(imported: imported, failed: failed, messages: messages);
  }

  /// Best-effort (name, lang) match against installed server sources.
  static ServerSourceInfo? _matchSource(
    TachiBkBackup backup,
    TachiBkManga m,
    List<ServerSourceInfo> serverSources,
  ) {
    // Backup records the source id per manga; look up its name/lang there.
    String sourceLang = m.lang;
    String? sourceName;
    for (final s in backup.sources) {
      if (s.id == m.sourceId) {
        sourceName = s.name;
        sourceLang = s.lang.isEmpty ? m.lang : s.lang;
        break;
      }
    }

    final nameKey = (sourceName ?? '').trim().toLowerCase();
    final langKey = sourceLang.trim().toLowerCase();

    // Exact (name, lang).
    for (final s in serverSources) {
      final sLang = s.lang.trim().toLowerCase();
      final sName = s.name.trim().toLowerCase();
      if (nameKey.isNotEmpty && sName == nameKey && (langKey.isEmpty || langKey == 'all' || sLang == langKey)) {
        return s;
      }
    }
    // displayName fallback (same lang).
    for (final s in serverSources) {
      final sLang = s.lang.trim().toLowerCase();
      final sDisp = s.displayName.trim().toLowerCase();
      if (nameKey.isNotEmpty && sDisp == nameKey && (langKey.isEmpty || langKey == 'all' || sLang == langKey)) {
        return s;
      }
    }
    // Lang-only fallback when name is unknown — still better than nothing.
    for (final s in serverSources) {
      final sLang = s.lang.trim().toLowerCase();
      if (langKey.isNotEmpty && langKey != 'all' && sLang == langKey && sLang == 'en') {
        return s;
      }
    }
    return null;
  }
}