import 'dart:convert';
import 'package:dio/dio.dart';
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
    {'name': 'm2k3a (Primary)', 'url': 'https://m2k3a.github.io/mangayomi-extensions/index.json'},
    {'name': 'Mallyd11 (Anime/Novel)', 'url': 'https://raw.githubusercontent.com/Mallyd11/mangayomi-anime-extensions/main/index.json'},
    {'name': 'Swakshan (Cloudflare)', 'url': 'https://raw.githubusercontent.com/Swakshan/mangayomi-swak-extensions/refs/heads/main/index.json'},
    {'name': 'gato404 (NSFW)', 'url': 'https://raw.githubusercontent.com/gato404/kegareta-sauces/refs/heads/main/index.json'},
  ];

  static RepoManager? _instance;
  final Dio _dio = Dio();

  RepoManager._();

  static RepoManager get instance {
    _instance ??= RepoManager._();
    return _instance!;
  }

  Future<List<RepoSourceItem>> fetchRepoSources(String indexUrl) async {
    try {
      final response = await _dio.get(indexUrl);
      final list = response.data is String ? jsonDecode(response.data) as List : response.data as List;
      return list.map((item) => RepoSourceItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      await LoggerService.instance.logError('Failed to fetch repo index from $indexUrl: $e', exception: e, stackTrace: stack, category: 'RepoManager');
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
