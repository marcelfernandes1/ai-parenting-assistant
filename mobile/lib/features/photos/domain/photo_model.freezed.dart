// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  /// Unique photo identifier from database
  String get id => throw _privateConstructorUsedError;

  /// Presigned S3 URL for accessing the photo (24-hour expiry)
  String get url => throw _privateConstructorUsedError;

  /// S3 key/path for the photo (server-side reference)
  String get s3Key => throw _privateConstructorUsedError;

  /// Upload timestamp
  DateTime get uploadedAt => throw _privateConstructorUsedError;

  /// Optional metadata (original filename, mime type, size)
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Optional milestone ID if photo is linked to a milestone
  String? get milestoneId => throw _privateConstructorUsedError;

  /// Optional album ID if photo is part of an album
  String? get albumId => throw _privateConstructorUsedError;

  /// Optional AI analysis results from Vision API
  Map<String, dynamic>? get analysisResults =>
      throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call({
    String id,
    String url,
    String s3Key,
    DateTime uploadedAt,
    Map<String, dynamic>? metadata,
    String? milestoneId,
    String? albumId,
    Map<String, dynamic>? analysisResults,
  });
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? s3Key = null,
    Object? uploadedAt = null,
    Object? metadata = freezed,
    Object? milestoneId = freezed,
    Object? albumId = freezed,
    Object? analysisResults = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            s3Key: null == s3Key
                ? _value.s3Key
                : s3Key // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            milestoneId: freezed == milestoneId
                ? _value.milestoneId
                : milestoneId // ignore: cast_nullable_to_non_nullable
                      as String?,
            albumId: freezed == albumId
                ? _value.albumId
                : albumId // ignore: cast_nullable_to_non_nullable
                      as String?,
            analysisResults: freezed == analysisResults
                ? _value.analysisResults
                : analysisResults // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
    _$PhotoImpl value,
    $Res Function(_$PhotoImpl) then,
  ) = __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    String s3Key,
    DateTime uploadedAt,
    Map<String, dynamic>? metadata,
    String? milestoneId,
    String? albumId,
    Map<String, dynamic>? analysisResults,
  });
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
    _$PhotoImpl _value,
    $Res Function(_$PhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? s3Key = null,
    Object? uploadedAt = null,
    Object? metadata = freezed,
    Object? milestoneId = freezed,
    Object? albumId = freezed,
    Object? analysisResults = freezed,
  }) {
    return _then(
      _$PhotoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        s3Key: null == s3Key
            ? _value.s3Key
            : s3Key // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        milestoneId: freezed == milestoneId
            ? _value.milestoneId
            : milestoneId // ignore: cast_nullable_to_non_nullable
                  as String?,
        albumId: freezed == albumId
            ? _value.albumId
            : albumId // ignore: cast_nullable_to_non_nullable
                  as String?,
        analysisResults: freezed == analysisResults
            ? _value._analysisResults
            : analysisResults // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoImpl implements _Photo {
  const _$PhotoImpl({
    required this.id,
    required this.url,
    required this.s3Key,
    required this.uploadedAt,
    final Map<String, dynamic>? metadata,
    this.milestoneId,
    this.albumId,
    final Map<String, dynamic>? analysisResults,
  }) : _metadata = metadata,
       _analysisResults = analysisResults;

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  /// Unique photo identifier from database
  @override
  final String id;

  /// Presigned S3 URL for accessing the photo (24-hour expiry)
  @override
  final String url;

  /// S3 key/path for the photo (server-side reference)
  @override
  final String s3Key;

  /// Upload timestamp
  @override
  final DateTime uploadedAt;

  /// Optional metadata (original filename, mime type, size)
  final Map<String, dynamic>? _metadata;

  /// Optional metadata (original filename, mime type, size)
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Optional milestone ID if photo is linked to a milestone
  @override
  final String? milestoneId;

  /// Optional album ID if photo is part of an album
  @override
  final String? albumId;

  /// Optional AI analysis results from Vision API
  final Map<String, dynamic>? _analysisResults;

  /// Optional AI analysis results from Vision API
  @override
  Map<String, dynamic>? get analysisResults {
    final value = _analysisResults;
    if (value == null) return null;
    if (_analysisResults is EqualUnmodifiableMapView) return _analysisResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Photo(id: $id, url: $url, s3Key: $s3Key, uploadedAt: $uploadedAt, metadata: $metadata, milestoneId: $milestoneId, albumId: $albumId, analysisResults: $analysisResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.s3Key, s3Key) || other.s3Key == s3Key) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.milestoneId, milestoneId) ||
                other.milestoneId == milestoneId) &&
            (identical(other.albumId, albumId) || other.albumId == albumId) &&
            const DeepCollectionEquality().equals(
              other._analysisResults,
              _analysisResults,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    s3Key,
    uploadedAt,
    const DeepCollectionEquality().hash(_metadata),
    milestoneId,
    albumId,
    const DeepCollectionEquality().hash(_analysisResults),
  );

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(this);
  }
}

