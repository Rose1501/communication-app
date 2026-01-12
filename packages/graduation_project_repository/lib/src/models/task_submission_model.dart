import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:equatable/equatable.dart';

class TaskSubmissionModel extends Equatable {
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

  const TaskSubmissionModel({
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

  TaskSubmissionModel copyWith({
    String? id,
    String? taskId,
    String? studentId,
    String? studentName,
    DateTime? submissionDate,
    String? attachmentUrl,
    String? fileName,
    bool? isGraded,
    int? grade,
    String? feedback,
  }) {
    return TaskSubmissionModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      submissionDate: submissionDate ?? this.submissionDate,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      fileName: fileName ?? this.fileName,
      isGraded: isGraded ?? this.isGraded,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
    );
  }

  TaskSubmissionEntity toEntity() {
    return TaskSubmissionEntity(
      id: id,
      taskId: taskId,
      studentId: studentId,
      studentName: studentName,
      submissionDate: submissionDate,
      attachmentUrl: attachmentUrl,
      fileName: fileName,
      isGraded: isGraded,
      grade: grade,
      feedback: feedback,
    );
  }

  factory TaskSubmissionModel.fromEntity(TaskSubmissionEntity entity) {
    return TaskSubmissionModel(
      id: entity.id,
      taskId: entity.taskId,
      studentId: entity.studentId,
      studentName: entity.studentName,
      submissionDate: entity.submissionDate,
      attachmentUrl: entity.attachmentUrl,
      fileName: entity.fileName,
      isGraded: entity.isGraded,
      grade: entity.grade,
      feedback: entity.feedback,
    );
  }

  @override
  List<Object?> props() => [
    id,
    taskId,
    studentId,
    studentName,
    submissionDate,
    attachmentUrl,
    fileName,
    isGraded,
    grade,
    feedback,
  ];
}