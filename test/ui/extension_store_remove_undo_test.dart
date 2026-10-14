import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunfire/src/core/services/settings_service.dart';
import 'package:sunfire/src/core/sync/graphql_client_service.dart';
import 'package:sunfire/src/core/sync/server_capabilities.dart';
import 'package:sunfire/src/features/settings/extension_repos_screen.dart';

const _url = 'https://example.test/repo/index.min.json';

class _FakeGql extends GraphQLClientService {
  _FakeGql() : super.forTesting();
  bool present = true;
  final calls = <String>[];

  @override
  bool get isConfigured => true;

  @override
  Future<ServerCapabilities> probeServerCapabilities({bool force = false}) async =>
      const ServerCapabilities(hasExtensionStores: true, probed: true);

  @override
  Future<Map<String, dynamic>?> query(String document,
      {Map<String, dynamic>? variables, String? label, GraphQLOp? op}) async {
    calls.add(label ?? '');
    switch (label) {
      case 'fetchExtensionStores':
        return {
          'extensionStores': {
            'nodes': [if (present) {'indexUrl': _url, 'name': 'Keiyoushi'}],
          },
        };
      case 'removeExtensionStore':
        present = false;
        return {'removeExtensionStore': {'extensionStore': {'indexUrl': _url}}};
      case 'addExtensionStore':
        present = true;
        return {'addExtensionStore': {'extensionStore': {'indexUrl': _url, 'name': 'Keiyoushi'}}};
    }
    return null;
  }
}

void main() {
  late _FakeGql fake;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.initialize();
    fake = _FakeGql();
    GraphQLClientService.debugInstance = fake;
  });
  tearDown(() => GraphQLClientService.debugInstance = null);

  testWidgets('ISS-099 Remove then Undo re-adds the store', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExtensionReposScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Keiyoushi'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('removeExtensionStore'));
    expect(find.text('Removed Keiyoushi'), findsOneWidget);
    expect(find.text('Keiyoushi'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(fake.calls, contains('addExtensionStore'));
    expect(find.text('Keiyoushi'), findsOneWidget);
  });

  testWidgets('ISS-099 Cancel does not call remove', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExtensionReposScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(fake.calls, isNot(contains('removeExtensionStore')));
    expect(find.text('Keiyoushi'), findsOneWidget);
  });
}
