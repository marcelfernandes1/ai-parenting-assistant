// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String?,
  name: json['name'] as String?,
  subscriptionTier: json['subscriptionTier'] as String? ?? 'FREE',
  onboardingComplete: json['onboardingComplete'] as bool? ?? false,
  mode: json['mode'] as String?,
  babyName: json['babyName'] as String?,
  babyBirthDate: json['babyBirthDate'] as String?,
  parentingPhilosophy: json['parentingPhilosophy'] as String?,
  religiousViews: json['religiousViews'] as String?,
  primaryConcerns: (json['primaryConcerns'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'subscriptionTier': instance.subscriptionTier,
      'onboardingComplete': instance.onboardingComplete,
      'mode': instance.mode,
      'babyName': instance.babyName,
      'babyBirthDate': instance.babyBirthDate,
      'parentingPhilosophy': instance.parentingPhilosophy,
      'religiousViews': instance.religiousViews,
      'primaryConcerns': instance.primaryConcerns,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
