import 'package:equatable/equatable.dart';
import 'package:teacher_data_repository/teacher_data_repository.dart';

class TeacherDataEntity extends Equatable {
  final String teacherId;
  final String teacherName;
  final List<OfficeHoursEntity> officeHours;
  final List<TeachingCourseEntity> teachingCourses;
  final List<ArchivedCurriculumEntity> archivedCurricula;

  const TeacherDataEntity({
    required this.teacherId,
    required this.teacherName,
    required this.officeHours,
    required this.teachingCourses,
    required this.archivedCurricula,
  });

  Map<String, dynamic> toDocument() {
    return {
      'teacherId': teacherId,
      'teacherName': teacherName,
      'officeHours': officeHours.map((oh) => oh.toDocument()).toList(),
      'teachingCourses': teachingCourses.map((tc) => tc.toDocument()).toList(),
      'archivedCurricula': archivedCurricula.map((ac) => ac.toDocument()).toList(),
    };
  }

  factory TeacherDataEntity.fromDocument(Map<String, dynamic> doc) {
    return TeacherDataEntity(
      teacherId: doc['teacherId'] as String,
      teacherName: doc['teacherName'] as String,
      officeHours: (doc['officeHours'] as List)
          .map((e) => OfficeHoursEntity.fromDocument(e as Map<String, dynamic>))
          .toList(),
      teachingCourses: (doc['teachingCourses'] as List)
          .map((e) => TeachingCourseEntity.fromDocument(e as Map<String, dynamic>))
          .toList(),
      archivedCurricula: (doc['archivedCurricula'] as List)
          .map((e) => ArchivedCurriculumEntity.fromDocument(e as Map<String, dynamic>))
          .toList(),
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