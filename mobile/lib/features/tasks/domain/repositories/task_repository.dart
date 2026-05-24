import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  Future<ApiResponse<List<Task>>> getTasks({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    String? prioritas,
    int? eventId,
    int? assigneeId,
    String? divisi,
  });

  Future<Task> getTaskDetail(int id);

  Future<Task> updateTaskStatus({
    required int id,
    required String status,
    String? catatan,
  });
}
