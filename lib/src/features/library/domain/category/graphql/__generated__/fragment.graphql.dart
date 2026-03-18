import '../../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../../graphql/__generated__/schema.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$CategoryDto {
  Fragment$CategoryDto({
    required this.defaultCategory,
    required this.id,
    required this.includeInDownload,
    required this.includeInUpdate,
    required this.name,
    required this.order,
    required this.mangas,
    required this.meta,
    this.$__typename = 'CategoryType',
  });

  factory Fragment$CategoryDto.fromJson(Map<String, dynamic> json) {
    final l$defaultCategory = json['defaultCategory'];
    final l$id = json['id'];
    final l$includeInDownload = json['includeInDownload'];
    final l$includeInUpdate = json['includeInUpdate'];
    final l$name = json['name'];
    final l$order = json['order'];
    final l$mangas = json['mangas'];
    final l$meta = json['meta'];
    final l$$__typename = json['__typename'];
    return Fragment$CategoryDto(
      defaultCategory: (l$defaultCategory as bool),
      id: (l$id as int),
      includeInDownload:
          fromJson$Enum$IncludeOrExclude((l$includeInDownload as String)),
      includeInUpdate:
          fromJson$Enum$IncludeOrExclude((l$includeInUpdate as String)),
      name: (l$name as String),
      order: (l$order as int),
      mangas: Fragment$CategoryDto$mangas.fromJson(
          (l$mangas as Map<String, dynamic>)),
      meta: (l$meta as List<dynamic>)
          .map((e) =>
              Fragment$CategoryDto$meta.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final bool defaultCategory;

  final int id;

  final Enum$IncludeOrExclude includeInDownload;

  final Enum$IncludeOrExclude includeInUpdate;

  final String name;

  final int order;

  final Fragment$CategoryDto$mangas mangas;

  final List<Fragment$CategoryDto$meta> meta;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$defaultCategory = defaultCategory;
    _resultData['defaultCategory'] = l$defaultCategory;
    final l$id = id;
    _resultData['id'] = l$id;
    final l$includeInDownload = includeInDownload;
    _resultData['includeInDownload'] =
        toJson$Enum$IncludeOrExclude(l$includeInDownload);
    final l$includeInUpdate = includeInUpdate;
    _resultData['includeInUpdate'] =
        toJson$Enum$IncludeOrExclude(l$includeInUpdate);
    final l$name = name;
    _resultData['name'] = l$name;
    final l$order = order;
    _resultData['order'] = l$order;
    final l$mangas = mangas;
    _resultData['mangas'] = l$mangas.toJson();
    final l$meta = meta;
    _resultData['meta'] = l$meta.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$defaultCategory = defaultCategory;
    final l$id = id;
    final l$includeInDownload = includeInDownload;
    final l$includeInUpdate = includeInUpdate;
    final l$name = name;
    final l$order = order;
    final l$mangas = mangas;
    final l$meta = meta;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$defaultCategory,
      l$id,
      l$includeInDownload,
      l$includeInUpdate,
      l$name,
      l$order,
      l$mangas,
      Object.hashAll(l$meta.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CategoryDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$defaultCategory = defaultCategory;
    final lOther$defaultCategory = other.defaultCategory;
    if (l$defaultCategory != lOther$defaultCategory) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$includeInDownload = includeInDownload;
    final lOther$includeInDownload = other.includeInDownload;
    if (l$includeInDownload != lOther$includeInDownload) {
      return false;
    }
    final l$includeInUpdate = includeInUpdate;
    final lOther$includeInUpdate = other.includeInUpdate;
    if (l$includeInUpdate != lOther$includeInUpdate) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$order = order;
    final lOther$order = other.order;
    if (l$order != lOther$order) {
      return false;
    }
    final l$mangas = mangas;
    final lOther$mangas = other.mangas;
    if (l$mangas != lOther$mangas) {
      return false;
    }
    final l$meta = meta;
    final lOther$meta = other.meta;
    if (l$meta.length != lOther$meta.length) {
      return false;
    }
    for (int i = 0; i < l$meta.length; i++) {
      final l$meta$entry = l$meta[i];
      final lOther$meta$entry = lOther$meta[i];
      if (l$meta$entry != lOther$meta$entry) {
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

extension UtilityExtension$Fragment$CategoryDto on Fragment$CategoryDto {
  CopyWith$Fragment$CategoryDto<Fragment$CategoryDto> get copyWith =>
      CopyWith$Fragment$CategoryDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$CategoryDto<TRes> {
  factory CopyWith$Fragment$CategoryDto(
    Fragment$CategoryDto instance,
    TRes Function(Fragment$CategoryDto) then,
  ) = _CopyWithImpl$Fragment$CategoryDto;

  factory CopyWith$Fragment$CategoryDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CategoryDto;

  TRes call({
    bool? defaultCategory,
    int? id,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
    int? order,
    Fragment$CategoryDto$mangas? mangas,
    List<Fragment$CategoryDto$meta>? meta,
    String? $__typename,
  });
  CopyWith$Fragment$CategoryDto$mangas<TRes> get mangas;
  TRes meta(
      Iterable<Fragment$CategoryDto$meta> Function(
              Iterable<
                  CopyWith$Fragment$CategoryDto$meta<
                      Fragment$CategoryDto$meta>>)
          _fn);
}

class _CopyWithImpl$Fragment$CategoryDto<TRes>
    implements CopyWith$Fragment$CategoryDto<TRes> {
  _CopyWithImpl$Fragment$CategoryDto(
    this._instance,
    this._then,
  );

  final Fragment$CategoryDto _instance;

  final TRes Function(Fragment$CategoryDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? defaultCategory = _undefined,
    Object? id = _undefined,
    Object? includeInDownload = _undefined,
    Object? includeInUpdate = _undefined,
    Object? name = _undefined,
    Object? order = _undefined,
    Object? mangas = _undefined,
    Object? meta = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CategoryDto(
        defaultCategory:
            defaultCategory == _undefined || defaultCategory == null
                ? _instance.defaultCategory
                : (defaultCategory as bool),
        id: id == _undefined || id == null ? _instance.id : (id as int),
        includeInDownload:
            includeInDownload == _undefined || includeInDownload == null
                ? _instance.includeInDownload
                : (includeInDownload as Enum$IncludeOrExclude),
        includeInUpdate:
            includeInUpdate == _undefined || includeInUpdate == null
                ? _instance.includeInUpdate
                : (includeInUpdate as Enum$IncludeOrExclude),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        order: order == _undefined || order == null
            ? _instance.order
            : (order as int),
        mangas: mangas == _undefined || mangas == null
            ? _instance.mangas
            : (mangas as Fragment$CategoryDto$mangas),
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as List<Fragment$CategoryDto$meta>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$CategoryDto$mangas<TRes> get mangas {
    final local$mangas = _instance.mangas;
    return CopyWith$Fragment$CategoryDto$mangas(
        local$mangas, (e) => call(mangas: e));
  }

  TRes meta(
          Iterable<Fragment$CategoryDto$meta> Function(
                  Iterable<
                      CopyWith$Fragment$CategoryDto$meta<
                          Fragment$CategoryDto$meta>>)
              _fn) =>
      call(
          meta:
              _fn(_instance.meta.map((e) => CopyWith$Fragment$CategoryDto$meta(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Fragment$CategoryDto<TRes>
    implements CopyWith$Fragment$CategoryDto<TRes> {
  _CopyWithStubImpl$Fragment$CategoryDto(this._res);

  TRes _res;

  call({
    bool? defaultCategory,
    int? id,
    Enum$IncludeOrExclude? includeInDownload,
    Enum$IncludeOrExclude? includeInUpdate,
    String? name,
    int? order,
    Fragment$CategoryDto$mangas? mangas,
    List<Fragment$CategoryDto$meta>? meta,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$CategoryDto$mangas<TRes> get mangas =>
      CopyWith$Fragment$CategoryDto$mangas.stub(_res);

  meta(_fn) => _res;
}

const fragmentDefinitionCategoryDto = FragmentDefinitionNode(
  name: NameNode(value: 'CategoryDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'CategoryType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'default'),
      alias: NameNode(value: 'defaultCategory'),
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
      name: NameNode(value: 'includeInDownload'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'includeInUpdate'),
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
      name: NameNode(value: 'order'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'mangas'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'totalCount'),
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
      name: NameNode(value: 'meta'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'key'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'value'),
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
const documentNodeFragmentCategoryDto = DocumentNode(definitions: [
  fragmentDefinitionCategoryDto,
]);

extension ClientExtension$Fragment$CategoryDto on graphql.GraphQLClient {
  void writeFragment$CategoryDto({
    required Fragment$CategoryDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'CategoryDto',
            document: documentNodeFragmentCategoryDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$CategoryDto? readFragment$CategoryDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'CategoryDto',
          document: documentNodeFragmentCategoryDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$CategoryDto.fromJson(result);
  }
}

class Fragment$CategoryDto$mangas {
  Fragment$CategoryDto$mangas({
    required this.totalCount,
    this.$__typename = 'MangaNodeList',
  });

  factory Fragment$CategoryDto$mangas.fromJson(Map<String, dynamic> json) {
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Fragment$CategoryDto$mangas(
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int totalCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$totalCount = totalCount;
    _resultData['totalCount'] = l$totalCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$totalCount = totalCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$totalCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CategoryDto$mangas ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$totalCount = totalCount;
    final lOther$totalCount = other.totalCount;
    if (l$totalCount != lOther$totalCount) {
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

extension UtilityExtension$Fragment$CategoryDto$mangas
    on Fragment$CategoryDto$mangas {
  CopyWith$Fragment$CategoryDto$mangas<Fragment$CategoryDto$mangas>
      get copyWith => CopyWith$Fragment$CategoryDto$mangas(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$CategoryDto$mangas<TRes> {
  factory CopyWith$Fragment$CategoryDto$mangas(
    Fragment$CategoryDto$mangas instance,
    TRes Function(Fragment$CategoryDto$mangas) then,
  ) = _CopyWithImpl$Fragment$CategoryDto$mangas;

  factory CopyWith$Fragment$CategoryDto$mangas.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CategoryDto$mangas;

  TRes call({
    int? totalCount,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$CategoryDto$mangas<TRes>
    implements CopyWith$Fragment$CategoryDto$mangas<TRes> {
  _CopyWithImpl$Fragment$CategoryDto$mangas(
    this._instance,
    this._then,
  );

  final Fragment$CategoryDto$mangas _instance;

  final TRes Function(Fragment$CategoryDto$mangas) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CategoryDto$mangas(
        totalCount: totalCount == _undefined || totalCount == null
            ? _instance.totalCount
            : (totalCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$CategoryDto$mangas<TRes>
    implements CopyWith$Fragment$CategoryDto$mangas<TRes> {
  _CopyWithStubImpl$Fragment$CategoryDto$mangas(this._res);

  TRes _res;

  call({
    int? totalCount,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$CategoryDto$meta {
  Fragment$CategoryDto$meta({
    required this.key,
    required this.value,
    this.$__typename = 'CategoryMetaType',
  });

  factory Fragment$CategoryDto$meta.fromJson(Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$CategoryDto$meta(
      key: (l$key as String),
      value: (l$value as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String key;

  final String value;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$key = key;
    _resultData['key'] = l$key;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$key,
      l$value,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CategoryDto$meta ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$key = key;
    final lOther$key = other.key;
    if (l$key != lOther$key) {
      return false;
    }
    final l$value = value;
    final lOther$value = other.value;
    if (l$value != lOther$value) {
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

extension UtilityExtension$Fragment$CategoryDto$meta
    on Fragment$CategoryDto$meta {
  CopyWith$Fragment$CategoryDto$meta<Fragment$CategoryDto$meta> get copyWith =>
      CopyWith$Fragment$CategoryDto$meta(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$CategoryDto$meta<TRes> {
  factory CopyWith$Fragment$CategoryDto$meta(
    Fragment$CategoryDto$meta instance,
    TRes Function(Fragment$CategoryDto$meta) then,
  ) = _CopyWithImpl$Fragment$CategoryDto$meta;

  factory CopyWith$Fragment$CategoryDto$meta.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CategoryDto$meta;

  TRes call({
    String? key,
    String? value,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$CategoryDto$meta<TRes>
    implements CopyWith$Fragment$CategoryDto$meta<TRes> {
  _CopyWithImpl$Fragment$CategoryDto$meta(
    this._instance,
    this._then,
  );

  final Fragment$CategoryDto$meta _instance;

  final TRes Function(Fragment$CategoryDto$meta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CategoryDto$meta(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$CategoryDto$meta<TRes>
    implements CopyWith$Fragment$CategoryDto$meta<TRes> {
  _CopyWithStubImpl$Fragment$CategoryDto$meta(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$CategoryPageDto {
  Fragment$CategoryPageDto({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'CategoryNodeList',
  });

  factory Fragment$CategoryPageDto.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Fragment$CategoryPageDto(
      nodes: (l$nodes as List<dynamic>)
          .map(
              (e) => Fragment$CategoryDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$CategoryDto> nodes;

  final Fragment$PageInfoDto pageInfo;

  final int totalCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes.map((e) => e.toJson()).toList();
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo.toJson();
    final l$totalCount = totalCount;
    _resultData['totalCount'] = l$totalCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$pageInfo = pageInfo;
    final l$totalCount = totalCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$nodes.map((v) => v)),
      l$pageInfo,
      l$totalCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CategoryPageDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes.length != lOther$nodes.length) {
      return false;
    }
    for (int i = 0; i < l$nodes.length; i++) {
      final l$nodes$entry = l$nodes[i];
      final lOther$nodes$entry = lOther$nodes[i];
      if (l$nodes$entry != lOther$nodes$entry) {
        return false;
      }
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$totalCount = totalCount;
    final lOther$totalCount = other.totalCount;
    if (l$totalCount != lOther$totalCount) {
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

extension UtilityExtension$Fragment$CategoryPageDto
    on Fragment$CategoryPageDto {
  CopyWith$Fragment$CategoryPageDto<Fragment$CategoryPageDto> get copyWith =>
      CopyWith$Fragment$CategoryPageDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$CategoryPageDto<TRes> {
  factory CopyWith$Fragment$CategoryPageDto(
    Fragment$CategoryPageDto instance,
    TRes Function(Fragment$CategoryPageDto) then,
  ) = _CopyWithImpl$Fragment$CategoryPageDto;

  factory CopyWith$Fragment$CategoryPageDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CategoryPageDto;

  TRes call({
    List<Fragment$CategoryDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$CategoryDto> Function(
              Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Fragment$CategoryPageDto<TRes>
    implements CopyWith$Fragment$CategoryPageDto<TRes> {
  _CopyWithImpl$Fragment$CategoryPageDto(
    this._instance,
    this._then,
  );

  final Fragment$CategoryPageDto _instance;

  final TRes Function(Fragment$CategoryPageDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CategoryPageDto(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$CategoryDto>),
        pageInfo: pageInfo == _undefined || pageInfo == null
            ? _instance.pageInfo
            : (pageInfo as Fragment$PageInfoDto),
        totalCount: totalCount == _undefined || totalCount == null
            ? _instance.totalCount
            : (totalCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Fragment$CategoryDto> Function(
                  Iterable<CopyWith$Fragment$CategoryDto<Fragment$CategoryDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$CategoryDto(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Fragment$CategoryPageDto<TRes>
    implements CopyWith$Fragment$CategoryPageDto<TRes> {
  _CopyWithStubImpl$Fragment$CategoryPageDto(this._res);

  TRes _res;

  call({
    List<Fragment$CategoryDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}

const fragmentDefinitionCategoryPageDto = FragmentDefinitionNode(
  name: NameNode(value: 'CategoryPageDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'CategoryNodeList'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'nodes'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'CategoryDto'),
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
      name: NameNode(value: 'pageInfo'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'PageInfoDto'),
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
      name: NameNode(value: 'totalCount'),
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
const documentNodeFragmentCategoryPageDto = DocumentNode(definitions: [
  fragmentDefinitionCategoryPageDto,
  fragmentDefinitionCategoryDto,
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$CategoryPageDto on graphql.GraphQLClient {
  void writeFragment$CategoryPageDto({
    required Fragment$CategoryPageDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'CategoryPageDto',
            document: documentNodeFragmentCategoryPageDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$CategoryPageDto? readFragment$CategoryPageDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'CategoryPageDto',
          document: documentNodeFragmentCategoryPageDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$CategoryPageDto.fromJson(result);
  }
}
