import 'package:flutter/material.dart';

/// Icon + title row for dialogs that can't overflow at large text sizes or on
/// narrow screens (UIS-11): the text is [Flexible], wraps to two lines, then
/// ellipsizes.
class DialogTitle extends StatelessWidget {
  const DialogTitle({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.iconSize = 24,
    this.gap = 8,
    this.style,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;
  final double iconSize;
  final double gap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: gap),
        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
