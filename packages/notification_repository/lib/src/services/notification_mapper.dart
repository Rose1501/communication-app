import 'package:complaint_repository/complaint_repository.dart';
import 'package:request_repository/request_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
import 'package:advertisement_repository/advertisement_repository.dart';
import 'package:notification_repository/notification_repository.dart';

class NotificationMapper {
  // إعلان عام (من advertisement_repository)
  static NotificationModel fromGeneralAdvertisement(AdvertisemenModel advertisement) {
    return NotificationModel(
      id: 'advertisement_${advertisement.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'advertisement',
      title: '📢 ${advertisement.user.name}',
      body: advertisement.description.length > 100 
          ? '${advertisement.description.substring(0, 100)}...' 
          : advertisement.description,
      timestamp: DateTime.now(),
      sourceEntityId: advertisement.id,
      sourceRepository: 'advertisement',
      metadata: {
        'advertisementId': advertisement.id,
        'description': advertisement.description,
        'custom': advertisement.custom,
        'publisher': advertisement.user.name,
        'publisherId': advertisement.user.firebaseUID,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    );
  }

  // 🔥 **إضافة دالة جديدة للإشعارات البسيطة**
  static NotificationModel createSimpleNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    String? targetFirebaseUID,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: '${type}_$id',
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      targetFirebaseUID: targetFirebaseUID,
      metadata: {
        ...metadata ?? {},
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    );
  }

  // إعلان مجموعة (من subjective_repository)
  static NotificationModel fromGroupAdvertisement(AdvertisementModel advertisement, String studentId) {
    return NotificationModel(
      id: 'group_ad_${advertisement.id}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'group_advertisement',
      title: 'إعلان جديد في المجموعة',
      body: 'إعلان جديد: ${advertisement.title}',
      timestamp: DateTime.now(),
      targetFirebaseUID: studentId,
      sourceEntityId: advertisement.id,
      sourceRepository: 'subjective_advertisement',
      metadata: {
        'advertisementId': advertisement.id,
        'title': advertisement.title,
        'description': advertisement.description,
        'isImportant': advertisement.isImportant,
        'file': advertisement.file,
      },
    );
  }

  // شكوى -> إشعار
  static NotificationModel fromComplaint(ComplaintModel complaint) {
    return NotificationModel(
      id: 'complaint_${complaint.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'complaint',
      title: 'شكوى جديدة',
      body: 'تم إرسال شكوى جديدة: ${complaint.title}',
      timestamp: DateTime.now(),
      sourceEntityId: complaint.id,
      sourceRepository: 'complaint',
      metadata: {
        'complaintId': complaint.id,
        'studentId': complaint.studentID,
        'studentName': complaint.studentName,
        'status': complaint.status,
        'targetRole': complaint.targetRole,
      },
    );
  }

