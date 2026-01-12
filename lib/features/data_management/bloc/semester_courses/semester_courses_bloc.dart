import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:course_repository/course_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'semester_courses_event.dart';
part 'semester_courses_state.dart';

class SemesterCoursesBloc
    extends Bloc<SemesterCoursesEvent, SemesterCoursesState> {
  final SemesterRepository semesterRepository;
  final CourseRepository courseRepository;

  SemesterCoursesBloc({
    required this.semesterRepository,
    required this.courseRepository,
  }) : super(const SemesterCoursesState()) {
    on<LoadSemesterCourses>(_onLoadSemesterCourses);
    on<GetCurrentSemester>(_onGetCurrentSemester); // أضف هذا السطر
    on<AddCourseToSemester>(_onAddCourseToSemester);
    on<RemoveCourseFromSemester>(_onRemoveCourseFromSemester);
    on<LoadAvailableCourses>(_onLoadAvailableCourses);
    on<SearchAvailableCourses>(_onSearchAvailableCourses);
    on<ImportCoursesToSemester>(_onImportCoursesToSemester);
    on<RefreshSemesterCourses>(_onRefreshSemesterCourses);

    on<AddCourseWithGroups>(_onAddCourseWithGroups);
    on<AddStudentsToGroup>(_onAddStudentsToGroup);
    on<LoadGroupStudents>(_onLoadGroupStudents);
    on<RemoveStudentFromGroup>(_onRemoveStudentFromGroup);
    on<UpdateCourseWithGroups>(_onUpdateCourseWithGroups);
    on<ClearMessagesSemester>(_onClearMessages);
  }

  // ✅ بيانات خاصة لدعم CourseSetupScreen
  final Map<String, List<UserModels>> _pendingGroupImports = {};
  final Map<String, List<Map<String, dynamic>>> _pendingGroupExcelData = {};
  final Map<String, String> _pendingGroupFileNames = {};

  // ✅ الحصول على البيانات المؤقتة
  Map<String, List<UserModels>> get pendingGroupImports => _pendingGroupImports;
  Map<String, List<Map<String, dynamic>>> get pendingGroupExcelData => _pendingGroupExcelData;
  Map<String, String> get pendingGroupFileNames => _pendingGroupFileNames;

  // ✅ حفظ بيانات مؤقتة للمجموعة
  void savePendingImport(String groupId, List<UserModels> students, 
                        List<Map<String, dynamic>> excelData, String fileName) {
    _pendingGroupImports[groupId] = students;
    _pendingGroupExcelData[groupId] = excelData;
    _pendingGroupFileNames[groupId] = fileName;
  }

  // ✅ مسح البيانات المؤقتة للمجموعة
  void clearPendingImport(String groupId) {
    _pendingGroupImports.remove(groupId);
    _pendingGroupExcelData.remove(groupId);
    _pendingGroupFileNames.remove(groupId);
  }

  // ✅ مسح جميع البيانات المؤقتة
  void clearAllPendingImports() {
    _pendingGroupImports.clear();
    _pendingGroupExcelData.clear();
    _pendingGroupFileNames.clear();
  }

  Future<void> _onLoadSemesterCourses(
    LoadSemesterCourses event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      // جلب الفصل النشط
      final currentSemester = await semesterRepository.getCurrentSemester();
      
      if (currentSemester == null) {
        emit(state.copyWith(
          status: SemesterCoursesStatus.error,
          errorMessage: 'لا يوجد فصل دراسي نشط',
        ));
        return;
      }

      // جلب المواد المتاحة (جميع المواد)
      final allCourses = await courseRepository.getAllCourses();
      
      // جلب مواد الفصل الحالي
      final semesterCourses = await semesterRepository.getSemesterCourses(currentSemester.id);

      emit(state.copyWith(
        status: SemesterCoursesStatus.success,
        currentSemester: currentSemester,
        semesterCourses: semesterCourses,
        availableCourses: allCourses,
        filteredCourses: allCourses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في تحميل البيانات: ${e.toString()}',
      ));
    }
  }

  /// معالج جلب الفصل الدراسي النشط فقط
  Future<void> _onGetCurrentSemester(
    GetCurrentSemester event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    // لا حاجة لتغيير حالة التحميل هنا لأنه عملية سريعة
    try {
      final currentSemester = await semesterRepository.getCurrentSemester();
      
      emit(state.copyWith(
        currentSemester: currentSemester,
        // يمكن إضافة رسالة نجاح إذا أردت
        // successMessage: 'تم جلب بيانات الفصل الدراسي',
      ));
    } catch (e) {
      // في حالة الخطأ، نحدث الحالة برسالة خطأ
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في جلب الفصل الدراسي الحالي: ${e.toString()}',
      ));
    }
  }

  // ✅ حدث جديد: إضافة مادة مع مجموعات
  Future<void> _onAddCourseWithGroups(
    AddCourseWithGroups event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      print('🚀 بدء إضافة المادة مع المجموعات: ${event.course.name}');
    print('📊 عدد المجموعات: ${event.groups.length}');
    print('💾 البيانات المؤقتة المتاحة: ${_pendingGroupImports.length} مجموعة');
      // 1. إضافة المادة الأساسية
      final addedCourse = await semesterRepository.addCourse(
        semester.id, 
        event.course
      );
      
      print('✅ تم إضافة المادة: ${addedCourse.name} (${addedCourse.id})');

      // 2. إضافة المجموعات للمادة
    int groupsAdded = 0;
    for (final group in event.groups) {
      try {
        final addedGroup = await semesterRepository.addGroup(
          semester.id,
          addedCourse.id,
          group,
        );
        groupsAdded++;
        print('✅ تم إضافة المجموعة: ${addedGroup.name} (${addedGroup.id})');
        
        // 3. إضافة الطلاب المعلقين لهذه المجموعة إذا وجدوا
        if (_pendingGroupImports.containsKey(group.id)) {
          final students = _pendingGroupImports[group.id]!;
          final fileName = _pendingGroupFileNames[group.id] ?? 'غير معروف';
          int studentsAdded = 0;
          
          print('📁 معالجة ملف: $fileName للمجموعة ${group.name}');
          print('👥 عدد الطلاب المعلقين: ${students.length}');

          for (final user in students) {
            try {
              final student = StudentModel(
                id: '', // سيتم توليده تلقائياً
                name: user.name,
                studentId: user.userID,
              );

              await semesterRepository.addStudent(
                semester.id,
                addedCourse.id,
                group.id, // ✅ استخدام معرف المجموعة المضاف حديثاً
                student,
              );

              studentsAdded++;
              print('✅ تم إضافة الطالب: ${user.name} للمجموعة ${group.name}');
            } catch (e) {
              print('❌ خطأ في إضافة الطالب ${user.name}: $e');
            }
          }

          print('✅ تم إضافة $studentsAdded طالب للمجموعة ${group.name} من ملف: $fileName');
        }
      } catch (e) {
        print('❌ خطأ في إضافة المجموعة ${group.name}: $e');
      }
    }

    // 4. تنظيف البيانات المؤقتة
    clearAllPendingImports();

    // 5. إعادة تحميل البيانات
    add(const LoadSemesterCourses());

    emit(state.copyWith(
      status: SemesterCoursesStatus.success,
      successMessage: 'تم إضافة المادة مع $groupsAdded مجموعة${_getPendingStudentsCount() > 0 ? ' و ${_getPendingStudentsCount()} طالب' : ''}',
    ));

    print('🎉 تم الانتهاء من عملية الحفظ بنجاح');

  } catch (e) {
    print('❌ خطأ في إضافة المادة والمجموعات: $e');
    emit(state.copyWith(
      status: SemesterCoursesStatus.error,
      errorMessage: 'فشل في إضافة المادة والمجموعات: ${e.toString()}',
    ));
  }
}
// ✅ دالة مساعدة لحساب إجمالي الطلاب المعلقين
int _getPendingStudentsCount() {
  return _pendingGroupImports.values.fold(0, (sum, students) => sum + students.length);
}

  // ✅ حدث جديد: إضافة طلاب لمجموعة
  Future<void> _onAddStudentsToGroup(
    AddStudentsToGroup event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      int successCount = 0;
      int errorCount = 0;

      for (final student in event.students) {
        try {
          await semesterRepository.addStudent(
            semester.id,
            event.courseId,
            event.groupId,
            student,
          );
          successCount++;
        } catch (e) {
          errorCount++;
          print('❌ خطأ في إضافة الطالب ${student.name}: $e');
        }
      }

      // إعادة تحميل بيانات المجموعة
      add(LoadGroupStudents(
        courseId: event.courseId,
        groupId: event.groupId,
      ));

      emit(state.copyWith(
        status: SemesterCoursesStatus.success,
        successMessage: 'تم إضافة $successCount طالب${errorCount > 0 ? ' مع $errorCount خطأ' : ''}',
      ));

    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في إضافة الطلاب: ${e.toString()}',
      ));
    }
  }

  // ✅ حدث جديد: جلب طلاب المجموعة
  Future<void> _onLoadGroupStudents(
    LoadGroupStudents event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      final students = await semesterRepository.getGroupStudents(
        semester.id,
        event.courseId,
        event.groupId,
      );

      emit(state.copyWith(
        status: SemesterCoursesStatus.success,
        groupStudents: students,
        selectedGroupId: event.groupId,
      ));

    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في تحميل طلاب المجموعة: ${e.toString()}',
      ));
    }
  }

  // ✅ حدث جديد: حذف طالب من المجموعة
  Future<void> _onRemoveStudentFromGroup(
    RemoveStudentFromGroup event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      await semesterRepository.deleteStudent(
        semester.id,
        event.courseId,
        event.groupId,
        event.studentId,
      );

      // إعادة تحميل طلاب المجموعة
      add(LoadGroupStudents(
        courseId: event.courseId,
        groupId: event.groupId,
      ));

      emit(state.copyWith(
        status: SemesterCoursesStatus.success,
        successMessage: 'تم حذف الطالب بنجاح',
      ));

    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في حذف الطالب: ${e.toString()}',
      ));
    }
  }

  // ✅ معالجة الحدث الجديد
