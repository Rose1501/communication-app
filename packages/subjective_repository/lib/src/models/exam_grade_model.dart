import 'package:equatable/equatable.dart';
import 'package:subjective_repository/subjective_repository.dart';

class ExamGradeModel extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String examType; // نصفي، نهائي، عملي
  final double grade;
  final double maxGrade;
  final DateTime examDate;

  const ExamGradeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examType,
    required this.grade,
    required this.maxGrade,
    required this.examDate,
  });

  static final empty = ExamGradeModel(
    id: '',
    studentId: '',
    studentName: '',
    examType: '',
    grade: 0.0,
    maxGrade: 100.0,
    examDate: DateTime.now(),
  );

  bool get isEmpty => this == ExamGradeModel.empty;
  bool get isNotEmpty => this != ExamGradeModel.empty;

  double get percentage => (grade / maxGrade) * 100;

  ExamGradeModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? examType,
    double? grade,
    double? maxGrade,
    DateTime? examDate,
  }) {
    return ExamGradeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      examType: examType ?? this.examType,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      examDate: examDate ?? this.examDate,
    );
  }

  ExamGradeEntity toEntity() {
    return ExamGradeEntity(
      id: id,
      studentId: studentId,
      studentName: studentName,
      examType: examType,
      grade: grade,
      maxGrade: maxGrade,
      examDate: examDate,
    );
  }

  factory ExamGradeModel.fromEntity(ExamGradeEntity entity) {
    return ExamGradeModel(
      id: entity.id,
      studentId: entity.studentId,
      studentName: entity.studentName,
      examType: entity.examType,
      grade: entity.grade,
      maxGrade: entity.maxGrade,
      examDate: entity.examDate,
    );
  }

  @override
  List<Object?> props() => [id, studentId, studentName, examType, grade, maxGrade, examDate];
}