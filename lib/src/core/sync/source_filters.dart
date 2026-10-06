// ISS-079 B4: Suwayomi source filters + preferences data model.
//
// Server shapes (v2.4.x introspection):
//  - `SourceType.filters: [Filter!]!` — union of HeaderFilter, SeparatorFilter,
//    CheckBoxFilter, TriStateFilter, TextFilter, SelectFilter, SortFilter,
//    GroupFilter (children: [Filter!]!).
//  - `SourceType.preferences: [Preference!]!` — union of CheckBoxPreference,
//    SwitchPreference, EditTextPreference, ListPreference,
//    MultiSelectListPreference.
//  - `fetchSourceManga(input.filters: [FilterChangeInput!])` where a change
//    addresses a filter by its index (`position`) and group children through
//    `groupChange`.
//  - `updateSourcePreference(input.change: SourcePreferenceChangeInput)`,
//    addressed by the preference's index (`position`).
//
// The union members disagree on the type of `default` / `currentValue`
// (Boolean vs Int vs String vs [String]); GraphQL forbids merging same-named
// fields with different shapes, so the selections alias them per type.
// UIS builds the filter sheet on top of this; no Flutter imports here.

/// Selection for one level of `Filter` (aliased per member type).
const String _kFilterLeafSelection = '''
  __typename
  ... on HeaderFilter { name }
  ... on SeparatorFilter { name }
  ... on CheckBoxFilter { name checkBoxDefault: default }
  ... on TriStateFilter { name triStateDefault: default }
  ... on TextFilter { name textDefault: default }
  ... on SelectFilter { name selectDefault: default values }
  ... on SortFilter { name sortDefault: default { index ascending } values }
''';

/// Full `filters { … }` selection (groups contain one nested level, which is
/// all Tachiyomi/Mihon filter lists use).
const String kSourceFiltersSelection = '''
filters {
  $_kFilterLeafSelection
  ... on GroupFilter { name filters { $_kFilterLeafSelection } }
}
''';

/// Full `preferences { … }` selection (aliased per member type).
const String kSourcePreferencesSelection = '''
preferences {
  __typename
  ... on CheckBoxPreference { key title summary visible enabled checkBoxCurrent: currentValue checkBoxDefault: default }
  ... on SwitchPreference { key title summary visible enabled switchCurrent: currentValue switchDefault: default }
  ... on EditTextPreference { key title summary visible enabled text dialogTitle dialogMessage editTextCurrent: currentValue editTextDefault: default }
  ... on ListPreference { key title summary visible enabled entries entryValues listCurrent: currentValue listDefault: default }
  ... on MultiSelectListPreference { key title summary visible enabled dialogTitle dialogMessage entries entryValues multiCurrent: currentValue multiDefault: default }
}
''';

enum SourceFilterKind { header, separator, checkBox, triState, text, select, sort, group, unknown }

/// Server `TriState` enum.
enum TriStateValue {
  ignore('IGNORE'),
  include('INCLUDE'),
  exclude('EXCLUDE');

  const TriStateValue(this.wire);
  final String wire;

  static TriStateValue parse(Object? raw) {
    final s = raw?.toString().toUpperCase();
    return TriStateValue.values.firstWhere((v) => v.wire == s, orElse: () => TriStateValue.ignore);
  }
}

class SortSelectionValue {
  final int index;
  final bool ascending;
  const SortSelectionValue({required this.index, required this.ascending});

  static SortSelectionValue? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final i = raw['index'];
    return SortSelectionValue(
      index: i is num ? i.toInt() : int.tryParse('$i') ?? 0,
      ascending: raw['ascending'] == true,
    );
  }

  Map<String, dynamic> toInput() => {'index': index, 'ascending': ascending};

  @override
  bool operator ==(Object other) => other is SortSelectionValue && other.index == index && other.ascending == ascending;
  @override
  int get hashCode => Object.hash(index, ascending);
}

