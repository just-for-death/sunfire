import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/logger_service.dart';
import 'metron_api_client.dart';
import 'metron_models.dart';

/// Service facade for Metron.cloud API integration.
class MetronService extends ChangeNotifier {
  static const String _storageKey = 'sunfire_metron_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static MetronService? _instance;
  static MetronService get instance => _instance ??= MetronService._();

  final MetronApiClient _client;

  // In-memory cache for recent search queries: query -> { timestamp, results }
  final Map<String, ({DateTime timestamp, List<MetronSeries> results, int count, String? nextUrl})> _searchCache = {};
  // In-memory cache for series details: seriesId -> { timestamp, series }
  final Map<int, ({DateTime timestamp, MetronSeries series})> _detailCache = {};
  // In-memory cache for series issue list: seriesId -> { timestamp, issues, issueMap }
  final Map<int, ({DateTime timestamp, List<MetronIssueSummary> issues, Map<String, int> issueMap})> _issueMapCache = {};

  static const Duration _cacheTtl = Duration(minutes: 10);

  MetronService._({MetronApiClient? client}) : _client = client ?? MetronApiClient();

  @visibleForTesting
  factory MetronService.withClient(MetronApiClient client) => MetronService._(client: client);

  MetronApiClient get client => _client;
  MetronRateLimitState get rateLimitState => _client.rateLimitState;

  bool get isConfigured => _client.apiToken != null && _client.apiToken!.trim().isNotEmpty;

  /// Load persisted token on app startup
  Future<void> initialize() async {
    try {
      final token = await _storage.read(key: _storageKey);
      if (token != null && token.isNotEmpty) {
        configureToken(token);
        return;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_storageKey);
      if (token != null && token.isNotEmpty) {
        configureToken(token);
      }
    } catch (_) {}
  }

