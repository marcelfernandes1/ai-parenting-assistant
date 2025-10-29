// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ChatMessageImpl(
  id: json['id'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  contentType: $enumDecode(_$MessageContentTypeEnumMap, json['contentType']),
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  mediaUrls:
      (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tokensUsed: (json['tokensUsed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'contentType': _$MessageContentTypeEnumMap[instance.contentType]!,
      'sessionId': instance.sessionId,
      'timestamp': instance.timestamp.toIso8601String(),
      'mediaUrls': instance.mediaUrls,
      'tokensUsed': instance.tokensUsed,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'USER',
  MessageRole.assistant: 'ASSISTANT',
};

const _$MessageContentTypeEnumMap = {
  MessageContentType.text: 'TEXT',
  MessageContentType.voice: 'VOICE',
  MessageContentType.image: 'IMAGE',
};
