import 'package:catalyst/src/features/library/presentation/library/controller/library_controller.dart';
import 'package:catalyst/src/global_providers/global_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The library filter checkboxes are tri-state, so "exclude" (`false`) has to
/// survive a provider rebuild and an app restart the same way `true` does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> containerWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('stored filter values are read back unchanged', () {
    test('unread: true', () async {
      final container = await containerWith({'mangaFilterUnread': true});
      addTearDown(container.dispose);

      expect(container.read(libraryMangaFilterUnreadProvider), isTrue);
    });

    test('unread: false is kept, not reset to off', () async {
      final container = await containerWith({'mangaFilterUnread': false});
      addTearDown(container.dispose);

      expect(container.read(libraryMangaFilterUnreadProvider), isFalse);
    });

    test('downloaded: false is kept', () async {
      final container = await containerWith({'mangaFilterDownloaded': false});
      addTearDown(container.dispose);

      expect(container.read(libraryMangaFilterDownloadedProvider), isFalse);
    });

    test('completed: false is kept', () async {
      final container = await containerWith({'mangaFilterCompleted': false});
      addTearDown(container.dispose);

      expect(container.read(libraryMangaFilterCompletedProvider), isFalse);
    });

    test('nothing stored means the filter is off', () async {
      final container = await containerWith({});
      addTearDown(container.dispose);

      expect(container.read(libraryMangaFilterUnreadProvider), isNull);
    });
  });

  test('setting a filter to false persists it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    container.read(libraryMangaFilterUnreadProvider.notifier).update(false);
    await Future<void>.delayed(Duration.zero);

    expect(
      prefs.getBool('mangaFilterUnread'),
      isFalse,
      reason: 'the excluded state must reach storage',
    );

    // A fresh container stands in for restarting the app.
    final restarted = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(restarted.dispose);

    expect(restarted.read(libraryMangaFilterUnreadProvider), isFalse);
  });

  test('clearing a filter removes it from storage', () async {
    SharedPreferences.setMockInitialValues({'mangaFilterUnread': true});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    container.read(libraryMangaFilterUnreadProvider.notifier).update(null);
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getBool('mangaFilterUnread'), isNull);
  });
}
