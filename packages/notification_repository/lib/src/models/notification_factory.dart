/*import 'package:complaint_repository/complaint_repository.dart';
import 'package:request_repository/request_repository.dart';
import 'package:subjective_repository/subjective_repository.dart' hide AdvertisementModel;
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:user_repository/user_repository.dart';

class NotificationFactory {
  /// 🏭 تحويل شكوى إلى إشعار موحد
  static UnifiedNotificationEntity fromComplaint({
    required ComplaintModel complaint,
    required UserModels sender,
    String? targetUserId,
  }) {
    return UnifiedNotificationEntity(
      id: 'complaint_${complaint.id}',
      type: 'complaint',
      title: 'شكوى جديدة',
      body: '${complaint.studentName}: ${complaint.title}',
      timestamp: complaint.createdAt,
      data: {
        'complaintId': complaint.id,
        'status': complaint.status,
        'targetRole': complaint.targetRole,
      },
      isRead: false,
      targetUserId: targetUserId,
      senderId:  sender.userID,
      senderName: sender.name,
      senderRole: sender.role,
      relatedId: complaint.id,
      icon: 'report_problem',
      actionType: 'view_complaint',
    );
  }

  /// 🏭 تحويل طلب إلى إشعار موحد
  static UnifiedNotificationEntity fromRequest({
    required StudentRequestModel request,
    required UserModels sender,
    String? targetUserId,
  }) {
    return UnifiedNotificationEntity(
      id: 'request_${request.id}',
      type: 'request',
      title: 'طلب جديد',
      body: '${request.name}: ${request.requestType}',
      timestamp: request.dateTime,
      data: {
        'requestId': request.id,
        'status': request.status,
        'requestType': request.requestType,
      },
      isRead: false,
      targetUserId: targetUserId,
      senderId:  sender.userID,
      senderName: sender.name,
      senderRole: sender.role,
      relatedId: request.id,
      icon: 'assignment',
      actionType: 'view_request',
    );
  }

  /// 🏭 تحويل واجب إلى إشعار موحد
  static UnifiedNotificationEntity fromHomework({
    required HomeworkModel homework,
    required UserModels sender,
    required String groupId,
    String? targetUserId,
  }) {
    return UnifiedNotificationEntity(
      id: 'homework_${homework.id}',
      type: 'homework',
      title: 'واجب جديد',
      body: '${homework.title}: ${homework.description}',
      timestamp: homework.start,
      data: {
        'homeworkId': homework.id,
        'groupId': groupId,
        'deadline': homework.end.toIso8601String(),
      },
      isRead: false,
      targetUserId: targetUserId,
      senderId: sender.userID,
      senderName: sender.name,
      senderRole: sender.role,
      relatedId: homework.id,
      icon: 'assignment',
      actionType: 'view_homework',
    );
  }

  /// 🏭 تحويل درجة امتحان إلى إشعار موحد
  static UnifiedNotificationEntity fromExamGrade({
    required ExamGradeModel examGrade,
    required UserModels sender,
    required String groupId,
    String? targetUserId,
  }) {
    return UnifiedNotificationEntity(
      id: 'exam_${examGrade.id}',
      type: 'exam_grade',
      title: 'نتيجة امتحان',
      body: '${examGrade.studentName}: ${examGrade.examType} - ${examGrade.grade}/${examGrade.maxGrade}',
      timestamp: examGrade.examDate,
      data: {
        'examGradeId': examGrade.id,
        'studentId': examGrade.studentId,
        'groupId': groupId,
        'examType': examGrade.examType,
      },
      isRead: false,
      targetUserId: targetUserId ?? examGrade.studentId,
      senderId:  sender.userID,
      senderName: sender.name,
      senderRole: sender.role,
      relatedId: examGrade.id,
      icon: 'grade',
      actionType: 'view_grade',
    );
  }

  /// 🏭 تحويل إعلان إلى إشعار موحد
  static UnifiedNotificationEntity fromAdvertisement({
    required AdvertisemenModel advertisement,
    required UserModels sender,
    String? targetUserId,
  }) {
    return UnifiedNotificationEntity(
      id: 'ad_${advertisement.id}',
      type: 'advertisement',
      title: 'إعلان جديد',
      body: advertisement.description,
      timestamp: advertisement.timeAdv,
      data: {
        'advertisementId': advertisement.id,
        'custom': advertisement.custom,
      },
      isRead: false,
      targetUserId: targetUserId,
      senderId: sender.userID,
      senderName: sender.name,
      senderRole: sender.role,
      relatedId: advertisement.id,
      icon: 'campaign',
      actionType: 'view_advertisement',
    );
  }

  /// 🏭 تحويل إشعار عام إلى موحد
  static UnifiedNotificationEntity fromGeneralNotification({
    required NotificationModel notification,
    required UserModels? sender,
  }) {
    return UnifiedNotificationEntity(
      id: 'notification_${notification.id}',
      type: 'notification',
      title: notification.title,
      body: notification.body,
      timestamp: notification.timestamp,
      data: notification.dataPayload ?? {},
      isRead: notification.isRead,
      targetUserId: notification.targetFirebaseUID,
      senderId: sender?.userID ?? 'system',
      senderName: sender?.name ?? 'النظام',
      senderRole: sender?.role ?? 'System',
      relatedId: notification.id,
      icon: 'notifications',
      actionType: 'view_notification',
    );
  }
}*/