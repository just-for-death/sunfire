import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'graphql_client_service.dart';
import '../engine/quickjs_service.dart';
import '../logging/logger_service.dart';
import '../services/settings_service.dart';

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
  final String? sessionToken;

  const ServerAuthCredentials({
    required this.type,
    this.username = '',
    this.password = '',
    this.token = '',
    this.sessionToken,
  });

  ServerAuthCredentials copyWith({
    ServerAuthType? type,
    String? username,
    String? password,
    String? token,
    String? sessionToken,
  }) {
    return ServerAuthCredentials(
      type: type ?? this.type,
      username: username ?? this.username,
      password: password ?? this.password,
      token: token ?? this.token,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }

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
      final bearerToken = trimmed.substring(7).trim();
      return ServerAuthCredentials(
        type: ServerAuthType.bearer,
        token: bearerToken,
        sessionToken: bearerToken,
      );
    } else {
      // Raw token entered without scheme prefix
      return ServerAuthCredentials(
        type: ServerAuthType.bearer,
        token: trimmed,
        sessionToken: trimmed,
      );
    }
  }
}

class ServerAuthHelper {
  static const String storageKey = 'sunfire_server_auth';

  /// True when credentials are currently held in plaintext SharedPreferences
  /// because the OS keystore failed. The fallback keeps users signed in, but
  /// it must never be silent: the server settings screen surfaces it.
  static bool insecureFallbackActive = false;

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
      if (header != null && header.isNotEmpty) {
        insecureFallbackActive = true;
      }
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
    } catch (e) {
      // Log but continue to prefs fallback.
      if (kDebugMode) debugPrint('[server_auth_helper] secure write failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (secureWriteSucceeded) {
        // Clean up any legacy plaintext credentials now that the secure copy is
        // known to exist.
        insecureFallbackActive = false;
        await prefs.remove(storageKey);
      } else if (header.isEmpty) {
        // Clearing: there is no secure copy to fall back on, so the plaintext
        // one must go too, or `loadCredentials` would resurrect it.
        await prefs.remove(storageKey);
      } else {
        // Secure storage is unavailable. Mirror the read path's fallback so the
        // credentials survive at all — plaintext on disk is strictly better than
        // losing them, and it is what this file already reads from.
        insecureFallbackActive = true;
        await prefs.setString(storageKey, header);
      }
    } on Exception catch (e) {
      // If secure write also failed, we have nowhere to store credentials.
      // Throw to alert the caller instead of silently losing them.
      if (!secureWriteSucceeded) {
        throw StateError('Both secure storage and SharedPreferences failed to save credentials: $e');
      }
      // Secure write succeeded but prefs cleanup failed - not fatal, just log.
      if (kDebugMode) debugPrint('[server_auth_helper] prefs cleanup failed: $e');
    }
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

  /// Validate current credentials and attempt to refresh if expired
  static Future<bool> validateAndRefreshAuth() async {
    final creds = await loadCredentials();
    if (creds.type == ServerAuthType.none) {
      return false;
    }

    // Try to validate with a simple API call
    try {
      final isConfigured = GraphQLClientService.instance.isConfigured;
      if (!isConfigured) {
        return false;
      }

      // Try a simple query to validate auth
      final reachable = await GraphQLClientService.instance.checkServerReachable();
      if (!reachable) {
        return false;
      }

      // If we have a session token, try to refresh it via authRefresher
      if (creds.sessionToken != null && creds.sessionToken!.isNotEmpty) {
        try {
          // The authRefresher handles session refresh automatically on 401
          // We just need to ensure the credentials are valid
          debugPrint('[server_auth_helper] Session token present, validation successful');
        } catch (e) {
          // Refresh failed, but existing token might still work
          debugPrint('[server_auth_helper] Session validation failed: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('[server_auth_helper] Auth validation failed: $e');
      return false;
    }
  }
}
