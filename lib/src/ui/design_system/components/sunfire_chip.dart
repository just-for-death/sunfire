// sunfire_chip.dart
//
// C5.3: Chips - filter / choice / input.

library;

import 'package:flutter/material.dart';

/// Chip variants.
enum SunfireChipVariant { filter, choice, input }

/// Sunfire chip: variant-driven wrapper over Material 3 chips.
class SunfireChip extends StatelessWidget {
  const SunfireChip({
    super.key,
    required this.label,
    this.variant = SunfireChipVariant.filter,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
  });

  final String label;
  final SunfireChipVariant variant;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case SunfireChipVariant.filter:
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          avatar: avatar,
          showCheckmark: true,
        );
      case SunfireChipVariant.choice:
        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          avatar: avatar,
        );
      case SunfireChipVariant.input:
        return InputChip(
          label: Text(label),
          selected: selected,
          onSelected: onSelected,
          onDeleted: onDeleted,
          avatar: avatar,
        );
    }
  }
}
