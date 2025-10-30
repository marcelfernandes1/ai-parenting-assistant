// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionStatusImpl _$$SubscriptionStatusImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionStatusImpl(
  subscriptionTier: json['subscriptionTier'] as String,
  subscriptionStatus: json['subscriptionStatus'] as String,
  subscriptionExpiresAt: json['subscriptionExpiresAt'] == null
      ? null
      : DateTime.parse(json['subscriptionExpiresAt'] as String),
  stripeCustomerId: json['stripeCustomerId'] as String?,
  stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
  usage: json['usage'] == null
      ? null
      : UsageStats.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SubscriptionStatusImplToJson(
  _$SubscriptionStatusImpl instance,
) => <String, dynamic>{
  'subscriptionTier': instance.subscriptionTier,
  'subscriptionStatus': instance.subscriptionStatus,
  'subscriptionExpiresAt': instance.subscriptionExpiresAt?.toIso8601String(),
  'stripeCustomerId': instance.stripeCustomerId,
  'stripeSubscriptionId': instance.stripeSubscriptionId,
  'usage': instance.usage,
};

_$UsageStatsImpl _$$UsageStatsImplFromJson(Map<String, dynamic> json) =>
    _$UsageStatsImpl(
      messagesUsed: (json['messagesUsed'] as num?)?.toInt() ?? 0,
      voiceMinutesUsed: (json['voiceMinutesUsed'] as num?)?.toInt() ?? 0,
      photosStored: (json['photosStored'] as num?)?.toInt() ?? 0,
      messageLimit: (json['messageLimit'] as num?)?.toInt(),
      voiceLimit: (json['voiceLimit'] as num?)?.toInt(),
      photoLimit: (json['photoLimit'] as num?)?.toInt(),
      resetTime: json['resetTime'] == null
          ? null
          : DateTime.parse(json['resetTime'] as String),
    );

Map<String, dynamic> _$$UsageStatsImplToJson(_$UsageStatsImpl instance) =>
    <String, dynamic>{
      'messagesUsed': instance.messagesUsed,
      'voiceMinutesUsed': instance.voiceMinutesUsed,
      'photosStored': instance.photosStored,
      'messageLimit': instance.messageLimit,
      'voiceLimit': instance.voiceLimit,
      'photoLimit': instance.photoLimit,
      'resetTime': instance.resetTime?.toIso8601String(),
    };
