part of 'semester_courses_bloc.dart';

enum SemesterCoursesStatus { initial, loading, success, error }

class SemesterCoursesState extends Equatable {
  final SemesterCoursesStatus status;
  final SemesterModel? currentSemester;
  final List<CoursesModel> semesterCourses;
  final List<CourseModel> availableCourses;
  final List<CourseModel> filteredCourses;
  final String errorMessage;
  final String successMessage;
  final bool isSearching;
  // ✅ بيانات جديدة لدعم CourseSetupScreen
  final List<StudentModel> groupStudents;
  final String? selectedGroupId;
  final Map<String, bool> groupsLoadingState;
  final Map<String, int> groupsStudentsCount;

  const SemesterCoursesState({
    this.status = SemesterCoursesStatus.initial,
    this.currentSemester,
    this.semesterCourses = const [],
    this.availableCourses = const [],
    this.filteredCourses = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.isSearching = false,
    this.groupStudents = const [],
    this.selectedGroupId,
    this.groupsLoadingState = const {},
    this.groupsStudentsCount = const {},
  });

  SemesterCoursesState copyWith({
    SemesterCoursesStatus? status,
    SemesterModel? currentSemester,
    List<CoursesModel>? semesterCourses,
    List<CourseModel>? availableCourses,
    List<CourseModel>? filteredCourses,
    String? errorMessage,
    String? successMessage,
    bool? isSearching,
    List<StudentModel>? groupStudents,
    String? selectedGroupId,
    Map<String, bool>? groupsLoadingState,
    Map<String, int>? groupsStudentsCount,
  }) {
    return SemesterCoursesState(
      status: status ?? this.status,
      currentSemester: currentSemester ?? this.currentSemester,
      semesterCourses: semesterCourses ?? this.semesterCourses,
      availableCourses: availableCourses ?? this.availableCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isSearching: isSearching ?? this.isSearching,
      groupStudents: groupStudents ?? this.groupStudents,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      groupsLoadingState: groupsLoadingState ?? this.groupsLoadingState,
      groupsStudentsCount: groupsStudentsCount ?? this.groupsStudentsCount,
    );
  }

  @override
  List<Object?> props() => [
        status,
        currentSemester,
        semesterCourses,
        availableCourses,
        filteredCourses,
        errorMessage,
        successMessage,
        isSearching,
        groupStudents,
        selectedGroupId,
        groupsLoadingState,
        groupsStudentsCount,
      ];
}