/// One server filter. [position] is its index within its parent list (the
/// address `FilterChangeInput.position` uses).
class SourceFilter {
  final SourceFilterKind kind;
  final int position;
  final String name;
  final bool? checkBoxDefault;
  final TriStateValue? triStateDefault;
  final String? textDefault;
  final int? selectDefault;
  final SortSelectionValue? sortDefault;

  /// Options for [SourceFilterKind.select] / [SourceFilterKind.sort].
  final List<String> values;

  /// Children for [SourceFilterKind.group].
  final List<SourceFilter> children;

  const SourceFilter({
    required this.kind,
    required this.position,
    required this.name,
    this.checkBoxDefault,
    this.triStateDefault,
    this.textDefault,
    this.selectDefault,
    this.sortDefault,
    this.values = const [],
    this.children = const [],
  });

  /// Whether the user can change it (headers/separators are labels only).
  bool get isInteractive =>
      kind != SourceFilterKind.header && kind != SourceFilterKind.separator && kind != SourceFilterKind.unknown;

  static SourceFilterKind _kind(Object? typename) {
    switch (typename) {
      case 'HeaderFilter':
        return SourceFilterKind.header;
      case 'SeparatorFilter':
        return SourceFilterKind.separator;
      case 'CheckBoxFilter':
        return SourceFilterKind.checkBox;
      case 'TriStateFilter':
        return SourceFilterKind.triState;
      case 'TextFilter':
        return SourceFilterKind.text;
      case 'SelectFilter':
        return SourceFilterKind.select;
      case 'SortFilter':
        return SourceFilterKind.sort;
      case 'GroupFilter':
        return SourceFilterKind.group;
      default:
        return SourceFilterKind.unknown;
    }
  }

  factory SourceFilter.fromMap(Map<dynamic, dynamic> m, int position) {
    final kind = _kind(m['__typename']);
    final sel = m['selectDefault'];
    return SourceFilter(
      kind: kind,
      position: position,
      name: m['name']?.toString() ?? '',
      checkBoxDefault: m['checkBoxDefault'] is bool ? m['checkBoxDefault'] as bool : null,
      triStateDefault: m.containsKey('triStateDefault') ? TriStateValue.parse(m['triStateDefault']) : null,
      textDefault: m['textDefault']?.toString(),
      selectDefault: sel is num ? sel.toInt() : int.tryParse('${sel ?? ''}'),
      sortDefault: SortSelectionValue.fromMap(m['sortDefault']),
      values: _strings(m['values']),
      children: kind == SourceFilterKind.group ? parseSourceFilters(m['filters']) : const [],
    );
  }
}

List<String> _strings(Object? raw) => raw is List ? [for (final v in raw) if (v != null) v.toString()] : const [];

/// Parses `SourceType.filters` (positions = list indices).
List<SourceFilter> parseSourceFilters(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (var i = 0; i < raw.length; i++)
      if (raw[i] is Map) SourceFilter.fromMap(raw[i] as Map, i),
  ];
}

/// One `FilterChangeInput`. Build with the named constructors; nest group
/// children with [SourceFilterChange.group].
class SourceFilterChange {
  final int position;
  final bool? checkBoxState;
  final TriStateValue? triState;
  final String? textState;
  final int? selectState;
  final SortSelectionValue? sortState;
  final SourceFilterChange? groupChange;

  const SourceFilterChange._(
    this.position, {
    this.checkBoxState,
    this.triState,
    this.textState,
    this.selectState,
    this.sortState,
    this.groupChange,
  });

  const SourceFilterChange.checkBox(int position, bool value) : this._(position, checkBoxState: value);
  const SourceFilterChange.triState(int position, TriStateValue value) : this._(position, triState: value);
  const SourceFilterChange.text(int position, String value) : this._(position, textState: value);
  const SourceFilterChange.select(int position, int index) : this._(position, selectState: index);
  SourceFilterChange.sort(int position, {required int index, required bool ascending})
      : this._(position, sortState: SortSelectionValue(index: index, ascending: ascending));