  // طلب -> إشعار
  static NotificationModel fromRequest(StudentRequestModel request) {
    return NotificationModel(
      id: 'request_${request.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'request',
      title: 'طلب جديد',
      body: 'طلب جديد من ${request.name}: ${request.requestType}',
      timestamp: DateTime.now(),
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
  }

  // واجب -> إشعار
  static NotificationModel fromHomework(HomeworkModel homework, String studentId) {
    return NotificationModel(
      id: 'homework_${homework.id}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'homework',
      title: 'واجب جديد',
      body: 'تم نشر واجب جديد: ${homework.title}',
      timestamp: DateTime.now(),
      targetFirebaseUID: studentId,
      sourceEntityId: homework.id,
      sourceRepository: 'subjective',
      metadata: {
        'homeworkId': homework.id,
        'title': homework.title,
        'endDate': homework.end.toIso8601String(),
        'maxMark': homework.maxMark,
      },
    );
  }

  // منهج -> إشعار
  static NotificationModel fromCurriculum(CurriculumModel curriculum, String studentId) {
    return NotificationModel(
      id: 'curriculum_${curriculum.id}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'curriculum',
      title: 'منهج جديد',
      body: 'تم إضافة منهج جديد: ${curriculum.description}',
      timestamp: DateTime.now(),
      targetFirebaseUID: studentId,
      sourceEntityId: curriculum.id,
      sourceRepository: 'subjective',
      metadata: {
        'curriculumId': curriculum.id,
        'description': curriculum.description,
        'fileUrl': curriculum.file,
      },
    );
  }

  // حضور -> إشعار
  static NotificationModel fromAttendance(AttendanceRecordModel attendance, String studentId, bool isPresent) {
    return NotificationModel(
      id: 'attendance_${attendance.id}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'attendance',
      title: isPresent ? 'تم تسجيل حضورك' : 'تم تسجيل غيابك',
      body: isPresent 
          ? 'تم تسجيل حضورك في محاضرة: ${attendance.lectureTitle}'
          : 'تم تسجيل غيابك في محاضرة: ${attendance.lectureTitle}',
      timestamp: DateTime.now(),
      targetFirebaseUID: studentId,
      sourceEntityId: attendance.id,
      sourceRepository: 'subjective',
      metadata: {
        'attendanceId': attendance.id,
        'lectureTitle': attendance.lectureTitle,
        'date': attendance.date.toIso8601String(),
        'isPresent': isPresent,
      },
    );
  }

  // امتحان -> إشعار
  static NotificationModel fromExamGrade(ExamGradeModel examGrade) {
    return NotificationModel(
      id: 'exam_${examGrade.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'exam',
      title: 'درجة امتحان',
      body: 'تم إضافة درجة ${examGrade.examType}: ${examGrade.grade}/${examGrade.maxGrade}',
      timestamp: DateTime.now(),
      targetFirebaseUID: examGrade.studentId,
      sourceEntityId: examGrade.id,
      sourceRepository: 'subjective',
      metadata: {
        'examGradeId': examGrade.id,
        'examType': examGrade.examType,
        'grade': examGrade.grade,
        'maxGrade': examGrade.maxGrade,
        'percentage': examGrade.grade / examGrade.maxGrade * 100,
      },
    );
  }

  // تحديث حالة شكوى -> إشعار
  static NotificationModel fromComplaintStatusUpdate(ComplaintModel complaint, String oldStatus) {
    String statusText = '';
    switch (complaint.status) {
      case 'in_progress':
        statusText = 'جاري المعالجة';
        break;
      case 'resolved':
        statusText = 'تم الحل';
        break;
      case 'rejected':
        statusText = 'مرفوض';
        break;
    }

    return NotificationModel(
      id: 'complaint_update_${complaint.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'complaint',
      title: 'تحديث حالة الشكوى',
      body: 'تم تحديث حالة شكواك "${complaint.title}" إلى: $statusText',
      timestamp: DateTime.now(),
      targetFirebaseUID: complaint.studentID,
      sourceEntityId: complaint.id,
      sourceRepository: 'complaint',
      metadata: {
        'complaintId': complaint.id,
        'oldStatus': oldStatus,
        'newStatus': complaint.status,
        'adminReply': complaint.adminReply,
        'updatedAt': complaint.updatedAt?.toIso8601String(),
      },
    );
  }

  // رد على طلب -> إشعار
static NotificationModel fromRequestReply(StudentRequestModel request) {
  return NotificationModel(
    id: 'request_reply_${request.id}_${DateTime.now().millisecondsSinceEpoch}',
    type: 'request',
    title: 'رد على طلبك',
    body: 'تم الرد على طلبك "${request.requestType}"، الحالة: ${request.status}',
    timestamp: DateTime.now(),
    targetFirebaseUID: null, // سيتم تعيينه لاحقاً
    sourceEntityId: request.id,
    sourceRepository: 'request',
    metadata: {
      'requestId': request.id,
      'studentId': request.studentID,
      'studentName': request.name,
      'requestType': request.requestType,
      'status': request.status,
      'adminReply': request.adminReply,
      'updatedAt': DateTime.now().toIso8601String(),
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    },
  );
}

  // تقييم واجب -> إشعار
  static NotificationModel fromHomeworkGrade(String homeworkId, String studentId, double mark, double maxMark) {
    return NotificationModel(
      id: 'homework_grade_${homeworkId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'homework',
      title: 'تقييم الواجب',
      body: 'تم تقييم واجبك: $mark/$maxMark',
      timestamp: DateTime.now(),
      targetFirebaseUID: studentId,
      sourceEntityId: homeworkId,
      sourceRepository: 'subjective',
      metadata: {
        'homeworkId': homeworkId,
        'mark': mark,
        'maxMark': maxMark,
        'percentage': (mark / maxMark * 100),
      },
    );
  }
}