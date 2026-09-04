import 'package:flutter/material.dart';

import '../../../core/widgets/sunfire_badge.dart';

enum SettingsPropKind {
  textField,
  numberSlider,
  numberPicker,
  switchTile,
  actionTile,
}

enum SettingScope {
  server,
  local,
  none,
}

class SettingsPropTile extends StatelessWidget {
  const SettingsPropTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.description,
    this.leading,
    this.trailing,
    this.kind = SettingsPropKind.actionTile,
    this.scope = SettingScope.none,
    this.boolValue,
    this.stringValue,
    this.intValue,
    this.doubleValue,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.unit = '',
    this.canObscure = false,
    this.hintText,
    this.onBoolChanged,
    this.onStringChanged,
    this.onIntChanged,
    this.onDoubleChanged,
    this.onTap,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final String? description;
  final Widget? leading;
  final Widget? trailing;
  final SettingsPropKind kind;
  final SettingScope scope;

  final bool? boolValue;
  final String? stringValue;
  final int? intValue;
  final double? doubleValue;
  final int min;
  final int max;
  final int? divisions;
  final String unit;
  final bool canObscure;
  final String? hintText;

  final ValueChanged<bool>? onBoolChanged;
  final ValueChanged<String>? onStringChanged;
  final ValueChanged<int>? onIntChanged;
  final ValueChanged<double>? onDoubleChanged;
  final VoidCallback? onTap;

  Widget _buildScopeBadge(BuildContext context) {
    if (scope == SettingScope.none) return const SizedBox.shrink();

    final isServer = scope == SettingScope.server;
    final color = isServer ? Colors.tealAccent : Colors.purpleAccent;

    return SunfireBadge(
      label: isServer ? 'SERVER' : 'LOCAL',
      color: color,
    );
  }

  void _showTextFieldDialog(BuildContext context) {
    final controller = TextEditingController(text: stringValue ?? '');
    bool isObscured = canObscure;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: Row(
                children: [
                  Expanded(child: titleWidget ?? Text(title ?? 'Edit Setting', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  _buildScopeBadge(context),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null && description!.isNotEmpty) ...[
                    Text(description!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 14),
                  ],
                  TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: isObscured,
                    decoration: InputDecoration(
                      hintText: hintText,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: canObscure
                          ? IconButton(
                              icon: Icon(isObscured ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                              onPressed: () => setDlgState(() => isObscured = !isObscured),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();
                    Navigator.pop(context);
                    onStringChanged?.call(text);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSliderDialog(BuildContext context) {
    double currentVal = (intValue?.toDouble()) ?? (doubleValue ?? min.toDouble());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final formatted = currentVal == currentVal.roundToDouble()
                ? '${currentVal.toInt()}$unit'
                : '${currentVal.toStringAsFixed(1)}$unit';

            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F24),
              title: Row(
                children: [
                  Expanded(child: titleWidget ?? Text(title ?? 'Adjust Value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  _buildScopeBadge(context),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (description != null && description!.isNotEmpty) ...[
                    Text(description!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    formatted,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  Slider(
                    value: currentVal.clamp(min.toDouble(), max.toDouble()),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: divisions ?? (max - min),
                    onChanged: (v) => setDlgState(() => currentVal = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onIntChanged != null) {
                      onIntChanged!(currentVal.round());
                    } else if (onDoubleChanged != null) {
                      onDoubleChanged!(currentVal);
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleWidgetContent = titleWidget ??
        Text(
          title ?? '',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        );

    final titleContent = scope == SettingScope.none
        ? titleWidgetContent
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              titleWidgetContent,
              _buildScopeBadge(context),
            ],
          );

    if (kind == SettingsPropKind.switchTile) {
      return SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        secondary: leading,
        title: titleContent,
        subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        value: boolValue ?? false,
        onChanged: onBoolChanged,
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: leading,
      title: titleContent,
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
      trailing: trailing,
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (kind == SettingsPropKind.textField) {
          _showTextFieldDialog(context);
        } else if (kind == SettingsPropKind.numberSlider || kind == SettingsPropKind.numberPicker) {
          _showSliderDialog(context);
        }
      },
    );
  }
}
