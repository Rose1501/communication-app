// packages/chat_repository/lib/src/models/message_model.dart
import 'package:chat_repository/chat_repository.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
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

  const MessageModel({
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

  static final empty = MessageModel(
    id: '',
    message: '',
    senderId: '',
    senderName: '',
    messageAttachment: '',
    timeMessage: '',
    timestamp: DateTime.now(),
    chatType: 'educational_group',
  );

  bool get isEmpty => this == MessageModel.empty;
  bool get isNotEmpty => this != MessageModel.empty;

  bool get isText => messageAttachment.isEmpty;
  bool get hasAttachment => messageAttachment.isNotEmpty;
  bool get isGroupMessage => groupId != null;
  bool get isPrivateMessage => receiverId != null;

  MessageModel copyWith({
    String? id,
    String? message,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? groupId,
    String? messageAttachment,
    String? timeMessage,
    DateTime? timestamp,
    bool? isDeleted,
    String? chatType,
  }) {
    return MessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      messageAttachment: messageAttachment ?? this.messageAttachment,
      timeMessage: timeMessage ?? this.timeMessage,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      chatType: chatType ?? this.chatType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'groupId': groupId,
      'messageAttachment': messageAttachment,
      'timeMessage': timeMessage,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'chatType': chatType,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // تحويل timestamp
    DateTime timestamp = DateTime.now();
    
    return MessageModel(
      id: json['id'] as String? ?? '',
      message: json['message'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? 'مستخدم',
      receiverId: json['receiverId'] as String?,
      groupId: json['groupId'] as String?,
      messageAttachment: json['messageAttachment'] as String? ?? '',
      timeMessage: json['timeMessage'] as String? ?? timestamp.toIso8601String(),
      timestamp: timestamp,
      isDeleted: json['isDeleted'] as bool? ?? false,
      chatType: json['chatType'] as String? ?? 'educational_group',
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      message: message,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      groupId: groupId,
      messageAttachment: messageAttachment,
      timeMessage: timeMessage,
      timestamp: timestamp,
      isDeleted: isDeleted,
      chatType: chatType,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      message: entity.message,
      senderId: entity.senderId,
      senderName: entity.senderName,
      receiverId: entity.receiverId,
      groupId: entity.groupId,
      messageAttachment: entity.messageAttachment,
      timeMessage: entity.timeMessage,
      timestamp: entity.timestamp,
      isDeleted: entity.isDeleted,
      chatType: entity.chatType,
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