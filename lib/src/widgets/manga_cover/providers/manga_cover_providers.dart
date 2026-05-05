// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/db_keys.dart';
import '../../../global_providers/global_providers.dart';

class _BoolPrefNotifier extends StateNotifier<bool?> {
  _BoolPrefNotifier(this._prefs, this._key, this._fallback)
      : super(_prefs.getBool(_key.name) ?? _fallback);

  final SharedPreferences _prefs;
  final DBKeys _key;
  final bool _fallback;

  void update(bool? value) {
    state = value ?? _fallback;
    _prefs.setBool(_key.name, state ?? _fallback);
  }
}

final downloadedBadgeProvider =
    StateNotifierProvider<_BoolPrefNotifier, bool?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return _BoolPrefNotifier(
    prefs,
    DBKeys.downloadedBadge,
    DBKeys.downloadedBadge.initial as bool,
  );
});

final unreadBadgeProvider = StateNotifierProvider<_BoolPrefNotifier, bool?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return _BoolPrefNotifier(
    prefs,
    DBKeys.unreadBadge,
    DBKeys.unreadBadge.initial as bool,
  );
});

final languageBadgeProvider =
    StateNotifierProvider<_BoolPrefNotifier, bool?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return _BoolPrefNotifier(
    prefs,
    DBKeys.languageBadge,
    DBKeys.languageBadge.initial as bool,
  );
});

final sourceBadgeProvider = StateNotifierProvider<_BoolPrefNotifier, bool?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return _BoolPrefNotifier(
    prefs,
    DBKeys.sourceBadge,
    DBKeys.sourceBadge.initial as bool,
  );
});
