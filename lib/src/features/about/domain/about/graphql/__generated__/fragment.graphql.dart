import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:catalyst/src/utils/misc/scalars.dart';

class Fragment$AboutDto {
  Fragment$AboutDto({
    required this.buildTime,
    required this.buildType,
    required this.discord,
    required this.github,
    required this.name,
    required this.revision,
    required this.version,
    this.$__typename = 'AboutServerPayload',
  });

  factory Fragment$AboutDto.fromJson(Map<String, dynamic> json) {
    final l$buildTime = json['buildTime'];
    final l$buildType = json['buildType'];
    final l$discord = json['discord'];
    final l$github = json['github'];
    final l$name = json['name'];
    final l$revision = json['revision'];
    final l$version = json['version'];
    final l$$__typename = json['__typename'];
    return Fragment$AboutDto(
      buildTime: longStringFromJson(l$buildTime),
      buildType: (l$buildType as String),
      discord: (l$discord as String),
      github: (l$github as String),
      name: (l$name as String),
      revision: (l$revision as String),
      version: (l$version as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String buildTime;

  final String buildType;

  final String discord;

  final String github;

  final String name;

  final String revision;

  final String version;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$buildTime = buildTime;
    _resultData['buildTime'] = longStringToJson(l$buildTime);
    final l$buildType = buildType;
    _resultData['buildType'] = l$buildType;
    final l$discord = discord;
    _resultData['discord'] = l$discord;
    final l$github = github;
    _resultData['github'] = l$github;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$revision = revision;
    _resultData['revision'] = l$revision;
    final l$version = version;
    _resultData['version'] = l$version;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$buildTime = buildTime;
    final l$buildType = buildType;
    final l$discord = discord;
    final l$github = github;
    final l$name = name;
    final l$revision = revision;
    final l$version = version;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$buildTime,
      l$buildType,
      l$discord,
      l$github,
      l$name,
      l$revision,
      l$version,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$AboutDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$buildTime = buildTime;
    final lOther$buildTime = other.buildTime;
    if (l$buildTime != lOther$buildTime) {
      return false;
    }
    final l$buildType = buildType;
    final lOther$buildType = other.buildType;
    if (l$buildType != lOther$buildType) {
      return false;
    }
    final l$discord = discord;
    final lOther$discord = other.discord;
    if (l$discord != lOther$discord) {
      return false;
    }
    final l$github = github;
    final lOther$github = other.github;
    if (l$github != lOther$github) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$revision = revision;
    final lOther$revision = other.revision;
    if (l$revision != lOther$revision) {
      return false;
    }
    final l$version = version;
    final lOther$version = other.version;
    if (l$version != lOther$version) {
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

extension UtilityExtension$Fragment$AboutDto on Fragment$AboutDto {
  CopyWith$Fragment$AboutDto<Fragment$AboutDto> get copyWith =>
      CopyWith$Fragment$AboutDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$AboutDto<TRes> {
  factory CopyWith$Fragment$AboutDto(
    Fragment$AboutDto instance,
    TRes Function(Fragment$AboutDto) then,
  ) = _CopyWithImpl$Fragment$AboutDto;

  factory CopyWith$Fragment$AboutDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AboutDto;

  TRes call({
    String? buildTime,
    String? buildType,
    String? discord,
    String? github,
    String? name,
    String? revision,
    String? version,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AboutDto<TRes>
    implements CopyWith$Fragment$AboutDto<TRes> {
  _CopyWithImpl$Fragment$AboutDto(
    this._instance,
    this._then,
  );

  final Fragment$AboutDto _instance;

  final TRes Function(Fragment$AboutDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? buildTime = _undefined,
    Object? buildType = _undefined,
    Object? discord = _undefined,
    Object? github = _undefined,
    Object? name = _undefined,
    Object? revision = _undefined,
    Object? version = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AboutDto(
        buildTime: buildTime == _undefined || buildTime == null
            ? _instance.buildTime
            : (buildTime as String),
        buildType: buildType == _undefined || buildType == null
            ? _instance.buildType
            : (buildType as String),
        discord: discord == _undefined || discord == null
            ? _instance.discord
            : (discord as String),
        github: github == _undefined || github == null
            ? _instance.github
            : (github as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        revision: revision == _undefined || revision == null
            ? _instance.revision
            : (revision as String),
        version: version == _undefined || version == null
            ? _instance.version
            : (version as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$AboutDto<TRes>
    implements CopyWith$Fragment$AboutDto<TRes> {
  _CopyWithStubImpl$Fragment$AboutDto(this._res);

  TRes _res;

  call({
    String? buildTime,
    String? buildType,
    String? discord,
    String? github,
    String? name,
    String? revision,
    String? version,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionAboutDto = FragmentDefinitionNode(
  name: NameNode(value: 'AboutDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'AboutServerPayload'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'buildTime'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'buildType'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'discord'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'github'),
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
      name: NameNode(value: 'revision'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'version'),
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
const documentNodeFragmentAboutDto = DocumentNode(definitions: [
  fragmentDefinitionAboutDto,
]);

extension ClientExtension$Fragment$AboutDto on graphql.GraphQLClient {
  void writeFragment$AboutDto({
    required Fragment$AboutDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'AboutDto',
            document: documentNodeFragmentAboutDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$AboutDto? readFragment$AboutDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'AboutDto',
          document: documentNodeFragmentAboutDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$AboutDto.fromJson(result);
  }
}
