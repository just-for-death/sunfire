import 'dart:convert';
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
      } catch (_) {}
      return const ServerAuthCredentials(type: ServerAuthType.basic);
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
    } catch (_) {}

    // Fallback to SharedPreferences if Keychain is restricted / fails
    try {
      final prefs = await SharedPreferences.getInstance();
      final header = prefs.getString(storageKey);
      return ServerAuthCredentials.fromHeaderValue(header);
    } catch (_) {
      return const ServerAuthCredentials(type: ServerAuthType.none);
    }
  }

  static Future<void> saveCredentials(ServerAuthCredentials creds) async {
    final header = creds.toHeaderValue();
    try {
      if (header.isEmpty) {
        await _storage.delete(key: storageKey);
      } else {
        await _storage.write(key: storageKey, value: header);
      }
    } catch (_) {}

    // Mirror to SharedPreferences as resilient fallback
    try {
      final prefs = await SharedPreferences.getInstance();
      if (header.isEmpty) {
        await prefs.remove(storageKey);
      } else {
        await prefs.setString(storageKey, header);
      }
    } catch (_) {}
  }

  static Future<String> getRawAuthHeader() async {
    try {
      final val = await _storage.read(key: storageKey);
      if (val != null && val.isNotEmpty) return val;
    } catch (_) {}

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
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(storageKey);
    } catch (_) {}
  }
}
