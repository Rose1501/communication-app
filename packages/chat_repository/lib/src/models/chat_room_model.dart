// packages/chat_repository/lib/src/models/chat_room_model.dart
import 'package:chat_repository/chat_repository.dart';
import 'package:equatable/equatable.dart';

class ChatRoomModel extends Equatable {
  final String id;
  final String name;
  final String type; // 'private', 'group', 'doctors'
  final List<String> memberIds;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastSenderId;
  final String createdAt;
  final String? updatedAt;
  final String lastActivity;

  const ChatRoomModel({
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

  static final empty = ChatRoomModel(
    id: '',
    name: '',
    type: 'private',
    memberIds: [],
    createdAt: '',
    lastActivity: '',
  );

  bool get isEmpty => this == ChatRoomModel.empty;
  bool get isNotEmpty => this != ChatRoomModel.empty;

  bool get isPrivate => type == 'private';
  bool get isGroup => type == 'group' || type == 'doctors_group' || type == 'educational_group';
  bool get isDoctorsGroup => type == 'doctors';

  ChatRoomModel copyWith({
    String? id,
    String? name,
    String? type,
    List<String>? memberIds,
    String? imageUrl,
    String? lastMessage,
    String? lastSenderId,
    String? createdAt,
    String? updatedAt,
    String? lastActivity,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      imageUrl: imageUrl ?? this.imageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  ChatRoomEntity toEntity() {
    return ChatRoomEntity(
      id: id,
      name: name,
      type: type,
      memberIds: memberIds,
      imageUrl: imageUrl,
      lastMessage: lastMessage,
      lastSenderId: lastSenderId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActivity: lastActivity,
    );
  }

  factory ChatRoomModel.fromEntity(ChatRoomEntity entity) {
    return ChatRoomModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      memberIds: entity.memberIds,
      imageUrl: entity.imageUrl,
      lastMessage: entity.lastMessage,
      lastSenderId: entity.lastSenderId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastActivity: entity.lastActivity,
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