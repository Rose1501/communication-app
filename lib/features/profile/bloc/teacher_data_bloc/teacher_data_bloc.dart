import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

part 'teacher_data_event.dart';
part 'teacher_data_state.dart';

class TeacherDataBloc extends Bloc<TeacherDataEvent, TeacherDataState> {
  final TeacherDataRepository _teacherDataRepository;

  TeacherDataBloc({required TeacherDataRepository teacherDataRepository})
      : _teacherDataRepository = teacherDataRepository,
        super(TeacherDataInitial()) {
    on<UpdateTeacherDataEvent>(_onUpdateTeacherData);
    on<LoadOfficeHoursEvent>(_onLoadOfficeHours);
    on<AddOfficeHoursEvent>(_onAddOfficeHours);
    on<UpdateOfficeHoursEvent>(_onUpdateOfficeHours);
    on<DeleteOfficeHoursEvent>(_onDeleteOfficeHours);
    on<AddTeachingCoursesEvent>(_onAddTeachingCourses);
    on<DeleteTeachingCourseEvent>(_onDeleteTeachingCourse);
    on<ArchiveCurriculaEvent>(_onArchiveCurricula);
    on<LoadArchivedCurriculaEvent>(_onLoadArchivedCurricula);
    on<RestoreCurriculumEvent>(_onRestoreCurriculum);
    on<DeleteArchivedCurriculumEvent>(_onDeleteArchivedCurriculum);
    on<SearchArchivedCurriculaEvent>(_onSearchArchivedCurricula);
    on<DeleteAllTeachingCoursesEvent>(_mapDeleteAllTeachingCoursesToState);
    on<UpdateTeachingCoursesEvent>(_mapUpdateTeachingCoursesToState);
    on<LoadTeachingCoursesEvent>(_onLoadTeachingCourses);
    on<LoadTeacherProfileDataEvent>(_onLoadTeacherProfileData);
  }

