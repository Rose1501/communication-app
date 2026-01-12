import 'package:course_repository/course_repository.dart';
import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final String id;
  final String name;
  final String codeCs;
  final List<String> requestCourses;
  final int credits;

  const CourseModel({
    required this.id,
    required this.name,
    required this.codeCs,
    required this.requestCourses,
    required this.credits,
  });

  static final empty = CourseModel(
    id: '',
    name: '',
    codeCs: '',
    requestCourses: const [],
    credits: 0,
  );

  bool get isEmpty => this == CourseModel.empty;
  bool get isNotEmpty => this != CourseModel.empty;

  // التحقق مما إذا كانت المادة لديها متطلبات سابقة
  bool get hasPrerequisites => requestCourses.isNotEmpty;

  // نسخ الكائن مع تحديث بعض الخصائص
  CourseModel copyWith({
    String? id,
    String? name,
    String? codeCs,
    List<String>? requestCourses,
    int? credits,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      codeCs: codeCs ?? this.codeCs,
      requestCourses: requestCourses ?? this.requestCourses,
      credits: credits ?? this.credits,
    );
  }

  // التحويل إلى Entity
  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      name: name,
      codeCs: codeCs,
      requestCourses: requestCourses,
      credits: credits,
    );
  }

  // الإنشاء من Entity
  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      name: entity.name,
      codeCs: entity.codeCs,
      requestCourses: entity.requestCourses,
      credits: entity.credits,
    );
  }

  @override
  List<Object?> props() => [
        id,
        name,
        codeCs,
        requestCourses,
        credits,
      ];

  @override
  String toString() {
    return 'CourseModel(id: $id, name: $name, codeCs: $codeCs, credits: $credits, prerequisites: ${requestCourses.length})';
  }
}