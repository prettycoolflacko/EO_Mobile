import 'dart:io';
import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/chat/domain/entities/chat_message.dart';
import 'package:eventsync_mobile/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;

  ChatRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<ChatMessage>>> getChatMessages({
    required int eventId,
    String? divisi,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.realtimeEventChat(eventId),
        queryParameters: {
          if (divisi != null) 'divisi': divisi,
          'limit': limit,
        },
      );

      return ApiResponse<List<ChatMessage>>.fromJson(
        response.data,
        (json) => (json['messages'] as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required int eventId,
    required String pesan,
    String? divisi,
    File? lampiran,
  }) async {
    try {
      late dynamic data;

      if (lampiran != null) {
        // Multipart request for file upload
        data = FormData.fromMap({
          'event_id': eventId,
          'pesan': pesan,
          if (divisi != null) 'divisi': divisi,
          'lampiran': await MultipartFile.fromFile(lampiran.path),
        });
      } else {
        // Normal JSON request
        data = {
          'event_id': eventId,
          'pesan': pesan,
          if (divisi != null) 'divisi': divisi,
        };
      }

      final response = await _dio.post(
        ApiEndpoints.realtimeChatMessages,
        data: data,
      );

      return ChatMessage.fromJson(response.data['data']['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
