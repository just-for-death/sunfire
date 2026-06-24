import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../global_providers/global_providers.dart';
import '../../../../../utils/extensions/custom_extensions.dart';

const _kReaderCoachMarkShownKey = 'reader_coach_mark_shown';

class ReaderCoachMark extends HookConsumerWidget {
  const ReaderCoachMark({
    super.key,
    required this.chromeVisible,
  });

  final bool chromeVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = useState(false);

    useEffect(() {
      if (chromeVisible) {
        visible.value = false;
        return null;
      }
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs.getBool(_kReaderCoachMarkShownKey) ?? false) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && !chromeVisible) visible.value = true;
      });
      return null;
    }, [chromeVisible]);

    if (!visible.value || chromeVisible) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: context.theme.colorScheme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.readerTapToShowControls,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onInverseSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref
                      .read(sharedPreferencesProvider)
                      .setBool(_kReaderCoachMarkShownKey, true);
                  visible.value = false;
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: context.theme.colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
