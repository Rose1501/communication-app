
import 'package:complaint_repository/complaint_repository.dart';

abstract class ComplaintRepository {
  // إرسال شكوى جديدة
  Future<ComplaintModel> sendComplaint(ComplaintModel complaint);

  // جلب جميع شكاوى الطالب
  Future<List<ComplaintModel>> getStudentComplaints(String studentID);

  // جلب الشكاوى الموجهة لمسؤول معين
  Future<List<ComplaintModel>> getComplaintsForRole(String targetRole);

  // جلب جميع الشكاوى (للمدير العام)
  Future<List<ComplaintModel>> getAllComplaints();

  // تحديث حالة الشكوى
  Future<void> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? adminReply,
    String? assignedAdmin,
  });

  // حذف شكوى
  Future<void> deleteComplaint(String complaintId);

  // حذف جميع الشكاوى
  Future<void> deleteAllComplaints();
}