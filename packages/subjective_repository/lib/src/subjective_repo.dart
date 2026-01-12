import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';

abstract class SubjectiveRepository {
  // ========== 🎯 دوال للربط مع Semester ==========
  /// 🔍 جلب معرف الفصل الدراسي الحالي النشط
  Future<String> getCurrentSemesterId();
  /// 🔍 جلب جميع المجموعات التي يشرف عليها دكتور محدد
  Future<List<CoursesModel>> getDoctorGroups(String doctorId);
  
  /// 👨‍🎓 جلب جميع المجموعات المسجل فيها طالب محدد
  Future<List<CoursesModel>> getStudentGroups(String studentId);
  
  /// 👥 جلب جميع طلاب المجموعة
  Future<List<StudentModel>> getGroupStudents({
  required String semesterId,
  required String courseId,
  required String groupId,
  });
  
  /// 📚 جلب المحتوى التعليمي (subjective) لمجموعة محددة
  Future<SubjectiveContentModel> getGroupSubjectiveContent({
    required String semesterId,
    required String courseId,
    required String groupId,
  });

  // ================== 📚 دوال إدارة اعلانات ==================
  /// 📢 جلب جميع إعلانات مجموعة
Future<List<AdvertisementModel>> getGroupAdvertisements({
  required String semesterId,
  required String courseId,
  required String groupId,
});
  /// ➕ إضافة إعلان جديد لمجموعة
Future<void> addAdvertisementToMultipleGroups({
  required String semesterId,
  required String courseId,
  required List<String> groupIds,
  required AdvertisementModel advertisement,
});
/// ✏️ تحديث إعلان موجود
Future<void> updateAdvertisement({
  required String semesterId,
  required String courseId,
  required String groupId,
  required AdvertisementModel advertisement,
});
/// 🗑️ حذف إعلان
Future<void> deleteAdvertisement({
  required String semesterId,
  required String courseId,
  required String groupId,
  required String advertisementId,
});
  // ================== 📚 دوال إدارة المناهج ==================
  
  /// 📖 جلب جميع مناهج مجموعة 
  Future<List<CurriculumModel>> getGroupCurricula({
    required String semesterId,
    required String courseId,
    required String groupId,
  });
  
  /// ➕ إضافة منهج جديد لمجموعة 
  Future<void> addCurriculumToMultipleGroups({
  required String semesterId,
  required String courseId,
  required List<String> groupIds,
  required CurriculumModel curriculum,
});
/// ✏️ تحديث منهج موجود
  Future<void> updateCurriculum({
    required String semesterId,
    required String courseId,
    required String groupId,
    required CurriculumModel curriculum,
  });
/// 🗑️ حذف منهج
  Future<void> deleteCurriculum({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String curriculumId,
  });

  // ============= 📝 دوال إدارة الواجبات ===================
  
  /// 📋 جلب جميع واجبات مجموعة 
  Future<List<HomeworkModel>> getGroupHomeworks({
    required String semesterId,
    required String courseId,
    required String groupId,
  });
  
  /// ➕ إضافة واجب جديد لمجموعة 
  Future<void> addHomeworkToMultipleGroups({
  required String semesterId,
  required String courseId,
  required List<String> groupIds,
  required HomeworkModel homework,
});
/// ✏️ تحديث واجب موجود
  Future<void> updateHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required HomeworkModel homework,
  });
/// 🗑️ حذف واجب
  Future<void> deleteHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
  });

  // ================== 👨‍🎓 دوال إدارة إجابات الطلاب  =================
  
  /// 📤 تقديم إجابة واجب من قبل طالب
  Future<StudentHomeworkModel> submitHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
    required StudentHomeworkModel submission,
  });

  /// 🎯 تقييم إجابة طالب لواجب محدد
  Future<void> gradeHomework({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
    required String studentId,
    required double mark,
  });

  /// 📥 جلب جميع إجابات الطلاب لواجب محدد
  Future<List<StudentHomeworkModel>> getHomeworkSubmissions({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String homeworkId,
  });

  // ========== 📊 دوال درجات الامتحانات ==========
  Future<List<ExamGradeModel>> getExamGrades({
    required String semesterId,
    required String courseId,
    required String groupId,
  });
  
  Future<void> addExamGrade({
    required String semesterId,
    required String courseId,
    required String groupId,
    required ExamGradeModel examGrade,
  });

  /// 🗑️ حذف درجة امتحان محددة
  Future<void> deleteExamGrade({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String examGradeId,
  });

  /// 🗑️ حذف جميع درجات نوع امتحان محدد
  Future<void> deleteExamColumnGrades({
    required String semesterId,
    required String courseId,
    required String groupId,
    required String examType,
  });

  // ========== 📝 دوال الحضور والغياب ==========
  Future<List<AttendanceRecordModel>> getAttendance({
    required String semesterId,
    required String courseId,
    required String groupId,
    required DateTime date,
  });
  
  Future<void> updateAttendance({
    required String semesterId,
    required String courseId,
    required String groupId,
    required AttendanceRecordModel attendance,
  });
/// 📅 دوال المحاضرات السابقة
Future<List<AttendanceRecordModel>> getGroupLectures({
  required String semesterId,
  required String courseId,
  required String groupId,
  String? doctorId,
});

Future<void> addLecture({
  required String semesterId,
  required String courseId,
  required String groupId,
  required AttendanceRecordModel lecture,
  required String doctorId,
});

Future<void> updateLecture({
  required String semesterId,
  required String courseId,
  required String groupId,
  required AttendanceRecordModel lecture,
  required String doctorId,
});

Future<void> deleteLecture({
  required String semesterId,
  required String courseId,
  required String groupId,
  required String lectureId,
  required String doctorId,
});

  Future<void> checkCurriculumStructure(String semesterId, String courseId, String groupId);

}
