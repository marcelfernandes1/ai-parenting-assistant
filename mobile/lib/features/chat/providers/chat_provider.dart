/// Chat provider using Riverpod for state management.
/// Manages chat messages, sending messages, and loading history.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers/service_providers.dart';
import '../../../shared/exceptions/limit_reached_exception.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';

/// Provider for ChatRepository singleton
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

/// State class for chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSendingMessage;
  final String? error;
  final String sessionId;
  final LimitReachedException? limitReached; // Track when limit is hit

  ChatState({
    required this.messages,
    required this.isLoading,
    required this.isSendingMessage,
    required this.error,
    required this.sessionId,
    this.limitReached,
  });

  /// Initial state with empty messages
  factory ChatState.initial() {
    return ChatState(
      messages: [],
      isLoading: false,
      isSendingMessage: false,
      error: null,
      sessionId: const Uuid().v4(), // Generate unique session ID
      limitReached: null,
    );
  }

  /// Copy with method for state updates
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSendingMessage,
    String? error,
    String? sessionId,
    LimitReachedException? limitReached,
    bool clearLimitReached = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      limitReached: clearLimitReached ? null : (limitReached ?? this.limitReached),
    );
  }
}

/// State notifier for managing chat state and operations
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;

  ChatNotifier(this._chatRepository) : super(ChatState.initial()) {
    // Load chat history on initialization
    loadHistory();
  }

  /// Loads chat message history from backend
  /// Fetches messages for the current session
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch messages for current session
      final messages = await _chatRepository.getHistory(
        sessionId: state.sessionId,
        limit: 50,
      );

      // Reverse to show oldest first (chronological order)
      final sortedMessages = messages.reversed.toList();

      state = state.copyWith(
        messages: sortedMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sends a message and receives AI response
  /// Optimistically adds user message to UI before API call
  /// Supports optional photo URLs to be included with the message
  Future<void> sendMessage(String content, {List<String>? photoUrls}) async {
    if (content.trim().isEmpty) return;

    // Set sending state
    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      // Call API to send message
      final result = await _chatRepository.sendMessage(
        content: content.trim(),
        sessionId: state.sessionId,
        photoUrls: photoUrls,
      );

      // Add both user and assistant messages to state
      final updatedMessages = [
        ...state.messages,
        result['userMessage']!,
        result['assistantMessage']!,
      ];

      state = state.copyWith(
        messages: updatedMessages,
        isSendingMessage: false,
      );
    } on LimitReachedException catch (e) {
      // Handle limit reached specifically - store exception for UI to show paywall
      state = state.copyWith(
        isSendingMessage: false,
        limitReached: e,
        error: e.message,
      );

      // Clear error message after 5 seconds, but keep limitReached flag
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    } catch (e) {
      // Handle other errors (e.g., network errors)
      state = state.copyWith(
        isSendingMessage: false,
        error: e.toString(),
      );

      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    }
  }

  /// Sends a voice message for transcription and receives AI response
  /// Uploads audio file, gets transcription, and displays both messages
  Future<void> sendVoiceMessage(String audioFilePath) async {
    // Set sending state
    state = state.copyWith(isSendingMessage: true, error: null);

    try {
      // Call API to upload and transcribe voice message
      final result = await _chatRepository.sendVoiceMessage(
        audioFilePath: audioFilePath,
        sessionId: state.sessionId,
      );

      // Add both user (voice) and assistant (text) messages to state
      final updatedMessages = [
        ...state.messages,
        result['userMessage'] as ChatMessage,
        result['assistantMessage'] as ChatMessage,
      ];

      state = state.copyWith(
        messages: updatedMessages,
        isSendingMessage: false,
      );
    } on LimitReachedException catch (e) {
      // Handle limit reached specifically - store exception for UI to show paywall
      state = state.copyWith(
        isSendingMessage: false,
        limitReached: e,
        error: e.message,
      );

      // Clear error message after 5 seconds, but keep limitReached flag
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    } catch (e) {
      // Handle other errors (e.g., transcription failed, network errors)
      state = state.copyWith(
        isSendingMessage: false,
        error: e.toString(),
      );

      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    }
  }

  /// Starts a new conversation by clearing messages and generating new session ID
  Future<void> newConversation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Delete old session on backend
      await _chatRepository.deleteSession(state.sessionId);

      // Generate new session ID and clear messages
      state = ChatState.initial();
    } catch (e) {
      // Even if delete fails, start new session locally
      state = ChatState.initial();
    }
  }

  /// Loads a specific conversation by sessionId
  /// Used when user selects a past conversation from history
  Future<void> loadConversation(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Update session ID first
      state = state.copyWith(sessionId: sessionId);

      // Fetch messages for the selected session
      final messages = await _chatRepository.getHistory(
        sessionId: sessionId,
        limit: 50,
      );

      // Reverse to show oldest first (chronological order)
      final sortedMessages = messages.reversed.toList();

      state = state.copyWith(
        messages: sortedMessages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refreshes the chat history
  Future<void> refresh() async {
    await loadHistory();
  }

  /// Clears the limit reached flag
  /// Call this after user dismisses paywall or upgrades to premium
  void clearLimitReached() {
    state = state.copyWith(clearLimitReached: true);
  }
}

/// Main chat provider
/// Watch this provider to react to chat state changes
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider));
});

/// Usage state class
class UsageState {
  final int messagesUsed;
  final double voiceMinutesUsed;
  final int photosStored;
  final bool isLoading;
  final String? error;

  UsageState({
    required this.messagesUsed,
    required this.voiceMinutesUsed,
    required this.photosStored,
    required this.isLoading,
    required this.error,
  });

  factory UsageState.initial() {
    return UsageState(
      messagesUsed: 0,
      voiceMinutesUsed: 0.0,
      photosStored: 0,
      isLoading: false,
      error: null,
    );
  }

  UsageState copyWith({
    int? messagesUsed,
    double? voiceMinutesUsed,
    int? photosStored,
    bool? isLoading,
    String? error,
  }) {
    return UsageState(
      messagesUsed: messagesUsed ?? this.messagesUsed,
      voiceMinutesUsed: voiceMinutesUsed ?? this.voiceMinutesUsed,
      photosStored: photosStored ?? this.photosStored,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State notifier for usage tracking
class UsageNotifier extends StateNotifier<UsageState> {
  final ChatRepository _chatRepository;

  UsageNotifier(this._chatRepository) : super(UsageState.initial()) {
    // Load usage on initialization
    loadUsage();
  }

  /// Loads today's usage statistics
  Future<void> loadUsage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final usage = await _chatRepository.getTodayUsage();

      state = state.copyWith(
        messagesUsed: usage['messagesUsed'] as int,
        voiceMinutesUsed: usage['voiceMinutesUsed'] as double,
        photosStored: usage['photosStored'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refreshes usage data
  Future<void> refresh() async {
    await loadUsage();
  }
}

/// Usage tracking provider
final usageProvider = StateNotifierProvider<UsageNotifier, UsageState>((ref) {
  return UsageNotifier(ref.watch(chatRepositoryProvider));
});
