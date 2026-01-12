import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myproject/services/file_upload_service.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:subjective_repository/subjective_repository.dart';
part 'subjective_event.dart';
part 'subjective_state.dart';

class SubjectiveBloc extends Bloc<SubjectiveEvent, SubjectiveState> {
  final SubjectiveRepository _subjectiveRepository;
  String? _currentSemesterId;

  SubjectiveBloc({required SubjectiveRepository subjectiveRepository})
      : _subjectiveRepository = subjectiveRepository,
        super(SubjectiveInitial()) {
    // ✅ تحميل معرف الفصل عند بداية البلوك
    on<InitializeCurrentSemesterEvent>(_onInitializeCurrentSemester);
    // 🎯 أحداث المجموعات
    on<LoadDoctorGroupsEvent>(_onLoadDoctorGroups);
    on<LoadStudentGroupsEvent>(_onLoadStudentGroups);
    on<LoadGroupSubjectiveContentEvent>(_onLoadGroupSubjectiveContent);
    
    // 📚 أحداث المناهج
    on<LoadCurriculaEvent>(_onLoadCurricula);
    on<AddCurriculumToMultipleGroupsEvent>(_onAddCurriculumToMultipleGroups);
    on<UpdateCurriculumEvent>(_onUpdateCurriculum);
    on<DeleteCurriculumEvent>(_onDeleteCurriculum);
    
    // 📝 أحداث الواجبات
    on<LoadHomeworksEvent>(_onLoadHomeworks);
    on<AddHomeworkToMultipleGroupsEvent>(_onAddHomeworkToMultipleGroups);
    on<UpdateHomeworkEvent>(_onUpdateHomework);
    on<DeleteHomeworkEvent>(_onDeleteHomework);
    
    // 📢 أحداث الإعلانات
    on<LoadAdvertisementsEvent>(_onLoadAdvertisements);
    on<AddAdvertisementToMultipleGroupsEvent>(_onAddAdvertisementToMultipleGroups);
    on<UpdateAdvertisementEvent>(_onUpdateAdvertisement);
    on<DeleteAdvertisementEvent>(_onDeleteAdvertisement);
    
    // 👨‍🎓 أحداث إرسال الواجبات
    on<SubmitHomeworkEvent>(_onSubmitHomework);
    on<GradeHomeworkEvent>(_onGradeHomework);
    
    // 📊 أحداث الإحصائيات والطلاب
    //on<LoadGroupStatisticsEvent>(_onLoadGroupStatistics);
    on<LoadGroupStudentsEvent>(_onLoadGroupStudents);
    // 📊 أحداث درجات الامتحانات
    on<LoadExamGradesEvent>(_onLoadExamGrades);
    on<AddExamGradeEvent>(_onAddExamGrade);
    on<DeleteExamGradeEvent>(_onDeleteExamGrade);
    on<DeleteExamColumnGradesEvent>(_onDeleteExamColumnGrades);
    
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<UpdateAttendanceEvent>(_onUpdateAttendance);
    // 🎯 أحداث المحاضرات
    on<LoadLecturesEvent>(_onLoadLectures);
    on<AddLectureEvent>(_onAddLecture);
    on<UpdateLectureEvent>(_onUpdateLecture);
    on<DeleteLectureEvent>(_onDeleteLecture);
  }

