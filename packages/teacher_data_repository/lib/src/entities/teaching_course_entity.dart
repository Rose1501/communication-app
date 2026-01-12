import 'package:equatable/equatable.dart';

class TeachingCourseEntity extends Equatable {
  final String id;
  final String courseCode;
  final String courseName;

  const TeachingCourseEntity({
    required this.id,
    required this.courseCode,
    required this.courseName,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
    };
  }

  factory TeachingCourseEntity.fromDocument(Map<String, dynamic> doc) {
    return TeachingCourseEntity(
      id: doc['id'] as String,
      courseCode: doc['courseCode'] as String,
      courseName: doc['courseName'] as String,
    );
  }

  @override
  List<Object?> props() => [
        id,
        courseCode,
        courseName,
      ];
}