import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:eventsync_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:eventsync_mobile/features/chat/domain/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(dio: ref.watch(dioProvider));
});

class ChatParams {
  final int eventId;
  final String? divisi;

  const ChatParams({required this.eventId, this.divisi});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatParams &&
        other.eventId == eventId &&
        other.divisi == divisi;
  }

  @override
  int get hashCode => eventId.hashCode ^ divisi.hashCode;
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool isSending;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSending = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? isSending,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Provider for managing chat messages with POLLING since backend has no websockets.
final chatNotifierProvider = StateNotifierProvider.family<ChatNotifier, ChatState, ChatParams>((ref, params) {
  return ChatNotifier(ref.watch(chatRepositoryProvider), params);
});

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final ChatParams _params;
  Timer? _pollingTimer;

  ChatNotifier(this._repository, this._params) : super(const ChatState()) {
    fetchMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 5 seconds as recommended in backend docs for realtime simulation
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollMessagesSilently();
    });
  }

  Future<void> fetchMessages() async {
    if (state.messages.isEmpty) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    
    try {
      final response = await _repository.getChatMessages(
        eventId: _params.eventId,
        divisi: _params.divisi,
      );
      
      state = state.copyWith(
        isLoading: false,
        messages: response.data ?? [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _pollMessagesSilently() async {
    try {
      final response = await _repository.getChatMessages(
        eventId: _params.eventId,
        divisi: _params.divisi,
      );
      
      // Only update state if new messages arrived to prevent unnecessary rebuilds
      final newMessages = response.data ?? [];
      if (newMessages.length != state.messages.length || 
          (newMessages.isNotEmpty && state.messages.isNotEmpty && 
           newMessages.first.id != state.messages.first.id)) {
        state = state.copyWith(messages: newMessages);
      }
    } catch (_) {
      // Ignore errors during silent polling to avoid spamming the UI with errors
    }
  }

  Future<void> sendMessage(String text, {File? file}) async {
    if (text.trim().isEmpty && file == null) return;

    state = state.copyWith(isSending: true);
    
    try {
      final newMessage = await _repository.sendMessage(
        eventId: _params.eventId,
        pesan: text.trim(),
        divisi: _params.divisi,
        lampiran: file,
      );

      // Optimistically add to top of list (assuming list is sorted newest first)
      state = state.copyWith(
        isSending: false,
        messages: [newMessage, ...state.messages],
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}
