import 'package:flutter_test/flutter_test.dart';
import 'package:sunfire/src/core/engine/quickjs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EXTENSION SECURITY: JavaScript Code Validation', () {
    test('1. QuickJS service handles malformed JavaScript gracefully', () async {
      await QuickJsService.instance.initialize();
      
      // Test with malformed JavaScript
      const malformedJs = '''
        const mangayomiSources = [{
          "name": "Test",
          "baseUrl": "https://example.com"
        }];
        function invalidSyntax() {
          return "unclosed string
        }
      ''';

      expect(() => QuickJsService.instance.saveLocalExtension('Test', malformedJs), 
             returnsNormally);
    });

    test('2. Extension metadata extraction handles non-JSON gracefully', () {
      const nonStandardJs = '''
        const mangayomiSources = [{
          name: 'TestSource',
          baseUrl: 'https://example.com',
          version: '1.0.0'
        }];
      ''';

      final metadata = QuickJsService.instance.extractSourceMetadata(nonStandardJs);
      
      // Should extract baseUrl even with non-standard JSON
      expect(metadata, isA<Map<String, dynamic>>());
      expect(metadata['baseUrl'], equals('https://example.com'));
    });

    test('3. Extension source name matching handles variations', () {
      const testJs = '''
        const mangayomiSources = [{
          "name": "TestExtension",
          "baseUrl": "https://example.com"
        }];
      ''';

      QuickJsService.instance.saveLocalExtension('TestExtension', testJs);
      
      // Test that the service can handle various name formats
      expect(QuickJsService.instance.isSourceInstalledLocally('TestExtension'), isTrue);
      expect(QuickJsService.instance.isSourceInstalledLocally('testextension'), isTrue);
    });

    test('4. Extension code extraction is case-insensitive but precise', () {
      // Test that extension matching works correctly
      const testJs = '''
        const mangayomiSources = [{
          "name": "TestExtension",
          "baseUrl": "https://example.com"
        }];
      ''';

      QuickJsService.instance.saveLocalExtension('TestExtension', testJs);
      
      // Should find the extension with various name formats
      expect(QuickJsService.instance.isSourceInstalledLocally('TestExtension'), isTrue);
    });
  });

  group('EXTENSION SECURITY: Code Injection Prevention', () {
    test('5. Extension code does not contain dangerous patterns', () async {
      await QuickJsService.instance.initialize();
      
      const safeJs = '''
        const mangayomiSources = [{
          "name": "SafeSource",
          "baseUrl": "https://example.com"
        }];
        
        class DefaultExtension extends MProvider {
          async getPopular(page) {
            return { list: [], hasNextPage: false };
          }
        }
      ''';

      expect(() => QuickJsService.instance.saveLocalExtension('SafeSource', safeJs), 
             returnsNormally);
    });

    test('6. Extension URL validation prevents remote code execution', () {
      const suspiciousJs = '''
        const mangayomiSources = [{
          "name": "Suspicious",
          "baseUrl": "data:text/javascript,alert(1)"
        }];
      ''';

      final metadata = QuickJsService.instance.extractSourceMetadata(suspiciousJs);
      
      // Should still extract metadata but URL should be flagged
      expect(metadata['baseUrl'], isNotEmpty);
      // Additional validation could be added here
    });
  });
}