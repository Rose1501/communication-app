
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:notification_repository/notification_repository.dart';

class NotificationModel extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic>? dataPayload;
  final bool isRead;
  final String? targetFirebaseUID;
  final String? sourceEntityId;
  final String? sourceRepository;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
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

  static final empty = NotificationModel(
    id: '',
    type: 'general',
    title: '',
    body: '',
    timestamp: DateTime.now(),
  );

  bool get isEmpty => this == NotificationModel.empty;
  bool get isNotEmpty => this != NotificationModel.empty;

  // Getters for specific notification types
  bool get isComplaint => type == 'complaint';
  bool get isRequest => type == 'request';
  bool get isHomework => type == 'homework';
  bool get isAdvertisement => type == 'advertisement';
  bool get isExam => type == 'exam';
  bool get isAttendance => type == 'attendance';
  bool get isCurriculum => type == 'curriculum';
  bool get isGeneral => type == 'general';

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    DateTime? timestamp,
    Map<String, dynamic>? dataPayload,
    bool? isRead,
    String? targetFirebaseUID,
    String? sourceEntityId,
    String? sourceRepository,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      dataPayload: dataPayload ?? this.dataPayload,
      isRead: isRead ?? this.isRead,
      targetFirebaseUID: targetFirebaseUID ?? this.targetFirebaseUID,
      sourceEntityId: sourceEntityId ?? this.sourceEntityId,
      sourceRepository: sourceRepository ?? this.sourceRepository,
      metadata: metadata ?? this.metadata,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      dataPayload: dataPayload,
      isRead: isRead,
      targetFirebaseUID: targetFirebaseUID,
      sourceEntityId: sourceEntityId,
      sourceRepository: sourceRepository,
      metadata: metadata,
    );
  }

  static NotificationModel fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      timestamp: entity.timestamp,
      dataPayload: entity.dataPayload,
      isRead: entity.isRead,
      targetFirebaseUID: entity.targetFirebaseUID,
      sourceEntityId: entity.sourceEntityId,
      sourceRepository: entity.sourceRepository,
      metadata: entity.metadata,
    );
  }

  factory NotificationModel.fromFirestore(Map<String, dynamic> map, String documentId) {
    try {
      DateTime timestamp;
      if (map['timestamp'] is Timestamp) {
        timestamp = (map['timestamp'] as Timestamp).toDate();
      } else if (map['timestamp'] is DateTime) {
        timestamp = map['timestamp'] as DateTime;
      } else {
        timestamp = DateTime.now();
      }

      return NotificationModel(
        id: documentId,
        type: map['type'] as String? ?? 'general',
        title: map['title'] as String? ?? 'إشعار',
        body: map['body'] as String? ?? '',
        timestamp: timestamp,
        dataPayload: map['dataPayload'] as Map<String, dynamic>?,
        isRead: map['isRead'] as bool? ?? false,
        targetFirebaseUID: map['targetFirebaseUID'] as String?,
        sourceEntityId: map['sourceEntityId'] as String?,
        sourceRepository: map['sourceRepository'] as String?,
        metadata: map['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('❌ Error parsing notification from Firestore: $e');
      return NotificationModel.empty.copyWith(
        id: documentId,
        title: 'خطأ في تحميل الإشعار',
        body: 'حدث خطأ أثناء تحميل بيانات الإشعار',
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'dataPayload': dataPayload,
      'isRead': isRead,
      'targetFirebaseUID': targetFirebaseUID,
      'sourceEntityId': sourceEntityId,
      'sourceRepository': sourceRepository,
      'metadata': metadata,
    };
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