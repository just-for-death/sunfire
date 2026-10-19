// Shared semantics auditor: walks a semantics tree and reports every
// actionable node (tap / long-press / button) that exposes neither a label nor
// a tooltip. Such a control is invisible to TalkBack / VoiceOver.
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';

/// Appends a description of each unlabeled actionable node under [node].
///
/// Nodes merged into a parent contribute their data upward and are not separate
/// focus targets, so auditing them in isolation is a false positive and they
/// are skipped.
void collectUnlabeledActionable(SemanticsNode node, List<String> issues) {
  if (node.isMergedIntoParent || node.isInvisible) return;
  final data = node.getSemanticsData();
  final actionable = data.hasAction(SemanticsAction.tap) ||
      data.hasAction(SemanticsAction.longPress) ||
      data.flagsCollection.isButton;
  if (actionable) {
    final label = data.label.trim();
    final tooltip = data.tooltip.trim();
    if (label.isEmpty && tooltip.isEmpty) {
      issues.add(
        'unlabeled actionable node ${node.id} rect=${node.rect} '
        'hint="${data.hint}" value="${data.value}" '
        'flags=${data.flagsCollection}',
      );
    }
  }
  node.visitChildren((child) {
    collectUnlabeledActionable(child, issues);
    return true;
  });
}
