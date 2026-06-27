// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/catalyst_app.dart';
import 'src/features/about/presentation/about/controllers/about_controller.dart';
import 'src/features/notifications/notification_service.dart';
import 'src/features/settings/data/basic_credentials_store.dart';
import 'src/global_providers/global_providers.dart';
import 'src/utils/platform/mobile_permissions.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final packageInfo = await PackageInfo.fromPlatform();
  final sharedPreferences = await SharedPreferences.getInstance();
  try {
    await BasicCredentialsStore.instance
        .init(sharedPreferences)
        .timeout(const Duration(seconds: 5));
  } catch (e, st) {
    debugPrint('BasicCredentialsStore init failed: $e\n$st');
  }
  try {
    await initHiveForFlutter().timeout(const Duration(seconds: 10));
  } catch (e, st) {
    debugPrint('Hive init failed: $e\n$st');
  }

  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  unawaited(MobilePermissions.requestNotificationsOnStartup());
  runApp(
    ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveStoreProvider.overrideWithValue(HiveStore()),
      ],
      child: const _AppRoot(),
    ),
  );
  unawaited(_initNotificationsDeferred());
}

Future<void> _initNotificationsDeferred() async {
  try {
    await NotificationService.instance
        .init()
        .timeout(const Duration(seconds: 8));
  } catch (e, st) {
    debugPrint('NotificationService init failed: $e\n$st');
  }
}

/// Removes the native splash after the first frame so release builds cannot
/// hang indefinitely on the launch screen if startup is slow.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  Timer? _splashFallback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _removeSplash());
    _splashFallback = Timer(const Duration(seconds: 12), _removeSplash);
  }

  void _removeSplash() {
    _splashFallback?.cancel();
    _splashFallback = null;
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _splashFallback?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const CatalystApp();
}
