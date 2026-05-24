import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/presentation/providers/event_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const Gap(16),
              Text(err.toString(), style: const TextStyle(color: AppColors.error)),
              const Gap(16),
              ElevatedButton(
                onPressed: () => ref.invalidate(eventDetailProvider(eventId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (event) => _EventDetailContent(event: event),
      ),
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  final Event event;

  const _EventDetailContent({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');

    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.surface,
              actions: [
                IconButton(
                  onPressed: () => context.push('/chat/${event.id}'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                  tooltip: 'Chat Divisi',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.surface],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.namaEvent,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          StatusBadge(status: event.status),
                        ],
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
                          const Gap(8),
                          Text(
                            '${dateFormat.format(event.tanggalMulai)} - ${dateFormat.format(event.tanggalSelesai)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              event.lokasi ?? 'Tidak ada lokasi',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Rundown'),
                    Tab(text: 'Tugas'),
                    Tab(text: 'Vendor'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          children: [
            _TabPlaceholder(
              icon: Icons.schedule_rounded,
              title: 'Rundown Acara',
              actionLabel: 'Lihat Rundown',
              onAction: () => context.push('/rundown/${event.id}'),
            ),
            _TabPlaceholder(
              icon: Icons.checklist_rounded,
              title: 'Tugas Kepanitiaan',
              actionLabel: 'Lihat Semua Tugas',
              onAction: () => context.push('/events/${event.id}/tasks'),
            ),
            _TabPlaceholder(
              icon: Icons.store_rounded,
              title: 'Vendor Terlibat',
              actionLabel: 'Lihat Vendor',
              onAction: () => context.push('/vendors/${event.id}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _TabPlaceholder({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.surfaceContainer),
          const Gap(16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Gap(16),
          ElevatedButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
