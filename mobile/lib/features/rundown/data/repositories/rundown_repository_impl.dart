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

  @override
  Future<Rundown> createRundown({
    required int eventId,
    required String kegiatan,
    required DateTime waktuMulai,
    required DateTime waktuSelesai,
    String? pic,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.eventRundowns(eventId),
        data: {
          'judul_sesi': kegiatan,
          'waktu_mulai': waktuMulai.toIso8601String(),
          'waktu_selesai': waktuSelesai.toIso8601String(),
          'urutan': 1,
          if (pic != null && pic.isNotEmpty) 'deskripsi': 'PIC: $pic',
        },
      );
      return Rundown.fromJson(response.data['data']['rundown'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteRundown(int id) async {
    try {
      await _dio.delete(ApiEndpoints.rundown(id));
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Rundown> updateRundown({
    required int id,
    required String kegiatan,
    required DateTime waktuMulai,
    required DateTime waktuSelesai,
    String? pic,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.rundown(id),
        data: {
          'judul_sesi': kegiatan,
          'waktu_mulai': waktuMulai.toIso8601String(),
          'waktu_selesai': waktuSelesai.toIso8601String(),
          if (pic != null && pic.isNotEmpty) 'deskripsi': 'PIC: $pic',
        },
      );
      return Rundown.fromJson(response.data['data']['rundown'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
