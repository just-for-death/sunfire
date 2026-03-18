import '../../../../../../graphql/__generated__/schema.graphql.dart';
import '../../../../../browse_center/domain/source/graphql/__generated__/fragment.graphql.dart';
import '../../../chapter/graphql/__generated__/fragment.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:catalyst/src/utils/misc/scalars.dart';

class Fragment$MangaDto {
  Fragment$MangaDto({
    this.age,
    this.artist,
    this.author,
    this.chaptersAge,
    this.chaptersLastFetchedAt,
    this.description,
    required this.downloadCount,
    required this.genre,
    required this.id,
    required this.inLibrary,
    required this.inLibraryAt,
    required this.initialized,
    this.lastFetchedAt,
    this.lastReadChapter,
    this.latestFetchedChapter,
    this.latestReadChapter,
    this.latestUploadedChapter,
    required this.meta,
    this.realUrl,
    this.source,
    required this.sourceId,
    required this.status,
    this.thumbnailUrl,
    this.thumbnailUrlLastFetched,
    required this.title,
    required this.unreadCount,
    required this.updateStrategy,
    required this.url,
    this.$__typename = 'MangaType',
  });

  factory Fragment$MangaDto.fromJson(Map<String, dynamic> json) {
    final l$age = json['age'];
    final l$artist = json['artist'];
    final l$author = json['author'];
    final l$chaptersAge = json['chaptersAge'];
    final l$chaptersLastFetchedAt = json['chaptersLastFetchedAt'];
    final l$description = json['description'];
    final l$downloadCount = json['downloadCount'];
    final l$genre = json['genre'];
    final l$id = json['id'];
    final l$inLibrary = json['inLibrary'];
    final l$inLibraryAt = json['inLibraryAt'];
    final l$initialized = json['initialized'];
    final l$lastFetchedAt = json['lastFetchedAt'];
    final l$lastReadChapter = json['lastReadChapter'];
    final l$latestFetchedChapter = json['latestFetchedChapter'];
    final l$latestReadChapter = json['latestReadChapter'];
    final l$latestUploadedChapter = json['latestUploadedChapter'];
    final l$meta = json['meta'];
    final l$realUrl = json['realUrl'];
    final l$source = json['source'];
    final l$sourceId = json['sourceId'];
    final l$status = json['status'];
    final l$thumbnailUrl = json['thumbnailUrl'];
    final l$thumbnailUrlLastFetched = json['thumbnailUrlLastFetched'];
    final l$title = json['title'];
    final l$unreadCount = json['unreadCount'];
    final l$updateStrategy = json['updateStrategy'];
    final l$url = json['url'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaDto(
      age: l$age == null ? null : longStringFromJson(l$age),
      artist: (l$artist as String?),
      author: (l$author as String?),
      chaptersAge:
          l$chaptersAge == null ? null : longStringFromJson(l$chaptersAge),
      chaptersLastFetchedAt: l$chaptersLastFetchedAt == null
          ? null
          : longStringFromJson(l$chaptersLastFetchedAt),
      description: (l$description as String?),
      downloadCount: (l$downloadCount as int),
      genre: (l$genre as List<dynamic>).map((e) => (e as String)).toList(),
      id: (l$id as int),
      inLibrary: (l$inLibrary as bool),
      inLibraryAt: longStringFromJson(l$inLibraryAt),
      initialized: (l$initialized as bool),
      lastFetchedAt:
          l$lastFetchedAt == null ? null : longStringFromJson(l$lastFetchedAt),
      lastReadChapter: l$lastReadChapter == null
          ? null
          : Fragment$ChapterDto.fromJson(
              (l$lastReadChapter as Map<String, dynamic>)),
      latestFetchedChapter: l$latestFetchedChapter == null
          ? null
          : Fragment$ChapterDto.fromJson(
              (l$latestFetchedChapter as Map<String, dynamic>)),
      latestReadChapter: l$latestReadChapter == null
          ? null
          : Fragment$ChapterDto.fromJson(
              (l$latestReadChapter as Map<String, dynamic>)),
      latestUploadedChapter: l$latestUploadedChapter == null
          ? null
          : Fragment$ChapterDto.fromJson(
              (l$latestUploadedChapter as Map<String, dynamic>)),
      meta: (l$meta as List<dynamic>)
          .map((e) =>
              Fragment$MangaDto$meta.fromJson((e as Map<String, dynamic>)))
          .toList(),
      realUrl: (l$realUrl as String?),
      source: l$source == null
          ? null
          : Fragment$SourceDto.fromJson((l$source as Map<String, dynamic>)),
      sourceId: longStringFromJson(l$sourceId),
      status: fromJson$Enum$MangaStatus((l$status as String)),
      thumbnailUrl: (l$thumbnailUrl as String?),
      thumbnailUrlLastFetched: l$thumbnailUrlLastFetched == null
          ? null
          : longStringFromJson(l$thumbnailUrlLastFetched),
      title: (l$title as String),
      unreadCount: (l$unreadCount as int),
      updateStrategy:
          fromJson$Enum$UpdateStrategy((l$updateStrategy as String)),
      url: (l$url as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String? age;

  final String? artist;

  final String? author;

  final String? chaptersAge;

  final String? chaptersLastFetchedAt;

  final String? description;

  final int downloadCount;

  final List<String> genre;

  final int id;

  final bool inLibrary;

  final String inLibraryAt;

  final bool initialized;

  final String? lastFetchedAt;

  final Fragment$ChapterDto? lastReadChapter;

  final Fragment$ChapterDto? latestFetchedChapter;

  final Fragment$ChapterDto? latestReadChapter;

  final Fragment$ChapterDto? latestUploadedChapter;

  final List<Fragment$MangaDto$meta> meta;

  final String? realUrl;

  final Fragment$SourceDto? source;

  final String sourceId;

  final Enum$MangaStatus status;

  final String? thumbnailUrl;

  final String? thumbnailUrlLastFetched;

  final String title;

  final int unreadCount;

  final Enum$UpdateStrategy updateStrategy;

  final String url;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$age = age;
    _resultData['age'] = l$age == null ? null : longStringToJson(l$age);
    final l$artist = artist;
    _resultData['artist'] = l$artist;
    final l$author = author;
    _resultData['author'] = l$author;
    final l$chaptersAge = chaptersAge;
    _resultData['chaptersAge'] =
        l$chaptersAge == null ? null : longStringToJson(l$chaptersAge);
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    _resultData['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt == null
        ? null
        : longStringToJson(l$chaptersLastFetchedAt);
    final l$description = description;
    _resultData['description'] = l$description;
    final l$downloadCount = downloadCount;
    _resultData['downloadCount'] = l$downloadCount;
    final l$genre = genre;
    _resultData['genre'] = l$genre.map((e) => e).toList();
    final l$id = id;
    _resultData['id'] = l$id;
    final l$inLibrary = inLibrary;
    _resultData['inLibrary'] = l$inLibrary;
    final l$inLibraryAt = inLibraryAt;
    _resultData['inLibraryAt'] = longStringToJson(l$inLibraryAt);
    final l$initialized = initialized;
    _resultData['initialized'] = l$initialized;
    final l$lastFetchedAt = lastFetchedAt;
    _resultData['lastFetchedAt'] =
        l$lastFetchedAt == null ? null : longStringToJson(l$lastFetchedAt);
    final l$lastReadChapter = lastReadChapter;
    _resultData['lastReadChapter'] = l$lastReadChapter?.toJson();
    final l$latestFetchedChapter = latestFetchedChapter;
    _resultData['latestFetchedChapter'] = l$latestFetchedChapter?.toJson();
    final l$latestReadChapter = latestReadChapter;
    _resultData['latestReadChapter'] = l$latestReadChapter?.toJson();
    final l$latestUploadedChapter = latestUploadedChapter;
    _resultData['latestUploadedChapter'] = l$latestUploadedChapter?.toJson();
    final l$meta = meta;
    _resultData['meta'] = l$meta.map((e) => e.toJson()).toList();
    final l$realUrl = realUrl;
    _resultData['realUrl'] = l$realUrl;
    final l$source = source;
    _resultData['source'] = l$source?.toJson();
    final l$sourceId = sourceId;
    _resultData['sourceId'] = longStringToJson(l$sourceId);
    final l$status = status;
    _resultData['status'] = toJson$Enum$MangaStatus(l$status);
    final l$thumbnailUrl = thumbnailUrl;
    _resultData['thumbnailUrl'] = l$thumbnailUrl;
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    _resultData['thumbnailUrlLastFetched'] = l$thumbnailUrlLastFetched == null
        ? null
        : longStringToJson(l$thumbnailUrlLastFetched);
    final l$title = title;
    _resultData['title'] = l$title;
    final l$unreadCount = unreadCount;
    _resultData['unreadCount'] = l$unreadCount;
    final l$updateStrategy = updateStrategy;
    _resultData['updateStrategy'] =
        toJson$Enum$UpdateStrategy(l$updateStrategy);
    final l$url = url;
    _resultData['url'] = l$url;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$age = age;
    final l$artist = artist;
    final l$author = author;
    final l$chaptersAge = chaptersAge;
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final l$description = description;
    final l$downloadCount = downloadCount;
    final l$genre = genre;
    final l$id = id;
    final l$inLibrary = inLibrary;
    final l$inLibraryAt = inLibraryAt;
    final l$initialized = initialized;
    final l$lastFetchedAt = lastFetchedAt;
    final l$lastReadChapter = lastReadChapter;
    final l$latestFetchedChapter = latestFetchedChapter;
    final l$latestReadChapter = latestReadChapter;
    final l$latestUploadedChapter = latestUploadedChapter;
    final l$meta = meta;
    final l$realUrl = realUrl;
    final l$source = source;
    final l$sourceId = sourceId;
    final l$status = status;
    final l$thumbnailUrl = thumbnailUrl;
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    final l$title = title;
    final l$unreadCount = unreadCount;
    final l$updateStrategy = updateStrategy;
    final l$url = url;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$age,
      l$artist,
      l$author,
      l$chaptersAge,
      l$chaptersLastFetchedAt,
      l$description,
      l$downloadCount,
      Object.hashAll(l$genre.map((v) => v)),
      l$id,
      l$inLibrary,
      l$inLibraryAt,
      l$initialized,
      l$lastFetchedAt,
      l$lastReadChapter,
      l$latestFetchedChapter,
      l$latestReadChapter,
      l$latestUploadedChapter,
      Object.hashAll(l$meta.map((v) => v)),
      l$realUrl,
      l$source,
      l$sourceId,
      l$status,
      l$thumbnailUrl,
      l$thumbnailUrlLastFetched,
      l$title,
      l$unreadCount,
      l$updateStrategy,
      l$url,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$MangaDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$age = age;
    final lOther$age = other.age;
    if (l$age != lOther$age) {
      return false;
    }
    final l$artist = artist;
    final lOther$artist = other.artist;
    if (l$artist != lOther$artist) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (l$author != lOther$author) {
      return false;
    }
    final l$chaptersAge = chaptersAge;
    final lOther$chaptersAge = other.chaptersAge;
    if (l$chaptersAge != lOther$chaptersAge) {
      return false;
    }
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final lOther$chaptersLastFetchedAt = other.chaptersLastFetchedAt;
    if (l$chaptersLastFetchedAt != lOther$chaptersLastFetchedAt) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$downloadCount = downloadCount;
    final lOther$downloadCount = other.downloadCount;
    if (l$downloadCount != lOther$downloadCount) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (l$genre.length != lOther$genre.length) {
      return false;
    }
    for (int i = 0; i < l$genre.length; i++) {
      final l$genre$entry = l$genre[i];
      final lOther$genre$entry = lOther$genre[i];
      if (l$genre$entry != lOther$genre$entry) {
        return false;
      }
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    final l$inLibraryAt = inLibraryAt;
    final lOther$inLibraryAt = other.inLibraryAt;
    if (l$inLibraryAt != lOther$inLibraryAt) {
      return false;
    }
    final l$initialized = initialized;
    final lOther$initialized = other.initialized;
    if (l$initialized != lOther$initialized) {
      return false;
    }
    final l$lastFetchedAt = lastFetchedAt;
    final lOther$lastFetchedAt = other.lastFetchedAt;
    if (l$lastFetchedAt != lOther$lastFetchedAt) {
      return false;
    }
    final l$lastReadChapter = lastReadChapter;
    final lOther$lastReadChapter = other.lastReadChapter;
    if (l$lastReadChapter != lOther$lastReadChapter) {
      return false;
    }
    final l$latestFetchedChapter = latestFetchedChapter;
    final lOther$latestFetchedChapter = other.latestFetchedChapter;
    if (l$latestFetchedChapter != lOther$latestFetchedChapter) {
      return false;
    }
    final l$latestReadChapter = latestReadChapter;
    final lOther$latestReadChapter = other.latestReadChapter;
    if (l$latestReadChapter != lOther$latestReadChapter) {
      return false;
    }
    final l$latestUploadedChapter = latestUploadedChapter;
    final lOther$latestUploadedChapter = other.latestUploadedChapter;
    if (l$latestUploadedChapter != lOther$latestUploadedChapter) {
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
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$thumbnailUrl = thumbnailUrl;
    final lOther$thumbnailUrl = other.thumbnailUrl;
    if (l$thumbnailUrl != lOther$thumbnailUrl) {
      return false;
    }
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    final lOther$thumbnailUrlLastFetched = other.thumbnailUrlLastFetched;
    if (l$thumbnailUrlLastFetched != lOther$thumbnailUrlLastFetched) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$unreadCount = unreadCount;
    final lOther$unreadCount = other.unreadCount;
    if (l$unreadCount != lOther$unreadCount) {
      return false;
    }
    final l$updateStrategy = updateStrategy;
    final lOther$updateStrategy = other.updateStrategy;
    if (l$updateStrategy != lOther$updateStrategy) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
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

extension UtilityExtension$Fragment$MangaDto on Fragment$MangaDto {
  CopyWith$Fragment$MangaDto<Fragment$MangaDto> get copyWith =>
      CopyWith$Fragment$MangaDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MangaDto<TRes> {
  factory CopyWith$Fragment$MangaDto(
    Fragment$MangaDto instance,
    TRes Function(Fragment$MangaDto) then,
  ) = _CopyWithImpl$Fragment$MangaDto;

  factory CopyWith$Fragment$MangaDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaDto;

  TRes call({
    String? age,
    String? artist,
    String? author,
    String? chaptersAge,
    String? chaptersLastFetchedAt,
    String? description,
    int? downloadCount,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    Fragment$ChapterDto? lastReadChapter,
    Fragment$ChapterDto? latestFetchedChapter,
    Fragment$ChapterDto? latestReadChapter,
    Fragment$ChapterDto? latestUploadedChapter,
    List<Fragment$MangaDto$meta>? meta,
    String? realUrl,
    Fragment$SourceDto? source,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? thumbnailUrlLastFetched,
    String? title,
    int? unreadCount,
    Enum$UpdateStrategy? updateStrategy,
    String? url,
    String? $__typename,
  });
  CopyWith$Fragment$ChapterDto<TRes> get lastReadChapter;
  CopyWith$Fragment$ChapterDto<TRes> get latestFetchedChapter;
  CopyWith$Fragment$ChapterDto<TRes> get latestReadChapter;
  CopyWith$Fragment$ChapterDto<TRes> get latestUploadedChapter;
  TRes meta(
      Iterable<Fragment$MangaDto$meta> Function(
              Iterable<CopyWith$Fragment$MangaDto$meta<Fragment$MangaDto$meta>>)
          _fn);
  CopyWith$Fragment$SourceDto<TRes> get source;
}

class _CopyWithImpl$Fragment$MangaDto<TRes>
    implements CopyWith$Fragment$MangaDto<TRes> {
  _CopyWithImpl$Fragment$MangaDto(
    this._instance,
    this._then,
  );

  final Fragment$MangaDto _instance;

  final TRes Function(Fragment$MangaDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? age = _undefined,
    Object? artist = _undefined,
    Object? author = _undefined,
    Object? chaptersAge = _undefined,
    Object? chaptersLastFetchedAt = _undefined,
    Object? description = _undefined,
    Object? downloadCount = _undefined,
    Object? genre = _undefined,
    Object? id = _undefined,
    Object? inLibrary = _undefined,
    Object? inLibraryAt = _undefined,
    Object? initialized = _undefined,
    Object? lastFetchedAt = _undefined,
    Object? lastReadChapter = _undefined,
    Object? latestFetchedChapter = _undefined,
    Object? latestReadChapter = _undefined,
    Object? latestUploadedChapter = _undefined,
    Object? meta = _undefined,
    Object? realUrl = _undefined,
    Object? source = _undefined,
    Object? sourceId = _undefined,
    Object? status = _undefined,
    Object? thumbnailUrl = _undefined,
    Object? thumbnailUrlLastFetched = _undefined,
    Object? title = _undefined,
    Object? unreadCount = _undefined,
    Object? updateStrategy = _undefined,
    Object? url = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaDto(
        age: age == _undefined ? _instance.age : (age as String?),
        artist: artist == _undefined ? _instance.artist : (artist as String?),
        author: author == _undefined ? _instance.author : (author as String?),
        chaptersAge: chaptersAge == _undefined
            ? _instance.chaptersAge
            : (chaptersAge as String?),
        chaptersLastFetchedAt: chaptersLastFetchedAt == _undefined
            ? _instance.chaptersLastFetchedAt
            : (chaptersLastFetchedAt as String?),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        downloadCount: downloadCount == _undefined || downloadCount == null
            ? _instance.downloadCount
            : (downloadCount as int),
        genre: genre == _undefined || genre == null
            ? _instance.genre
            : (genre as List<String>),
        id: id == _undefined || id == null ? _instance.id : (id as int),
        inLibrary: inLibrary == _undefined || inLibrary == null
            ? _instance.inLibrary
            : (inLibrary as bool),
        inLibraryAt: inLibraryAt == _undefined || inLibraryAt == null
            ? _instance.inLibraryAt
            : (inLibraryAt as String),
        initialized: initialized == _undefined || initialized == null
            ? _instance.initialized
            : (initialized as bool),
        lastFetchedAt: lastFetchedAt == _undefined
            ? _instance.lastFetchedAt
            : (lastFetchedAt as String?),
        lastReadChapter: lastReadChapter == _undefined
            ? _instance.lastReadChapter
            : (lastReadChapter as Fragment$ChapterDto?),
        latestFetchedChapter: latestFetchedChapter == _undefined
            ? _instance.latestFetchedChapter
            : (latestFetchedChapter as Fragment$ChapterDto?),
        latestReadChapter: latestReadChapter == _undefined
            ? _instance.latestReadChapter
            : (latestReadChapter as Fragment$ChapterDto?),
        latestUploadedChapter: latestUploadedChapter == _undefined
            ? _instance.latestUploadedChapter
            : (latestUploadedChapter as Fragment$ChapterDto?),
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as List<Fragment$MangaDto$meta>),
        realUrl:
            realUrl == _undefined ? _instance.realUrl : (realUrl as String?),
        source: source == _undefined
            ? _instance.source
            : (source as Fragment$SourceDto?),
        sourceId: sourceId == _undefined || sourceId == null
            ? _instance.sourceId
            : (sourceId as String),
        status: status == _undefined || status == null
            ? _instance.status
            : (status as Enum$MangaStatus),
        thumbnailUrl: thumbnailUrl == _undefined
            ? _instance.thumbnailUrl
            : (thumbnailUrl as String?),
        thumbnailUrlLastFetched: thumbnailUrlLastFetched == _undefined
            ? _instance.thumbnailUrlLastFetched
            : (thumbnailUrlLastFetched as String?),
        title: title == _undefined || title == null
            ? _instance.title
            : (title as String),
        unreadCount: unreadCount == _undefined || unreadCount == null
            ? _instance.unreadCount
            : (unreadCount as int),
        updateStrategy: updateStrategy == _undefined || updateStrategy == null
            ? _instance.updateStrategy
            : (updateStrategy as Enum$UpdateStrategy),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$ChapterDto<TRes> get lastReadChapter {
    final local$lastReadChapter = _instance.lastReadChapter;
    return local$lastReadChapter == null
        ? CopyWith$Fragment$ChapterDto.stub(_then(_instance))
        : CopyWith$Fragment$ChapterDto(
            local$lastReadChapter, (e) => call(lastReadChapter: e));
  }

  CopyWith$Fragment$ChapterDto<TRes> get latestFetchedChapter {
    final local$latestFetchedChapter = _instance.latestFetchedChapter;
    return local$latestFetchedChapter == null
        ? CopyWith$Fragment$ChapterDto.stub(_then(_instance))
        : CopyWith$Fragment$ChapterDto(
            local$latestFetchedChapter, (e) => call(latestFetchedChapter: e));
  }

  CopyWith$Fragment$ChapterDto<TRes> get latestReadChapter {
    final local$latestReadChapter = _instance.latestReadChapter;
    return local$latestReadChapter == null
        ? CopyWith$Fragment$ChapterDto.stub(_then(_instance))
        : CopyWith$Fragment$ChapterDto(
            local$latestReadChapter, (e) => call(latestReadChapter: e));
  }

  CopyWith$Fragment$ChapterDto<TRes> get latestUploadedChapter {
    final local$latestUploadedChapter = _instance.latestUploadedChapter;
    return local$latestUploadedChapter == null
        ? CopyWith$Fragment$ChapterDto.stub(_then(_instance))
        : CopyWith$Fragment$ChapterDto(
            local$latestUploadedChapter, (e) => call(latestUploadedChapter: e));
  }

  TRes meta(
          Iterable<Fragment$MangaDto$meta> Function(
                  Iterable<
                      CopyWith$Fragment$MangaDto$meta<Fragment$MangaDto$meta>>)
              _fn) =>
      call(
          meta: _fn(_instance.meta.map((e) => CopyWith$Fragment$MangaDto$meta(
                e,
                (i) => i,
              ))).toList());

  CopyWith$Fragment$SourceDto<TRes> get source {
    final local$source = _instance.source;
    return local$source == null
        ? CopyWith$Fragment$SourceDto.stub(_then(_instance))
        : CopyWith$Fragment$SourceDto(local$source, (e) => call(source: e));
  }
}

class _CopyWithStubImpl$Fragment$MangaDto<TRes>
    implements CopyWith$Fragment$MangaDto<TRes> {
  _CopyWithStubImpl$Fragment$MangaDto(this._res);

  TRes _res;

  call({
    String? age,
    String? artist,
    String? author,
    String? chaptersAge,
    String? chaptersLastFetchedAt,
    String? description,
    int? downloadCount,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    Fragment$ChapterDto? lastReadChapter,
    Fragment$ChapterDto? latestFetchedChapter,
    Fragment$ChapterDto? latestReadChapter,
    Fragment$ChapterDto? latestUploadedChapter,
    List<Fragment$MangaDto$meta>? meta,
    String? realUrl,
    Fragment$SourceDto? source,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? thumbnailUrlLastFetched,
    String? title,
    int? unreadCount,
    Enum$UpdateStrategy? updateStrategy,
    String? url,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$ChapterDto<TRes> get lastReadChapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);

  CopyWith$Fragment$ChapterDto<TRes> get latestFetchedChapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);

  CopyWith$Fragment$ChapterDto<TRes> get latestReadChapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);

  CopyWith$Fragment$ChapterDto<TRes> get latestUploadedChapter =>
      CopyWith$Fragment$ChapterDto.stub(_res);

  meta(_fn) => _res;

  CopyWith$Fragment$SourceDto<TRes> get source =>
      CopyWith$Fragment$SourceDto.stub(_res);
}

const fragmentDefinitionMangaDto = FragmentDefinitionNode(
  name: NameNode(value: 'MangaDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'MangaType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'age'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'artist'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'author'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'chaptersAge'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'chaptersLastFetchedAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'description'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'downloadCount'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'genre'),
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
      name: NameNode(value: 'inLibrary'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'inLibraryAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'initialized'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lastFetchedAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lastReadChapter'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'ChapterDto'),
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
      name: NameNode(value: 'latestFetchedChapter'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'ChapterDto'),
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
      name: NameNode(value: 'latestReadChapter'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'ChapterDto'),
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
      name: NameNode(value: 'latestUploadedChapter'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'ChapterDto'),
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
      name: NameNode(value: 'realUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'source'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'SourceDto'),
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
      name: NameNode(value: 'sourceId'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'status'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'thumbnailUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'thumbnailUrlLastFetched'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'title'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'unreadCount'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'updateStrategy'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'url'),
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
const documentNodeFragmentMangaDto = DocumentNode(definitions: [
  fragmentDefinitionMangaDto,
  fragmentDefinitionChapterDto,
  fragmentDefinitionSourceDto,
]);

extension ClientExtension$Fragment$MangaDto on graphql.GraphQLClient {
  void writeFragment$MangaDto({
    required Fragment$MangaDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'MangaDto',
            document: documentNodeFragmentMangaDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$MangaDto? readFragment$MangaDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'MangaDto',
          document: documentNodeFragmentMangaDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$MangaDto.fromJson(result);
  }
}

class Fragment$MangaDto$meta {
  Fragment$MangaDto$meta({
    required this.key,
    required this.value,
    this.$__typename = 'MangaMetaType',
  });

  factory Fragment$MangaDto$meta.fromJson(Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaDto$meta(
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
    if (other is! Fragment$MangaDto$meta || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$MangaDto$meta on Fragment$MangaDto$meta {
  CopyWith$Fragment$MangaDto$meta<Fragment$MangaDto$meta> get copyWith =>
      CopyWith$Fragment$MangaDto$meta(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MangaDto$meta<TRes> {
  factory CopyWith$Fragment$MangaDto$meta(
    Fragment$MangaDto$meta instance,
    TRes Function(Fragment$MangaDto$meta) then,
  ) = _CopyWithImpl$Fragment$MangaDto$meta;

  factory CopyWith$Fragment$MangaDto$meta.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaDto$meta;

  TRes call({
    String? key,
    String? value,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$MangaDto$meta<TRes>
    implements CopyWith$Fragment$MangaDto$meta<TRes> {
  _CopyWithImpl$Fragment$MangaDto$meta(
    this._instance,
    this._then,
  );

  final Fragment$MangaDto$meta _instance;

  final TRes Function(Fragment$MangaDto$meta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaDto$meta(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$MangaDto$meta<TRes>
    implements CopyWith$Fragment$MangaDto$meta<TRes> {
  _CopyWithStubImpl$Fragment$MangaDto$meta(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$MangaMetaDto {
  Fragment$MangaMetaDto({
    required this.key,
    required this.value,
    required this.mangaId,
    this.$__typename = 'MangaMetaType',
  });

  factory Fragment$MangaMetaDto.fromJson(Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$mangaId = json['mangaId'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaMetaDto(
      key: (l$key as String),
      value: (l$value as String),
      mangaId: (l$mangaId as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String key;

  final String value;

  final int mangaId;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$key = key;
    _resultData['key'] = l$key;
    final l$value = value;
    _resultData['value'] = l$value;
    final l$mangaId = mangaId;
    _resultData['mangaId'] = l$mangaId;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$key = key;
    final l$value = value;
    final l$mangaId = mangaId;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$key,
      l$value,
      l$mangaId,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$MangaMetaDto || runtimeType != other.runtimeType) {
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
    final l$mangaId = mangaId;
    final lOther$mangaId = other.mangaId;
    if (l$mangaId != lOther$mangaId) {
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

extension UtilityExtension$Fragment$MangaMetaDto on Fragment$MangaMetaDto {
  CopyWith$Fragment$MangaMetaDto<Fragment$MangaMetaDto> get copyWith =>
      CopyWith$Fragment$MangaMetaDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MangaMetaDto<TRes> {
  factory CopyWith$Fragment$MangaMetaDto(
    Fragment$MangaMetaDto instance,
    TRes Function(Fragment$MangaMetaDto) then,
  ) = _CopyWithImpl$Fragment$MangaMetaDto;

  factory CopyWith$Fragment$MangaMetaDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaMetaDto;

  TRes call({
    String? key,
    String? value,
    int? mangaId,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$MangaMetaDto<TRes>
    implements CopyWith$Fragment$MangaMetaDto<TRes> {
  _CopyWithImpl$Fragment$MangaMetaDto(
    this._instance,
    this._then,
  );

  final Fragment$MangaMetaDto _instance;

  final TRes Function(Fragment$MangaMetaDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? mangaId = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaMetaDto(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        mangaId: mangaId == _undefined || mangaId == null
            ? _instance.mangaId
            : (mangaId as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$MangaMetaDto<TRes>
    implements CopyWith$Fragment$MangaMetaDto<TRes> {
  _CopyWithStubImpl$Fragment$MangaMetaDto(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    int? mangaId,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionMangaMetaDto = FragmentDefinitionNode(
  name: NameNode(value: 'MangaMetaDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'MangaMetaType'),
    isNonNull: false,
  )),
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
      name: NameNode(value: 'mangaId'),
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
const documentNodeFragmentMangaMetaDto = DocumentNode(definitions: [
  fragmentDefinitionMangaMetaDto,
]);

extension ClientExtension$Fragment$MangaMetaDto on graphql.GraphQLClient {
  void writeFragment$MangaMetaDto({
    required Fragment$MangaMetaDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'MangaMetaDto',
            document: documentNodeFragmentMangaMetaDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$MangaMetaDto? readFragment$MangaMetaDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'MangaMetaDto',
          document: documentNodeFragmentMangaMetaDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$MangaMetaDto.fromJson(result);
  }
}

class Fragment$MangaBaseDto {
  Fragment$MangaBaseDto({
    this.age,
    this.artist,
    this.author,
    this.chaptersLastFetchedAt,
    this.description,
    required this.genre,
    required this.id,
    required this.inLibrary,
    required this.inLibraryAt,
    required this.initialized,
    this.lastFetchedAt,
    required this.meta,
    this.realUrl,
    required this.sourceId,
    required this.status,
    this.thumbnailUrl,
    this.thumbnailUrlLastFetched,
    required this.title,
    required this.unreadCount,
    required this.updateStrategy,
    required this.url,
    this.$__typename = 'MangaType',
  });

  factory Fragment$MangaBaseDto.fromJson(Map<String, dynamic> json) {
    final l$age = json['age'];
    final l$artist = json['artist'];
    final l$author = json['author'];
    final l$chaptersLastFetchedAt = json['chaptersLastFetchedAt'];
    final l$description = json['description'];
    final l$genre = json['genre'];
    final l$id = json['id'];
    final l$inLibrary = json['inLibrary'];
    final l$inLibraryAt = json['inLibraryAt'];
    final l$initialized = json['initialized'];
    final l$lastFetchedAt = json['lastFetchedAt'];
    final l$meta = json['meta'];
    final l$realUrl = json['realUrl'];
    final l$sourceId = json['sourceId'];
    final l$status = json['status'];
    final l$thumbnailUrl = json['thumbnailUrl'];
    final l$thumbnailUrlLastFetched = json['thumbnailUrlLastFetched'];
    final l$title = json['title'];
    final l$unreadCount = json['unreadCount'];
    final l$updateStrategy = json['updateStrategy'];
    final l$url = json['url'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaBaseDto(
      age: l$age == null ? null : longStringFromJson(l$age),
      artist: (l$artist as String?),
      author: (l$author as String?),
      chaptersLastFetchedAt: l$chaptersLastFetchedAt == null
          ? null
          : longStringFromJson(l$chaptersLastFetchedAt),
      description: (l$description as String?),
      genre: (l$genre as List<dynamic>).map((e) => (e as String)).toList(),
      id: (l$id as int),
      inLibrary: (l$inLibrary as bool),
      inLibraryAt: longStringFromJson(l$inLibraryAt),
      initialized: (l$initialized as bool),
      lastFetchedAt:
          l$lastFetchedAt == null ? null : longStringFromJson(l$lastFetchedAt),
      meta: (l$meta as List<dynamic>)
          .map((e) =>
              Fragment$MangaBaseDto$meta.fromJson((e as Map<String, dynamic>)))
          .toList(),
      realUrl: (l$realUrl as String?),
      sourceId: longStringFromJson(l$sourceId),
      status: fromJson$Enum$MangaStatus((l$status as String)),
      thumbnailUrl: (l$thumbnailUrl as String?),
      thumbnailUrlLastFetched: l$thumbnailUrlLastFetched == null
          ? null
          : longStringFromJson(l$thumbnailUrlLastFetched),
      title: (l$title as String),
      unreadCount: (l$unreadCount as int),
      updateStrategy:
          fromJson$Enum$UpdateStrategy((l$updateStrategy as String)),
      url: (l$url as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String? age;

  final String? artist;

  final String? author;

  final String? chaptersLastFetchedAt;

  final String? description;

  final List<String> genre;

  final int id;

  final bool inLibrary;

  final String inLibraryAt;

  final bool initialized;

  final String? lastFetchedAt;

  final List<Fragment$MangaBaseDto$meta> meta;

  final String? realUrl;

  final String sourceId;

  final Enum$MangaStatus status;

  final String? thumbnailUrl;

  final String? thumbnailUrlLastFetched;

  final String title;

  final int unreadCount;

  final Enum$UpdateStrategy updateStrategy;

  final String url;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$age = age;
    _resultData['age'] = l$age == null ? null : longStringToJson(l$age);
    final l$artist = artist;
    _resultData['artist'] = l$artist;
    final l$author = author;
    _resultData['author'] = l$author;
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    _resultData['chaptersLastFetchedAt'] = l$chaptersLastFetchedAt == null
        ? null
        : longStringToJson(l$chaptersLastFetchedAt);
    final l$description = description;
    _resultData['description'] = l$description;
    final l$genre = genre;
    _resultData['genre'] = l$genre.map((e) => e).toList();
    final l$id = id;
    _resultData['id'] = l$id;
    final l$inLibrary = inLibrary;
    _resultData['inLibrary'] = l$inLibrary;
    final l$inLibraryAt = inLibraryAt;
    _resultData['inLibraryAt'] = longStringToJson(l$inLibraryAt);
    final l$initialized = initialized;
    _resultData['initialized'] = l$initialized;
    final l$lastFetchedAt = lastFetchedAt;
    _resultData['lastFetchedAt'] =
        l$lastFetchedAt == null ? null : longStringToJson(l$lastFetchedAt);
    final l$meta = meta;
    _resultData['meta'] = l$meta.map((e) => e.toJson()).toList();
    final l$realUrl = realUrl;
    _resultData['realUrl'] = l$realUrl;
    final l$sourceId = sourceId;
    _resultData['sourceId'] = longStringToJson(l$sourceId);
    final l$status = status;
    _resultData['status'] = toJson$Enum$MangaStatus(l$status);
    final l$thumbnailUrl = thumbnailUrl;
    _resultData['thumbnailUrl'] = l$thumbnailUrl;
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    _resultData['thumbnailUrlLastFetched'] = l$thumbnailUrlLastFetched == null
        ? null
        : longStringToJson(l$thumbnailUrlLastFetched);
    final l$title = title;
    _resultData['title'] = l$title;
    final l$unreadCount = unreadCount;
    _resultData['unreadCount'] = l$unreadCount;
    final l$updateStrategy = updateStrategy;
    _resultData['updateStrategy'] =
        toJson$Enum$UpdateStrategy(l$updateStrategy);
    final l$url = url;
    _resultData['url'] = l$url;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$age = age;
    final l$artist = artist;
    final l$author = author;
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final l$description = description;
    final l$genre = genre;
    final l$id = id;
    final l$inLibrary = inLibrary;
    final l$inLibraryAt = inLibraryAt;
    final l$initialized = initialized;
    final l$lastFetchedAt = lastFetchedAt;
    final l$meta = meta;
    final l$realUrl = realUrl;
    final l$sourceId = sourceId;
    final l$status = status;
    final l$thumbnailUrl = thumbnailUrl;
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    final l$title = title;
    final l$unreadCount = unreadCount;
    final l$updateStrategy = updateStrategy;
    final l$url = url;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$age,
      l$artist,
      l$author,
      l$chaptersLastFetchedAt,
      l$description,
      Object.hashAll(l$genre.map((v) => v)),
      l$id,
      l$inLibrary,
      l$inLibraryAt,
      l$initialized,
      l$lastFetchedAt,
      Object.hashAll(l$meta.map((v) => v)),
      l$realUrl,
      l$sourceId,
      l$status,
      l$thumbnailUrl,
      l$thumbnailUrlLastFetched,
      l$title,
      l$unreadCount,
      l$updateStrategy,
      l$url,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$MangaBaseDto || runtimeType != other.runtimeType) {
      return false;
    }
    final l$age = age;
    final lOther$age = other.age;
    if (l$age != lOther$age) {
      return false;
    }
    final l$artist = artist;
    final lOther$artist = other.artist;
    if (l$artist != lOther$artist) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (l$author != lOther$author) {
      return false;
    }
    final l$chaptersLastFetchedAt = chaptersLastFetchedAt;
    final lOther$chaptersLastFetchedAt = other.chaptersLastFetchedAt;
    if (l$chaptersLastFetchedAt != lOther$chaptersLastFetchedAt) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (l$genre.length != lOther$genre.length) {
      return false;
    }
    for (int i = 0; i < l$genre.length; i++) {
      final l$genre$entry = l$genre[i];
      final lOther$genre$entry = lOther$genre[i];
      if (l$genre$entry != lOther$genre$entry) {
        return false;
      }
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$inLibrary = inLibrary;
    final lOther$inLibrary = other.inLibrary;
    if (l$inLibrary != lOther$inLibrary) {
      return false;
    }
    final l$inLibraryAt = inLibraryAt;
    final lOther$inLibraryAt = other.inLibraryAt;
    if (l$inLibraryAt != lOther$inLibraryAt) {
      return false;
    }
    final l$initialized = initialized;
    final lOther$initialized = other.initialized;
    if (l$initialized != lOther$initialized) {
      return false;
    }
    final l$lastFetchedAt = lastFetchedAt;
    final lOther$lastFetchedAt = other.lastFetchedAt;
    if (l$lastFetchedAt != lOther$lastFetchedAt) {
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
    final l$realUrl = realUrl;
    final lOther$realUrl = other.realUrl;
    if (l$realUrl != lOther$realUrl) {
      return false;
    }
    final l$sourceId = sourceId;
    final lOther$sourceId = other.sourceId;
    if (l$sourceId != lOther$sourceId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$thumbnailUrl = thumbnailUrl;
    final lOther$thumbnailUrl = other.thumbnailUrl;
    if (l$thumbnailUrl != lOther$thumbnailUrl) {
      return false;
    }
    final l$thumbnailUrlLastFetched = thumbnailUrlLastFetched;
    final lOther$thumbnailUrlLastFetched = other.thumbnailUrlLastFetched;
    if (l$thumbnailUrlLastFetched != lOther$thumbnailUrlLastFetched) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$unreadCount = unreadCount;
    final lOther$unreadCount = other.unreadCount;
    if (l$unreadCount != lOther$unreadCount) {
      return false;
    }
    final l$updateStrategy = updateStrategy;
    final lOther$updateStrategy = other.updateStrategy;
    if (l$updateStrategy != lOther$updateStrategy) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
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

extension UtilityExtension$Fragment$MangaBaseDto on Fragment$MangaBaseDto {
  CopyWith$Fragment$MangaBaseDto<Fragment$MangaBaseDto> get copyWith =>
      CopyWith$Fragment$MangaBaseDto(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$MangaBaseDto<TRes> {
  factory CopyWith$Fragment$MangaBaseDto(
    Fragment$MangaBaseDto instance,
    TRes Function(Fragment$MangaBaseDto) then,
  ) = _CopyWithImpl$Fragment$MangaBaseDto;

  factory CopyWith$Fragment$MangaBaseDto.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaBaseDto;

  TRes call({
    String? age,
    String? artist,
    String? author,
    String? chaptersLastFetchedAt,
    String? description,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    List<Fragment$MangaBaseDto$meta>? meta,
    String? realUrl,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? thumbnailUrlLastFetched,
    String? title,
    int? unreadCount,
    Enum$UpdateStrategy? updateStrategy,
    String? url,
    String? $__typename,
  });
  TRes meta(
      Iterable<Fragment$MangaBaseDto$meta> Function(
              Iterable<
                  CopyWith$Fragment$MangaBaseDto$meta<
                      Fragment$MangaBaseDto$meta>>)
          _fn);
}

class _CopyWithImpl$Fragment$MangaBaseDto<TRes>
    implements CopyWith$Fragment$MangaBaseDto<TRes> {
  _CopyWithImpl$Fragment$MangaBaseDto(
    this._instance,
    this._then,
  );

  final Fragment$MangaBaseDto _instance;

  final TRes Function(Fragment$MangaBaseDto) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? age = _undefined,
    Object? artist = _undefined,
    Object? author = _undefined,
    Object? chaptersLastFetchedAt = _undefined,
    Object? description = _undefined,
    Object? genre = _undefined,
    Object? id = _undefined,
    Object? inLibrary = _undefined,
    Object? inLibraryAt = _undefined,
    Object? initialized = _undefined,
    Object? lastFetchedAt = _undefined,
    Object? meta = _undefined,
    Object? realUrl = _undefined,
    Object? sourceId = _undefined,
    Object? status = _undefined,
    Object? thumbnailUrl = _undefined,
    Object? thumbnailUrlLastFetched = _undefined,
    Object? title = _undefined,
    Object? unreadCount = _undefined,
    Object? updateStrategy = _undefined,
    Object? url = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaBaseDto(
        age: age == _undefined ? _instance.age : (age as String?),
        artist: artist == _undefined ? _instance.artist : (artist as String?),
        author: author == _undefined ? _instance.author : (author as String?),
        chaptersLastFetchedAt: chaptersLastFetchedAt == _undefined
            ? _instance.chaptersLastFetchedAt
            : (chaptersLastFetchedAt as String?),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        genre: genre == _undefined || genre == null
            ? _instance.genre
            : (genre as List<String>),
        id: id == _undefined || id == null ? _instance.id : (id as int),
        inLibrary: inLibrary == _undefined || inLibrary == null
            ? _instance.inLibrary
            : (inLibrary as bool),
        inLibraryAt: inLibraryAt == _undefined || inLibraryAt == null
            ? _instance.inLibraryAt
            : (inLibraryAt as String),
        initialized: initialized == _undefined || initialized == null
            ? _instance.initialized
            : (initialized as bool),
        lastFetchedAt: lastFetchedAt == _undefined
            ? _instance.lastFetchedAt
            : (lastFetchedAt as String?),
        meta: meta == _undefined || meta == null
            ? _instance.meta
            : (meta as List<Fragment$MangaBaseDto$meta>),
        realUrl:
            realUrl == _undefined ? _instance.realUrl : (realUrl as String?),
        sourceId: sourceId == _undefined || sourceId == null
            ? _instance.sourceId
            : (sourceId as String),
        status: status == _undefined || status == null
            ? _instance.status
            : (status as Enum$MangaStatus),
        thumbnailUrl: thumbnailUrl == _undefined
            ? _instance.thumbnailUrl
            : (thumbnailUrl as String?),
        thumbnailUrlLastFetched: thumbnailUrlLastFetched == _undefined
            ? _instance.thumbnailUrlLastFetched
            : (thumbnailUrlLastFetched as String?),
        title: title == _undefined || title == null
            ? _instance.title
            : (title as String),
        unreadCount: unreadCount == _undefined || unreadCount == null
            ? _instance.unreadCount
            : (unreadCount as int),
        updateStrategy: updateStrategy == _undefined || updateStrategy == null
            ? _instance.updateStrategy
            : (updateStrategy as Enum$UpdateStrategy),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes meta(
          Iterable<Fragment$MangaBaseDto$meta> Function(
                  Iterable<
                      CopyWith$Fragment$MangaBaseDto$meta<
                          Fragment$MangaBaseDto$meta>>)
              _fn) =>
      call(
          meta:
              _fn(_instance.meta.map((e) => CopyWith$Fragment$MangaBaseDto$meta(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Fragment$MangaBaseDto<TRes>
    implements CopyWith$Fragment$MangaBaseDto<TRes> {
  _CopyWithStubImpl$Fragment$MangaBaseDto(this._res);

  TRes _res;

  call({
    String? age,
    String? artist,
    String? author,
    String? chaptersLastFetchedAt,
    String? description,
    List<String>? genre,
    int? id,
    bool? inLibrary,
    String? inLibraryAt,
    bool? initialized,
    String? lastFetchedAt,
    List<Fragment$MangaBaseDto$meta>? meta,
    String? realUrl,
    String? sourceId,
    Enum$MangaStatus? status,
    String? thumbnailUrl,
    String? thumbnailUrlLastFetched,
    String? title,
    int? unreadCount,
    Enum$UpdateStrategy? updateStrategy,
    String? url,
    String? $__typename,
  }) =>
      _res;

  meta(_fn) => _res;
}

const fragmentDefinitionMangaBaseDto = FragmentDefinitionNode(
  name: NameNode(value: 'MangaBaseDto'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'MangaType'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'age'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'artist'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'author'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'chaptersLastFetchedAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'description'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'genre'),
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
      name: NameNode(value: 'inLibrary'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'inLibraryAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'initialized'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'lastFetchedAt'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
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
      name: NameNode(value: 'realUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'sourceId'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'status'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'thumbnailUrl'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'thumbnailUrlLastFetched'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'title'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'unreadCount'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'updateStrategy'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'url'),
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
const documentNodeFragmentMangaBaseDto = DocumentNode(definitions: [
  fragmentDefinitionMangaBaseDto,
]);

extension ClientExtension$Fragment$MangaBaseDto on graphql.GraphQLClient {
  void writeFragment$MangaBaseDto({
    required Fragment$MangaBaseDto data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'MangaBaseDto',
            document: documentNodeFragmentMangaBaseDto,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );

  Fragment$MangaBaseDto? readFragment$MangaBaseDto({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'MangaBaseDto',
          document: documentNodeFragmentMangaBaseDto,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$MangaBaseDto.fromJson(result);
  }
}

class Fragment$MangaBaseDto$meta {
  Fragment$MangaBaseDto$meta({
    required this.key,
    required this.value,
    this.$__typename = 'MangaMetaType',
  });

  factory Fragment$MangaBaseDto$meta.fromJson(Map<String, dynamic> json) {
    final l$key = json['key'];
    final l$value = json['value'];
    final l$$__typename = json['__typename'];
    return Fragment$MangaBaseDto$meta(
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
    if (other is! Fragment$MangaBaseDto$meta ||
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

extension UtilityExtension$Fragment$MangaBaseDto$meta
    on Fragment$MangaBaseDto$meta {
  CopyWith$Fragment$MangaBaseDto$meta<Fragment$MangaBaseDto$meta>
      get copyWith => CopyWith$Fragment$MangaBaseDto$meta(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$MangaBaseDto$meta<TRes> {
  factory CopyWith$Fragment$MangaBaseDto$meta(
    Fragment$MangaBaseDto$meta instance,
    TRes Function(Fragment$MangaBaseDto$meta) then,
  ) = _CopyWithImpl$Fragment$MangaBaseDto$meta;

  factory CopyWith$Fragment$MangaBaseDto$meta.stub(TRes res) =
      _CopyWithStubImpl$Fragment$MangaBaseDto$meta;

  TRes call({
    String? key,
    String? value,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$MangaBaseDto$meta<TRes>
    implements CopyWith$Fragment$MangaBaseDto$meta<TRes> {
  _CopyWithImpl$Fragment$MangaBaseDto$meta(
    this._instance,
    this._then,
  );

  final Fragment$MangaBaseDto$meta _instance;

  final TRes Function(Fragment$MangaBaseDto$meta) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? key = _undefined,
    Object? value = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$MangaBaseDto$meta(
        key: key == _undefined || key == null ? _instance.key : (key as String),
        value: value == _undefined || value == null
            ? _instance.value
            : (value as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$MangaBaseDto$meta<TRes>
    implements CopyWith$Fragment$MangaBaseDto$meta<TRes> {
  _CopyWithStubImpl$Fragment$MangaBaseDto$meta(this._res);

  TRes _res;

  call({
    String? key,
    String? value,
    String? $__typename,
  }) =>
      _res;
}
