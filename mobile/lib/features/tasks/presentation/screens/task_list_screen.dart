import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/paginated_list.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';
import 'package:eventsync_mobile/features/tasks/presentation/providers/task_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  /// If provided, lists tasks for a specific event. Otherwise, lists 'My Tasks'.
  final int? eventId;

  const TaskListScreen({super.key, this.eventId});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  late final TaskListParams _params;

  @override
  void initState() {
    super.initState();
    _params = TaskListParams(
      eventId: widget.eventId,
      myTasksOnly: widget.eventId == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskListNotifierProvider(_params));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Tugas Saya' : 'Tugas Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Filter
            },
          ),
        ],
      ),
      body: PaginatedListView<Task>(
        items: state.tasks,
        isLoading: state.isLoading,
        hasNextPage: state.hasNextPage,
        errorMessage: state.errorMessage,
        onFetchNextPage: () => ref
            .read(taskListNotifierProvider(_params).notifier)
            .fetchNextPage(),
        onRefresh: () => ref
            .read(taskListNotifierProvider(_params).notifier)
            .fetchFirstPage(),
        emptyState: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rounded,
                size: 64, color: AppColors.textSecondary),
            Gap(16),
            Text('Belum ada tugas',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        itemBuilder: (context, task) => _TaskCard(task: task),
      ),
      floatingActionButton: widget.eventId != null
          ? Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(currentUserProvider);
                if (user?.role == 'admin' || user?.role == 'ketua') {
                  return FloatingActionButton.extended(
                    onPressed: () => context.push('/events/${widget.eventId}/tasks/new'),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.add_task, color: Colors.white),
                    label: const Text('Buat Tugas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : null,
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return GestureDetector(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.judul,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                StatusBadge(status: task.status),
              ],
            ),
            const Gap(8),
            Text(
              task.deskripsi ?? 'Tidak ada deskripsi',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(12),
            const Divider(),
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriorityBadge(priority: task.prioritas),
                if (task.deadline != null)
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const Gap(4),
                      Text(
                        dateFormat.format(task.deadline!),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
