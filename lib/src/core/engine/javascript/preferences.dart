import 'package:flutter_qjs/flutter_qjs.dart';

class JsPreferences {
  final JavascriptRuntime runtime;
  final Map<String, dynamic> _prefs = {
    'pref_popular_content': 1,
    'pref_latest_content': 1,
    'pref_title_lang': 1,
  };

  JsPreferences(this.runtime);

  void init() {
    runtime.onMessage('get_pref', (dynamic args) {
      final key = args is List ? args[0]?.toString() : args?.toString();
      return _prefs[key]?.toString() ?? "";
    });

    runtime.onMessage('getString_pref', (dynamic args) {
      final key = args is List ? args[0]?.toString() : args?.toString();
      final def = args is List && args.length > 1 ? args[1]?.toString() : "";
      return _prefs[key]?.toString() ?? (def ?? "");
    });

    runtime.onMessage('setString_pref', (dynamic args) {
      if (args is List && args.length > 1) {
        _prefs[args[0].toString()] = args[1];
      }
      return null;
    });

    runtime.evaluate('''
class SharedPreferences {
    constructor() {}
    get(key) {
        return sendMessage("get_pref", JSON.stringify([key])) || "";
    }
    getString(key, defaultValue) {
        return sendMessage("getString_pref", JSON.stringify([key, defaultValue || ""])) || (defaultValue || "");
    }
    getInt(key, defaultValue) {
        const val = parseInt(this.get(key));
        return isNaN(val) ? (defaultValue || 0) : val;
    }
    getBool(key, defaultValue) {
        const val = this.get(key);
        if (val === "true" || val === true) return true;
        if (val === "false" || val === false) return false;
        return defaultValue !== undefined ? defaultValue : false;
    }
    setString(key, value) {
        sendMessage("setString_pref", JSON.stringify([key, String(value)]));
    }
}

class Preference {
    constructor() {}
    getPreference(key, def) {
        return def !== undefined && def !== null ? def : '';
    }
}
''');
  }
}
