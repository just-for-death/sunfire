import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String log = "Starting tests...\n";

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _runTests() async {
    MClient.cfProxyUrl = "http://100.85.171.6:8191/v1";
    await QuickJsService.instance.initialize();
    
    final extDir = Directory('/home/zoro/Documents/Projects/mangayomi-extensions/javascript/manga/src/en');
    final files = extDir.listSync().where((f) => f.path.endsWith('.js')).toList();
    
    for (final file in files) {
      try {
        final code = File(file.path).readAsStringSync();
        final name = file.path.split('/').last.replaceAll('.js', '');
        _log("\n=================================");
        _log("Testing Extension: \$name");
        _log("=================================");
        
        // Wait 1 second between tests to avoid spamming
        await Future.delayed(const Duration(seconds: 1));

        final popData = await QuickJsService.instance.evaluatePopular(code, 1);
        final list = popData['list'] as List<dynamic>? ?? [];
        _log("  [+] Popular List Length: \${list.length}");
        
        if (list.isNotEmpty) {
          final first = list.first;
          final link = first['link'];
          _log("  [+] First Manga: \${first['name']}");
          _log("  [+] Cover URL: \${first['imageUrl']}");
          
          final details = await QuickJsService.instance.evaluateDetail(code, link);
          final chapters = details['chapters'] as List<dynamic>? ?? [];
          _log("  [+] Details Chapters: \${chapters.length}");
          
          if (chapters.isNotEmpty) {
            final chLink = chapters.first['url'];
            _log("  [+] First Chapter URL: \$chLink");
            final pages = await QuickJsService.instance.evaluatePageList(code, chLink);
            _log("  [+] Pages Found: \${pages.length}");
            if (pages.isNotEmpty) {
               _log("  [+] First Page URL: \${pages.first['url']}");
            }
          }
        }
      } catch (e) {
        _log("  [-] Error testing extension: \$e");
      }
    }
    _log("\nTests finished.");
  }

  void _log(String msg) {
    print(msg);
    if (mounted) {
      setState(() {
        log += msg + "\n";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Extension Tester')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(log),
          ),
        ),
      ),
    );
  }
}