  /// Change of child [child] (its position is the index inside the group).
  const SourceFilterChange.group(int position, SourceFilterChange child) : this._(position, groupChange: child);

  Map<String, dynamic> toInput() => {
        'position': position,
        if (checkBoxState != null) 'checkBoxState': checkBoxState,
        if (triState != null) 'triState': triState!.wire,
        if (textState != null) 'textState': textState,
        if (selectState != null) 'selectState': selectState,
        if (sortState != null) 'sortState': sortState!.toInput(),
        if (groupChange != null) 'groupChange': groupChange!.toInput(),
      };
}

/// Group-change inputs must be one per child: a group with N changed children
/// is sent as N `FilterChangeInput`s with the same group position.
List<Map<String, dynamic>> filterChangesToInput(Iterable<SourceFilterChange> changes) =>
    [for (final c in changes) c.toInput()];

enum SourcePreferenceKind { checkBox, switchPreference, editText, list, multiSelectList, unknown }

/// One source preference. [position] is its index (`SourcePreferenceChangeInput.position`).
class SourcePreference {
  final SourcePreferenceKind kind;
  final int position;
  final String? key;
  final String? title;
  final String? summary;
  final bool visible;
  final bool enabled;

  /// Bool for checkBox/switch, String for editText/list, `List<String>` for
  /// multiSelectList. Null = unset (use [defaultValue]).
  final Object? currentValue;
  final Object? defaultValue;
  final List<String> entries;
  final List<String> entryValues;
  final String? dialogTitle;
  final String? dialogMessage;
  final String? text;

  const SourcePreference({
    required this.kind,
    required this.position,
    this.key,
    this.title,
    this.summary,
    this.visible = true,
    this.enabled = true,
    this.currentValue,
    this.defaultValue,
    this.entries = const [],
    this.entryValues = const [],
    this.dialogTitle,
    this.dialogMessage,
    this.text,
  });

  /// [currentValue] falling back to [defaultValue].
  Object? get effectiveValue => currentValue ?? defaultValue;

  bool? get boolValue => effectiveValue is bool ? effectiveValue as bool : null;
  String? get stringValue => effectiveValue is String ? effectiveValue as String : null;
  List<String>? get listValue => effectiveValue is List ? _strings(effectiveValue) : null;

  /// Display label of the selected list entry (ListPreference).
  String? get selectedEntryLabel {
    final v = stringValue;
    if (v == null) return null;
    final i = entryValues.indexOf(v);
    return i >= 0 && i < entries.length ? entries[i] : v;
  }

  factory SourcePreference.fromMap(Map<dynamic, dynamic> m, int position) {
    final SourcePreferenceKind kind;
    Object? current;
    Object? def;
    switch (m['__typename']) {
      case 'CheckBoxPreference':
        kind = SourcePreferenceKind.checkBox;
        current = m['checkBoxCurrent'];
        def = m['checkBoxDefault'];
      case 'SwitchPreference':
        kind = SourcePreferenceKind.switchPreference;
        current = m['switchCurrent'];
        def = m['switchDefault'];
      case 'EditTextPreference':
        kind = SourcePreferenceKind.editText;
        current = m['editTextCurrent'];
        def = m['editTextDefault'];
      case 'ListPreference':
        kind = SourcePreferenceKind.list;
        current = m['listCurrent'];
        def = m['listDefault'];
      case 'MultiSelectListPreference':
        kind = SourcePreferenceKind.multiSelectList;
        current = m['multiCurrent'] is List ? _strings(m['multiCurrent']) : null;
        def = m['multiDefault'] is List ? _strings(m['multiDefault']) : null;
      default:
        kind = SourcePreferenceKind.unknown;
    }
    return SourcePreference(
      kind: kind,
      position: position,
      key: m['key']?.toString(),
      title: m['title']?.toString(),
      summary: m['summary']?.toString(),
      visible: m['visible'] != false,
      enabled: m['enabled'] != false,
      currentValue: current,
      defaultValue: def,
      entries: _strings(m['entries']),
      entryValues: _strings(m['entryValues']),
      dialogTitle: m['dialogTitle']?.toString(),
      dialogMessage: m['dialogMessage']?.toString(),
      text: m['text']?.toString(),
    );
  }
}

