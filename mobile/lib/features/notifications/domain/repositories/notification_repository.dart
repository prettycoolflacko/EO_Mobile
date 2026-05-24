import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/notifications/domain/entities/notification_model.dart';

abstract class NotificationRepository {
  Future<ApiResponse<List<NotificationModel>>> getMyNotifications();
  Future<NotificationModel> markAsRead(String id);
}
