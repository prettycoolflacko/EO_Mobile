import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/rundown/domain/entities/rundown.dart';
import 'package:eventsync_mobile/features/rundown/domain/repositories/rundown_repository.dart';

class RundownRepositoryImpl implements RundownRepository {
  final Dio _dio;

  RundownRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<Rundown>>> getRundownsByEvent(int eventId) async {
    try {
      final response = await _dio.get(ApiEndpoints.eventRundowns(eventId));
      return ApiResponse<List<Rundown>>.fromJson(
        response.data,
        (json) => (json['rundowns'] as List)
            .map((e) => Rundown.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Rundown> updateRundownStatus(int id, String status) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.rundown(id),
        data: {'status': status},
      );
      return Rundown.fromJson(response.data['data']['rundown'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
