// Copyright (c) 2022 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/platform_ui.dart';
import 'pop_button.dart';

class RadioListPopup<T> extends StatelessWidget {
  const RadioListPopup({
    super.key,
    required this.title,
    required this.optionList,
    required this.value,
    required this.onChange,
    this.getOptionTitle,
    this.getOptionSubtitle,
  });

  final String title;
  final List<T> optionList;
  final T value;
  final ValueChanged<T> onChange;
  final String Function(T)? getOptionTitle;
  final String Function(T)? getOptionSubtitle;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform) {
      return _CupertinoRadioListPopup(
        title: title,
        optionList: optionList,
        value: value,
        onChange: onChange,
        getOptionTitle: getOptionTitle,
        getOptionSubtitle: getOptionSubtitle,
      );
    }
    return AlertDialog(
      contentPadding: KEdgeInsets.v8.size,
      title: Text(title),
      content: RadioList(
        optionList: optionList,
        value: value,
        onChange: onChange,
        getTitle: getOptionTitle,
        getSubtitle: getOptionSubtitle,
      ),
      actions: const [PopButton()],
    );
  }
}

class _CupertinoRadioListPopup<T> extends StatelessWidget {
  const _CupertinoRadioListPopup({
    required this.title,
    required this.optionList,
    required this.value,
    required this.onChange,
    this.getOptionTitle,
    this.getOptionSubtitle,
  });

  final String title;
  final List<T> optionList;
  final T value;
  final ValueChanged<T> onChange;
  final String Function(T)? getOptionTitle;
  final String Function(T)? getOptionSubtitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: context.height * .7),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    title,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navTitleTextStyle
                        .copyWith(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      children: optionList.map((option) {
                        final selected = option == value;
                        return CupertinoListTile(
                          title: Text(
                            getOptionTitle?.call(option) ?? option.toString(),
                          ),
                          subtitle: getOptionSubtitle != null
                              ? Text(getOptionSubtitle!(option))
                              : null,
                          trailing: selected
                              ? Icon(
                                  CupertinoIcons.check_mark,
                                  color: CupertinoTheme.of(context)
                                      .primaryColor,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            onChange(option);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.close),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadioList<T> extends StatelessWidget {
  const RadioList({
    super.key,
    required this.optionList,
    required this.value,
    required this.onChange,
    this.getTitle,
    this.getSubtitle,
  });

  final List<T> optionList;
  final T value;
  final ValueChanged<T> onChange;
  final String Function(T)? getTitle;
  final String Function(T)? getSubtitle;

  Widget getRadioListTile(BuildContext context, T option) {
    return RadioListTile<T>(
      activeColor: context.theme.colorScheme.primary,
      title: Text(
        getTitle?.call(option) ?? option.toString(),
      ),
      subtitle: getSubtitle != null ? (Text(getSubtitle!(option))) : null,
      value: option,
      groupValue: value,
      onChanged: (value) {
        if (value != null) {
          onChange(value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.height * .7),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              optionList.map((e) => getRadioListTile(context, e)).toList(),
        ),
      ),
    );
  }
}
