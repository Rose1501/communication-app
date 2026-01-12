import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final String id;
  final String name;
  final String studentId;

  const StudentEntity({
    required this.id,
    required this.name,
    required this.studentId,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'student_id': studentId,
    };
  }

  factory StudentEntity.fromDocument(Map<String, dynamic> doc) {
    return StudentEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      studentId: doc['student_id'] as String,
    );
  }

  @override
  List<Object?> props() => [id, name, studentId];
}