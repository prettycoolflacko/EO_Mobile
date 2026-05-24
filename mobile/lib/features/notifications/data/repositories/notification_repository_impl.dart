import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/notifications/domain/entities/notification_model.dart';
import 'package:eventsync_mobile/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<NotificationModel>>> getMyNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.realtimeNotifikasiMe);
      return ApiResponse<List<NotificationModel>>.fromJson(
        response.data,
        (json) => (json['notifications'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<NotificationModel> markAsRead(String id) async {
    try {
      final response = await _dio.patch(ApiEndpoints.realtimeNotifikasiRead(id));
      return NotificationModel.fromJson(response.data['data']['notification'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
