import '../../../../../../graphql/__generated__/schema.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto({required this.$__typename});

  factory Fragment$PrimitiveFilterDto.fromJson(Map<String, dynamic> json) {
    switch (json["__typename"] as String) {
      case "CheckBoxFilter":
        return Fragment$PrimitiveFilterDto$$CheckBoxFilter.fromJson(json);

      case "HeaderFilter":
        return Fragment$PrimitiveFilterDto$$HeaderFilter.fromJson(json);

      case "SelectFilter":
        return Fragment$PrimitiveFilterDto$$SelectFilter.fromJson(json);

      case "TriStateFilter":
        return Fragment$PrimitiveFilterDto$$TriStateFilter.fromJson(json);

      case "TextFilter":
        return Fragment$PrimitiveFilterDto$$TextFilter.fromJson(json);

      case "SortFilter":
        return Fragment$PrimitiveFilterDto$$SortFilter.fromJson(json);

      case "SeparatorFilter":
        return Fragment$PrimitiveFilterDto$$SeparatorFilter.fromJson(json);

      case "GroupFilter":
        return Fragment$PrimitiveFilterDto$$GroupFilter.fromJson(json);

      default:
        final l$$__typename = json['__typename'];
        return Fragment$PrimitiveFilterDto(
            $__typename: (l$$__typename as String));
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto
    on Fragment$PrimitiveFilterDto {
  CopyWith$Fragment$PrimitiveFilterDto<Fragment$PrimitiveFilterDto>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto(
            this,
            (i) => i,
          );

  _T when<_T>({
    required _T Function(Fragment$PrimitiveFilterDto$$CheckBoxFilter)
        checkBoxFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$HeaderFilter)
        headerFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$SelectFilter)
        selectFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$TriStateFilter)
        triStateFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$TextFilter) textFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$SortFilter) sortFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$SeparatorFilter)
        separatorFilter,
    required _T Function(Fragment$PrimitiveFilterDto$$GroupFilter) groupFilter,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxFilter":
        return checkBoxFilter(
            this as Fragment$PrimitiveFilterDto$$CheckBoxFilter);

      case "HeaderFilter":
        return headerFilter(this as Fragment$PrimitiveFilterDto$$HeaderFilter);

      case "SelectFilter":
        return selectFilter(this as Fragment$PrimitiveFilterDto$$SelectFilter);

      case "TriStateFilter":
        return triStateFilter(
            this as Fragment$PrimitiveFilterDto$$TriStateFilter);

      case "TextFilter":
        return textFilter(this as Fragment$PrimitiveFilterDto$$TextFilter);

      case "SortFilter":
        return sortFilter(this as Fragment$PrimitiveFilterDto$$SortFilter);

      case "SeparatorFilter":
        return separatorFilter(
            this as Fragment$PrimitiveFilterDto$$SeparatorFilter);

      case "GroupFilter":
        return groupFilter(this as Fragment$PrimitiveFilterDto$$GroupFilter);

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Fragment$PrimitiveFilterDto$$CheckBoxFilter)? checkBoxFilter,
    _T Function(Fragment$PrimitiveFilterDto$$HeaderFilter)? headerFilter,
    _T Function(Fragment$PrimitiveFilterDto$$SelectFilter)? selectFilter,
    _T Function(Fragment$PrimitiveFilterDto$$TriStateFilter)? triStateFilter,
    _T Function(Fragment$PrimitiveFilterDto$$TextFilter)? textFilter,
    _T Function(Fragment$PrimitiveFilterDto$$SortFilter)? sortFilter,
    _T Function(Fragment$PrimitiveFilterDto$$SeparatorFilter)? separatorFilter,
    _T Function(Fragment$PrimitiveFilterDto$$GroupFilter)? groupFilter,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxFilter":
        if (checkBoxFilter != null) {
          return checkBoxFilter(
              this as Fragment$PrimitiveFilterDto$$CheckBoxFilter);
        } else {
          return orElse();
        }

      case "HeaderFilter":
        if (headerFilter != null) {
          return headerFilter(
              this as Fragment$PrimitiveFilterDto$$HeaderFilter);
        } else {
          return orElse();
        }

      case "SelectFilter":
        if (selectFilter != null) {
          return selectFilter(
              this as Fragment$PrimitiveFilterDto$$SelectFilter);
        } else {
          return orElse();
        }

      case "TriStateFilter":
        if (triStateFilter != null) {
          return triStateFilter(
              this as Fragment$PrimitiveFilterDto$$TriStateFilter);
        } else {
          return orElse();
        }

      case "TextFilter":
        if (textFilter != null) {
          return textFilter(this as Fragment$PrimitiveFilterDto$$TextFilter);
        } else {
          return orElse();
        }

      case "SortFilter":
        if (sortFilter != null) {
          return sortFilter(this as Fragment$PrimitiveFilterDto$$SortFilter);
        } else {
          return orElse();
        }

      case "SeparatorFilter":
        if (separatorFilter != null) {
          return separatorFilter(
              this as Fragment$PrimitiveFilterDto$$SeparatorFilter);
        } else {
          return orElse();
        }

      case "GroupFilter":
        if (groupFilter != null) {
          return groupFilter(this as Fragment$PrimitiveFilterDto$$GroupFilter);
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Fragment$PrimitiveFilterDto<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto(
    Fragment$PrimitiveFilterDto instance,
    TRes Function(Fragment$PrimitiveFilterDto) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto;

  factory CopyWith$Fragment$PrimitiveFilterDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto _instance;

  final TRes Function(Fragment$PrimitiveFilterDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Fragment$PrimitiveFilterDto(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

const fragmentDefinitionPrimitiveFilterDto = FragmentDefinitionNode(
  name: NameNode(value: 'PrimitiveFilterDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Filter'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'CheckBoxFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'checkBoxState'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'HeaderFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'SelectFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'selectState'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'values'),
          alias: NameNode(value: 'displayValues'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'TriStateFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'tristate'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'TextFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'textState'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'SortFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'sortState'),
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'SortSelectionDto'),
              directives: [],
            ),
            FieldNode(
              name: NameNode(value: '__typename'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
          ]),
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'values'),
          alias: NameNode(value: 'displayValues'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'SeparatorFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
  ]),
);
const documentNodeFragmentPrimitiveFilterDto = DocumentNode(definitions: [
  fragmentDefinitionPrimitiveFilterDto,
  fragmentDefinitionSortSelectionDto,
]);

extension ClientExtension$Fragment$PrimitiveFilterDto on graphql.GraphQLClient {
  void writeFragment$PrimitiveFilterDto({
    required Fragment$PrimitiveFilterDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'PrimitiveFilterDto',
            document: documentNodeFragmentPrimitiveFilterDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$PrimitiveFilterDto? readFragment$PrimitiveFilterDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'PrimitiveFilterDto',
          document: documentNodeFragmentPrimitiveFilterDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$PrimitiveFilterDto.fromJson(result);
  }
}

class Fragment$PrimitiveFilterDto$$CheckBoxFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$CheckBoxFilter({
    this.$__typename = 'CheckBoxFilter',
    required this.checkBoxState,
    required this.name,
  });

  factory Fragment$PrimitiveFilterDto$$CheckBoxFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$checkBoxState = json['checkBoxState'];
    final l$name = json['name'];
    return Fragment$PrimitiveFilterDto$$CheckBoxFilter(
      $__typename: (l$$__typename as String),
      checkBoxState: (l$checkBoxState as bool),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final bool checkBoxState;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$checkBoxState = checkBoxState;
    _resultData['checkBoxState'] = l$checkBoxState;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$checkBoxState = checkBoxState;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$checkBoxState,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$CheckBoxFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$checkBoxState = checkBoxState;
    final lOther$checkBoxState = other.checkBoxState;
    if (l$checkBoxState != lOther$checkBoxState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$CheckBoxFilter
    on Fragment$PrimitiveFilterDto$$CheckBoxFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter<
          Fragment$PrimitiveFilterDto$$CheckBoxFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter(
    Fragment$PrimitiveFilterDto$$CheckBoxFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$CheckBoxFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter;

  TRes call({
    String? $__typename,
    bool? checkBoxState,
    String? name,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$CheckBoxFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$CheckBoxFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? checkBoxState = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$CheckBoxFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        checkBoxState: checkBoxState == _undefined || checkBoxState == null
            ? _instance.checkBoxState
            : (checkBoxState as bool),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$CheckBoxFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$CheckBoxFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    bool? checkBoxState,
    String? name,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$HeaderFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$HeaderFilter({
    this.$__typename = 'HeaderFilter',
    required this.name,
  });

  factory Fragment$PrimitiveFilterDto$$HeaderFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$name = json['name'];
    return Fragment$PrimitiveFilterDto$$HeaderFilter(
      $__typename: (l$$__typename as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$HeaderFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$HeaderFilter
    on Fragment$PrimitiveFilterDto$$HeaderFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter<
          Fragment$PrimitiveFilterDto$$HeaderFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter(
    Fragment$PrimitiveFilterDto$$HeaderFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$HeaderFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$HeaderFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$HeaderFilter;

  TRes call({
    String? $__typename,
    String? name,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$HeaderFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$HeaderFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$HeaderFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$HeaderFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$HeaderFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$HeaderFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$HeaderFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$HeaderFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? name,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$SelectFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$SelectFilter({
    this.$__typename = 'SelectFilter',
    required this.selectState,
    required this.name,
    required this.displayValues,
  });

  factory Fragment$PrimitiveFilterDto$$SelectFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$selectState = json['selectState'];
    final l$name = json['name'];
    final l$displayValues = json['displayValues'];
    return Fragment$PrimitiveFilterDto$$SelectFilter(
      $__typename: (l$$__typename as String),
      selectState: (l$selectState as int),
      name: (l$name as String),
      displayValues:
          (l$displayValues as List<dynamic>).map((e) => (e as String)).toList(),
    );
  }

  final String $__typename;

  final int selectState;

  final String name;

  final List<String> displayValues;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$selectState = selectState;
    _resultData['selectState'] = l$selectState;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$displayValues = displayValues;
    _resultData['displayValues'] = l$displayValues.map((e) => e).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$selectState = selectState;
    final l$name = name;
    final l$displayValues = displayValues;
    return Object.hashAll([
      l$$__typename,
      l$selectState,
      l$name,
      Object.hashAll(l$displayValues.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$SelectFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$selectState = selectState;
    final lOther$selectState = other.selectState;
    if (l$selectState != lOther$selectState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$displayValues = displayValues;
    final lOther$displayValues = other.displayValues;
    if (l$displayValues.length != lOther$displayValues.length) {
      return false;
    }
    for (int i = 0; i < l$displayValues.length; i++) {
      final l$displayValues$entry = l$displayValues[i];
      final lOther$displayValues$entry = lOther$displayValues[i];
      if (l$displayValues$entry != lOther$displayValues$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$SelectFilter
    on Fragment$PrimitiveFilterDto$$SelectFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter<
          Fragment$PrimitiveFilterDto$$SelectFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter(
    Fragment$PrimitiveFilterDto$$SelectFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$SelectFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$SelectFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SelectFilter;

  TRes call({
    String? $__typename,
    int? selectState,
    String? name,
    List<String>? displayValues,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$SelectFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$SelectFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$SelectFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$SelectFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? selectState = _undefined,
    Object? name = _undefined,
    Object? displayValues = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$SelectFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        selectState: selectState == _undefined || selectState == null
            ? _instance.selectState
            : (selectState as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        displayValues: displayValues == _undefined || displayValues == null
            ? _instance.displayValues
            : (displayValues as List<String>),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SelectFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SelectFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SelectFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    int? selectState,
    String? name,
    List<String>? displayValues,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$TriStateFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$TriStateFilter({
    this.$__typename = 'TriStateFilter',
    required this.tristate,
    required this.name,
  });

  factory Fragment$PrimitiveFilterDto$$TriStateFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$tristate = json['tristate'];
    final l$name = json['name'];
    return Fragment$PrimitiveFilterDto$$TriStateFilter(
      $__typename: (l$$__typename as String),
      tristate: fromJson$Enum$TriState((l$tristate as String)),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final Enum$TriState tristate;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$tristate = tristate;
    _resultData['tristate'] = toJson$Enum$TriState(l$tristate);
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$tristate = tristate;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$tristate,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$TriStateFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$tristate = tristate;
    final lOther$tristate = other.tristate;
    if (l$tristate != lOther$tristate) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$TriStateFilter
    on Fragment$PrimitiveFilterDto$$TriStateFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter<
          Fragment$PrimitiveFilterDto$$TriStateFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter(
    Fragment$PrimitiveFilterDto$$TriStateFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$TriStateFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$TriStateFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TriStateFilter;

  TRes call({
    String? $__typename,
    Enum$TriState? tristate,
    String? name,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$TriStateFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$TriStateFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$TriStateFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$TriStateFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? tristate = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$TriStateFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        tristate: tristate == _undefined || tristate == null
            ? _instance.tristate
            : (tristate as Enum$TriState),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TriStateFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$TriStateFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TriStateFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    Enum$TriState? tristate,
    String? name,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$TextFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$TextFilter({
    this.$__typename = 'TextFilter',
    required this.textState,
    required this.name,
  });

  factory Fragment$PrimitiveFilterDto$$TextFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$textState = json['textState'];
    final l$name = json['name'];
    return Fragment$PrimitiveFilterDto$$TextFilter(
      $__typename: (l$$__typename as String),
      textState: (l$textState as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String textState;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$textState = textState;
    _resultData['textState'] = l$textState;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$textState = textState;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$textState,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$TextFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$textState = textState;
    final lOther$textState = other.textState;
    if (l$textState != lOther$textState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$TextFilter
    on Fragment$PrimitiveFilterDto$$TextFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$TextFilter<
          Fragment$PrimitiveFilterDto$$TextFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$TextFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$TextFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$TextFilter(
    Fragment$PrimitiveFilterDto$$TextFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$TextFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$TextFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$TextFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TextFilter;

  TRes call({
    String? $__typename,
    String? textState,
    String? name,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$TextFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$TextFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$TextFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$TextFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$TextFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? textState = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$TextFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        textState: textState == _undefined || textState == null
            ? _instance.textState
            : (textState as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TextFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$TextFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$TextFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? textState,
    String? name,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$SortFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$SortFilter({
    this.$__typename = 'SortFilter',
    this.sortState,
    required this.name,
    required this.displayValues,
  });

  factory Fragment$PrimitiveFilterDto$$SortFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$sortState = json['sortState'];
    final l$name = json['name'];
    final l$displayValues = json['displayValues'];
    return Fragment$PrimitiveFilterDto$$SortFilter(
      $__typename: (l$$__typename as String),
      sortState: l$sortState == null
          ? null
          : Fragment$SortSelectionDto.fromJson(
              (l$sortState as Map<String, dynamic>)),
      name: (l$name as String),
      displayValues:
          (l$displayValues as List<dynamic>).map((e) => (e as String)).toList(),
    );
  }

  final String $__typename;

  final Fragment$SortSelectionDto? sortState;

  final String name;

  final List<String> displayValues;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$sortState = sortState;
    _resultData['sortState'] = l$sortState?.toJson();
    final l$name = name;
    _resultData['name'] = l$name;
    final l$displayValues = displayValues;
    _resultData['displayValues'] = l$displayValues.map((e) => e).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$sortState = sortState;
    final l$name = name;
    final l$displayValues = displayValues;
    return Object.hashAll([
      l$$__typename,
      l$sortState,
      l$name,
      Object.hashAll(l$displayValues.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$SortFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$sortState = sortState;
    final lOther$sortState = other.sortState;
    if (l$sortState != lOther$sortState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$displayValues = displayValues;
    final lOther$displayValues = other.displayValues;
    if (l$displayValues.length != lOther$displayValues.length) {
      return false;
    }
    for (int i = 0; i < l$displayValues.length; i++) {
      final l$displayValues$entry = l$displayValues[i];
      final lOther$displayValues$entry = lOther$displayValues[i];
      if (l$displayValues$entry != lOther$displayValues$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$SortFilter
    on Fragment$PrimitiveFilterDto$$SortFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$SortFilter<
          Fragment$PrimitiveFilterDto$$SortFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$SortFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$SortFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$SortFilter(
    Fragment$PrimitiveFilterDto$$SortFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$SortFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$SortFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$SortFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SortFilter;

  TRes call({
    String? $__typename,
    Fragment$SortSelectionDto? sortState,
    String? name,
    List<String>? displayValues,
  });
  CopyWith$Fragment$SortSelectionDto<TRes> get sortState;
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$SortFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SortFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$SortFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$SortFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$SortFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? sortState = _undefined,
    Object? name = _undefined,
    Object? displayValues = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$SortFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        sortState: sortState == _undefined
            ? _instance.sortState
            : (sortState as Fragment$SortSelectionDto?),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        displayValues: displayValues == _undefined || displayValues == null
            ? _instance.displayValues
            : (displayValues as List<String>),
      ));

  CopyWith$Fragment$SortSelectionDto<TRes> get sortState {
    final local$sortState = _instance.sortState;
    return local$sortState == null
        ? CopyWith$Fragment$SortSelectionDto.stub(_then(_instance))
        : CopyWith$Fragment$SortSelectionDto(
            local$sortState, (e) => call(sortState: e));
  }
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SortFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SortFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SortFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    Fragment$SortSelectionDto? sortState,
    String? name,
    List<String>? displayValues,
  }) =>
      _res;

  CopyWith$Fragment$SortSelectionDto<TRes> get sortState =>
      CopyWith$Fragment$SortSelectionDto.stub(_res);
}

class Fragment$PrimitiveFilterDto$$SeparatorFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$SeparatorFilter({
    this.$__typename = 'SeparatorFilter',
    required this.name,
  });

  factory Fragment$PrimitiveFilterDto$$SeparatorFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$name = json['name'];
    return Fragment$PrimitiveFilterDto$$SeparatorFilter(
      $__typename: (l$$__typename as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$SeparatorFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$SeparatorFilter
    on Fragment$PrimitiveFilterDto$$SeparatorFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter<
          Fragment$PrimitiveFilterDto$$SeparatorFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter(
    Fragment$PrimitiveFilterDto$$SeparatorFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$SeparatorFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter;

  TRes call({
    String? $__typename,
    String? name,
  });
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$SeparatorFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$SeparatorFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$PrimitiveFilterDto$$SeparatorFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$SeparatorFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$SeparatorFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? name,
  }) =>
      _res;
}

class Fragment$PrimitiveFilterDto$$GroupFilter
    implements Fragment$PrimitiveFilterDto {
  Fragment$PrimitiveFilterDto$$GroupFilter({this.$__typename = 'GroupFilter'});

  factory Fragment$PrimitiveFilterDto$$GroupFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Fragment$PrimitiveFilterDto$$GroupFilter(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PrimitiveFilterDto$$GroupFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PrimitiveFilterDto$$GroupFilter
    on Fragment$PrimitiveFilterDto$$GroupFilter {
  CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter<
          Fragment$PrimitiveFilterDto$$GroupFilter>
      get copyWith => CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter<TRes> {
  factory CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter(
    Fragment$PrimitiveFilterDto$$GroupFilter instance,
    TRes Function(Fragment$PrimitiveFilterDto$$GroupFilter) then,
  ) = _CopyWithImpl$Fragment$PrimitiveFilterDto$$GroupFilter;

  factory CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$GroupFilter;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$PrimitiveFilterDto$$GroupFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter<TRes> {
  _CopyWithImpl$Fragment$PrimitiveFilterDto$$GroupFilter(
    this._instance,
    this._then,
  );

  final Fragment$PrimitiveFilterDto$$GroupFilter _instance;

  final TRes Function(Fragment$PrimitiveFilterDto$$GroupFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Fragment$PrimitiveFilterDto$$GroupFilter(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$GroupFilter<TRes>
    implements CopyWith$Fragment$PrimitiveFilterDto$$GroupFilter<TRes> {
  _CopyWithStubImpl$Fragment$PrimitiveFilterDto$$GroupFilter(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Fragment$FilterDto implements Fragment$PrimitiveFilterDto {
  Fragment$FilterDto({required this.$__typename});

  factory Fragment$FilterDto.fromJson(Map<String, dynamic> json) {
    switch (json["__typename"] as String) {
      case "CheckBoxFilter":
        return Fragment$FilterDto$$CheckBoxFilter.fromJson(json);

      case "HeaderFilter":
        return Fragment$FilterDto$$HeaderFilter.fromJson(json);

      case "SelectFilter":
        return Fragment$FilterDto$$SelectFilter.fromJson(json);

      case "TriStateFilter":
        return Fragment$FilterDto$$TriStateFilter.fromJson(json);

      case "TextFilter":
        return Fragment$FilterDto$$TextFilter.fromJson(json);

      case "SortFilter":
        return Fragment$FilterDto$$SortFilter.fromJson(json);

      case "SeparatorFilter":
        return Fragment$FilterDto$$SeparatorFilter.fromJson(json);

      case "GroupFilter":
        return Fragment$FilterDto$$GroupFilter.fromJson(json);

      default:
        final l$$__typename = json['__typename'];
        return Fragment$FilterDto($__typename: (l$$__typename as String));
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto on Fragment$FilterDto {
  CopyWith$Fragment$FilterDto<Fragment$FilterDto> get copyWith =>
      CopyWith$Fragment$FilterDto(
        this,
        (i) => i,
      );

  _T when<_T>({
    required _T Function(Fragment$FilterDto$$CheckBoxFilter) checkBoxFilter,
    required _T Function(Fragment$FilterDto$$HeaderFilter) headerFilter,
    required _T Function(Fragment$FilterDto$$SelectFilter) selectFilter,
    required _T Function(Fragment$FilterDto$$TriStateFilter) triStateFilter,
    required _T Function(Fragment$FilterDto$$TextFilter) textFilter,
    required _T Function(Fragment$FilterDto$$SortFilter) sortFilter,
    required _T Function(Fragment$FilterDto$$SeparatorFilter) separatorFilter,
    required _T Function(Fragment$FilterDto$$GroupFilter) groupFilter,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxFilter":
        return checkBoxFilter(this as Fragment$FilterDto$$CheckBoxFilter);

      case "HeaderFilter":
        return headerFilter(this as Fragment$FilterDto$$HeaderFilter);

      case "SelectFilter":
        return selectFilter(this as Fragment$FilterDto$$SelectFilter);

      case "TriStateFilter":
        return triStateFilter(this as Fragment$FilterDto$$TriStateFilter);

      case "TextFilter":
        return textFilter(this as Fragment$FilterDto$$TextFilter);

      case "SortFilter":
        return sortFilter(this as Fragment$FilterDto$$SortFilter);

      case "SeparatorFilter":
        return separatorFilter(this as Fragment$FilterDto$$SeparatorFilter);

      case "GroupFilter":
        return groupFilter(this as Fragment$FilterDto$$GroupFilter);

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Fragment$FilterDto$$CheckBoxFilter)? checkBoxFilter,
    _T Function(Fragment$FilterDto$$HeaderFilter)? headerFilter,
    _T Function(Fragment$FilterDto$$SelectFilter)? selectFilter,
    _T Function(Fragment$FilterDto$$TriStateFilter)? triStateFilter,
    _T Function(Fragment$FilterDto$$TextFilter)? textFilter,
    _T Function(Fragment$FilterDto$$SortFilter)? sortFilter,
    _T Function(Fragment$FilterDto$$SeparatorFilter)? separatorFilter,
    _T Function(Fragment$FilterDto$$GroupFilter)? groupFilter,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxFilter":
        if (checkBoxFilter != null) {
          return checkBoxFilter(this as Fragment$FilterDto$$CheckBoxFilter);
        } else {
          return orElse();
        }

      case "HeaderFilter":
        if (headerFilter != null) {
          return headerFilter(this as Fragment$FilterDto$$HeaderFilter);
        } else {
          return orElse();
        }

      case "SelectFilter":
        if (selectFilter != null) {
          return selectFilter(this as Fragment$FilterDto$$SelectFilter);
        } else {
          return orElse();
        }

      case "TriStateFilter":
        if (triStateFilter != null) {
          return triStateFilter(this as Fragment$FilterDto$$TriStateFilter);
        } else {
          return orElse();
        }

      case "TextFilter":
        if (textFilter != null) {
          return textFilter(this as Fragment$FilterDto$$TextFilter);
        } else {
          return orElse();
        }

      case "SortFilter":
        if (sortFilter != null) {
          return sortFilter(this as Fragment$FilterDto$$SortFilter);
        } else {
          return orElse();
        }

      case "SeparatorFilter":
        if (separatorFilter != null) {
          return separatorFilter(this as Fragment$FilterDto$$SeparatorFilter);
        } else {
          return orElse();
        }

      case "GroupFilter":
        if (groupFilter != null) {
          return groupFilter(this as Fragment$FilterDto$$GroupFilter);
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Fragment$FilterDto<TRes> {
  factory CopyWith$Fragment$FilterDto(
    Fragment$FilterDto instance,
    TRes Function(Fragment$FilterDto) then,
  ) = _CopyWithImpl$Fragment$FilterDto;

  factory CopyWith$Fragment$FilterDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$FilterDto<TRes>
    implements CopyWith$Fragment$FilterDto<TRes> {
  _CopyWithImpl$Fragment$FilterDto(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto _instance;

  final TRes Function(Fragment$FilterDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(Fragment$FilterDto(
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String)));
}

class _CopyWithStubImpl$Fragment$FilterDto<TRes>
    implements CopyWith$Fragment$FilterDto<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

const fragmentDefinitionFilterDto = FragmentDefinitionNode(
  name: NameNode(value: 'FilterDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Filter'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FragmentSpreadNode(
      name: NameNode(value: 'PrimitiveFilterDto'),
      directives: [],
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'GroupFilter'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'filters'),
          alias: NameNode(value: 'groupState'),
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'PrimitiveFilterDto'),
              directives: [],
            ),
            FieldNode(
              name: NameNode(value: '__typename'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
          ]),
        ),
      ]),
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentFilterDto = DocumentNode(definitions: [
  fragmentDefinitionFilterDto,
  fragmentDefinitionPrimitiveFilterDto,
  fragmentDefinitionSortSelectionDto,
]);

extension ClientExtension$Fragment$FilterDto on graphql.GraphQLClient {
  void writeFragment$FilterDto({
    required Fragment$FilterDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'FilterDto',
            document: documentNodeFragmentFilterDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$FilterDto? readFragment$FilterDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'FilterDto',
          document: documentNodeFragmentFilterDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$FilterDto.fromJson(result);
  }
}

class Fragment$FilterDto$$CheckBoxFilter
    implements Fragment$PrimitiveFilterDto$$CheckBoxFilter, Fragment$FilterDto {
  Fragment$FilterDto$$CheckBoxFilter({
    this.$__typename = 'CheckBoxFilter',
    required this.checkBoxState,
    required this.name,
  });

  factory Fragment$FilterDto$$CheckBoxFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$checkBoxState = json['checkBoxState'];
    final l$name = json['name'];
    return Fragment$FilterDto$$CheckBoxFilter(
      $__typename: (l$$__typename as String),
      checkBoxState: (l$checkBoxState as bool),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final bool checkBoxState;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$checkBoxState = checkBoxState;
    _resultData['checkBoxState'] = l$checkBoxState;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$checkBoxState = checkBoxState;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$checkBoxState,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$CheckBoxFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$checkBoxState = checkBoxState;
    final lOther$checkBoxState = other.checkBoxState;
    if (l$checkBoxState != lOther$checkBoxState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$CheckBoxFilter
    on Fragment$FilterDto$$CheckBoxFilter {
  CopyWith$Fragment$FilterDto$$CheckBoxFilter<
          Fragment$FilterDto$$CheckBoxFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$CheckBoxFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$CheckBoxFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$CheckBoxFilter(
    Fragment$FilterDto$$CheckBoxFilter instance,
    TRes Function(Fragment$FilterDto$$CheckBoxFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$CheckBoxFilter;

  factory CopyWith$Fragment$FilterDto$$CheckBoxFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$CheckBoxFilter;

  TRes call({
    String? $__typename,
    bool? checkBoxState,
    String? name,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$CheckBoxFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$CheckBoxFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$CheckBoxFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$CheckBoxFilter _instance;

  final TRes Function(Fragment$FilterDto$$CheckBoxFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? checkBoxState = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$FilterDto$$CheckBoxFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        checkBoxState: checkBoxState == _undefined || checkBoxState == null
            ? _instance.checkBoxState
            : (checkBoxState as bool),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$CheckBoxFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$CheckBoxFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$CheckBoxFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    bool? checkBoxState,
    String? name,
  }) =>
      _res;
}

class Fragment$FilterDto$$HeaderFilter
    implements Fragment$PrimitiveFilterDto$$HeaderFilter, Fragment$FilterDto {
  Fragment$FilterDto$$HeaderFilter({
    this.$__typename = 'HeaderFilter',
    required this.name,
  });

  factory Fragment$FilterDto$$HeaderFilter.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$name = json['name'];
    return Fragment$FilterDto$$HeaderFilter(
      $__typename: (l$$__typename as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$HeaderFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$HeaderFilter
    on Fragment$FilterDto$$HeaderFilter {
  CopyWith$Fragment$FilterDto$$HeaderFilter<Fragment$FilterDto$$HeaderFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$HeaderFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$HeaderFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$HeaderFilter(
    Fragment$FilterDto$$HeaderFilter instance,
    TRes Function(Fragment$FilterDto$$HeaderFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$HeaderFilter;

  factory CopyWith$Fragment$FilterDto$$HeaderFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$HeaderFilter;

  TRes call({
    String? $__typename,
    String? name,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$HeaderFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$HeaderFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$HeaderFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$HeaderFilter _instance;

  final TRes Function(Fragment$FilterDto$$HeaderFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$FilterDto$$HeaderFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$HeaderFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$HeaderFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$HeaderFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? name,
  }) =>
      _res;
}

class Fragment$FilterDto$$SelectFilter
    implements Fragment$PrimitiveFilterDto$$SelectFilter, Fragment$FilterDto {
  Fragment$FilterDto$$SelectFilter({
    this.$__typename = 'SelectFilter',
    required this.selectState,
    required this.name,
    required this.displayValues,
  });

  factory Fragment$FilterDto$$SelectFilter.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$selectState = json['selectState'];
    final l$name = json['name'];
    final l$displayValues = json['displayValues'];
    return Fragment$FilterDto$$SelectFilter(
      $__typename: (l$$__typename as String),
      selectState: (l$selectState as int),
      name: (l$name as String),
      displayValues:
          (l$displayValues as List<dynamic>).map((e) => (e as String)).toList(),
    );
  }

  final String $__typename;

  final int selectState;

  final String name;

  final List<String> displayValues;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$selectState = selectState;
    _resultData['selectState'] = l$selectState;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$displayValues = displayValues;
    _resultData['displayValues'] = l$displayValues.map((e) => e).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$selectState = selectState;
    final l$name = name;
    final l$displayValues = displayValues;
    return Object.hashAll([
      l$$__typename,
      l$selectState,
      l$name,
      Object.hashAll(l$displayValues.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$SelectFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$selectState = selectState;
    final lOther$selectState = other.selectState;
    if (l$selectState != lOther$selectState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$displayValues = displayValues;
    final lOther$displayValues = other.displayValues;
    if (l$displayValues.length != lOther$displayValues.length) {
      return false;
    }
    for (int i = 0; i < l$displayValues.length; i++) {
      final l$displayValues$entry = l$displayValues[i];
      final lOther$displayValues$entry = lOther$displayValues[i];
      if (l$displayValues$entry != lOther$displayValues$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$SelectFilter
    on Fragment$FilterDto$$SelectFilter {
  CopyWith$Fragment$FilterDto$$SelectFilter<Fragment$FilterDto$$SelectFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$SelectFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$SelectFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$SelectFilter(
    Fragment$FilterDto$$SelectFilter instance,
    TRes Function(Fragment$FilterDto$$SelectFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$SelectFilter;

  factory CopyWith$Fragment$FilterDto$$SelectFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$SelectFilter;

  TRes call({
    String? $__typename,
    int? selectState,
    String? name,
    List<String>? displayValues,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$SelectFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SelectFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$SelectFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$SelectFilter _instance;

  final TRes Function(Fragment$FilterDto$$SelectFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? selectState = _undefined,
    Object? name = _undefined,
    Object? displayValues = _undefined,
  }) =>
      _then(Fragment$FilterDto$$SelectFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        selectState: selectState == _undefined || selectState == null
            ? _instance.selectState
            : (selectState as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        displayValues: displayValues == _undefined || displayValues == null
            ? _instance.displayValues
            : (displayValues as List<String>),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$SelectFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SelectFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$SelectFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    int? selectState,
    String? name,
    List<String>? displayValues,
  }) =>
      _res;
}

class Fragment$FilterDto$$TriStateFilter
    implements Fragment$PrimitiveFilterDto$$TriStateFilter, Fragment$FilterDto {
  Fragment$FilterDto$$TriStateFilter({
    this.$__typename = 'TriStateFilter',
    required this.tristate,
    required this.name,
  });

  factory Fragment$FilterDto$$TriStateFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$tristate = json['tristate'];
    final l$name = json['name'];
    return Fragment$FilterDto$$TriStateFilter(
      $__typename: (l$$__typename as String),
      tristate: fromJson$Enum$TriState((l$tristate as String)),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final Enum$TriState tristate;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$tristate = tristate;
    _resultData['tristate'] = toJson$Enum$TriState(l$tristate);
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$tristate = tristate;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$tristate,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$TriStateFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$tristate = tristate;
    final lOther$tristate = other.tristate;
    if (l$tristate != lOther$tristate) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$TriStateFilter
    on Fragment$FilterDto$$TriStateFilter {
  CopyWith$Fragment$FilterDto$$TriStateFilter<
          Fragment$FilterDto$$TriStateFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$TriStateFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$TriStateFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$TriStateFilter(
    Fragment$FilterDto$$TriStateFilter instance,
    TRes Function(Fragment$FilterDto$$TriStateFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$TriStateFilter;

  factory CopyWith$Fragment$FilterDto$$TriStateFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$TriStateFilter;

  TRes call({
    String? $__typename,
    Enum$TriState? tristate,
    String? name,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$TriStateFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$TriStateFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$TriStateFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$TriStateFilter _instance;

  final TRes Function(Fragment$FilterDto$$TriStateFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? tristate = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$FilterDto$$TriStateFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        tristate: tristate == _undefined || tristate == null
            ? _instance.tristate
            : (tristate as Enum$TriState),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$TriStateFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$TriStateFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$TriStateFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    Enum$TriState? tristate,
    String? name,
  }) =>
      _res;
}

class Fragment$FilterDto$$TextFilter
    implements Fragment$PrimitiveFilterDto$$TextFilter, Fragment$FilterDto {
  Fragment$FilterDto$$TextFilter({
    this.$__typename = 'TextFilter',
    required this.textState,
    required this.name,
  });

  factory Fragment$FilterDto$$TextFilter.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$textState = json['textState'];
    final l$name = json['name'];
    return Fragment$FilterDto$$TextFilter(
      $__typename: (l$$__typename as String),
      textState: (l$textState as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String textState;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$textState = textState;
    _resultData['textState'] = l$textState;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$textState = textState;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$textState,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$TextFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$textState = textState;
    final lOther$textState = other.textState;
    if (l$textState != lOther$textState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$TextFilter
    on Fragment$FilterDto$$TextFilter {
  CopyWith$Fragment$FilterDto$$TextFilter<Fragment$FilterDto$$TextFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$TextFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$TextFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$TextFilter(
    Fragment$FilterDto$$TextFilter instance,
    TRes Function(Fragment$FilterDto$$TextFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$TextFilter;

  factory CopyWith$Fragment$FilterDto$$TextFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$TextFilter;

  TRes call({
    String? $__typename,
    String? textState,
    String? name,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$TextFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$TextFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$TextFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$TextFilter _instance;

  final TRes Function(Fragment$FilterDto$$TextFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? textState = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$FilterDto$$TextFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        textState: textState == _undefined || textState == null
            ? _instance.textState
            : (textState as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$TextFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$TextFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$TextFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? textState,
    String? name,
  }) =>
      _res;
}

class Fragment$FilterDto$$SortFilter
    implements Fragment$PrimitiveFilterDto$$SortFilter, Fragment$FilterDto {
  Fragment$FilterDto$$SortFilter({
    this.$__typename = 'SortFilter',
    this.sortState,
    required this.name,
    required this.displayValues,
  });

  factory Fragment$FilterDto$$SortFilter.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$sortState = json['sortState'];
    final l$name = json['name'];
    final l$displayValues = json['displayValues'];
    return Fragment$FilterDto$$SortFilter(
      $__typename: (l$$__typename as String),
      sortState: l$sortState == null
          ? null
          : Fragment$SortSelectionDto.fromJson(
              (l$sortState as Map<String, dynamic>)),
      name: (l$name as String),
      displayValues:
          (l$displayValues as List<dynamic>).map((e) => (e as String)).toList(),
    );
  }

  final String $__typename;

  final Fragment$SortSelectionDto? sortState;

  final String name;

  final List<String> displayValues;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$sortState = sortState;
    _resultData['sortState'] = l$sortState?.toJson();
    final l$name = name;
    _resultData['name'] = l$name;
    final l$displayValues = displayValues;
    _resultData['displayValues'] = l$displayValues.map((e) => e).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$sortState = sortState;
    final l$name = name;
    final l$displayValues = displayValues;
    return Object.hashAll([
      l$$__typename,
      l$sortState,
      l$name,
      Object.hashAll(l$displayValues.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$SortFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$sortState = sortState;
    final lOther$sortState = other.sortState;
    if (l$sortState != lOther$sortState) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$displayValues = displayValues;
    final lOther$displayValues = other.displayValues;
    if (l$displayValues.length != lOther$displayValues.length) {
      return false;
    }
    for (int i = 0; i < l$displayValues.length; i++) {
      final l$displayValues$entry = l$displayValues[i];
      final lOther$displayValues$entry = lOther$displayValues[i];
      if (l$displayValues$entry != lOther$displayValues$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$SortFilter
    on Fragment$FilterDto$$SortFilter {
  CopyWith$Fragment$FilterDto$$SortFilter<Fragment$FilterDto$$SortFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$SortFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$SortFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$SortFilter(
    Fragment$FilterDto$$SortFilter instance,
    TRes Function(Fragment$FilterDto$$SortFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$SortFilter;

  factory CopyWith$Fragment$FilterDto$$SortFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$SortFilter;

  TRes call({
    String? $__typename,
    Fragment$SortSelectionDto? sortState,
    String? name,
    List<String>? displayValues,
  });
  CopyWith$Fragment$SortSelectionDto<TRes> get sortState;
}

class _CopyWithImpl$Fragment$FilterDto$$SortFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SortFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$SortFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$SortFilter _instance;

  final TRes Function(Fragment$FilterDto$$SortFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? sortState = _undefined,
    Object? name = _undefined,
    Object? displayValues = _undefined,
  }) =>
      _then(Fragment$FilterDto$$SortFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        sortState: sortState == _undefined
            ? _instance.sortState
            : (sortState as Fragment$SortSelectionDto?),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        displayValues: displayValues == _undefined || displayValues == null
            ? _instance.displayValues
            : (displayValues as List<String>),
      ));

  CopyWith$Fragment$SortSelectionDto<TRes> get sortState {
    final local$sortState = _instance.sortState;
    return local$sortState == null
        ? CopyWith$Fragment$SortSelectionDto.stub(_then(_instance))
        : CopyWith$Fragment$SortSelectionDto(
            local$sortState, (e) => call(sortState: e));
  }
}

class _CopyWithStubImpl$Fragment$FilterDto$$SortFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SortFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$SortFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    Fragment$SortSelectionDto? sortState,
    String? name,
    List<String>? displayValues,
  }) =>
      _res;

  CopyWith$Fragment$SortSelectionDto<TRes> get sortState =>
      CopyWith$Fragment$SortSelectionDto.stub(_res);
}

class Fragment$FilterDto$$SeparatorFilter
    implements
        Fragment$PrimitiveFilterDto$$SeparatorFilter,
        Fragment$FilterDto {
  Fragment$FilterDto$$SeparatorFilter({
    this.$__typename = 'SeparatorFilter',
    required this.name,
  });

  factory Fragment$FilterDto$$SeparatorFilter.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$name = json['name'];
    return Fragment$FilterDto$$SeparatorFilter(
      $__typename: (l$$__typename as String),
      name: (l$name as String),
    );
  }

  final String $__typename;

  final String name;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$name = name;
    _resultData['name'] = l$name;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$name = name;
    return Object.hashAll([
      l$$__typename,
      l$name,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$SeparatorFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$SeparatorFilter
    on Fragment$FilterDto$$SeparatorFilter {
  CopyWith$Fragment$FilterDto$$SeparatorFilter<
          Fragment$FilterDto$$SeparatorFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$SeparatorFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$SeparatorFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$SeparatorFilter(
    Fragment$FilterDto$$SeparatorFilter instance,
    TRes Function(Fragment$FilterDto$$SeparatorFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$SeparatorFilter;

  factory CopyWith$Fragment$FilterDto$$SeparatorFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$SeparatorFilter;

  TRes call({
    String? $__typename,
    String? name,
  });
}

class _CopyWithImpl$Fragment$FilterDto$$SeparatorFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SeparatorFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$SeparatorFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$SeparatorFilter _instance;

  final TRes Function(Fragment$FilterDto$$SeparatorFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? name = _undefined,
  }) =>
      _then(Fragment$FilterDto$$SeparatorFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
      ));
}

class _CopyWithStubImpl$Fragment$FilterDto$$SeparatorFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$SeparatorFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$SeparatorFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? name,
  }) =>
      _res;
}

class Fragment$FilterDto$$GroupFilter
    implements Fragment$PrimitiveFilterDto$$GroupFilter, Fragment$FilterDto {
  Fragment$FilterDto$$GroupFilter({
    this.$__typename = 'GroupFilter',
    required this.name,
    required this.groupState,
  });

  factory Fragment$FilterDto$$GroupFilter.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    final l$name = json['name'];
    final l$groupState = json['groupState'];
    return Fragment$FilterDto$$GroupFilter(
      $__typename: (l$$__typename as String),
      name: (l$name as String),
      groupState: (l$groupState as List<dynamic>)
          .map((e) =>
              Fragment$PrimitiveFilterDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  final String $__typename;

  final String name;

  final List<Fragment$PrimitiveFilterDto> groupState;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$groupState = groupState;
    _resultData['groupState'] = l$groupState.map((e) => e.toJson()).toList();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    final l$name = name;
    final l$groupState = groupState;
    return Object.hashAll([
      l$$__typename,
      l$name,
      Object.hashAll(l$groupState.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$FilterDto$$GroupFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$groupState = groupState;
    final lOther$groupState = other.groupState;
    if (l$groupState.length != lOther$groupState.length) {
      return false;
    }
    for (int i = 0; i < l$groupState.length; i++) {
      final l$groupState$entry = l$groupState[i];
      final lOther$groupState$entry = lOther$groupState[i];
      if (l$groupState$entry != lOther$groupState$entry) {
        return false;
      }
    }
    return true;
  }
}

extension UtilityExtension$Fragment$FilterDto$$GroupFilter
    on Fragment$FilterDto$$GroupFilter {
  CopyWith$Fragment$FilterDto$$GroupFilter<Fragment$FilterDto$$GroupFilter>
      get copyWith => CopyWith$Fragment$FilterDto$$GroupFilter(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$FilterDto$$GroupFilter<TRes> {
  factory CopyWith$Fragment$FilterDto$$GroupFilter(
    Fragment$FilterDto$$GroupFilter instance,
    TRes Function(Fragment$FilterDto$$GroupFilter) then,
  ) = _CopyWithImpl$Fragment$FilterDto$$GroupFilter;

  factory CopyWith$Fragment$FilterDto$$GroupFilter.stub(TRes res) =
      _CopyWithStubImpl$Fragment$FilterDto$$GroupFilter;

  TRes call({
    String? $__typename,
    String? name,
    List<Fragment$PrimitiveFilterDto>? groupState,
  });
  TRes groupState(
      Iterable<Fragment$PrimitiveFilterDto> Function(
              Iterable<
                  CopyWith$Fragment$PrimitiveFilterDto<
                      Fragment$PrimitiveFilterDto>>)
          _fn);
}

class _CopyWithImpl$Fragment$FilterDto$$GroupFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$GroupFilter<TRes> {
  _CopyWithImpl$Fragment$FilterDto$$GroupFilter(
    this._instance,
    this._then,
  );

  final Fragment$FilterDto$$GroupFilter _instance;

  final TRes Function(Fragment$FilterDto$$GroupFilter) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? $__typename = _undefined,
    Object? name = _undefined,
    Object? groupState = _undefined,
  }) =>
      _then(Fragment$FilterDto$$GroupFilter(
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        groupState: groupState == _undefined || groupState == null
            ? _instance.groupState
            : (groupState as List<Fragment$PrimitiveFilterDto>),
      ));

  TRes groupState(
          Iterable<Fragment$PrimitiveFilterDto> Function(
                  Iterable<
                      CopyWith$Fragment$PrimitiveFilterDto<
                          Fragment$PrimitiveFilterDto>>)
              _fn) =>
      call(
          groupState: _fn(_instance.groupState
              .map((e) => CopyWith$Fragment$PrimitiveFilterDto(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Fragment$FilterDto$$GroupFilter<TRes>
    implements CopyWith$Fragment$FilterDto$$GroupFilter<TRes> {
  _CopyWithStubImpl$Fragment$FilterDto$$GroupFilter(this._res);

  TRes _res;

  call({
    String? $__typename,
    String? name,
    List<Fragment$PrimitiveFilterDto>? groupState,
  }) =>
      _res;

  groupState(_fn) => _res;
}

class Fragment$SortSelectionDto {
  Fragment$SortSelectionDto({
    required this.ascending,
    required this.index,
    this.$__typename = 'SortSelection',
  });

  factory Fragment$SortSelectionDto.fromJson(Map<String, dynamic> json) {
    final l$ascending = json['ascending'];
    final l$index = json['index'];
    final l$$__typename = json['__typename'];
    return Fragment$SortSelectionDto(
      ascending: (l$ascending as bool),
      index: (l$index as int),
      $__typename: (l$$__typename as String),
    );
  }

  final bool ascending;

  final int index;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$ascending = ascending;
    _resultData['ascending'] = l$ascending;
    final l$index = index;
    _resultData['index'] = l$index;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$ascending = ascending;
    final l$index = index;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$ascending,
      l$index,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SortSelectionDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ascending = ascending;
    final lOther$ascending = other.ascending;
    if (l$ascending != lOther$ascending) {
      return false;
    }
    final l$index = index;
    final lOther$index = other.index;
    if (l$index != lOther$index) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SortSelectionDto
    on Fragment$SortSelectionDto {
  CopyWith$Fragment$SortSelectionDto<Fragment$SortSelectionDto> get copyWith =>
      CopyWith$Fragment$SortSelectionDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$SortSelectionDto<TRes> {
  factory CopyWith$Fragment$SortSelectionDto(
    Fragment$SortSelectionDto instance,
    TRes Function(Fragment$SortSelectionDto) then,
  ) = _CopyWithImpl$Fragment$SortSelectionDto;

  factory CopyWith$Fragment$SortSelectionDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SortSelectionDto;

  TRes call({
    bool? ascending,
    int? index,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SortSelectionDto<TRes>
    implements CopyWith$Fragment$SortSelectionDto<TRes> {
  _CopyWithImpl$Fragment$SortSelectionDto(
    this._instance,
    this._then,
  );

  final Fragment$SortSelectionDto _instance;

  final TRes Function(Fragment$SortSelectionDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? ascending = _undefined,
    Object? index = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SortSelectionDto(
        ascending: ascending == _undefined || ascending == null
            ? _instance.ascending
            : (ascending as bool),
        index: index == _undefined || index == null
            ? _instance.index
            : (index as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SortSelectionDto<TRes>
    implements CopyWith$Fragment$SortSelectionDto<TRes> {
  _CopyWithStubImpl$Fragment$SortSelectionDto(this._res);

  TRes _res;

  call({
    bool? ascending,
    int? index,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionSortSelectionDto = FragmentDefinitionNode(
  name: NameNode(value: 'SortSelectionDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SortSelection'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'ascending'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'index'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentSortSelectionDto = DocumentNode(definitions: [
  fragmentDefinitionSortSelectionDto,
]);

extension ClientExtension$Fragment$SortSelectionDto on graphql.GraphQLClient {
  void writeFragment$SortSelectionDto({
    required Fragment$SortSelectionDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SortSelectionDto',
            document: documentNodeFragmentSortSelectionDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SortSelectionDto? readFragment$SortSelectionDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SortSelectionDto',
          document: documentNodeFragmentSortSelectionDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SortSelectionDto.fromJson(result);
  }
}
