part of 'data_management_bloc.dart';

enum DataManagementStatus { initial, loading, success, error }

class DataManagementState extends Equatable {
  final DataManagementStatus status;
  final List<CourseModel> courses;
  final List<SemesterModel> semesters;
  final String errorMessage;
  final String successMessage;
  final bool isSearching;
  final List<CourseModel> searchResults;

  const DataManagementState({
    this.status = DataManagementStatus.initial,
    this.courses = const [],
    this.semesters = const [],
    this.errorMessage = '',
    this.successMessage = '',
    this.isSearching = false,
    this.searchResults = const [],
  });

  DataManagementState copyWith({
    DataManagementStatus? status,
    List<CourseModel>? courses,
    List<SemesterModel>? semesters,
    String? errorMessage,
    String? successMessage,
    bool? isSearching,
    List<CourseModel>? searchResults,
  }) {
    return DataManagementState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      semesters: semesters ?? this.semesters,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object> props() => [
        status,
        courses,
        semesters,
        errorMessage,
        successMessage,
        isSearching,
        searchResults,
      ];
}