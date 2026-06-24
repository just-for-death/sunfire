// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:flutter/material.dart';

import '../reader_tap_zone.dart';

class EdgeLayout extends StatelessWidget {
  const EdgeLayout({
    super.key,
    this.onLeftTap,
    this.onRightTap,
    this.leftColor,
    this.rightColor,
    this.previousPageLabel,
    this.nextPageLabel,
  });
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;
  final Color? leftColor;
  final Color? rightColor;
  final String? previousPageLabel;
  final String? nextPageLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ReaderTapZone(
            onTap: onRightTap,
            color: rightColor,
            semanticsLabel: nextPageLabel,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Expanded(
                flex: 2,
                child: SizedBox.expand(),
              ),
              Expanded(
                child: ReaderTapZone(
                  onTap: onLeftTap,
                  color: leftColor,
                  semanticsLabel: previousPageLabel,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReaderTapZone(
            onTap: onRightTap,
            color: rightColor,
            semanticsLabel: nextPageLabel,
          ),
        ),
      ],
    );
  }
}
