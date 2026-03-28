import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/gen/assets.gen.dart';
import '../../../../../routes/router_config.dart';
import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../widgets/shell/ios/glass_app_bar.dart';

class IOSSettingsScreen extends StatelessWidget {
  const IOSSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cs = context.theme.colorScheme;
    final bg = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          GlassSliverAppBar(title: context.l10n.settings),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // App icon + name header
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ImageIcon(
                            AssetImage(Assets.icons.darkIcon.path),
                            size: 72,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.appTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // General group
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.gear_alt_fill,
                      iconColor: Colors.grey,
                      title: context.l10n.general,
                      onTap: () => const GeneralSettingsRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.paintbrush_fill,
                      iconColor: Colors.pink,
                      title: context.l10n.appearance,
                      onTap: () =>
                          const AppearanceSettingsRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.book_fill,
                      iconColor: Colors.orange,
                      title: context.l10n.library,
                      onTap: () => const LibrarySettingsRoute().go(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Content group
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.arrow_down_circle_fill,
                      iconColor: Colors.blue,
                      title: context.l10n.downloads,
                      onTap: () =>
                          const DownloadsSettingsRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.book_circle_fill,
                      iconColor: Colors.purple,
                      title: context.l10n.reader,
                      onTap: () => const ReaderSettingsRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.compass_fill,
                      iconColor: Colors.teal,
                      title: context.l10n.browse,
                      onTap: () => const BrowseSettingsRoute().go(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Data group
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.arrow_2_circlepath,
                      iconColor: Colors.green,
                      title: context.l10n.backup,
                      onTap: () => const BackupRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.antenna_radiowaves_left_right,
                      iconColor: Colors.indigo,
                      title: context.l10n.server,
                      onTap: () => const ServerSettingsRoute().go(context),
                    ),
                    _SettingsTile(
                      icon: CupertinoIcons.chart_bar_fill,
                      iconColor: Colors.cyan,
                      title: 'Trackers',
                      onTap: () => const TrackerSettingsRoute().go(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // About group
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: CupertinoIcons.info_circle_fill,
                      iconColor: Colors.blue,
                      title: context.l10n.about,
                      onTap: () => const AboutRoute().go(context),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 52,
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final subColor = (isDark ? Colors.white : Colors.black).withOpacity(0.45);

    return CupertinoListTile(
      onTap: onTap,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_right,
        size: 15,
        color: subColor,
      ),
    );
  }
}
