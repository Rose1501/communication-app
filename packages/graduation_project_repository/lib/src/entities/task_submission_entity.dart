import 'package:cloud_firestore/cloud_firestore.dart';

class TaskSubmissionEntity {
  final String id;
  final String taskId;
  final String studentId;
  final String studentName;
  final DateTime submissionDate;
  final String attachmentUrl;
  final String fileName;
  final bool isGraded;
  final int? grade;
  final String? feedback;

  const TaskSubmissionEntity({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.studentName,
    required this.submissionDate,
    required this.attachmentUrl,
    required this.fileName,
    this.isGraded = false,
    this.grade,
    this.feedback,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'taskId': taskId,
      'studentId': studentId,
      'studentName': studentName,
      'submissionDate': Timestamp.fromDate(submissionDate),
      'attachmentUrl': attachmentUrl,
      'fileName': fileName,
      'isGraded': isGraded,
      'grade': grade,
      'feedback': feedback,
    };
  }

  static TaskSubmissionEntity fromDocument(Map<String, dynamic> doc) {
    return TaskSubmissionEntity(
      id: doc['id'] as String,
      taskId: doc['taskId'] as String,
      studentId: doc['studentId'] as String,
      studentName: doc['studentName'] as String,
      submissionDate: (doc['submissionDate'] as Timestamp).toDate(),
      attachmentUrl: doc['attachmentUrl'] as String,
      fileName: doc['fileName'] as String,
      isGraded: doc['isGraded'] as bool? ?? false,
      grade: doc['grade'] as int?,
      feedback: doc['feedback'] as String?,
    );
  }
}