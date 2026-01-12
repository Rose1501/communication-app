part of 'subjective_bloc.dart';

sealed class SubjectiveState extends Equatable {
  const SubjectiveState();

  @override
  List<Object> props() => [];
}

class SubjectiveInitial extends SubjectiveState {}

class SubjectiveLoading extends SubjectiveState {}

// ========== 🎯 حالات المجموعات ==========

class DoctorGroupsLoadSuccess extends SubjectiveState {
  final List<CoursesModel> courses;

  const DoctorGroupsLoadSuccess(this.courses);

  @override
  List<Object> props() => [courses];
}

class StudentGroupsLoadSuccess extends SubjectiveState {
  final List<CoursesModel> courses;

  const StudentGroupsLoadSuccess(this.courses);

  @override
  List<Object> props() => [courses];
}

class GroupSubjectiveContentLoadSuccess extends SubjectiveState {
  final SubjectiveContentModel content;
  //final GroupStatistics? statistics;

  const GroupSubjectiveContentLoadSuccess({
    required this.content,
    //this.statistics,
  });

  @override
  List<Object> props() => [content, /*statistics ?? GroupStatisticsExtension.empty*/];
}

class GroupStudentsLoadSuccess extends SubjectiveState {
  final List<StudentModel> students;

  const GroupStudentsLoadSuccess(this.students);

  @override
  List<Object> props() => [students];
}

class CurrentSemesterInitialized extends SubjectiveState {
  final String semesterId;
  
  const CurrentSemesterInitialized(this.semesterId);
  
  @override
  List<Object> props() => [semesterId];
}


// ========== 📚 حالات المناهج ==========

class CurriculumLoadSuccess  extends SubjectiveState {
  final List<CurriculumModel> curricula;

  const CurriculumLoadSuccess(this.curricula);

  @override
  List<Object> props() => [curricula];
}
// ========== 📢 حالات الإعلانات ==========

class AdvertisementLoadSuccess extends SubjectiveState {
  final List<AdvertisementModel> advertisements;

  const AdvertisementLoadSuccess(this.advertisements);

  @override
  List<Object> props() => [advertisements];
}
// ========== 📝 حالات الواجبات ==========

class HomeworkLoadSuccess extends SubjectiveState {
  final List<HomeworkModel> homeworks;

  const HomeworkLoadSuccess(this.homeworks);

  @override
  List<Object> props() => [homeworks];
}

class HomeworkSubmissionsLoadSuccess extends SubjectiveState {
  final List<StudentHomeworkModel> submissions;

  const HomeworkSubmissionsLoadSuccess(this.submissions);

  @override
  List<Object> props() => [submissions];
}

// ========== ✅ حالات العمليات ==========

class SubjectiveOperationSuccess extends SubjectiveState {
  final String message;

  const SubjectiveOperationSuccess(this.message);

  @override
  List<Object> props() => [message];
}

class SubjectiveError extends SubjectiveState {
  final String message;

  const SubjectiveError(this.message);

  @override
  List<Object> props() => [message];
}

// ========== 📊 حالات درجات الامتحانات ==========
class ExamGradesLoadSuccess extends SubjectiveState {
  final List<ExamGradeModel> examGrades;

  const ExamGradesLoadSuccess(this.examGrades);

  @override
  List<Object> props() => [examGrades];
}

// ========== 📝 حالات الحضور والغياب ==========
class AttendanceLoadSuccess extends SubjectiveState {
  final List<AttendanceRecordModel> attendanceRecords;

  const AttendanceLoadSuccess(this.attendanceRecords);

  @override
  List<Object> props() => [attendanceRecords];
}

class LecturesLoadSuccess extends SubjectiveState {
  final List<AttendanceRecordModel> lectures;

  const LecturesLoadSuccess(this.lectures);

  @override
  List<Object> props() => [lectures];
}

// ========== 🎯 حالات المحتوى المجمع للمجموعات ==========
class CourseGroupsContentLoadSuccess extends SubjectiveState {
  final Map<String, SubjectiveContentModel> groupsContent;

  const CourseGroupsContentLoadSuccess(this.groupsContent);

  @override
  List<Object> props() => [groupsContent];
}