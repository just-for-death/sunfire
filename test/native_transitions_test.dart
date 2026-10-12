// test/native_transitions_test.dart
//
// I8.1: platform-aware page transitions.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sunfire/src/app.dart'
    show sunfireTransitionPage, isCupertinoPlatform;

GoRouter testRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
            path: '/', builder: _home),
        GoRoute(
          path: '/next',
          pageBuilder: (c, s) =>
              sunfireTransitionPage(state: s, child: const Text('next')),
        ),
      ],
    );

Widget _home(BuildContext c, GoRouterState s) => const Text('home');

void main() {
  testWidgets('isCupertinoPlatform reflects platform', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    var cupertino = false;
    await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
      cupertino = isCupertinoPlatform(c);
      return const SizedBox();
    })));
    expect(cupertino, isTrue);
    debugDefaultTargetPlatformOverride = null;

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
      cupertino = isCupertinoPlatform(c);
      return const SizedBox();
    })));
    expect(cupertino, isFalse);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android /next transition uses Fade+Slide', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final router = testRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    unawaited(router.push('/next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        find.ancestor(
            of: find.text('next'),
            matching: find.byType(FadeTransition)),
        findsOneWidget);
    expect(
        find.ancestor(
            of: find.text('next'),
            matching: find.byType(CupertinoPageTransition)),
        findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS /next transition uses CupertinoPageTransition',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final router = testRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    unawaited(router.push('/next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        find.ancestor(
            of: find.text('next'),
            matching: find.byType(CupertinoPageTransition)),
        findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
