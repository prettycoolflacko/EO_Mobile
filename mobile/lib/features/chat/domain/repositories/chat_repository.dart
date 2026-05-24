import 'dart:io';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<ApiResponse<List<ChatMessage>>> getChatMessages({
    required int eventId,
    String? divisi,
    int limit = 50,
  });

  Future<ChatMessage> sendMessage({
    required int eventId,
    required String pesan,
    String? divisi,
    File? lampiran,
  });
}
