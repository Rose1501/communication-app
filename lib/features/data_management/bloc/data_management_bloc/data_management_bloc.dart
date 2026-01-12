import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:course_repository/course_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

part 'data_management_event.dart';
part 'data_management_state.dart';
// SnackBar 
/*
 * 🎛️ بلوك مركزي لإدارة البيانات العامة
 * 
 * الأحداث:
 * 📥 LoadAllData - تحميل جميع البيانات
 * 📚 LoadCourses/LoadSemesters - تحميل جزئي
 * ➕ Add/Update/Delete - عمليات CRUD
 * 📤 ImportFromExcel - استيراد من Excel
 * 🔍 Search - البحث
 * 🔄 Refresh - التحديث
 */
class DataManagementBloc
    extends Bloc<DataManagementEvent, DataManagementState> {
  final CourseRepository courseRepository;
  final SemesterRepository semesterRepository;

  DataManagementBloc({
    required this.courseRepository,
    required this.semesterRepository,
  }) : super(const DataManagementState()) {
    on<LoadAllData>(_onLoadAllData);
    on<LoadCourses>(_onLoadCourses);
    on<LoadSemesters>(_onLoadSemesters);
    on<AddCourse>(_onAddCourse);
    on<UpdateCourse>(_onUpdateCourse);
    on<DeleteCourse>(_onDeleteCourse);
    on<AddSemester>(_onAddSemester);
    on<UpdateSemester>(_onUpdateSemester);
    on<DeleteSemester>(_onDeleteSemester);
    on<ImportCoursesFromExcel>(_onImportCoursesFromExcel);
    on<ImportStudentsFromExcel>(_onImportStudentsFromExcel);
    on<SearchCourses>(_onSearchCourses);
    on<RefreshData>(_onRefreshData);
    on<ClearMessages>(_onClearMessages); 
  }
  Future<void> _onLoadAllData(
  LoadAllData event,
  Emitter<DataManagementState> emit,
) async {
  emit(state.copyWith(
    status: DataManagementStatus.loading,
    errorMessage: '',
    successMessage: '',
    ));
  print('🔄 بدء تحميل جميع البيانات...');
  
  try {
    // ✅ تنظيف البيانات التالفة أولاً
    await courseRepository.cleanupCorruptedData();
    await semesterRepository.cleanupCorruptedData();
    
    final courses = await courseRepository.getAllCourses();
    final semesters = await semesterRepository.getAllSemesters();
    
    print('📊 نتائج التحميل: ${courses.length} مادة, ${semesters.length} فصل');
    
      emit(state.copyWith( status: DataManagementStatus.success,
      courses: courses,
      semesters: semesters,
      ));
  } catch (e) {
    print('❌ خطأ في تحميل البيانات: $e');
    emit(state.copyWith(
      status: DataManagementStatus.error,
      errorMessage: 'فشل في تحميل البيانات: ${e.toString()}',
    ));
  }
}

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(
      status: DataManagementStatus.loading,
      errorMessage: '',
      successMessage: '',
      ));
    try {
      final courses = await courseRepository.getAllCourses();
      // 🔥 التحقق من البيانات المحملة
      for (final course in courses) {
        print('📋 ${course.name} - المتطلبات: ${course.requestCourses} (${course.requestCourses.length})');
      }
      emit(state.copyWith(
        status: DataManagementStatus.success,
        courses: courses,
      ));
    } catch (e) {
        print('❌ خطأ في تحميل المواد: $e');
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في تحميل المواد: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadSemesters(
    LoadSemesters event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      final semesters = await semesterRepository.getAllSemesters();
      emit(state.copyWith(
        status: DataManagementStatus.success,
        semesters: semesters,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في تحميل الفصول: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddCourse(
    AddCourse event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      // ✅ التحقق من عدم تكرار المادة
    final existingCourse = state.courses.firstWhere(
      (c) => c.codeCs == event.course.codeCs,
      orElse: () => CourseModel.empty,
    );
    
    if (!existingCourse.isEmpty) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'كود المادة موجود مسبقاً',
      ));
      return;
    }

      await courseRepository.addCourse(event.course);
      final courses = await courseRepository.getAllCourses();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        courses: courses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في إضافة المادة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateCourse(
    UpdateCourse event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await courseRepository.updateCourse(event.course);
      final courses = await courseRepository.getAllCourses();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        courses: courses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في تحديث المادة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteCourse(
    DeleteCourse event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await courseRepository.deleteCourse(event.courseId);
      final courses = await courseRepository.getAllCourses();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        courses: courses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في حذف المادة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddSemester(
    AddSemester event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await semesterRepository.createSemester(event.semester);
      final semesters = await semesterRepository.getAllSemesters();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        semesters: semesters,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في إضافة الفصل: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateSemester(
    UpdateSemester event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await semesterRepository.updateSemester(event.semester);
      final semesters = await semesterRepository.getAllSemesters();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        semesters: semesters,
        successMessage: 'تم تحديث الفصل الدراسي بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في تحديث الفصل: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteSemester(
    DeleteSemester event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await semesterRepository.deleteSemester(event.semesterId);
      final semesters = await semesterRepository.getAllSemesters();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        semesters: semesters,
        successMessage: 'تم حذف الفصل الدراسي بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في حذف الفصل: ${e.toString()}',
      ));
    }
  }

  Future<void> _onImportCoursesFromExcel(
  ImportCoursesFromExcel event,
  Emitter<DataManagementState> emit,
) async {
  emit(state.copyWith(
    status: DataManagementStatus.loading,
    errorMessage: '',
    successMessage: '',
  ));
  
  print('📥 بدء استيراد المواد من Excel: ${event.excelData.length} سجل');
  
  try {
    final result = await courseRepository.importCoursesFromExcelData(event.excelData);
    
    print('📊 نتائج الاستيراد: ${result['success']}');
    print('✅ تمت إضافة: ${result['addedCount']}');
    print('🔄 تم تحديث: ${result['updatedCount']}');
    print('❌ أخطاء: ${result['errorCount']}');
    
    if (result['success'] == true) {
      // إعادة تحميل البيانات بعد الاستيراد الناجح
      final courses = await courseRepository.getAllCourses();
      final semesters = await semesterRepository.getAllSemesters();
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
        courses: courses,
        semesters: semesters,
        successMessage: result['message'] as String? ?? 'تم استيراد المواد بنجاح',
      ));
      
      print('🎯 استيراد المواد تم بنجاح');
    } else {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: result['message'] as String? ?? 'فشل في استيراد البيانات',
      ));
      
      print('❌ فشل في استيراد المواد: ${result['message']}');
    }
  } catch (e, stackTrace) {
    print('❌ خطأ غير متوقع في استيراد المواد: $e');
    print('📋 StackTrace: $stackTrace');
    
    emit(state.copyWith(
      status: DataManagementStatus.error,
      errorMessage: 'حدث خطأ غير متوقع أثناء الاستيراد: ${e.toString()}',
    ));
  }
}

  Future<void> _onImportStudentsFromExcel(
    ImportStudentsFromExcel event,
    Emitter<DataManagementState> emit,
  ) async {
    emit(state.copyWith(status: DataManagementStatus.loading));
    try {
      await semesterRepository.importStudentsFromExcel(
        semesterId: event.semesterId,
        courseId: event.courseId,
        groupId: event.groupId,
        excelData: event.excelData,
      );
      
      emit(state.copyWith(
        status: DataManagementStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DataManagementStatus.error,
        errorMessage: 'فشل في استيراد الطلاب: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearchCourses(
    SearchCourses event,
    Emitter<DataManagementState> emit,
  ) async {
    if (event.searchTerm.isEmpty) {
      emit(state.copyWith(
        isSearching: false,
        searchResults: [],
      ));
      return;
    }

    emit(state.copyWith(isSearching: true));
    try {
      final results = await courseRepository.searchCoursesByName(event.searchTerm);
      emit(state.copyWith(
        searchResults: results,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        errorMessage: 'فشل في البحث: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshData(
  RefreshData event,
  Emitter<DataManagementState> emit,
) async {
  emit(state.copyWith(
    status: DataManagementStatus.loading,
    errorMessage: '',
    successMessage: '',
    ));
  try {
    final courses = await courseRepository.getAllCourses();
    final semesters = await semesterRepository.getAllSemesters();
    
    emit(state.copyWith(
      status: DataManagementStatus.success,
      courses: courses,
      semesters: semesters,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: DataManagementStatus.error,
      errorMessage: 'فشل في تحديث البيانات: ${e.toString()}',
    ));
  }
}

// 🔥 دالة جديدة لمسح الرسائل
  void _onClearMessages(
    ClearMessages event,
    Emitter<DataManagementState> emit,
  ) {
    emit(state.copyWith(
      errorMessage: '',
      successMessage: '',
    ));
  }

}