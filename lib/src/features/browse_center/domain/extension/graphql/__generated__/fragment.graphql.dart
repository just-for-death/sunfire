import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$ExtensionDto {
  Fragment$ExtensionDto({
    required this.apkName,
    required this.hasUpdate,
    required this.iconUrl,
    required this.isInstalled,
    required this.isNsfw,
    required this.isObsolete,
    required this.lang,
    required this.name,
    required this.pkgName,
    this.repo,
    required this.versionCode,
    required this.versionName,
    this.$__typename = 'ExtensionType',
  });

  factory Fragment$ExtensionDto.fromJson(Map<String, dynamic> json) {
    final l$apkName = json['apkName'];
    final l$hasUpdate = json['hasUpdate'];
    final l$iconUrl = json['iconUrl'];
    final l$isInstalled = json['isInstalled'];
    final l$isNsfw = json['isNsfw'];
    final l$isObsolete = json['isObsolete'];
    final l$lang = json['lang'];
    final l$name = json['name'];
    final l$pkgName = json['pkgName'];
    final l$repo = json['repo'];
    final l$versionCode = json['versionCode'];
    final l$versionName = json['versionName'];
    final l$$__typename = json['__typename'];
    return Fragment$ExtensionDto(
      apkName: (l$apkName as String),
      hasUpdate: (l$hasUpdate as bool),
      iconUrl: (l$iconUrl as String),
      isInstalled: (l$isInstalled as bool),
      isNsfw: (l$isNsfw as bool),
      isObsolete: (l$isObsolete as bool),
      lang: (l$lang as String),
      name: (l$name as String),
      pkgName: (l$pkgName as String),
      repo: (l$repo as String?),
      versionCode: (l$versionCode as int),
      versionName: (l$versionName as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String apkName;

  final bool hasUpdate;

  final String iconUrl;

  final bool isInstalled;

  final bool isNsfw;

  final bool isObsolete;

  final String lang;

  final String name;

  final String pkgName;

  final String? repo;

  final int versionCode;

  final String versionName;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$apkName = apkName;
    _resultData['apkName'] = l$apkName;
    final l$hasUpdate = hasUpdate;
    _resultData['hasUpdate'] = l$hasUpdate;
    final l$iconUrl = iconUrl;
    _resultData['iconUrl'] = l$iconUrl;
    final l$isInstalled = isInstalled;
    _resultData['isInstalled'] = l$isInstalled;
    final l$isNsfw = isNsfw;
    _resultData['isNsfw'] = l$isNsfw;
    final l$isObsolete = isObsolete;
    _resultData['isObsolete'] = l$isObsolete;
    final l$lang = lang;
    _resultData['lang'] = l$lang;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$pkgName = pkgName;
    _resultData['pkgName'] = l$pkgName;
    final l$repo = repo;
    _resultData['repo'] = l$repo;
    final l$versionCode = versionCode;
    _resultData['versionCode'] = l$versionCode;
    final l$versionName = versionName;
    _resultData['versionName'] = l$versionName;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$apkName = apkName;
    final l$hasUpdate = hasUpdate;
    final l$iconUrl = iconUrl;
    final l$isInstalled = isInstalled;
    final l$isNsfw = isNsfw;
    final l$isObsolete = isObsolete;
    final l$lang = lang;
    final l$name = name;
    final l$pkgName = pkgName;
    final l$repo = repo;
    final l$versionCode = versionCode;
    final l$versionName = versionName;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$apkName,
      l$hasUpdate,
      l$iconUrl,
      l$isInstalled,
      l$isNsfw,
      l$isObsolete,
      l$lang,
      l$name,
      l$pkgName,
      l$repo,
      l$versionCode,
      l$versionName,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$ExtensionDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$apkName = apkName;
    final lOther$apkName = other.apkName;
    if (l$apkName != lOther$apkName) {
      return false;
    }
    final l$hasUpdate = hasUpdate;
    final lOther$hasUpdate = other.hasUpdate;
    if (l$hasUpdate != lOther$hasUpdate) {
      return false;
    }
    final l$iconUrl = iconUrl;
    final lOther$iconUrl = other.iconUrl;
    if (l$iconUrl != lOther$iconUrl) {
      return false;
    }
    final l$isInstalled = isInstalled;
    final lOther$isInstalled = other.isInstalled;
    if (l$isInstalled != lOther$isInstalled) {
      return false;
    }
    final l$isNsfw = isNsfw;
    final lOther$isNsfw = other.isNsfw;
    if (l$isNsfw != lOther$isNsfw) {
      return false;
    }
    final l$isObsolete = isObsolete;
    final lOther$isObsolete = other.isObsolete;
    if (l$isObsolete != lOther$isObsolete) {
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
    final l$versionCode = versionCode;
    final lOther$versionCode = other.versionCode;
    if (l$versionCode != lOther$versionCode) {
      return false;
    }
    final l$versionName = versionName;
    final lOther$versionName = other.versionName;
    if (l$versionName != lOther$versionName) {
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

extension UtilityExtension$Fragment$ExtensionDto on Fragment$ExtensionDto {
  CopyWith$Fragment$ExtensionDto<Fragment$ExtensionDto> get copyWith =>
      CopyWith$Fragment$ExtensionDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$ExtensionDto<TRes> {
  factory CopyWith$Fragment$ExtensionDto(
    Fragment$ExtensionDto instance,
    TRes Function(Fragment$ExtensionDto) then,
  ) = _CopyWithImpl$Fragment$ExtensionDto;

  factory CopyWith$Fragment$ExtensionDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$ExtensionDto;

  TRes call({
    String? apkName,
    bool? hasUpdate,
    String? iconUrl,
    bool? isInstalled,
    bool? isNsfw,
    bool? isObsolete,
    String? lang,
    String? name,
    String? pkgName,
    String? repo,
    int? versionCode,
    String? versionName,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$ExtensionDto<TRes>
    implements CopyWith$Fragment$ExtensionDto<TRes> {
  _CopyWithImpl$Fragment$ExtensionDto(
    this._instance,
    this._then,
  );

  final Fragment$ExtensionDto _instance;

  final TRes Function(Fragment$ExtensionDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? apkName = _undefined,
    Object? hasUpdate = _undefined,
    Object? iconUrl = _undefined,
    Object? isInstalled = _undefined,
    Object? isNsfw = _undefined,
    Object? isObsolete = _undefined,
    Object? lang = _undefined,
    Object? name = _undefined,
    Object? pkgName = _undefined,
    Object? repo = _undefined,
    Object? versionCode = _undefined,
    Object? versionName = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$ExtensionDto(
        apkName: apkName == _undefined || apkName == null
            ? _instance.apkName
            : (apkName as String),
        hasUpdate: hasUpdate == _undefined || hasUpdate == null
            ? _instance.hasUpdate
            : (hasUpdate as bool),
        iconUrl: iconUrl == _undefined || iconUrl == null
            ? _instance.iconUrl
            : (iconUrl as String),
        isInstalled: isInstalled == _undefined || isInstalled == null
            ? _instance.isInstalled
            : (isInstalled as bool),
        isNsfw: isNsfw == _undefined || isNsfw == null
            ? _instance.isNsfw
            : (isNsfw as bool),
        isObsolete: isObsolete == _undefined || isObsolete == null
            ? _instance.isObsolete
            : (isObsolete as bool),
        lang: lang == _undefined || lang == null
            ? _instance.lang
            : (lang as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        pkgName: pkgName == _undefined || pkgName == null
            ? _instance.pkgName
            : (pkgName as String),
        repo: repo == _undefined ? _instance.repo : (repo as String?),
        versionCode: versionCode == _undefined || versionCode == null
            ? _instance.versionCode
            : (versionCode as int),
        versionName: versionName == _undefined || versionName == null
            ? _instance.versionName
            : (versionName as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$ExtensionDto<TRes>
    implements CopyWith$Fragment$ExtensionDto<TRes> {
  _CopyWithStubImpl$Fragment$ExtensionDto(this._res);

  TRes _res;

  call({
    String? apkName,
    bool? hasUpdate,
    String? iconUrl,
    bool? isInstalled,
    bool? isNsfw,
    bool? isObsolete,
    String? lang,
    String? name,
    String? pkgName,
    String? repo,
    int? versionCode,
    String? versionName,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionExtensionDto = FragmentDefinitionNode(
  name: NameNode(value: 'ExtensionDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'ExtensionType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'apkName'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'hasUpdate'),
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
      name: NameNode(value: 'isInstalled'),
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
      name: NameNode(value: 'isObsolete'),
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
      name: NameNode(value: 'versionCode'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'versionName'),
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
const documentNodeFragmentExtensionDto = DocumentNode(definitions: [
  fragmentDefinitionExtensionDto,
]);

extension ClientExtension$Fragment$ExtensionDto on graphql.GraphQLClient {
  void writeFragment$ExtensionDto({
    required Fragment$ExtensionDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'ExtensionDto',
            document: documentNodeFragmentExtensionDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$ExtensionDto? readFragment$ExtensionDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'ExtensionDto',
          document: documentNodeFragmentExtensionDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$ExtensionDto.fromJson(result);
  }
}
