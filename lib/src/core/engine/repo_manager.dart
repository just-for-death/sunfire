import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../logging/logger_service.dart';

class RepoSourceItem {
  final String name;
  final String lang;
  final String sourceCodeUrl;
  final String iconUrl;
  final String version;
  final bool isJs;

  RepoSourceItem({
    required this.name,
    required this.lang,
    required this.sourceCodeUrl,
    required this.iconUrl,
    required this.version,
    required this.isJs,
  });

  factory RepoSourceItem.fromJson(Map<String, dynamic> json) {
    final url = json['sourceCodeUrl'] as String? ?? '';
    final isJs = url.endsWith('.js') || url.contains('/javascript/');
    return RepoSourceItem(
      name: json['name'] as String? ?? 'Unknown',
      lang: json['lang'] as String? ?? 'all',
      sourceCodeUrl: url,
      iconUrl: json['iconUrl'] as String? ?? '',
      version: json['version'] as String? ?? '0.0.1',
      isJs: isJs,
    );
  }
}

class RepoManager {
  static const List<Map<String, String>> defaultRepos = [
    {'name': 'kodjodevf (Official Core)', 'url': 'https://kodjodevf.github.io/mangayomi-extensions/index.json'},
    {'name': 'm2k3a (Primary Community)', 'url': 'https://m2k3a.github.io/mangayomi-extensions/index.json'},
    {'name': 'Mallyd11 (Anime/Novel)', 'url': 'https://raw.githubusercontent.com/Mallyd11/mangayomi-anime-extensions/main/index.json'},
    {'name': 'Swakshan (Cloudflare Bypass)', 'url': 'https://raw.githubusercontent.com/Swakshan/mangayomi-swak-extensions/refs/heads/main/index.json'},
    {'name': 'gato404 (NSFW)', 'url': 'https://raw.githubusercontent.com/gato404/kegareta-sauces/refs/heads/main/index.json'},
  ];

  static RepoManager? _instance;
  final Dio _dio = Dio();

  RepoManager._();

  static RepoManager get instance {
    _instance ??= RepoManager._();
    return _instance!;
  }

  /// Returns a cache-friendly key for a given repo URL
  String _cacheKeyFor(String url) =>
      url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').substring(0, url.length.clamp(0, 60));

  Future<File> _cacheFileFor(String indexUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/repo_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    return File('${cacheDir.path}/${_cacheKeyFor(indexUrl)}.json');
  }

  Future<List<RepoSourceItem>> fetchRepoSources(String indexUrl) async {
    final cacheFile = await _cacheFileFor(indexUrl);
    try {
      // Try network first
      final response = await _dio
          .get(indexUrl)
          .timeout(const Duration(seconds: 6));
      final raw = response.data is String
          ? response.data as String
          : jsonEncode(response.data);
      // Cache to disk for offline use
      await cacheFile.writeAsString(raw);
      final list = jsonDecode(raw) as List;
      return list.map((item) => RepoSourceItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      // Offline fallback: read from disk cache
      if (await cacheFile.exists()) {
        try {
          final cached = await cacheFile.readAsString();
          final list = jsonDecode(cached) as List;
          return list.map((item) => RepoSourceItem.fromJson(item as Map<String, dynamic>)).toList();
        } catch (_) {}
      }
      return [];
    }
  }

  Future<String?> downloadJsSourceCode(String jsUrl) async {
    try {
      final response = await _dio.get<String>(jsUrl);
      return response.data;
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to download JS source code from $jsUrl: $e', exception: e, stackTrace: stack, category: 'RepoManager');
      return null;
    }
  }
}
