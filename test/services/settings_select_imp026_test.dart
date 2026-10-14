// IMP-026: per-key SettingsService listenables notify only on their key.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';

void main() {
  late SettingsService s;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SettingsService.debugResetInstance();
    s = SettingsService.instance;
    await s.initialize();
  });

  test('notifies only when the selected value changes', () {
    final cbz = s.select('downloadAsCbz', (x) => x.downloadAsCbz);
    var hits = 0;
    cbz.addListener(() => hits++);
    s.updateSkipCompleted = true; // unrelated key
    expect(hits, 0);
    s.downloadAsCbz = true;
    expect(hits, 1);
    expect(cbz.value, isTrue);
    s.downloadAsCbz = true; // same value
    expect(hits, 1);
  });

  test('cached per key; collections compare element-wise', () async {
    final a = s.select('root', (x) => x.localSourceRoot);
    expect(identical(a, s.select('root', (x) => x.localSourceRoot)), isTrue);
    expect(s.debugSelectorCount, 1);

    final list = s.select('both', (x) => [x.updateSkipCompleted, x.updateSkipWithUnread]);
    var hits = 0;
    list.addListener(() => hits++);
    s.downloadAsCbz = true; // a fresh but equal list must not notify
    expect(hits, 0);
    s.updateSkipWithUnread = true;
    expect(hits, 1);
    expect(list.value, [false, true]);
  });
}
