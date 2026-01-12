import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? attachmentUrl;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.attachmentUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskEntity.fromDocument(Map<String, dynamic> doc) {
    return TaskEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      description: doc['description'] as String?,
      attachmentUrl: doc['attachmentUrl'] as String?,
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> props() => [id, title, description, attachmentUrl, createdAt];
}