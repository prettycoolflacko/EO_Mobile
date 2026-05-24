import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:eventsync_mobile/features/notifications/domain/entities/notification_model.dart';
import 'package:eventsync_mobile/features/notifications/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(dio: ref.watch(dioProvider));
});

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(notificationRepositoryProvider));
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  Timer? _pollingTimer;

  NotificationNotifier(this._repository) : super(const NotificationState()) {
    fetchNotifications();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll every 15 seconds for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollNotificationsSilently();
    });
  }

  Future<void> fetchNotifications() async {
    if (state.notifications.isEmpty) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final response = await _repository.getMyNotifications();
      state = state.copyWith(
        isLoading: false,
        notifications: response.data ?? [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _pollNotificationsSilently() async {
    try {
      final response = await _repository.getMyNotifications();
      final newNotifs = response.data ?? [];
      
      // Simple equality check by length or latest ID to prevent unnecessary rebuilds
      if (newNotifs.length != state.notifications.length ||
          (newNotifs.isNotEmpty && state.notifications.isNotEmpty && newNotifs.first.id != state.notifications.first.id) ||
          newNotifs.where((n) => !n.isRead).length != state.unreadCount) {
        state = state.copyWith(notifications: newNotifs);
      }
    } catch (_) {
      // Ignore polling errors
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final currentNotifs = List<NotificationModel>.from(state.notifications);
    final index = currentNotifs.indexWhere((n) => n.id == id);
    if (index == -1 || currentNotifs[index].isRead) return;

    final oldNotif = currentNotifs[index];
    currentNotifs[index] = NotificationModel(
      id: oldNotif.id,
      tipe: oldNotif.tipe,
      judul: oldNotif.judul,
      pesan: oldNotif.pesan,
      isRead: true,
      createdAt: oldNotif.createdAt,
      targetDivisi: oldNotif.targetDivisi,
      targetUserId: oldNotif.targetUserId,
    );
    
    state = state.copyWith(notifications: currentNotifs);

    try {
      await _repository.markAsRead(id);
    } catch (e) {
      // Revert on failure
      currentNotifs[index] = oldNotif;
      state = state.copyWith(notifications: currentNotifs);
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = state.notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    for (final id in unreadIds) {
      await markAsRead(id);
    }
  }
}
