// lib/src/core/library/smart_collection_service.dart
//
// L10.1: Smart collections — auto-assign tags from manga field rules.

import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../db/isar_service.dart';
import '../db/models/manga.dart';
import '../services/settings_service.dart';
import '../services/tag_service.dart';

/// Match field on [Manga] for a smart-collection rule.
enum SmartMatchField {
  genre,
  status,
  sourceName,
  author,
  title,
  unread,
  language,
}

/// How [SmartMatchField] is compared to [SmartCollectionRule.matchValue].
enum SmartMatchOp {
  contains,
  equals,
  startsWith,
  isTrue,
}

/// One auto-tag rule persisted as JSON in SettingsService.
class SmartCollectionRule {
  SmartCollectionRule({
    required this.id,
    required this.name,
    required this.tagName,
    this.tagColor = '#FF5722',
    required this.field,
    required this.op,
    this.matchValue = '',
    this.enabled = true,
  });

  factory SmartCollectionRule.fromJson(Map<String, dynamic> json) {
    return SmartCollectionRule(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tagName: json['tagName']?.toString() ?? '',
      tagColor: json['tagColor']?.toString() ?? '#FF5722',
      field: SmartMatchField.values.firstWhere(
        (f) => f.name == json['field'],
        orElse: () => SmartMatchField.genre,
      ),
      op: SmartMatchOp.values.firstWhere(
        (o) => o.name == json['op'],
        orElse: () => SmartMatchOp.contains,
      ),
      matchValue: json['matchValue']?.toString() ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final String tagName;
  final String tagColor;
  final SmartMatchField field;
  final SmartMatchOp op;
  final String matchValue;
  final bool enabled;

  SmartCollectionRule copyWith({
    String? id,
    String? name,
    String? tagName,
    String? tagColor,
    SmartMatchField? field,
    SmartMatchOp? op,
    String? matchValue,
    bool? enabled,
  }) {
    return SmartCollectionRule(
      id: id ?? this.id,
      name: name ?? this.name,
      tagName: tagName ?? this.tagName,
      tagColor: tagColor ?? this.tagColor,
      field: field ?? this.field,
      op: op ?? this.op,
      matchValue: matchValue ?? this.matchValue,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagName': tagName,
        'tagColor': tagColor,
        'field': field.name,
        'op': op.name,
        'matchValue': matchValue,
        'enabled': enabled,
      };
}

/// Pure matcher (unit-testable without Isar).
bool mangaMatchesSmartRule(Manga manga, SmartCollectionRule rule) {
  if (!rule.enabled) return false;
  final needle = rule.matchValue.trim().toLowerCase();

  switch (rule.field) {
    case SmartMatchField.genre:
      return _matchList(manga.genres, rule.op, needle);
    case SmartMatchField.status:
      return _matchString(manga.status ?? '', rule.op, needle);
    case SmartMatchField.sourceName:
      return _matchString(manga.sourceName, rule.op, needle);
    case SmartMatchField.author:
      return _matchString(manga.author ?? '', rule.op, needle);
    case SmartMatchField.title:
      return _matchString(manga.title, rule.op, needle);
    case SmartMatchField.language:
      return _matchString(manga.lang, rule.op, needle);
    case SmartMatchField.unread:
      final unread = (manga.unreadCount ?? 0) > 0;
      if (rule.op == SmartMatchOp.isTrue) return unread;
      if (needle == 'true' || needle == '1' || needle == 'yes') return unread;
      if (needle == 'false' || needle == '0' || needle == 'no') return !unread;
      return unread;
  }
}

bool _matchString(String haystack, SmartMatchOp op, String needle) {
  final h = haystack.toLowerCase();
  switch (op) {
    case SmartMatchOp.equals:
      return h == needle;
    case SmartMatchOp.startsWith:
      return needle.isNotEmpty && h.startsWith(needle);
    case SmartMatchOp.contains:
      return needle.isNotEmpty && h.contains(needle);
    case SmartMatchOp.isTrue:
      return h == 'true' || h == '1' || h == 'yes';
  }
}

bool _matchList(List<String> values, SmartMatchOp op, String needle) {
  if (needle.isEmpty && op != SmartMatchOp.isTrue) return false;
  for (final v in values) {
    if (_matchString(v, op, needle)) return true;
  }
  return false;
}

/// L10.1 Smart collections service.
class SmartCollectionService {
  SmartCollectionService._();
  static final SmartCollectionService instance = SmartCollectionService._();

  List<SmartCollectionRule> loadRules() {
    final raw = SettingsService.instance.smartCollectionRulesJson;
    if (raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => SmartCollectionRule.fromJson(Map<String, dynamic>.from(e)))
          .where((r) => r.id.isNotEmpty && r.tagName.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('[SmartCollection] loadRules failed: $e');
      return [];
    }
  }

  Future<void> saveRules(List<SmartCollectionRule> rules) async {
    SettingsService.instance.smartCollectionRulesJson =
        jsonEncode(rules.map((r) => r.toJson()).toList());
  }

  Future<void> upsertRule(SmartCollectionRule rule) async {
    final rules = loadRules();
    final idx = rules.indexWhere((r) => r.id == rule.id);
    if (idx >= 0) {
      rules[idx] = rule;
    } else {
      rules.add(rule);
    }
    await saveRules(rules);
  }

  Future<void> deleteRule(String id) async {
    final rules = loadRules()..removeWhere((r) => r.id == id);
    await saveRules(rules);
  }

  /// Evaluate enabled rules against one manga. A rule's tag tracks its
  /// matches: it is assigned when any enabled rule for that tag matches and
  /// removed when none do, so a series that stops matching (finished, lost a
  /// genre) leaves the collection. Returns the number of tag changes.
  Future<int> evaluateManga(Manga manga) async {
    final rules = loadRules().where((r) => r.enabled).toList();
    if (rules.isEmpty) return 0;
    final wanted = <String, SmartCollectionRule>{};
    final managed = <String, SmartCollectionRule>{};
    for (final rule in rules) {
      final key = rule.tagName.trim().toLowerCase();
      managed.putIfAbsent(key, () => rule);
      if (mangaMatchesSmartRule(manga, rule)) wanted.putIfAbsent(key, () => rule);
    }

    var changed = 0;
    final current = await TagService.instance.getTagsForManga(manga.canonicalKey);
    final currentIds = current.map((t) => t.id).toSet();
    for (final rule in wanted.values) {
      final tag = await TagService.instance
          .getOrCreateTag(rule.tagName, color: rule.tagColor);
      if (tag.id <= 0 || currentIds.contains(tag.id)) continue;
      if (await TagService.instance.assignTag(manga.canonicalKey, tag.id)) {
        changed++;
      }
    }
    for (final tag in current) {
      final key = tag.name.trim().toLowerCase();
      if (!managed.containsKey(key) || wanted.containsKey(key)) continue;
      if (await TagService.instance.removeTag(manga.canonicalKey, tag.id)) {
        changed++;
      }
    }
    return changed;
  }

  /// Evaluate all in-library manga. Returns the total number of tag changes.
  Future<int> evaluateAll() async {
    if (!IsarService.instance.isInitialized) return 0;
    final library = await IsarService.instance.getLibraryManga();
    var total = 0;
    for (final manga in library) {
      total += await evaluateManga(manga);
    }
    return total;
  }
}
