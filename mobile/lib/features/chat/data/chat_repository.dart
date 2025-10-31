/// Chat repository for handling all chat-related API calls.
/// Provides methods for sending messages, fetching history, and managing sessions.
library;

import 'package:dio/dio.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_config.dart';
import '../../../shared/exceptions/limit_reached_exception.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';

/// Repository class handling chat API calls and session management.
/// Uses ApiClient for network requests with automatic authentication.
class ChatRepository {
  final ApiClient _apiClient;

  /// Constructor accepts ApiClient dependency
  ChatRepository(this._apiClient);

  /// Sends a message and receives AI response.
  ///
  /// Parameters:
  /// - content: The message text to send
  /// - sessionId: The conversation session ID
  ///
  /// Returns: Both the user message and assistant response
  /// Throws: DioException on network errors, Exception on other errors
  Future<Map<String, ChatMessage>> sendMessage({
    required String content,
    required String sessionId,
    List<String>? photoUrls,  // Optional photo URLs array
  }) async {
    try {
      // Build request data
      final requestData = <String, dynamic>{
        'content': content,
        'sessionId': sessionId,
      };

      // Add photoUrls if provided
      if (photoUrls != null && photoUrls.isNotEmpty) {
        requestData['photoUrls'] = photoUrls;
      }

      // Call backend chat endpoint
      final response = await _apiClient.post(
        ApiConfig.sendMessageEndpoint,
        data: requestData,
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = response.data;

        // Parse user and assistant messages from response
        // Backend now returns contentType and mediaUrls correctly
        final userMessage = ChatMessage.fromJson({
          ...data['userMessage'],
          'role': 'USER',
          'sessionId': sessionId,
          // Use contentType from backend if available, fallback to TEXT
          'contentType': data['userMessage']['contentType'] ?? 'TEXT',
          // Use mediaUrls from backend if available, fallback to empty array
          'mediaUrls': data['userMessage']['mediaUrls'] ?? [],
        });

        final assistantMessage = ChatMessage.fromJson({
          ...data['assistantMessage'],
          'role': 'ASSISTANT',
          'sessionId': sessionId,
          'contentType': data['assistantMessage']['contentType'] ?? 'TEXT',
          'mediaUrls': data['assistantMessage']['mediaUrls'] ?? [],
        });

        return {
          'userMessage': userMessage,
          'assistantMessage': assistantMessage,
        };
      } else if (response.statusCode == 429) {
        // Daily limit reached - throw custom exception with reset time
        throw LimitReachedException.fromResponse(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to send message');
      }
    } on DioException catch (e) {
      // Handle network errors
      throw _handleDioError(e);
    }
  }

  /// Fetches chat message history.
  ///
  /// Parameters:
  /// - sessionId: Optional - filter by specific session
  /// - limit: Number of messages to fetch (default: 50)
  /// - offset: Pagination offset (default: 0)
  ///
  /// Returns: List of chat messages ordered by timestamp (newest first)
  Future<List<ChatMessage>> getHistory({
    String? sessionId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (sessionId != null) {
        queryParams['sessionId'] = sessionId;
      }

      // Call backend history endpoint
      final response = await _apiClient.get(
        ApiConfig.chatMessagesEndpoint,
        queryParameters: queryParams,
      );

      // Check response status
      if (response.statusCode == 200) {
        final messages = (response.data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
            .toList();

        return messages;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to fetch history');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Deletes all messages in a conversation session.
  ///
  /// Parameters:
  /// - sessionId: The session ID to delete
  ///
  /// Returns: Number of messages deleted
  Future<int> deleteSession(String sessionId) async {
    try {
      // Call backend delete session endpoint
      final response = await _apiClient.delete(
        '/chat/session',
        data: {
          'sessionId': sessionId,
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        return response.data['deletedCount'] as int? ?? 0;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to delete session');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Sends a voice message for transcription and AI response.
  ///
  /// Parameters:
  /// - audioFilePath: Path to the recorded audio file
  /// - sessionId: The conversation session ID
  ///
  /// Returns: Map containing transcription text, user message, and assistant response
  /// Throws: DioException on network errors, Exception on other errors
  Future<Map<String, dynamic>> sendVoiceMessage({
    required String audioFilePath,
    required String sessionId,
  }) async {
    try {
      // Upload audio file using multipart form data
      final response = await _apiClient.uploadFile(
        '/chat/voice',
        audioFilePath,
        'audio',
        additionalData: {
          'sessionId': sessionId,
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = response.data;

        // Parse user voice message (with transcribed text)
        final userMessage = ChatMessage.fromJson({
          ...data['userMessage'],
          'role': 'USER',
          'contentType': 'VOICE',
          'sessionId': sessionId,
        });

        // Parse assistant text response
        final assistantMessage = ChatMessage.fromJson({
          ...data['assistantMessage'],
          'role': 'ASSISTANT',
          'contentType': 'TEXT',
          'sessionId': sessionId,
        });

        return {
          'transcription': data['transcription'] as String,
          'userMessage': userMessage,
          'assistantMessage': assistantMessage,
        };
      } else if (response.statusCode == 429) {
        // Daily limit reached - throw custom exception with reset time
        throw LimitReachedException.fromResponse(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to process voice message');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches all conversation sessions for the authenticated user.
  ///
  /// Parameters:
  /// - limit: Number of conversations to fetch (default: 20)
  /// - offset: Pagination offset (default: 0)
  ///
  /// Returns: List of conversations ordered by most recent activity
  Future<List<Conversation>> getConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      // Call backend conversations endpoint
      final response = await _apiClient.get(
        '/chat/conversations',
        queryParameters: queryParams,
      );

      // Check response status
      if (response.statusCode == 200) {
        final conversations = (response.data['conversations'] as List)
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();

        return conversations;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to fetch conversations');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs AI-powered semantic search through conversations.
  ///
  /// Parameters:
  /// - query: The search query text
  ///
  /// Returns: List of session IDs ranked by relevance (most relevant first)
  Future<List<String>> searchConversations(String query) async {
    try {
      // Call backend search endpoint
      final response = await _apiClient.post(
        '/chat/conversations/search',
        data: {
          'query': query,
        },
      );

      // Check response status
      if (response.statusCode == 200) {
        // Extract ranked session IDs from response
        final rankedSessionIds = (response.data['rankedSessionIds'] as List)
            .map((id) => id as String)
            .toList();

        return rankedSessionIds;
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to search conversations');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Gets today's usage statistics.
  ///
  /// Returns: Map containing messagesUsed, voiceMinutesUsed, photosStored
  Future<Map<String, dynamic>> getTodayUsage() async {
    try {
      // Call backend usage endpoint
      final response = await _apiClient.get(ApiConfig.usageEndpoint);

      // Check response status
      if (response.statusCode == 200) {
        return {
          'messagesUsed': response.data['messagesUsed'] as int? ?? 0,
          'voiceMinutesUsed':
              (response.data['voiceMinutesUsed'] as num?)?.toDouble() ?? 0.0,
          'photosStored': response.data['photosStored'] as int? ?? 0,
        };
      } else {
        throw Exception(
            response.data['error'] ?? 'Failed to fetch usage');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Converts DioException to user-friendly error message
  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please try again.');
    }

    // Extract error message from response
    final response = error.response;
    if (response != null && response.data is Map) {
      final errorMessage = response.data['error'] as String?;
      if (errorMessage != null) {
        return Exception(errorMessage);
      }
    }

    // Generic error message
    return Exception('An unexpected error occurred. Please try again.');
  }
}
