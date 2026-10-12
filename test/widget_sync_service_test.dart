// test/widget_sync_service_test.dart
//
// A7.4: Continue Reading widget state persistence.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/sync/widget_sync_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('updateContinueReading persists all keys', () async {
    await WidgetSyncService.instance.updateContinueReading(
      mangaTitle: 'Berserk',
      chapterName: 'Ch 1',
      mangaId: 7,
      chapterId: 99,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('widget_title'), 'Berserk');
    expect(prefs.getString('widget_subtitle'), 'Ch 1');
    expect(prefs.getInt('widget_manga_id'), 7);
    expect(prefs.getInt('widget_chapter_id'), 99);
    expect(prefs.getInt('widget_updated_at'), isNotNull);
  });

  test('clear removes all keys', () async {
    await WidgetSyncService.instance.updateContinueReading(
      mangaTitle: 'Berserk',
      chapterName: 'Ch 1',
      mangaId: 7,
      chapterId: 99,
    );
    await WidgetSyncService.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('widget_title'), isNull);
    expect(prefs.getInt('widget_chapter_id'), isNull);
  });
}
