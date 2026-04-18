// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/db_keys.dart';

/// Persists the HTTP `Authorization` header value for Suwayomi Basic auth.
///
/// Values written by older builds under [DBKeys.basicCredentials] in
/// SharedPreferences are migrated once into the platform secure store.
///
/// On Linux (and other platforms), if the OS keyring / libsecret is unavailable
/// or cannot be unlocked, reads and writes fall back to SharedPreferences under
/// [_prefsFallbackKey] so the app can still start.
class BasicCredentialsStore {
  BasicCredentialsStore._();

  static final BasicCredentialsStore instance = BasicCredentialsStore._();

  static const _secureKey = 'basic_auth_header';
  static const _prefsFallbackKey = 'basic_auth_header_insecure';

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  late SharedPreferences _prefs;
  bool _useInsecurePrefs = false;
  String? _current;

  String? get current => _current;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    String? value;

    try {
      value = await _secure.read(key: _secureKey);
    } on PlatformException catch (e) {
      debugPrint(
        'BasicCredentialsStore: secure storage unavailable (${e.message}); '
        'using SharedPreferences fallback.',
      );
      _useInsecurePrefs = true;
    }

    if (!_useInsecurePrefs) {
      if (value == null || value.isEmpty) {
        final legacy = prefs.getString(DBKeys.basicCredentials.name);
        if (legacy != null && legacy.isNotEmpty) {
          try {
            await _secure.write(key: _secureKey, value: legacy);
            await prefs.remove(DBKeys.basicCredentials.name);
            value = legacy;
          } on PlatformException catch (e) {
            debugPrint(
              'BasicCredentialsStore: could not migrate to secure storage '
              '(${e.message}); using SharedPreferences fallback.',
            );
            _useInsecurePrefs = true;
            await prefs.setString(_prefsFallbackKey, legacy);
            await prefs.remove(DBKeys.basicCredentials.name);
            value = legacy;
          }
        }
      }
    } else {
      value = prefs.getString(_prefsFallbackKey);
      if (value == null || value.isEmpty) {
        final legacy = prefs.getString(DBKeys.basicCredentials.name);
        if (legacy != null && legacy.isNotEmpty) {
          await prefs.setString(_prefsFallbackKey, legacy);
          await prefs.remove(DBKeys.basicCredentials.name);
          value = legacy;
        }
      }
    }

    _current = (value == null || value.isEmpty) ? null : value;
  }

  Future<void> set(String? value) async {
    final normalized =
        (value == null || value.isEmpty) ? null : value;
    _current = normalized;

    if (_useInsecurePrefs) {
      if (normalized == null) {
        await _prefs.remove(_prefsFallbackKey);
      } else {
        await _prefs.setString(_prefsFallbackKey, normalized);
      }
      return;
    }

    try {
      if (normalized == null) {
        await _secure.delete(key: _secureKey);
      } else {
        await _secure.write(key: _secureKey, value: normalized);
      }
    } on PlatformException catch (e) {
      debugPrint(
        'BasicCredentialsStore: secure storage write failed (${e.message}); '
        'using SharedPreferences fallback.',
      );
      _useInsecurePrefs = true;
      if (normalized == null) {
        await _prefs.remove(_prefsFallbackKey);
      } else {
        await _prefs.setString(_prefsFallbackKey, normalized);
      }
    }
  }
}
