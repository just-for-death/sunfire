import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ServerAuthType {
  none,
  basic,
  bearer,
}

class ServerAuthCredentials {
  final ServerAuthType type;
  final String username;
  final String password;
  final String token;

  const ServerAuthCredentials({
    required this.type,
    this.username = '',
    this.password = '',
    this.token = '',
  });

  /// Formats credentials into standard HTTP Authorization header value
  String toHeaderValue() {
    switch (type) {
      case ServerAuthType.none:
        return '';
      case ServerAuthType.basic:
        if (username.isEmpty && password.isEmpty) return '';
        final encoded = base64.encode(utf8.encode('$username:$password'));
        return 'Basic $encoded';
      case ServerAuthType.bearer:
        final clean = token.trim();
        if (clean.isEmpty) return '';
        return clean.startsWith('Bearer ') ? clean : 'Bearer $clean';
    }
  }

  static ServerAuthCredentials fromHeaderValue(String? header) {
    if (header == null || header.trim().isEmpty) {
      return const ServerAuthCredentials(type: ServerAuthType.none);
    }
    final trimmed = header.trim();
    if (trimmed.startsWith('Basic ')) {
      try {
        final payload = trimmed.substring(6).trim();
        final decoded = utf8.decode(base64.decode(payload));
        final colonIdx = decoded.indexOf(':');
        if (colonIdx != -1) {
          final user = decoded.substring(0, colonIdx);
          final pass = decoded.substring(colonIdx + 1);
          return ServerAuthCredentials(
            type: ServerAuthType.basic,
            username: user,
            password: pass,
          );
        }
      } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }
      return const ServerAuthCredentials(type: ServerAuthType.none);
    } else if (trimmed.startsWith('Bearer ')) {
      return ServerAuthCredentials(
        type: ServerAuthType.bearer,
        token: trimmed.substring(7).trim(),
      );
    } else {
      // Raw token entered without scheme prefix
      return ServerAuthCredentials(
        type: ServerAuthType.bearer,
        token: trimmed,
      );
    }
  }
}

class ServerAuthHelper {
  static const String storageKey = 'sunfire_server_auth';
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<ServerAuthCredentials> loadCredentials() async {
    try {
      final header = await _storage.read(key: storageKey);
      if (header != null && header.isNotEmpty) {
        return ServerAuthCredentials.fromHeaderValue(header);
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }

    // Fallback to SharedPreferences if Keychain is restricted / fails
    try {
      final prefs = await SharedPreferences.getInstance();
      final header = prefs.getString(storageKey);
      return ServerAuthCredentials.fromHeaderValue(header);
    } catch (_) {
      return const ServerAuthCredentials(type: ServerAuthType.none);
    }
  }

  /// Persists [creds], preferring secure storage and falling back to prefs.
  ///
  /// The write path had no fallback while the read path had one, which is
  /// backwards: on a device where `FlutterSecureStorage` fails — the exact case
  /// the fallback exists for, a restricted or broken keystore — the secure write
  /// threw, the error was swallowed, and the plaintext cleanup below then ran
  /// anyway and DELETED any pre-existing fallback copy. The credentials were
  /// unrecoverable and the caller was told the save succeeded, so the user was
  /// silently signed out with no explanation.
  ///
  /// The plaintext copy is therefore only removed once the secure write has
  /// actually succeeded. It is still cleared once one does, so a device that
  /// regains a working keystore does not keep a redundant plaintext duplicate
  /// around.
  static Future<void> saveCredentials(ServerAuthCredentials creds) async {
    final header = creds.toHeaderValue();
    var secureWriteSucceeded = false;
    try {
      if (header.isEmpty) {
        await _storage.delete(key: storageKey);
      } else {
        await _storage.write(key: storageKey, value: header);
      }
      secureWriteSucceeded = true;
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (secureWriteSucceeded) {
        // Clean up any legacy plaintext credentials now that the secure copy is
        // known to exist.
        await prefs.remove(storageKey);
      } else if (header.isEmpty) {
        // Clearing: there is no secure copy to fall back on, so the plaintext
        // one must go too, or `loadCredentials` would resurrect it.
        await prefs.remove(storageKey);
      } else {
        // Secure storage is unavailable. Mirror the read path's fallback so the
        // credentials survive at all — plaintext on disk is strictly better than
        // losing them, and it is what this file already reads from.
        await prefs.setString(storageKey, header);
      }
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }
  }

  static Future<String> getRawAuthHeader() async {
    try {
      final val = await _storage.read(key: storageKey);
      if (val != null) return val;
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(storageKey) ?? '';
    } catch (_) {
      return '';
    }
  }

  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: storageKey);
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (ignoredError) { if (kDebugMode) debugPrint('[server_auth_helper] ignored ${ignoredError.runtimeType} (details withheld: credential storage)'); }
  }
}
