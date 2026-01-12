import 'package:semester_repository/semester_repository.dart';

class GroupsCacheService {
  static final GroupsCacheService _instance = GroupsCacheService._internal();
  factory GroupsCacheService() => _instance;
  GroupsCacheService._internal();

  // تخزين مجموعات الطالب
  List<CoursesModel>? _studentCourses;
  String? _studentId;

  // تخزين مجموعات الدكتور
  List<CoursesModel>? _doctorCourses;
  String? _doctorId;

  // 🔄 حفظ مجموعات الطالب
  void cacheStudentGroups(String studentId, List<CoursesModel> courses) {
    _studentCourses = List<CoursesModel>.from(courses);
    _studentId = studentId;
  }

  // 🔄 حفظ مجموعات الدكتور
  void cacheDoctorGroups(String doctorId, List<CoursesModel> courses) {
    _doctorCourses = List<CoursesModel>.from(courses);
    _doctorId = doctorId;
  }

  // 🔍 جلب مجموعات الطالب المخزنة
  List<CoursesModel>? getStudentGroups(String studentId) {
    if (_studentId == studentId && _studentCourses != null) {
      return List<CoursesModel>.from(_studentCourses!);
    }
    return null;
  }

  // 🔍 جلب مجموعات الدكتور المخزنة
  List<CoursesModel>? getDoctorGroups(String doctorId) {
    if (_doctorId == doctorId && _doctorCourses != null) {
      return List<CoursesModel>.from(_doctorCourses!);
    }
    return null;
  }

  // 🗑️ مسح التخزين المؤقت
  void clearCache() {
    _studentCourses = null;
    _studentId = null;
    _doctorCourses = null;
    _doctorId = null;
  }

  // 📊 معلومات التخزين
  void printCacheInfo() {
    print('📊 معلومات التخزين المؤقت:');
    print('   👨‍🎓 مجموعات الطالب: ${_studentCourses?.length ?? 0}');
    print('   👨‍🏫 مواد الدكتور: ${_doctorCourses?.length ?? 0}');
  }
}