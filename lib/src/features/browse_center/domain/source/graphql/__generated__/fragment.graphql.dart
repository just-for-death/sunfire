import 'package:catalyst/src/utils/misc/scalars.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$SourceDto {
  Fragment$SourceDto({
    required this.displayName,
    required this.iconUrl,
    required this.id,
    required this.isConfigurable,
    required this.isNsfw,
    required this.lang,
    required this.name,
    required this.supportsLatest,
    required this.$extension,
    this.$__typename = 'SourceType',
  });

  factory Fragment$SourceDto.fromJson(Map<String, dynamic> json) {
    final l$displayName = json['displayName'];
    final l$iconUrl = json['iconUrl'];
    final l$id = json['id'];
    final l$isConfigurable = json['isConfigurable'];
    final l$isNsfw = json['isNsfw'];
    final l$lang = json['lang'];
    final l$name = json['name'];
    final l$supportsLatest = json['supportsLatest'];
    final l$$extension = json['extension'];
    final l$$__typename = json['__typename'];
    return Fragment$SourceDto(
      displayName: (l$displayName as String),
      iconUrl: (l$iconUrl as String),
      id: longStringFromJson(l$id),
      isConfigurable: (l$isConfigurable as bool),
      isNsfw: (l$isNsfw as bool),
      lang: (l$lang as String),
      name: (l$name as String),
      supportsLatest: (l$supportsLatest as bool),
      $extension: Fragment$SourceDto$extension.fromJson(
          (l$$extension as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final String displayName;

  final String iconUrl;

  final String id;

  final bool isConfigurable;

  final bool isNsfw;

  final String lang;

  final String name;

  final bool supportsLatest;

  final Fragment$SourceDto$extension $extension;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$displayName = displayName;
    _resultData['displayName'] = l$displayName;
    final l$iconUrl = iconUrl;
    _resultData['iconUrl'] = l$iconUrl;
    final l$id = id;
    _resultData['id'] = longStringToJson(l$id);
    final l$isConfigurable = isConfigurable;
    _resultData['isConfigurable'] = l$isConfigurable;
    final l$isNsfw = isNsfw;
    _resultData['isNsfw'] = l$isNsfw;
    final l$lang = lang;
    _resultData['lang'] = l$lang;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$supportsLatest = supportsLatest;
    _resultData['supportsLatest'] = l$supportsLatest;
    final l$$extension = $extension;
    _resultData['extension'] = l$$extension.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$displayName = displayName;
    final l$iconUrl = iconUrl;
    final l$id = id;
    final l$isConfigurable = isConfigurable;
    final l$isNsfw = isNsfw;
    final l$lang = lang;
    final l$name = name;
    final l$supportsLatest = supportsLatest;
    final l$$extension = $extension;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$displayName,
      l$iconUrl,
      l$id,
      l$isConfigurable,
      l$isNsfw,
      l$lang,
      l$name,
      l$supportsLatest,
      l$$extension,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourceDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$displayName = displayName;
    final lOther$displayName = other.displayName;
    if (l$displayName != lOther$displayName) {
      return false;
    }
    final l$iconUrl = iconUrl;
    final lOther$iconUrl = other.iconUrl;
    if (l$iconUrl != lOther$iconUrl) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$isConfigurable = isConfigurable;
    final lOther$isConfigurable = other.isConfigurable;
    if (l$isConfigurable != lOther$isConfigurable) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$lang = lang;
    final lOther$lang = other.lang;
    if (l$lang != lOther$lang) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$supportsLatest = supportsLatest;
    final lOther$supportsLatest = other.supportsLatest;
    if (l$supportsLatest != lOther$supportsLatest) {
      return false;
    }
    final l$$extension = $extension;
    final lOther$$extension = other.$extension;
    if (l$$extension != lOther$$extension) {
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

extension UtilityExtension$Fragment$SourceDto on Fragment$SourceDto {
  CopyWith$Fragment$SourceDto<Fragment$SourceDto> get copyWith =>
      CopyWith$Fragment$SourceDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$SourceDto<TRes> {
  factory CopyWith$Fragment$SourceDto(
    Fragment$SourceDto instance,
    TRes Function(Fragment$SourceDto) then,
  ) = _CopyWithImpl$Fragment$SourceDto;

  factory CopyWith$Fragment$SourceDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourceDto;

  TRes call({
    String? displayName,
    String? iconUrl,
    String? id,
    bool? isConfigurable,
    bool? isNsfw,
    String? lang,
    String? name,
    bool? supportsLatest,
    Fragment$SourceDto$extension? $extension,
    String? $__typename,
  });
  CopyWith$Fragment$SourceDto$extension<TRes> get $extension;
}

class _CopyWithImpl$Fragment$SourceDto<TRes>
    implements CopyWith$Fragment$SourceDto<TRes> {
  _CopyWithImpl$Fragment$SourceDto(
    this._instance,
    this._then,
  );

  final Fragment$SourceDto _instance;

  final TRes Function(Fragment$SourceDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? displayName = _undefined,
    Object? iconUrl = _undefined,
    Object? id = _undefined,
    Object? isConfigurable = _undefined,
    Object? isNsfw = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
    Object? supportsLatest = _undefined,
    Object? $extension = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourceDto(
        displayName: displayName == _undefined || displayName == null
            ? _instance.displayName
            : (displayName as String),
        iconUrl: iconUrl == _undefined || iconUrl == null
            ? _instance.iconUrl
            : (iconUrl as String),
        id: id == _undefined || id == null ? _instance.id : (id as String),
        isConfigurable: isConfigurable == _undefined || isConfigurable == null
            ? _instance.isConfigurable
            : (isConfigurable as bool),
        isNsfw: isNsfw == _undefined || isNsfw == null
            ? _instance.isNsfw
            : (isNsfw as bool),
        lang: lang == _undefined || lang == null
            ? _instance.lang
            : (lang as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        supportsLatest: supportsLatest == _undefined || supportsLatest == null
            ? _instance.supportsLatest
            : (supportsLatest as bool),
        $extension: $extension == _undefined || $extension == null
            ? _instance.$extension
            : ($extension as Fragment$SourceDto$extension),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$SourceDto$extension<TRes> get $extension {
    final local$$extension = _instance.$extension;
    return CopyWith$Fragment$SourceDto$extension(
        local$$extension, (e) => call($extension: e));
  }
}

class _CopyWithStubImpl$Fragment$SourceDto<TRes>
    implements CopyWith$Fragment$SourceDto<TRes> {
  _CopyWithStubImpl$Fragment$SourceDto(this._res);

  TRes _res;

  call({
    String? displayName,
    String? iconUrl,
    String? id,
    bool? isConfigurable,
    bool? isNsfw,
    String? lang,
    String? name,
    bool? supportsLatest,
    Fragment$SourceDto$extension? $extension,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$SourceDto$extension<TRes> get $extension =>
      CopyWith$Fragment$SourceDto$extension.stub(_res);
}

const fragmentDefinitionSourceDto = FragmentDefinitionNode(
  name: NameNode(value: 'SourceDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'SourceType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'displayName'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'iconUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'id'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'isConfigurable'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'isNsfw'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lang'),
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
      name: NameNode(value: 'supportsLatest'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'extension'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'pkgName'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'repo'),
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
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentSourceDto = DocumentNode(definitions: [
  fragmentDefinitionSourceDto,
]);

extension ClientExtension$Fragment$SourceDto on graphql.GraphQLClient {
  void writeFragment$SourceDto({
    required Fragment$SourceDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SourceDto',
            document: documentNodeFragmentSourceDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SourceDto? readFragment$SourceDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SourceDto',
          document: documentNodeFragmentSourceDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SourceDto.fromJson(result);
  }
}

class Fragment$SourceDto$extension {
  Fragment$SourceDto$extension({
    required this.pkgName,
    this.repo,
    this.$__typename = 'ExtensionType',
  });

  factory Fragment$SourceDto$extension.fromJson(Map<String, dynamic> json) {
    final l$pkgName = json['pkgName'];
    final l$repo = json['repo'];
    final l$$__typename = json['__typename'];
    return Fragment$SourceDto$extension(
      pkgName: (l$pkgName as String),
      repo: (l$repo as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String pkgName;

  final String? repo;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pkgName = pkgName;
    _resultData['pkgName'] = l$pkgName;
    final l$repo = repo;
    _resultData['repo'] = l$repo;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pkgName = pkgName;
    final l$repo = repo;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pkgName,
      l$repo,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourceDto$extension ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pkgName = pkgName;
    final lOther$pkgName = other.pkgName;
    if (l$pkgName != lOther$pkgName) {
      return false;
    }
    final l$repo = repo;
    final lOther$repo = other.repo;
    if (l$repo != lOther$repo) {
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

extension UtilityExtension$Fragment$SourceDto$extension
    on Fragment$SourceDto$extension {
  CopyWith$Fragment$SourceDto$extension<Fragment$SourceDto$extension>
      get copyWith => CopyWith$Fragment$SourceDto$extension(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$SourceDto$extension<TRes> {
  factory CopyWith$Fragment$SourceDto$extension(
    Fragment$SourceDto$extension instance,
    TRes Function(Fragment$SourceDto$extension) then,
  ) = _CopyWithImpl$Fragment$SourceDto$extension;

  factory CopyWith$Fragment$SourceDto$extension.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourceDto$extension;

  TRes call({
    String? pkgName,
    String? repo,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$SourceDto$extension<TRes>
    implements CopyWith$Fragment$SourceDto$extension<TRes> {
  _CopyWithImpl$Fragment$SourceDto$extension(
    this._instance,
    this._then,
  );

  final Fragment$SourceDto$extension _instance;

  final TRes Function(Fragment$SourceDto$extension) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pkgName = _undefined,
    Object? repo = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourceDto$extension(
        pkgName: pkgName == _undefined || pkgName == null
            ? _instance.pkgName
            : (pkgName as String),
        repo: repo == _undefined ? _instance.repo : (repo as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$SourceDto$extension<TRes>
    implements CopyWith$Fragment$SourceDto$extension<TRes> {
  _CopyWithStubImpl$Fragment$SourceDto$extension(this._res);

  TRes _res;

  call({
    String? pkgName,
    String? repo,
    String? $__typename,
  }) =>
      _res;
}