abstract class _Photo implements Photo {
  const factory _Photo({
    required final String id,
    required final String url,
    required final String s3Key,
    required final DateTime uploadedAt,
    final Map<String, dynamic>? metadata,
    final String? milestoneId,
    final String? albumId,
    final Map<String, dynamic>? analysisResults,
  }) = _$PhotoImpl;

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  /// Unique photo identifier from database
  @override
  String get id;

  /// Presigned S3 URL for accessing the photo (24-hour expiry)
  @override
  String get url;

  /// S3 key/path for the photo (server-side reference)
  @override
  String get s3Key;

  /// Upload timestamp
  @override
  DateTime get uploadedAt;

  /// Optional metadata (original filename, mime type, size)
  @override
  Map<String, dynamic>? get metadata;

  /// Optional milestone ID if photo is linked to a milestone
  @override
  String? get milestoneId;

  /// Optional album ID if photo is part of an album
  @override
  String? get albumId;

  /// Optional AI analysis results from Vision API
  @override
  Map<String, dynamic>? get analysisResults;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PhotoListResponse _$PhotoListResponseFromJson(Map<String, dynamic> json) {
  return _PhotoListResponse.fromJson(json);
}

/// @nodoc
mixin _$PhotoListResponse {
  /// List of photos in current page
  List<Photo> get photos => throw _privateConstructorUsedError;

  /// Pagination metadata
  PaginationInfo get pagination => throw _privateConstructorUsedError;

  /// Serializes this PhotoListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoListResponseCopyWith<PhotoListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoListResponseCopyWith<$Res> {
  factory $PhotoListResponseCopyWith(
    PhotoListResponse value,
    $Res Function(PhotoListResponse) then,
  ) = _$PhotoListResponseCopyWithImpl<$Res, PhotoListResponse>;
  @useResult
  $Res call({List<Photo> photos, PaginationInfo pagination});

  $PaginationInfoCopyWith<$Res> get pagination;
}

/// @nodoc
class _$PhotoListResponseCopyWithImpl<$Res, $Val extends PhotoListResponse>
    implements $PhotoListResponseCopyWith<$Res> {
  _$PhotoListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? photos = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            photos: null == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<Photo>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as PaginationInfo,
          )
          as $Val,
    );
  }

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationInfoCopyWith<$Res> get pagination {
    return $PaginationInfoCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PhotoListResponseImplCopyWith<$Res>
    implements $PhotoListResponseCopyWith<$Res> {
  factory _$$PhotoListResponseImplCopyWith(
    _$PhotoListResponseImpl value,
    $Res Function(_$PhotoListResponseImpl) then,
  ) = __$$PhotoListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Photo> photos, PaginationInfo pagination});

  @override
  $PaginationInfoCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$PhotoListResponseImplCopyWithImpl<$Res>
    extends _$PhotoListResponseCopyWithImpl<$Res, _$PhotoListResponseImpl>
    implements _$$PhotoListResponseImplCopyWith<$Res> {
  __$$PhotoListResponseImplCopyWithImpl(
    _$PhotoListResponseImpl _value,
    $Res Function(_$PhotoListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? photos = null, Object? pagination = null}) {
    return _then(
      _$PhotoListResponseImpl(
        photos: null == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<Photo>,
        pagination: null == pagination
            ? _value.pagination
            : pagination // ignore: cast_nullable_to_non_nullable
                  as PaginationInfo,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoListResponseImpl implements _PhotoListResponse {
  const _$PhotoListResponseImpl({
    required final List<Photo> photos,
    required this.pagination,
  }) : _photos = photos;

  factory _$PhotoListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoListResponseImplFromJson(json);

  /// List of photos in current page
  final List<Photo> _photos;

  /// List of photos in current page
  @override
  List<Photo> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  /// Pagination metadata
  @override
  final PaginationInfo pagination;

  @override
  String toString() {
    return 'PhotoListResponse(photos: $photos, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoListResponseImpl &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_photos),
    pagination,
  );

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoListResponseImplCopyWith<_$PhotoListResponseImpl> get copyWith =>
      __$$PhotoListResponseImplCopyWithImpl<_$PhotoListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoListResponseImplToJson(this);
  }
}

abstract class _PhotoListResponse implements PhotoListResponse {
  const factory _PhotoListResponse({
    required final List<Photo> photos,
    required final PaginationInfo pagination,
  }) = _$PhotoListResponseImpl;

  factory _PhotoListResponse.fromJson(Map<String, dynamic> json) =
      _$PhotoListResponseImpl.fromJson;

  /// List of photos in current page
  @override
  List<Photo> get photos;

  /// Pagination metadata
  @override
  PaginationInfo get pagination;

  /// Create a copy of PhotoListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoListResponseImplCopyWith<_$PhotoListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginationInfo _$PaginationInfoFromJson(Map<String, dynamic> json) {
  return _PaginationInfo.fromJson(json);
}

/// @nodoc
mixin _$PaginationInfo {
  /// Number of items per page
  int get limit => throw _privateConstructorUsedError;

  /// Number of items skipped
  int get offset => throw _privateConstructorUsedError;

  /// Total number of items available
  int get total => throw _privateConstructorUsedError;

  /// Whether there are more pages available
  bool get hasMore => throw _privateConstructorUsedError;

  /// Serializes this PaginationInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationInfoCopyWith<PaginationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationInfoCopyWith<$Res> {
  factory $PaginationInfoCopyWith(
    PaginationInfo value,
    $Res Function(PaginationInfo) then,
  ) = _$PaginationInfoCopyWithImpl<$Res, PaginationInfo>;
  @useResult
  $Res call({int limit, int offset, int total, bool hasMore});
}

/// @nodoc
class _$PaginationInfoCopyWithImpl<$Res, $Val extends PaginationInfo>
    implements $PaginationInfoCopyWith<$Res> {
  _$PaginationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? offset = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            offset: null == offset
                ? _value.offset
                : offset // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginationInfoImplCopyWith<$Res>
    implements $PaginationInfoCopyWith<$Res> {
  factory _$$PaginationInfoImplCopyWith(
    _$PaginationInfoImpl value,
    $Res Function(_$PaginationInfoImpl) then,
  ) = __$$PaginationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int limit, int offset, int total, bool hasMore});
}

/// @nodoc
class __$$PaginationInfoImplCopyWithImpl<$Res>
    extends _$PaginationInfoCopyWithImpl<$Res, _$PaginationInfoImpl>
    implements _$$PaginationInfoImplCopyWith<$Res> {
  __$$PaginationInfoImplCopyWithImpl(
    _$PaginationInfoImpl _value,
    $Res Function(_$PaginationInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? offset = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$PaginationInfoImpl(
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        offset: null == offset
            ? _value.offset
            : offset // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationInfoImpl implements _PaginationInfo {
  const _$PaginationInfoImpl({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasMore,
  });

  factory _$PaginationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationInfoImplFromJson(json);

  /// Number of items per page
  @override
  final int limit;

  /// Number of items skipped
  @override
  final int offset;

  /// Total number of items available
  @override
  final int total;

  /// Whether there are more pages available
  @override
  final bool hasMore;

  @override
  String toString() {
    return 'PaginationInfo(limit: $limit, offset: $offset, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationInfoImpl &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, limit, offset, total, hasMore);

  /// Create a copy of PaginationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationInfoImplCopyWith<_$PaginationInfoImpl> get copyWith =>
      __$$PaginationInfoImplCopyWithImpl<_$PaginationInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationInfoImplToJson(this);
  }
}

abstract class _PaginationInfo implements PaginationInfo {
  const factory _PaginationInfo({
    required final int limit,
    required final int offset,
    required final int total,
    required final bool hasMore,
  }) = _$PaginationInfoImpl;

  factory _PaginationInfo.fromJson(Map<String, dynamic> json) =
      _$PaginationInfoImpl.fromJson;

  /// Number of items per page
  @override
  int get limit;

  /// Number of items skipped
  @override
  int get offset;

  /// Total number of items available
  @override
  int get total;

  /// Whether there are more pages available
  @override
  bool get hasMore;

  /// Create a copy of PaginationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationInfoImplCopyWith<_$PaginationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PhotoAnalysisResult _$PhotoAnalysisResultFromJson(Map<String, dynamic> json) {
  return _PhotoAnalysisResult.fromJson(json);
}

/// @nodoc
mixin _$PhotoAnalysisResult {
  /// Unique photo identifier
  String get photoId => throw _privateConstructorUsedError;

  /// Presigned URL for the analyzed photo
  String get photoUrl => throw _privateConstructorUsedError;

  /// AI-generated analysis text
  String get analysis => throw _privateConstructorUsedError;

  /// Medical disclaimer text
  String get disclaimer => throw _privateConstructorUsedError;

  /// Timestamp of upload
  DateTime get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this PhotoAnalysisResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoAnalysisResultCopyWith<PhotoAnalysisResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoAnalysisResultCopyWith<$Res> {
  factory $PhotoAnalysisResultCopyWith(
    PhotoAnalysisResult value,
    $Res Function(PhotoAnalysisResult) then,
  ) = _$PhotoAnalysisResultCopyWithImpl<$Res, PhotoAnalysisResult>;
  @useResult
  $Res call({
    String photoId,
    String photoUrl,
    String analysis,
    String disclaimer,
    DateTime uploadedAt,
  });
}

/// @nodoc
class _$PhotoAnalysisResultCopyWithImpl<$Res, $Val extends PhotoAnalysisResult>
    implements $PhotoAnalysisResultCopyWith<$Res> {
  _$PhotoAnalysisResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? photoUrl = null,
    Object? analysis = null,
    Object? disclaimer = null,
    Object? uploadedAt = null,
  }) {
    return _then(
      _value.copyWith(
            photoId: null == photoId
                ? _value.photoId
                : photoId // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            analysis: null == analysis
                ? _value.analysis
                : analysis // ignore: cast_nullable_to_non_nullable
                      as String,
            disclaimer: null == disclaimer
                ? _value.disclaimer
                : disclaimer // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoAnalysisResultImplCopyWith<$Res>
    implements $PhotoAnalysisResultCopyWith<$Res> {
  factory _$$PhotoAnalysisResultImplCopyWith(
    _$PhotoAnalysisResultImpl value,
    $Res Function(_$PhotoAnalysisResultImpl) then,
  ) = __$$PhotoAnalysisResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String photoId,
    String photoUrl,
    String analysis,
    String disclaimer,
    DateTime uploadedAt,
  });
}

/// @nodoc
class __$$PhotoAnalysisResultImplCopyWithImpl<$Res>
    extends _$PhotoAnalysisResultCopyWithImpl<$Res, _$PhotoAnalysisResultImpl>
    implements _$$PhotoAnalysisResultImplCopyWith<$Res> {
  __$$PhotoAnalysisResultImplCopyWithImpl(
    _$PhotoAnalysisResultImpl _value,
    $Res Function(_$PhotoAnalysisResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? photoUrl = null,
    Object? analysis = null,
    Object? disclaimer = null,
    Object? uploadedAt = null,
  }) {
    return _then(
      _$PhotoAnalysisResultImpl(
        photoId: null == photoId
            ? _value.photoId
            : photoId // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: null == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        analysis: null == analysis
            ? _value.analysis
            : analysis // ignore: cast_nullable_to_non_nullable
                  as String,
        disclaimer: null == disclaimer
            ? _value.disclaimer
            : disclaimer // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoAnalysisResultImpl implements _PhotoAnalysisResult {
  const _$PhotoAnalysisResultImpl({
    required this.photoId,
    required this.photoUrl,
    required this.analysis,
    required this.disclaimer,
    required this.uploadedAt,
  });

  factory _$PhotoAnalysisResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoAnalysisResultImplFromJson(json);

  /// Unique photo identifier
  @override
  final String photoId;

  /// Presigned URL for the analyzed photo
  @override
  final String photoUrl;

  /// AI-generated analysis text
  @override
  final String analysis;

  /// Medical disclaimer text
  @override
  final String disclaimer;

  /// Timestamp of upload
  @override
  final DateTime uploadedAt;

  @override
  String toString() {
    return 'PhotoAnalysisResult(photoId: $photoId, photoUrl: $photoUrl, analysis: $analysis, disclaimer: $disclaimer, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoAnalysisResultImpl &&
            (identical(other.photoId, photoId) || other.photoId == photoId) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.analysis, analysis) ||
                other.analysis == analysis) &&
            (identical(other.disclaimer, disclaimer) ||
                other.disclaimer == disclaimer) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    photoId,
    photoUrl,
    analysis,
    disclaimer,
    uploadedAt,
  );

  /// Create a copy of PhotoAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoAnalysisResultImplCopyWith<_$PhotoAnalysisResultImpl> get copyWith =>
      __$$PhotoAnalysisResultImplCopyWithImpl<_$PhotoAnalysisResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoAnalysisResultImplToJson(this);
  }
}

abstract class _PhotoAnalysisResult implements PhotoAnalysisResult {
  const factory _PhotoAnalysisResult({
    required final String photoId,
    required final String photoUrl,
    required final String analysis,
    required final String disclaimer,
    required final DateTime uploadedAt,
  }) = _$PhotoAnalysisResultImpl;

  factory _PhotoAnalysisResult.fromJson(Map<String, dynamic> json) =
      _$PhotoAnalysisResultImpl.fromJson;

  /// Unique photo identifier
  @override
  String get photoId;

  /// Presigned URL for the analyzed photo
  @override
  String get photoUrl;

  /// AI-generated analysis text
  @override
  String get analysis;

  /// Medical disclaimer text
  @override
  String get disclaimer;

  /// Timestamp of upload
  @override
  DateTime get uploadedAt;

  /// Create a copy of PhotoAnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoAnalysisResultImplCopyWith<_$PhotoAnalysisResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
