import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:notification_repository/src/services/notification_mapper.dart';
import 'package:request_repository/request_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseNotificationsRepository implements NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userRepository;
  
  // أسماء المجموعات
  static const String _generalNotifications = 'general_notifications';
  static const String _userNotifications = 'user_notifications';
  static const String _systemNotifications = 'system_notifications';

  // Constructor مع dependency injection
  FirebaseNotificationsRepository({required UserRepository userRepository})
      : _userRepository = userRepository;

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      debugPrint('💾 Saving notification: ${notification.id} - Type: ${notification.type}');
      
      // تحديد مكان الحفظ بناءً على targetFirebaseUID
      String collection = _userNotifications;
      if (notification.targetFirebaseUID == null) {
        collection = notification.type == 'system' ? _systemNotifications : _generalNotifications;
      }
      
      // الحفظ بناءً على الهدف
      if (notification.targetFirebaseUID != null && 
          notification.targetFirebaseUID!.isNotEmpty) {
        
        await _firestore
            .collection(collection)
            .doc(notification.targetFirebaseUID)
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toFirestore());
        
        debugPrint('✅ Notification saved for user: ${notification.targetFirebaseUID}');
      } else {
        await _firestore
            .collection(collection)
            .doc(notification.id)
            .set(notification.toFirestore());
        
        debugPrint('✅ ${notification.type.capitalize()} notification saved');
      }
    } catch (e) {
      debugPrint('❌ Error saving notification: $e');
      rethrow;
    }
  }

  // 🔥 دالة مساعدة للبحث عن firebaseUID باستخدام userID
  Future<String?> _getFirebaseUIDByUserID(String userID) async {
    try {
      debugPrint('🔍 Searching for user by userID: $userID');
      final user = await _userRepository.getUserByUserID(userID);
      
      if (user.isNotEmpty && user.firebaseUID != null && user.firebaseUID!.isNotEmpty) {
        debugPrint('✅ Found firebaseUID: ${user.firebaseUID} for userID: $userID');
        return user.firebaseUID;
      }
      
      debugPrint('⚠️ No firebaseUID found for userID: $userID');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting firebaseUID for userID $userID: $e');
      return null;
    }
  }

  // 🔥 دالة مساعدة للبحث عن المسؤولين بناءً على الدور
  Future<List<String>> _getAdminsByRole(String role) async {
    try {
      debugPrint('🔍 Searching for admins with role: $role');
      
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

        debugPrint('📊 Found ${usersSnapshot.docs.length} users with role: $role');

      final adminFirebaseUIDs = <String>[];
      
      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        final firebaseUID = userData['firebaseUID'] as String?;
        
        if (firebaseUID != null && firebaseUID.isNotEmpty) {
          adminFirebaseUIDs.add(firebaseUID);
        }
      }
      
      debugPrint('✅ Found ${adminFirebaseUIDs.length} admins with role: $role');
      return adminFirebaseUIDs;
    } catch (e) {
      debugPrint('❌ Error getting admins by role $role: $e');
      return [];
    }
  }

  // ========== إشعارات الشكاوى ==========
  @override
  Future<void> saveComplaintNotification(ComplaintModel complaint) async {
    try {
      debugPrint('🚀 Saving complaint notification for: ${complaint.title}');
      
      // 1. تحويل الشكوى إلى إشعار للطالب
      final notification = NotificationMapper.fromComplaint(complaint);
      
      // 2. الحصول على firebaseUID للطالب
      final studentFirebaseUID = await _getFirebaseUIDByUserID(complaint.studentID);
      
      if (studentFirebaseUID != null) {
        // إرسال إشعار للطالب
        final studentNotification = notification.copyWith(
          targetFirebaseUID: studentFirebaseUID,
          title: 'شكوى جديدة',
          body: 'شكوى: ${complaint.title}',
        );
        await saveNotification(studentNotification);
        debugPrint('✅ Complaint notification sent to student: ${complaint.studentName}');
      }
      
      // 3. إرسال إشعارات للمسؤولين بناءً على targetRole
      await _notifyAdminsForComplaint(complaint);
      
      debugPrint('✅ Complaint notification saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving complaint notification: $e');
      rethrow;
    }
  }

  // 🔥 دالة مساعدة لإرسال إشعارات الشكاوى للمسؤولين
  Future<void> _notifyAdminsForComplaint(ComplaintModel complaint) async {
    try {
      debugPrint('🔍 Notifying admins for complaint: ${complaint.id}');
      
      // الحصول على جميع المسؤولين بالدور المطلوب
      final adminFirebaseUIDs = await _getAdminsByRole(complaint.targetRole);
      
      for (final adminUID in adminFirebaseUIDs) {
        try {
          final adminNotification = NotificationModel(
            id: 'complaint_admin_${complaint.id}_${adminUID}_${DateTime.now().millisecondsSinceEpoch}',
            type: 'complaint',
            title: 'شكوى جديدة تحتاج المراجعة',
            body: 'شكوى جديدة من ${complaint.studentName}: ${complaint.title}',
            timestamp: DateTime.now(),
            targetFirebaseUID: adminUID,
            sourceEntityId: complaint.id,
            sourceRepository: 'complaint',
            metadata: {
              'complaintId': complaint.id,
              'studentId': complaint.studentID,
              'studentName': complaint.studentName,
              'title': complaint.title,
              'targetRole': complaint.targetRole,
              'status': complaint.status,
            },
          );
          
          await saveNotification(adminNotification);
          debugPrint('✅ Complaint notification sent to admin: $adminUID');
        } catch (e) {
          debugPrint('⚠️ Error sending complaint notification to admin $adminUID: $e');
        }
      }
      
      debugPrint('✅ Notified ${adminFirebaseUIDs.length} admins for complaint');
    } catch (e) {
      debugPrint('❌ Error notifying admins for complaint: $e');
    }
  }

  @override
  Future<void> saveComplaintStatusUpdateNotification(ComplaintModel complaint, String oldStatus) async {
    try {
      debugPrint('🚀 Saving complaint status update notification');
      
      // 1. تحويل تحديث حالة الشكوى إلى إشعار
      final notification = NotificationMapper.fromComplaintStatusUpdate(complaint, oldStatus);
      
      // 2. الحصول على firebaseUID للطالب
      final studentFirebaseUID = await _getFirebaseUIDByUserID(complaint.studentID);
      
      if (studentFirebaseUID != null) {
        // إرسال إشعار للطالب
        final studentNotification = notification.copyWith(
          targetFirebaseUID: studentFirebaseUID,
          title: 'تحديث حالة الشكوى',
          body: ':تحديث حالة "${complaint.title}"',
        );
        await saveNotification(studentNotification);
        debugPrint('✅ Status update notification sent to student: ${complaint.studentName}');
      }
      
      debugPrint('✅ Complaint status update notification saved');
    } catch (e) {
      debugPrint('❌ Error saving complaint status update: $e');
      rethrow;
    }
  }

  // ========== إشعارات الطلبات ==========
  @override
  Future<void> saveRequestNotification(StudentRequestModel request) async {
    try {
      debugPrint('🚀 Saving request notification for: ${request.requestType}');
      
      // 1. تحويل الطلب إلى إشعار
      NotificationMapper.fromRequest(request);
      
      // 2. إرسال إشعار للمسؤولين (Admin فقط)
      final adminFirebaseUIDs = await _getAdminsByRole('Admin');
      
      for (final adminUID in adminFirebaseUIDs) {
        try {
          final adminNotification = NotificationModel(
            id: 'request_admin_${request.id}_${adminUID}_${DateTime.now().millisecondsSinceEpoch}',
            type: 'request',
            title: 'طلب جديد',
            body: 'طلب جديد من ${request.name}: ${request.requestType}',
            timestamp: DateTime.now(),
            targetFirebaseUID: adminUID,
            sourceEntityId: request.id,
            sourceRepository: 'request',
            metadata: {
              'requestId': request.id,
              'studentId': request.studentID,
              'studentName': request.name,
              'requestType': request.requestType,
              'status': request.status,
            },
          );
          
          await saveNotification(adminNotification);
          debugPrint('✅ Request notification sent to admin: $adminUID');
        } catch (e) {
          debugPrint('⚠️ Error sending request notification to admin $adminUID: $e');
        }
      }
      
      debugPrint('✅ Request notification saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving request notification: $e');
      rethrow;
    }
  }

  @override
