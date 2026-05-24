import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/notifications/domain/entities/notification_model.dart';
import 'package:eventsync_mobile/features/notifications/presentation/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () => notifier.markAllAsRead(),
              child: const Text('Tandai Dibaca', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchNotifications(),
        child: notifState.isLoading && notifState.notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notifState.notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 64, color: AppColors.textSecondary),
                        Gap(16),
                        Text('Tidak ada notifikasi baru',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifState.notifications.length,
                    separatorBuilder: (_, __) => const Gap(12),
                    itemBuilder: (context, index) {
                      final notif = notifState.notifications[index];
                      return _NotificationCard(
                        notification: notif,
                        onTap: () => notifier.markAsRead(notif.id),
                      );
                    },
                  ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    
    IconData icon;
    Color iconColor;
    
    switch (notification.tipe) {
      case 'peringatan':
        icon = Icons.warning_rounded;
        iconColor = AppColors.error;
        break;
      case 'tugas':
        icon = Icons.assignment_rounded;
        iconColor = AppColors.primary;
        break;
      default:
        icon = Icons.info_rounded;
        iconColor = AppColors.info;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.cardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? AppColors.glassBorder : AppColors.primary.withAlpha(50),
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withAlpha(20),
              radius: 20,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.judul,
                          style: TextStyle(
                            color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    notification.pesan,
                    style: TextStyle(
                      color: notification.isRead ? AppColors.textSecondary.withAlpha(150) : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    dateFormat.format(notification.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
