import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/db/models/chapter.dart';
import 'package:sunfire/src/core/db/models/manga.dart';
import 'package:sunfire/src/core/engine/local_source_service.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/features/browse/local_source_screen.dart';

class _Store implements LocalLibraryStore {
  final List<Manga> items;
  _Store(this.items);
  @override
  Future<List<Manga>> allManga() async => items;
  @override
  Future<Manga?> mangaByServerId(int serverId) async => null;
  @override
  Future<void> saveManga(Manga manga) async {}
  @override
  Future<List<Chapter>> chaptersFor(int mangaKey) async => [];
  @override
  Future<void> saveChapters(List<Chapter> chapters) async {}
  @override
  Future<void> deleteChapters(List<Chapter> chapters) async {}
}

void main() {
  tearDown(() => LocalSourceService.instance.debugReset());

  testWidgets('IMP-002 empty state without a folder', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    LocalSourceService.instance.debugStore = _Store([]);
    await tester.pumpWidget(const MaterialApp(home: LocalSourceScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Pick a folder to get started'), findsOneWidget);
    expect(find.byKey(const ValueKey('localRescan')), findsNothing);
  });

  testWidgets('IMP-002 lists local series', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    await LocalSourceService.instance.setRoot('/tmp/manga');
    LocalSourceService.instance.debugStore = _Store([
      Manga()
        ..serverId = -5
        ..title = 'Local One'
        ..sourceName = kLocalSourceName,
    ]);
    await tester.pumpWidget(const MaterialApp(home: LocalSourceScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Local One'), findsOneWidget);
    expect(find.text('/tmp/manga'), findsOneWidget);
    expect(find.byKey(const ValueKey('localRescan')), findsOneWidget);
  });
}
