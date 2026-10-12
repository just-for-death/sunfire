// lib/src/features/library/smart_collections_screen.dart
//
// L10.1: UI for smart collection (auto-tag) rules.

import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/library/smart_collection_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/design_system/components/components.dart' show SunfireButton;

class SmartCollectionsScreen extends StatefulWidget {
  const SmartCollectionsScreen({super.key});

  @override
  State<SmartCollectionsScreen> createState() => _SmartCollectionsScreenState();
}

class _SmartCollectionsScreenState extends State<SmartCollectionsScreen> {
  List<SmartCollectionRule> _rules = const [];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _rules = SmartCollectionService.instance.loadRules());
  }

  Future<void> _runAll() async {
    setState(() => _running = true);
    try {
      final n = await SmartCollectionService.instance.evaluateAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied smart tags ($n assignments)')),
      );
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _editRule([SmartCollectionRule? existing]) async {
    final result = await showDialog<SmartCollectionRule>(
      context: context,
      builder: (ctx) => _RuleEditorDialog(initial: existing),
    );
    if (result == null) return;
    await SmartCollectionService.instance.upsertRule(result);
    if (mounted) _reload();
  }

  Future<void> _deleteRule(SmartCollectionRule rule) async {
    await SmartCollectionService.instance.deleteRule(rule.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Collections'),
        actions: [
          TextButton(
            onPressed: _running ? null : () => unawaited(_runAll()),
            child: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run now'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => unawaited(_editRule()),
        child: const Icon(Icons.add),
      ),
      body: _rules.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Create rules to auto-tag manga by genre, status, source, and more.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              itemCount: _rules.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return ListTile(
                  leading: Icon(
                    rule.enabled ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                    color: rule.enabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(rule.name.isEmpty ? rule.tagName : rule.name),
                      SunfireBadge.local(),
                    ],
                  ),
                  subtitle: Text(
                    '${rule.field.name} ${rule.op.name} "${rule.matchValue}" → #${rule.tagName}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: rule.enabled,
                        onChanged: (v) async {
                          await SmartCollectionService.instance
                              .upsertRule(rule.copyWith(enabled: v));
                          if (mounted) _reload();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => unawaited(_editRule(rule)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => unawaited(_deleteRule(rule)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _RuleEditorDialog extends StatefulWidget {
  const _RuleEditorDialog({this.initial});

  final SmartCollectionRule? initial;

  @override
  State<_RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends State<_RuleEditorDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _tagCtrl;
  late final TextEditingController _valueCtrl;
  late SmartMatchField _field;
  late SmartMatchOp _op;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _tagCtrl = TextEditingController(text: i?.tagName ?? '');
    _valueCtrl = TextEditingController(text: i?.matchValue ?? '');
    _field = i?.field ?? SmartMatchField.genre;
    _op = i?.op ?? SmartMatchOp.contains;
    _enabled = i?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'New rule' : 'Edit rule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Rule name'),
            ),
            TextField(
              controller: _tagCtrl,
              decoration: const InputDecoration(labelText: 'Tag to apply'),
            ),
            DropdownButtonFormField<SmartMatchField>(
              key: ValueKey(_field),
              initialValue: _field,
              decoration: const InputDecoration(labelText: 'Match field'),
              items: SmartMatchField.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (v) => setState(() => _field = v ?? _field),
            ),
            DropdownButtonFormField<SmartMatchOp>(
              key: ValueKey(_op),
              initialValue: _op,
              decoration: const InputDecoration(labelText: 'Operator'),
              items: SmartMatchOp.values
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.name)))
                  .toList(),
              onChanged: (v) => setState(() => _op = v ?? _op),
            ),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Match value'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        SunfireButton.primary(
          label: 'Save',
          onPressed: () {
            final tag = _tagCtrl.text.trim();
            if (tag.isEmpty) return;
            Navigator.pop(
              context,
              SmartCollectionRule(
                id: widget.initial?.id ?? const Uuid().v4(),
                name: _nameCtrl.text.trim().isEmpty
                    ? tag
                    : _nameCtrl.text.trim(),
                tagName: tag,
                field: _field,
                op: _op,
                matchValue: _valueCtrl.text,
                enabled: _enabled,
              ),
            );
          },
        ),
      ],
    );
  }
}
