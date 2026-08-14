// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../utils/misc/toast/toast.dart';
import '../../../../../widgets/custom_circular_progress_indicator.dart';
import '../controller/edit_category_controller.dart';
import 'edit_category_dialog.dart';

class CategoryCreateFab extends HookConsumerWidget {
  const CategoryCreateFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    return FloatingActionButton.extended(
      onPressed: isLoading.value
          ? null
          : () {
              context.showAdaptiveAppDialog(builder: (context) => EditCategoryDialog(
                  createCategory: (newCategory) async {
                    isLoading.value = true;
                    final result = await AsyncValue.guard(
                      () => ref
                          .read(categoryControllerProvider.notifier)
                          .createCategory(newCategory),
                    );
                    // Always clear the spinner, or a failed create leaves the
                    // button disabled for good, and say so when it failed.
                    isLoading.value = false;
                    result.showToastOnError(ref.read(toastProvider));
                  },
                ),
              );
            },
      isExtended: context.isTablet && !isLoading.value,
      label: Text(context.l10n.addCategory),
      icon: isLoading.value
          ? MiniCircularProgressIndicator(color: context.iconColor)
          : const Icon(Icons.add_rounded),
    );
  }
}
