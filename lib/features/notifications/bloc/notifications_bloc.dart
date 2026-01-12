import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:notification_repository/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository repository;
  final NotificationService notificationService;
  
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  String? _currentFirebaseUID;

  NotificationsBloc({
    required this.repository,
    required this.notificationService,
  }) : super(NotificationsInitial()) {
    
    // تسجيل المستمعين
    _setupMessageListener();
    
    // معالج الأحداث
    on<LoadNotifications>(_onLoadNotifications);
    on<AddNotification>(_onAddNotification);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<CreateTestNotification>(_onCreateTestNotification);
    on<DeleteNotifications>(_onDeleteNotifications);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
  }

  void _setupMessageListener() {
    notificationService.messageStream.listen((message) {
      debugPrint('📩 New message received in BLoC');
      add(AddNotification(message));
    });
  }

Future<void> _onLoadNotifications(
  LoadNotifications event, 
  Emitter<NotificationsState> emit,
) async {
  try {
    debugPrint('🔄 Loading notifications...');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ No user logged in');
      emit(const NotificationsLoadSuccess([]));
      return;
    }
    
    debugPrint('👤 Loading notifications for user: ${currentUser.uid}');
    emit(NotificationsLoading());
    
    // 🔥 **التعديل هنا**: استخدام FirebaseUID مباشرة**
    final notifications = await repository.getAllNotifications(currentUser.uid);
    
    debugPrint('✅ Notifications loaded: ${notifications.length} items');
    emit(NotificationsLoadSuccess(notifications));
    
  } catch (e) {
    debugPrint('❌ Error loading notifications: $e');
    emit(NotificationsLoadFailure(e.toString()));
  }
}

  Future<void> _onAddNotification(
    AddNotification event, 
    Emitter<NotificationsState> emit,
  ) async {
    try {
      debugPrint('➕ Adding notification from message');
      await repository.saveNotificationFromRemoteMessage(event.message);
    } catch (e) {
      debugPrint('❌ Error adding notification: $e');
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event, 
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (_currentFirebaseUID == null) {
        _currentFirebaseUID = FirebaseAuth.instance.currentUser?.uid;
      }
      
      if (_currentFirebaseUID != null) {
        debugPrint('📝 Marking all as read for: $_currentFirebaseUID');
        await repository.markAllNotificationsAsRead(_currentFirebaseUID!);
        
        // تحديث الحالة المحلية
        if (state is NotificationsLoadSuccess) {
          final currentState = state as NotificationsLoadSuccess;
          final updated = currentState.notifications
              .map((n) => n.copyWith(isRead: true))
              .toList();
          emit(NotificationsLoadSuccess(updated));
        }
      }
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
    }
  }

  Future<void> _onMarkNotificationAsRead(
  MarkNotificationAsRead event, 
  Emitter<NotificationsState> emit,
) async {
  try {
    if (_currentFirebaseUID == null) {
      _currentFirebaseUID = FirebaseAuth.instance.currentUser?.uid;
    }
    
    if (_currentFirebaseUID != null) {
      debugPrint('📝 Marking notification as read: ${event.notificationId}');
      await repository.markNotificationAsRead(event.notificationId, _currentFirebaseUID!);
      
      // تحديث الحالة المحلية
      if (state is NotificationsLoadSuccess) {
        final currentState = state as NotificationsLoadSuccess;
        final updated = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        emit(NotificationsLoadSuccess(updated));
      }
    }
  } catch (e) {
    debugPrint('❌ Error marking notification as read: $e');
  }
}

  Future<void> _onCreateTestNotification(
    CreateTestNotification event, 
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (_currentFirebaseUID == null) {
        _currentFirebaseUID = FirebaseAuth.instance.currentUser?.uid;
      }
      
      if (_currentFirebaseUID != null) {
        debugPrint('🧪 Creating test notification');
        await repository.createTestNotification(_currentFirebaseUID!);
      }
    } catch (e) {
      debugPrint('❌ Error creating test notification: $e');
    }
  }

  // 🔥 إضافة معالج الحذف
  Future<void> _onDeleteNotifications(
    DeleteNotifications event, 
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (_currentFirebaseUID == null) {
        _currentFirebaseUID = FirebaseAuth.instance.currentUser?.uid;
      }
      
      if (_currentFirebaseUID != null) {
        debugPrint('🗑️ Deleting ${event.notificationIds.length} notifications');
        
        // حذف كل إشعار على حدة
        for (final id in event.notificationIds) {
          await repository.deleteNotification(id, _currentFirebaseUID!);
        }
        
        debugPrint('✅ Notifications deleted successfully');
        
        // تحديث الحالة المحلية بعد الحذف
        if (state is NotificationsLoadSuccess) {
          final currentState = state as NotificationsLoadSuccess;
          final remaining = currentState.notifications
              .where((n) => !event.notificationIds.contains(n.id))
              .toList();
          emit(NotificationsLoadSuccess(remaining));
        }
      }
    } catch (e) {
      debugPrint('❌ Error deleting notifications: $e');
      emit(NotificationsDeleteFailure(e.toString()));
    }
  }

  // 🔥 إضافة معالج حذف الكل
  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event, 
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (_currentFirebaseUID == null) {
        _currentFirebaseUID = FirebaseAuth.instance.currentUser?.uid;
      }
      
      if (_currentFirebaseUID != null) {
        debugPrint('🗑️ Deleting ALL notifications for: $_currentFirebaseUID');
        await repository.clearAllNotifications(_currentFirebaseUID!);
        
        debugPrint('✅ All notifications deleted');
        emit(const NotificationsLoadSuccess([]));
      }
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
      emit(NotificationsDeleteFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}