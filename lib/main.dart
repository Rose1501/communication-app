import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myproject/firebase_options.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';
import 'app.dart';

void main() async{
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure the app runs in portrait mode only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // تهيئة SharedPreferences
  await SharedPreferences.getInstance();
  
  final userRepository = FirebaseUserRepository();
  // إنشاء instance من NotificationsRepository
  final notificationsRepository = FirebaseNotificationsRepository(userRepository: userRepository,);
  final advertisementRepository = AdvertisementFirebaseRepository(notificationsRepository: notificationsRepository,);
  final notificationService = NotificationService();

  // 🔥 تهيئة المجموعات قبل بدء التطبيق
  try {
    await notificationsRepository.initializeCollections();
    debugPrint('✅ Collections initialized in main');
  } catch (e) {
    debugPrint('❌ Error initializing collections in main: $e');
  }

  // تهيئة خدمة الإشعارات
  try {
    await notificationService.initialize(
      repository: notificationsRepository,
      userRepository: userRepository,
    );
    debugPrint('✅ Notification service initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing notification service: $e');
  }
  
  runApp(MainApp(
    userRepository: userRepository,
    advertisementRepository: advertisementRepository,
    notificationsRepository: notificationsRepository,
    notificationService: notificationService,
  ));
}
