import 'package:semester_repository/semester_repository.dart';
/*
 * 📅 مسؤول عن عمليات الفصول والمواد المضافَة
 * 
 * الهيكل:
 * الفصول → المواد → المجموعات → الطلاب
 * 
 * العمليات المتسلسلة:
 * 1. حذف الفصل ← حذف جميع مواده
 * 2. حذف المادة ← حذف جميع مجموعاتها
 * 3. حذف المجموعة ← حذف جميع طلابها
 */
abstract class SemesterRepository {
  /// جلب المواد التي يشرف عليها دكتور محدد في الفصل الحالي
  Future<List<CoursesModel>> getCoursesByGroupDoctor(String doctorId);

  /// جلب المواد التي يوجد بها طالب محدد في الفصل الحالي
  Future<List<CoursesModel>> getCoursesByStudent(String studentId);

  // جلب جميع الفصول الدراسية
  Future<List<SemesterModel>> getAllSemesters();
  
  // جلب الفصل الحالي
  Future<SemesterModel?> getCurrentSemester();
  
  // إنشاء فصل دراسي جديد
  Future<SemesterModel> createSemester(SemesterModel semester);
  
  // تحديث فصل دراسي
  Future<void> updateSemester(SemesterModel semester);
  
  // حذف فصل دراسي
  Future<void> deleteSemester(String semesterId);
  
  // جلب جميع المواد في فصل دراسي
  Future<List<CoursesModel>> getSemesterCourses(String semesterId);
  
  // جلب مادة محددة
  Future<CoursesModel> getCourse(String semesterId, String courseId);
  
  // إضافة مادة جديدة
  Future<CoursesModel> addCourse(String semesterId, CoursesModel course);
  
  // تحديث مادة
  Future<void> updateCourse(String semesterId, CoursesModel course);
  
  // حذف مادة
  Future<void> deleteCourse(String semesterId, String courseId);
  
  // جلب المجموعات في مادة
  Future<List<GroupModel>> getCourseGroups(String semesterId, String courseId);
  
  // إضافة مجموعة جديدة
  Future<GroupModel> addGroup(String semesterId, String courseId, GroupModel group);
  
  // تحديث مجموعة
  Future<void> updateGroup(String semesterId, String courseId, GroupModel group);
  
  // حذف مجموعة
  Future<void> deleteGroup(String semesterId, String courseId, String groupId);
  // إدارة الطلاب
  Future<List<StudentModel>> getGroupStudents(String semesterId, String courseId, String groupId);
  Future<StudentModel> addStudent(String semesterId, String courseId, String groupId, StudentModel student);
  Future<void> updateStudent(String semesterId, String courseId, String groupId, StudentModel student);
  Future<void> deleteStudent(String semesterId, String courseId, String groupId, String studentId);
  
  // استيراد الطلاب من Excel
  Future<List<StudentModel>> importStudentsFromExcel({
    required String semesterId,
    required String courseId,
    required String groupId,
    required List<Map<String, dynamic>> excelData,
  });
  
  // نسخ الطلاب من مجموعة إلى أخرى
  Future<void> copyStudentsToGroup({
    required String sourceSemesterId,
    required String sourceCourseId,
    required String sourceGroupId,
    required String targetSemesterId,
    required String targetCourseId,
    required String targetGroupId,
  });
  // ✅ دالة لتنظيف البيانات التالفة
Future<void> cleanupCorruptedData() ;
}