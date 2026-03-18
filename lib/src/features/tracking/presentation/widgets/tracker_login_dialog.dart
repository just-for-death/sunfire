// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../utils/extensions/custom_extensions.dart';
import '../../../../utils/launch_url_in_web.dart';
import '../../../../utils/misc/toast/toast.dart';
import '../../domain/tracker_model.dart';
import '../controller/tracker_controller.dart';

class TrackerLoginDialog extends HookConsumerWidget {
  const TrackerLoginDialog({super.key, required this.tracker});
  final TrackerDto tracker;

  // MAL, AniList, Bangumi use OAuth (have an authUrl)
  bool get _isOAuth => tracker.authUrl != null && tracker.authUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscure = useState(true);
    final loading = useState(false);

    return AlertDialog(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: tracker.icon,
              width: 28,
              height: 28,
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.track_changes_rounded, size: 28),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Log In — ${tracker.name}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: _isOAuth
          ? Text(
              'You will be redirected to ${tracker.name} to authorise access.',
              style: context.textTheme.bodyMedium,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.userName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure.value,
                  decoration: InputDecoration(
                    labelText: context.l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure.value
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: loading.value
              ? null
              : () async {
                  loading.value = true;
                  try {
                    if (_isOAuth) {
                      // Open browser for OAuth flow
                      await launchUrlInWeb(
                        context,
                        tracker.authUrl!,
                        ref.read(toastProvider),
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    } else {
                      // Credentials login (Kitsu)
                      await ref
                          .read(trackerAuthNotifierProvider.notifier)
                          .loginCredentials(
                            tracker.id,
                            usernameController.text.trim(),
                            passwordController.text,
                          );
                      final state = ref.read(trackerAuthNotifierProvider);
                      if (context.mounted) {
                        if (state.hasError) {
                          ref
                              .read(toastProvider)
                              ?.showError(state.error.toString());
                          loading.value = false;
                        } else {
                          Navigator.pop(context, true);
                        }
                      } else {
                        loading.value = false;
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      loading.value = false;
                      ref.read(toastProvider)?.showError(e.toString());
                    }
                  }
                },
          child: loading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isOAuth ? context.l10n.openInWeb : 'Log In'),
        ),
      ],
    );
  }
}
