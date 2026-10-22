import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotificationsStream(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markSectionAsRead(String userId, List<String> notificationIds);
  Future<void> markAllAsRead(String userId);
  Future<void> refresh(String userId);
}
