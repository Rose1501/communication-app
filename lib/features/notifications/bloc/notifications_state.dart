part of 'notifications_bloc.dart';
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> props() => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoadSuccess extends NotificationsState {
  final List<NotificationModel> notifications;
  
  const NotificationsLoadSuccess(this.notifications);
  
  @override
  List<Object> props() => [notifications];
}

class NotificationsLoadFailure extends NotificationsState {
  final String error;
  
  const NotificationsLoadFailure(this.error);
  
  @override
  List<Object> props() => [error];
}

// 🔥 حالة لفشل الحذف
class NotificationsDeleteFailure extends NotificationsState {
  final String error;
  
  const NotificationsDeleteFailure(this.error);
  
  @override
  List<Object> props() => [error];
}