import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventsync_mobile/features/events/presentation/providers/event_provider.dart';
import 'package:eventsync_mobile/features/tasks/presentation/providers/task_provider.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final eventsState = ref.watch(eventListNotifierProvider);
    final tasksState = ref.watch(taskListNotifierProvider(const TaskListParams(myTasksOnly: true)));

    // For quick stats
    final taskCount = tasksState.tasks.where((t) => t.status != 'selesai').length;
    final eventCount = eventsState.events.length;
    
    // Urgent tasks and active events
    final urgentTasks = tasksState.tasks.where((t) => t.status != 'selesai').take(3).toList();
    final activeEvents = eventsState.events.where((e) => e.status != 'selesai').take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(authStateProvider.notifier).refreshUser();
            ref.read(eventListNotifierProvider.notifier).fetchFirstPage();
            ref.read(taskListNotifierProvider(const TaskListParams(myTasksOnly: true)).notifier).fetchFirstPage();
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withAlpha(50),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? 'User'}!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            Text(
                              user?.divisi ?? user?.role ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(
                          LucideIcons.bell,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverGap(24),

              // Quick stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Ringkasan Hari Ini',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
              ),

              const SliverGap(12),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _StatCard(
                        icon: LucideIcons.checkSquare,
                        label: 'Tugas Aktif',
                        value: tasksState.isLoading ? '-' : taskCount.toString(),
                        color: AppColors.primary,
                        onTap: () => context.go('/tasks'),
                      ),
                      const Gap(12),
                      _StatCard(
                        icon: LucideIcons.calendar,
                        label: 'Event Aktif',
                        value: eventsState.isLoading ? '-' : eventCount.toString(),
                        color: AppColors.success,
                        onTap: () => context.go('/events'),
                      ),
                      const Gap(12),
                      const _StatCard(
                        icon: LucideIcons.clock,
                        label: 'Rundown',
                        value: '-',
                        color: AppColors.warning,
                      ),
                      const Gap(12),
                      const _StatCard(
                        icon: LucideIcons.store,
                        label: 'Vendor',
                        value: '-',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverGap(28),

              // Admin Management Section
              if (user?.role == 'admin' || user?.role == 'ketua')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'Manajemen Khusus'),
                        const Gap(12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (user?.role == 'admin' || user?.role == 'ketua')
                              _ActionChip(
                                icon: LucideIcons.settings,
                                label: user?.role == 'admin' ? 'Kelola User' : 'Kelola Staff & Divisi',
                                color: AppColors.info,
                                onTap: () => context.push('/admin/users'),
                              ),
                            _ActionChip(
                              icon: LucideIcons.barChart3,
                              label: 'Buat Event Baru',
                              color: AppColors.primary,
                              onTap: () => context.push('/admin/events/new'),
                            ),
                          ],
                        ),
                        const Gap(28),
                      ],
                    ),
                  ),
                ),

              // Urgent Tasks
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeader(
                    title: 'Tugas Mendesak',
                    onSeeAll: () => context.go('/tasks'),
                  ),
                ),
              ),
              const SliverGap(12),
              SliverToBoxAdapter(
                child: tasksState.isLoading && tasksState.tasks.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : urgentTasks.isEmpty
                        ? const _EmptyPlaceholder(
                            icon: LucideIcons.checkCircle,
                            message: 'Tidak ada tugas mendesak',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: urgentTasks.length,
                            separatorBuilder: (_, __) => const Gap(12),
                            itemBuilder: (ctx, i) => _CompactTaskCard(task: urgentTasks[i]),
                          ),
              ),

              const SliverGap(28),

              // Upcoming Events
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeader(
                    title: 'Event Mendatang',
                    onSeeAll: () => context.go('/events'),
                  ),
                ),
              ),
              const SliverGap(12),
              SliverToBoxAdapter(
                child: eventsState.isLoading && eventsState.events.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : activeEvents.isEmpty
                        ? const _EmptyPlaceholder(
                            icon: LucideIcons.calendar,
                            message: 'Tidak ada event aktif',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: activeEvents.length,
                            separatorBuilder: (_, __) => const Gap(12),
                            itemBuilder: (ctx, i) => _CompactEventCard(event: activeEvents[i]),
                          ),
              ),

              const SliverGap(40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 28),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyPlaceholder({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 40),
          const Gap(12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CompactTaskCard extends StatelessWidget {
  final Task task;

  const _CompactTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    return GestureDetector(
      onTap: () => context.push('/tasks/${task.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.judul,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (task.deadline != null) ...[
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 14, color: AppColors.error),
                        const Gap(4),
                        Text(
                          dateFormat.format(task.deadline!),
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            StatusBadge(status: task.status, fontSize: 10),
          ],
        ),
      ),
    );
  }
}

class _CompactEventCard extends StatelessWidget {
  final Event event;

  const _CompactEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return GestureDetector(
      onTap: () => context.push('/events/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.namaEvent,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.textSecondary),
                      const Gap(4),
                      Text(
                        dateFormat.format(event.tanggalMulai),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
