import 'package:teacher_data_repository/teacher_data_repository.dart';
import 'package:equatable/equatable.dart';

class TeachingCourseModel extends Equatable {
  final String id;          // 1. المعرف الفريد
  final String courseCode;  // 2. رمز المادة
  final String courseName;  // 3. اسم المادة

  const TeachingCourseModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
  });

  static final empty = TeachingCourseModel(
    id: '',
    courseCode: '',
    courseName: '',
  );

  bool get isEmpty => this == TeachingCourseModel.empty;
  bool get isNotEmpty => this != TeachingCourseModel.empty;

  String get displayName => '$courseCode - $courseName';

  TeachingCourseModel copyWith({
    String? id,
    String? courseCode,
    String? courseName,
  }) {
    return TeachingCourseModel(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
    );
  }

  TeachingCourseEntity toEntity() {
    return TeachingCourseEntity(
      id: id,
      courseCode: courseCode,
      courseName: courseName,
    );
  }

  factory TeachingCourseModel.fromEntity(TeachingCourseEntity entity) {
    return TeachingCourseModel(
      id: entity.id,
      courseCode: entity.courseCode,
      courseName: entity.courseName,
    );
  }

  @override
  List<Object?> props() => [
        id,
        courseCode,
        courseName,
      ];
}