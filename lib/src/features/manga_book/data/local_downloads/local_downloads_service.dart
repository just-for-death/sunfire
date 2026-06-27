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
import '../../domain/chapter/chapter_model.dart';
import '../../domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../domain/manga/manga_model.dart';

part 'local_downloads_service.g.dart';

/// Metadata stored alongside offline chapter pages for offline reading fallbacks.
class OfflineChapterManifest {
  const OfflineChapterManifest({
    required this.chapterId,
    required this.mangaId,
    required this.chapterName,
    required this.chapterNumber,
    required this.mangaTitle,
    required this.pageCount,
    required this.pages,
    this.lastPageRead = 0,
    this.isRead = false,
  });

  final int chapterId;
  final int mangaId;
  final String chapterName;
  final double chapterNumber;
  final String mangaTitle;
  final int pageCount;
  final List<String> pages;
  final int lastPageRead;
  final bool isRead;

  factory OfflineChapterManifest.fromJson(Map<String, dynamic> json) {
    final pagesRaw = json['pages'];
    return OfflineChapterManifest(
      chapterId: json['chapterId'] as int? ?? 0,
      mangaId: json['mangaId'] as int? ?? 0,
      chapterName: json['chapterName'] as String? ?? '',
      chapterNumber: (json['chapterNumber'] as num?)?.toDouble() ?? 0,
      mangaTitle: json['mangaTitle'] as String? ?? '',
      pageCount: json['pageCount'] as int? ??
          (pagesRaw is List ? pagesRaw.length : 0),
      pages: pagesRaw is List
          ? pagesRaw.whereType<String>().toList()
          : const [],
      lastPageRead: json['lastPageRead'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'mangaId': mangaId,
        'chapterName': chapterName,
        'chapterNumber': chapterNumber,
        'mangaTitle': mangaTitle,
        'pageCount': pageCount,
        'lastPageRead': lastPageRead,
        'isRead': isRead,
        'downloadedAt': DateTime.now().toIso8601String(),
        'pages': pages,
      };
}

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
    final manifest = await getOfflineManifest(chapterId);
    if (manifest == null || manifest.pages.isEmpty) return false;
    final pages = await getLocalPages(chapterId);
    return pages != null && pages.length >= manifest.pageCount;
  }

  Future<OfflineChapterManifest?> getOfflineManifest(int chapterId) async {
    final manifest = await _manifestFile(chapterId);
    if (!await manifest.exists()) return null;

    try {
      final raw = await manifest.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return OfflineChapterManifest.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getOfflineMangaTitle(int mangaId) async {
    if (mangaId <= 0) return null;
    final ids = await listDownloadedChapterIds();
    for (final chapterId in ids) {
      final manifest = await getOfflineManifest(chapterId);
      if (manifest?.mangaId == mangaId &&
          manifest!.mangaTitle.isNotEmpty) {
        return manifest.mangaTitle;
      }
    }
    return null;
  }

  Future<bool> hasOfflineManga(int mangaId) async {
    if (mangaId <= 0) return false;
    final ids = await listDownloadedChapterIds();
    for (final chapterId in ids) {
      final manifest = await getOfflineManifest(chapterId);
      if (manifest?.mangaId == mangaId) return true;
    }
    return false;
  }

  ChapterDto _chapterDtoFromManifest(OfflineChapterManifest manifest) {
    return Fragment$ChapterDto(
      chapterNumber: manifest.chapterNumber,
      fetchedAt: '0',
      id: manifest.chapterId,
      isBookmarked: false,
      isDownloaded: true,
      isRead: manifest.isRead,
      lastPageRead: manifest.lastPageRead,
      lastReadAt: '0',
      mangaId: manifest.mangaId,
      name: manifest.chapterName.isNotEmpty
          ? manifest.chapterName
          : 'Chapter ${manifest.chapterId}',
      pageCount: manifest.pageCount,
      sourceOrder: 0,
      uploadDate: '0',
      url: '',
      meta: const [],
    );
  }

  /// Builds a chapter list from offline manifests when the server is unavailable.
  Future<List<ChapterDto>> getOfflineChaptersForManga(int mangaId) async {
    if (mangaId <= 0) return const [];
    final ids = await listDownloadedChapterIds();
    final chapters = <ChapterDto>[];
    for (final chapterId in ids) {
      final manifest = await getOfflineManifest(chapterId);
      if (manifest == null || manifest.mangaId != mangaId) continue;
      final pages = await getLocalPages(chapterId);
      if (pages == null || pages.isEmpty) continue;
      chapters.add(_chapterDtoFromManifest(manifest));
    }
    chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    return chapters;
  }

  Future<List<String>?> getLocalPages(int chapterId) async {
    final manifest = await getOfflineManifest(chapterId);
    if (manifest == null || manifest.pages.isEmpty) return null;

    final dir = await _chapterDir(chapterId);
    final result = <String>[];
    for (final entry in manifest.pages) {
      final filePath = p.join(dir.path, entry);
      if (await File(filePath).exists()) {
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
    if (chapterPages == null || chapterPages.pages.isEmpty) {
      throw StateError('No chapter pages available for offline download');
    }

    ChapterDto? chapterMeta;
    try {
      chapterMeta = await repo.getChapter(chapterId: chapterId);
    } catch (_) {
      chapterMeta = null;
    }

    MangaDto? mangaMeta;
    final mangaId = chapterMeta?.mangaId;
    if (mangaId == null || mangaId <= 0) {
      throw StateError('Cannot download chapter without manga metadata');
    }
    try {
      mangaMeta = await repo.getManga(mangaId: mangaId);
    } catch (_) {
      mangaMeta = null;
    }

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
    try {
      for (int i = 0; i < total; i++) {
        final pageUrl = chapterPages.pages[i];
        final fullUrl = '$baseApi$pageUrl';
        final response = await http
            .get(Uri.parse(fullUrl), headers: headers)
            .timeout(const Duration(seconds: 30));
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
    } catch (e) {
      // Clean up the partial directory to avoid orphaned files consuming storage.
      try {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      } catch (_) {
        // Best-effort cleanup — don't mask the original error.
      }
      rethrow;
    }

    final manifest = await _manifestFile(chapterId);
    await manifest.writeAsString(
      jsonEncode(
        OfflineChapterManifest(
          chapterId: chapterId,
          mangaId: mangaId,
          chapterName: chapterMeta?.name ?? '',
          chapterNumber: chapterMeta?.chapterNumber ?? 0,
          mangaTitle: mangaMeta?.title ?? '',
          pageCount: total,
          pages: savedFiles,
          lastPageRead: chapterMeta?.lastPageRead ?? 0,
          isRead: chapterMeta?.isRead ?? false,
        ).toJson(),
      ),
    );
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
