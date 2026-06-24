import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import 'ios/ios_reader_settings_screen.dart';
import 'reader_settings_body.dart';

class ReaderSettingsScreen extends ConsumerWidget {
  const ReaderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb && Platform.isIOS) {
      return const IOSReaderSettingsScreen();
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reader)),
      body: const ReaderSettingsBody(),
    );
  }
}
