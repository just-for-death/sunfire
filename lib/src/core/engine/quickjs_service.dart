import 'dart:convert';
import 'package:flutter_qjs/flutter_qjs.dart';
import '../logging/logger_service.dart';

class QuickJsService {
  static QuickJsService? _instance;
  FlutterQjs? _engine;

  QuickJsService._();

  static QuickJsService get instance {
    _instance ??= QuickJsService._();
    return _instance!;
  }

  void initialize() {
    _engine = FlutterQjs(
      stackSize: 1024 * 1024,
    );
    _engine!.dispatch();
  }

  Future<Map<String, dynamic>> evaluateExtensionScript(String jsCode, String functionName, List<dynamic> args) async {
    try {
      final script = '''
        (function() {
          $jsCode
          if (typeof $functionName === 'function') {
            return JSON.stringify($functionName(${args.map((a) => jsonEncode(a)).join(', ')}));
          }
          return JSON.stringify({ error: 'Function $functionName not found' });
        })();
      ''';

      final rawResult = await _engine!.evaluate(script);
      final jsonStr = rawResult.toString();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e, stack) {
      await LoggerService.instance.logError('QuickJS Evaluation error in $functionName: $e', exception: e, stackTrace: stack, category: 'QuickJS');
      return {'error': e.toString()};
    }
  }

  void dispose() {
    _engine?.close();
    _engine = null;
  }
}
