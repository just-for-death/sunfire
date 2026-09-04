import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/isar_service.dart';
import '../engine/content_resolver_service.dart';
import '../engine/javascript/m_client.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../sync/graphql_client_service.dart';
import 'settings_service.dart';

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

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'mangaId': mangaId,
    'chapterName': chapterName,
    'mangaTitle': mangaTitle,
    'progress': progress,
    'status': status.name,
    'error': error,
  };

  factory LocalDownloadTask.fromJson(Map<String, dynamic> map) {
    return LocalDownloadTask(
      chapterId: map['chapterId'] as int,
      mangaId: map['mangaId'] as int,
      chapterName: map['chapterName'] as String? ?? '',
      mangaTitle: map['mangaTitle'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      status: LocalDownloadStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LocalDownloadStatus.queued,
      ),
      error: map['error'] as String?,
    );
  }
}

class DownloadManagerService extends ChangeNotifier {
  static final DownloadManagerService instance = DownloadManagerService._();
  DownloadManagerService._() {
    _configureDio();
  }

  final List<LocalDownloadTask> _localTasks = [];
  final Set<int> _downloadedLocalChapterIds = {};
  final Set<int> _downloadedServerChapterIds = {};
  final Set<int> _downloadedLocalMangaIds = {};

  bool _isProcessingLocalQueue = false;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 2),
    followRedirects: true,
    maxRedirects: 5,
  ));

  void _configureDio() {
    try {
      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        };
      }
    } catch (_) {}
  }

  static const String _queuePrefKey = 'sunfire_download_queue_v1';

  List<LocalDownloadTask> get localTasks => List.unmodifiable(_localTasks);
  Set<int> get downloadedLocalChapterIds => _downloadedLocalChapterIds;
  Set<int> get downloadedServerChapterIds => _downloadedServerChapterIds;
  Set<int> get downloadedMangaIds => _downloadedLocalMangaIds;

  Future<bool> _isWifiConnected() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    } catch (_) {
      return true;
    }
  }

  Future<void> _saveQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _localTasks.map((t) => t.toJson()).toList();
      await prefs.setString(_queuePrefKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[DownloadManager] Error saving queue state: $e');
    }
  }

  Future<void> _loadQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_queuePrefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _localTasks.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final task = LocalDownloadTask.fromJson(item);
            // Any tasks interrupted mid-flight should reset to queued
            if (task.status == LocalDownloadStatus.downloading) {
              task.status = LocalDownloadStatus.queued;
            }
            _localTasks.add(task);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DownloadManager] Error loading queue state: $e');
    }
  }

  bool _isQueuePaused = false;
  bool get isQueuePaused => _isQueuePaused;

  void pauseLocalQueue() {
    _isQueuePaused = true;
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.queued) {
        task.status = LocalDownloadStatus.paused;
      }
    }
    _saveQueueState();
    notifyListeners();
  }

  void resumeLocalQueue() {
    _isQueuePaused = false;
    for (final task in _localTasks) {
      if (task.status == LocalDownloadStatus.downloading || task.status == LocalDownloadStatus.paused) {
        task.status = LocalDownloadStatus.queued;
      }
    }
    _saveQueueState();
    if (!_isProcessingLocalQueue && _localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
      _processLocalQueue();
    }
    notifyListeners();
  }

  Future<void> initialize() async {
    await _scanDownloadedLocalChapters();
    await _loadQueueState();
    resumeLocalQueue();
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
                final ch = await IsarService.instance.getChapterByServerId(id);
                if (ch != null && ch.mangaId > 0) {
                  _downloadedLocalMangaIds.add(ch.mangaId);
                }
              }
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      LoggerService.instance.logError('_scanDownloadedLocalChapters error: $e', category: 'DownloadManager');
    }
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
    _localTasks.removeWhere((t) => t.chapterId == chapterId && t.status == LocalDownloadStatus.failed);
    _localTasks.add(task);
    await _saveQueueState();
    notifyListeners();

    _processLocalQueue();
  }

  Future<void> _processLocalQueue() async {
    if (_isProcessingLocalQueue) return;
    _isProcessingLocalQueue = true;

    while (_localTasks.any((t) => t.status == LocalDownloadStatus.queued)) {
      if (_isQueuePaused) {
        _isProcessingLocalQueue = false;
        notifyListeners();
        return;
      }
      // Check network constraints (Wi-Fi only)
      if (SettingsService.instance.downloadOnlyOnWifi) {
        final onWifi = await _isWifiConnected();
        if (!onWifi) {
          debugPrint('[DownloadManager] ⏸️ Pausing queue: Download only on Wi-Fi is enabled');
          _isProcessingLocalQueue = false;
          notifyListeners();
          return;
        }
      }

      final task = _localTasks.firstWhere((t) => t.status == LocalDownloadStatus.queued);
      task.status = LocalDownloadStatus.downloading;
      await _saveQueueState();
      notifyListeners();

      try {
        await _downloadChapterLocally(task);
        task.status = LocalDownloadStatus.completed;
        task.progress = 1.0;
        _downloadedLocalChapterIds.add(task.chapterId);
        _downloadedLocalMangaIds.add(task.mangaId);

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
      await _saveQueueState();
      notifyListeners();
    }

    _isProcessingLocalQueue = false;
  }

  Future<void> _downloadChapterLocally(LocalDownloadTask task) async {
    // 1. Resolve chapter pages via 3-Tier ContentResolver (supports local JS scrapers, downloads & server)
    final ch = await IsarService.instance.getChapterByServerId(task.chapterId);
    final manga = ch != null ? await IsarService.instance.getMangaByServerId(ch.mangaId) : null;
    final sourceName = manga?.sourceName;
    final chapterUrl = (ch?.url.isNotEmpty == true) ? ch!.url : ch?.realUrl;

    final resolved = await ContentResolverService.instance.resolveChapterPages(
      chapterServerId: task.chapterId,
      chapterUrl: chapterUrl,
      sourceName: sourceName,
    );

    final rawPages = resolved.pageUrls;
    if (rawPages.isEmpty) {
      throw Exception('No pages found for chapter ${task.chapterName}');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final chapterDir = Directory('${appDir.path}/downloads/${task.chapterId}');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }

    final totalPages = rawPages.length;
    final effectiveSource = resolved.effectiveSourceName ?? sourceName ?? '';

    // Download pages with bounded concurrency instead of one-at-a-time.
    // Each page fetch is dominated by network round-trip latency, not CPU,
    // so running several in parallel cuts total chapter time roughly by the
    // concurrency factor (e.g. a 50-page chapter at ~1s/page sequentially
    // takes ~50s; at 5-way concurrency it takes closer to ~10s).
    const concurrency = 5;
    var completed = 0;
    for (var start = 0; start < totalPages; start += concurrency) {
      final end = (start + concurrency < totalPages) ? start + concurrency : totalPages;
      if (task.status == LocalDownloadStatus.failed || task.status == LocalDownloadStatus.paused) {
        throw Exception('Cancelled or paused');
      }
      await Future.wait(List.generate(end - start, (offset) async {
        final i = start + offset;
        await _downloadSinglePage(chapterDir, effectiveSource, rawPages[i], i);
        completed++;
        task.progress = completed / totalPages;
        notifyListeners();
      }));
    }
    final existingFiles = chapterDir
        .listSync()
        .whereType<File>()
        .where((f) {
          final name = f.path.toLowerCase();
          return name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.png') ||
              name.endsWith('.webp') ||
              name.endsWith('.gif') ||
              name.endsWith('.bmp');
        })
        .toList();
    if (existingFiles.length < totalPages) {
      throw Exception('Incomplete download: only ${existingFiles.length}/$totalPages pages saved');
    }
  }

  static bool _isValidImageBytes(List<int>? b) {
    if (b == null || b.length < 12) return false;
    // JPEG: FF D8
    if (b[0] == 0xFF && b[1] == 0xD8) return true;
    // PNG: 89 50 4E 47
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return true;
    // WebP: RIFF ... WEBP
    if (b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
        b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return true;
    }
    // GIF: GIF87a / GIF89a
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) return true;
    // BMP: 42 4D
    if (b[0] == 0x42 && b[1] == 0x4D) return true;
    // Reject HTML/XML/JSON error responses (<, {, [)
    if (b[0] == 60 || b[0] == 123 || b[0] == 91) return false;
    return b.length > 500;
  }

  Future<void> _downloadSinglePage(Directory chapterDir, String effectiveSource, String pageUrl, int index) async {
    final file = File('${chapterDir.path}/page_${(index + 1).toString().padLeft(3, '0')}.jpg');
    if (await file.exists() && await file.length() > 500) {
      return;
    }
    final baseHeaders = QuickJsService.getImageHeaders(effectiveSource, pageUrl);
    final cookieHeaders = MClient.getCookiesPref(pageUrl);
    final headers = <String, dynamic>{
      ...baseHeaders,
      ...cookieHeaders,
      'User-Agent': MClient.userAgent,
    };
    List<int>? pageBytes;

    // Pass 1: Standard fetch
    try {
      final response = await _dio.get<List<int>>(
        pageUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
      );
      if (_isValidImageBytes(response.data)) {
        pageBytes = response.data;
      }
    } catch (_) {}

    // Pass 2: Retry with Referer stripped (anti-hotlink bypass)
    if (pageBytes == null && headers.containsKey('Referer')) {
      try {
        final noRef = Map<String, dynamic>.from(headers)..remove('Referer');
        final r2 = await _dio.get<List<int>>(
          pageUrl,
          options: Options(headers: noRef, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r2.data)) {
          pageBytes = r2.data;
        }
      } catch (_) {}
    }

    // Pass 3: Retry with Origin Referer
    if (pageBytes == null) {
      try {
        final uri = Uri.parse(pageUrl);
        final originRef = Map<String, dynamic>.from(headers)..['Referer'] = '${uri.origin}/';
        final r3 = await _dio.get<List<int>>(
          pageUrl,
          options: Options(headers: originRef, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r3.data)) {
          pageBytes = r3.data;
        }
      } catch (_) {}
    }

    // Pass 4: Clean Desktop Chrome User-Agent and Image Accept headers
    if (pageBytes == null) {
      try {
        final browserHeaders = Map<String, dynamic>.from(headers)
          ..['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
          ..['Accept'] = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
        final r4 = await _dio.get<List<int>>(
          pageUrl,
          options: Options(headers: browserHeaders, responseType: ResponseType.bytes),
        );
        if (_isValidImageBytes(r4.data)) {
          pageBytes = r4.data;
        }
      } catch (_) {}
    }

    // Desktop fallback: if Dio was blocked by Cloudflare TLS fingerprint, fetch via curl-impersonate
    if ((pageBytes == null || pageBytes.isEmpty) && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      final candidates = ['/usr/bin/curl-impersonate', 'curl-impersonate', 'curl-impersonate-chrome', '/usr/bin/curl', 'curl'];
      for (final exe in candidates) {
        try {
          final args = <String>['-s', '-L', '--max-time', '25'];
          headers.forEach((k, v) => args.addAll(['-H', '$k: $v']));
          args.add(pageUrl);
          final res = await Process.run(exe, args, stdoutEncoding: null);
          if (res.exitCode == 0) {
            final b = res.stdout as List<int>;
            if (_isValidImageBytes(b)) {
              pageBytes = b;
              break;
            }
          }
        } catch (_) {}
      }
    }

    if (pageBytes != null && pageBytes.isNotEmpty && _isValidImageBytes(pageBytes)) {
      await file.writeAsBytes(pageBytes);
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
      await _saveQueueState();

      final ch = await IsarService.instance.getChapterByServerId(chapterId);
      final mId = ch?.mangaId;
      if (ch != null) {
        ch.isDownloaded = false;
        await IsarService.instance.saveChapter(ch);
      }
      if (mId != null && mId > 0) {
        final remaining = await IsarService.instance.getChaptersForManga(mId);
        final hasOther = remaining.any((c) => _downloadedLocalChapterIds.contains(c.serverId));
        if (!hasOther) {
          _downloadedLocalMangaIds.remove(mId);
        }
      }
      notifyListeners();
    } catch (e) {
      LoggerService.instance.logError('deleteLocalDownload error: $e', category: 'DownloadManager');
    }
  }

  void cancelLocalDownload(int chapterId) {
    final task = _localTasks.firstWhere((t) => t.chapterId == chapterId, orElse: () => LocalDownloadTask(chapterId: 0, mangaId: 0, chapterName: '', mangaTitle: ''));
    if (task.chapterId != 0) {
      task.status = LocalDownloadStatus.failed;
      task.error = 'Cancelled';
      _saveQueueState();
      notifyListeners();
    }
  }

  Future<void> dismissLocalTask(int chapterId) async {
    _localTasks.removeWhere((t) => t.chapterId == chapterId);
    await _saveQueueState();
    notifyListeners();
  }

  void clearCompletedDownloads() {
    _localTasks.removeWhere((t) => t.status == LocalDownloadStatus.completed);
    _saveQueueState();
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
