// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../utils/extensions/custom_extensions.dart';
import '../../../../../../widgets/popup_widgets/pop_button.dart';
import '../../../../data/basic_credentials_store.dart';

part 'credentials_popup.g.dart';

@riverpod
class Credentials extends _$Credentials {
  @override
  String? build() => BasicCredentialsStore.instance.current;

  Future<void> update(String? value) async {
    await BasicCredentialsStore.instance.set(value);
    state = BasicCredentialsStore.instance.current;
  }
}

final formKey = GlobalKey<FormState>();

class CredentialsPopup extends HookConsumerWidget {
  const CredentialsPopup({super.key});

  String _basicAuth({
    required String userName,
    required String password,
  }) =>
      'Basic ${base64.encode(
        utf8.encode('$userName:$password'),
      )}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = useTextEditingController();
    final password = useTextEditingController();
    return AlertDialog(
      title: Text(context.l10n.credentials),
      content: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: username,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value.isBlank ? (context.l10n.errorUserName) : null,
                decoration: InputDecoration(
                  hintText: context.l10n.userName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const Gap(4),
              TextFormField(
                controller: password,
                autofillHints: const [AutofillHints.password],
                obscureText: true,
                validator: (value) =>
                    value.isBlank ? (context.l10n.errorPassword) : null,
                decoration: InputDecoration(
                  hintText: context.l10n.password,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        const PopButton(),
        ElevatedButton(
          onPressed: () async {
            if ((formKey.currentState?.validate()).ifNull()) {
              await ref.read(credentialsProvider.notifier).update(
                    _basicAuth(
                      userName: username.text,
                      password: password.text,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
