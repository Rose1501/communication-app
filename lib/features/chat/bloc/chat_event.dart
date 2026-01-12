// lib/features/chat/bloc/chat_event.dart
part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  
  @override
  List<Object> props() => [];
}

class LoadPrivateMessages extends ChatEvent {
  final String userId;
  final String receiverId;
  
  const LoadPrivateMessages({
    required this.userId,
    required this.receiverId,
  });
  
  @override
  List<Object> props() => [userId, receiverId];
}

class LoadGroupMessages extends ChatEvent {
  final String groupId;
  
  const LoadGroupMessages(this.groupId,);
  
  @override
  List<Object> props() => [groupId];
}

class LoadDoctorsMessages extends ChatEvent {
  const LoadDoctorsMessages();
}

class SendMessage extends ChatEvent {
  final MessageModel message;
  
  const SendMessage(this.message);
  
  @override
  List<Object> props() => [message];
}

class DeleteMessage extends ChatEvent {
  final MessageModel message;
  final String? groupId;
  
  const DeleteMessage(this.message,{this.groupId});
  
  @override
  List<Object> props() => [message, groupId!];
}

class UpdateMessage extends ChatEvent {
  final MessageModel message;
  final String? groupId;

  const UpdateMessage(this.message, {this.groupId});

  @override
  List<Object> props() => [message, groupId!];
}

class LoadUserRoles extends ChatEvent {
  const LoadUserRoles();
}

class CheckConnection extends ChatEvent {
  final bool isConnected;
  
  const CheckConnection({required this.isConnected});
  
  @override
  List<Object> props() => [isConnected];
}

class RetrySendMessage extends ChatEvent {
  const RetrySendMessage();
}

class ClearCache extends ChatEvent {
  const ClearCache();
}

class SyncMessages extends ChatEvent {
  const SyncMessages();
}

class SearchMessages extends ChatEvent {
  final String groupId;
  final String query;

  const SearchMessages({required this.groupId, required this.query});

  @override
  List<Object> props() => [groupId, query];
}

// ✅ حدث جديد: جلب محادثاتي (Groups + Private)
class LoadMyChats extends ChatEvent {
  final String userId;
  final String userRole;

  const LoadMyChats({required this.userId, required this.userRole});

  @override
  List<Object> props() => [userId, userRole];
}

// التحقق من وجود مجموعة الأطباء
class CheckDoctorsGroup extends ChatEvent {
  final String userId;
  final String userRole;
  
  const CheckDoctorsGroup({
    required this.userId,
    required this.userRole,
  });
  
  @override
  List<Object> props() => [userId, userRole];
}

// إنشاء مجموعة الأطباء
class CreateDoctorsGroup extends ChatEvent {
  const CreateDoctorsGroup();
  
  @override
  List<Object> props() => [];
}

class EnsureGroupData extends ChatEvent {
  final String groupId;
  final GroupModel? groupModel;
  final String? courseName;

  const EnsureGroupData({
    required this.groupId,
    this.groupModel,
    this.courseName,
  });

  @override
  List<Object> props() => [groupId];
}
// حدث لجلب الأعضاء كاحتياطي (Fallback)
class LoadGroupMembersFallback extends ChatEvent {
  final String groupId;
  
  const LoadGroupMembersFallback(this.groupId);
  
  @override
  List<Object> props() => [groupId];
}