  /// ✅ تهيئة معرف الفصل الدراسي الحالي
  Future<void> _onInitializeCurrentSemester(
    InitializeCurrentSemesterEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      _currentSemesterId = await _subjectiveRepository.getCurrentSemesterId();
      emit(CurrentSemesterInitialized(_currentSemesterId!));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل الفصل الدراسي الحالي: $e'));
    }
  }

  // ========== 🎯 معالجات أحداث المجموعات ==========

  /// 👨‍🏫 جلب مجموعات الدكتور
  Future<void> _onLoadDoctorGroups(
    LoadDoctorGroupsEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final courses  = await _subjectiveRepository.getDoctorGroups(event.doctorId);
      emit(DoctorGroupsLoadSuccess(courses ));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل مجموعات الدكتور: $e'));
    }
  }

  /// 👨‍🎓 جلب مجموعات الطالب
  Future<void> _onLoadStudentGroups(
    LoadStudentGroupsEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final courses  = await _subjectiveRepository.getStudentGroups(event.studentId);
      emit(StudentGroupsLoadSuccess(courses ));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل مجموعات الطالب: $e'));
    }
  }

  /// 📚 جلب المحتوى التعليمي الكامل للمجموعة
  Future<void> _onLoadGroupSubjectiveContent(
    LoadGroupSubjectiveContentEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final content = await _subjectiveRepository.getGroupSubjectiveContent(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
      );
      emit(GroupSubjectiveContentLoadSuccess(
        content: content,
      ));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل محتوى المجموعة: $e'));
    }
  }

  // ========== 📚 معالجات أحداث المناهج ==========

  Future<void> _onLoadCurricula(
    LoadCurriculaEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final curricula = await _subjectiveRepository.getGroupCurricula(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
      );
      emit(CurriculumLoadSuccess(curricula));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل المناهج: $e'));
    }
  }

  Future<void> _onAddCurriculumToMultipleGroups(
  AddCurriculumToMultipleGroupsEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    print('🎯 بدء معالجة AddCurriculumToMultipleGroupsEvent مع رفع الملف');
    print('📚 المادة: ${event.courseId}');
    print('👥 عدد المجموعات: ${event.groupIds.length}');
    print('📝 عنوان المنهج: ${event.curriculum.description}');
    String fileUrl = event.curriculum.file;
      
      // 🔥 رفع الملف إذا كان موجوداً
      if (event.file != null) {
        print('📤 رفع ملف المنهج...');
        fileUrl = await FileUploadService.uploadCurriculumFile(event.file!);
        print('✅ تم رفع الملف: $fileUrl');
      }
      
      final curriculumWithFile = event.curriculum.copyWith(file: fileUrl);
    emit(SubjectiveLoading());
    await _subjectiveRepository.addCurriculumToMultipleGroups(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupIds: event.groupIds,
      curriculum: curriculumWithFile,
    );
    print('✅ تم إضافة المنهج بنجاح في الـ Repository');
    emit(SubjectiveOperationSuccess('تم نشر المنهج بنجاح في جميع المجموعات'));
    // إعادة تحميل المناهج للتأكد من تحديث البيانات
    final curricula = await _subjectiveRepository.getGroupCurricula(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupIds.first, // استخدام أول مجموعة كمثال
    );
    
    print('📥 عدد المناهج بعد الإضافة: ${curricula.length}');
    emit(SubjectiveOperationSuccess('تم نشر المنهج بنجاح'));
  } catch (e) {
    print('❌ خطأ في معالجة AddCurriculumToMultipleGroupsEvent: $e');
    emit(SubjectiveError('فشل في نشر المنهج: $e'));
  }
}

  Future<void> _onUpdateCurriculum(
  UpdateCurriculumEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    String fileUrl = event.curriculum.file;
      
      // 🔥 رفع الملف الجديد إذا كان موجوداً
      if (event.file != null) {
        print('📤 رفع ملف المنهج المحدث...');
        fileUrl = await FileUploadService.uploadCurriculumFile(event.file!);
        print('✅ تم رفع الملف: $fileUrl');
        
        // حذف الملف القديم إذا كان مختلفاً
        if (event.curriculum.file.isNotEmpty && event.curriculum.file != fileUrl) {
          await FileUploadService.deleteFile(event.curriculum.file);
        }
      }
      
      final curriculumWithFile = event.curriculum.copyWith(file: fileUrl);
    await _subjectiveRepository.updateCurriculum(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      curriculum: curriculumWithFile,
    );
    emit(SubjectiveOperationSuccess('تم تحديث المنهج بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في تحديث المنهج: $e'));
  }
}

  Future<void> _onDeleteCurriculum(
  DeleteCurriculumEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.deleteCurriculum(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      curriculumId: event.curriculumId,
    );
    emit(SubjectiveOperationSuccess('تم حذف المنهج بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في حذف المنهج: $e'));
  }
}

  // ========== 📝 معالجات أحداث الواجبات ==========

  Future<void> _onLoadHomeworks(
    LoadHomeworksEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final homeworks = await _subjectiveRepository.getGroupHomeworks(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
      );
      emit(HomeworkLoadSuccess(homeworks));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل الواجبات: $e'));
    }
  }

  Future<void> _onAddHomeworkToMultipleGroups(
  AddHomeworkToMultipleGroupsEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    String fileUrl = event.homework.file;
      
      // 🔥 رفع الملف إذا كان موجوداً
      if (event.file != null) {
        print('📤 رفع ملف الواجب...');
        fileUrl = await FileUploadService.uploadHomeworkFile(event.file!);
        print('✅ تم رفع الملف: $fileUrl');
      }
      
      final homeworkWithFile = event.homework.copyWith(file: fileUrl);
    await _subjectiveRepository.addHomeworkToMultipleGroups(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupIds: event.groupIds,
      homework: homeworkWithFile,
    );
    emit(SubjectiveOperationSuccess('تم نشر الواجب بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في نشر الواجب: $e'));
  }
}

  Future<void> _onUpdateHomework(
  UpdateHomeworkEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.updateHomework(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      homework: event.homework,
    );
    emit(SubjectiveOperationSuccess('تم تحديث الواجب بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في تحديث الواجب: $e'));
  }
}

  Future<void> _onDeleteHomework(
  DeleteHomeworkEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.deleteHomework(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      homeworkId: event.homeworkId,
    );
    emit(SubjectiveOperationSuccess('تم حذف الواجب بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في حذف الواجب: $e'));
  }
}

  // ========== 📢 معالجات أحداث الإعلانات ==========

  Future<void> _onLoadAdvertisements(
  LoadAdvertisementsEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    final advertisements = await _subjectiveRepository.getGroupAdvertisements(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
    );
    emit(AdvertisementLoadSuccess(advertisements));
  } catch (e) {
    emit(SubjectiveError('فشل في تحميل الإعلانات: $e'));
  }
}

  Future<void> _onAddAdvertisementToMultipleGroups(
    AddAdvertisementToMultipleGroupsEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      String fileUrl = '';
      
      // 🔥 رفع الملف إذا كان موجوداً
      if (event.file != null) {
        print('📤 رفع ملف الإعلان...');
        fileUrl = await FileUploadService.uploadAdvertisementFile(event.file!);
        print('✅ تم رفع الملف: $fileUrl');
      }
      
      final advertisementWithFile = event.advertisement.copyWith(file: fileUrl);
      await _subjectiveRepository.addAdvertisementToMultipleGroups(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupIds: event.groupIds,
        advertisement: advertisementWithFile,
      );
      emit(SubjectiveOperationSuccess('تم نشر الإعلان بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في نشر الإعلان: $e'));
    }
  }

  Future<void> _onUpdateAdvertisement(
    UpdateAdvertisementEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      String fileUrl = event.advertisement.file;
      // 🔥 رفع الملف الجديد إذا كان موجوداً
    if (event.file != null) {
      print('📤 رفع ملف الإعلان المحدث...');
      fileUrl = await FileUploadService.uploadAdvertisementFile(event.file!);
      print('✅ تم رفع الملف: $fileUrl');
      
      // 🔥 حذف الملف القديم إذا كان مختلفاً
      if (event.advertisement.file.isNotEmpty && event.advertisement.file != fileUrl) {
        await FileUploadService.deleteFile(event.advertisement.file);
      }
    }
    
    // 🔥 تحديث الإعلان بالملف الجديد
    final advertisementWithFile = event.advertisement.copyWith(file: fileUrl);

      await _subjectiveRepository.updateAdvertisement(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        advertisement: advertisementWithFile,
      );
      emit(SubjectiveOperationSuccess('تم تحديث الإعلان بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في تحديث الإعلان: $e'));
    }
  }

  Future<void> _onDeleteAdvertisement(
    DeleteAdvertisementEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      await _subjectiveRepository.deleteAdvertisement(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        advertisementId: event.advertisementId,
      );
      emit(SubjectiveOperationSuccess('تم حذف الإعلان بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في حذف الإعلان: $e'));
    }
  }

  // ========== 👨‍🎓 معالجات أحداث إرسال الواجبات ==========

  Future<void> _onSubmitHomework(
    SubmitHomeworkEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      await _subjectiveRepository.submitHomework(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        homeworkId: event.homeworkId,
        submission: event.submission,
      );
      emit(SubjectiveOperationSuccess('تم إرسال الواجب بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في إرسال الواجب: $e'));
    }
  }

  Future<void> _onGradeHomework(
    GradeHomeworkEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      await _subjectiveRepository.gradeHomework(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        homeworkId: event.homeworkId,
        studentId: event.studentId,
        mark: event.mark,
      );
      emit(SubjectiveOperationSuccess('تم تقييم الواجب بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في تقييم الواجب: $e'));
    }
  }

  Future<void> _onLoadGroupStudents(
    LoadGroupStudentsEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      final students = await _subjectiveRepository.getGroupStudents(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
      );
      emit(GroupStudentsLoadSuccess(students));
    } catch (e) {
      emit(SubjectiveError('فشل في تحميل طلاب المجموعة: $e'));
    }
  }

  // ========== 📊 معالجات درجات الامتحانات ==========
