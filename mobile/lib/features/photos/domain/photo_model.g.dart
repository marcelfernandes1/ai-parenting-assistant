// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
  id: json['id'] as String,
  url: json['url'] as String,
  s3Key: json['s3Key'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  milestoneId: json['milestoneId'] as String?,
  albumId: json['albumId'] as String?,
  analysisResults: json['analysisResults'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      's3Key': instance.s3Key,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'metadata': instance.metadata,
      'milestoneId': instance.milestoneId,
      'albumId': instance.albumId,
      'analysisResults': instance.analysisResults,
    };

_$PhotoListResponseImpl _$$PhotoListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PhotoListResponseImpl(
  photos: (json['photos'] as List<dynamic>)
      .map((e) => Photo.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationInfo.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$PhotoListResponseImplToJson(
  _$PhotoListResponseImpl instance,
) => <String, dynamic>{
  'photos': instance.photos,
  'pagination': instance.pagination,
};

_$PaginationInfoImpl _$$PaginationInfoImplFromJson(Map<String, dynamic> json) =>
    _$PaginationInfoImpl(
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$$PaginationInfoImplToJson(
  _$PaginationInfoImpl instance,
) => <String, dynamic>{
  'limit': instance.limit,
  'offset': instance.offset,
  'total': instance.total,
  'hasMore': instance.hasMore,
};

_$PhotoAnalysisResultImpl _$$PhotoAnalysisResultImplFromJson(
  Map<String, dynamic> json,
) => _$PhotoAnalysisResultImpl(
  photoId: json['photoId'] as String,
  photoUrl: json['photoUrl'] as String,
  analysis: json['analysis'] as String,
  disclaimer: json['disclaimer'] as String,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$$PhotoAnalysisResultImplToJson(
  _$PhotoAnalysisResultImpl instance,
) => <String, dynamic>{
  'photoId': instance.photoId,
  'photoUrl': instance.photoUrl,
  'analysis': instance.analysis,
  'disclaimer': instance.disclaimer,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
};
