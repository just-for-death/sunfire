// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:catalyst/src/theme/catalyst_component_themes.dart';
import 'package:catalyst/src/theme/catalyst_typography.dart';
import 'package:catalyst/src/theme/catalyst_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _theme({
  Brightness brightness = Brightness.dark,
  bool isTrueBlack = false,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3F51B5),
    brightness: brightness,
  );
  return buildCatalystTheme(
    base: ThemeData(colorScheme: scheme, useMaterial3: true),
    scheme: scheme,
    isTrueBlack: isTrueBlack,
  );
}

/// Renders the components whose themes are configured in
/// [buildCatalystTheme]. Material asserts several theme/widget combinations
/// only at build time, so exercising them here keeps the theme honest.
Widget _gallery(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catalyst'),
          bottom: const TabBar(tabs: [Tab(text: 'One'), Tab(text: 'Two')]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.book), label: 'Library'),
            NavigationDestination(icon: Icon(Icons.explore), label: 'Browse'),
          ],
          onDestinationSelected: (_) {},
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              labelType: NavigationRailLabelType.none,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text('Library'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore),
                  label: Text('Browse'),
                ),
              ],
              selectedIndex: 0,
            ),
            const Expanded(
              child: Column(
                children: [
                  Card(child: ListTile(title: Text('Tile'))),
                  Chip(label: Text('Chip')),
                  Divider(),
                  LinearProgressIndicator(value: 0.5),
                  Slider(value: 0.5, onChanged: null),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('buildCatalystTheme', () {
    testWidgets('renders themed components without assertions', (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(_gallery(_theme(brightness: brightness)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('collapsed rail uses labels like the tablet shell',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Scaffold(
            body: NavigationRail(
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text('Library'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore),
                  label: Text('Browse'),
                ),
              ],
              selectedIndex: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Library'), findsOneWidget);
    });

    test('true black only darkens the dark scheme', () {
      final dark = _theme(isTrueBlack: true);
      final light = _theme(brightness: Brightness.light, isTrueBlack: true);

      expect(dark.scaffoldBackgroundColor, Colors.black);
      expect(light.scaffoldBackgroundColor, isNot(Colors.black));
    });

    test('applies the Catalyst type scale and shapes', () {
      final theme = _theme();

      expect(
        theme.textTheme.bodyMedium?.fontSize,
        CatalystTypography.textTheme.bodyMedium?.fontSize,
      );
      expect(
        theme.cardTheme.shape,
        const RoundedRectangleBorder(borderRadius: CatalystUiTokens.cardRadius),
      );
      expect(theme.appBarTheme.elevation, CatalystUiTokens.elevationFlat);
    });
  });
}
