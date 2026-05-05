import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../constants/db_keys.dart';
import '../../../../../../global_providers/global_providers.dart';

class CustomFlexSchemeNotifier extends StateNotifier<String?> {
  CustomFlexSchemeNotifier(this._prefs)
      : super(_prefs.getString(DBKeys.customFlexScheme.name));

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
