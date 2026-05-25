import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/paginated_list.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/presentation/providers/event_provider.dart';

class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Daftar Event'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {
              // TODO: Implement filter bottom sheet (Status)
            },
          ),
        ],
      ),
      body: PaginatedListView<Event>(
        items: state.events,
        isLoading: state.isLoading,
        hasNextPage: state.hasNextPage,
        errorMessage: state.errorMessage,
        onFetchNextPage: () =>
            ref.read(eventListNotifierProvider.notifier).fetchNextPage(),
        onRefresh: () =>
            ref.read(eventListNotifierProvider.notifier).fetchFirstPage(),
        emptyState: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendar,
                size: 64, color: AppColors.textSecondary),
            Gap(16),
            Text('Belum ada event',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        itemBuilder: (context, event) => _EventCard(event: event),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.namaEvent,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                StatusBadge(status: event.status),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 16, color: AppColors.textSecondary),
                const Gap(8),
                Expanded(
                  child: Text(
                    event.lokasi ?? 'Tidak ada lokasi',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Gap(8),
            Row(
              children: [
                const Icon(LucideIcons.calendar,
                    size: 16, color: AppColors.textSecondary),
                const Gap(8),
                Text(
                  '${dateFormat.format(event.tanggalMulai)} - ${dateFormat.format(event.tanggalSelesai)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
