import 'package:teacher_data_repository/teacher_data_repository.dart';

abstract class TeacherDataRepository {
  // الحصول على بيانات الأستاذ 
  Future<TeacherDataModel> getTeacherData(String teacherId);
  
  // تحديث بيانات الأستاذ 
  Future<void> updateTeacherData(TeacherDataModel teacherData);
  
  // إضافة ساعات مكتبية (متعددة في مرة واحدة)
  Future<void> addOfficeHours(String teacherId, List<OfficeHoursModel> officeHoursList);
  
  // جلب الساعات المكتبية 
  Future<List<OfficeHoursModel>> getOfficeHours(String teacherId);
  
  // تحديث ساعات مكتبية
  Future<void> updateOfficeHours(String teacherId, OfficeHoursModel officeHours);
  
  // حذف ساعات مكتبية
  Future<void> deleteOfficeHours(String teacherId, String officeHoursId);
  
  // إضافة مواد دراسية (متعددة في مرة واحدة)
  Future<void> addTeachingCourses(String teacherId, List<TeachingCourseModel> courses);
  
  // جلب المواد الدراسية للدكتور
  Future<List<TeachingCourseModel>> getTeachingCourses(String teacherId);
  
  // حذف مادة دراسية
  Future<void> deleteTeachingCourse(String teacherId, String courseId);
  
  //  دالة حذف جميع المواد الدراسية
  Future<void> deleteAllTeachingCourses(String teacherId);
  
  // دالة تحديث المواد الدراسية
  Future<void> updateTeachingCourses(String teacherId, List<TeachingCourseModel> courses);
  
  // أرشفة منهج (متعددة في مرة واحدة)
  Future<void> archiveCurricula(String teacherId,String teacherName, List<ArchivedCurriculumModel> curricula);
  
  // الحصول على المناهج المؤرشفة لأستاذ
  Future<List<ArchivedCurriculumModel>> getArchivedCurricula(String teacherId);
  
  // استعادة منهج من الأرشيف
  Future<bool> restoreCurriculum(String teacherId, String archiveId);
  
  // حذف منهج من الأرشيف
  Future<void> deleteArchivedCurriculum(String teacherId, String archiveId);
  
  // البحث في المناهج المؤرشفة
  Future<List<ArchivedCurriculumModel>> searchArchivedCurricula(
    String teacherId, 
    String query
  );
}