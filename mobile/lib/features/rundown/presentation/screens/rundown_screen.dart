import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/rundown/domain/entities/rundown.dart';
import 'package:eventsync_mobile/features/rundown/presentation/providers/rundown_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

class RundownScreen extends ConsumerWidget {
  final int eventId;

  const RundownScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rundownAsync = ref.watch(rundownListProvider(eventId));
    final user = ref.watch(currentUserProvider);
    final isAdminOrKetua = user?.role == 'admin' || user?.role == 'ketua';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Rundown Acara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(rundownListProvider(eventId)),
          ),
        ],
      ),
      body: rundownAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const Gap(16),
              Text(err.toString(),
                  style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        data: (rundowns) {
          if (rundowns.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 64, color: AppColors.textSecondary),
                  Gap(16),
                  Text('Belum ada rundown untuk event ini',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // Sort by urutan (order)
          final sorted = List<Rundown>.from(rundowns)
            ..sort((a, b) => a.urutan.compareTo(b.urutan));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final rundown = sorted[index];
              final isLast = index == sorted.length - 1;
              return _TimelineTile(
                rundown: rundown,
                isLast: isLast,
                isAdmin: isAdminOrKetua,
                onStatusUpdate: () =>
                    ref.invalidate(rundownListProvider(eventId)),
              );
            },
          );
        },
      ),
    );
  }
}

class _TimelineTile extends ConsumerWidget {
  final Rundown rundown;
  final bool isLast;
  final bool isAdmin;
  final VoidCallback onStatusUpdate;

  const _TimelineTile({
    required this.rundown,
    required this.isLast,
    required this.isAdmin,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat('HH:mm');
    final isActive = rundown.status == 'berjalan';
    final isDone = rundown.status == 'selesai';

    final markerColor = isActive
        ? AppColors.primary
        : (isDone ? AppColors.success : AppColors.surfaceContainer);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time Column
          SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeFormat.format(rundown.waktuMulai),
                    style: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    timeFormat.format(rundown.waktuSelesai),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline Marker
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryDark : AppColors.backgroundDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: markerColor,
                      width: isActive ? 4 : 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDone ? AppColors.success.withAlpha(100) : AppColors.surfaceContainer,
                    ),
                  ),
              ],
            ),
          ),
          const Gap(12),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary.withAlpha(15) : AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? AppColors.primary.withAlpha(100) : AppColors.glassBorder,
                    width: isActive ? 1 : 0.5,
                  ),
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
                            rundown.namaKegiatan,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (isAdmin)
                          GestureDetector(
                            onTap: () => _showUpdateStatusMenu(context, ref),
                            child: const Icon(Icons.more_vert_rounded,
                                color: AppColors.textSecondary, size: 20),
                          ),
                      ],
                    ),
                    const Gap(8),
                    StatusBadge(status: rundown.status, fontSize: 10),
                    if (rundown.deskripsi != null && rundown.deskripsi!.isNotEmpty) ...[
                      const Gap(12),
                      Text(
                        rundown.deskripsi!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const Gap(12),
                    const Divider(),
                    const Gap(8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const Gap(6),
                        Text(
                          rundown.pic,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (rundown.lokasi != null && rundown.lokasi!.isNotEmpty) ...[
                          const Gap(16),
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              rundown.lokasi!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Update Status Rundown',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            _StatusTile(
              label: 'Berjalan',
              color: AppColors.statusProses,
              onTap: () => _update(context, ref, 'berjalan'),
            ),
            _StatusTile(
              label: 'Selesai',
              color: AppColors.statusSelesai,
              onTap: () => _update(context, ref, 'selesai'),
            ),
            _StatusTile(
              label: 'Ditunda',
              color: AppColors.rundownDitunda,
              onTap: () => _update(context, ref, 'ditunda'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              title: const Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('newRundown', pathParameters: {'eventId': rundown.eventId.toString()}, extra: rundown).then((_) {
                  onStatusUpdate();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Hapus', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.cardDark,
                    title: const Text('Hapus Rundown'),
                    content: const Text('Apakah Anda yakin ingin menghapus rundown ini?'),
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
                    await ref.read(rundownRepositoryProvider).deleteRundown(rundown.id);
                    onStatusUpdate();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rundown berhasil dihapus')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menghapus rundown')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, WidgetRef ref, String status) async {
    Navigator.pop(context);
    try {
      final repo = ref.read(rundownRepositoryProvider);
      await repo.updateRundownStatus(rundown.id, status);
      onStatusUpdate();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status rundown diperbarui')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _StatusTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 6,
        backgroundColor: color,
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
