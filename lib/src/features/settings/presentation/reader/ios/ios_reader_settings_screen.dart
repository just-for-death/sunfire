// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import 'reader_settings_body.dart';

class IOSReaderSettingsScreen extends StatelessWidget {
  const IOSReaderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return CupertinoPageScaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        middle: Text(context.l10n.reader),
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.72)
            : Colors.white.withValues(alpha: 0.72),
      ),
      child: const SafeArea(
        child: ReaderSettingsBody(),
      ),
    );
  }
}
