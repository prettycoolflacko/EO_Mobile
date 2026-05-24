import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';
import 'package:eventsync_mobile/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final Dio _dio;

  TaskRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<Task>>> getTasks({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? prioritas,
    int? eventId,
    int? assigneeId,
    String? divisi,
  }) async {
    try {
      // If backend doesn't have a global /tugas, we need to handle it.
      // Based on docs, GET /events/:id/tugas exists.
      // Wait, is there a GET /tugas? The requirements say:
      // "staf -> GET /tugas -> lihat tugas sendiri"
      // Wait, ROLE_ENDPOINTS.md says `GET /api/v1/tugas?assignee_id=x` for staf.
      // Let's assume `/tugas` is the correct path for global tasks.
      final path = eventId != null ? ApiEndpoints.eventTugas(eventId) : '/tugas';

      final response = await _dio.get(
        path,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'q': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (prioritas != null && prioritas.isNotEmpty) 'prioritas': prioritas,
          if (assigneeId != null) 'assignee_id': assigneeId,
          if (divisi != null && divisi.isNotEmpty) 'divisi': divisi,
        },
      );

      return ApiResponse<List<Task>>.fromJson(
        response.data,
        (json) => (json['tugas'] as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Task> getTaskDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.tugas(id));
      return Task.fromJson(response.data['data']['tugas'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Task> updateTaskStatus({
    required int id,
    required String status,
    String? catatan,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.tugasStatus(id),
        data: {
          'status': status,
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
        },
      );
      return Task.fromJson(response.data['data']['tugas'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Task> createTask({
    required int eventId,
    required int assigneeId,
    required String judul,
    required DateTime tenggatWaktu,
    required String prioritas,
    String? deskripsi,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.eventTugas(eventId),
        data: {
          'assignee_id': assigneeId,
          'judul': judul,
          'deskripsi': deskripsi ?? '',
          'tenggat_waktu': tenggatWaktu.toIso8601String(),
          'prioritas': prioritas,
        },
      );
      return Task.fromJson(response.data['data']['tugas'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
