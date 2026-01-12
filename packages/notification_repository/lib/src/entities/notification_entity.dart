import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String type; // 'complaint', 'request', 'homework', 'advertisement', 'exam', 'attendance', 'curriculum'
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? dataPayload;
  final bool isRead;
  final String? targetFirebaseUID;
  final String? sourceEntityId; // ID of the source entity (complaintId, requestId, etc.)
  final String? sourceRepository; // 'complaint', 'request', 'subjective', 'advertisement'
  final Map<String, dynamic>? metadata; // Additional metadata based on type

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.dataPayload,
    this.isRead = false,
    this.targetFirebaseUID,
    this.sourceEntityId,
    this.sourceRepository,
    this.metadata,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'dataPayload': dataPayload,
      'isRead': isRead,
      'targetFirebaseUID': targetFirebaseUID,
      'sourceEntityId': sourceEntityId,
      'sourceRepository': sourceRepository,
      'metadata': metadata,
    };
  }

  static NotificationEntity fromDocument(Map<String, dynamic> doc) {
    return NotificationEntity(
      id: doc['id'] as String,
      type: doc['type'] as String,
      title: doc['title'] as String,
      body: doc['body'] as String,
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      dataPayload: doc['dataPayload'] as Map<String, dynamic>?,
      isRead: doc['isRead'] as bool? ?? false,
      targetFirebaseUID: doc['targetFirebaseUID'] as String?,
      sourceEntityId: doc['sourceEntityId'] as String?,
      sourceRepository: doc['sourceRepository'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> props() => [
        id,
        type,
        title,
        body,
        timestamp,
        dataPayload,
        isRead,
        targetFirebaseUID,
        sourceEntityId,
        sourceRepository,
        metadata,
      ];
}