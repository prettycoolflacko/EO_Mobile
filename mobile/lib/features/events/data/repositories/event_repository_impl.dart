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
    int? ketuaId,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.events,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'q': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (ketuaId != null) 'ketua_id': ketuaId,
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
  @override
  Future<Event> createEvent({
    required String namaEvent,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    String? deskripsi,
    String? lokasi,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.events,
        data: {
          'nama_event': namaEvent,
          'tanggal_mulai': tanggalMulai.toIso8601String(),
          'tanggal_selesai': tanggalSelesai.toIso8601String(),
          if (deskripsi != null && deskripsi.isNotEmpty) 'deskripsi': deskripsi,
          if (lokasi != null && lokasi.isNotEmpty) 'lokasi': lokasi,
        },
      );
      return Event.fromJson(response.data['data']['event'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteEvent(int id) async {
    try {
      await _dio.delete(ApiEndpoints.event(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
