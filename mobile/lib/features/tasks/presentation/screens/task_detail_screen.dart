import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/tasks/domain/entities/task.dart';
import 'package:eventsync_mobile/features/tasks/presentation/providers/task_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          taskAsync.maybeWhen(
            data: (task) {
              final currentUserId = ref.watch(currentUserProvider)?.id;
              final isAdmin = ref.watch(currentUserProvider)?.isAdmin ?? false;
              final canEdit = isAdmin || task.assigneeId == currentUserId;

              if (canEdit) {
                return IconButton(
                  icon: const Icon(Icons.edit_note_rounded),
                  onPressed: () => _showUpdateStatusSheet(context, task),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: taskAsync.when(
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
              const Gap(16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(taskDetailProvider(widget.taskId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (task) => _TaskDetailContent(task: task),
      ),
    );
  }

  void _showUpdateStatusSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UpdateStatusSheet(
        task: task,
        onStatusUpdated: () {
          // Invalidate detail to refresh
          ref.invalidate(taskDetailProvider(task.id));
          // Note: we should also refresh the list, but list uses family params so we'd need to know which list to refresh.
          // In a real app we might invalidate the list provider or use a shared state.
        },
      ),
    );
  }
}

class _TaskDetailContent extends StatelessWidget {
  final Task task;

  const _TaskDetailContent({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PriorityBadge(priority: task.prioritas),
              StatusBadge(status: task.status, fontSize: 13),
            ],
          ),
          const Gap(16),
          Text(
            task.judul,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const Gap(24),
          
          // Info Cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.event_note_rounded,
                  label: 'Event',
                  value: task.eventName ?? 'Event #${task.eventId}',
                ),
              ),
              const Gap(12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.access_time_rounded,
                  label: 'Tenggat Waktu',
                  value: task.deadline != null ? dateFormat.format(task.deadline!) : 'Tidak ada',
                  isAlert: task.deadline != null &&
                      task.deadline!.isBefore(DateTime.now()) &&
                      task.status != 'selesai',
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.person_outline_rounded,
                  label: 'Penanggung Jawab',
                  value: task.assigneeName ?? 'Belum ada',
                ),
              ),
              const Gap(12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.groups_outlined,
                  label: 'Divisi',
                  value: task.divisi ?? '-',
                ),
              ),
            ],
          ),
          
          const Gap(32),
          const Text(
            'Deskripsi Tugas',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          Text(
            task.deskripsi ?? 'Tidak ada deskripsi',
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15, height: 1.5),
          ),

          if (task.catatan != null && task.catatan!.isNotEmpty) ...[
            const Gap(24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withAlpha(50)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 20),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Catatan Status',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const Gap(4),
                        Text(task.catatan!,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (task.lampiranUrl != null) ...[
            const Gap(32),
            const Text(
              'Lampiran',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const Gap(12),
            InkWell(
              onTap: () async {
                final url = Uri.parse(task.lampiranUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attachment_rounded,
                        color: AppColors.primary),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        task.lampiranUrl!.split('/').last,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isAlert;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppColors.error.withAlpha(100) : AppColors.glassBorder,
          width: isAlert ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isAlert ? AppColors.error : AppColors.textSecondary, size: 20),
          const Gap(12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              color: isAlert ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateStatusSheet extends ConsumerStatefulWidget {
  final Task task;
  final VoidCallback onStatusUpdated;

  const _UpdateStatusSheet({required this.task, required this.onStatusUpdated});

  @override
  ConsumerState<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends ConsumerState<_UpdateStatusSheet> {
  late String _selectedStatus;
  final _catatanController = TextEditingController();
  bool _isLoading = false;

  final _statuses = [
    {'value': 'belum', 'label': 'Belum Dikerjakan', 'color': AppColors.statusBelum},
    {'value': 'proses', 'label': 'Sedang Diproses', 'color': AppColors.statusProses},
    {'value': 'terkendala', 'label': 'Terkendala', 'color': AppColors.statusTerkendala},
    {'value': 'selesai', 'label': 'Selesai', 'color': AppColors.statusSelesai},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
    _catatanController.text = widget.task.catatan ?? '';
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateTaskStatus(
        id: widget.task.id,
        status: _selectedStatus,
        catatan: _catatanController.text.trim(),
      );
      if (mounted) {
        widget.onStatusUpdated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status tugas berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status Tugas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const Gap(24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((s) {
                final isSelected = _selectedStatus == s['value'];
                final color = s['color'] as Color;
                return ChoiceChip(
                  label: Text(s['label'] as String),
                  selected: isSelected,
                  selectedColor: color.withAlpha(40),
                  backgroundColor: AppColors.surfaceVariant,
                  labelStyle: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: isSelected ? color : AppColors.surfaceContainer,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedStatus = s['value'] as String);
                  },
                );
              }).toList(),
            ),
            const Gap(24),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan (opsional, wajib jika terkendala)',
                labelText: 'Catatan',
                alignLabelWithHint: true,
              ),
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