Future<void> _onLoadExamGrades(
  LoadExamGradesEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    final examGrades = await _subjectiveRepository.getExamGrades(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
    );
    emit(ExamGradesLoadSuccess(examGrades));
  } catch (e) {
    emit(SubjectiveError('فشل في تحميل درجات الامتحانات: $e'));
  }
}

Future<void> _onAddExamGrade(
  AddExamGradeEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    await _subjectiveRepository.addExamGrade(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      examGrade: event.examGrade,
    );
    emit(SubjectiveOperationSuccess('تم إضافة درجة الامتحان بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في إضافة درجة الامتحان: $e'));
  }
}

Future<void> _onDeleteExamGrade(
    DeleteExamGradeEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      
      await _subjectiveRepository.deleteExamGrade(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        examGradeId: event.examGradeId,
      );
      
      emit(SubjectiveOperationSuccess('تم حذف درجة الامتحان بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في حذف درجة الامتحان: $e'));
    }
  }

  Future<void> _onDeleteExamColumnGrades(
    DeleteExamColumnGradesEvent event,
    Emitter<SubjectiveState> emit,
  ) async {
    try {
      emit(SubjectiveLoading());
      
      await _subjectiveRepository.deleteExamColumnGrades(
        semesterId: _currentSemesterId!,
        courseId: event.courseId,
        groupId: event.groupId,
        examType: event.examType,
      );
      
      emit(SubjectiveOperationSuccess('تم حذف جميع درجات العمود بنجاح'));
    } catch (e) {
      emit(SubjectiveError('فشل في حذف درجات العمود: $e'));
    }
  }

