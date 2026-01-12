// lib/features/chat/bloc/chat_state.dart
part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> props() => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSending extends ChatState {}

class ChatError extends ChatState {
  final String message;
  final bool canRetry;
  final VoidCallback? retryAction;
  
  const ChatError({
    required this.message,
    this.canRetry = false,
    this.retryAction,
  });
  
  @override
  List<Object> props() => [message, canRetry];
}

class ChatConnectionLost extends ChatState {
  final String message;
  final bool canRetry;
  
  const ChatConnectionLost({
    required this.message,
    this.canRetry = false,
  });
  
  @override
  List<Object> props() => [message, canRetry];
}

class ChatReconnecting extends ChatState {}

class ChatMessageSent extends ChatState {
  final MessageModel message;
  
  const ChatMessageSent({required this.message});
  
  @override
  List<Object> props() => [message];
}

class ChatMessageRetried extends ChatState {}

class PrivateMessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  
  const PrivateMessagesLoaded({required this.messages});
  
  PrivateMessagesLoaded copyWith({
    List<MessageModel>? messages,
  }) {
    return PrivateMessagesLoaded(
      messages: messages ?? this.messages,
    );
  }
  
  @override
  List<Object> props() => [messages];
}

class GroupMessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  
  const GroupMessagesLoaded({required this.messages});
  
  GroupMessagesLoaded copyWith({
    List<MessageModel>? messages,
  }) {
    return GroupMessagesLoaded(
      messages: messages ?? this.messages,
    );
  }
  
  @override
  List<Object> props() => [messages];
}

class DoctorsMessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  
  const DoctorsMessagesLoaded({required this.messages});
  
  DoctorsMessagesLoaded copyWith({
    List<MessageModel>? messages,
  }) {
    return DoctorsMessagesLoaded(
      messages: messages ?? this.messages,
    );
  }
  
  @override
  List<Object> props() => [messages];
}

class UserRolesLoaded extends ChatState {
  final Map<String, int> roles;
  
  const UserRolesLoaded({required this.roles});
  
  @override
  List<Object> props() => [roles];
}

class CacheCleared extends ChatState {}

// ✅ حالة جديدة: قائمة جميع المحادثات (مجموعات وخاصة)
class MyChatsLoaded extends ChatState {
  final List<ChatRoomModel> chats;

  const MyChatsLoaded({required this.chats});

  @override
  List<Object> props() => [chats];
}

// حالة التحقق من مجموعة الأطباء
class DoctorsGroupChecking extends ChatState {
  const DoctorsGroupChecking();
  
  @override
  List<Object> props() => [];
}

// حالة نتيجة التحقق من مجموعة الأطباء
class DoctorsGroupChecked extends ChatState {
  final bool exists;
  
  const DoctorsGroupChecked({required this.exists});
  
  @override
  List<Object> props() => [exists];
}

// حالة إنشاء مجموعة الأطباء
class DoctorsGroupCreated extends ChatState {
  const DoctorsGroupCreated();
  
  @override
  List<Object> props() => [];
}

class GroupMembersLoaded extends ChatState {
  final List<Map<String, dynamic>> members;
  
  const GroupMembersLoaded(this.members);
  
  @override
  List<Object> props() => [members];
}