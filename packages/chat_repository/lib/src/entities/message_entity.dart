// packages/chat_repository/lib/src/entities/message_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final String? receiverId;
  final String? groupId;
  final String messageAttachment;
  final String timeMessage;
  final DateTime timestamp;
  final bool isDeleted;
  final String chatType;

  const MessageEntity({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    this.receiverId,
    this.groupId,
    required this.messageAttachment,
    required this.timeMessage,
    required this.timestamp,
    this.isDeleted = false,
    required this.chatType,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      if (receiverId != null) 'receiverId': receiverId,
      if (groupId != null) 'groupId': groupId,
      'messageAttachment': messageAttachment,
      'timeMessage': timeMessage,
      'timestamp': timestamp,
      'chatType': chatType,
      'isDeleted': isDeleted,
      'createdAt': timestamp,
    };
  }

  factory MessageEntity.fromDocument(Map<String, dynamic> doc) {
    // استخراج timestamp
    Timestamp timestamp;
    
    if (doc['timestamp'] != null && doc['timestamp'] is Timestamp) {
      timestamp = doc['timestamp'] as Timestamp;
    } else if (doc['createdAt'] != null && doc['createdAt'] is Timestamp) {
      timestamp = doc['createdAt'] as Timestamp;
    } else if (doc['timeMessage'] != null && doc['timeMessage'] is String) {
      try {
        final dateTime = DateTime.parse(doc['timeMessage'] as String);
        timestamp = Timestamp.fromDate(dateTime);
      } catch (e) {
        timestamp = Timestamp.now();
      }
    } else {
      timestamp = Timestamp.now();
    }
    
    // استخراج timeMessage
    String timeMessage;
    if (doc['timeMessage'] != null && doc['timeMessage'] is String) {
      timeMessage = doc['timeMessage'] as String;
    } else {
      timeMessage = timestamp.toDate().toIso8601String();
    }
    
    return MessageEntity(
      id: doc['id'] as String? ?? '',
      message: doc['message'] as String? ?? '',
      senderId: doc['senderId'] as String? ?? doc['sendMessageID'] as String? ?? '',
      senderName: doc['senderName'] as String? ?? doc['sender_name'] as String? ?? 'مستخدم',
      receiverId: doc['receiverId'] as String? ?? doc['receiver_id'] as String?,
      groupId: doc['groupId'] as String? ?? doc['groupID'] as String?,
      messageAttachment: doc['messageAttachment'] as String? ?? '',
      timeMessage: timeMessage,
      timestamp: (doc['timeMessage'] as Timestamp).toDate(),
      isDeleted: doc['isDeleted'] as bool? ?? false,
      chatType: doc['chatType'] as String? ?? 'educational_group',
    );
  }

  @override
  List<Object?> props() => [
    id,
    message,
    senderId,
    senderName,
    receiverId,
    groupId,
    messageAttachment,
    timeMessage,
    timestamp,
    isDeleted,
    chatType,
  ];
}