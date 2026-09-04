import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_qjs/flutter_qjs.dart';

class JsUtils {
  final JavascriptRuntime runtime;

  JsUtils(this.runtime);

  void init() {
    // Extensions call console.log/warn/error for their own debugging, but
    // this was previously discarded entirely, making it impossible to
    // diagnose extension-side issues (e.g. selector/parsing failures) from
    // logs. Forward it to debugPrint so it shows up like any other trace.
    runtime.onMessage('log', (dynamic args) {
      try {
        final List<dynamic> params = args is String ? jsonDecode(args) : args;
        debugPrint('[JS] ${params.join(' ')}');
      } catch (_) {}
      return null;
    });

    runtime.evaluate('''
console.log = function (message) {
    if (typeof message === "object") {
         message = JSON.stringify(message);
    }
    sendMessage("log", JSON.stringify([message.toString()]));
};
console.warn = function (message) {
    if (typeof message === "object") {
         message = JSON.stringify(message);
    }
    sendMessage("log", JSON.stringify([message.toString()]));
};
console.error = function (message) {
    if (typeof message === "object") {
         message = JSON.stringify(message);
    }
    sendMessage("log", JSON.stringify([message.toString()]));
};
String.prototype.substringAfter = function(pattern) {
    const startIndex = this.indexOf(pattern);
    if (startIndex === -1) return this.substring(0);
    const start = startIndex + pattern.length;
    return this.substring(start);
};
String.prototype.substringAfterLast = function(pattern) {
    return this.split(pattern).pop();
};
String.prototype.substringBefore = function(pattern) {
    const endIndex = this.indexOf(pattern);
    if (endIndex === -1) return this.substring(0);
    return this.substring(0, endIndex);
};
String.prototype.substringBeforeLast = function(pattern) {
    const endIndex = this.lastIndexOf(pattern);
    if (endIndex === -1) return this.substring(0);
    return this.substring(0, endIndex);
};
String.prototype.substringBetween = function(left, right) {
    let startIndex = 0;
    let index = this.indexOf(left, startIndex);
    if (index === -1) return "";
    let leftIndex = index + left.length;
    let rightIndex = this.indexOf(right, leftIndex);
    if (rightIndex === -1) return "";
    startIndex = rightIndex + right.length;
    return this.substring(leftIndex, rightIndex);
};
function atob(a) {
    var b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var c = String(a).replace(/=+\$/, "");
    if (c.length % 4 == 1) throw new Error("Invalid base64 string");
    var d = "";
    for (var e = 0, f, g, h = 0; g = c.charAt(h++); ~g && (f = e % 4 ? f * 64 + g : g, e++ % 4) ? d += String.fromCharCode(255 & f >> (-2 * e & 6)) : 0) {
        g = b.indexOf(g);
    }
    return d;
}
function btoa(a) {
    var b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    var c = String(a);
    var d = "";
    for (var e = 0, f, g, h = 0; h < c.length;) {
        f = c.charCodeAt(h++);
        g = c.charCodeAt(h++);
        var i = c.charCodeAt(h++);
        var j = f << 16 | g << 8 | i;
        d += b.charAt(j >> 18 & 63) + b.charAt(j >> 12 & 63) + (isNaN(g) ? "=" : b.charAt(j >> 6 & 63)) + (isNaN(i) ? "=" : b.charAt(j & 63));
    }
    return d;
}
void 0;
''');
  }
}
