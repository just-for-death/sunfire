import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$SourcePreference {
  Fragment$SourcePreference({required this.$__typename});

  factory Fragment$SourcePreference.fromJson(Map<String, dynamic> json) {
    switch (json["__typename"] as String) {
      case "CheckBoxPreference":
        return Fragment$SourcePreference$$CheckBoxPreference.fromJson(json);

      case "EditTextPreference":
        return Fragment$SourcePreference$$EditTextPreference.fromJson(json);

      case "SwitchPreference":
        return Fragment$SourcePreference$$SwitchPreference.fromJson(json);

      case "MultiSelectListPreference":
        return Fragment$SourcePreference$$MultiSelectListPreference.fromJson(
            json);

      case "ListPreference":
        return Fragment$SourcePreference$$ListPreference.fromJson(json);

      default:
        final l$$__typename = json['__typename'];
        return Fragment$SourcePreference(
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
    if (other is! Fragment$SourcePreference ||
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

extension UtilityExtension$Fragment$SourcePreference
    on Fragment$SourcePreference {
  CopyWith$Fragment$SourcePreference<Fragment$SourcePreference> get copyWith =>
      CopyWith$Fragment$SourcePreference(
        this,
        (i) => i,
      );

  _T when<_T>({
    required _T Function(Fragment$SourcePreference$$CheckBoxPreference)
        checkBoxPreference,
    required _T Function(Fragment$SourcePreference$$EditTextPreference)
        editTextPreference,
    required _T Function(Fragment$SourcePreference$$SwitchPreference)
        switchPreference,
    required _T Function(Fragment$SourcePreference$$MultiSelectListPreference)
        multiSelectListPreference,
    required _T Function(Fragment$SourcePreference$$ListPreference)
        listPreference,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxPreference":
        return checkBoxPreference(
            this as Fragment$SourcePreference$$CheckBoxPreference);

      case "EditTextPreference":
        return editTextPreference(
            this as Fragment$SourcePreference$$EditTextPreference);

      case "SwitchPreference":
        return switchPreference(
            this as Fragment$SourcePreference$$SwitchPreference);

      case "MultiSelectListPreference":
        return multiSelectListPreference(
            this as Fragment$SourcePreference$$MultiSelectListPreference);

      case "ListPreference":
        return listPreference(
            this as Fragment$SourcePreference$$ListPreference);

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Fragment$SourcePreference$$CheckBoxPreference)?
        checkBoxPreference,
    _T Function(Fragment$SourcePreference$$EditTextPreference)?
        editTextPreference,
    _T Function(Fragment$SourcePreference$$SwitchPreference)? switchPreference,
    _T Function(Fragment$SourcePreference$$MultiSelectListPreference)?
        multiSelectListPreference,
    _T Function(Fragment$SourcePreference$$ListPreference)? listPreference,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "CheckBoxPreference":
        if (checkBoxPreference != null) {
          return checkBoxPreference(
              this as Fragment$SourcePreference$$CheckBoxPreference);
        } else {
          return orElse();
        }

      case "EditTextPreference":
        if (editTextPreference != null) {
          return editTextPreference(
              this as Fragment$SourcePreference$$EditTextPreference);
        } else {
          return orElse();
        }

      case "SwitchPreference":
        if (switchPreference != null) {
          return switchPreference(
              this as Fragment$SourcePreference$$SwitchPreference);
        } else {
          return orElse();
        }

      case "MultiSelectListPreference":
        if (multiSelectListPreference != null) {
          return multiSelectListPreference(
              this as Fragment$SourcePreference$$MultiSelectListPreference);
        } else {
          return orElse();
        }

      case "ListPreference":
        if (listPreference != null) {
          return listPreference(
              this as Fragment$SourcePreference$$ListPreference);
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Fragment$SourcePreference<TRes> {
  factory CopyWith$Fragment$SourcePreference(
    Fragment$SourcePreference instance,
    TRes Function(Fragment$SourcePreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference;

  factory CopyWith$Fragment$SourcePreference.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Fragment$SourcePreference<TRes>
    implements CopyWith$Fragment$SourcePreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference _instance;

  final TRes Function(Fragment$SourcePreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Fragment$SourcePreference(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Fragment$SourcePreference<TRes>
    implements CopyWith$Fragment$SourcePreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

const fragmentDefinitionSourcePreference = FragmentDefinitionNode(
  name: NameNode(value: 'SourcePreference'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Preference'),
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
        name: NameNode(value: 'CheckBoxPreference'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'currentValue'),
          alias: NameNode(value: 'checkBoxValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'summary'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'checkBoxDefaultValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'title'),
          alias: NameNode(value: 'checkBoxTitle'),
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
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'EditTextPreference'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'currentValue'),
          alias: NameNode(value: 'editTextValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'EditTextDefaultValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'title'),
          alias: NameNode(value: 'editTextTitle'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'text'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'summary'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'dialogTitle'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'dialogMessage'),
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
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'SwitchPreference'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'currentValue'),
          alias: NameNode(value: 'switchValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'summary'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'switchDefaultValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'title'),
          alias: NameNode(value: 'switchTitle'),
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
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'MultiSelectListPreference'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'dialogMessage'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'dialogTitle'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'title'),
          alias: NameNode(value: 'multiSelectTitle'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'summary'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'entryValues'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'entries'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'multiSelectDefaultValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'currentValue'),
          alias: NameNode(value: 'multiSelectValue'),
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
    ),
    InlineFragmentNode(
      typeCondition: TypeConditionNode(
          on: NamedTypeNode(
        name: NameNode(value: 'ListPreference'),
        isNonNull: false,
      )),
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'currentValue'),
          alias: NameNode(value: 'listValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'default'),
          alias: NameNode(value: 'listDefaultValue'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'title'),
          alias: NameNode(value: 'listTitle'),
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'summary'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'entryValues'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'entries'),
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
    ),
  ]),
);
const documentNodeFragmentSourcePreference = DocumentNode(definitions: [
  fragmentDefinitionSourcePreference,
]);

extension ClientExtension$Fragment$SourcePreference on graphql.GraphQLClient {
  void writeFragment$SourcePreference({
    required Fragment$SourcePreference data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SourcePreference',
            document: documentNodeFragmentSourcePreference,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SourcePreference? readFragment$SourcePreference({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SourcePreference',
          document: documentNodeFragmentSourcePreference,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SourcePreference.fromJson(result);
  }
}

class Fragment$SourcePreference$$CheckBoxPreference
    implements Fragment$SourcePreference {
  Fragment$SourcePreference$$CheckBoxPreference({
    this.checkBoxValue,
    this.summary,
    required this.checkBoxDefaultValue,
    required this.key,
    required this.checkBoxTitle,
    this.$__typename = 'CheckBoxPreference',
  });

  factory Fragment$SourcePreference$$CheckBoxPreference.fromJson(
      Map<String, dynamic> json) {
    final l$checkBoxValue = json['checkBoxValue'];
    final l$summary = json['summary'];
    final l$checkBoxDefaultValue = json['checkBoxDefaultValue'];
    final l$key = json['key'];
    final l$checkBoxTitle = json['checkBoxTitle'];
    final l$$__typename = json['__typename'];
    return Fragment$SourcePreference$$CheckBoxPreference(
      checkBoxValue: (l$checkBoxValue as bool?),
      summary: (l$summary as String?),
      checkBoxDefaultValue: (l$checkBoxDefaultValue as bool),
      key: (l$key as String),
      checkBoxTitle: (l$checkBoxTitle as String),
      $__typename: (l$$__typename as String),
    );
  }

  final bool? checkBoxValue;

  final String? summary;

  final bool checkBoxDefaultValue;

  final String key;

  final String checkBoxTitle;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$checkBoxValue = checkBoxValue;
    _resultData['checkBoxValue'] = l$checkBoxValue;
    final l$summary = summary;
    _resultData['summary'] = l$summary;
    final l$checkBoxDefaultValue = checkBoxDefaultValue;
    _resultData['checkBoxDefaultValue'] = l$checkBoxDefaultValue;
    final l$key = key;
    _resultData['key'] = l$key;
    final l$checkBoxTitle = checkBoxTitle;
    _resultData['checkBoxTitle'] = l$checkBoxTitle;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$checkBoxValue = checkBoxValue;
    final l$summary = summary;
    final l$checkBoxDefaultValue = checkBoxDefaultValue;
    final l$key = key;
    final l$checkBoxTitle = checkBoxTitle;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$checkBoxValue,
      l$summary,
      l$checkBoxDefaultValue,
      l$key,
      l$checkBoxTitle,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourcePreference$$CheckBoxPreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$checkBoxValue = checkBoxValue;
    final lOther$checkBoxValue = other.checkBoxValue;
    if (l$checkBoxValue != lOther$checkBoxValue) {
      return false;
    }
    final l$summary = summary;
    final lOther$summary = other.summary;
    if (l$summary != lOther$summary) {
      return false;
    }
    final l$checkBoxDefaultValue = checkBoxDefaultValue;
    final lOther$checkBoxDefaultValue = other.checkBoxDefaultValue;
    if (l$checkBoxDefaultValue != lOther$checkBoxDefaultValue) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$checkBoxTitle = checkBoxTitle;
    final lOther$checkBoxTitle = other.checkBoxTitle;
    if (l$checkBoxTitle != lOther$checkBoxTitle) {
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

extension UtilityExtension$Fragment$SourcePreference$$CheckBoxPreference
    on Fragment$SourcePreference$$CheckBoxPreference {
  CopyWith$Fragment$SourcePreference$$CheckBoxPreference<
          Fragment$SourcePreference$$CheckBoxPreference>
      get copyWith => CopyWith$Fragment$SourcePreference$$CheckBoxPreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourcePreference$$CheckBoxPreference<TRes> {
  factory CopyWith$Fragment$SourcePreference$$CheckBoxPreference(
    Fragment$SourcePreference$$CheckBoxPreference instance,
    TRes Function(Fragment$SourcePreference$$CheckBoxPreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference$$CheckBoxPreference;

  factory CopyWith$Fragment$SourcePreference$$CheckBoxPreference.stub(
          TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference$$CheckBoxPreference;

  TRes call({
    bool? checkBoxValue,
    String? summary,
    bool? checkBoxDefaultValue,
    String? key,
    String? checkBoxTitle,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourcePreference$$CheckBoxPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$CheckBoxPreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference$$CheckBoxPreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference$$CheckBoxPreference _instance;

  final TRes Function(Fragment$SourcePreference$$CheckBoxPreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? checkBoxValue = _undefined,
    Object? summary = _undefined,
    Object? checkBoxDefaultValue = _undefined,
    Object? key = _undefined,
    Object? checkBoxTitle = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourcePreference$$CheckBoxPreference(
        checkBoxValue: checkBoxValue == _undefined
            ? _instance.checkBoxValue
            : (checkBoxValue as bool?),
        summary:
            summary == _undefined ? _instance.summary : (summary as String?),
        checkBoxDefaultValue:
            checkBoxDefaultValue == _undefined || checkBoxDefaultValue == null
                ? _instance.checkBoxDefaultValue
                : (checkBoxDefaultValue as bool),
        key: key == _undefined || key == null ? _instance.key : (key as String),
        checkBoxTitle: checkBoxTitle == _undefined || checkBoxTitle == null
            ? _instance.checkBoxTitle
            : (checkBoxTitle as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourcePreference$$CheckBoxPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$CheckBoxPreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference$$CheckBoxPreference(this._res);

  TRes _res;

  call({
    bool? checkBoxValue,
    String? summary,
    bool? checkBoxDefaultValue,
    String? key,
    String? checkBoxTitle,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$SourcePreference$$EditTextPreference
    implements Fragment$SourcePreference {
  Fragment$SourcePreference$$EditTextPreference({
    this.editTextValue,
    this.EditTextDefaultValue,
    this.editTextTitle,
    this.text,
    this.summary,
    required this.key,
    this.dialogTitle,
    this.dialogMessage,
    this.$__typename = 'EditTextPreference',
  });

  factory Fragment$SourcePreference$$EditTextPreference.fromJson(
      Map<String, dynamic> json) {
    final l$editTextValue = json['editTextValue'];
    final l$EditTextDefaultValue = json['EditTextDefaultValue'];
    final l$editTextTitle = json['editTextTitle'];
    final l$text = json['text'];
    final l$summary = json['summary'];
    final l$key = json['key'];
    final l$dialogTitle = json['dialogTitle'];
    final l$dialogMessage = json['dialogMessage'];
    final l$$__typename = json['__typename'];
    return Fragment$SourcePreference$$EditTextPreference(
      editTextValue: (l$editTextValue as String?),
      EditTextDefaultValue: (l$EditTextDefaultValue as String?),
      editTextTitle: (l$editTextTitle as String?),
      text: (l$text as String?),
      summary: (l$summary as String?),
      key: (l$key as String),
      dialogTitle: (l$dialogTitle as String?),
      dialogMessage: (l$dialogMessage as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? editTextValue;

  final String? EditTextDefaultValue;

  final String? editTextTitle;

  final String? text;

  final String? summary;

  final String key;

  final String? dialogTitle;

  final String? dialogMessage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$editTextValue = editTextValue;
    _resultData['editTextValue'] = l$editTextValue;
    final l$EditTextDefaultValue = EditTextDefaultValue;
    _resultData['EditTextDefaultValue'] = l$EditTextDefaultValue;
    final l$editTextTitle = editTextTitle;
    _resultData['editTextTitle'] = l$editTextTitle;
    final l$text = text;
    _resultData['text'] = l$text;
    final l$summary = summary;
    _resultData['summary'] = l$summary;
    final l$key = key;
    _resultData['key'] = l$key;
    final l$dialogTitle = dialogTitle;
    _resultData['dialogTitle'] = l$dialogTitle;
    final l$dialogMessage = dialogMessage;
    _resultData['dialogMessage'] = l$dialogMessage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$editTextValue = editTextValue;
    final l$EditTextDefaultValue = EditTextDefaultValue;
    final l$editTextTitle = editTextTitle;
    final l$text = text;
    final l$summary = summary;
    final l$key = key;
    final l$dialogTitle = dialogTitle;
    final l$dialogMessage = dialogMessage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$editTextValue,
      l$EditTextDefaultValue,
      l$editTextTitle,
      l$text,
      l$summary,
      l$key,
      l$dialogTitle,
      l$dialogMessage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourcePreference$$EditTextPreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$editTextValue = editTextValue;
    final lOther$editTextValue = other.editTextValue;
    if (l$editTextValue != lOther$editTextValue) {
      return false;
    }
    final l$EditTextDefaultValue = EditTextDefaultValue;
    final lOther$EditTextDefaultValue = other.EditTextDefaultValue;
    if (l$EditTextDefaultValue != lOther$EditTextDefaultValue) {
      return false;
    }
    final l$editTextTitle = editTextTitle;
    final lOther$editTextTitle = other.editTextTitle;
    if (l$editTextTitle != lOther$editTextTitle) {
      return false;
    }
    final l$text = text;
    final lOther$text = other.text;
    if (l$text != lOther$text) {
      return false;
    }
    final l$summary = summary;
    final lOther$summary = other.summary;
    if (l$summary != lOther$summary) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$dialogTitle = dialogTitle;
    final lOther$dialogTitle = other.dialogTitle;
    if (l$dialogTitle != lOther$dialogTitle) {
      return false;
    }
    final l$dialogMessage = dialogMessage;
    final lOther$dialogMessage = other.dialogMessage;
    if (l$dialogMessage != lOther$dialogMessage) {
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

extension UtilityExtension$Fragment$SourcePreference$$EditTextPreference
    on Fragment$SourcePreference$$EditTextPreference {
  CopyWith$Fragment$SourcePreference$$EditTextPreference<
          Fragment$SourcePreference$$EditTextPreference>
      get copyWith => CopyWith$Fragment$SourcePreference$$EditTextPreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourcePreference$$EditTextPreference<TRes> {
  factory CopyWith$Fragment$SourcePreference$$EditTextPreference(
    Fragment$SourcePreference$$EditTextPreference instance,
    TRes Function(Fragment$SourcePreference$$EditTextPreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference$$EditTextPreference;

  factory CopyWith$Fragment$SourcePreference$$EditTextPreference.stub(
          TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference$$EditTextPreference;

  TRes call({
    String? editTextValue,
    String? EditTextDefaultValue,
    String? editTextTitle,
    String? text,
    String? summary,
    String? key,
    String? dialogTitle,
    String? dialogMessage,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourcePreference$$EditTextPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$EditTextPreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference$$EditTextPreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference$$EditTextPreference _instance;

  final TRes Function(Fragment$SourcePreference$$EditTextPreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? editTextValue = _undefined,
    Object? EditTextDefaultValue = _undefined,
    Object? editTextTitle = _undefined,
    Object? text = _undefined,
    Object? summary = _undefined,
    Object? key = _undefined,
    Object? dialogTitle = _undefined,
    Object? dialogMessage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourcePreference$$EditTextPreference(
        editTextValue: editTextValue == _undefined
            ? _instance.editTextValue
            : (editTextValue as String?),
        EditTextDefaultValue: EditTextDefaultValue == _undefined
            ? _instance.EditTextDefaultValue
            : (EditTextDefaultValue as String?),
        editTextTitle: editTextTitle == _undefined
            ? _instance.editTextTitle
            : (editTextTitle as String?),
        text: text == _undefined ? _instance.text : (text as String?),
        summary:
            summary == _undefined ? _instance.summary : (summary as String?),
        key: key == _undefined || key == null ? _instance.key : (key as String),
        dialogTitle: dialogTitle == _undefined
            ? _instance.dialogTitle
            : (dialogTitle as String?),
        dialogMessage: dialogMessage == _undefined
            ? _instance.dialogMessage
            : (dialogMessage as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourcePreference$$EditTextPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$EditTextPreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference$$EditTextPreference(this._res);

  TRes _res;

  call({
    String? editTextValue,
    String? EditTextDefaultValue,
    String? editTextTitle,
    String? text,
    String? summary,
    String? key,
    String? dialogTitle,
    String? dialogMessage,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$SourcePreference$$SwitchPreference
    implements Fragment$SourcePreference {
  Fragment$SourcePreference$$SwitchPreference({
    this.switchValue,
    this.summary,
    required this.key,
    required this.switchDefaultValue,
    required this.switchTitle,
    this.$__typename = 'SwitchPreference',
  });

  factory Fragment$SourcePreference$$SwitchPreference.fromJson(
      Map<String, dynamic> json) {
    final l$switchValue = json['switchValue'];
    final l$summary = json['summary'];
    final l$key = json['key'];
    final l$switchDefaultValue = json['switchDefaultValue'];
    final l$switchTitle = json['switchTitle'];
    final l$$__typename = json['__typename'];
    return Fragment$SourcePreference$$SwitchPreference(
      switchValue: (l$switchValue as bool?),
      summary: (l$summary as String?),
      key: (l$key as String),
      switchDefaultValue: (l$switchDefaultValue as bool),
      switchTitle: (l$switchTitle as String),
      $__typename: (l$$__typename as String),
    );
  }

  final bool? switchValue;

  final String? summary;

  final String key;

  final bool switchDefaultValue;

  final String switchTitle;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$switchValue = switchValue;
    _resultData['switchValue'] = l$switchValue;
    final l$summary = summary;
    _resultData['summary'] = l$summary;
    final l$key = key;
    _resultData['key'] = l$key;
    final l$switchDefaultValue = switchDefaultValue;
    _resultData['switchDefaultValue'] = l$switchDefaultValue;
    final l$switchTitle = switchTitle;
    _resultData['switchTitle'] = l$switchTitle;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$switchValue = switchValue;
    final l$summary = summary;
    final l$key = key;
    final l$switchDefaultValue = switchDefaultValue;
    final l$switchTitle = switchTitle;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$switchValue,
      l$summary,
      l$key,
      l$switchDefaultValue,
      l$switchTitle,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourcePreference$$SwitchPreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$switchValue = switchValue;
    final lOther$switchValue = other.switchValue;
    if (l$switchValue != lOther$switchValue) {
      return false;
    }
    final l$summary = summary;
    final lOther$summary = other.summary;
    if (l$summary != lOther$summary) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$switchDefaultValue = switchDefaultValue;
    final lOther$switchDefaultValue = other.switchDefaultValue;
    if (l$switchDefaultValue != lOther$switchDefaultValue) {
      return false;
    }
    final l$switchTitle = switchTitle;
    final lOther$switchTitle = other.switchTitle;
    if (l$switchTitle != lOther$switchTitle) {
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

extension UtilityExtension$Fragment$SourcePreference$$SwitchPreference
    on Fragment$SourcePreference$$SwitchPreference {
  CopyWith$Fragment$SourcePreference$$SwitchPreference<
          Fragment$SourcePreference$$SwitchPreference>
      get copyWith => CopyWith$Fragment$SourcePreference$$SwitchPreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourcePreference$$SwitchPreference<TRes> {
  factory CopyWith$Fragment$SourcePreference$$SwitchPreference(
    Fragment$SourcePreference$$SwitchPreference instance,
    TRes Function(Fragment$SourcePreference$$SwitchPreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference$$SwitchPreference;

  factory CopyWith$Fragment$SourcePreference$$SwitchPreference.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference$$SwitchPreference;

  TRes call({
    bool? switchValue,
    String? summary,
    String? key,
    bool? switchDefaultValue,
    String? switchTitle,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourcePreference$$SwitchPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$SwitchPreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference$$SwitchPreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference$$SwitchPreference _instance;

  final TRes Function(Fragment$SourcePreference$$SwitchPreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? switchValue = _undefined,
    Object? summary = _undefined,
    Object? key = _undefined,
    Object? switchDefaultValue = _undefined,
    Object? switchTitle = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourcePreference$$SwitchPreference(
        switchValue: switchValue == _undefined
            ? _instance.switchValue
            : (switchValue as bool?),
        summary:
            summary == _undefined ? _instance.summary : (summary as String?),
        key: key == _undefined || key == null ? _instance.key : (key as String),
        switchDefaultValue:
            switchDefaultValue == _undefined || switchDefaultValue == null
                ? _instance.switchDefaultValue
                : (switchDefaultValue as bool),
        switchTitle: switchTitle == _undefined || switchTitle == null
            ? _instance.switchTitle
            : (switchTitle as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourcePreference$$SwitchPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$SwitchPreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference$$SwitchPreference(this._res);

  TRes _res;

  call({
    bool? switchValue,
    String? summary,
    String? key,
    bool? switchDefaultValue,
    String? switchTitle,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$SourcePreference$$MultiSelectListPreference
    implements Fragment$SourcePreference {
  Fragment$SourcePreference$$MultiSelectListPreference({
    this.dialogMessage,
    this.dialogTitle,
    this.multiSelectTitle,
    this.summary,
    required this.key,
    required this.entryValues,
    required this.entries,
    this.multiSelectDefaultValue,
    this.multiSelectValue,
    this.$__typename = 'MultiSelectListPreference',
  });

  factory Fragment$SourcePreference$$MultiSelectListPreference.fromJson(
      Map<String, dynamic> json) {
    final l$dialogMessage = json['dialogMessage'];
    final l$dialogTitle = json['dialogTitle'];
    final l$multiSelectTitle = json['multiSelectTitle'];
    final l$summary = json['summary'];
    final l$key = json['key'];
    final l$entryValues = json['entryValues'];
    final l$entries = json['entries'];
    final l$multiSelectDefaultValue = json['multiSelectDefaultValue'];
    final l$multiSelectValue = json['multiSelectValue'];
    final l$$__typename = json['__typename'];
    return Fragment$SourcePreference$$MultiSelectListPreference(
      dialogMessage: (l$dialogMessage as String?),
      dialogTitle: (l$dialogTitle as String?),
      multiSelectTitle: (l$multiSelectTitle as String?),
      summary: (l$summary as String?),
      key: (l$key as String),
      entryValues:
          (l$entryValues as List<dynamic>).map((e) => (e as String)).toList(),
      entries: (l$entries as List<dynamic>).map((e) => (e as String)).toList(),
      multiSelectDefaultValue: (l$multiSelectDefaultValue as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList(),
      multiSelectValue: (l$multiSelectValue as List<dynamic>?)
          ?.map((e) => (e as String))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? dialogMessage;

  final String? dialogTitle;

  final String? multiSelectTitle;

  final String? summary;

  final String key;

  final List<String> entryValues;

  final List<String> entries;

  final List<String>? multiSelectDefaultValue;

  final List<String>? multiSelectValue;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$dialogMessage = dialogMessage;
    _resultData['dialogMessage'] = l$dialogMessage;
    final l$dialogTitle = dialogTitle;
    _resultData['dialogTitle'] = l$dialogTitle;
    final l$multiSelectTitle = multiSelectTitle;
    _resultData['multiSelectTitle'] = l$multiSelectTitle;
    final l$summary = summary;
    _resultData['summary'] = l$summary;
    final l$key = key;
    _resultData['key'] = l$key;
    final l$entryValues = entryValues;
    _resultData['entryValues'] = l$entryValues.map((e) => e).toList();
    final l$entries = entries;
    _resultData['entries'] = l$entries.map((e) => e).toList();
    final l$multiSelectDefaultValue = multiSelectDefaultValue;
    _resultData['multiSelectDefaultValue'] =
        l$multiSelectDefaultValue?.map((e) => e).toList();
    final l$multiSelectValue = multiSelectValue;
    _resultData['multiSelectValue'] =
        l$multiSelectValue?.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$dialogMessage = dialogMessage;
    final l$dialogTitle = dialogTitle;
    final l$multiSelectTitle = multiSelectTitle;
    final l$summary = summary;
    final l$key = key;
    final l$entryValues = entryValues;
    final l$entries = entries;
    final l$multiSelectDefaultValue = multiSelectDefaultValue;
    final l$multiSelectValue = multiSelectValue;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$dialogMessage,
      l$dialogTitle,
      l$multiSelectTitle,
      l$summary,
      l$key,
      Object.hashAll(l$entryValues.map((v) => v)),
      Object.hashAll(l$entries.map((v) => v)),
      l$multiSelectDefaultValue == null
          ? null
          : Object.hashAll(l$multiSelectDefaultValue.map((v) => v)),
      l$multiSelectValue == null
          ? null
          : Object.hashAll(l$multiSelectValue.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourcePreference$$MultiSelectListPreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$dialogMessage = dialogMessage;
    final lOther$dialogMessage = other.dialogMessage;
    if (l$dialogMessage != lOther$dialogMessage) {
      return false;
    }
    final l$dialogTitle = dialogTitle;
    final lOther$dialogTitle = other.dialogTitle;
    if (l$dialogTitle != lOther$dialogTitle) {
      return false;
    }
    final l$multiSelectTitle = multiSelectTitle;
    final lOther$multiSelectTitle = other.multiSelectTitle;
    if (l$multiSelectTitle != lOther$multiSelectTitle) {
      return false;
    }
    final l$summary = summary;
    final lOther$summary = other.summary;
    if (l$summary != lOther$summary) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$entryValues = entryValues;
    final lOther$entryValues = other.entryValues;
    if (l$entryValues.length != lOther$entryValues.length) {
      return false;
    }
    for (int i = 0; i < l$entryValues.length; i++) {
      final l$entryValues$entry = l$entryValues[i];
      final lOther$entryValues$entry = lOther$entryValues[i];
      if (l$entryValues$entry != lOther$entryValues$entry) {
        return false;
      }
    }
    final l$entries = entries;
    final lOther$entries = other.entries;
    if (l$entries.length != lOther$entries.length) {
      return false;
    }
    for (int i = 0; i < l$entries.length; i++) {
      final l$entries$entry = l$entries[i];
      final lOther$entries$entry = lOther$entries[i];
      if (l$entries$entry != lOther$entries$entry) {
        return false;
      }
    }
    final l$multiSelectDefaultValue = multiSelectDefaultValue;
    final lOther$multiSelectDefaultValue = other.multiSelectDefaultValue;
    if (l$multiSelectDefaultValue != null &&
        lOther$multiSelectDefaultValue != null) {
      if (l$multiSelectDefaultValue.length !=
          lOther$multiSelectDefaultValue.length) {
        return false;
      }
      for (int i = 0; i < l$multiSelectDefaultValue.length; i++) {
        final l$multiSelectDefaultValue$entry = l$multiSelectDefaultValue[i];
        final lOther$multiSelectDefaultValue$entry =
            lOther$multiSelectDefaultValue[i];
        if (l$multiSelectDefaultValue$entry !=
            lOther$multiSelectDefaultValue$entry) {
          return false;
        }
      }
    } else if (l$multiSelectDefaultValue != lOther$multiSelectDefaultValue) {
      return false;
    }
    final l$multiSelectValue = multiSelectValue;
    final lOther$multiSelectValue = other.multiSelectValue;
    if (l$multiSelectValue != null && lOther$multiSelectValue != null) {
      if (l$multiSelectValue.length != lOther$multiSelectValue.length) {
        return false;
      }
      for (int i = 0; i < l$multiSelectValue.length; i++) {
        final l$multiSelectValue$entry = l$multiSelectValue[i];
        final lOther$multiSelectValue$entry = lOther$multiSelectValue[i];
        if (l$multiSelectValue$entry != lOther$multiSelectValue$entry) {
          return false;
        }
      }
    } else if (l$multiSelectValue != lOther$multiSelectValue) {
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

extension UtilityExtension$Fragment$SourcePreference$$MultiSelectListPreference
    on Fragment$SourcePreference$$MultiSelectListPreference {
  CopyWith$Fragment$SourcePreference$$MultiSelectListPreference<
          Fragment$SourcePreference$$MultiSelectListPreference>
      get copyWith =>
          CopyWith$Fragment$SourcePreference$$MultiSelectListPreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourcePreference$$MultiSelectListPreference<
    TRes> {
  factory CopyWith$Fragment$SourcePreference$$MultiSelectListPreference(
    Fragment$SourcePreference$$MultiSelectListPreference instance,
    TRes Function(Fragment$SourcePreference$$MultiSelectListPreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference$$MultiSelectListPreference;

  factory CopyWith$Fragment$SourcePreference$$MultiSelectListPreference.stub(
          TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference$$MultiSelectListPreference;

  TRes call({
    String? dialogMessage,
    String? dialogTitle,
    String? multiSelectTitle,
    String? summary,
    String? key,
    List<String>? entryValues,
    List<String>? entries,
    List<String>? multiSelectDefaultValue,
    List<String>? multiSelectValue,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourcePreference$$MultiSelectListPreference<TRes>
    implements
        CopyWith$Fragment$SourcePreference$$MultiSelectListPreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference$$MultiSelectListPreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference$$MultiSelectListPreference _instance;

  final TRes Function(Fragment$SourcePreference$$MultiSelectListPreference)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? dialogMessage = _undefined,
    Object? dialogTitle = _undefined,
    Object? multiSelectTitle = _undefined,
    Object? summary = _undefined,
    Object? key = _undefined,
    Object? entryValues = _undefined,
    Object? entries = _undefined,
    Object? multiSelectDefaultValue = _undefined,
    Object? multiSelectValue = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourcePreference$$MultiSelectListPreference(
        dialogMessage: dialogMessage == _undefined
            ? _instance.dialogMessage
            : (dialogMessage as String?),
        dialogTitle: dialogTitle == _undefined
            ? _instance.dialogTitle
            : (dialogTitle as String?),
        multiSelectTitle: multiSelectTitle == _undefined
            ? _instance.multiSelectTitle
            : (multiSelectTitle as String?),
        summary:
            summary == _undefined ? _instance.summary : (summary as String?),
        key: key == _undefined || key == null ? _instance.key : (key as String),
        entryValues: entryValues == _undefined || entryValues == null
            ? _instance.entryValues
            : (entryValues as List<String>),
        entries: entries == _undefined || entries == null
            ? _instance.entries
            : (entries as List<String>),
        multiSelectDefaultValue: multiSelectDefaultValue == _undefined
            ? _instance.multiSelectDefaultValue
            : (multiSelectDefaultValue as List<String>?),
        multiSelectValue: multiSelectValue == _undefined
            ? _instance.multiSelectValue
            : (multiSelectValue as List<String>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourcePreference$$MultiSelectListPreference<
        TRes>
    implements
        CopyWith$Fragment$SourcePreference$$MultiSelectListPreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference$$MultiSelectListPreference(
      this._res);

  TRes _res;

  call({
    String? dialogMessage,
    String? dialogTitle,
    String? multiSelectTitle,
    String? summary,
    String? key,
    List<String>? entryValues,
    List<String>? entries,
    List<String>? multiSelectDefaultValue,
    List<String>? multiSelectValue,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$SourcePreference$$ListPreference
    implements Fragment$SourcePreference {
  Fragment$SourcePreference$$ListPreference({
    this.listValue,
    this.listDefaultValue,
    this.listTitle,
    this.summary,
    required this.key,
    required this.entryValues,
    required this.entries,
    this.$__typename = 'ListPreference',
  });

  factory Fragment$SourcePreference$$ListPreference.fromJson(
      Map<String, dynamic> json) {
    final l$listValue = json['listValue'];
    final l$listDefaultValue = json['listDefaultValue'];
    final l$listTitle = json['listTitle'];
    final l$summary = json['summary'];
    final l$key = json['key'];
    final l$entryValues = json['entryValues'];
    final l$entries = json['entries'];
    final l$$__typename = json['__typename'];
    return Fragment$SourcePreference$$ListPreference(
      listValue: (l$listValue as String?),
      listDefaultValue: (l$listDefaultValue as String?),
      listTitle: (l$listTitle as String?),
      summary: (l$summary as String?),
      key: (l$key as String),
      entryValues:
          (l$entryValues as List<dynamic>).map((e) => (e as String)).toList(),
      entries: (l$entries as List<dynamic>).map((e) => (e as String)).toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? listValue;

  final String? listDefaultValue;

  final String? listTitle;

  final String? summary;

  final String key;

  final List<String> entryValues;

  final List<String> entries;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$listValue = listValue;
    _resultData['listValue'] = l$listValue;
    final l$listDefaultValue = listDefaultValue;
    _resultData['listDefaultValue'] = l$listDefaultValue;
    final l$listTitle = listTitle;
    _resultData['listTitle'] = l$listTitle;
    final l$summary = summary;
    _resultData['summary'] = l$summary;
    final l$key = key;
    _resultData['key'] = l$key;
    final l$entryValues = entryValues;
    _resultData['entryValues'] = l$entryValues.map((e) => e).toList();
    final l$entries = entries;
    _resultData['entries'] = l$entries.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$listValue = listValue;
    final l$listDefaultValue = listDefaultValue;
    final l$listTitle = listTitle;
    final l$summary = summary;
    final l$key = key;
    final l$entryValues = entryValues;
    final l$entries = entries;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$listValue,
      l$listDefaultValue,
      l$listTitle,
      l$summary,
      l$key,
      Object.hashAll(l$entryValues.map((v) => v)),
      Object.hashAll(l$entries.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourcePreference$$ListPreference ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$listValue = listValue;
    final lOther$listValue = other.listValue;
    if (l$listValue != lOther$listValue) {
      return false;
    }
    final l$listDefaultValue = listDefaultValue;
    final lOther$listDefaultValue = other.listDefaultValue;
    if (l$listDefaultValue != lOther$listDefaultValue) {
      return false;
    }
    final l$listTitle = listTitle;
    final lOther$listTitle = other.listTitle;
    if (l$listTitle != lOther$listTitle) {
      return false;
    }
    final l$summary = summary;
    final lOther$summary = other.summary;
    if (l$summary != lOther$summary) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$entryValues = entryValues;
    final lOther$entryValues = other.entryValues;
    if (l$entryValues.length != lOther$entryValues.length) {
      return false;
    }
    for (int i = 0; i < l$entryValues.length; i++) {
      final l$entryValues$entry = l$entryValues[i];
      final lOther$entryValues$entry = lOther$entryValues[i];
      if (l$entryValues$entry != lOther$entryValues$entry) {
        return false;
      }
    }
    final l$entries = entries;
    final lOther$entries = other.entries;
    if (l$entries.length != lOther$entries.length) {
      return false;
    }
    for (int i = 0; i < l$entries.length; i++) {
      final l$entries$entry = l$entries[i];
      final lOther$entries$entry = lOther$entries[i];
      if (l$entries$entry != lOther$entries$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$SourcePreference$$ListPreference
    on Fragment$SourcePreference$$ListPreference {
  CopyWith$Fragment$SourcePreference$$ListPreference<
          Fragment$SourcePreference$$ListPreference>
      get copyWith => CopyWith$Fragment$SourcePreference$$ListPreference(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourcePreference$$ListPreference<TRes> {
  factory CopyWith$Fragment$SourcePreference$$ListPreference(
    Fragment$SourcePreference$$ListPreference instance,
    TRes Function(Fragment$SourcePreference$$ListPreference) then,
  ) = _CopyWithImpl$Fragment$SourcePreference$$ListPreference;

  factory CopyWith$Fragment$SourcePreference$$ListPreference.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourcePreference$$ListPreference;

  TRes call({
    String? listValue,
    String? listDefaultValue,
    String? listTitle,
    String? summary,
    String? key,
    List<String>? entryValues,
    List<String>? entries,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourcePreference$$ListPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$ListPreference<TRes> {
  _CopyWithImpl$Fragment$SourcePreference$$ListPreference(
    this._instance,
    this._then,
  );

  final Fragment$SourcePreference$$ListPreference _instance;

  final TRes Function(Fragment$SourcePreference$$ListPreference) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? listValue = _undefined,
    Object? listDefaultValue = _undefined,
    Object? listTitle = _undefined,
    Object? summary = _undefined,
    Object? key = _undefined,
    Object? entryValues = _undefined,
    Object? entries = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourcePreference$$ListPreference(
        listValue: listValue == _undefined
            ? _instance.listValue
            : (listValue as String?),
        listDefaultValue: listDefaultValue == _undefined
            ? _instance.listDefaultValue
            : (listDefaultValue as String?),
        listTitle: listTitle == _undefined
            ? _instance.listTitle
            : (listTitle as String?),
        summary:
            summary == _undefined ? _instance.summary : (summary as String?),
        key: key == _undefined || key == null ? _instance.key : (key as String),
        entryValues: entryValues == _undefined || entryValues == null
            ? _instance.entryValues
            : (entryValues as List<String>),
        entries: entries == _undefined || entries == null
            ? _instance.entries
            : (entries as List<String>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourcePreference$$ListPreference<TRes>
    implements CopyWith$Fragment$SourcePreference$$ListPreference<TRes> {
  _CopyWithStubImpl$Fragment$SourcePreference$$ListPreference(this._res);

  TRes _res;

  call({
    String? listValue,
    String? listDefaultValue,
    String? listTitle,
    String? summary,
    String? key,
    List<String>? entryValues,
    List<String>? entries,
    String? $__typename,
  }) =>
      _res;
}
