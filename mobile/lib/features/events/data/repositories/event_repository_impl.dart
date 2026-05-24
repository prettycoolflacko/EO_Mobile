import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final Dio _dio;

  EventRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.events,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'q': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      return ApiResponse<List<Event>>.fromJson(
        response.data,
        (json) => (json['events'] as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Event> getEventDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.event(id));
      return Event.fromJson(response.data['data']['event'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
