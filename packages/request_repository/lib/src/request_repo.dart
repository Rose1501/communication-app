import 'models/student_request_model.dart';

abstract class RequestRepository {
  // إرسال طلب جديد
  Future<StudentRequestModel> sendRequest(StudentRequestModel request);

  // جلب جميع طلبات الطالب
  Future<List<StudentRequestModel>> getStudentRequests(String studentID);

  // جلب جميع الطلبات (للمدير)
  Future<List<StudentRequestModel>> getAllRequests();

  // تحديث حالة الطلب مع إمكانية إضافة رد
  Future<void> updateRequestStatus(String requestId, String status, {String? adminReply});

  // حذف طلب
  Future<void> deleteRequest(String requestId);

  // 🔥 حذف جميع الطلبات
  Future<void> deleteAllRequests();
}
