// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/catalyst_app.dart';
import 'src/features/about/presentation/about/controllers/about_controller.dart';
import 'src/features/settings/data/basic_credentials_store.dart';
import 'src/global_providers/global_providers.dart';
import 'src/utils/platform/mobile_permissions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  final sharedPreferences = await SharedPreferences.getInstance();
  await BasicCredentialsStore.instance.init(sharedPreferences);
  await initHiveForFlutter();

  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  unawaited(MobilePermissions.requestNotificationsOnStartup());
  runApp(
    ProviderScope(
      overrides: [
        packageInfoProvider.overrideWithValue(packageInfo),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveStoreProvider.overrideWithValue(HiveStore())
      ],
      child: const CatalystApp(),
    ),
  );
}
