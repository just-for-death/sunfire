// test/ocr_tts_test.dart
//
// R9.3/R9.4: OCR models + TTS helpers (plugin-free).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/features/reader/controller/ocr_service.dart';
import 'package:sunfire/src/features/reader/controller/tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('R9.3 OcrPageResult', () {
    test('fromJson filters empty blocks', () {
      final result = OcrPageResult.fromJson({
        'script': 'japanese',
        'blocks': [
          {'text': '  ', 'left': 0, 'top': 0, 'right': 1, 'bottom': 1},
          {'text': 'こんにちは', 'left': 1, 'top': 2, 'right': 3, 'bottom': 4},
        ],
      });
      expect(result.blocks.length, 1);
      expect(result.blocks.first.text, 'こんにちは');
      expect(result.script, OcrScript.japanese);
    });

    test('fullText joins blocks', () {
      const result = OcrPageResult(blocks: [
        OcrTextBlock(text: 'a', left: 0, top: 0, right: 1, bottom: 1),
        OcrTextBlock(text: 'b', left: 0, top: 0, right: 1, bottom: 1),
      ], script: OcrScript.latin);
      expect(result.fullText, 'a\nb');
      expect(result.isEmpty, isFalse);
      expect(OcrPageResult.empty(OcrScript.latin).isEmpty, isTrue);
    });

    test('round-trips through JSON', () {
      const original = OcrPageResult(blocks: [
        OcrTextBlock(text: 'x', left: 1, top: 2, right: 3, bottom: 4),
      ], script: OcrScript.korean);
      final back = OcrPageResult.fromJson(
          Map<String, dynamic>.from(
              (original.toJson() as Map).map((k, v) => MapEntry('$k', v))));
      expect(back.blocks.length, 1);
      expect(back.blocks.first.right, 3);
      expect(back.script, OcrScript.korean);
    });

    test('rejects unknown version shape gracefully', () {
      final result = OcrPageResult.fromJson({'nonsense': true});
      expect(result.isEmpty, isTrue);
    });

    test('cacheKey differs by script', () {
      expect(
          OcrService.cacheKey('/a.png', OcrScript.japanese),
          isNot(OcrService.cacheKey('/a.png', OcrScript.latin)));
    });

    test('default script is japanese', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await OcrService.instance.getScript(), OcrScript.japanese);
    });

    test('setScript persists and clears memory cache', () async {
      SharedPreferences.setMockInitialValues({});
      await OcrService.instance.setScript(OcrScript.korean);
      expect(await OcrService.instance.getScript(), OcrScript.korean);
      await OcrService.instance.setScript(OcrScript.japanese);
    });
  });

  group('R9.4 TtsService', () {
    test('languageForScript maps scripts to BCP-47', () {
      expect(TtsService.languageForScript('japanese'), 'ja-JP');
      expect(TtsService.languageForScript('korean'), 'ko-KR');
      expect(TtsService.languageForScript('chinese'), 'zh-CN');
      expect(TtsService.languageForScript('devanagiri'), 'hi-IN');
      expect(TtsService.languageForScript('latin'), 'en-US');
      expect(TtsService.languageForScript('unknown'), 'en-US');
    });

    test('default rate is 0.5', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await TtsService.instance.getRate(), 0.5);
    });

    test('setRate clamps and persists', () async {
      SharedPreferences.setMockInitialValues({});
      await TtsService.instance.setRate(99);
      expect(await TtsService.instance.getRate(), 1.0);
      await TtsService.instance.setRate(-5);
      expect(await TtsService.instance.getRate(), 0.1);
      await TtsService.instance.setRate(0.5);
    });
  });
}
