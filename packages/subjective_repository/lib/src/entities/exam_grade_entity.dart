import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExamGradeEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String examType; // نصفي، نهائي، عملي
  final double grade;
  final double maxGrade;
  final DateTime examDate;

  const ExamGradeEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.examType,
    required this.grade,
    required this.maxGrade,
    required this.examDate,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'exam_type': examType,
      'grade': grade,
      'max_grade': maxGrade,
      'exam_date': Timestamp.fromDate(examDate),
    };
  }

  factory ExamGradeEntity.fromDocument(Map<String, dynamic> doc) {
    try {
      return ExamGradeEntity(
        id: doc['id'] as String? ?? '',
        studentId: doc['student_id'] as String? ?? '',
        studentName: doc['student_name'] as String? ?? '',
        examType: doc['exam_type'] as String? ?? 'نهائي',
        grade: (doc['grade'] as num?)?.toDouble() ?? 0.0,
        maxGrade: (doc['max_grade'] as num?)?.toDouble() ?? 100.0,
        examDate: (doc['exam_date'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('❌ خطأ في fromDocument لدرجة الامتحان: $e');
      print('📋 بيانات المستند: $doc');
      rethrow;
    }
  }

  @override
  List<Object?> props() => [id, studentId, studentName, examType, grade, maxGrade, examDate];
}