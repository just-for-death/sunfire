import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoggerService {
  static LoggerService? _instance;
  File? _logFile;

  LoggerService._();

  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  Future<void> initialize() async {
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
      await logInfo('LoggerService initialized');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize local log file: $e');
      }
    }
  }

  Future<void> logInfo(String message, [String? category]) async {
    final entry = '[${DateTime.now().toIso8601String()}] [INFO] ${category != null ? "[$category] " : ""}$message\n';
    if (kDebugMode) {
      print(entry.trimRight());
    }
    await _writeToLogFile(entry);
  }

  Future<void> logWarning(String message, [String? category]) async {
    final entry = '[${DateTime.now().toIso8601String()}] [WARN] ${category != null ? "[$category] " : ""}$message\n';
    if (kDebugMode) {
      print(entry.trimRight());
    }
    await _writeToLogFile(entry);
  }

  Future<void> logError(String message, {dynamic exception, StackTrace? stackTrace, String? category}) async {
    final entry = '[${DateTime.now().toIso8601String()}] [ERROR] ${category != null ? "[$category] " : ""}$message\nException: $exception\n';
    if (kDebugMode) {
      print(entry.trimRight());
    }
    await _writeToLogFile(entry);

    if (exception != null) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: Hint.withMap({'category': category ?? 'General', 'message': message}),
      );
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
    return 'No logs recorded yet.';
  }

  Future<void> clearLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.writeAsString('');
      }
    } catch (_) {}
  }
}
