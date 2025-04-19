import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fyp/features/notifications/domain/entities/notification.dart';
import 'package:fyp/features/notifications/domain/repo/notification_repo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;

  NotificationCubit({required this.notificationRepo})
    : super(NotificationInitial());

  Future<void> fetchNotifications(String uid) async {
    emit(NotificationLoading());
    try {
      final notifications = await notificationRepo.fetchNotifications(uid);
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError("Failed to load notifications"));
    }
  }

  Future<void> sendNotification(
    String receiverUid,
    AppNotification notification,
  ) async {
    try {
      await notificationRepo.sendNotification(receiverUid, notification);
    } catch (e) {
      emit(NotificationError("Failed to send notification"));
    }
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      await notificationRepo.markAsRead(uid, notificationId);
      fetchNotifications(uid); // Refresh after marking
    } catch (e) {
      emit(NotificationError("Failed to mark notification as read"));
    }
  }
}
