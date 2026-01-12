part of 'notifications_bloc.dart';
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> props() => [];
}

class LoadNotifications extends NotificationsEvent {}

class AddNotification extends NotificationsEvent {
  final RemoteMessage message;
  
  const AddNotification(this.message);
  
  @override
  List<Object> props() => [message];
}

class MarkAllAsRead extends NotificationsEvent {}

class CreateTestNotification extends NotificationsEvent {}

// 🔥 إضافة أحداث للحذف
class DeleteNotifications extends NotificationsEvent {
  final List<String> notificationIds;
  
  const DeleteNotifications(this.notificationIds);
  
  @override
  List<Object> props() => [notificationIds];
}

class DeleteAllNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;
  
  const MarkNotificationAsRead(this.notificationId);
  
  @override
  List<Object> props() => [notificationId];
}