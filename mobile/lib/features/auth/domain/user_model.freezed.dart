// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  /// Unique user identifier from database
  String get id => throw _privateConstructorUsedError;

  /// User's email address (used for login) - optional as profile endpoint doesn't return it
  String? get email => throw _privateConstructorUsedError;

  /// Optional user display name
  String? get name => throw _privateConstructorUsedError;

  /// User's subscription tier (FREE or PREMIUM)
  String get subscriptionTier => throw _privateConstructorUsedError;

  /// Whether user has completed onboarding
  bool get onboardingComplete => throw _privateConstructorUsedError;

  /// User profile mode (PREGNANCY or PARENT)
  String? get mode => throw _privateConstructorUsedError;

  /// Baby's name (if provided during onboarding)
  String? get babyName => throw _privateConstructorUsedError;

  /// Baby's birth date or due date (ISO string)
  String? get babyBirthDate => throw _privateConstructorUsedError;

  /// User's parenting philosophy preferences
  String? get parentingPhilosophy => throw _privateConstructorUsedError;

  /// User's religious/cultural background
  String? get religiousViews => throw _privateConstructorUsedError;

  /// User's primary concerns as a parent
  List<String>? get primaryConcerns => throw _privateConstructorUsedError;

  /// Profile creation timestamp
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Last profile update timestamp
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String? email,
    String? name,
    String subscriptionTier,
    bool onboardingComplete,
    String? mode,
    String? babyName,
    String? babyBirthDate,
    String? parentingPhilosophy,
    String? religiousViews,
    List<String>? primaryConcerns,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? name = freezed,
    Object? subscriptionTier = null,
    Object? onboardingComplete = null,
    Object? mode = freezed,
    Object? babyName = freezed,
    Object? babyBirthDate = freezed,
    Object? parentingPhilosophy = freezed,
    Object? religiousViews = freezed,
    Object? primaryConcerns = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            subscriptionTier: null == subscriptionTier
                ? _value.subscriptionTier
                : subscriptionTier // ignore: cast_nullable_to_non_nullable
                      as String,
            onboardingComplete: null == onboardingComplete
                ? _value.onboardingComplete
                : onboardingComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            mode: freezed == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String?,
            babyName: freezed == babyName
                ? _value.babyName
                : babyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            babyBirthDate: freezed == babyBirthDate
                ? _value.babyBirthDate
                : babyBirthDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentingPhilosophy: freezed == parentingPhilosophy
                ? _value.parentingPhilosophy
                : parentingPhilosophy // ignore: cast_nullable_to_non_nullable
                      as String?,
            religiousViews: freezed == religiousViews
                ? _value.religiousViews
                : religiousViews // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryConcerns: freezed == primaryConcerns
                ? _value.primaryConcerns
                : primaryConcerns // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? email,
    String? name,
    String subscriptionTier,
    bool onboardingComplete,
    String? mode,
    String? babyName,
    String? babyBirthDate,
    String? parentingPhilosophy,
    String? religiousViews,
    List<String>? primaryConcerns,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? name = freezed,
    Object? subscriptionTier = null,
    Object? onboardingComplete = null,
    Object? mode = freezed,
    Object? babyName = freezed,
    Object? babyBirthDate = freezed,
    Object? parentingPhilosophy = freezed,
    Object? religiousViews = freezed,
    Object? primaryConcerns = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        subscriptionTier: null == subscriptionTier
            ? _value.subscriptionTier
            : subscriptionTier // ignore: cast_nullable_to_non_nullable
                  as String,
        onboardingComplete: null == onboardingComplete
            ? _value.onboardingComplete
            : onboardingComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        mode: freezed == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String?,
        babyName: freezed == babyName
            ? _value.babyName
            : babyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        babyBirthDate: freezed == babyBirthDate
            ? _value.babyBirthDate
            : babyBirthDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentingPhilosophy: freezed == parentingPhilosophy
            ? _value.parentingPhilosophy
            : parentingPhilosophy // ignore: cast_nullable_to_non_nullable
                  as String?,
        religiousViews: freezed == religiousViews
            ? _value.religiousViews
            : religiousViews // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryConcerns: freezed == primaryConcerns
            ? _value._primaryConcerns
            : primaryConcerns // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    this.email,
    this.name,
    this.subscriptionTier = 'FREE',
    this.onboardingComplete = false,
    this.mode,
    this.babyName,
    this.babyBirthDate,
    this.parentingPhilosophy,
    this.religiousViews,
    final List<String>? primaryConcerns,
    this.createdAt,
    this.updatedAt,
  }) : _primaryConcerns = primaryConcerns;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  /// Unique user identifier from database
  @override
  final String id;

  /// User's email address (used for login) - optional as profile endpoint doesn't return it
  @override
  final String? email;

  /// Optional user display name
  @override
  final String? name;

  /// User's subscription tier (FREE or PREMIUM)
  @override
  @JsonKey()
  final String subscriptionTier;

  /// Whether user has completed onboarding
  @override
  @JsonKey()
  final bool onboardingComplete;

  /// User profile mode (PREGNANCY or PARENT)
  @override
  final String? mode;

  /// Baby's name (if provided during onboarding)
  @override
  final String? babyName;

  /// Baby's birth date or due date (ISO string)
  @override
  final String? babyBirthDate;

  /// User's parenting philosophy preferences
  @override
  final String? parentingPhilosophy;

  /// User's religious/cultural background
  @override
  final String? religiousViews;

  /// User's primary concerns as a parent
  final List<String>? _primaryConcerns;

  /// User's primary concerns as a parent
  @override
  List<String>? get primaryConcerns {
    final value = _primaryConcerns;
    if (value == null) return null;
    if (_primaryConcerns is EqualUnmodifiableListView) return _primaryConcerns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Profile creation timestamp
  @override
  final DateTime? createdAt;

  /// Last profile update timestamp
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, subscriptionTier: $subscriptionTier, onboardingComplete: $onboardingComplete, mode: $mode, babyName: $babyName, babyBirthDate: $babyBirthDate, parentingPhilosophy: $parentingPhilosophy, religiousViews: $religiousViews, primaryConcerns: $primaryConcerns, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.babyName, babyName) ||
                other.babyName == babyName) &&
            (identical(other.babyBirthDate, babyBirthDate) ||
                other.babyBirthDate == babyBirthDate) &&
            (identical(other.parentingPhilosophy, parentingPhilosophy) ||
                other.parentingPhilosophy == parentingPhilosophy) &&
            (identical(other.religiousViews, religiousViews) ||
                other.religiousViews == religiousViews) &&
            const DeepCollectionEquality().equals(
              other._primaryConcerns,
              _primaryConcerns,
            ) &&
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
    email,
    name,
    subscriptionTier,
    onboardingComplete,
    mode,
    babyName,
    babyBirthDate,
    parentingPhilosophy,
    religiousViews,
    const DeepCollectionEquality().hash(_primaryConcerns),
    createdAt,
    updatedAt,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    final String? email,
    final String? name,
    final String subscriptionTier,
    final bool onboardingComplete,
    final String? mode,
    final String? babyName,
    final String? babyBirthDate,
    final String? parentingPhilosophy,
    final String? religiousViews,
    final List<String>? primaryConcerns,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  /// Unique user identifier from database
  @override
  String get id;

  /// User's email address (used for login) - optional as profile endpoint doesn't return it
  @override
  String? get email;

  /// Optional user display name
  @override
  String? get name;

  /// User's subscription tier (FREE or PREMIUM)
  @override
  String get subscriptionTier;

  /// Whether user has completed onboarding
  @override
  bool get onboardingComplete;

  /// User profile mode (PREGNANCY or PARENT)
  @override
  String? get mode;

  /// Baby's name (if provided during onboarding)
  @override
  String? get babyName;

  /// Baby's birth date or due date (ISO string)
  @override
  String? get babyBirthDate;

  /// User's parenting philosophy preferences
  @override
  String? get parentingPhilosophy;

  /// User's religious/cultural background
  @override
  String? get religiousViews;

  /// User's primary concerns as a parent
  @override
  List<String>? get primaryConcerns;

  /// Profile creation timestamp
  @override
  DateTime? get createdAt;

  /// Last profile update timestamp
  @override
  DateTime? get updatedAt;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
