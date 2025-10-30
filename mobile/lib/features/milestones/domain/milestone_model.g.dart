// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      id: json['id'] as String,
      type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
      name: json['name'] as String,
      achievedDate: DateTime.parse(json['achievedDate'] as String),
      notes: json['notes'] as String?,
      photoUrls:
          (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aiSuggested: json['aiSuggested'] as bool? ?? false,
      confirmed: json['confirmed'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MilestoneTypeEnumMap[instance.type]!,
      'name': instance.name,
      'achievedDate': instance.achievedDate.toIso8601String(),
      'notes': instance.notes,
      'photoUrls': instance.photoUrls,
      'aiSuggested': instance.aiSuggested,
      'confirmed': instance.confirmed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MilestoneTypeEnumMap = {
  MilestoneType.physical: 'PHYSICAL',
  MilestoneType.feeding: 'FEEDING',
  MilestoneType.sleep: 'SLEEP',
  MilestoneType.social: 'SOCIAL',
  MilestoneType.health: 'HEALTH',
};

_$MilestoneListResponseImpl _$$MilestoneListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MilestoneListResponseImpl(
  milestones: (json['milestones'] as List<dynamic>)
      .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$MilestoneListResponseImplToJson(
  _$MilestoneListResponseImpl instance,
) => <String, dynamic>{
  'milestones': instance.milestones,
  'count': instance.count,
};

_$MilestoneSuggestionImpl _$$MilestoneSuggestionImplFromJson(
  Map<String, dynamic> json,
) => _$MilestoneSuggestionImpl(
  type: $enumDecode(_$MilestoneTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  ageRangeMonths: AgeRange.fromJson(
    json['ageRangeMonths'] as Map<String, dynamic>,
  ),
  aiSuggested: json['aiSuggested'] as bool? ?? true,
);

Map<String, dynamic> _$$MilestoneSuggestionImplToJson(
  _$MilestoneSuggestionImpl instance,
) => <String, dynamic>{
  'type': _$MilestoneTypeEnumMap[instance.type]!,
  'name': instance.name,
  'description': instance.description,
  'ageRangeMonths': instance.ageRangeMonths,
  'aiSuggested': instance.aiSuggested,
};

_$AgeRangeImpl _$$AgeRangeImplFromJson(Map<String, dynamic> json) =>
    _$AgeRangeImpl(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$$AgeRangeImplToJson(_$AgeRangeImpl instance) =>
    <String, dynamic>{'min': instance.min, 'max': instance.max};

_$MilestoneSuggestionsResponseImpl _$$MilestoneSuggestionsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$MilestoneSuggestionsResponseImpl(
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => MilestoneSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$MilestoneSuggestionsResponseImplToJson(
  _$MilestoneSuggestionsResponseImpl instance,
) => <String, dynamic>{
  'suggestions': instance.suggestions,
  'count': instance.count,
};