Future<void> saveRequestReplyNotification(
  StudentRequestModel request, {
  String? adminReply,
}) async {
  try {
    debugPrint('🚀 Saving request reply notification');
    debugPrint('📝 Request ID: ${request.id}');
    debugPrint('👤 Student ID: ${request.studentID}');
    debugPrint('🔄 Status: ${request.status}');
    
    if (adminReply != null) {
      debugPrint('💬 Admin Reply: $adminReply');
    }
    
    // الحصول على firebaseUID للطالب
    final studentFirebaseUID = await _getFirebaseUIDByUserID(request.studentID);
    
    if (studentFirebaseUID != null && studentFirebaseUID.isNotEmpty) {
      // تحويل رد الطلب إلى إشعار
      final notification = NotificationMapper.fromRequestReply(request);
      
      // إنشاء نص الإشعار بناءً على الحالة والرد
      String bodyText;
      if (request.status == 'موافق') {
        bodyText = adminReply != null && adminReply.isNotEmpty
            ? 'تم الموافقة على طلبك "${request.requestType}" مع الرد: $adminReply'
            : 'تم الموافقة على طلبك "${request.requestType}"';
      } else if (request.status == 'مرفوض') {
        bodyText = adminReply != null && adminReply.isNotEmpty
            ? 'تم رفض طلبك "${request.requestType}" مع التعليق: $adminReply'
            : 'تم رفض طلبك "${request.requestType}"';
      } else {
        bodyText = 'تم تحديث حالة طلبك "${request.requestType}" إلى: ${request.status}';
      }
      
      final studentNotification = notification.copyWith(
        targetFirebaseUID: studentFirebaseUID,
        title: 'تحديث حالة طلبك',
        body: bodyText,
        metadata: {
          ...notification.metadata ?? {},
          'hasAdminReply': adminReply != null && adminReply.isNotEmpty,
          'replyLength': adminReply?.length ?? 0,
        },
      );
      
      await saveNotification(studentNotification);
      debugPrint('✅ Request reply notification sent to student: ${request.name}');
      debugPrint('📧 Firebase UID: $studentFirebaseUID');
      debugPrint('📨 Body: $bodyText');
    } else {
      debugPrint('⚠️ Could not find firebaseUID for student ID: ${request.studentID}');
    }
    
    debugPrint('✅ Request reply notification saved');
  } catch (e) {
    debugPrint('❌ Error saving request reply notification: $e');
    rethrow;
  }
}

  // ========== إشعارات الإعلانات العامة ==========
  @override
  Future<void> saveAdvertisementNotification(AdvertisemenModel advertisement) async {
    try {
      print('🚀 بدء حفظ إشعار الإعلان: ${advertisement.id}');
      print('📢 الإعلان: ${advertisement.description}');
      print('🎯 الفئة المستهدفة: ${advertisement.custom}');
      // 🔥 **التحقق من دقة البيانات**
      if (advertisement.custom == null || advertisement.custom!.isEmpty) {
      print('⚠️ custom فارغ، استخدام القيمة الافتراضية: "الكل"');
      }
      // تحديد المستخدمين المستهدفين بناءً على custom
      final List<String> targetFirebaseUIDs = await _getTargetUsersForAdvertisement(advertisement.custom);
      print('📢 إرسال الإعلان إلى ${targetFirebaseUIDs.length} مستخدم مع custom: ${advertisement.custom}');
    
      if (targetFirebaseUIDs.isEmpty) {
      print('⚠️ لا يوجد مستخدمين مستهدفين للإعلان');
      return;
      }
      debugPrint('📢 Sending advertisement to ${targetFirebaseUIDs.length} users with custom: ${advertisement.custom}');
      
      for (final userUID in targetFirebaseUIDs) {
        try {
          final notification = NotificationMapper.fromGeneralAdvertisement(advertisement);
          
          final userNotification = notification.copyWith(
            targetFirebaseUID: userUID,
            title: 'إعلان جديد',
            body: advertisement.description.isNotEmpty? 'إعلان: ${advertisement.description}':'إعلان: تم نشر صورة',
            metadata: {
              ...notification.metadata ?? {},
              'publisher': advertisement.user.name,
              'custom': advertisement.custom,
            },
          );
          
          await saveNotification(userNotification);
          debugPrint('✅ Advertisement sent to user: $userUID');
        } catch (e) {
          debugPrint('⚠️ Error sending advertisement to user $userUID: $e');
        }
      }
      
      debugPrint('✅ Advertisement notification sent to ${targetFirebaseUIDs.length} users');
    } catch (e) {
      debugPrint('❌ Error saving advertisement notification: $e');
      rethrow;
    }
  }

  // 🔥 دالة مساعدة لتحديد المستخدمين المستهدفين للإعلان
  Future<List<String>> _getTargetUsersForAdvertisement(String custom) async {
    try {
      print('🔍 البحث عن مستخدمين مستهدفين للإعلان مع custom: $custom');
      
      final List<String> targetFirebaseUIDs = [];
      final usersSnapshot = await _firestore.collection('users').get();
      print('👥 العدد الإجمالي للمستخدمين: ${usersSnapshot.docs.length}');

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        final userRole = userData['role'] as String?;
        final firebaseUID = userData['firebaseUID'] as String?;
        
        if (firebaseUID == null || firebaseUID.isEmpty) {
          print('⚠️ مستخدم بدون firebaseUID: ${doc.id}');
          continue;
        }
        
        // تحديد إذا كان المستخدم ضمن الفئة المستهدفة
        bool shouldReceive = false;
        // 🔥 **إضافة المزيد من الـ logs للتشخيص**
        print('   👤 التحقق من المستخدم: $firebaseUID');
        print('   🎯 الدور: $userRole');
        
        switch (custom) {
        case 'الكل':
          shouldReceive = true;
          print('   ✅ إرسال إلى: الكل');
          break;
        case 'الطلاب':
          shouldReceive = userRole == 'Student';
          print('   ${shouldReceive ? '✅' : '❌'} إرسال إلى: الطلاب');
          break;
        case 'أعضاء هيئة التدريس':
          shouldReceive = userRole == 'Doctor';
          print('   ${shouldReceive ? '✅' : '❌'} إرسال إلى: أعضاء هيئة التدريس');
          break;
        case 'الإدارة':
          shouldReceive = userRole == 'Admin' || userRole == 'Manager';
          print('   ${shouldReceive ? '✅' : '❌'} إرسال إلى: الإدارة');
          break;
        default:
          shouldReceive = true;
          print('   ⚠️ custom غير معروف، إرسال للجميع');
      }
      
      if (shouldReceive) {
        targetFirebaseUIDs.add(firebaseUID);
        print('   📨 تمت إضافة المستخدم: $firebaseUID');
      }
    }
      
      print('✅ تم العثور على ${targetFirebaseUIDs.length} مستخدم مستهدف');
    return targetFirebaseUIDs;
  } catch (e) {
    print('❌ خطأ في البحث عن مستخدمين مستهدفين: $e');
    return [];
  }
}

  // ========== إشعارات الإعلانات الخاصة بالمجموعات ==========
  @override
  Future<void> saveGroupAdvertisementNotification({
    required AdvertisementModel advertisement,
    required List<String> studentIds,
  }) async {
    try {
      debugPrint('🚀 Saving group advertisement notification: ${advertisement.title}');
      debugPrint('🎯 Target students: ${studentIds.length}');
      
      for (final studentId in studentIds) {
        try {
          // الحصول على firebaseUID للطالب
          final studentFirebaseUID = await _getFirebaseUIDByUserID(studentId);
          
          if (studentFirebaseUID != null) {
            // تحويل الإعلان إلى إشعار
            final notification = NotificationMapper.fromGroupAdvertisement(advertisement, studentId);
            
            final studentNotification = notification.copyWith(
              targetFirebaseUID: studentFirebaseUID,
              title: 'إعلان جديد في المجموعة',
              body: 'إعلان: ${advertisement.title}',
            );
            
            await saveNotification(studentNotification);
            debugPrint('✅ Group advertisement sent to student: $studentId');
          }
        } catch (e) {
          debugPrint('⚠️ Error sending group advertisement to student $studentId: $e');
        }
      }
      
      debugPrint('✅ Group advertisement notification sent to ${studentIds.length} students');
    } catch (e) {
      debugPrint('❌ Error saving group advertisement notification: $e');
      rethrow;
    }
  }

  // ========== إشعارات المناهج ==========
  @override
  Future<void> saveCurriculumNotification(CurriculumModel curriculum, List<String> studentIds) async {
    try {
      debugPrint('🚀 Saving curriculum notification: ${curriculum.description}');
      debugPrint('🎯 Target students: ${studentIds.length}');
      
      for (final studentId in studentIds) {
        try {
          // الحصول على firebaseUID للطالب
          final studentFirebaseUID = await _getFirebaseUIDByUserID(studentId);
          
          if (studentFirebaseUID != null) {
            // تحويل المنهج إلى إشعار
            final notification = NotificationMapper.fromCurriculum(curriculum, studentId);
            
            final studentNotification = notification.copyWith(
              targetFirebaseUID: studentFirebaseUID,
              title: 'منهج جديد',
              body: 'المنهج: ${curriculum.description}',
            );
            
            await saveNotification(studentNotification);
            debugPrint('✅ Curriculum notification sent to student: $studentId');
          }
        } catch (e) {
          debugPrint('⚠️ Error sending curriculum notification to student $studentId: $e');
        }
      }
      
      debugPrint('✅ Curriculum notification sent to ${studentIds.length} students');
    } catch (e) {
      debugPrint('❌ Error saving curriculum notification: $e');
      rethrow;
    }
  }

  // ========== إشعارات الواجبات ==========
  @override
  Future<void> saveHomeworkNotification(HomeworkModel homework, List<String> studentIds) async {
    try {
      debugPrint('🚀 Saving homework notification: ${homework.title}');
      debugPrint('🎯 Target students: ${studentIds.length}');
      
      for (final studentId in studentIds) {
        try {
          // الحصول على firebaseUID للطالب
          final studentFirebaseUID = await _getFirebaseUIDByUserID(studentId);
          
          if (studentFirebaseUID != null) {
            // تحويل الواجب إلى إشعار
            final notification = NotificationMapper.fromHomework(homework, studentId);
            
            final studentNotification = notification.copyWith(
              targetFirebaseUID: studentFirebaseUID,
              title: 'واجب جديد',
              body: 'تم نشر: ${homework.title}',
              metadata: {
                ...notification.metadata ?? {},
                'dueDate': homework.end.toIso8601String(),
                'maxMark': homework.maxMark,
              },
            );
            
            await saveNotification(studentNotification);
            debugPrint('✅ Homework notification sent to student: $studentId');
          }
        } catch (e) {
          debugPrint('⚠️ Error sending homework notification to student $studentId: $e');
        }
      }
      
      debugPrint('✅ Homework notification sent to ${studentIds.length} students');
    } catch (e) {
      debugPrint('❌ Error saving homework notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveHomeworkGradeNotification(String homeworkId, String studentId, double mark, double maxMark) async {
    try {
      debugPrint('🚀 Saving homework grade notification for student: $studentId');
      
      // الحصول على firebaseUID للطالب
      final studentFirebaseUID = await _getFirebaseUIDByUserID(studentId);
      
      if (studentFirebaseUID != null) {
        // تحويل التقييم إلى إشعار
        final notification = NotificationMapper.fromHomeworkGrade(homeworkId, studentId, mark, maxMark);
        
        final studentNotification = notification.copyWith(
          targetFirebaseUID: studentFirebaseUID,
          title: 'تقييم الواجب',
          body: 'تم تقييم: ${mark.toStringAsFixed(1)}/$maxMark',
        );
        
        await saveNotification(studentNotification);
        debugPrint('✅ Homework grade notification sent to student: $studentId');
      }
      
      debugPrint('✅ Homework grade notification saved');
    } catch (e) {
      debugPrint('❌ Error saving homework grade notification: $e');
      rethrow;
    }
  }

  // ========== إشعارات درجات الامتحانات ==========
  @override
  Future<void> saveExamGradeNotification(ExamGradeModel examGrade) async {
    try {
      debugPrint('🚀 Saving exam grade notification: ${examGrade.examType}');
      
      // الحصول على firebaseUID للطالب
      final studentFirebaseUID = await _getFirebaseUIDByUserID(examGrade.studentId);
      
      if (studentFirebaseUID != null) {
        // تحويل درجة الامتحان إلى إشعار
        final notification = NotificationMapper.fromExamGrade(examGrade);
        
        final studentNotification = notification.copyWith(
          targetFirebaseUID: studentFirebaseUID,
          title: 'درجة امتحان ${examGrade.examType}',
          body: 'درجة ${examGrade.examType}: ${examGrade.grade}/${examGrade.maxGrade}',
          metadata: {
            ...notification.metadata ?? {},
            'percentage': (examGrade.grade / examGrade.maxGrade * 100).toStringAsFixed(1),
          },
        );
        
        await saveNotification(studentNotification);
        debugPrint('✅ Exam grade notification sent to student: ${examGrade.studentName}');
      }
      
      debugPrint('✅ Exam grade notification saved');
    } catch (e) {
      debugPrint('❌ Error saving exam grade notification: $e');
      rethrow;
    }
  }

  // ========== إشعارات الحضور والغياب ==========
  @override
  Future<void> saveAttendanceNotification(AttendanceRecordModel attendance, Map<String, bool> studentPresence) async {
    try {
      debugPrint('🚀 Saving attendance notification');
      debugPrint('🎯 Target students: ${studentPresence.length}');
      
      for (final entry in studentPresence.entries) {
        final studentId = entry.key;
        final isPresent = entry.value;
        
        try {
          // الحصول على firebaseUID للطالب
          final studentFirebaseUID = await _getFirebaseUIDByUserID(studentId);
          
          if (studentFirebaseUID != null) {
            // تحويل الحضور إلى إشعار
            final notification = NotificationMapper.fromAttendance(attendance, studentId, isPresent);
            
            final studentNotification = notification.copyWith(
              targetFirebaseUID: studentFirebaseUID,
              title: isPresent ? 'تم تسجيل حضورك' : 'تم تسجيل غيابك',
              body: isPresent 
                  ? 'تم تسجيل حضورك في محاضرة: ${attendance.lectureTitle}'
                  : 'تم تسجيل غيابك في محاضرة: ${attendance.lectureTitle}',
            );
            
            await saveNotification(studentNotification);
            debugPrint('✅ Attendance notification sent to student: $studentId');
          }
        } catch (e) {
          debugPrint('⚠️ Error sending attendance notification to student $studentId: $e');
        }
      }
      
      debugPrint('✅ Attendance notification sent to ${studentPresence.length} students');
    } catch (e) {
      debugPrint('❌ Error saving attendance notification: $e');
      rethrow;
    }
  }

  // ========== باقي الدوال الأساسية (كما هي) ==========
  @override
  Future<void> saveNotificationFromRemoteMessage(RemoteMessage message) async {
    try {
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: message.data['type'] ?? 'general',
        title: message.notification?.title ?? 'إشعار جديد',
        body: message.notification?.body ?? '',
        timestamp: DateTime.now(),
        dataPayload: message.data,
        targetFirebaseUID: message.data['firebaseUID'] as String?,
        sourceEntityId: message.data['sourceEntityId'] as String?,
        sourceRepository: message.data['sourceRepository'] as String?,
        metadata: message.data['metadata'] as Map<String, dynamic>?,
      );
      
      await saveNotification(notification);
      debugPrint('✅ Remote message saved as notification');
    } catch (e) {
      debugPrint('❌ Error saving remote message: $e');
      rethrow;
    }
  }

  @override
  Stream<List<NotificationModel>> getUserNotifications(String firebaseUID) {
    debugPrint('👤 Getting notifications for user: $firebaseUID');
    
    return _firestore
        .collection(_userNotifications)
        .doc(firebaseUID)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList();
          
          debugPrint('📱 User has ${notifications.length} notifications');
          return notifications;
        })
        .handleError((error) {
          debugPrint('❌ Error getting user notifications: $error');
          return [];
        });
  }

  @override
  Stream<List<NotificationModel>> getNotificationsByType(String type) {
    debugPrint('🔍 Getting notifications of type: $type');
    
    return _firestore
        .collection(_generalNotifications)
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList();
          
          debugPrint('📱 Found ${notifications.length} $type notifications');
          return notifications;
        })
        .handleError((error) {
          debugPrint('❌ Error getting $type notifications: $error');
          return [];
        });
  }

  @override
  Future<List<NotificationModel>> getAllNotifications(String firebaseUID) async {
    debugPrint('📊 Getting all notifications for: $firebaseUID');
    
    try {
      final List<NotificationModel> allNotifications = [];
      
      // جلب إشعارات المستخدم
      final userQuery = await _firestore
          .collection(_userNotifications)
          .doc(firebaseUID)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();
      
      final userNotifications = userQuery.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      allNotifications.addAll(userNotifications);
      
      // جلب الإشعارات العامة
      final generalQuery = await _firestore
          .collection(_generalNotifications)
          .orderBy('timestamp', descending: true)
          .get();
      
      final generalNotifications = generalQuery.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      allNotifications.addAll(generalNotifications);
      
      // جلب إشعارات النظام
      final systemQuery = await _firestore
          .collection(_systemNotifications)
          .orderBy('timestamp', descending: true)
          .get();
      
      final systemNotifications = systemQuery.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      allNotifications.addAll(systemNotifications);
      
      // ترتيب جميع الإشعارات
      allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      debugPrint('📊 Total notifications: ${allNotifications.length}');
      return allNotifications;
      
    } catch (e) {
      debugPrint('❌ Error getting all notifications: $e');
      return [];
    }
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications(String firebaseUID) async {
    try {
      final allNotifications = await getAllNotifications(firebaseUID);
      return allNotifications.where((n) => !n.isRead).toList();
    } catch (e) {
      debugPrint('❌ Error getting unread notifications: $e');
      return [];
    }
  }

  @override
  Future<int> getUnreadCount(String firebaseUID) async {
    try {
      final unread = await getUnreadNotifications(firebaseUID);
      return unread.length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId, String firebaseUID) async {
    try {
      debugPrint('📝 Marking notification $notificationId as read');
      
      // محاولة العثور والتحديث في إشعارات المستخدم
      final userNotificationRef = _firestore
          .collection(_userNotifications)
          .doc(firebaseUID)
          .collection('notifications')
          .doc(notificationId);
      
      final userNotification = await userNotificationRef.get();
      
      if (userNotification.exists) {
        await userNotificationRef.update({'isRead': true});
        debugPrint('✅ User notification marked as read');
        return;
      }
      
      // إذا لم يتم العثور في إشعارات المستخدم، حاول في العامة
      final generalNotificationRef = _firestore
          .collection(_generalNotifications)
          .doc(notificationId);
      
      await generalNotificationRef.update({'isRead': true});
      
      debugPrint('✅ Notification marked as read');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String firebaseUID) async {
    try {
      debugPrint('📝 Marking all notifications as read for: $firebaseUID');
      
      // تحديث إشعارات المستخدم
      final userSnapshot = await _firestore
          .collection(_userNotifications)
          .doc(firebaseUID)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in userSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      debugPrint('✅ All user notifications marked as read');
      
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> createTestNotification(String firebaseUID) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'test',
        title: 'إشعار اختبار',
        body: 'هذا إشعار اختبار من التطبيق - ${DateTime.now().toString()}',
        timestamp: DateTime.now(),
        isRead: false,
        targetFirebaseUID: firebaseUID,
        dataPayload: {
          'type': 'test',
          'firebaseUID': firebaseUID,
          'createdAt': DateTime.now().toString(),
        },
        metadata: {
          'testId': 'test_${DateTime.now().millisecondsSinceEpoch}',
          'purpose': 'Testing notifications system',
        },
      );
      
      await saveNotification(notification);
      debugPrint('✅ Test notification created successfully');
    } catch (e) {
      debugPrint('❌ Error creating test notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> initializeCollections() async {
    try {
      // تهيئة مجموعة الإشعارات العامة
      await _firestore
          .collection(_generalNotifications)
          .doc('initialized')
          .set({
            'initialized': true,
            'createdAt': FieldValue.serverTimestamp(),
            'description': 'مجموعة الإشعارات العامة',
          });
      
      // تهيئة مجموعة إشعارات المستخدمين
      await _firestore
          .collection(_userNotifications)
          .doc('initialized')
          .set({
            'initialized': true,
            'createdAt': FieldValue.serverTimestamp(),
            'description': 'مجموعة إشعارات المستخدمين',
          });
      
      // تهيئة مجموعة إشعارات النظام
      await _firestore
          .collection(_systemNotifications)
          .doc('initialized')
          .set({
            'initialized': true,
            'createdAt': FieldValue.serverTimestamp(),
            'description': 'مجموعة إشعارات النظام',
          });
      
      debugPrint('✅ All notification collections initialized');
    } catch (e) {
      debugPrint('❌ Error initializing collections: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId, String firebaseUID) async {
    try {
      debugPrint('🗑️ Deleting notification: $notificationId');
      
      // محاولة الحذف من إشعارات المستخدم أولاً
      final userRef = _firestore
          .collection(_userNotifications)
          .doc(firebaseUID)
          .collection('notifications')
          .doc(notificationId);
      
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        await userRef.delete();
        debugPrint('✅ Deleted from user notifications');
        return;
      }
      
      // إذا لم يتم العثور، حاول في الإشعارات العامة
      final generalRef = _firestore
          .collection(_generalNotifications)
          .doc(notificationId);
      
      await generalRef.delete();
      
      debugPrint('✅ Notification deleted');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  @override
  Future<void> clearAllNotifications(String firebaseUID) async {
    try {
      debugPrint('🧹 Clearing all notifications for: $firebaseUID');
      
      // مسح إشعارات المستخدم
      final userSnapshot = await _firestore
          .collection(_userNotifications)
          .doc(firebaseUID)
          .collection('notifications')
          .get();
      
      final batch = _firestore.batch();
      for (final doc in userSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      debugPrint('✅ Cleared all user notifications');
      
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }
}

// Extension for String capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}