import '../entities/notification.dart';

abstract class NotificationRepo {
  Future<void> sendNotification(
    String receiverUid,
    AppNotification notification,
  );
  Future<List<AppNotification>> fetchNotifications(String uid);
  Future<void> markAsRead(String uid, String notificationId);
}
