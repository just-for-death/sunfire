// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:convert';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../constants/endpoints.dart';
import '../../../../constants/enum.dart';
import '../../../../features/settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import '../../../../features/settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import '../../../../features/settings/presentation/server/widget/credential_popup/credentials_popup.dart';
import '../../../../global_providers/global_providers.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import '../../data/manga_book/manga_book_repository.dart';

part 'local_downloads_service.g.dart';

class LocalDownloadsService {
  const LocalDownloadsService();

  static const _rootFolderName = 'catalyst_offline';
  static const _chaptersFolderName = 'chapters';
  static const _manifestFileName = 'manifest.json';

  Future<Directory> _chapterDir(int chapterId) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(baseDir.path, _rootFolderName, _chaptersFolderName, '$chapterId'),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _manifestFile(int chapterId) async {
    final dir = await _chapterDir(chapterId);
    return File(p.join(dir.path, _manifestFileName));
  }

  Future<bool> isChapterDownloaded(int chapterId) async {
    final manifest = await _manifestFile(chapterId);
    return manifest.exists();
  }

  Future<List<String>?> getLocalPages(int chapterId) async {
    final manifest = await _manifestFile(chapterId);
    if (!await manifest.exists()) return null;

    final raw = await manifest.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    final pages = decoded['pages'];
    if (pages is! List) return null;

    final dir = await _chapterDir(chapterId);
    final result = <String>[];
    for (final entry in pages) {
      if (entry is! String) continue;
      final filePath = p.join(dir.path, entry);
      if (await File(filePath).exists()) {
        // Use file:// so the rest of the app can treat it like a URL.
        result.add(Uri.file(filePath).toString());
      }
    }
    return result.isEmpty ? null : result;
  }

  Future<void> deleteChapter(int chapterId) async {
    final dir = await _chapterDir(chapterId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<List<int>> listDownloadedChapterIds() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(baseDir.path, _rootFolderName, _chaptersFolderName),
    );
    if (!await dir.exists()) return const [];

    final results = <int>[];
    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final id = int.tryParse(p.basename(entity.path));
      if (id == null) continue;
      final manifest = File(p.join(entity.path, _manifestFileName));
      if (await manifest.exists()) {
        results.add(id);
      }
    }
    results.sort();
    return results;
  }

  /// Downloads all pages of a chapter to local device storage.
  ///
  /// [onProgress] is called after each page is saved:
  ///   - first arg: pages saved so far (1-based)
  ///   - second arg: total pages in the chapter
  Future<void> downloadChapter({
    required Ref ref,
    required int chapterId,
    void Function(int current, int total)? onProgress,
  }) async {
    final repo = ref.read(mangaBookRepositoryProvider);
    final chapterPages = await repo.getChapterPages(chapterId: chapterId);
    if (chapterPages == null || chapterPages.pages.isEmpty) return;

    final total = chapterPages.pages.length;
    final dir = await _chapterDir(chapterId);
    final authType = ref.read(authTypeKeyProvider);
    final basicToken = ref.read(credentialsProvider);
    final baseApi = Endpoints.baseApi(
      baseUrl: ref.read(serverUrlProvider),
      port: ref.read(serverPortProvider),
      addPort: ref.read(serverPortToggleProvider).ifNull(),
      appendApiToUrl: false,
    );
    final headers = (authType == AuthType.basic && basicToken.isNotBlank)
        ? <String, String>{'Authorization': basicToken!}
        : const <String, String>{};

    final savedFiles = <String>[];
    for (int i = 0; i < total; i++) {
      final pageUrl = chapterPages.pages[i];
      final fullUrl = '$baseApi$pageUrl';
      final response = await http.get(Uri.parse(fullUrl), headers: headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Failed to download page: $fullUrl');
      }

      final extFromUrl = _safeExtFromUrl(pageUrl);
      final fileName = '${(i + 1).toString().padLeft(4, '0')}$extFromUrl';
      final targetPath = p.join(dir.path, fileName);
      await File(targetPath).writeAsBytes(response.bodyBytes, flush: true);
      savedFiles.add(fileName);

      // Notify progress after each saved page.
      onProgress?.call(i + 1, total);
    }

    final manifest = await _manifestFile(chapterId);
    await manifest.writeAsString(jsonEncode({
      'chapterId': chapterId,
      'downloadedAt': DateTime.now().toIso8601String(),
      'pages': savedFiles,
    }));
  }

  /// Returns total bytes used by all offline downloads in the app documents dir.
  Future<int> getOfflineStorageBytesUsed() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(baseDir.path, _rootFolderName));
    if (!await dir.exists()) return 0;

    int total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  static String _safeExtFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final ext = p.extension(uri.path);
      if (ext.isEmpty || ext.length > 8) return '.img';
      return ext;
    } catch (_) {
      return '.img';
    }
  }
}

@riverpod
LocalDownloadsService localDownloadsService(Ref ref) =>
    const LocalDownloadsService();

@riverpod
Future<List<int>> localDownloadedChapterIds(Ref ref) =>
    ref.watch(localDownloadsServiceProvider).listDownloadedChapterIds();

/// Total bytes consumed by offline downloads.
/// Re-evaluates whenever the downloaded-chapters list changes.
/// Old-style provider — no build_runner needed.
final offlineStorageSizeProvider = FutureProvider<int>((ref) async {
  // Depend on the chapters list so we refresh after add/delete.
  await ref.watch(localDownloadedChapterIdsProvider.future);
  return ref.read(localDownloadsServiceProvider).getOfflineStorageBytesUsed();
});

