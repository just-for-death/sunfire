import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../widgets/settings/settings_subpage_scaffold.dart';
import 'reader_settings_body.dart';

class ReaderSettingsScreen extends ConsumerWidget {
  const ReaderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSubpageScaffold(
      title: context.l10n.reader,
      body: const ReaderSettingsBody(),
    );
  }
}
