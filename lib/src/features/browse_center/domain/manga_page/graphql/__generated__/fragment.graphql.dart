import '../../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../manga_book/domain/chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../../../manga_book/domain/manga/graphql/__generated__/fragment.graphql.dart';
import '../../../source/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$SourceMangaPage {
  Fragment$SourceMangaPage({
    required this.hasNextPage,
    required this.mangas,
    this.$__typename = 'FetchSourceMangaPayload',
  });

  factory Fragment$SourceMangaPage.fromJson(Map<String, dynamic> json) {
    final l$hasNextPage = json['hasNextPage'];
    final l$mangas = json['mangas'];
    final l$$__typename = json['__typename'];
    return Fragment$SourceMangaPage(
      hasNextPage: (l$hasNextPage as bool),
      mangas: (l$mangas as List<dynamic>)
          .map((e) => Fragment$MangaDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final bool hasNextPage;

  final List<Fragment$MangaDto> mangas;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$mangas = mangas;
    _resultData['mangas'] = l$mangas.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$hasNextPage = hasNextPage;
    final l$mangas = mangas;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$hasNextPage,
      Object.hashAll(l$mangas.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$SourceMangaPage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$mangas = mangas;
    final lOther$mangas = other.mangas;
    if (l$mangas.length != lOther$mangas.length) {
      return false;
    }
    for (int i = 0; i < l$mangas.length; i++) {
      final l$mangas$entry = l$mangas[i];
      final lOther$mangas$entry = lOther$mangas[i];
      if (l$mangas$entry != lOther$mangas$entry) {
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

extension UtilityExtension$Fragment$SourceMangaPage
    on Fragment$SourceMangaPage {
  CopyWith$Fragment$SourceMangaPage<Fragment$SourceMangaPage> get copyWith =>
      CopyWith$Fragment$SourceMangaPage(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$SourceMangaPage<TRes> {
  factory CopyWith$Fragment$SourceMangaPage(
    Fragment$SourceMangaPage instance,
    TRes Function(Fragment$SourceMangaPage) then,
  ) = _CopyWithImpl$Fragment$SourceMangaPage;

  factory CopyWith$Fragment$SourceMangaPage.stub(TRes res) =
      _CopyWithStubImpl$Fragment$SourceMangaPage;

  TRes call({
    bool? hasNextPage,
    List<Fragment$MangaDto>? mangas,
    String? $__typename,
  });
  TRes mangas(
      Iterable<Fragment$MangaDto> Function(
              Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
          _fn);
}

class _CopyWithImpl$Fragment$SourceMangaPage<TRes>
    implements CopyWith$Fragment$SourceMangaPage<TRes> {
  _CopyWithImpl$Fragment$SourceMangaPage(
    this._instance,
    this._then,
  );

  final Fragment$SourceMangaPage _instance;

  final TRes Function(Fragment$SourceMangaPage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? hasNextPage = _undefined,
    Object? mangas = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$SourceMangaPage(
        hasNextPage: hasNextPage == _undefined || hasNextPage == null
            ? _instance.hasNextPage
            : (hasNextPage as bool),
        mangas: mangas == _undefined || mangas == null
            ? _instance.mangas
            : (mangas as List<Fragment$MangaDto>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes mangas(
          Iterable<Fragment$MangaDto> Function(
                  Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
              _fn) =>
      call(
          mangas: _fn(_instance.mangas.map((e) => CopyWith$Fragment$MangaDto(
                e,
                (i) => i,
              ))).toList());
}

class _CopyWithStubImpl$Fragment$SourceMangaPage<TRes>
    implements CopyWith$Fragment$SourceMangaPage<TRes> {
  _CopyWithStubImpl$Fragment$SourceMangaPage(this._res);

  TRes _res;

  call({
    bool? hasNextPage,
    List<Fragment$MangaDto>? mangas,
    String? $__typename,
  }) =>
      _res;

  mangas(_fn) => _res;
}

const fragmentDefinitionSourceMangaPage = FragmentDefinitionNode(
  name: NameNode(value: 'SourceMangaPage'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'FetchSourceMangaPayload'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'hasNextPage'),
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
        FragmentSpreadNode(
          name: NameNode(value: 'MangaDto'),
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
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentSourceMangaPage = DocumentNode(definitions: [
  fragmentDefinitionSourceMangaPage,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
]);

extension ClientExtension$Fragment$SourceMangaPage on graphql.GraphQLClient {
  void writeFragment$SourceMangaPage({
    required Fragment$SourceMangaPage data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'SourceMangaPage',
            document: documentNodeFragmentSourceMangaPage,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$SourceMangaPage? readFragment$SourceMangaPage({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'SourceMangaPage',
          document: documentNodeFragmentSourceMangaPage,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$SourceMangaPage.fromJson(result);
  }
}

class Fragment$MangaPageDto {
  Fragment$MangaPageDto({
    required this.nodes,
    required this.pageInfo,
    required this.totalCount,
    this.$__typename = 'MangaNodeList',
  });

  factory Fragment$MangaPageDto.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$pageInfo = json['pageInfo'];
    final l$totalCount = json['totalCount'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaPageDto(
      nodes: (l$nodes as List<dynamic>)
          .map((e) => Fragment$MangaDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pageInfo:
          Fragment$PageInfoDto.fromJson((l$pageInfo as Map<String, dynamic>)),
      totalCount: (l$totalCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$MangaDto> nodes;

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
    if (other is! Fragment$MangaPageDto || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$MangaPageDto on Fragment$MangaPageDto {
  CopyWith$Fragment$MangaPageDto<Fragment$MangaPageDto> get copyWith =>
      CopyWith$Fragment$MangaPageDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MangaPageDto<TRes> {
  factory CopyWith$Fragment$MangaPageDto(
    Fragment$MangaPageDto instance,
    TRes Function(Fragment$MangaPageDto) then,
  ) = _CopyWithImpl$Fragment$MangaPageDto;

  factory CopyWith$Fragment$MangaPageDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaPageDto;

  TRes call({
    List<Fragment$MangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Fragment$MangaDto> Function(
              Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
          _fn);
  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo;
}

class _CopyWithImpl$Fragment$MangaPageDto<TRes>
    implements CopyWith$Fragment$MangaPageDto<TRes> {
  _CopyWithImpl$Fragment$MangaPageDto(
    this._instance,
    this._then,
  );

  final Fragment$MangaPageDto _instance;

  final TRes Function(Fragment$MangaPageDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? pageInfo = _undefined,
    Object? totalCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaPageDto(
        nodes: nodes == _undefined || nodes == null
            ? _instance.nodes
            : (nodes as List<Fragment$MangaDto>),
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
          Iterable<Fragment$MangaDto> Function(
                  Iterable<CopyWith$Fragment$MangaDto<Fragment$MangaDto>>)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes.map((e) => CopyWith$Fragment$MangaDto(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return CopyWith$Fragment$PageInfoDto(
        local$pageInfo, (e) => call(pageInfo: e));
  }
}

class _CopyWithStubImpl$Fragment$MangaPageDto<TRes>
    implements CopyWith$Fragment$MangaPageDto<TRes> {
  _CopyWithStubImpl$Fragment$MangaPageDto(this._res);

  TRes _res;

  call({
    List<Fragment$MangaDto>? nodes,
    Fragment$PageInfoDto? pageInfo,
    int? totalCount,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;

  CopyWith$Fragment$PageInfoDto<TRes> get pageInfo =>
      CopyWith$Fragment$PageInfoDto.stub(_res);
}

const fragmentDefinitionMangaPageDto = FragmentDefinitionNode(
  name: NameNode(value: 'MangaPageDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'MangaNodeList'),
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
          name: NameNode(value: 'MangaDto'),
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
const documentNodeFragmentMangaPageDto = DocumentNode(definitions: [
  fragmentDefinitionMangaPageDto,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$MangaPageDto on graphql.GraphQLClient {
  void writeFragment$MangaPageDto({
    required Fragment$MangaPageDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'MangaPageDto',
            document: documentNodeFragmentMangaPageDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$MangaPageDto? readFragment$MangaPageDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'MangaPageDto',
          document: documentNodeFragmentMangaPageDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$MangaPageDto.fromJson(result);
  }
}
