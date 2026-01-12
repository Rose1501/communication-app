import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:complaint_repository/complaint_repository.dart';
import 'package:request_repository/request_repository.dart';
import 'package:subjective_repository/subjective_repository.dart' as subjective;
import 'package:advertisement_repository/advertisement_repository.dart';

abstract class NotificationsRepository {
  // ========== Basic Notification Operations ==========
  
  /// حفظ إشعار
  Future<void> saveNotification(NotificationModel notification);
  
  /// حفظ إشعار من رسالة Firebase
  Future<void> saveNotificationFromRemoteMessage(RemoteMessage message);
  
  /// جلب إشعارات مستخدم معين
  Stream<List<NotificationModel>> getUserNotifications(String firebaseUID);
  
  /// جلب الإشعارات حسب النوع
  Stream<List<NotificationModel>> getNotificationsByType(String type);
  
  /// جلب جميع الإشعارات (خاصة + عامة + نظامية)
  Future<List<NotificationModel>> getAllNotifications(String firebaseUID);
  
  /// جلب الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications(String firebaseUID);
  
  /// جلب عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount(String firebaseUID);
  
  /// تحديث حالة الإشعار كمقروء
  Future<void> markNotificationAsRead(String notificationId, String firebaseUID);
  
  /// تحديث جميع الإشعارات كمقروءة
  Future<void> markAllNotificationsAsRead(String firebaseUID);
  
  /// حذف إشعار
  Future<void> deleteNotification(String notificationId, String firebaseUID);
  
  /// مسح جميع الإشعارات
  Future<void> clearAllNotifications(String firebaseUID);
  
  /// إنشاء إشعار اختبار
  Future<void> createTestNotification(String firebaseUID);
  
  /// تهيئة المجموعات
  Future<void> initializeCollections();
  
  // ========== Repository-Specific Notifications ==========
  
  /// حفظ إشعار شكوى
  Future<void> saveComplaintNotification(ComplaintModel complaint);
  
  /// حفظ إشعار طلب
  Future<void> saveRequestNotification(StudentRequestModel request);
  
  /// حفظ إشعار واجب
  Future<void> saveHomeworkNotification(subjective.HomeworkModel homework, List<String> studentIds);
  
  /// حفظ إشعار منهج
  Future<void> saveCurriculumNotification(subjective.CurriculumModel curriculum, List<String> studentIds);
  
  /// حفظ إشعار إعلان عام
  Future<void> saveAdvertisementNotification(AdvertisemenModel advertisement);
  
  /// 🔥 حفظ إشعار إعلان مجموعة
  Future<void> saveGroupAdvertisementNotification({
    required subjective.AdvertisementModel advertisement,
    required List<String> studentIds,
  });
  
  /// حفظ إشعار حضور/غياب
  Future<void> saveAttendanceNotification(
    subjective.AttendanceRecordModel attendance, 
    Map<String, bool> studentPresence
  );
  
  /// حفظ إشعار درجة امتحان
  Future<void> saveExamGradeNotification(subjective.ExamGradeModel examGrade);
  
  /// حفظ إشعار تحديث حالة شكوى
  Future<void> saveComplaintStatusUpdateNotification(
    ComplaintModel complaint, 
    String oldStatus
  );
  
  /// حفظ إشعار رد على طلب
  Future<void> saveRequestReplyNotification(StudentRequestModel request, {String? adminReply,});
  
  /// حفظ إشعار تقييم واجب
  Future<void> saveHomeworkGradeNotification(
    String homeworkId, 
    String studentId, 
    double mark, 
    double maxMark
  );
}