/// Parses `SourceType.preferences` (positions = list indices).
List<SourcePreference> parseSourcePreferences(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (var i = 0; i < raw.length; i++)
      if (raw[i] is Map) SourcePreference.fromMap(raw[i] as Map, i),
  ];
}

/// One `SourcePreferenceChangeInput`.
class SourcePreferenceChange {
  final int position;
  final bool? checkBoxState;
  final bool? switchState;
  final String? editTextState;
  final String? listState;
  final List<String>? multiSelectState;

  const SourcePreferenceChange._(
    this.position, {
    this.checkBoxState,
    this.switchState,
    this.editTextState,
    this.listState,
    this.multiSelectState,
  });

  const SourcePreferenceChange.checkBox(int position, bool value) : this._(position, checkBoxState: value);
  const SourcePreferenceChange.switchState(int position, bool value) : this._(position, switchState: value);
  const SourcePreferenceChange.editText(int position, String value) : this._(position, editTextState: value);
  const SourcePreferenceChange.list(int position, String entryValue) : this._(position, listState: entryValue);
  const SourcePreferenceChange.multiSelect(int position, List<String> entryValues)
      : this._(position, multiSelectState: entryValues);

  /// Picks the right input field from [pref.kind]. Throws [ArgumentError] when
  /// [value] has the wrong type for that kind.
  factory SourcePreferenceChange.forPreference(SourcePreference pref, Object? value) {
    switch (pref.kind) {
      case SourcePreferenceKind.checkBox:
        if (value is bool) return SourcePreferenceChange.checkBox(pref.position, value);
      case SourcePreferenceKind.switchPreference:
        if (value is bool) return SourcePreferenceChange.switchState(pref.position, value);
      case SourcePreferenceKind.editText:
        if (value is String) return SourcePreferenceChange.editText(pref.position, value);
      case SourcePreferenceKind.list:
        if (value is String) return SourcePreferenceChange.list(pref.position, value);
      case SourcePreferenceKind.multiSelectList:
        if (value is Iterable) {
          return SourcePreferenceChange.multiSelect(pref.position, [for (final v in value) v.toString()]);
        }
      case SourcePreferenceKind.unknown:
        break;
    }
    throw ArgumentError.value(value, 'value', 'invalid for ${pref.kind.name} preference');
  }

  Map<String, dynamic> toInput() => {
        'position': position,
        if (checkBoxState != null) 'checkBoxState': checkBoxState,
        if (switchState != null) 'switchState': switchState,
        if (editTextState != null) 'editTextState': editTextState,
        if (listState != null) 'listState': listState,
        if (multiSelectState != null) 'multiSelectState': multiSelectState,
      };
}

/// Filters + preferences for one source.
class SourceFiltersAndPreferences {
  final String sourceId;
  final String name;
  final bool isConfigurable;
  final bool supportsLatest;
  final List<SourceFilter> filters;
  final List<SourcePreference> preferences;

  const SourceFiltersAndPreferences({
    required this.sourceId,
    required this.name,
    required this.isConfigurable,
    required this.supportsLatest,
    required this.filters,
    required this.preferences,
  });

  factory SourceFiltersAndPreferences.fromMap(Map<dynamic, dynamic> m) => SourceFiltersAndPreferences(
        sourceId: m['id']?.toString() ?? '',
        name: m['displayName']?.toString() ?? m['name']?.toString() ?? '',
        isConfigurable: m['isConfigurable'] == true,
        supportsLatest: m['supportsLatest'] == true,
        filters: parseSourceFilters(m['filters']),
        preferences: parseSourcePreferences(m['preferences']),
      );
}
