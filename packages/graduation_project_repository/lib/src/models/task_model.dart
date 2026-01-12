import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? attachmentUrl;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.attachmentUrl,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? attachmentUrl,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      attachmentUrl: attachmentUrl,
      createdAt: createdAt,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      attachmentUrl: entity.attachmentUrl,
      createdAt: entity.createdAt,
    );
  }

  @override
  List<Object?> props() => [
    id,
    title,
    description,
    attachmentUrl,
    createdAt,
  ];
}