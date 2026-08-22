import 'dart:convert';
import 'package:flutter_qjs/flutter_qjs.dart';

class JsMProvider {
  final JavascriptRuntime runtime;

  JsMProvider(this.runtime);

  void init(Map<String, dynamic> sourceMap) {
    final sourceJson = jsonEncode(sourceMap);

    runtime.evaluate('''
class MProvider {
    get source() {
        return $sourceJson;
    }
    get supportsLatest() {
        return true;
    }
    getHeaders(url) {
        return {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Referer": this.source.baseUrl || ""
        };
    }
    async getPopular(page) {
        throw new Error("getPopular not implemented");
    }
    async getLatestUpdates(page) {
        throw new Error("getLatestUpdates not implemented");
    }
    async search(query, page, filters) {
        throw new Error("search not implemented");
    }
    async getDetail(url) {
        throw new Error("getDetail not implemented");
    }
    async getPageList(url) {
        throw new Error("getPageList not implemented");
    }
    getFilterList() {
        return [];
    }
    getSourcePreferences() {
        return [];
    }
}

async function jsonStringify(fn) {
    return JSON.stringify(await fn());
}
''');
  }
}
