part of 'subjective_bloc.dart';

sealed class SubjectiveEvent extends Equatable {
  const SubjectiveEvent();

  @override
  List<Object> props() => [];
}

// ========== 🎯 أحداث المجموعات ==========

/// 👨‍🏫 جلب مجموعات الدكتور
class LoadDoctorGroupsEvent extends SubjectiveEvent {
  final String doctorId;

  const LoadDoctorGroupsEvent(this.doctorId);

  @override
  List<Object> props() => [doctorId];
}

/// 👨‍🎓 جلب مجموعات الطالب
class LoadStudentGroupsEvent extends SubjectiveEvent {
  final String studentId;

  const LoadStudentGroupsEvent(this.studentId);

  @override
  List<Object> props() => [studentId];
}

// ✅ حدث تهيئة الفصل الحالي
class InitializeCurrentSemesterEvent extends SubjectiveEvent {
  const InitializeCurrentSemesterEvent();
}

/// 📚 جلب المحتوى التعليمي الكامل للمجموعة
class LoadGroupSubjectiveContentEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadGroupSubjectiveContentEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [courseId, groupId];
}

// ========== 📚 أحداث المناهج ==========

class LoadCurriculaEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadCurriculaEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [ courseId, groupId];
}

class AddCurriculumToMultipleGroupsEvent extends SubjectiveEvent {
  final String courseId;
  final List<String> groupIds;
  final CurriculumModel curriculum;
  final File? file;

  const AddCurriculumToMultipleGroupsEvent({
    required this.courseId,
    required this.groupIds,
    required this.curriculum,
    this.file,
  });

  @override
  List<Object> props() => [ courseId, groupIds, curriculum, file ?? ''];
}

class UpdateCurriculumEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final CurriculumModel curriculum;
  final File? file;

  const UpdateCurriculumEvent({
    required this.courseId,
    required this.groupId,
    required this.curriculum,
    this.file,
  });

  @override
  List<Object> props() => [ courseId, groupId, curriculum, file ?? ''];
}

class DeleteCurriculumEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String curriculumId;

  const DeleteCurriculumEvent({
    required this.courseId,
    required this.groupId,
    required this.curriculumId,
  });

  @override
  List<Object> props() => [ courseId, groupId, curriculumId];
}

// ========== 📝 أحداث الواجبات ==========

class LoadHomeworksEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadHomeworksEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [courseId, groupId];
}

class AddHomeworkToMultipleGroupsEvent extends SubjectiveEvent {
  final String courseId;
  final List<String> groupIds;
  final HomeworkModel homework;
  final File? file; 

  const AddHomeworkToMultipleGroupsEvent({
    required this.courseId,
    required this.groupIds,
    required this.homework,
    this.file,
  });

  @override
  List<Object> props() => [courseId, groupIds, homework, file ?? ''];
}

class UpdateHomeworkEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final HomeworkModel homework;
  final File? file;

  const UpdateHomeworkEvent({
    required this.courseId,
    required this.groupId,
    required this.homework,
    this.file,
  });

  @override
  List<Object> props() => [ courseId, groupId, homework, file ?? ''];
}

class DeleteHomeworkEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String homeworkId;

  const DeleteHomeworkEvent({
    required this.courseId,
    required this.groupId,
    required this.homeworkId,
  });

  @override
  List<Object> props() => [ courseId, groupId, homeworkId];
}

/// 👨‍🎓 حدث جلب تسليمات الواجب
class LoadHomeworkSubmissionsEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String homeworkId;

  const LoadHomeworkSubmissionsEvent({
    required this.courseId,
    required this.groupId,
    required this.homeworkId,
  });

  @override
  List<Object> props() => [ courseId, groupId, homeworkId];
}

/// 📊 حدث جلب إحصائيات الواجب
class LoadHomeworkStatisticsEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String homeworkId;

  const LoadHomeworkStatisticsEvent({
    required this.courseId,
    required this.groupId,
    required this.homeworkId,
  });

  @override
  List<Object> props() => [courseId, groupId, homeworkId];
}
// ========== 👨‍🎓 أحداث إرسال الواجبات ==========

class SubmitHomeworkEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String homeworkId;
  final StudentHomeworkModel submission;

  const SubmitHomeworkEvent({
    required this.courseId,
    required this.groupId,
    required this.homeworkId,
    required this.submission,
  });

  @override
  List<Object> props() => [courseId, groupId, homeworkId, submission];
}

class GradeHomeworkEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String homeworkId;
  final String studentId;
  final double mark;

  const GradeHomeworkEvent({
    required this.courseId,
    required this.groupId,
    required this.homeworkId,
    required this.studentId,
    required this.mark,
  });

  @override
  List<Object> props() => [courseId, groupId, homeworkId, studentId, mark];
}
// ========== 📢 أحداث الإعلانات  ==========================

class LoadAdvertisementsEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadAdvertisementsEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [ courseId, groupId];
}

class AddAdvertisementToMultipleGroupsEvent extends SubjectiveEvent {
  final String courseId;
  final List<String> groupIds;
  final AdvertisementModel advertisement;
  final File? file;

  const AddAdvertisementToMultipleGroupsEvent({
    required this.courseId,
    required this.groupIds,
    required this.advertisement,
    this.file,
  });

  @override
  List<Object> props() => [ courseId, groupIds, advertisement, file ?? ''];
}

class UpdateAdvertisementEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final AdvertisementModel advertisement;
  final File? file;

  const UpdateAdvertisementEvent({
    required this.courseId,
    required this.groupId,
    required this.advertisement,
    this.file,
  });

  @override
  List<Object> props() => [ courseId, groupId, advertisement , file ?? ''];
}

class DeleteAdvertisementEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String advertisementId;

  const DeleteAdvertisementEvent({
    required this.courseId,
    required this.groupId,
    required this.advertisementId,
  });

  @override
  List<Object> props() => [courseId, groupId, advertisementId];
}
// ========== 📊 أحداث الإحصائيات والطلاب ==========

class LoadGroupStatisticsEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadGroupStatisticsEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [courseId, groupId];
}

class LoadGroupStudentsEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadGroupStudentsEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [ courseId, groupId];
}
/// ================📊 أحداث درجات الامتحانات=================================
class LoadExamGradesEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;

  const LoadExamGradesEvent({
    required this.courseId,
    required this.groupId,
  });

  @override
  List<Object> props() => [courseId, groupId];
}

class AddExamGradeEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final ExamGradeModel examGrade;

  const AddExamGradeEvent({
    required this.courseId,
    required this.groupId,
    required this.examGrade,
  });

  @override
  List<Object> props() => [courseId, groupId, examGrade];
}

/// 🗑️ حدث حذف درجة امتحان
class DeleteExamGradeEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String examGradeId;

  const DeleteExamGradeEvent({
    required this.courseId,
    required this.groupId,
    required this.examGradeId,
  });

  @override
  List<Object> props() => [courseId, groupId, examGradeId];
}

/// 🗑️ حدث حذف جميع درجات عمود امتحان
class DeleteExamColumnGradesEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String examType;

  const DeleteExamColumnGradesEvent({
    required this.courseId,
    required this.groupId,
    required this.examType,
  });

  @override
  List<Object> props() => [courseId, groupId, examType];
}
/// ====================📝 أحداث الحضور والغياب============================
class LoadAttendanceEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final DateTime date;

  const LoadAttendanceEvent({
    required this.courseId,
    required this.groupId,
    required this.date,
  });

  @override
  List<Object> props() => [courseId, groupId, date];
}

class UpdateAttendanceEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final AttendanceRecordModel attendance;

  const UpdateAttendanceEvent({
    required this.courseId,
    required this.groupId,
    required this.attendance,
  });

  @override
  List<Object> props() => [ courseId, groupId, attendance];
}
/// ====================📅 أحداث المحاضرات السابقة============================
class LoadLecturesEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String? doctorId;

  const LoadLecturesEvent({
    required this.courseId,
    required this.groupId,
    this.doctorId,
  });

  @override
  List<Object> props() => [courseId, groupId, doctorId ?? ''];
}

class AddLectureEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final AttendanceRecordModel lecture;
  final String doctorId;

  const AddLectureEvent({
    required this.courseId,
    required this.groupId,
    required this.lecture,
    required this.doctorId,
  });

  @override
  List<Object> props() => [courseId, groupId, lecture, doctorId];
}

class UpdateLectureEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final AttendanceRecordModel lecture;
  final String doctorId;

  const UpdateLectureEvent({
    required this.courseId,
    required this.groupId,
    required this.lecture,
    required this.doctorId,
  });

  @override
  List<Object> props() => [ courseId, groupId, lecture, doctorId];
}

class DeleteLectureEvent extends SubjectiveEvent {
  final String courseId;
  final String groupId;
  final String lectureId;
  final String doctorId;

  const DeleteLectureEvent({
    required this.courseId,
    required this.groupId,
    required this.lectureId,
    required this.doctorId,
  });

  @override
  List<Object> props() => [ courseId, groupId, lectureId, doctorId];
}
