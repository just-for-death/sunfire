// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MigrationSourceImpl _$$MigrationSourceImplFromJson(
        Map<String, dynamic> json) =>
    _$MigrationSourceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      lang: json['lang'] as String,
      isConfigured: json['isConfigured'] as bool? ?? false,
      mangaCount: (json['mangaCount'] as num?)?.toInt() ?? 0,
      displayName: json['displayName'] as String?,
      supportsLatest: json['supportsLatest'] as bool?,
    );

Map<String, dynamic> _$$MigrationSourceImplToJson(
        _$MigrationSourceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lang': instance.lang,
      'isConfigured': instance.isConfigured,
      'mangaCount': instance.mangaCount,
      'displayName': instance.displayName,
      'supportsLatest': instance.supportsLatest,
    };

_$MigrationOptionImpl _$$MigrationOptionImplFromJson(
        Map<String, dynamic> json) =>
    _$MigrationOptionImpl(
      migrateChapters: json['migrateChapters'] as bool? ?? true,
      migrateCategories: json['migrateCategories'] as bool? ?? true,
      migrateDownloads: json['migrateDownloads'] as bool? ?? false,
      migrateTracking: json['migrateTracking'] as bool? ?? false,
      deleteSource: json['deleteSource'] as bool? ?? true,
    );

Map<String, dynamic> _$$MigrationOptionImplToJson(
        _$MigrationOptionImpl instance) =>
    <String, dynamic>{
      'migrateChapters': instance.migrateChapters,
      'migrateCategories': instance.migrateCategories,
      'migrateDownloads': instance.migrateDownloads,
      'migrateTracking': instance.migrateTracking,
      'deleteSource': instance.deleteSource,
    };

_$MigrationResultImpl _$$MigrationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$MigrationResultImpl(
      success: json['success'] as bool,
      error: json['error'] as String?,
      migratedChapters: (json['migratedChapters'] as num?)?.toInt() ?? 0,
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      newManga: json['newManga'] == null
          ? null
          : Fragment$MangaDto.fromJson(
              json['newManga'] as Map<String, dynamic>),
      migratedCategories: (json['migratedCategories'] as num?)?.toInt() ?? 0,
      migratedDownloads: (json['migratedDownloads'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MigrationResultImplToJson(
        _$MigrationResultImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'error': instance.error,
      'migratedChapters': instance.migratedChapters,
      'warnings': instance.warnings,
      'newManga': instance.newManga?.toJson(),
      'migratedCategories': instance.migratedCategories,
      'migratedDownloads': instance.migratedDownloads,
    };

_$MigrationProgressImpl _$$MigrationProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$MigrationProgressImpl(
      currentStep: $enumDecode(_$MigrationStepEnumMap, json['currentStep']),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      status: $enumDecodeNullable(_$MigrationStatusEnumMap, json['status']) ??
          MigrationStatus.idle,
      errorMessage: json['errorMessage'] as String?,
      processedItems: (json['processedItems'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MigrationProgressImplToJson(
        _$MigrationProgressImpl instance) =>
    <String, dynamic>{
      'currentStep': _$MigrationStepEnumMap[instance.currentStep]!,
      'percentage': instance.percentage,
      'status': _$MigrationStatusEnumMap[instance.status]!,
      'errorMessage': instance.errorMessage,
      'processedItems': instance.processedItems,
      'totalItems': instance.totalItems,
    };

const _$MigrationStepEnumMap = {
  MigrationStep.preparingMigration: 'preparingMigration',
  MigrationStep.migrateChapters: 'migrateChapters',
  MigrationStep.migrateCategories: 'migrateCategories',
  MigrationStep.migrationInProgress: 'migrationInProgress',
  MigrationStep.migrationCompleted: 'migrationCompleted',
  MigrationStep.migrationFailed: 'migrationFailed',
  MigrationStep.migrationCancelled: 'migrationCancelled',
};

const _$MigrationStatusEnumMap = {
  MigrationStatus.idle: 'idle',
  MigrationStatus.preparing: 'preparing',
  MigrationStatus.migrating: 'migrating',
  MigrationStatus.completed: 'completed',
  MigrationStatus.error: 'error',
  MigrationStatus.cancelled: 'cancelled',
};

_$MangaSearchResultImpl _$$MangaSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$MangaSearchResultImpl(
      manga: Fragment$MangaDto.fromJson(json['manga'] as Map<String, dynamic>),
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      matchReason: json['matchReason'] as String?,
    );

Map<String, dynamic> _$$MangaSearchResultImplToJson(
        _$MangaSearchResultImpl instance) =>
    <String, dynamic>{
      'manga': instance.manga.toJson(),
      'similarity': instance.similarity,
      'matchReason': instance.matchReason,
    };
