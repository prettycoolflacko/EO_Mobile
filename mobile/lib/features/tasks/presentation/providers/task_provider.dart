import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';
import 'package:eventsync_mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

/// Provides the TaskRepository.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(dio: ref.watch(dioProvider));
});

/// Parameters for querying tasks, used as Family key.
class TaskListParams {
  final int? eventId;
  final bool myTasksOnly;

  const TaskListParams({this.eventId, this.myTasksOnly = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskListParams &&
        other.eventId == eventId &&
        other.myTasksOnly == myTasksOnly;
  }

  @override
  int get hashCode => eventId.hashCode ^ myTasksOnly.hashCode;
}

/// State class for paginated task list.
class TaskListState {
  final List<Task> tasks;
  final bool isLoading;
  final bool hasNextPage;
  final int currentPage;
  final String? errorMessage;
  final String? searchQuery;
  final String? statusFilter;
  final String? priorityFilter;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.hasNextPage = true,
    this.currentPage = 1,
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
    this.priorityFilter,
  });

  TaskListState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    bool? hasNextPage,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    String? priorityFilter,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
    );
  }
}

/// Provider for managing the paginated list of tasks, scoped by Event or MyTasks.
final taskListNotifierProvider = StateNotifierProvider.family<TaskListNotifier,
    TaskListState, TaskListParams>((ref, params) {
  final currentUserId = ref.watch(currentUserProvider)?.id;
  return TaskListNotifier(
    ref.watch(taskRepositoryProvider),
    params,
    currentUserId,
  );
});

class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;
  final TaskListParams _params;
  final int? _currentUserId;
  static const int _perPage = 10;

  TaskListNotifier(this._repository, this._params, this._currentUserId)
      : super(const TaskListState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage({
    String? search,
    String? status,
    String? prioritas,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      searchQuery: search ?? state.searchQuery,
      statusFilter: status ?? state.statusFilter,
      priorityFilter: prioritas ?? state.priorityFilter,
    );

    try {
      final response = await _repository.getTasks(
        page: 1,
        perPage: _perPage,
        search: state.searchQuery,
        status: state.statusFilter,
        prioritas: state.priorityFilter,
        eventId: _params.eventId,
        assigneeId: _params.myTasksOnly ? _currentUserId : null,
      );

      state = state.copyWith(
        isLoading: false,
        tasks: response.data ?? [],
        hasNextPage: response.meta?.hasNextPage ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasNextPage) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getTasks(
        page: nextPage,
        perPage: _perPage,
        search: state.searchQuery,
        status: state.statusFilter,
        prioritas: state.priorityFilter,
        eventId: _params.eventId,
        assigneeId: _params.myTasksOnly ? _currentUserId : null,
      );

      final newTasks = response.data ?? [];

      state = state.copyWith(
        isLoading: false,
        currentPage: nextPage,
        tasks: [...state.tasks, ...newTasks],
        hasNextPage: response.meta?.hasNextPage ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateStatus(int taskId, String status, String? catatan) async {
    try {
      final updatedTask = await _repository.updateTaskStatus(
        id: taskId,
        status: status,
        catatan: catatan,
      );

      // Update local state
      final updatedTasks = state.tasks.map((t) {
        return t.id == taskId ? updatedTask : t;
      }).toList();

      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      // Let the UI handle the error (e.g., via a Future return)
      rethrow;
    }
  }
}

/// Provider for a single task detail.
final taskDetailProvider = FutureProvider.family<Task, int>((ref, id) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskDetail(id);
});