// ========== 📝 معالجات الحضور والغياب ==========
Future<void> _onLoadAttendance(
  LoadAttendanceEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    final attendance = await _subjectiveRepository.getAttendance(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      date: event.date,
    );
    emit(AttendanceLoadSuccess(attendance));
  } catch (e) {
    emit(SubjectiveError('فشل في تحميل سجل الحضور: $e'));
  }
}

Future<void> _onUpdateAttendance(
  UpdateAttendanceEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    await _subjectiveRepository.updateAttendance(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      attendance: event.attendance,
    );
    emit(SubjectiveOperationSuccess('تم تحديث سجل الحضور بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في تحديث سجل الحضور: $e'));
  }
}
// معالجات أحداث المحاضرات
Future<void> _onLoadLectures(
  LoadLecturesEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    final lectures = await _subjectiveRepository.getGroupLectures(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      doctorId: event.doctorId,
    );
    emit(LecturesLoadSuccess(lectures));
  } catch (e) {
    emit(SubjectiveError('فشل في تحميل المحاضرات: $e'));
  }
}

Future<void> _onAddLecture(
  AddLectureEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.addLecture(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      lecture: event.lecture,
      doctorId: event.doctorId,
    );
    emit(SubjectiveOperationSuccess('تم إضافة المحاضرة بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في إضافة المحاضرة: $e'));
  }
}

Future<void> _onUpdateLecture(
  UpdateLectureEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.updateLecture(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      lecture: event.lecture,
      doctorId: event.doctorId,
    );
    emit(SubjectiveOperationSuccess('تم تحديث المحاضرة بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في تحديث المحاضرة: $e'));
  }
}

Future<void> _onDeleteLecture(
  DeleteLectureEvent event,
  Emitter<SubjectiveState> emit,
) async {
  try {
    emit(SubjectiveLoading());
    await _subjectiveRepository.deleteLecture(
      semesterId: _currentSemesterId!,
      courseId: event.courseId,
      groupId: event.groupId,
      lectureId: event.lectureId,
      doctorId: event.doctorId,
    );
    emit(SubjectiveOperationSuccess('تم حذف المحاضرة بنجاح'));
  } catch (e) {
    emit(SubjectiveError('فشل في حذف المحاضرة: $e'));
  }
}

}