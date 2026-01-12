part of 'semester_courses_bloc.dart';

abstract class SemesterCoursesEvent extends Equatable {
  const SemesterCoursesEvent();

  @override
  List<Object> props() => [];
}

class LoadSemesterCourses extends SemesterCoursesEvent {
  const LoadSemesterCourses();
}

class AddCourseToSemester extends SemesterCoursesEvent {
  final CoursesModel course;
  const AddCourseToSemester(this.course);
}

class RemoveCourseFromSemester extends SemesterCoursesEvent {
  final String courseId;
  const RemoveCourseFromSemester(this.courseId);
}

class LoadAvailableCourses extends SemesterCoursesEvent {
  const LoadAvailableCourses();
}

class SearchAvailableCourses extends SemesterCoursesEvent {
  final String searchTerm;
  const SearchAvailableCourses(this.searchTerm);
}

class ImportCoursesToSemester extends SemesterCoursesEvent {
  final List<CoursesModel> courses;
  const ImportCoursesToSemester(this.courses);
}

class RefreshSemesterCourses extends SemesterCoursesEvent {
  const RefreshSemesterCourses();
}

// ✅ الأحداث الجديدة لدعم CourseSetupScreen
class AddCourseWithGroups extends SemesterCoursesEvent {
  final CoursesModel course;
  final List<GroupModel> groups;
  const AddCourseWithGroups(this.course, this.groups);
}

class AddStudentsToGroup extends SemesterCoursesEvent {
  final String courseId;
  final String groupId;
  final List<StudentModel> students;
  const AddStudentsToGroup({
    required this.courseId,
    required this.groupId,
    required this.students,
  });
}

class LoadGroupStudents extends SemesterCoursesEvent {
  final String courseId;
  final String groupId;
  const LoadGroupStudents({
    required this.courseId,
    required this.groupId,
  });
}

class RemoveStudentFromGroup extends SemesterCoursesEvent {
  final String courseId;
  final String groupId;
  final String studentId;
  const RemoveStudentFromGroup({
    required this.courseId,
    required this.groupId,
    required this.studentId,
  });
}

class UpdateCourseWithGroups extends SemesterCoursesEvent {
  final String semesterId;
  final CoursesModel course;
  final List<GroupModel> groups;
  
  const UpdateCourseWithGroups({
    required this.semesterId,
    required this.course,
    required this.groups,
  });
}

class ClearMessagesSemester extends SemesterCoursesEvent {
  const ClearMessagesSemester();
}

/// حدث لجلب الفصل الدراسي النشط فقط (بدون المواد)
class GetCurrentSemester extends SemesterCoursesEvent {
  const GetCurrentSemester();
  
  @override
  List<Object> props() => [];
}