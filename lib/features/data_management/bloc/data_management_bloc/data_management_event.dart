part of 'data_management_bloc.dart';

abstract class DataManagementEvent extends Equatable {
  const DataManagementEvent();

  @override
  List<Object> props() => [];
}

class LoadAllData extends DataManagementEvent {
  const LoadAllData();
}

class LoadCourses extends DataManagementEvent {
  const LoadCourses();
}

class LoadSemesters extends DataManagementEvent {
  const LoadSemesters();
}

class AddCourse extends DataManagementEvent {
  final CourseModel course;
  const AddCourse(this.course);
}

class UpdateCourse extends DataManagementEvent {
  final CourseModel course;
  const UpdateCourse(this.course);
}

class DeleteCourse extends DataManagementEvent {
  final String courseId;
  const DeleteCourse(this.courseId);
}

class AddSemester extends DataManagementEvent {
  final SemesterModel semester;
  const AddSemester(this.semester);
}

class UpdateSemester extends DataManagementEvent {
  final SemesterModel semester;
  const UpdateSemester(this.semester);
  @override
  List<Object> props() => [semester];
}

class DeleteSemester extends DataManagementEvent {
  final String semesterId;
  const DeleteSemester(this.semesterId);
  @override
  List<Object> props() => [semesterId];
}

class ImportCoursesFromExcel  extends DataManagementEvent {
  final List<Map<String, dynamic>> excelData;
  const ImportCoursesFromExcel(this.excelData);
  @override
  List<Object> props() => [excelData];
}

class ImportStudentsFromExcel extends DataManagementEvent {
  final String semesterId;
  final String courseId;
  final String groupId;
  final List<Map<String, dynamic>> excelData;
  const ImportStudentsFromExcel({
    required this.semesterId,
    required this.courseId,
    required this.groupId,
    required this.excelData,
  });
  @override
  List<Object> props() => [semesterId, courseId, groupId, excelData];
}

class SearchCourses extends DataManagementEvent {
  final String searchTerm;
  const SearchCourses(this.searchTerm);
}

class RefreshData extends DataManagementEvent {
  const RefreshData();
}

class CleanupCorruptedData extends DataManagementEvent {
  const CleanupCorruptedData();
}

class AddCoursesToActiveSemester extends DataManagementEvent {
  final List<String> courseIds;
  const AddCoursesToActiveSemester(this.courseIds);
}

// 🔥 إضافة حدث جديد لمسح الرسائل
class ClearMessages extends DataManagementEvent {
  const ClearMessages();
}