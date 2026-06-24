import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/launch_url_in_web.dart';
import '../../../../../utils/misc/toast/toast.dart';

class MediaLaunchButton extends StatelessWidget {
  const MediaLaunchButton({
    super.key,
    required this.toast,
    required this.title,
    required this.icon,
    required this.url,
  });

  final Toast? toast;
  final String title;
  final FaIconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return url.isNotBlank
        ? context.isSmallTabletOrLess
            ? IconButton(
                tooltip: title,
                onPressed: () => launchUrlInWeb(context, url, toast),
                icon: FaIcon(icon),
              )
            : TextButton.icon(
                label: Text(title),
                onPressed: () => launchUrlInWeb(context, url, toast),
                icon: FaIcon(icon),
              )
        : const SizedBox.shrink();
  }
}