  // تحديث بيانات الأستاذ
  Future<void> _onUpdateTeacherData(
    UpdateTeacherDataEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.updateTeacherData(event.teacherData);
      emit(TeacherDataOperationSuccess(
        message: 'تم تحديث بيانات الأستاذ بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل تحديث بيانات الأستاذ: $e'));
    }
  }

  Future<void> _onLoadOfficeHours(
  LoadOfficeHoursEvent event,
  Emitter<TeacherDataState> emit,
) async {
  emit(TeacherDataLoading());
  try {
    // في هذا المثال، سنستخدم getTeacherData ثم نستخرج الساعات
    final officeHours  = await _teacherDataRepository.getOfficeHours(event.teacherId);
    emit(OfficeHoursLoaded(officeHours: officeHours));
  } catch (e) {
    emit(TeacherDataError(message: 'فشل جلب الساعات المكتبية: $e'));
  }
}

  // إضافة ساعات مكتبية متعددة
  Future<void> _onAddOfficeHours(
    AddOfficeHoursEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.addOfficeHours(
        event.teacherId,
        event.officeHoursList,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم إضافة الساعات المكتبية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل إضافة الساعات المكتبية: $e'));
    }
  }

  // تحديث ساعة مكتبية
  Future<void> _onUpdateOfficeHours(
    UpdateOfficeHoursEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.updateOfficeHours(
        event.teacherId,
        event.officeHours,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم تحديث الساعات المكتبية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل تحديث الساعات المكتبية: $e'));
    }
  }

  // حذف ساعة مكتبية
  Future<void> _onDeleteOfficeHours(
    DeleteOfficeHoursEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.deleteOfficeHours(
        event.teacherId,
        event.officeHoursId,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم حذف الساعات المكتبية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل حذف الساعات المكتبية: $e'));
    }
  }

  // إضافة مواد دراسية متعددة
  Future<void> _onAddTeachingCourses(
    AddTeachingCoursesEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.addTeachingCourses(
        event.teacherId,
        event.courses,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم إضافة المواد الدراسية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل إضافة المواد الدراسية: $e'));
    }
  }

  // حذف مادة دراسية
  Future<void> _onDeleteTeachingCourse(
    DeleteTeachingCourseEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.deleteTeachingCourse(
        event.teacherId,
        event.courseId,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم حذف المادة الدراسية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل حذف المادة الدراسية: $e'));
    }
  }

  // أرشفة مناهج متعددة
  Future<void> _onArchiveCurricula(
    ArchiveCurriculaEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.archiveCurricula(
        event.teacherId,
        event.teacherName,
        event.curricula,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم أرشفة المناهج بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل أرشفة المناهج: $e'));
    }
  }

  // جلب المناهج المؤرشفة
  Future<void> _onLoadArchivedCurricula(
    LoadArchivedCurriculaEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      final curricula = await _teacherDataRepository.getArchivedCurricula(
        event.teacherId,
      );
      emit(ArchivedCurriculaLoaded(curricula: curricula));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل جلب المناهج المؤرشفة: $e'));
    }
  }

  // استعادة منهج من الأرشيف
  Future<void> _onRestoreCurriculum(
    RestoreCurriculumEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      final success = await _teacherDataRepository.restoreCurriculum(
        event.teacherId,
        event.archiveId,
      );
      if (success) {
        emit(TeacherDataOperationSuccess(
          message: 'تم استعادة المنهج بنجاح',
        ));
        // إعادة تحميل المناهج المؤرشفة
        add(LoadArchivedCurriculaEvent(event.teacherId));
      } else {
        emit(TeacherDataError(message: 'فشل استعادة المنهج'));
      }
    } catch (e) {
      emit(TeacherDataError(message: 'فشل استعادة المنهج: $e'));
    }
  }

  // حذف منهج من الأرشيف
  Future<void> _onDeleteArchivedCurriculum(
    DeleteArchivedCurriculumEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.deleteArchivedCurriculum(
        event.teacherId,
        event.archiveId,
      );
      emit(TeacherDataOperationSuccess(
        message: 'تم حذف المنهج المؤرشف بنجاح',
      ));
      // إعادة تحميل المناهج المؤرشفة
      add(LoadArchivedCurriculaEvent(event.teacherId));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل حذف المنهج المؤرشف: $e'));
    }
  }

  // البحث في المناهج المؤرشفة
  Future<void> _onSearchArchivedCurricula(
    SearchArchivedCurriculaEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      final results = await _teacherDataRepository.searchArchivedCurricula(
        event.teacherId,
        event.query,
      );
      emit(SearchArchivedCurriculaResult(results: results));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل البحث في المناهج المؤرشفة: $e'));
    }
  }

  Future<void> _mapDeleteAllTeachingCoursesToState(
    DeleteAllTeachingCoursesEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      await _teacherDataRepository.deleteAllTeachingCourses(event.teacherId);
      emit(TeacherDataOperationSuccess(
        message: 'تم حذف جميع المواد الدراسية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل في حذف المواد الدراسية: $e'));
    }
  }
  Future<void> _mapUpdateTeachingCoursesToState(
    UpdateTeachingCoursesEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      // 1. حذف المواد الدراسية السابقة
      await _teacherDataRepository.deleteAllTeachingCourses(event.teacherId);

      // 2. إضافة المواد الدراسية الجديدة (إذا كانت موجودة)
      if (event.courses.isNotEmpty) {
        await _teacherDataRepository.addTeachingCourses(
          event.teacherId,
          event.courses,
        );
      }

      emit(TeacherDataOperationSuccess(
        message: 'تم تحديث المواد الدراسية بنجاح',
      ));
    } catch (e) {
      emit(TeacherDataError(message: 'فشل تحديث المواد الدراسية: $e'));
    }
  }

  // 🔥جلب المواد الدراسية
  Future<void> _onLoadTeachingCourses(
    LoadTeachingCoursesEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      print('🔄 جلب المواد الدراسية للأستاذ: ${event.teacherId}');
      
      final teachingCourses = await _teacherDataRepository.getTeachingCourses(event.teacherId);
      
      emit(TeachingCoursesLoaded(teachingCourses: teachingCourses));
      
      print('✅ تم جلب ${teachingCourses.length} مادة دراسية بنجاح');
    } catch (e) {
      emit(TeacherDataError(message: 'فشل جلب المواد الدراسية: $e'));
      print('❌ فشل جلب المواد الدراسية: $e');
    }
  }

  
  Future<void> _onLoadTeacherProfileData(
    LoadTeacherProfileDataEvent event,
    Emitter<TeacherDataState> emit,
  ) async {
    emit(TeacherDataLoading());
    try {
      print('🔄 جلب جميع بيانات الملف الأكاديمي: ${event.teacherId}');
      
      // تحميل الساعات المكتبية والمواد الدراسية معاً
      final officeHours = await _teacherDataRepository.getOfficeHours(event.teacherId);
      final teachingCourses = await _teacherDataRepository.getTeachingCourses(event.teacherId);
      
      emit(TeacherProfileDataLoaded(
        officeHours: officeHours,
        teachingCourses: teachingCourses,
      ));
      
      print('✅ تم جلب ${officeHours.length} ساعة مكتبية و ${teachingCourses.length} مادة دراسية بنجاح');
    } catch (e) {
      emit(TeacherDataError(message: 'فشل جلب بيانات الملف الأكاديمي: $e'));
      print('❌ فشل جلب بيانات الملف الأكاديمي: $e');
    }
  }
}