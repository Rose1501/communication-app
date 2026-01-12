import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// 🎯 كيان إشعار موحد يدمج جميع أنواع الإشعارات
class UnifiedNotificationEntity extends Equatable {
  final String id;
  final String type; // notification, complaint, request, subjective, advertisement
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? targetUserId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String? relatedId; // ID للعنصر المرتبط (شكوى، طلب، إعلان...)
  final String? icon;
  final String? actionType; // view, reply, approve, reject

  const UnifiedNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.data,
    this.isRead = false,
    this.targetUserId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.relatedId,
    this.icon,
    this.actionType,
  });

  factory UnifiedNotificationEntity.fromFirestore(Map<String, dynamic> doc) {
    return UnifiedNotificationEntity(
      id: doc['id'] as String,
      type: doc['type'] as String,
      title: doc['title'] as String,
      body: doc['body'] as String,
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      data: Map<String, dynamic>.from(doc['data'] ?? {}),
      isRead: doc['isRead'] as bool? ?? false,
      targetUserId: doc['targetUserId'] as String?,
      senderId: doc['senderId'] as String,
      senderName: doc['senderName'] as String,
      senderRole: doc['senderRole'] as String,
      relatedId: doc['relatedId'] as String?,
      icon: doc['icon'] as String?,
      actionType: doc['actionType'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'data': data,
      'isRead': isRead,
      'targetUserId': targetUserId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'relatedId': relatedId,
      'icon': icon,
      'actionType': actionType,
    };
  }

  @override
  List<Object?> props() => [
        id,
        type,
        title,
        body,
        timestamp,
        data,
        isRead,
        targetUserId,
        senderId,
        senderName,
        senderRole,
        relatedId,
        icon,
        actionType,
      ];
}