/// Conversation session model representing a chat history session.
/// Contains metadata about the conversation including preview and timestamps.
library;

/// Represents a conversation session with metadata.
/// Each conversation has a unique sessionId and contains multiple messages.
class Conversation {
  /// Unique identifier for this conversation session
  final String sessionId;

  /// Number of messages in this conversation
  final int messageCount;

  /// Timestamp of the first message in this conversation
  final DateTime firstMessageAt;

  /// Timestamp of the most recent message in this conversation
  final DateTime lastMessageAt;

  /// AI-generated conversation title (e.g., "Sleep training for 4-month-old")
  /// Falls back to preview text if title hasn't been generated yet
  final String title;

  /// Preview text (first ~100 chars of the first user message)
  final String preview;

  /// Type of the preview message (TEXT, VOICE, or IMAGE)
  final String previewType;

  /// AI-generated conversation summary for semantic search (optional)
  /// Contains 2-3 sentence summary with keywords
  final String? summary;

  /// Constructor with all required fields
  const Conversation({
    required this.sessionId,
    required this.messageCount,
    required this.firstMessageAt,
    required this.lastMessageAt,
    required this.title,
    required this.preview,
    required this.previewType,
    this.summary,
  });

  /// Creates a Conversation from JSON data (from API response)
  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Use title if available, otherwise fall back to preview
    final title = json['title'] as String? ?? json['preview'] as String;

    return Conversation(
      sessionId: json['sessionId'] as String,
      messageCount: json['messageCount'] as int,
      firstMessageAt: DateTime.parse(json['firstMessageAt'] as String),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      title: title,
      preview: json['preview'] as String,
      previewType: json['previewType'] as String? ?? 'TEXT',
      summary: json['summary'] as String?,
    );
  }

  /// Converts this Conversation to JSON (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messageCount': messageCount,
      'firstMessageAt': firstMessageAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'title': title,
      'preview': preview,
      'previewType': previewType,
      'summary': summary,
    };
  }

  /// Returns a formatted string for the last message time (e.g., "2 hours ago")
  String get formattedLastMessageTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inDays > 7) {
      // More than a week ago - show date
      return '${lastMessageAt.month}/${lastMessageAt.day}/${lastMessageAt.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Just now
      return 'Just now';
    }
  }
}
