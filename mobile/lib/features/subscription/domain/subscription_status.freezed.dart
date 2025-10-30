// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) {
  return _SubscriptionStatus.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionStatus {
  /// User's subscription tier (FREE or PREMIUM)
  String get subscriptionTier => throw _privateConstructorUsedError;

  /// Current subscription status (ACTIVE, CANCELLED, EXPIRED, TRIALING)
  String get subscriptionStatus => throw _privateConstructorUsedError;

  /// When the subscription expires (null for FREE or unlimited)
  DateTime? get subscriptionExpiresAt => throw _privateConstructorUsedError;

  /// Stripe customer ID (null for FREE users)
  String? get stripeCustomerId => throw _privateConstructorUsedError;

  /// Stripe subscription ID (null for FREE users)
  String? get stripeSubscriptionId => throw _privateConstructorUsedError;

  /// Usage statistics for the current period
  UsageStats? get usage => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStatusCopyWith<SubscriptionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStatusCopyWith<$Res> {
  factory $SubscriptionStatusCopyWith(
    SubscriptionStatus value,
    $Res Function(SubscriptionStatus) then,
  ) = _$SubscriptionStatusCopyWithImpl<$Res, SubscriptionStatus>;
  @useResult
  $Res call({
    String subscriptionTier,
    String subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    UsageStats? usage,
  });

  $UsageStatsCopyWith<$Res>? get usage;
}

/// @nodoc
class _$SubscriptionStatusCopyWithImpl<$Res, $Val extends SubscriptionStatus>
    implements $SubscriptionStatusCopyWith<$Res> {
  _$SubscriptionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscriptionTier = null,
    Object? subscriptionStatus = null,
    Object? subscriptionExpiresAt = freezed,
    Object? stripeCustomerId = freezed,
    Object? stripeSubscriptionId = freezed,
    Object? usage = freezed,
  }) {
    return _then(
      _value.copyWith(
            subscriptionTier: null == subscriptionTier
                ? _value.subscriptionTier
                : subscriptionTier // ignore: cast_nullable_to_non_nullable
                      as String,
            subscriptionStatus: null == subscriptionStatus
                ? _value.subscriptionStatus
                : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            subscriptionExpiresAt: freezed == subscriptionExpiresAt
                ? _value.subscriptionExpiresAt
                : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            stripeCustomerId: freezed == stripeCustomerId
                ? _value.stripeCustomerId
                : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            stripeSubscriptionId: freezed == stripeSubscriptionId
                ? _value.stripeSubscriptionId
                : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            usage: freezed == usage
                ? _value.usage
                : usage // ignore: cast_nullable_to_non_nullable
                      as UsageStats?,
          )
          as $Val,
    );
  }

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UsageStatsCopyWith<$Res>? get usage {
    if (_value.usage == null) {
      return null;
    }

    return $UsageStatsCopyWith<$Res>(_value.usage!, (value) {
      return _then(_value.copyWith(usage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubscriptionStatusImplCopyWith<$Res>
    implements $SubscriptionStatusCopyWith<$Res> {
  factory _$$SubscriptionStatusImplCopyWith(
    _$SubscriptionStatusImpl value,
    $Res Function(_$SubscriptionStatusImpl) then,
  ) = __$$SubscriptionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String subscriptionTier,
    String subscriptionStatus,
    DateTime? subscriptionExpiresAt,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    UsageStats? usage,
  });

  @override
  $UsageStatsCopyWith<$Res>? get usage;
}

/// @nodoc
class __$$SubscriptionStatusImplCopyWithImpl<$Res>
    extends _$SubscriptionStatusCopyWithImpl<$Res, _$SubscriptionStatusImpl>
    implements _$$SubscriptionStatusImplCopyWith<$Res> {
  __$$SubscriptionStatusImplCopyWithImpl(
    _$SubscriptionStatusImpl _value,
    $Res Function(_$SubscriptionStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subscriptionTier = null,
    Object? subscriptionStatus = null,
    Object? subscriptionExpiresAt = freezed,
    Object? stripeCustomerId = freezed,
    Object? stripeSubscriptionId = freezed,
    Object? usage = freezed,
  }) {
    return _then(
      _$SubscriptionStatusImpl(
        subscriptionTier: null == subscriptionTier
            ? _value.subscriptionTier
            : subscriptionTier // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionStatus: null == subscriptionStatus
            ? _value.subscriptionStatus
            : subscriptionStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionExpiresAt: freezed == subscriptionExpiresAt
            ? _value.subscriptionExpiresAt
            : subscriptionExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stripeCustomerId: freezed == stripeCustomerId
            ? _value.stripeCustomerId
            : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        stripeSubscriptionId: freezed == stripeSubscriptionId
            ? _value.stripeSubscriptionId
            : stripeSubscriptionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        usage: freezed == usage
            ? _value.usage
            : usage // ignore: cast_nullable_to_non_nullable
                  as UsageStats?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionStatusImpl implements _SubscriptionStatus {
  const _$SubscriptionStatusImpl({
    required this.subscriptionTier,
    required this.subscriptionStatus,
    this.subscriptionExpiresAt,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.usage,
  });

  factory _$SubscriptionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionStatusImplFromJson(json);

  /// User's subscription tier (FREE or PREMIUM)
  @override
  final String subscriptionTier;

  /// Current subscription status (ACTIVE, CANCELLED, EXPIRED, TRIALING)
  @override
  final String subscriptionStatus;

  /// When the subscription expires (null for FREE or unlimited)
  @override
  final DateTime? subscriptionExpiresAt;

  /// Stripe customer ID (null for FREE users)
  @override
  final String? stripeCustomerId;

  /// Stripe subscription ID (null for FREE users)
  @override
  final String? stripeSubscriptionId;

  /// Usage statistics for the current period
  @override
  final UsageStats? usage;

  @override
  String toString() {
    return 'SubscriptionStatus(subscriptionTier: $subscriptionTier, subscriptionStatus: $subscriptionStatus, subscriptionExpiresAt: $subscriptionExpiresAt, stripeCustomerId: $stripeCustomerId, stripeSubscriptionId: $stripeSubscriptionId, usage: $usage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStatusImpl &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            (identical(other.subscriptionStatus, subscriptionStatus) ||
                other.subscriptionStatus == subscriptionStatus) &&
            (identical(other.subscriptionExpiresAt, subscriptionExpiresAt) ||
                other.subscriptionExpiresAt == subscriptionExpiresAt) &&
            (identical(other.stripeCustomerId, stripeCustomerId) ||
                other.stripeCustomerId == stripeCustomerId) &&
            (identical(other.stripeSubscriptionId, stripeSubscriptionId) ||
                other.stripeSubscriptionId == stripeSubscriptionId) &&
            (identical(other.usage, usage) || other.usage == usage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    subscriptionTier,
    subscriptionStatus,
    subscriptionExpiresAt,
    stripeCustomerId,
    stripeSubscriptionId,
    usage,
  );

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      __$$SubscriptionStatusImplCopyWithImpl<_$SubscriptionStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionStatusImplToJson(this);
  }
}

abstract class _SubscriptionStatus implements SubscriptionStatus {
  const factory _SubscriptionStatus({
    required final String subscriptionTier,
    required final String subscriptionStatus,
    final DateTime? subscriptionExpiresAt,
    final String? stripeCustomerId,
    final String? stripeSubscriptionId,
    final UsageStats? usage,
  }) = _$SubscriptionStatusImpl;

  factory _SubscriptionStatus.fromJson(Map<String, dynamic> json) =
      _$SubscriptionStatusImpl.fromJson;

  /// User's subscription tier (FREE or PREMIUM)
  @override
  String get subscriptionTier;

  /// Current subscription status (ACTIVE, CANCELLED, EXPIRED, TRIALING)
  @override
  String get subscriptionStatus;

  /// When the subscription expires (null for FREE or unlimited)
  @override
  DateTime? get subscriptionExpiresAt;

  /// Stripe customer ID (null for FREE users)
  @override
  String? get stripeCustomerId;

  /// Stripe subscription ID (null for FREE users)
  @override
  String? get stripeSubscriptionId;

  /// Usage statistics for the current period
  @override
  UsageStats? get usage;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UsageStats _$UsageStatsFromJson(Map<String, dynamic> json) {
  return _UsageStats.fromJson(json);
}

/// @nodoc
mixin _$UsageStats {
  /// Number of messages used today
  int get messagesUsed => throw _privateConstructorUsedError;

  /// Number of voice minutes used today
  int get voiceMinutesUsed => throw _privateConstructorUsedError;

  /// Total number of photos stored
  int get photosStored => throw _privateConstructorUsedError;

  /// Message limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  int? get messageLimit => throw _privateConstructorUsedError;

  /// Voice minutes limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  int? get voiceLimit => throw _privateConstructorUsedError;

  /// Photo storage limit for current tier (100 for FREE, null/unlimited for PREMIUM)
  int? get photoLimit => throw _privateConstructorUsedError;

  /// When the daily usage counters reset (midnight UTC)
  DateTime? get resetTime => throw _privateConstructorUsedError;

  /// Serializes this UsageStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UsageStatsCopyWith<UsageStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UsageStatsCopyWith<$Res> {
  factory $UsageStatsCopyWith(
    UsageStats value,
    $Res Function(UsageStats) then,
  ) = _$UsageStatsCopyWithImpl<$Res, UsageStats>;
  @useResult
  $Res call({
    int messagesUsed,
    int voiceMinutesUsed,
    int photosStored,
    int? messageLimit,
    int? voiceLimit,
    int? photoLimit,
    DateTime? resetTime,
  });
}

/// @nodoc
class _$UsageStatsCopyWithImpl<$Res, $Val extends UsageStats>
    implements $UsageStatsCopyWith<$Res> {
  _$UsageStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messagesUsed = null,
    Object? voiceMinutesUsed = null,
    Object? photosStored = null,
    Object? messageLimit = freezed,
    Object? voiceLimit = freezed,
    Object? photoLimit = freezed,
    Object? resetTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            messagesUsed: null == messagesUsed
                ? _value.messagesUsed
                : messagesUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            voiceMinutesUsed: null == voiceMinutesUsed
                ? _value.voiceMinutesUsed
                : voiceMinutesUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            photosStored: null == photosStored
                ? _value.photosStored
                : photosStored // ignore: cast_nullable_to_non_nullable
                      as int,
            messageLimit: freezed == messageLimit
                ? _value.messageLimit
                : messageLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            voiceLimit: freezed == voiceLimit
                ? _value.voiceLimit
                : voiceLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            photoLimit: freezed == photoLimit
                ? _value.photoLimit
                : photoLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            resetTime: freezed == resetTime
                ? _value.resetTime
                : resetTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UsageStatsImplCopyWith<$Res>
    implements $UsageStatsCopyWith<$Res> {
  factory _$$UsageStatsImplCopyWith(
    _$UsageStatsImpl value,
    $Res Function(_$UsageStatsImpl) then,
  ) = __$$UsageStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int messagesUsed,
    int voiceMinutesUsed,
    int photosStored,
    int? messageLimit,
    int? voiceLimit,
    int? photoLimit,
    DateTime? resetTime,
  });
}

/// @nodoc
class __$$UsageStatsImplCopyWithImpl<$Res>
    extends _$UsageStatsCopyWithImpl<$Res, _$UsageStatsImpl>
    implements _$$UsageStatsImplCopyWith<$Res> {
  __$$UsageStatsImplCopyWithImpl(
    _$UsageStatsImpl _value,
    $Res Function(_$UsageStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UsageStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messagesUsed = null,
    Object? voiceMinutesUsed = null,
    Object? photosStored = null,
    Object? messageLimit = freezed,
    Object? voiceLimit = freezed,
    Object? photoLimit = freezed,
    Object? resetTime = freezed,
  }) {
    return _then(
      _$UsageStatsImpl(
        messagesUsed: null == messagesUsed
            ? _value.messagesUsed
            : messagesUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        voiceMinutesUsed: null == voiceMinutesUsed
            ? _value.voiceMinutesUsed
            : voiceMinutesUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        photosStored: null == photosStored
            ? _value.photosStored
            : photosStored // ignore: cast_nullable_to_non_nullable
                  as int,
        messageLimit: freezed == messageLimit
            ? _value.messageLimit
            : messageLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        voiceLimit: freezed == voiceLimit
            ? _value.voiceLimit
            : voiceLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        photoLimit: freezed == photoLimit
            ? _value.photoLimit
            : photoLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        resetTime: freezed == resetTime
            ? _value.resetTime
            : resetTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UsageStatsImpl implements _UsageStats {
  const _$UsageStatsImpl({
    this.messagesUsed = 0,
    this.voiceMinutesUsed = 0,
    this.photosStored = 0,
    this.messageLimit,
    this.voiceLimit,
    this.photoLimit,
    this.resetTime,
  });

  factory _$UsageStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UsageStatsImplFromJson(json);

  /// Number of messages used today
  @override
  @JsonKey()
  final int messagesUsed;

  /// Number of voice minutes used today
  @override
  @JsonKey()
  final int voiceMinutesUsed;

  /// Total number of photos stored
  @override
  @JsonKey()
  final int photosStored;

  /// Message limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  @override
  final int? messageLimit;

  /// Voice minutes limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  @override
  final int? voiceLimit;

  /// Photo storage limit for current tier (100 for FREE, null/unlimited for PREMIUM)
  @override
  final int? photoLimit;

  /// When the daily usage counters reset (midnight UTC)
  @override
  final DateTime? resetTime;

  @override
  String toString() {
    return 'UsageStats(messagesUsed: $messagesUsed, voiceMinutesUsed: $voiceMinutesUsed, photosStored: $photosStored, messageLimit: $messageLimit, voiceLimit: $voiceLimit, photoLimit: $photoLimit, resetTime: $resetTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UsageStatsImpl &&
            (identical(other.messagesUsed, messagesUsed) ||
                other.messagesUsed == messagesUsed) &&
            (identical(other.voiceMinutesUsed, voiceMinutesUsed) ||
                other.voiceMinutesUsed == voiceMinutesUsed) &&
            (identical(other.photosStored, photosStored) ||
                other.photosStored == photosStored) &&
            (identical(other.messageLimit, messageLimit) ||
                other.messageLimit == messageLimit) &&
            (identical(other.voiceLimit, voiceLimit) ||
                other.voiceLimit == voiceLimit) &&
            (identical(other.photoLimit, photoLimit) ||
                other.photoLimit == photoLimit) &&
            (identical(other.resetTime, resetTime) ||
                other.resetTime == resetTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    messagesUsed,
    voiceMinutesUsed,
    photosStored,
    messageLimit,
    voiceLimit,
    photoLimit,
    resetTime,
  );

  /// Create a copy of UsageStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UsageStatsImplCopyWith<_$UsageStatsImpl> get copyWith =>
      __$$UsageStatsImplCopyWithImpl<_$UsageStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UsageStatsImplToJson(this);
  }
}

abstract class _UsageStats implements UsageStats {
  const factory _UsageStats({
    final int messagesUsed,
    final int voiceMinutesUsed,
    final int photosStored,
    final int? messageLimit,
    final int? voiceLimit,
    final int? photoLimit,
    final DateTime? resetTime,
  }) = _$UsageStatsImpl;

  factory _UsageStats.fromJson(Map<String, dynamic> json) =
      _$UsageStatsImpl.fromJson;

  /// Number of messages used today
  @override
  int get messagesUsed;

  /// Number of voice minutes used today
  @override
  int get voiceMinutesUsed;

  /// Total number of photos stored
  @override
  int get photosStored;

  /// Message limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  @override
  int? get messageLimit;

  /// Voice minutes limit for current tier (10 for FREE, null/unlimited for PREMIUM)
  @override
  int? get voiceLimit;

  /// Photo storage limit for current tier (100 for FREE, null/unlimited for PREMIUM)
  @override
  int? get photoLimit;

  /// When the daily usage counters reset (midnight UTC)
  @override
  DateTime? get resetTime;

  /// Create a copy of UsageStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UsageStatsImplCopyWith<_$UsageStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
