import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../routes/router_config.dart';
import '../../../../utils/extensions/custom_extensions.dart';
import 'ios/ios_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return const IOSSettingsScreen();
    }
    return const _AndroidSettingsScreen();
  }
}

class _AndroidSettingsScreen extends StatelessWidget {
  const _AndroidSettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(context.l10n.general),
            leading: const Icon(Icons.tune_rounded),
            onTap: () => const GeneralSettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.appearance),
            leading: const Icon(Icons.color_lens_rounded),
            onTap: () => const AppearanceSettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.library),
            leading: const Icon(Icons.collections_bookmark_rounded),
            onTap: () => const LibrarySettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.downloads),
            leading: const Icon(Icons.download_rounded),
            onTap: () => const DownloadsSettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.reader),
            leading: const Icon(Icons.chrome_reader_mode_rounded),
            onTap: () => const ReaderSettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.browse),
            leading: const Icon(Icons.explore_rounded),
            onTap: () => const BrowseSettingsRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.backup),
            leading: const Icon(Icons.settings_backup_restore_rounded),
            onTap: () => const BackupRoute().go(context),
          ),
          ListTile(
            title: Text(context.l10n.server),
            leading: const Icon(Icons.computer_rounded),
            onTap: () => const ServerSettingsRoute().go(context),
          ),
          ListTile(
            title: const Text('Trackers'),
            leading: const Icon(Icons.track_changes_rounded),
            onTap: () => const TrackerSettingsRoute().go(context),
          ),
        ],
      ),
    );
  }
}
