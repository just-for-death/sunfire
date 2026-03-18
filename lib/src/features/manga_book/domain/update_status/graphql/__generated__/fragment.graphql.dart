import '../../../../../../graphql/__generated__/fragments.graphql.dart';
import '../../../../../browse_center/domain/manga_page/graphql/__generated__/fragment.graphql.dart';
import '../../../../../browse_center/domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../../../library/domain/category/graphql/__generated__/fragment.graphql.dart';
import '../../../chapter/graphql/__generated__/fragment.graphql.dart';
import '../../../manga/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$UpdateStatusBaseDto {
  Fragment$UpdateStatusBaseDto({
    required this.isRunning,
    this.$__typename = 'UpdateStatus',
  });

  factory Fragment$UpdateStatusBaseDto.fromJson(Map<String, dynamic> json) {
    final l$isRunning = json['isRunning'];
    final l$$__typename = json['__typename'];
    return Fragment$UpdateStatusBaseDto(
      isRunning: (l$isRunning as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool isRunning;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$isRunning = isRunning;
    _resultData['isRunning'] = l$isRunning;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$isRunning = isRunning;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$isRunning,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UpdateStatusBaseDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$isRunning = isRunning;
    final lOther$isRunning = other.isRunning;
    if (l$isRunning != lOther$isRunning) {
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

extension UtilityExtension$Fragment$UpdateStatusBaseDto
    on Fragment$UpdateStatusBaseDto {
  CopyWith$Fragment$UpdateStatusBaseDto<Fragment$UpdateStatusBaseDto>
      get copyWith => CopyWith$Fragment$UpdateStatusBaseDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$UpdateStatusBaseDto<TRes> {
  factory CopyWith$Fragment$UpdateStatusBaseDto(
    Fragment$UpdateStatusBaseDto instance,
    TRes Function(Fragment$UpdateStatusBaseDto) then,
  ) = _CopyWithImpl$Fragment$UpdateStatusBaseDto;

  factory CopyWith$Fragment$UpdateStatusBaseDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UpdateStatusBaseDto;

  TRes call({
    bool? isRunning,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$UpdateStatusBaseDto<TRes>
    implements CopyWith$Fragment$UpdateStatusBaseDto<TRes> {
  _CopyWithImpl$Fragment$UpdateStatusBaseDto(
    this._instance,
    this._then,
  );

  final Fragment$UpdateStatusBaseDto _instance;

  final TRes Function(Fragment$UpdateStatusBaseDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? isRunning = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UpdateStatusBaseDto(
        isRunning: isRunning == _undefined || isRunning == null
            ? _instance.isRunning
            : (isRunning as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$UpdateStatusBaseDto<TRes>
    implements CopyWith$Fragment$UpdateStatusBaseDto<TRes> {
  _CopyWithStubImpl$Fragment$UpdateStatusBaseDto(this._res);

  TRes _res;

  call({
    bool? isRunning,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionUpdateStatusBaseDto = FragmentDefinitionNode(
  name: NameNode(value: 'UpdateStatusBaseDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'UpdateStatus'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'isRunning'),
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
const documentNodeFragmentUpdateStatusBaseDto = DocumentNode(definitions: [
  fragmentDefinitionUpdateStatusBaseDto,
]);

extension ClientExtension$Fragment$UpdateStatusBaseDto
    on graphql.GraphQLClient {
  void writeFragment$UpdateStatusBaseDto({
    required Fragment$UpdateStatusBaseDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'UpdateStatusBaseDto',
            document: documentNodeFragmentUpdateStatusBaseDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$UpdateStatusBaseDto? readFragment$UpdateStatusBaseDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'UpdateStatusBaseDto',
          document: documentNodeFragmentUpdateStatusBaseDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Fragment$UpdateStatusBaseDto.fromJson(result);
  }
}

class Fragment$UpdateStatusJobDto {
  Fragment$UpdateStatusJobDto({
    required this.mangas,
    this.$__typename = 'UpdateStatusType',
  });

  factory Fragment$UpdateStatusJobDto.fromJson(Map<String, dynamic> json) {
    final l$mangas = json['mangas'];
    final l$$__typename = json['__typename'];
    return Fragment$UpdateStatusJobDto(
      mangas:
          Fragment$MangaPageDto.fromJson((l$mangas as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$MangaPageDto mangas;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$mangas = mangas;
    _resultData['mangas'] = l$mangas.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$mangas = mangas;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$mangas,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UpdateStatusJobDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mangas = mangas;
    final lOther$mangas = other.mangas;
    if (l$mangas != lOther$mangas) {
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

extension UtilityExtension$Fragment$UpdateStatusJobDto
    on Fragment$UpdateStatusJobDto {
  CopyWith$Fragment$UpdateStatusJobDto<Fragment$UpdateStatusJobDto>
      get copyWith => CopyWith$Fragment$UpdateStatusJobDto(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$UpdateStatusJobDto<TRes> {
  factory CopyWith$Fragment$UpdateStatusJobDto(
    Fragment$UpdateStatusJobDto instance,
    TRes Function(Fragment$UpdateStatusJobDto) then,
  ) = _CopyWithImpl$Fragment$UpdateStatusJobDto;

  factory CopyWith$Fragment$UpdateStatusJobDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UpdateStatusJobDto;

  TRes call({
    Fragment$MangaPageDto? mangas,
    String? $__typename,
  });
  CopyWith$Fragment$MangaPageDto<TRes> get mangas;
}

class _CopyWithImpl$Fragment$UpdateStatusJobDto<TRes>
    implements CopyWith$Fragment$UpdateStatusJobDto<TRes> {
  _CopyWithImpl$Fragment$UpdateStatusJobDto(
    this._instance,
    this._then,
  );

  final Fragment$UpdateStatusJobDto _instance;

  final TRes Function(Fragment$UpdateStatusJobDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mangas = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UpdateStatusJobDto(
        mangas: mangas == _undefined || mangas == null
            ? _instance.mangas
            : (mangas as Fragment$MangaPageDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$MangaPageDto<TRes> get mangas {
    final local$mangas = _instance.mangas;
    return CopyWith$Fragment$MangaPageDto(local$mangas, (e) => call(mangas: e));
  }
}

class _CopyWithStubImpl$Fragment$UpdateStatusJobDto<TRes>
    implements CopyWith$Fragment$UpdateStatusJobDto<TRes> {
  _CopyWithStubImpl$Fragment$UpdateStatusJobDto(this._res);

  TRes _res;

  call({
    Fragment$MangaPageDto? mangas,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$MangaPageDto<TRes> get mangas =>
      CopyWith$Fragment$MangaPageDto.stub(_res);
}

const fragmentDefinitionUpdateStatusJobDto = FragmentDefinitionNode(
  name: NameNode(value: 'UpdateStatusJobDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'UpdateStatusType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'mangas'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'MangaPageDto'),
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
const documentNodeFragmentUpdateStatusJobDto = DocumentNode(definitions: [
  fragmentDefinitionUpdateStatusJobDto,
  fragmentDefinitionMangaPageDto,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
]);

extension ClientExtension$Fragment$UpdateStatusJobDto on graphql.GraphQLClient {
  void writeFragment$UpdateStatusJobDto({
    required Fragment$UpdateStatusJobDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'UpdateStatusJobDto',
            document: documentNodeFragmentUpdateStatusJobDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$UpdateStatusJobDto? readFragment$UpdateStatusJobDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'UpdateStatusJobDto',
          document: documentNodeFragmentUpdateStatusJobDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$UpdateStatusJobDto.fromJson(result);
  }
}

class Fragment$UpdateStatusDto implements Fragment$UpdateStatusBaseDto {
  Fragment$UpdateStatusDto({
    required this.isRunning,
    this.$__typename = 'UpdateStatus',
    required this.completeJobs,
    required this.failedJobs,
    required this.pendingJobs,
    required this.runningJobs,
    required this.skippedCategories,
    required this.skippedJobs,
    required this.updatingCategories,
  });

  factory Fragment$UpdateStatusDto.fromJson(Map<String, dynamic> json) {
    final l$isRunning = json['isRunning'];
    final l$$__typename = json['__typename'];
    final l$completeJobs = json['completeJobs'];
    final l$failedJobs = json['failedJobs'];
    final l$pendingJobs = json['pendingJobs'];
    final l$runningJobs = json['runningJobs'];
    final l$skippedCategories = json['skippedCategories'];
    final l$skippedJobs = json['skippedJobs'];
    final l$updatingCategories = json['updatingCategories'];
    return Fragment$UpdateStatusDto(
      isRunning: (l$isRunning as bool),
      $__typename: (l$$__typename as String),
      completeJobs: Fragment$UpdateStatusJobDto.fromJson(
          (l$completeJobs as Map<String, dynamic>)),
      failedJobs: Fragment$UpdateStatusJobDto.fromJson(
          (l$failedJobs as Map<String, dynamic>)),
      pendingJobs: Fragment$UpdateStatusJobDto.fromJson(
          (l$pendingJobs as Map<String, dynamic>)),
      runningJobs: Fragment$UpdateStatusJobDto.fromJson(
          (l$runningJobs as Map<String, dynamic>)),
      skippedCategories: Fragment$UpdateStatusDto$skippedCategories.fromJson(
          (l$skippedCategories as Map<String, dynamic>)),
      skippedJobs: Fragment$UpdateStatusJobDto.fromJson(
          (l$skippedJobs as Map<String, dynamic>)),
      updatingCategories: Fragment$UpdateStatusDto$updatingCategories.fromJson(
          (l$updatingCategories as Map<String, dynamic>)),
    );
  }

  final bool isRunning;

  final String $__typename;

  final Fragment$UpdateStatusJobDto completeJobs;

  final Fragment$UpdateStatusJobDto failedJobs;

  final Fragment$UpdateStatusJobDto pendingJobs;

  final Fragment$UpdateStatusJobDto runningJobs;

  final Fragment$UpdateStatusDto$skippedCategories skippedCategories;

  final Fragment$UpdateStatusJobDto skippedJobs;

  final Fragment$UpdateStatusDto$updatingCategories updatingCategories;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$isRunning = isRunning;
    _resultData['isRunning'] = l$isRunning;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$completeJobs = completeJobs;
    _resultData['completeJobs'] = l$completeJobs.toJson();
    final l$failedJobs = failedJobs;
    _resultData['failedJobs'] = l$failedJobs.toJson();
    final l$pendingJobs = pendingJobs;
    _resultData['pendingJobs'] = l$pendingJobs.toJson();
    final l$runningJobs = runningJobs;
    _resultData['runningJobs'] = l$runningJobs.toJson();
    final l$skippedCategories = skippedCategories;
    _resultData['skippedCategories'] = l$skippedCategories.toJson();
    final l$skippedJobs = skippedJobs;
    _resultData['skippedJobs'] = l$skippedJobs.toJson();
    final l$updatingCategories = updatingCategories;
    _resultData['updatingCategories'] = l$updatingCategories.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$isRunning = isRunning;
    final l$$__typename = $__typename;
    final l$completeJobs = completeJobs;
    final l$failedJobs = failedJobs;
    final l$pendingJobs = pendingJobs;
    final l$runningJobs = runningJobs;
    final l$skippedCategories = skippedCategories;
    final l$skippedJobs = skippedJobs;
    final l$updatingCategories = updatingCategories;
    return Object.hashAll([
      l$isRunning,
      l$$__typename,
      l$completeJobs,
      l$failedJobs,
      l$pendingJobs,
      l$runningJobs,
      l$skippedCategories,
      l$skippedJobs,
      l$updatingCategories,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UpdateStatusDto ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$isRunning = isRunning;
    final lOther$isRunning = other.isRunning;
    if (l$isRunning != lOther$isRunning) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$completeJobs = completeJobs;
    final lOther$completeJobs = other.completeJobs;
    if (l$completeJobs != lOther$completeJobs) {
      return false;
    }
    final l$failedJobs = failedJobs;
    final lOther$failedJobs = other.failedJobs;
    if (l$failedJobs != lOther$failedJobs) {
      return false;
    }
    final l$pendingJobs = pendingJobs;
    final lOther$pendingJobs = other.pendingJobs;
    if (l$pendingJobs != lOther$pendingJobs) {
      return false;
    }
    final l$runningJobs = runningJobs;
    final lOther$runningJobs = other.runningJobs;
    if (l$runningJobs != lOther$runningJobs) {
      return false;
    }
    final l$skippedCategories = skippedCategories;
    final lOther$skippedCategories = other.skippedCategories;
    if (l$skippedCategories != lOther$skippedCategories) {
      return false;
    }
    final l$skippedJobs = skippedJobs;
    final lOther$skippedJobs = other.skippedJobs;
    if (l$skippedJobs != lOther$skippedJobs) {
      return false;
    }
    final l$updatingCategories = updatingCategories;
    final lOther$updatingCategories = other.updatingCategories;
    if (l$updatingCategories != lOther$updatingCategories) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$UpdateStatusDto
    on Fragment$UpdateStatusDto {
  CopyWith$Fragment$UpdateStatusDto<Fragment$UpdateStatusDto> get copyWith =>
      CopyWith$Fragment$UpdateStatusDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$UpdateStatusDto<TRes> {
  factory CopyWith$Fragment$UpdateStatusDto(
    Fragment$UpdateStatusDto instance,
    TRes Function(Fragment$UpdateStatusDto) then,
  ) = _CopyWithImpl$Fragment$UpdateStatusDto;

  factory CopyWith$Fragment$UpdateStatusDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UpdateStatusDto;

  TRes call({
    bool? isRunning,
    String? $__typename,
    Fragment$UpdateStatusJobDto? completeJobs,
    Fragment$UpdateStatusJobDto? failedJobs,
    Fragment$UpdateStatusJobDto? pendingJobs,
    Fragment$UpdateStatusJobDto? runningJobs,
    Fragment$UpdateStatusDto$skippedCategories? skippedCategories,
    Fragment$UpdateStatusJobDto? skippedJobs,
    Fragment$UpdateStatusDto$updatingCategories? updatingCategories,
  });
  CopyWith$Fragment$UpdateStatusJobDto<TRes> get completeJobs;
  CopyWith$Fragment$UpdateStatusJobDto<TRes> get failedJobs;
  CopyWith$Fragment$UpdateStatusJobDto<TRes> get pendingJobs;
  CopyWith$Fragment$UpdateStatusJobDto<TRes> get runningJobs;
  CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes>
      get skippedCategories;
  CopyWith$Fragment$UpdateStatusJobDto<TRes> get skippedJobs;
  CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes>
      get updatingCategories;
}

class _CopyWithImpl$Fragment$UpdateStatusDto<TRes>
    implements CopyWith$Fragment$UpdateStatusDto<TRes> {
  _CopyWithImpl$Fragment$UpdateStatusDto(
    this._instance,
    this._then,
  );

  final Fragment$UpdateStatusDto _instance;

  final TRes Function(Fragment$UpdateStatusDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? isRunning = _undefined,
    Object? $__typename = _undefined,
    Object? completeJobs = _undefined,
    Object? failedJobs = _undefined,
    Object? pendingJobs = _undefined,
    Object? runningJobs = _undefined,
    Object? skippedCategories = _undefined,
    Object? skippedJobs = _undefined,
    Object? updatingCategories = _undefined,
  }) =>
      _then(Fragment$UpdateStatusDto(
        isRunning: isRunning == _undefined || isRunning == null
            ? _instance.isRunning
            : (isRunning as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        completeJobs: completeJobs == _undefined || completeJobs == null
            ? _instance.completeJobs
            : (completeJobs as Fragment$UpdateStatusJobDto),
        failedJobs: failedJobs == _undefined || failedJobs == null
            ? _instance.failedJobs
            : (failedJobs as Fragment$UpdateStatusJobDto),
        pendingJobs: pendingJobs == _undefined || pendingJobs == null
            ? _instance.pendingJobs
            : (pendingJobs as Fragment$UpdateStatusJobDto),
        runningJobs: runningJobs == _undefined || runningJobs == null
            ? _instance.runningJobs
            : (runningJobs as Fragment$UpdateStatusJobDto),
        skippedCategories: skippedCategories == _undefined ||
                skippedCategories == null
            ? _instance.skippedCategories
            : (skippedCategories as Fragment$UpdateStatusDto$skippedCategories),
        skippedJobs: skippedJobs == _undefined || skippedJobs == null
            ? _instance.skippedJobs
            : (skippedJobs as Fragment$UpdateStatusJobDto),
        updatingCategories:
            updatingCategories == _undefined || updatingCategories == null
                ? _instance.updatingCategories
                : (updatingCategories
                    as Fragment$UpdateStatusDto$updatingCategories),
      ));

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get completeJobs {
    final local$completeJobs = _instance.completeJobs;
    return CopyWith$Fragment$UpdateStatusJobDto(
        local$completeJobs, (e) => call(completeJobs: e));
  }

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get failedJobs {
    final local$failedJobs = _instance.failedJobs;
    return CopyWith$Fragment$UpdateStatusJobDto(
        local$failedJobs, (e) => call(failedJobs: e));
  }

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get pendingJobs {
    final local$pendingJobs = _instance.pendingJobs;
    return CopyWith$Fragment$UpdateStatusJobDto(
        local$pendingJobs, (e) => call(pendingJobs: e));
  }

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get runningJobs {
    final local$runningJobs = _instance.runningJobs;
    return CopyWith$Fragment$UpdateStatusJobDto(
        local$runningJobs, (e) => call(runningJobs: e));
  }

  CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes>
      get skippedCategories {
    final local$skippedCategories = _instance.skippedCategories;
    return CopyWith$Fragment$UpdateStatusDto$skippedCategories(
        local$skippedCategories, (e) => call(skippedCategories: e));
  }

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get skippedJobs {
    final local$skippedJobs = _instance.skippedJobs;
    return CopyWith$Fragment$UpdateStatusJobDto(
        local$skippedJobs, (e) => call(skippedJobs: e));
  }

  CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes>
      get updatingCategories {
    final local$updatingCategories = _instance.updatingCategories;
    return CopyWith$Fragment$UpdateStatusDto$updatingCategories(
        local$updatingCategories, (e) => call(updatingCategories: e));
  }
}

class _CopyWithStubImpl$Fragment$UpdateStatusDto<TRes>
    implements CopyWith$Fragment$UpdateStatusDto<TRes> {
  _CopyWithStubImpl$Fragment$UpdateStatusDto(this._res);

  TRes _res;

  call({
    bool? isRunning,
    String? $__typename,
    Fragment$UpdateStatusJobDto? completeJobs,
    Fragment$UpdateStatusJobDto? failedJobs,
    Fragment$UpdateStatusJobDto? pendingJobs,
    Fragment$UpdateStatusJobDto? runningJobs,
    Fragment$UpdateStatusDto$skippedCategories? skippedCategories,
    Fragment$UpdateStatusJobDto? skippedJobs,
    Fragment$UpdateStatusDto$updatingCategories? updatingCategories,
  }) =>
      _res;

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get completeJobs =>
      CopyWith$Fragment$UpdateStatusJobDto.stub(_res);

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get failedJobs =>
      CopyWith$Fragment$UpdateStatusJobDto.stub(_res);

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get pendingJobs =>
      CopyWith$Fragment$UpdateStatusJobDto.stub(_res);

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get runningJobs =>
      CopyWith$Fragment$UpdateStatusJobDto.stub(_res);

  CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes>
      get skippedCategories =>
          CopyWith$Fragment$UpdateStatusDto$skippedCategories.stub(_res);

  CopyWith$Fragment$UpdateStatusJobDto<TRes> get skippedJobs =>
      CopyWith$Fragment$UpdateStatusJobDto.stub(_res);

  CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes>
      get updatingCategories =>
          CopyWith$Fragment$UpdateStatusDto$updatingCategories.stub(_res);
}

const fragmentDefinitionUpdateStatusDto = FragmentDefinitionNode(
  name: NameNode(value: 'UpdateStatusDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'UpdateStatus'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FragmentSpreadNode(
      name: NameNode(value: 'UpdateStatusBaseDto'),
      directives: [],
    ),
    FieldNode(
      name: NameNode(value: 'completeJobs'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'UpdateStatusJobDto'),
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
      name: NameNode(value: 'failedJobs'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'UpdateStatusJobDto'),
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
      name: NameNode(value: 'pendingJobs'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'UpdateStatusJobDto'),
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
      name: NameNode(value: 'runningJobs'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'UpdateStatusJobDto'),
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
      name: NameNode(value: 'skippedCategories'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'categories'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'CategoryPageDto'),
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
    ),
    FieldNode(
      name: NameNode(value: 'skippedJobs'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'UpdateStatusJobDto'),
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
      name: NameNode(value: 'updatingCategories'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'categories'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'CategoryPageDto'),
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
const documentNodeFragmentUpdateStatusDto = DocumentNode(definitions: [
  fragmentDefinitionUpdateStatusDto,
  fragmentDefinitionUpdateStatusBaseDto,
  fragmentDefinitionUpdateStatusJobDto,
  fragmentDefinitionMangaPageDto,
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
  fragmentDefinitionPageInfoDto,
  fragmentDefinitionCategoryPageDto,
  fragmentDefinitionCategoryDto,
]);

extension ClientExtension$Fragment$UpdateStatusDto on graphql.GraphQLClient {
  void writeFragment$UpdateStatusDto({
    required Fragment$UpdateStatusDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'UpdateStatusDto',
            document: documentNodeFragmentUpdateStatusDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$UpdateStatusDto? readFragment$UpdateStatusDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'UpdateStatusDto',
          document: documentNodeFragmentUpdateStatusDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$UpdateStatusDto.fromJson(result);
  }
}

class Fragment$UpdateStatusDto$skippedCategories {
  Fragment$UpdateStatusDto$skippedCategories({
    required this.categories,
    this.$__typename = 'UpdateStatusCategoryType',
  });

  factory Fragment$UpdateStatusDto$skippedCategories.fromJson(
      Map<String, dynamic> json) {
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Fragment$UpdateStatusDto$skippedCategories(
      categories: Fragment$CategoryPageDto.fromJson(
          (l$categories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$CategoryPageDto categories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$categories = categories;
    _resultData['categories'] = l$categories.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$categories = categories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$categories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UpdateStatusDto$skippedCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categories = categories;
    final lOther$categories = other.categories;
    if (l$categories != lOther$categories) {
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

extension UtilityExtension$Fragment$UpdateStatusDto$skippedCategories
    on Fragment$UpdateStatusDto$skippedCategories {
  CopyWith$Fragment$UpdateStatusDto$skippedCategories<
          Fragment$UpdateStatusDto$skippedCategories>
      get copyWith => CopyWith$Fragment$UpdateStatusDto$skippedCategories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes> {
  factory CopyWith$Fragment$UpdateStatusDto$skippedCategories(
    Fragment$UpdateStatusDto$skippedCategories instance,
    TRes Function(Fragment$UpdateStatusDto$skippedCategories) then,
  ) = _CopyWithImpl$Fragment$UpdateStatusDto$skippedCategories;

  factory CopyWith$Fragment$UpdateStatusDto$skippedCategories.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UpdateStatusDto$skippedCategories;

  TRes call({
    Fragment$CategoryPageDto? categories,
    String? $__typename,
  });
  CopyWith$Fragment$CategoryPageDto<TRes> get categories;
}

class _CopyWithImpl$Fragment$UpdateStatusDto$skippedCategories<TRes>
    implements CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes> {
  _CopyWithImpl$Fragment$UpdateStatusDto$skippedCategories(
    this._instance,
    this._then,
  );

  final Fragment$UpdateStatusDto$skippedCategories _instance;

  final TRes Function(Fragment$UpdateStatusDto$skippedCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UpdateStatusDto$skippedCategories(
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories as Fragment$CategoryPageDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$CategoryPageDto<TRes> get categories {
    final local$categories = _instance.categories;
    return CopyWith$Fragment$CategoryPageDto(
        local$categories, (e) => call(categories: e));
  }
}

class _CopyWithStubImpl$Fragment$UpdateStatusDto$skippedCategories<TRes>
    implements CopyWith$Fragment$UpdateStatusDto$skippedCategories<TRes> {
  _CopyWithStubImpl$Fragment$UpdateStatusDto$skippedCategories(this._res);

  TRes _res;

  call({
    Fragment$CategoryPageDto? categories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$CategoryPageDto<TRes> get categories =>
      CopyWith$Fragment$CategoryPageDto.stub(_res);
}

class Fragment$UpdateStatusDto$updatingCategories {
  Fragment$UpdateStatusDto$updatingCategories({
    required this.categories,
    this.$__typename = 'UpdateStatusCategoryType',
  });

  factory Fragment$UpdateStatusDto$updatingCategories.fromJson(
      Map<String, dynamic> json) {
    final l$categories = json['categories'];
    final l$$__typename = json['__typename'];
    return Fragment$UpdateStatusDto$updatingCategories(
      categories: Fragment$CategoryPageDto.fromJson(
          (l$categories as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$CategoryPageDto categories;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$categories = categories;
    _resultData['categories'] = l$categories.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$categories = categories;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$categories,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UpdateStatusDto$updatingCategories ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$categories = categories;
    final lOther$categories = other.categories;
    if (l$categories != lOther$categories) {
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

extension UtilityExtension$Fragment$UpdateStatusDto$updatingCategories
    on Fragment$UpdateStatusDto$updatingCategories {
  CopyWith$Fragment$UpdateStatusDto$updatingCategories<
          Fragment$UpdateStatusDto$updatingCategories>
      get copyWith => CopyWith$Fragment$UpdateStatusDto$updatingCategories(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes> {
  factory CopyWith$Fragment$UpdateStatusDto$updatingCategories(
    Fragment$UpdateStatusDto$updatingCategories instance,
    TRes Function(Fragment$UpdateStatusDto$updatingCategories) then,
  ) = _CopyWithImpl$Fragment$UpdateStatusDto$updatingCategories;

  factory CopyWith$Fragment$UpdateStatusDto$updatingCategories.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UpdateStatusDto$updatingCategories;

  TRes call({
    Fragment$CategoryPageDto? categories,
    String? $__typename,
  });
  CopyWith$Fragment$CategoryPageDto<TRes> get categories;
}

class _CopyWithImpl$Fragment$UpdateStatusDto$updatingCategories<TRes>
    implements CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes> {
  _CopyWithImpl$Fragment$UpdateStatusDto$updatingCategories(
    this._instance,
    this._then,
  );

  final Fragment$UpdateStatusDto$updatingCategories _instance;

  final TRes Function(Fragment$UpdateStatusDto$updatingCategories) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? categories = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UpdateStatusDto$updatingCategories(
        categories: categories == _undefined || categories == null
            ? _instance.categories
            : (categories as Fragment$CategoryPageDto),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$CategoryPageDto<TRes> get categories {
    final local$categories = _instance.categories;
    return CopyWith$Fragment$CategoryPageDto(
        local$categories, (e) => call(categories: e));
  }
}

class _CopyWithStubImpl$Fragment$UpdateStatusDto$updatingCategories<TRes>
    implements CopyWith$Fragment$UpdateStatusDto$updatingCategories<TRes> {
  _CopyWithStubImpl$Fragment$UpdateStatusDto$updatingCategories(this._res);

  TRes _res;

  call({
    Fragment$CategoryPageDto? categories,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$CategoryPageDto<TRes> get categories =>
      CopyWith$Fragment$CategoryPageDto.stub(_res);
}
