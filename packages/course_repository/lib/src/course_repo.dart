import 'package:course_repository/course_repository.dart';
/*
 * 📚 مسؤول عن عمليات المواد في Firestore
 * 
 * العمليات:
 * ✅ CRUD الأساسي للمواد
 * 🔍 البحث بالاسم والكود
 * 📤 استيراد من Excel مع معالجة المتطلبات
 * 🧹 تنظيف البيانات التالفة
 */
abstract class CourseRepository {
  // إضافة مادة جديدة
  Future<CourseModel> addCourse(CourseModel course);

  // الحصول على مادة بواسطة ID
  Future<CourseModel> getCourseById(String courseId);

  // الحصول على مادة بواسطة الكود
  Future<CourseModel?> getCourseByCode(String codeCs);

  // الحصول على جميع المواد
  Future<List<CourseModel>> getAllCourses();

  // تحديث مادة
  Future<CourseModel> updateCourse(CourseModel course);

  // حذف مادة
  Future<void> deleteCourse(String courseId);

  // حذف جميع المواد
  Future<void> deleteAllCourses();

  // البحث عن مواد بالاسم
  Future<List<CourseModel>> searchCoursesByName(String searchTerm);

  // استيراد مواد من بيانات Excel (JSON)
  Future<Map<String, dynamic>> importCoursesFromExcelData(List<Map<String, dynamic>> excelData);
// ✅ دالة لتنظيف البيانات التالفة
Future<void> cleanupCorruptedData() ;

}