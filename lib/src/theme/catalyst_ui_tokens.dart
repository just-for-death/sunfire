import 'package:flutter/material.dart';

/// Shared visual constants for the Catalyst UI.
///
/// Values follow the Material 3 shape/spacing scale so component themes,
/// covers and one-off widgets stay in sync.
class CatalystUiTokens {
  CatalystUiTokens._();

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;

  // ── Corner radii ─────────────────────────────────────────────────────────
  static const double radiusExtraSmall = 4;
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusLargeIncreased = 20;
  static const double radiusExtraLarge = 28;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius chipRadius =
      BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius badgeRadius =
      BorderRadius.all(Radius.circular(radiusExtraSmall));
  static const BorderRadius coverRadius =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius coverRadiusSmall =
      BorderRadius.all(Radius.circular(radiusExtraSmall));
  static const BorderRadius listItemRadius =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius sheetRadius =
      BorderRadius.vertical(top: Radius.circular(radiusExtraLarge));
  static const BorderRadius dialogRadius =
      BorderRadius.all(Radius.circular(radiusExtraLarge));
  static const BorderRadius readerBarRadius =
      BorderRadius.all(Radius.circular(radiusLargeIncreased));

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: space16,
  );

  // ── Covers & grid ────────────────────────────────────────────────────────
  /// Cover art ratio used across grids, lists and details.
  static const double coverAspectRatio = 13 / 18;

  /// Target width of a single grid column before spacing is applied.
  static const double gridPreferredItemWidth = 120;
  static const double gridSpacing = space8;

  /// Vertical space reserved under a cover for a two-line title.
  static const double gridTitleExtent = 40;

  // ── Elevation ────────────────────────────────────────────────────────────
  static const double elevationFlat = 0;
  static const double elevationLow = 1;
  static const double elevationFloating = 2;
  static const double elevationRaised = 8;

  // ── Motion ───────────────────────────────────────────────────────────────
  static const Duration durationTiny = Duration(milliseconds: 50);
  static const Duration durationShort = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 1000);

  /// Chrome that slides away on scroll leaves faster than it returns.
  static const Duration durationChromeEnter = Duration(milliseconds: 225);
  static const Duration durationChromeExit = Duration(milliseconds: 175);

  static const Curve curveStandard = Curves.fastOutSlowIn;
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
}
