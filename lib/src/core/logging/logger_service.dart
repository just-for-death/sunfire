import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LogEntry {
  final DateTime timestamp;
  final String level; // INFO, WARN, ERROR, DEBUG, NETWORK
  final String? category;
  final String message;
  final dynamic exception;
  final StackTrace? stackTrace;
  /// Correlation id of the async flow that produced this entry, or null when
  /// logged outside any [LoggerService.withCorrelationAsync] scope.
  final String? correlationId;

  LogEntry({
    required this.timestamp,
    required this.level,
    this.category,
    required this.message,
    this.exception,
    this.stackTrace,
    this.correlationId,
  });

  String format() {
    final cat = category != null ? '[$category] ' : '';
    final exc = exception != null ? '\nException: $exception' : '';
    final st = (stackTrace != null && level == 'ERROR') ? '\n$stackTrace' : '';
    final corr = correlationId != null ? ' [corr=$correlationId]' : '';
    return '[${timestamp.toIso8601String()}] [$level]$corr $cat$message$exc$st';
  }
}

class LoggerService {
  static LoggerService? _instance;
  File? _logFile;
  final List<LogEntry> _inMemoryLogs = [];
  final StreamController<LogEntry> _streamController = StreamController<LogEntry>.broadcast();
  static const int maxInMemoryLogs = 1000;

  LoggerService._();

  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  List<LogEntry> get inMemoryLogs => List.unmodifiable(_inMemoryLogs);
  Stream<LogEntry> get logStream => _streamController.stream;

  /// Zone key for the correlation id (UIX-18). Zone-scoped rather than a
  /// static global, so concurrent async flows (sync, library update, download
  /// queue) each keep their own id across awaits instead of overwriting one
  /// another's.
  static const Symbol _corrKey = #sunfireCorrelationId;

  /// Generates a new correlation ID.
  static String _generateCorrelationId() {
    return const Uuid().v4().substring(0, 8);
  }

  /// The correlation id of the current flow, or null outside any scope. No id
  /// is invented per log line (that only added noise).
  static String? get currentCorrelationId => Zone.current[_corrKey] as String?;

  /// Runs [body] within a new correlation ID scope.
  static R withCorrelation<R>(R Function() body, {String? correlationId}) =>
      runZoned(body, zoneValues: {_corrKey: correlationId ?? _generateCorrelationId()});

  /// Async version of [withCorrelation]. The id follows every await and
  /// callback started inside [body].
  static Future<R> withCorrelationAsync<R>(Future<R> Function() body, {String? correlationId}) =>
      runZoned(body, zoneValues: {_corrKey: correlationId ?? _generateCorrelationId()});

  Future<void> initialize() async {
    installGlobalErrorHooks();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${dir.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      _logFile = File('${logDir.path}/sunfire_diagnostic.log');
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }
      await logInfo('LoggerService initialized with live streaming and error capture', 'System');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize local log file: $e');
      }
    }
  }

  void installGlobalErrorHooks() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      // Filter out noisy Linux GTK keyboard modifier assertion from legacy RawKeyboard
      if (msg.contains('raw_keyboard.dart') || msg.contains('keysPressed.isNotEmpty')) {
        return;
      }
      FlutterError.presentError(details);
      unawaited(logError(
        msg,
        exception: details.exception,
        stackTrace: details.stack,
        category: 'FlutterError',
      ));
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      final msg = error.toString();
      if (msg.contains('raw_keyboard.dart') ||
          msg.contains('keysPressed.isNotEmpty') ||
          msg.contains('JSValue released') ||
          msg.contains('WebSocketChannelException') ||
          msg.contains('SocketException')) {
        return true;
      }
      unawaited(logError(
        msg,
        exception: error,
        stackTrace: stack,
        category: 'PlatformError',
      ));
      return true;
    };
  }

  Future<void> _recordLog(LogEntry entry) async {
    _inMemoryLogs.add(entry);
    if (_inMemoryLogs.length > maxInMemoryLogs) {
      _inMemoryLogs.removeAt(0);
    }
    _streamController.add(entry);

    final formatted = '${entry.format()}\n';
    if (kDebugMode) {
      print(formatted.trimRight());
    }
    await _writeToLogFile(formatted);
  }

  Future<void> logInfo(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'INFO',
      category: category,
      message: message,
      correlationId: currentCorrelationId,
    ));
  }

  Future<void> logDebug(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'DEBUG',
      category: category,
      message: message,
      correlationId: currentCorrelationId,
    ));
  }

  Future<void> logNetwork(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'NETWORK',
      category: category,
      message: message,
      correlationId: currentCorrelationId,
    ));
  }

  Future<void> logWarning(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'WARN',
      category: category,
      message: message,
      correlationId: currentCorrelationId,
    ));
  }

  Future<void> logError(String message, {dynamic exception, StackTrace? stackTrace, String? category}) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: 'ERROR',
      category: category,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
      correlationId: currentCorrelationId,
    );
    await _recordLog(entry);
  }

  Future<void> _writeFuture = Future.value();

  Future<void> _writeToLogFile(String text) {
    _writeFuture = _writeFuture.then((_) async {
      try {
        if (_logFile != null) {
          if (await _logFile!.exists()) {
            final len = await _logFile!.length();
            if (len > 2 * 1024 * 1024) {
              final oldContent = await _logFile!.readAsString();
              final truncated = oldContent.substring(oldContent.length ~/ 2);
              await _logFile!.writeAsString(truncated);
            }
          }
          await _logFile!.writeAsString(text, mode: FileMode.append, flush: true);
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[logger_service] ignored error: $ignoredError'); }
    });
    return _writeFuture;
  }

  Future<String> getDiagnosticLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (e) {
      return 'Failed to read log file: $e';
    }
    if (_inMemoryLogs.isNotEmpty) {
      return _inMemoryLogs.map((e) => e.format()).join('\n');
    }
    return 'No logs recorded yet.';
  }

  Future<void> clearLogs() async {
    _inMemoryLogs.clear();
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.writeAsString('');
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[logger_service] ignored error: $ignoredError'); }
  }
}