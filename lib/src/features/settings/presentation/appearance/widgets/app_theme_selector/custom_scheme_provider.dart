import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../constants/db_keys.dart';
import '../../../../../../global_providers/global_providers.dart';

/// Legacy custom scheme names from earlier app versions.
const _legacySchemeAliases = <String, String>{
  'Tachiyomi': 'Classic Crimson',
};

String? _migrateSavedScheme(SharedPreferences prefs) {
  final saved = prefs.getString(DBKeys.customFlexScheme.name);
  if (saved == null) return null;
  final migrated = _legacySchemeAliases[saved] ?? saved;
  if (migrated != saved) {
    prefs.setString(DBKeys.customFlexScheme.name, migrated);
  }
  return migrated;
}

class CustomFlexSchemeNotifier extends StateNotifier<String?> {
  CustomFlexSchemeNotifier(this._prefs) : super(_migrateSavedScheme(_prefs));

  final SharedPreferences _prefs;

  void updateScheme(String? schemeName) {
    state = schemeName;
    if (schemeName == null) {
      _prefs.remove(DBKeys.customFlexScheme.name);
    } else {
      _prefs.setString(DBKeys.customFlexScheme.name, schemeName);
    }
  }
}

final customFlexSchemeProvider =
    StateNotifierProvider<CustomFlexSchemeNotifier, String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CustomFlexSchemeNotifier(prefs);
});