Future<void> _onUpdateCourseWithGroups(
  UpdateCourseWithGroups event,
  Emitter<SemesterCoursesState> emit,
) async {
  emit(state.copyWith(status: SemesterCoursesStatus.loading));
  
  try {
    print('🔄 بدء تحديث المادة مع المجموعات: ${event.course.name}');
    
    // 1. تحديث المادة الأساسية
    await semesterRepository.updateCourse(
      event.semesterId,
      event.course,
    );
    
    print('✅ تم تحديث المادة: ${event.course.name}');

    // 2. الحصول على المجموعات الحالية
    final existingGroups = await semesterRepository.getCourseGroups(
      event.semesterId,
      event.course.id,
    );

    // 3. معالجة المجموعات - تحديث الموجودة وإضافة الجديدة
    int groupsProcessed = 0;
    int studentsAdded = 0;
    
    for (final newGroup in event.groups) {
      try {
        // البحث عن المجموعة الحالية بنفس المعرف
        final existingGroup = existingGroups.firstWhere(
          (g) => g.id == newGroup.id,
          orElse: () => GroupModel.empty,
        );

        if (existingGroup.isNotEmpty) {
          // ✅ تحديث المجموعة الموجودة
          await semesterRepository.updateGroup(
            event.semesterId,
            event.course.id,
            newGroup,
          );
          print('✅ تم تحديث المجموعة: ${newGroup.name}');
          // ✅ إضافة الطلاب المعلقين للمجموعة الموجودة
          if (_pendingGroupImports.containsKey(newGroup.id)) {
            final students = _pendingGroupImports[newGroup.id]!;
            final fileName = _pendingGroupFileNames[newGroup.id] ?? 'غير معروف';
            
            print('📁 معالجة ملف: $fileName للمجموعة الموجودة ${newGroup.name}');
            print('👥 عدد الطلاب المعلقين: ${students.length}');

            for (final user in students) {
              try {
                // ✅ التحقق من عدم وجود الطالب مسبقاً
                final existingStudents = await semesterRepository.getGroupStudents(
                  event.semesterId,
                  event.course.id,
                  newGroup.id,
                );
                
                final studentExists = existingStudents.any((s) => s.studentId == user.userID);
                
                if (!studentExists) {
                  final student = StudentModel(
                    id: '',
                    name: user.name,
                    studentId: user.userID,
                  );

                  await semesterRepository.addStudent(
                    event.semesterId,
                    event.course.id,
                    newGroup.id,
                    student,
                  );
                  studentsAdded++;
                  print('✅ تم إضافة الطالب: ${user.name} للمجموعة ${newGroup.name}');
                } else {
                  print('⚠️ الطالب ${user.name} موجود مسبقاً في المجموعة ${newGroup.name}');
                }
              } catch (e) {
                print('❌ خطأ في إضافة الطالب ${user.name}: $e');
              }
            }
          }
        } else {
          // ✅ إضافة مجموعة جديدة
          final addedGroup = await semesterRepository.addGroup(
            event.semesterId,
            event.course.id,
            newGroup,
          );
          print('✅ تم إضافة المجموعة: ${newGroup.name}');
          
          // ✅ نقل الطلاب المعلقين للمجموعة الجديدة
          if (_pendingGroupImports.containsKey(newGroup.id)) {
            final students = _pendingGroupImports[newGroup.id]!;
            final fileName = _pendingGroupFileNames[newGroup.id] ?? 'غير معروف';
            print('📁 معالجة ملف: $fileName للمجموعة الجديدة ${newGroup.name}');
            print('👥 عدد الطلاب المعلقين: ${students.length}');
            for (final user in students) {
              try {
                final student = StudentModel(
                  id: '',
                  name: user.name,
                  studentId: user.userID,
                );

                await semesterRepository.addStudent(
                  event.semesterId,
                  event.course.id,
                  addedGroup.id,
                  student,
                );
                studentsAdded++;
                print('✅ تم إضافة الطالب: ${user.name} للمجموعة الجديدة ${newGroup.name}');
              } catch (e) {
                print('❌ خطأ في إضافة الطالب ${user.name}: $e');
              }
            }
          }
        }
        
        groupsProcessed++;
      } catch (e) {
        print('❌ خطأ في معالجة المجموعة ${newGroup.name}: $e');
      }
    }
    // 4. حذف المجموعات التي تم إزالتها
    final newGroupIds = event.groups.map((g) => g.id).toSet();
    for (final existingGroup in existingGroups) {
      if (!newGroupIds.contains(existingGroup.id)) {
        try {
          await semesterRepository.deleteGroup(
            event.semesterId,
            event.course.id,
            existingGroup.id,
          );
          print('🗑️ تم حذف المجموعة: ${existingGroup.name}');
        } catch (e) {
          print('❌ خطأ في حذف المجموعة ${existingGroup.name}: $e');
        }
      }
    }

    // 5. تنظيف البيانات المؤقتة
    clearAllPendingImports();

    // 6. إعادة تحميل البيانات
    add(const LoadSemesterCourses());

    String successMsg = 'تم تحديث المادة مع $groupsProcessed مجموعة';
    if (studentsAdded > 0) {
      successMsg += ' وتم إضافة $studentsAdded طالب';
    }

    emit(state.copyWith(
      status: SemesterCoursesStatus.success,
      successMessage: successMsg,
    ));

  } catch (e) {
    emit(state.copyWith(
      status: SemesterCoursesStatus.error,
      errorMessage: 'فشل في تحديث المادة: ${e.toString()}',
    ));
  }
}

  // الأحداث الأصلية تبقى كما هي مع تحسينات طفيفة
  Future<void> _onAddCourseToSemester(
    AddCourseToSemester event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      await semesterRepository.addCourse(semester.id, event.course);
      add(const LoadSemesterCourses());
      
    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في إضافة المادة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRemoveCourseFromSemester(
    RemoveCourseFromSemester event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      await semesterRepository.deleteCourse(semester.id, event.courseId);
      add(const LoadSemesterCourses());
      
    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في حذف المادة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadAvailableCourses(
    LoadAvailableCourses event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    try {
      final allCourses = await courseRepository.getAllCourses();
      final semesterCoursesIds = state.semesterCourses.map((c) => c.id).toSet();
      
      final available = allCourses.where((course) => !semesterCoursesIds.contains(course.id)).toList();

      emit(state.copyWith(
        availableCourses: allCourses,
        filteredCourses: available,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحميل المواد المتاحة: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearchAvailableCourses(
    SearchAvailableCourses event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    if (event.searchTerm.isEmpty) {
      emit(state.copyWith(
        filteredCourses: state.availableCourses,
        isSearching: false,
      ));
      return;
    }

    emit(state.copyWith(isSearching: true));
    
    try {
      final results = await courseRepository.searchCoursesByName(event.searchTerm);
      final semesterCoursesIds = state.semesterCourses.map((c) => c.id).toSet();
      
      final filtered = results.where((course) => !semesterCoursesIds.contains(course.id)).toList();

      emit(state.copyWith(
        filteredCourses: filtered,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        errorMessage: 'فشل في البحث: ${e.toString()}',
      ));
    }
  }

  Future<void> _onImportCoursesToSemester(
    ImportCoursesToSemester event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    emit(state.copyWith(status: SemesterCoursesStatus.loading));
    
    try {
      final semester = state.currentSemester;
      if (semester == null) throw Exception('لا يوجد فصل دراسي نشط');

      int successCount = 0;
      int errorCount = 0;

      for (final course in event.courses) {
        try {
          await semesterRepository.addCourse(semester.id, course);
          successCount++;
        } catch (e) {
          errorCount++;
          print('❌ فشل في إضافة المادة ${course.name}: $e');
        }
      }

      add(const LoadSemesterCourses());

      emit(state.copyWith(
        status: SemesterCoursesStatus.success,
        successMessage: 'تم استيراد $successCount مادة بنجاح${errorCount > 0 ? ' مع $errorCount خطأ' : ''}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SemesterCoursesStatus.error,
        errorMessage: 'فشل في استيراد المواد: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshSemesterCourses(
    RefreshSemesterCourses event,
    Emitter<SemesterCoursesState> emit,
  ) async {
    add(const LoadSemesterCourses());
  }

  // ✅ دالة جديدة لمسح الرسائل
  void _onClearMessages(
    ClearMessagesSemester event,
    Emitter<SemesterCoursesState> emit,
  ) {
    emit(state.copyWith(
      errorMessage: '',
      successMessage: '',
    ));
  }
}