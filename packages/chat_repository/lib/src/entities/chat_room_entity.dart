// packages/chat_repository/lib/src/entities/chat_room_entity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final List<String> memberIds;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastSenderId;
  final String createdAt;
  final String? updatedAt;
  final String lastActivity;

  const ChatRoomEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.memberIds,
    this.imageUrl,
    this.lastMessage,
    this.lastSenderId,
    required this.createdAt,
    this.updatedAt,
    required this.lastActivity,
  });

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'memberIds': memberIds,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastSenderId != null) 'lastSenderId': lastSenderId,
      'createdAt': Timestamp.fromDate(DateTime.parse(createdAt)),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(DateTime.parse(updatedAt!)),
      'lastActivity': Timestamp.fromDate(DateTime.parse(lastActivity)),
    };
  }

  factory ChatRoomEntity.fromDocument(Map<String, dynamic> doc) {
    return ChatRoomEntity(
      id: doc['id'] as String,
      name: doc['name'] as String,
      type: doc['type'] as String,
      memberIds: List<String>.from(doc['memberIds']),
      imageUrl: doc['imageUrl'] as String?,
      lastMessage: doc['lastMessage'] as String?,
      lastSenderId: doc['lastSenderId'] as String?,
      createdAt: (doc['createdAt'] as Timestamp).toDate().toIso8601String(),
      updatedAt: doc['updatedAt'] != null 
          ? (doc['updatedAt'] as Timestamp).toDate().toIso8601String() 
          : null,
      lastActivity: (doc['lastActivity'] as Timestamp).toDate().toIso8601String(),
    );
  }

  @override
  List<Object?> props() => [
    id,
    name,
    type,
    memberIds,
    imageUrl,
    lastMessage,
    lastSenderId,
    createdAt,
    updatedAt,
    lastActivity,
  ];
}