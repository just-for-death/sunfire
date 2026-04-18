// ignore_for_file: directives_ordering

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:catalyst/src/features/settings/presentation/server/server_connectivity.dart';
import 'package:catalyst/src/features/settings/presentation/server/widget/client/server_port_tile/server_port_tile.dart';
import 'package:catalyst/src/features/settings/presentation/server/widget/client/server_url_tile/server_url_tile.dart';
import 'package:catalyst/src/l10n/generated/app_localizations.dart';

class _FixedServerUrl extends ServerUrl {
  @override
  String? build() => 'http://127.0.0.1';
}

class _FixedServerPort extends ServerPort {
  @override
  int? build() => 4567;
}

class _FixedServerPortToggle extends ServerPortToggle {
  @override
  bool? build() => true;
}

class _FixedServerPortToggleOff extends ServerPortToggle {
  @override
  bool? build() => false;
}

List<Override> _baseOverrides({
  required Future<http.Response> Function(Uri uri) httpGet,
  ServerPortToggle Function()? portToggle,
}) {
  return [
    serverUrlProvider.overrideWith(_FixedServerUrl.new),
    serverPortProvider.overrideWith(_FixedServerPort.new),
    serverPortToggleProvider.overrideWith(
      portToggle ?? _FixedServerPortToggle.new,
    ),
    serverConnectivityHttpGetProvider.overrideWith((ref) => httpGet),
  ];
}

void main() {
  setUp(() => ServerConnectivity.debugSkipInitialMicrotaskPing = true);
  tearDown(() => ServerConnectivity.debugSkipInitialMicrotaskPing = false);

  group('ServerConnectivity', () {
    Future<ProviderContainer> pumpTestContainer(
      WidgetTester tester,
      List<Override> overrides,
    ) async {
      final container = ProviderContainer(overrides: overrides);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const SizedBox.shrink(),
        ),
      );
      return container;
    }

    testWidgets('HTTP 200 -> online', (tester) async {
      final container = await pumpTestContainer(
        tester,
        _baseOverrides(
          httpGet: (_) async => http.Response('', 200),
        ),
      );
      try {
        await tester.pump();
        expect(
          container.read(serverConnectivityProvider),
          ServerStatus.checking,
        );
        await container.read(serverConnectivityProvider.notifier).checkServer();
        expect(container.read(serverConnectivityProvider), ServerStatus.online);
      } finally {
        container.dispose();
      }
    });

    testWidgets('HTTP 503 -> offline', (tester) async {
      final container = await pumpTestContainer(
        tester,
        _baseOverrides(
          httpGet: (_) async => http.Response('err', 503),
        ),
      );
      try {
        await tester.pump();
        await container.read(serverConnectivityProvider.notifier).checkServer();
        expect(
          container.read(serverConnectivityProvider),
          ServerStatus.offline,
        );
      } finally {
        container.dispose();
      }
    });

    testWidgets('SocketException -> offline', (tester) async {
      final container = await pumpTestContainer(
        tester,
        _baseOverrides(
          httpGet: (_) async => throw const SocketException('test'),
        ),
      );
      try {
        await tester.pump();
        await container.read(serverConnectivityProvider.notifier).checkServer();
        expect(
          container.read(serverConnectivityProvider),
          ServerStatus.offline,
        );
      } finally {
        container.dispose();
      }
    });

    testWidgets('ping omits port when toggle is off', (tester) async {
      Uri? seen;
      final container = await pumpTestContainer(
        tester,
        [
          serverUrlProvider.overrideWith(_FixedServerUrl.new),
          serverPortProvider.overrideWith(_FixedServerPort.new),
          serverPortToggleProvider.overrideWith(_FixedServerPortToggleOff.new),
          serverConnectivityHttpGetProvider.overrideWith(
            (ref) => (uri) async {
              seen = uri;
              return http.Response('', 200);
            },
          ),
        ],
      );
      try {
        await tester.pump();
        await container.read(serverConnectivityProvider.notifier).checkServer();

        expect(seen, isNotNull);
        expect(seen!.hasPort, isFalse);
        expect(container.read(serverConnectivityProvider), ServerStatus.online);
      } finally {
        container.dispose();
      }
    });
  });

  group('ServerAwareWrapper', () {
    testWidgets('shows offline banner when server offline', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(
            httpGet: (_) async => http.Response('', 503),
          ),
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: ServerAwareWrapper(
                child: Text('INNER'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(ServerAwareWrapper)),
      );
      await scope.read(serverConnectivityProvider.notifier).checkServer();
      await tester.pump();

      expect(find.text('INNER'), findsOneWidget);
      expect(find.textContaining('Server offline'), findsOneWidget);
    });

    testWidgets('dismiss hides offline banner', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _baseOverrides(
            httpGet: (_) async => http.Response('', 503),
          ),
          child: MaterialApp(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: ServerAwareWrapper(
                child: Text('INNER'),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final scope = ProviderScope.containerOf(
        tester.element(find.byType(ServerAwareWrapper)),
      );
      await scope.read(serverConnectivityProvider.notifier).checkServer();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(find.textContaining('Server offline'), findsNothing);
      expect(find.text('INNER'), findsOneWidget);
    });
  });
}
