// Auto-scroll speed bottom sheet, extracted from ReaderScreen (v6 Step 9).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/design_system/tokens/sunfire_colors.dart';

void showAutoScrollSpeedSheet(
BuildContext context, {
required double Function() getSpeed,
required void Function(double speed) setSpeed,
required void Function(double speed) onSaveDefault,
}) {
  final primaryColor = Theme.of(context).colorScheme.primary;
  unawaited(showModalBottomSheet<void>(
    context: context,
    backgroundColor: SunfireColors.surface1,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Auto-Scroll Speed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SunfireColors.contentPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${getSpeed().round()} px/s',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          onSaveDefault(getSpeed());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Default auto-scroll speed set to ${getSpeed().round()} px/s'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Default', style: TextStyle(fontSize: 11, color: SunfireColors.trackerAmber)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: SunfireColors.borderHairline,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          setSpeed((getSpeed() - 10.0).clamp(10.0, 2000.0));
                          setSheetState(() {});
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: getSpeed().clamp(10.0, 2000.0),
                          min: 10.0,
                          max: 2000.0,
                          divisions: 199,
                          activeColor: primaryColor,
                          label: '${getSpeed().round()} px/s',
                          onChanged: (val) {
                            setSpeed(val);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: SunfireColors.borderHairline,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          setSpeed((getSpeed() + 10.0).clamp(10.0, 2000.0));
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Quick Presets', style: TextStyle(fontSize: 12, color: SunfireColors.contentTertiary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _speedChip('Slow (25 px/s)', 25.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Normal (50 px/s)', 50.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Fast (120 px/s)', 120.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Faster (250 px/s)', 250.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Turbo (500 px/s)', 500.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Hyper (800 px/s)', 800.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Warp (1200 px/s)', 1200.0, primaryColor, setSheetState, getSpeed, setSpeed),
                      _speedChip('Light (1600 px/s)', 1600.0, primaryColor, setSheetState, getSpeed, setSpeed),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  ));
}

Widget _speedChip(String label, double speed, Color primaryColor, StateSetter setSheetState,
  double Function() getSpeed, void Function(double) setSpeed) {
  final isSelected = (getSpeed() - speed).abs() < 5.0;
  return ChoiceChip(
    label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? SunfireColors.contentPrimary : SunfireColors.contentSecondary)),
    selected: isSelected,
    selectedColor: primaryColor.withValues(alpha: 0.35),
    backgroundColor: SunfireColors.borderSubtle,
    side: BorderSide(color: isSelected ? primaryColor : SunfireColors.borderSubtle, width: 0.8),
    onSelected: (_) {
      setSpeed(speed);
      setSheetState(() {});
    },
  );
}
