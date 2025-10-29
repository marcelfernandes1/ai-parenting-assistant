/// Chat message model with Freezed for immutability.
/// Represents a single message in the chat conversation.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

// Generated file imports (will be created by build_runner)
part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Message role enum - who sent the message
enum MessageRole {
  @JsonValue('USER')
  user,
  @JsonValue('ASSISTANT')
  assistant,
}

/// Message content type enum
enum MessageContentType {
  @JsonValue('TEXT')
  text,
  @JsonValue('VOICE')
  voice,
  @JsonValue('IMAGE')
  image,
}

/// Immutable chat message model using Freezed
/// Contains all data for a single message in the conversation
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    /// Unique message identifier from backend
    required String id,

    /// Message role (USER or ASSISTANT)
    required MessageRole role,

    /// Message text content
    required String content,

    /// Content type (TEXT, VOICE, IMAGE)
    required MessageContentType contentType,

    /// Session ID for grouping messages
    required String sessionId,

    /// Message timestamp
    required DateTime timestamp,

    /// Media URLs (for voice/image messages)
    @Default([]) List<String> mediaUrls,

    /// Tokens used (for AI responses only)
    @Default(0) int tokensUsed,
  }) = _ChatMessage;

  /// Factory constructor for creating ChatMessage from JSON
  /// Used when deserializing API responses
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
