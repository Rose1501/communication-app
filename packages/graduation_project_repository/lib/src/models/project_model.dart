import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String projectType;
  final String projectGoals;
  final List<String> supervisors;
  final List<String> studentIds;
  final List<String> studentsName;
  final DateTime createdAt;
  final String? attachmentFile;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectType,
    required this.projectGoals,
    required this.supervisors,
    required this.studentIds,
    required this.studentsName,
    required this.createdAt,
    this.attachmentFile,
  });

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? projectType,
    String? projectGoals,
    List<String>? supervisors,
    List<String>? studentIds,
    List<String>? studentsName,
    DateTime? createdAt,
    String? attachmentFile,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectType: projectType ?? this.projectType,
      projectGoals: projectGoals ?? this.projectGoals,
      supervisors: supervisors ?? this.supervisors,
      studentIds: studentIds ?? this.studentIds,
      studentsName: studentsName ?? this.studentsName,
      createdAt: createdAt ?? this.createdAt,
      attachmentFile: attachmentFile ?? this.attachmentFile,
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      title: title,
      description: description,
      projectType: projectType,
      projectGoals: projectGoals,
      supervisors: supervisors,
      studentIds: studentIds,
      studentsName: studentsName,
      createdAt: createdAt,
      attachmentFile: attachmentFile,
    );
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      projectType: entity.projectType,
      projectGoals: entity.projectGoals,
      supervisors: entity.supervisors,
      studentIds: entity.studentIds,
      studentsName: entity.studentsName,
      createdAt: entity.createdAt,
      attachmentFile: entity.attachmentFile,
    );
  }

  @override
  List<Object?> props() => [
        id,
        title,
        description,
        projectType,
        projectGoals,
        supervisors,
        studentIds,
        studentsName,
        createdAt,
        attachmentFile,
      ];
}