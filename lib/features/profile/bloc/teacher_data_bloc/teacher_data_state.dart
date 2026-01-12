part of 'teacher_data_bloc.dart';

abstract class TeacherDataState extends Equatable {
  const TeacherDataState();

  @override
  List<Object> props() => [];
}

class TeacherDataInitial extends TeacherDataState {}

class TeacherDataLoading extends TeacherDataState {}

class TeacherDataOperationSuccess extends TeacherDataState {
  final String message;
  const TeacherDataOperationSuccess({required this.message});

  @override
  List<Object> props() => [message];
}

class TeacherDataError extends TeacherDataState {
  final String message;
  const TeacherDataError({required this.message});

  @override
  List<Object> props() => [message];
}

class ArchivedCurriculaLoaded extends TeacherDataState {
  final List<ArchivedCurriculumModel> curricula;
  const ArchivedCurriculaLoaded({required this.curricula});

  @override
  List<Object> props() => [curricula];
}

class SearchArchivedCurriculaResult extends TeacherDataState {
  final List<ArchivedCurriculumModel> results;
  const SearchArchivedCurriculaResult({required this.results});

  @override
  List<Object> props() => [results];
}

class OfficeHoursLoaded extends TeacherDataState {
  final List<OfficeHoursModel> officeHours;
  const OfficeHoursLoaded({required this.officeHours});

  @override
  List<Object> props() => [officeHours];
}

class TeachingCoursesLoaded extends TeacherDataState {
  final List<TeachingCourseModel> teachingCourses;
  const TeachingCoursesLoaded({required this.teachingCourses});

  @override
  List<Object> props() => [teachingCourses];
}

// حالة واحدة تحتوي على كل البيانات
class TeacherProfileDataLoaded extends TeacherDataState {
  final List<OfficeHoursModel> officeHours;
  final List<TeachingCourseModel> teachingCourses;
  
  const TeacherProfileDataLoaded({
    required this.officeHours,
    required this.teachingCourses,
  });

  @override
  List<Object> props() => [officeHours, teachingCourses];
}