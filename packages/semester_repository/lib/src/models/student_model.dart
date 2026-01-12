import 'package:equatable/equatable.dart';
import 'package:semester_repository/semester_repository.dart';

class StudentModel extends Equatable {
  final String id;
  final String name;
  final String studentId;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studentId,
  });

  static final empty = StudentModel(
    id: '',
    name: '',
    studentId: '',
  );

  bool get isEmpty => this == StudentModel.empty;
  bool get isNotEmpty => this != StudentModel.empty;

  StudentModel copyWith({
    String? id,
    String? name,
    String? studentId,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
    );
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      name: name,
      studentId: studentId,
    );
  }

  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      name: entity.name,
      studentId: entity.studentId,
    );
  }

  // لاستيراد من Excel
  factory StudentModel.fromExcel(Map<String, dynamic> excelRow) {
    return StudentModel(
      id: excelRow['id']?.toString() ?? '',
      name: excelRow['name']?.toString() ?? '',
      studentId: excelRow['student_id']?.toString() ?? '',
    );
  }

  @override
  List<Object?> props() => [id, name, studentId];
}