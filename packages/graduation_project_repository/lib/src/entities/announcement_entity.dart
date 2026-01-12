import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AnnouncementPriority { normal, important, urgent }

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final DateTime createdAt;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AnnouncementEntity.fromDocument(Map<String, dynamic> doc) {
    return AnnouncementEntity(
      id: doc['id'] as String,
      title: doc['title'] as String,
      content: doc['content'] as String,
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == doc['priority'],
        orElse: () => AnnouncementPriority.normal,
      ),
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> props() => [id, title, content, priority, createdAt];
}