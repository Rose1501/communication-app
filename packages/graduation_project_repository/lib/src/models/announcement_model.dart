import 'package:graduation_project_repository/graduation_project_repository.dart';
import 'package:equatable/equatable.dart';

class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
  });

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementPriority? priority,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AnnouncementEntity toEntity() {
    return AnnouncementEntity(
      id: id,
      title: title,
      content: content,
      priority: priority,
      createdAt: createdAt,
    );
  }

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      priority: entity.priority,
      createdAt: entity.createdAt,
    );
  }

  @override
  List<Object?> props() => [
    id,
    title,
    content,
    priority,
    createdAt,
  ];
}