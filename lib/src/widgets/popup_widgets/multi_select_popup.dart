// Copyright (c) 2023 Contributors to the Catalyst project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../constants/app_sizes.dart';
import '../../utils/extensions/custom_extensions.dart';
import '../../utils/platform/platform_ui.dart';
import 'pop_button.dart';

class MultiSelectPopup<T> extends HookWidget {
  const MultiSelectPopup({
    super.key,
    required this.title,
    required this.optionList,
    required this.values,
    required this.onChange,
    this.getOptionTitle,
    this.getOptionSubtitle,
  });

  final String title;
  final List<T> optionList;
  final List<T> values;
  final ValueChanged<List<T>> onChange;
  final String Function(T)? getOptionTitle;
  final String Function(T)? getOptionSubtitle;

  Map<T, bool> getSelectedValuesFromOptions() {
    return {
      for (var item in optionList) item: values.contains(item),
    };
  }

  @override
  Widget build(BuildContext context) {
    final selectedValues =
        useState<Map<T, bool>>(getSelectedValuesFromOptions());
    useEffect(() {
      selectedValues.value = (getSelectedValuesFromOptions());
      return null;
    }, [values, optionList]);

    if (isCupertinoPlatform) {
      return _CupertinoMultiSelectPopup(
        title: title,
        optionList: optionList,
        selectedValues: selectedValues,
        onChange: onChange,
        getOptionTitle: getOptionTitle,
        getOptionSubtitle: getOptionSubtitle,
      );
    }

    return AlertDialog(
      contentPadding: KEdgeInsets.v8.size,
      title: Text(title),
      content: CheckboxSelectList(
        values: selectedValues.value,
        onChange: (value) {
          final multiSelectMap = selectedValues.value;
          multiSelectMap[value.key] = value.value;
          selectedValues.value = multiSelectMap;
        },
        getTitle: getOptionTitle,
        getSubtitle: getOptionSubtitle,
      ),
      actions: [
        const PopButton(),
        ElevatedButton(
          onPressed: () {
            final multiSelectMap = selectedValues.value;
            final selected = multiSelectMap.keys
                .where((key) => multiSelectMap[key].ifNull())
                .toList();
            onChange(selected);
          },
          child: Text(context.l10n.save),
        )
      ],
    );
  }
}

class _CupertinoMultiSelectPopup<T> extends HookWidget {
  const _CupertinoMultiSelectPopup({
    required this.title,
    required this.optionList,
    required this.selectedValues,
    required this.onChange,
    this.getOptionTitle,
    this.getOptionSubtitle,
  });

  final String title;
  final List<T> optionList;
  final ValueNotifier<Map<T, bool>> selectedValues;
  final ValueChanged<List<T>> onChange;
  final String Function(T)? getOptionTitle;
  final String Function(T)? getOptionSubtitle;

  void _save(BuildContext context) {
    final selected = selectedValues.value.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    onChange(selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: context.height * .75),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.cancel),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navTitleTextStyle
                              .copyWith(fontSize: 17),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () => _save(context),
                        child: Text(
                          context.l10n.save,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.all(8),
                      children: optionList.map((option) {
                        final checked =
                            selectedValues.value[option].ifNull();
                        return CupertinoListTile(
                          title: Text(
                            getOptionTitle?.call(option) ?? option.toString(),
                          ),
                          subtitle: getOptionSubtitle != null
                              ? Text(getOptionSubtitle!(option))
                              : null,
                          trailing: checked
                              ? Icon(
                                  CupertinoIcons.check_mark_circled_solid,
                                  color: CupertinoTheme.of(context)
                                      .primaryColor,
                                )
                              : const Icon(CupertinoIcons.circle),
                          onTap: () {
                            final map = Map<T, bool>.from(
                              selectedValues.value,
                            );
                            map[option] = !checked;
                            selectedValues.value = map;
                          },
                        );
                      }).toList(),
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

class CheckboxSelectList<T> extends StatefulWidget {
  const CheckboxSelectList({
    super.key,
    required this.values,
    required this.onChange,
    this.getTitle,
    this.getSubtitle,
  });

  final Map<T, bool> values;
  final ValueChanged<MapEntry<T, bool>> onChange;
  final String Function(T)? getTitle;
  final String Function(T)? getSubtitle;

  @override
  State<CheckboxSelectList<T>> createState() => _CheckboxSelectListState<T>();
}

class _CheckboxSelectListState<T> extends State<CheckboxSelectList<T>> {
  Widget getCheckboxListTile(
    BuildContext context,
    MapEntry<T, bool> value,
    ValueChanged<bool> onChange,
  ) {
    return CheckboxListTile(
      key: Key(value.key.hashCode.toString()),
      activeColor: context.theme.colorScheme.primary,
      title: Text(
        widget.getTitle?.call(value.key) ?? value.toString(),
      ),
      subtitle: widget.getSubtitle != null
          ? Text(widget.getSubtitle!(value.key))
          : null,
      value: value.value,
      onChanged: (value) {
        onChange(value.ifNull());
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
          children: widget.values.entries
              .map((e) => getCheckboxListTile(
                    context,
                    e,
                    (value) {
                      setState(() {
                        widget.onChange(MapEntry(e.key, value));
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
