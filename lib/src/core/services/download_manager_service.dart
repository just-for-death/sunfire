import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../db/isar_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';

enum LocalDownloadStatus { queued, downloading, completed, failed, paused }

class LocalDownloadTask {
  final int chapterId;
  final int mangaId;
  final String chapterName;
  final String mangaTitle;
  double progress; // 0.0 to 1.0
  LocalDownloadStatus status;
  String? error;

  LocalDownloadTask({
    required this.chapterId,
    required this.mangaId,
    required this.chapterName,
    required this.mangaTitle,
    this.progress = 0.0,
    this.status = LocalDownloadStatus.queued,
    this.error,
  });
}

class DownloadManagerService extends ChangeNotifier {
  static final DownloadManagerService instance = DownloadManagerService._();
  DownloadManagerService._();

  final List<LocalDownloadTask> _localTasks = [];
  final Set<int> _downloadedLocalChapterIds = {};
  final Set<int> _downloadedServerChapterIds = {};

  bool _isProcessingLocalQueue = false;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(minutes: 2)));

  List<LocalDownloadTask> get localTasks => List.unmodifiable(_localTasks);
  Set<int> get downloadedLocalChapterIds => _downloadedLocalChapterIds;
  Set<int> get downloadedServerChapterIds => _downloadedServerChapterIds;

  Future<void> initialize() async {
    await _scanDownloadedLocalChapters();
  }

  Future<void> _scanDownloadedLocalChapters() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      if (await downloadsDir.exists()) {
        final entities = await downloadsDir.list().toList();
        for (final entity in entities) {
          if (entity is Directory) {
            final segments = entity.uri.pathSegments.where((s) => s.isNotEmpty).toList();
            if (segments.isNotEmpty) {
              final id = int.tryParse(segments.last);
              if (id != null) {
                _downloadedLocalChapterIds.add(id);
              }
            }
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  bool isChapterDownloadedLocally(int chapterId) => _downloadedLocalChapterIds.contains(chapterId);
  bool isChapterDownloadedOnServer(int chapterId) => _downloadedServerChapterIds.contains(chapterId);

  void markChapterDownloadedOnServer(int chapterId, bool isDownloaded) {
    if (isDownloaded) {
      _downloadedServerChapterIds.add(chapterId);
    } else {
      _downloadedServerChapterIds.remove(chapterId);
    }
    notifyListeners();
  }

  // ── LOCAL DEVICE DOWNLOAD QUEUE ────────────────────────────
  Future<void> enqueueLocalDownload({
    required int chapterId,
    required int mangaId,
    required String chapterName,
    required String mangaTitle,
  }) async {
    if (_localTasks.any((t) => t.chapterId == chapterId && t.status != LocalDownloadStatus.failed)) {
      return;
    }

    final task = LocalDownloadTask(
      chapterId: chapterId,
      mangaId: mangaId,
      chapterName: chapterName,
      mangaTitle: mangaTitle,
    );
    _localTasks.add(task);
    notifyListeners();

    _processLocalQueue();
  }

  Future<void> _processLocalQueue() async {
    if (_isProcessingLocalQueue) return;
    _isProcessingLocalQueue = true;

    while (_localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
      final task = _localTasks.firstWhere((t) => t.status == LocalDownloadStatus.queued);
      task.status = LocalDownloadStatus.downloading;
      notifyListeners();

      try {
        await _downloadChapterLocally(task);
        task.status = LocalDownloadStatus.completed;
        task.progress = 1.0;
        _downloadedLocalChapterIds.add(task.chapterId);

        // Update Isar DB
        final ch = await IsarService.instance.getChapterByServerId(task.chapterId);
        if (ch != null) {
          ch.isDownloaded = true;
          await IsarService.instance.saveChapter(ch);
        }
      } catch (e, stack) {
        task.status = LocalDownloadStatus.failed;
        task.error = e.toString();
        await LoggerService.instance.logError('Failed to download chapter ${task.chapterId}: $e', exception: e, stackTrace: stack, category: 'DownloadManager');
      }
      notifyListeners();
    }

    _isProcessingLocalQueue = false;
  }

  Future<void> _downloadChapterLocally(LocalDownloadTask task) async {
    final serverUrl = GraphQLClientService.instance.baseUrl ?? 'http://localhost:4567';

    // 1. Fetch chapter page URLs from Suwayomi
    final data = await GraphQLClientService.instance.fetchChapterPages(task.chapterId);
    if (data == null || !data.containsKey('fetchChapterPages')) {
      throw Exception('Failed to retrieve chapter page URLs');
    }

    final rawPages = data['fetchChapterPages']['pages'] as List<dynamic>?;
    if (rawPages == null || rawPages.isEmpty) {
      throw Exception('No pages found for chapter');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final chapterDir = Directory('${appDir.path}/downloads/${task.chapterId}');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }

    final totalPages = rawPages.length;
    for (int i = 0; i < totalPages; i++) {
      final pagePath = rawPages[i].toString();
      final pageUrl = pagePath.startsWith('http') ? pagePath : '$serverUrl$pagePath';
      final file = File('${chapterDir.path}/page_${i + 1}.jpg');

      await _dio.download(pageUrl, file.path);

      task.progress = (i + 1) / totalPages;
      notifyListeners();
    }
  }

  Future<void> deleteLocalDownload(int chapterId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${appDir.path}/downloads/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }
      _downloadedLocalChapterIds.remove(chapterId);
      _localTasks.removeWhere((t) => t.chapterId == chapterId);

      final ch = await IsarService.instance.getChapterByServerId(chapterId);
      if (ch != null) {
        ch.isDownloaded = false;
        await IsarService.instance.saveChapter(ch);
      }
      notifyListeners();
    } catch (_) {}
  }

  void cancelLocalDownload(int chapterId) {
    final task = _localTasks.firstWhere((t) => t.chapterId == chapterId, orElse: () => LocalDownloadTask(chapterId: 0, mangaId: 0, chapterName: '', mangaTitle: ''));
    if (task.chapterId != 0) {
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
      notifyListeners();
    }
  }

  void clearCompletedDownloads() {
    _localTasks.removeWhere((t) => t.status == LocalDownloadStatus.completed);
    notifyListeners();
  }

  // ── SERVER DOWNLOAD PROXY ──────────────────────────────────
  Future<void> enqueueServerDownload(int chapterId) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.enqueueChapterDownload(chapterId);
      _downloadedServerChapterIds.add(chapterId);
      notifyListeners();
    }
  }

  Future<void> enqueueServerDownloads(List<int> chapterIds) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.enqueueChapterDownloads(chapterIds);
      _downloadedServerChapterIds.addAll(chapterIds);
      notifyListeners();
    }
  }

  Future<void> deleteServerDownload(int chapterId) async {
    if (GraphQLClientService.instance.isConfigured) {
      await GraphQLClientService.instance.deleteDownloadedChapter(chapterId);
      _downloadedServerChapterIds.remove(chapterId);
      notifyListeners();
    }
  }
}
