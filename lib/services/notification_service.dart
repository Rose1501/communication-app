import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:user_repository/user_repository.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<RemoteMessage> _messageStreamController = StreamController<RemoteMessage>.broadcast();
  
  late NotificationsRepository _repository;
  late UserRepository _userRepository;

  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

  Future<void> initialize({
    required NotificationsRepository repository,
    required UserRepository userRepository,
  }) async {
    _repository = repository;
    _userRepository = userRepository;
    
    debugPrint('🔔 Initializing notification service');
    
    // طلب الأذونات
    await _requestPermissions();
    
    // الحصول على FCM Token
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      debugPrint('📱 FCM Token: $fcmToken');
      
      // حفظ التوكن في بيانات المستخدم
      try {
        await _userRepository.ensureFirebaseUidAndSetFcmToken(token: fcmToken);
      } catch (e) {
        debugPrint('⚠️ Error saving FCM token: $e');
      }
    }
    
    // إعداد الإشعارات المحلية
    await _setupLocalNotifications();
    
    // إعداد معالج الرسائل
    await _setupMessageHandlers();
    
    debugPrint('✅ Notification service initialized');
  }

  Future<void> _requestPermissions() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('✅ Notification permissions granted');
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(settings);
    debugPrint('✅ Local notifications initialized');
  }

  Future<void> _setupMessageHandlers() async {
    // رسائل في المقدمة
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📱 Foreground message: ${message.messageId}');
      _messageStreamController.add(message);
      _showLocalNotification(message);
    });
    
    // رسائل عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('👆 Message opened: ${message.messageId}');
      _messageStreamController.add(message);
    });
    
    // رسالة التطبيق الأولية
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 Initial message: ${initialMessage.messageId}');
        _messageStreamController.add(initialMessage);
      }
    } catch (e) {
      debugPrint('❌ Error getting initial message: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'إشعارات التطبيق',
        channelDescription: 'إشعارات تطبيق الجامعة',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'إشعار جديد',
        message.notification?.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      
      debugPrint('📲 Local notification shown');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  void dispose() {
    _messageStreamController.close();
  }
}