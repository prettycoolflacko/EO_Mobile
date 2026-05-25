import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/presentation/providers/event_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

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
                Consumer(
                  builder: (context, ref, child) {
                    final user = ref.watch(currentUserProvider);
                    final isAdmin = user?.role == 'admin';
                    final isKetuaOfThisEvent = user?.role == 'ketua' && event.ketuaId == user?.id;
                    // Backend explicitly restricts event deletion to 'admin' only in routes/v1/eventRoutes.js
                    final canDelete = isAdmin;
                    final canCancel = isKetuaOfThisEvent && event.status != 'batal';

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canCancel)
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.cardDark,
                                  title: const Text('Batalkan Event'),
                                  content: Text('Batalkan event ${event.namaEvent}? Event tidak dihapus dari sistem, tapi statusnya berubah menjadi Batal.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Tidak', style: TextStyle(color: AppColors.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Batalkan', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                try {
                                  await ref.read(eventListNotifierProvider.notifier).updateEventStatus(event.id, 'batal');
                                  ref.invalidate(eventDetailProvider(event.id));
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Event berhasil dibatalkan')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Gagal membatalkan event')),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                            tooltip: 'Batalkan Event',
                          ),
                        if (canDelete)
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.cardDark,
                                  title: const Text('Hapus Event'),
                                  content: Text('Hapus event ${event.namaEvent}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                try {
                                  await ref.read(eventListNotifierProvider.notifier).deleteEvent(event.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Event berhasil dihapus')),
                                    );
                                    context.pop(); // go back to dashboard
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Gagal menghapus event')),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            tooltip: 'Hapus Event',
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  onPressed: () => context.push('/chat/${event.id}'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textPrimary),
                  tooltip: 'Chat Divisi',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                  color: AppColors.surface,
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
                          const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 16),
                          const Gap(8),
                          Text(
                            '${dateFormat.format(event.tanggalMulai)} - ${dateFormat.format(event.tanggalSelesai)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 16),
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
        body: Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(currentUserProvider);
            final isAdminOrKetua = user?.role == 'admin' || user?.role == 'ketua';

            return TabBarView(
              children: [
                _TabPlaceholder(
                  icon: Icons.schedule_rounded,
                  title: 'Rundown Acara',
                  actionLabel: 'Lihat Rundown',
                  onAction: () => context.push('/rundown/${event.id}'),
                  secondaryActionLabel: isAdminOrKetua ? '+ Buat Rundown' : null,
                  onSecondaryAction: isAdminOrKetua ? () => context.push('/rundown/${event.id}/new') : null,
                ),
                _TabPlaceholder(
                  icon: Icons.checklist_rounded,
                  title: 'Tugas Kepanitiaan',
                  actionLabel: 'Lihat Semua Tugas',
                  onAction: () => context.push('/events/${event.id}/tasks'),
                  secondaryActionLabel: isAdminOrKetua ? '+ Tambah Tugas via Email' : null,
                  onSecondaryAction: isAdminOrKetua ? () => context.push('/events/${event.id}/tasks/new') : null,
                ),
                _TabPlaceholder(
                  icon: Icons.store_rounded,
                  title: 'Vendor Terlibat',
                  actionLabel: 'Lihat Vendor',
                  onAction: () => context.push('/vendors/${event.id}'),
                  secondaryActionLabel: isAdminOrKetua ? '+ Tambah Vendor' : null,
                  onSecondaryAction: isAdminOrKetua ? () => context.push('/vendors/${event.id}/new') : null,
                ),
              ],
            );
          },
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
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const _TabPlaceholder({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
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
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const Gap(12),
            OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
              ),
              child: Text(secondaryActionLabel!),
            ),
          ],
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
