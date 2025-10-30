// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Milestone _$MilestoneFromJson(Map<String, dynamic> json) {
  return _Milestone.fromJson(json);
}

/// @nodoc
mixin _$Milestone {
  /// Unique milestone identifier from database
  String get id => throw _privateConstructorUsedError;

  /// Type of milestone (physical, feeding, sleep, social, health)
  MilestoneType get type => throw _privateConstructorUsedError;

  /// Name/title of the milestone
  String get name => throw _privateConstructorUsedError;

  /// Date the milestone was achieved
  DateTime get achievedDate => throw _privateConstructorUsedError;

  /// Optional notes from parent about the milestone
  String? get notes => throw _privateConstructorUsedError;

  /// Array of photo URLs associated with this milestone
  List<String> get photoUrls => throw _privateConstructorUsedError;

  /// Whether this milestone was suggested by AI
  bool get aiSuggested => throw _privateConstructorUsedError;

  /// Whether user has confirmed this milestone
  bool get confirmed => throw _privateConstructorUsedError;

  /// Timestamp when milestone was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp when milestone was last updated
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneCopyWith<Milestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneCopyWith<$Res> {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) then) =
      _$MilestoneCopyWithImpl<$Res, Milestone>;
  @useResult
  $Res call({
    String id,
    MilestoneType type,
    String name,
    DateTime achievedDate,
    String? notes,
    List<String> photoUrls,
    bool aiSuggested,
    bool confirmed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$MilestoneCopyWithImpl<$Res, $Val extends Milestone>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? achievedDate = null,
    Object? notes = freezed,
    Object? photoUrls = null,
    Object? aiSuggested = null,
    Object? confirmed = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MilestoneType,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            achievedDate: null == achievedDate
                ? _value.achievedDate
                : achievedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            aiSuggested: null == aiSuggested
                ? _value.aiSuggested
                : aiSuggested // ignore: cast_nullable_to_non_nullable
                      as bool,
            confirmed: null == confirmed
                ? _value.confirmed
                : confirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MilestoneImplCopyWith<$Res>
    implements $MilestoneCopyWith<$Res> {
  factory _$$MilestoneImplCopyWith(
    _$MilestoneImpl value,
    $Res Function(_$MilestoneImpl) then,
  ) = __$$MilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    MilestoneType type,
    String name,
    DateTime achievedDate,
    String? notes,
    List<String> photoUrls,
    bool aiSuggested,
    bool confirmed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$MilestoneImplCopyWithImpl<$Res>
    extends _$MilestoneCopyWithImpl<$Res, _$MilestoneImpl>
    implements _$$MilestoneImplCopyWith<$Res> {
  __$$MilestoneImplCopyWithImpl(
    _$MilestoneImpl _value,
    $Res Function(_$MilestoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? achievedDate = null,
    Object? notes = freezed,
    Object? photoUrls = null,
    Object? aiSuggested = null,
    Object? confirmed = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MilestoneImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MilestoneType,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        achievedDate: null == achievedDate
            ? _value.achievedDate
            : achievedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        aiSuggested: null == aiSuggested
            ? _value.aiSuggested
            : aiSuggested // ignore: cast_nullable_to_non_nullable
                  as bool,
        confirmed: null == confirmed
            ? _value.confirmed
            : confirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneImpl implements _Milestone {
  const _$MilestoneImpl({
    required this.id,
    required this.type,
    required this.name,
    required this.achievedDate,
    this.notes,
    final List<String> photoUrls = const [],
    this.aiSuggested = false,
    this.confirmed = true,
    required this.createdAt,
    required this.updatedAt,
  }) : _photoUrls = photoUrls;

  factory _$MilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneImplFromJson(json);

  /// Unique milestone identifier from database
  @override
  final String id;

  /// Type of milestone (physical, feeding, sleep, social, health)
  @override
  final MilestoneType type;

  /// Name/title of the milestone
  @override
  final String name;

  /// Date the milestone was achieved
  @override
  final DateTime achievedDate;

  /// Optional notes from parent about the milestone
  @override
  final String? notes;

  /// Array of photo URLs associated with this milestone
  final List<String> _photoUrls;

  /// Array of photo URLs associated with this milestone
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  /// Whether this milestone was suggested by AI
  @override
  @JsonKey()
  final bool aiSuggested;

  /// Whether user has confirmed this milestone
  @override
  @JsonKey()
  final bool confirmed;

  /// Timestamp when milestone was created
  @override
  final DateTime createdAt;

  /// Timestamp when milestone was last updated
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Milestone(id: $id, type: $type, name: $name, achievedDate: $achievedDate, notes: $notes, photoUrls: $photoUrls, aiSuggested: $aiSuggested, confirmed: $confirmed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.achievedDate, achievedDate) ||
                other.achievedDate == achievedDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ) &&
            (identical(other.aiSuggested, aiSuggested) ||
                other.aiSuggested == aiSuggested) &&
            (identical(other.confirmed, confirmed) ||
                other.confirmed == confirmed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    name,
    achievedDate,
    notes,
    const DeepCollectionEquality().hash(_photoUrls),
    aiSuggested,
    confirmed,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      __$$MilestoneImplCopyWithImpl<_$MilestoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneImplToJson(this);
  }
}

abstract class _Milestone implements Milestone {
  const factory _Milestone({
    required final String id,
    required final MilestoneType type,
    required final String name,
    required final DateTime achievedDate,
    final String? notes,
    final List<String> photoUrls,
    final bool aiSuggested,
    final bool confirmed,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$MilestoneImpl;

  factory _Milestone.fromJson(Map<String, dynamic> json) =
      _$MilestoneImpl.fromJson;

  /// Unique milestone identifier from database
  @override
  String get id;

  /// Type of milestone (physical, feeding, sleep, social, health)
  @override
  MilestoneType get type;

  /// Name/title of the milestone
  @override
  String get name;

  /// Date the milestone was achieved
  @override
  DateTime get achievedDate;

  /// Optional notes from parent about the milestone
  @override
  String? get notes;

  /// Array of photo URLs associated with this milestone
  @override
  List<String> get photoUrls;

  /// Whether this milestone was suggested by AI
  @override
  bool get aiSuggested;

  /// Whether user has confirmed this milestone
  @override
  bool get confirmed;

  /// Timestamp when milestone was created
  @override
  DateTime get createdAt;

  /// Timestamp when milestone was last updated
  @override
  DateTime get updatedAt;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MilestoneListResponse _$MilestoneListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MilestoneListResponse.fromJson(json);
}

/// @nodoc
mixin _$MilestoneListResponse {
  /// List of milestones
  List<Milestone> get milestones => throw _privateConstructorUsedError;

  /// Total count of milestones for this query
  int get count => throw _privateConstructorUsedError;

  /// Serializes this MilestoneListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MilestoneListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneListResponseCopyWith<MilestoneListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneListResponseCopyWith<$Res> {
  factory $MilestoneListResponseCopyWith(
    MilestoneListResponse value,
    $Res Function(MilestoneListResponse) then,
  ) = _$MilestoneListResponseCopyWithImpl<$Res, MilestoneListResponse>;
  @useResult
  $Res call({List<Milestone> milestones, int count});
}

/// @nodoc
class _$MilestoneListResponseCopyWithImpl<
  $Res,
  $Val extends MilestoneListResponse
>
    implements $MilestoneListResponseCopyWith<$Res> {
  _$MilestoneListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MilestoneListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? milestones = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            milestones: null == milestones
                ? _value.milestones
                : milestones // ignore: cast_nullable_to_non_nullable
                      as List<Milestone>,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MilestoneListResponseImplCopyWith<$Res>
    implements $MilestoneListResponseCopyWith<$Res> {
  factory _$$MilestoneListResponseImplCopyWith(
    _$MilestoneListResponseImpl value,
    $Res Function(_$MilestoneListResponseImpl) then,
  ) = __$$MilestoneListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Milestone> milestones, int count});
}

/// @nodoc
class __$$MilestoneListResponseImplCopyWithImpl<$Res>
    extends
        _$MilestoneListResponseCopyWithImpl<$Res, _$MilestoneListResponseImpl>
    implements _$$MilestoneListResponseImplCopyWith<$Res> {
  __$$MilestoneListResponseImplCopyWithImpl(
    _$MilestoneListResponseImpl _value,
    $Res Function(_$MilestoneListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MilestoneListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? milestones = null, Object? count = null}) {
    return _then(
      _$MilestoneListResponseImpl(
        milestones: null == milestones
            ? _value._milestones
            : milestones // ignore: cast_nullable_to_non_nullable
                  as List<Milestone>,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneListResponseImpl implements _MilestoneListResponse {
  const _$MilestoneListResponseImpl({
    required final List<Milestone> milestones,
    required this.count,
  }) : _milestones = milestones;

  factory _$MilestoneListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneListResponseImplFromJson(json);

  /// List of milestones
  final List<Milestone> _milestones;

  /// List of milestones
  @override
  List<Milestone> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

  /// Total count of milestones for this query
  @override
  final int count;

  @override
  String toString() {
    return 'MilestoneListResponse(milestones: $milestones, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneListResponseImpl &&
            const DeepCollectionEquality().equals(
              other._milestones,
              _milestones,
            ) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_milestones),
    count,
  );

  /// Create a copy of MilestoneListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneListResponseImplCopyWith<_$MilestoneListResponseImpl>
  get copyWith =>
      __$$MilestoneListResponseImplCopyWithImpl<_$MilestoneListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneListResponseImplToJson(this);
  }
}

abstract class _MilestoneListResponse implements MilestoneListResponse {
  const factory _MilestoneListResponse({
    required final List<Milestone> milestones,
    required final int count,
  }) = _$MilestoneListResponseImpl;

  factory _MilestoneListResponse.fromJson(Map<String, dynamic> json) =
      _$MilestoneListResponseImpl.fromJson;

  /// List of milestones
  @override
  List<Milestone> get milestones;

  /// Total count of milestones for this query
  @override
  int get count;

  /// Create a copy of MilestoneListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneListResponseImplCopyWith<_$MilestoneListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MilestoneSuggestion _$MilestoneSuggestionFromJson(Map<String, dynamic> json) {
  return _MilestoneSuggestion.fromJson(json);
}

/// @nodoc
mixin _$MilestoneSuggestion {
  /// Type of milestone (physical, feeding, sleep, social, health)
  MilestoneType get type => throw _privateConstructorUsedError;

  /// Name/title of the suggested milestone
  String get name => throw _privateConstructorUsedError;

  /// Description explaining what this milestone means
  String get description => throw _privateConstructorUsedError;

  /// Age range when this milestone typically occurs
  AgeRange get ageRangeMonths => throw _privateConstructorUsedError;

  /// Always true for suggestions
  bool get aiSuggested => throw _privateConstructorUsedError;

  /// Serializes this MilestoneSuggestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneSuggestionCopyWith<MilestoneSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneSuggestionCopyWith<$Res> {
  factory $MilestoneSuggestionCopyWith(
    MilestoneSuggestion value,
    $Res Function(MilestoneSuggestion) then,
  ) = _$MilestoneSuggestionCopyWithImpl<$Res, MilestoneSuggestion>;
  @useResult
  $Res call({
    MilestoneType type,
    String name,
    String description,
    AgeRange ageRangeMonths,
    bool aiSuggested,
  });

  $AgeRangeCopyWith<$Res> get ageRangeMonths;
}

/// @nodoc
class _$MilestoneSuggestionCopyWithImpl<$Res, $Val extends MilestoneSuggestion>
    implements $MilestoneSuggestionCopyWith<$Res> {
  _$MilestoneSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? description = null,
    Object? ageRangeMonths = null,
    Object? aiSuggested = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MilestoneType,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            ageRangeMonths: null == ageRangeMonths
                ? _value.ageRangeMonths
                : ageRangeMonths // ignore: cast_nullable_to_non_nullable
                      as AgeRange,
            aiSuggested: null == aiSuggested
                ? _value.aiSuggested
                : aiSuggested // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AgeRangeCopyWith<$Res> get ageRangeMonths {
    return $AgeRangeCopyWith<$Res>(_value.ageRangeMonths, (value) {
      return _then(_value.copyWith(ageRangeMonths: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MilestoneSuggestionImplCopyWith<$Res>
    implements $MilestoneSuggestionCopyWith<$Res> {
  factory _$$MilestoneSuggestionImplCopyWith(
    _$MilestoneSuggestionImpl value,
    $Res Function(_$MilestoneSuggestionImpl) then,
  ) = __$$MilestoneSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MilestoneType type,
    String name,
    String description,
    AgeRange ageRangeMonths,
    bool aiSuggested,
  });

  @override
  $AgeRangeCopyWith<$Res> get ageRangeMonths;
}

/// @nodoc
class __$$MilestoneSuggestionImplCopyWithImpl<$Res>
    extends _$MilestoneSuggestionCopyWithImpl<$Res, _$MilestoneSuggestionImpl>
    implements _$$MilestoneSuggestionImplCopyWith<$Res> {
  __$$MilestoneSuggestionImplCopyWithImpl(
    _$MilestoneSuggestionImpl _value,
    $Res Function(_$MilestoneSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? name = null,
    Object? description = null,
    Object? ageRangeMonths = null,
    Object? aiSuggested = null,
  }) {
    return _then(
      _$MilestoneSuggestionImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MilestoneType,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        ageRangeMonths: null == ageRangeMonths
            ? _value.ageRangeMonths
            : ageRangeMonths // ignore: cast_nullable_to_non_nullable
                  as AgeRange,
        aiSuggested: null == aiSuggested
            ? _value.aiSuggested
            : aiSuggested // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneSuggestionImpl implements _MilestoneSuggestion {
  const _$MilestoneSuggestionImpl({
    required this.type,
    required this.name,
    required this.description,
    required this.ageRangeMonths,
    this.aiSuggested = true,
  });

  factory _$MilestoneSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneSuggestionImplFromJson(json);

  /// Type of milestone (physical, feeding, sleep, social, health)
  @override
  final MilestoneType type;

  /// Name/title of the suggested milestone
  @override
  final String name;

  /// Description explaining what this milestone means
  @override
  final String description;

  /// Age range when this milestone typically occurs
  @override
  final AgeRange ageRangeMonths;

  /// Always true for suggestions
  @override
  @JsonKey()
  final bool aiSuggested;

  @override
  String toString() {
    return 'MilestoneSuggestion(type: $type, name: $name, description: $description, ageRangeMonths: $ageRangeMonths, aiSuggested: $aiSuggested)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneSuggestionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.ageRangeMonths, ageRangeMonths) ||
                other.ageRangeMonths == ageRangeMonths) &&
            (identical(other.aiSuggested, aiSuggested) ||
                other.aiSuggested == aiSuggested));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    name,
    description,
    ageRangeMonths,
    aiSuggested,
  );

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneSuggestionImplCopyWith<_$MilestoneSuggestionImpl> get copyWith =>
      __$$MilestoneSuggestionImplCopyWithImpl<_$MilestoneSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneSuggestionImplToJson(this);
  }
}

abstract class _MilestoneSuggestion implements MilestoneSuggestion {
  const factory _MilestoneSuggestion({
    required final MilestoneType type,
    required final String name,
    required final String description,
    required final AgeRange ageRangeMonths,
    final bool aiSuggested,
  }) = _$MilestoneSuggestionImpl;

  factory _MilestoneSuggestion.fromJson(Map<String, dynamic> json) =
      _$MilestoneSuggestionImpl.fromJson;

  /// Type of milestone (physical, feeding, sleep, social, health)
  @override
  MilestoneType get type;

  /// Name/title of the suggested milestone
  @override
  String get name;

  /// Description explaining what this milestone means
  @override
  String get description;

  /// Age range when this milestone typically occurs
  @override
  AgeRange get ageRangeMonths;

  /// Always true for suggestions
  @override
  bool get aiSuggested;

  /// Create a copy of MilestoneSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneSuggestionImplCopyWith<_$MilestoneSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgeRange _$AgeRangeFromJson(Map<String, dynamic> json) {
  return _AgeRange.fromJson(json);
}

/// @nodoc
mixin _$AgeRange {
  /// Minimum age in months when milestone typically occurs
  int get min => throw _privateConstructorUsedError;

  /// Maximum age in months when milestone typically occurs
  int get max => throw _privateConstructorUsedError;

  /// Serializes this AgeRange to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgeRangeCopyWith<AgeRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgeRangeCopyWith<$Res> {
  factory $AgeRangeCopyWith(AgeRange value, $Res Function(AgeRange) then) =
      _$AgeRangeCopyWithImpl<$Res, AgeRange>;
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class _$AgeRangeCopyWithImpl<$Res, $Val extends AgeRange>
    implements $AgeRangeCopyWith<$Res> {
  _$AgeRangeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _value.copyWith(
            min: null == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as int,
            max: null == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgeRangeImplCopyWith<$Res>
    implements $AgeRangeCopyWith<$Res> {
  factory _$$AgeRangeImplCopyWith(
    _$AgeRangeImpl value,
    $Res Function(_$AgeRangeImpl) then,
  ) = __$$AgeRangeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int min, int max});
}

/// @nodoc
class __$$AgeRangeImplCopyWithImpl<$Res>
    extends _$AgeRangeCopyWithImpl<$Res, _$AgeRangeImpl>
    implements _$$AgeRangeImplCopyWith<$Res> {
  __$$AgeRangeImplCopyWithImpl(
    _$AgeRangeImpl _value,
    $Res Function(_$AgeRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgeRange
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? min = null, Object? max = null}) {
    return _then(
      _$AgeRangeImpl(
        min: null == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as int,
        max: null == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgeRangeImpl implements _AgeRange {
  const _$AgeRangeImpl({required this.min, required this.max});

  factory _$AgeRangeImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgeRangeImplFromJson(json);

  /// Minimum age in months when milestone typically occurs
  @override
  final int min;

  /// Maximum age in months when milestone typically occurs
  @override
  final int max;

  @override
  String toString() {
    return 'AgeRange(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgeRangeImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, min, max);

  /// Create a copy of AgeRange
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgeRangeImplCopyWith<_$AgeRangeImpl> get copyWith =>
      __$$AgeRangeImplCopyWithImpl<_$AgeRangeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgeRangeImplToJson(this);
  }
}

abstract class _AgeRange implements AgeRange {
  const factory _AgeRange({required final int min, required final int max}) =
      _$AgeRangeImpl;

  factory _AgeRange.fromJson(Map<String, dynamic> json) =
      _$AgeRangeImpl.fromJson;

  /// Minimum age in months when milestone typically occurs
  @override
  int get min;

  /// Maximum age in months when milestone typically occurs
  @override
  int get max;

  /// Create a copy of AgeRange
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgeRangeImplCopyWith<_$AgeRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MilestoneSuggestionsResponse _$MilestoneSuggestionsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _MilestoneSuggestionsResponse.fromJson(json);
}

/// @nodoc
mixin _$MilestoneSuggestionsResponse {
  /// List of suggested milestones
  List<MilestoneSuggestion> get suggestions =>
      throw _privateConstructorUsedError;

  /// Total count of suggestions
  int get count => throw _privateConstructorUsedError;

  /// Serializes this MilestoneSuggestionsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MilestoneSuggestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneSuggestionsResponseCopyWith<MilestoneSuggestionsResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneSuggestionsResponseCopyWith<$Res> {
  factory $MilestoneSuggestionsResponseCopyWith(
    MilestoneSuggestionsResponse value,
    $Res Function(MilestoneSuggestionsResponse) then,
  ) =
      _$MilestoneSuggestionsResponseCopyWithImpl<
        $Res,
        MilestoneSuggestionsResponse
      >;
  @useResult
  $Res call({List<MilestoneSuggestion> suggestions, int count});
}

/// @nodoc
class _$MilestoneSuggestionsResponseCopyWithImpl<
  $Res,
  $Val extends MilestoneSuggestionsResponse
>
    implements $MilestoneSuggestionsResponseCopyWith<$Res> {
  _$MilestoneSuggestionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MilestoneSuggestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? suggestions = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<MilestoneSuggestion>,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MilestoneSuggestionsResponseImplCopyWith<$Res>
    implements $MilestoneSuggestionsResponseCopyWith<$Res> {
  factory _$$MilestoneSuggestionsResponseImplCopyWith(
    _$MilestoneSuggestionsResponseImpl value,
    $Res Function(_$MilestoneSuggestionsResponseImpl) then,
  ) = __$$MilestoneSuggestionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MilestoneSuggestion> suggestions, int count});
}

/// @nodoc
class __$$MilestoneSuggestionsResponseImplCopyWithImpl<$Res>
    extends
        _$MilestoneSuggestionsResponseCopyWithImpl<
          $Res,
          _$MilestoneSuggestionsResponseImpl
        >
    implements _$$MilestoneSuggestionsResponseImplCopyWith<$Res> {
  __$$MilestoneSuggestionsResponseImplCopyWithImpl(
    _$MilestoneSuggestionsResponseImpl _value,
    $Res Function(_$MilestoneSuggestionsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MilestoneSuggestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? suggestions = null, Object? count = null}) {
    return _then(
      _$MilestoneSuggestionsResponseImpl(
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<MilestoneSuggestion>,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneSuggestionsResponseImpl
    implements _MilestoneSuggestionsResponse {
  const _$MilestoneSuggestionsResponseImpl({
    required final List<MilestoneSuggestion> suggestions,
    required this.count,
  }) : _suggestions = suggestions;

  factory _$MilestoneSuggestionsResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$MilestoneSuggestionsResponseImplFromJson(json);

  /// List of suggested milestones
  final List<MilestoneSuggestion> _suggestions;

  /// List of suggested milestones
  @override
  List<MilestoneSuggestion> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  /// Total count of suggestions
  @override
  final int count;

  @override
  String toString() {
    return 'MilestoneSuggestionsResponse(suggestions: $suggestions, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneSuggestionsResponseImpl &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_suggestions),
    count,
  );

  /// Create a copy of MilestoneSuggestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneSuggestionsResponseImplCopyWith<
    _$MilestoneSuggestionsResponseImpl
  >
  get copyWith =>
      __$$MilestoneSuggestionsResponseImplCopyWithImpl<
        _$MilestoneSuggestionsResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneSuggestionsResponseImplToJson(this);
  }
}

abstract class _MilestoneSuggestionsResponse
    implements MilestoneSuggestionsResponse {
  const factory _MilestoneSuggestionsResponse({
    required final List<MilestoneSuggestion> suggestions,
    required final int count,
  }) = _$MilestoneSuggestionsResponseImpl;

  factory _MilestoneSuggestionsResponse.fromJson(Map<String, dynamic> json) =
      _$MilestoneSuggestionsResponseImpl.fromJson;

  /// List of suggested milestones
  @override
  List<MilestoneSuggestion> get suggestions;

  /// Total count of suggestions
  @override
  int get count;

  /// Create a copy of MilestoneSuggestionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneSuggestionsResponseImplCopyWith<
    _$MilestoneSuggestionsResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
