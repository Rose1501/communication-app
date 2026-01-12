import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:equatable/equatable.dart';

class TeacherDataModel extends Equatable {
  final String teacherId;              // معرف الأستاذ
  final String teacherName;            // اسم الأستاذ
  final List<OfficeHoursModel> officeHours;          // الساعات المكتبية
  final List<TeachingCourseModel> teachingCourses;   // المواد الدراسية
  final List<ArchivedCurriculumModel> archivedCurricula; // المناهج المؤرشفة

  const TeacherDataModel({
    required this.teacherId,
    required this.teacherName,
    this.officeHours = const [],
    this.teachingCourses = const [],
    this.archivedCurricula = const [],
  });

  static final empty = TeacherDataModel(
    teacherId: '',
    teacherName: '',
  );

  bool get isEmpty => this == TeacherDataModel.empty;
  bool get isNotEmpty => this != TeacherDataModel.empty;

  // دوال مساعدة
  bool get hasOfficeHours => officeHours.isNotEmpty;
  bool get hasTeachingCourses => teachingCourses.isNotEmpty;
  bool get hasArchivedCurricula => archivedCurricula.isNotEmpty;

  // تصفية الساعات المكتبية حسب اليوم
  List<OfficeHoursModel> getOfficeHoursByDay(String day) {
    return officeHours.where((oh) => oh.dayOfWeek == day).toList();
  }

  // تصفية المواد الدراسية حسب الرمز
  List<TeachingCourseModel> getCoursesByCode(String code) {
    return teachingCourses
        .where((course) => course.courseCode.toLowerCase().contains(code.toLowerCase()))
        .toList();
  }

  TeacherDataModel copyWith({
    String? teacherId,
    String? teacherName,
    List<OfficeHoursModel>? officeHours,
    List<TeachingCourseModel>? teachingCourses,
    List<ArchivedCurriculumModel>? archivedCurricula,
  }) {
    return TeacherDataModel(
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      officeHours: officeHours ?? this.officeHours,
      teachingCourses: teachingCourses ?? this.teachingCourses,
      archivedCurricula: archivedCurricula ?? this.archivedCurricula,
    );
  }

  TeacherDataEntity toEntity() {
    return TeacherDataEntity(
      teacherId: teacherId,
      teacherName: teacherName,
      officeHours: officeHours.map((oh) => oh.toEntity()).toList(),
      teachingCourses: teachingCourses.map((tc) => tc.toEntity()).toList(),
      archivedCurricula: archivedCurricula.map((ac) => ac.toEntity()).toList(),
    );
  }

  factory TeacherDataModel.fromEntity(TeacherDataEntity entity) {
    return TeacherDataModel(
      teacherId: entity.teacherId,
      teacherName: entity.teacherName,
      officeHours: entity.officeHours.whereType<OfficeHoursEntity>().map((e) => OfficeHoursModel.fromEntity(e)).toList(),
      teachingCourses: entity.teachingCourses.whereType<TeachingCourseEntity>().map((e) => TeachingCourseModel.fromEntity(e)).toList(),
      archivedCurricula: entity.archivedCurricula.whereType<ArchivedCurriculumEntity>().map((e) => ArchivedCurriculumModel.fromEntity(e)).toList(),
    );
  }

  @override
  List<Object?> props() => [
        teacherId,
        teacherName,
        officeHours,
        teachingCourses,
        archivedCurricula,
      ];
}