  /// Save or clear the Metron API token securely
  Future<void> saveToken(String? token) async {
    final clean = token?.trim();
    if (clean == null || clean.isEmpty) {
      try {
        await _storage.delete(key: _storageKey);
      } catch (_) {}
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_storageKey);
      } catch (_) {}
      configureToken(null);
    } else {
      try {
        await _storage.write(key: _storageKey, value: clean);
      } catch (_) {}
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, clean);
      } catch (_) {}
      configureToken(clean);
    }
  }

  void configureToken(String? token) {
    _client.setToken(token);
    _searchCache.clear();
    _detailCache.clear();
    _issueMapCache.clear();
    notifyListeners();
  }

  /// Test token validity by requesting the first page of publishers.
  Future<bool> testConnection(String token) async {
    final prev = _client.apiToken;
    try {
      _client.setToken(token);
      final res = await _client.get<Map<String, dynamic>>('publisher/', queryParameters: {'page': 1});
      return res.statusCode == 200;
    } finally {
      _client.setToken(prev);
    }
  }

  /// Search for series by name and optional publisher ID.
  Future<({List<MetronSeries> series, int totalCount, String? nextUrl})> searchSeries({
    required String query,
    int page = 1,
    int? publisherId,
  }) async {
    final cleanQuery = query.trim();
    final cacheKey = '$cleanQuery|$page|$publisherId';

    final cached = _searchCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return (series: cached.results, totalCount: cached.count, nextUrl: cached.nextUrl);
    }

    final queryParams = <String, dynamic>{
      'page': page,
    };
    if (cleanQuery.isNotEmpty) {
      queryParams['name'] = cleanQuery;
    }
    if (publisherId != null && publisherId > 0) {
      queryParams['publisher'] = publisherId;
    }

    try {
      final res = await _client.get<Map<String, dynamic>>('series/', queryParameters: queryParams);
      final data = res.data ?? {};
      final rawList = data['results'] as List<dynamic>? ?? [];
      final count = data['count'] is int ? data['count'] as int : int.tryParse(data['count']?.toString() ?? '') ?? 0;
      final next = data['next'] as String?;

      final parsed = rawList
          .whereType<Map<String, dynamic>>()
          .map((m) => MetronSeries.fromJson(m))
          .toList();

      _searchCache[cacheKey] = (
        timestamp: DateTime.now(),
        results: parsed,
        count: count,
        nextUrl: next,
      );

      return (series: parsed, totalCount: count, nextUrl: next);
    } catch (e, st) {
      LoggerService.instance.logError('Metron search failed for "$query": $e', exception: e, stackTrace: st, category: 'Metron');
      rethrow;
    }
  }

  /// Fetch full series details by ID.
  Future<MetronSeries> getSeriesDetail(int seriesId) async {
    final cached = _detailCache[seriesId];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.series;
    }

    try {
      final res = await _client.get<Map<String, dynamic>>('series/$seriesId/');
      final data = res.data ?? {};
      final series = MetronSeries.fromJson(data);

      _detailCache[seriesId] = (timestamp: DateTime.now(), series: series);
      return series;
    } catch (e, st) {
      LoggerService.instance.logError('Metron getSeriesDetail failed for $seriesId: $e', exception: e, stackTrace: st, category: 'Metron');
      rethrow;
    }
  }

  /// Fetch full issue list for a series and return both the list and an issue-number-to-ID lookup map.
  Future<({List<MetronIssueSummary> issues, Map<String, int> issueMap})> getSeriesIssues(int seriesId) async {
    final cached = _issueMapCache[seriesId];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return (issues: cached.issues, issueMap: cached.issueMap);
    }

    try {
      final res = await _client.get<dynamic>('series/$seriesId/issue_list/');
      final List<dynamic> rawList;
      if (res.data is List) {
        rawList = res.data as List<dynamic>;
      } else if (res.data is Map && (res.data as Map).containsKey('results')) {
        rawList = (res.data as Map)['results'] as List<dynamic>;
      } else {
        rawList = [];
      }

      final issues = <MetronIssueSummary>[];
      final map = <String, int>{};

      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final issue = MetronIssueSummary.fromJson(item);
          issues.add(issue);

          // Normalize issue number for key lookups (e.g. "1", "1.5", "001" -> "1")
          final cleanNum = issue.number.trim();
          map[cleanNum] = issue.id;

          final asDouble = double.tryParse(cleanNum);
          if (asDouble != null) {
            final intEquivalent = asDouble.toInt();
            if (asDouble == intEquivalent) {
              map[intEquivalent.toString()] = issue.id;
            }
          }
        }
      }

      _issueMapCache[seriesId] = (timestamp: DateTime.now(), issues: issues, issueMap: map);
      return (issues: issues, issueMap: map);
    } catch (e, st) {
      LoggerService.instance.logError('Metron getSeriesIssues failed for $seriesId: $e', exception: e, stackTrace: st, category: 'Metron');
      rethrow;
    }
  }

  /// Scrobble an issue to the user's Metron collection as read.
  Future<bool> scrobbleIssue({required int issueId, DateTime? readDate}) async {
    final dateStr = (readDate ?? DateTime.now()).toIso8601String().split('T').first;
    try {
      final res = await _client.post<Map<String, dynamic>>(
        'collection/scrobble/',
        data: {
          'issue_id': issueId,
          'date_read': dateStr,
        },
      );
      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (ok) {
        LoggerService.instance.logInfo('Successfully scrobbled issue $issueId to Metron ($dateStr)', 'Metron');
      }
      return ok;
    } catch (e, st) {
      LoggerService.instance.logError('Metron scrobbleIssue failed for $issueId: $e', exception: e, stackTrace: st, category: 'Metron');
      rethrow;
    }
  }

  /// Fetch list of known major publishers.
  Future<List<MetronPublisher>> getPublishers({int page = 1}) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('publisher/', queryParameters: {'page': page});
      final data = res.data ?? {};
      final rawList = data['results'] as List<dynamic>? ?? [];
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((p) => MetronPublisher.fromJson(p))
          .toList();
    } catch (e, st) {
      LoggerService.instance.logError('Metron getPublishers failed: $e', exception: e, stackTrace: st, category: 'Metron');
      return [];
    }
  }

  /// Normalize a chapter number and title to match against a Metron issue map.
  static String? matchIssueNumber(String chapterName, double chapterNumber, Map<String, int> issueMap) {
    // 1. Direct double formatted as integer or decimal
    final intPart = chapterNumber.toInt();
    if (chapterNumber == intPart) {
      final intStr = intPart.toString();
      if (issueMap.containsKey(intStr)) return intStr;
    } else {
      final floatStr = chapterNumber.toString();
      if (issueMap.containsKey(floatStr)) return floatStr;
    }

    // 2. Extract leading number or "#X" from chapter title
    final hashMatch = RegExp(r'#\s*(\d+(\.\d+)?)').firstMatch(chapterName);
    if (hashMatch != null) {
      final numStr = hashMatch.group(1)!;
      if (issueMap.containsKey(numStr)) return numStr;
    }

    final issueWordMatch = RegExp(r'(?:issue|chapter|ch\.?)\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(chapterName);
    if (issueWordMatch != null) {
      final numStr = issueWordMatch.group(1)!;
      if (issueMap.containsKey(numStr)) return numStr;
    }

    // 3. Fallback: check if the integer part is in the map
    if (issueMap.containsKey(intPart.toString())) {
      return intPart.toString();
    }

    return null;
  }
}
