import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LogEntry {
  final DateTime timestamp;
  final String level; // INFO, WARN, ERROR, DEBUG, NETWORK
  final String? category;
  final String message;
  final dynamic exception;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    this.category,
    required this.message,
    this.exception,
    this.stackTrace,
  });

  String format() {
    final cat = category != null ? '[$category] ' : '';
    final exc = exception != null ? '\nException: $exception' : '';
    final st = (stackTrace != null && level == 'ERROR') ? '\n$stackTrace' : '';
    return '[${timestamp.toIso8601String()}] [$level] $cat$message$exc$st';
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
      FlutterError.presentError(details);
      logError(
        details.exceptionAsString(),
        exception: details.exception,
        stackTrace: details.stack,
        category: 'FlutterError',
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      logError(
        error.toString(),
        exception: error,
        stackTrace: stack,
        category: 'PlatformError',
      );
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
    ));
  }

  Future<void> logDebug(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'DEBUG',
      category: category,
      message: message,
    ));
  }

  Future<void> logNetwork(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'NETWORK',
      category: category,
      message: message,
    ));
  }

  Future<void> logWarning(String message, [String? category]) async {
    await _recordLog(LogEntry(
      timestamp: DateTime.now(),
      level: 'WARN',
      category: category,
      message: message,
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
    );
    await _recordLog(entry);

    if (exception != null) {
      try {
        await Sentry.captureException(
          exception,
          stackTrace: stackTrace,
          hint: Hint.withMap({'category': category ?? 'General', 'message': message}),
        );
      } catch (_) {}
    }
  }

  Future<void> _writeToLogFile(String text) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString(text, mode: FileMode.append);
      }
    } catch (_) {}
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
    } catch (_) {}
  }
}
