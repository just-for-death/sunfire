import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';
import 'package:sunfire/src/core/engine/javascript/m_client.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Test extensions extensively', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    MClient.cfProxyUrl = "http://100.85.171.6:8191/v1";
    await QuickJsService.instance.initialize();
    
    final extDir = Directory('/home/zoro/Documents/Projects/mangayomi-extensions/javascript/manga/src/en');
    final files = extDir.listSync().where((f) => f.path.endsWith('.js')).toList();
    
    for (final file in files) {
      try {
        final code = File(file.path).readAsStringSync();
        final name = file.path.split('/').last.replaceAll('.js', '');
        print("=================================");
        print("Testing Extension: \$name");
        print("=================================");
        
        final popData = await QuickJsService.instance.evaluatePopular(code, 1);
        final list = popData['list'] as List<dynamic>? ?? [];
        print("  [+] Popular List Length: \${list.length}");
        
        if (list.isNotEmpty) {
          final first = list.first;
          final link = first['link'];
          print("  [+] First Manga: \${first['name']}");
          print("  [+] Cover URL: \${first['imageUrl']}");
          
          final details = await QuickJsService.instance.evaluateDetail(code, link);
          final chapters = details['chapters'] as List<dynamic>? ?? [];
          print("  [+] Details Chapters: \${chapters.length}");
          
          if (chapters.isNotEmpty) {
            final chLink = chapters.first['url'];
            print("  [+] First Chapter URL: \$chLink");
            final pages = await QuickJsService.instance.evaluatePageList(code, chLink);
            print("  [+] Pages Found: \${pages.length}");
            if (pages.isNotEmpty) {
               print("  [+] First Page URL: \${pages.first['url']}");
            }
          }
        }
      } catch (e) {
        print("  [-] Error testing extension: \$e");
      }
    }
  });
}
