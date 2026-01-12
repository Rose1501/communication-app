// packages/chat_repository/lib/src/chat_repo.dart (محدث)
import 'package:chat_repository/chat_repository.dart';
import 'package:semester_repository/semester_repository.dart';

abstract class ChatRepository {
  // ✅ دالة لإنشاء هيكل الدردشة بالكامل
  Future<void> initializeChatStructure();
  // ✅ دالة لتحديث أعضاء المجموعة
  Future<void> updateGroupMembers(String groupId);
  // ✅ جلب قائمة المحادثات الخاصة للمستخدم
  Future<List<ChatRoomModel>> getMyPrivateChats(String userId);
  // === الرسائل ===
  Future<MessageModel> sendMessage(MessageModel message);
  Future<List<MessageModel>> getPrivateMessages({
    required String userId,
    required String receiverId,
  });
  Future<List<MessageModel>> getGroupMessages(String groupId);
  Future<List<MessageModel>> getDoctorsGroupMessages();
  // ✅ إضافة دالة البحث
  Future<List<MessageModel>> searchGroupMessages({
    required String groupId,
    required String query,
  });
  Future<List<MessageModel>> getUserMessages(String userId);
  Future<void> deleteMessage(MessageModel message,{String? groupId});
  Future<void> deleteAllMessages();
  //  دالة التعديل
  Future<void> updateMessage(MessageModel message, {String? groupId});

    // ✅ دالة لضمان وجود مستند الدردشة وتحديث الأعضاء بناءً على النموذج الممرر
  Future<void> ensureGroupChatDoc(String groupId, {GroupModel? groupModel, String? courseName});
  // === الأعضاء ===
  // ✅جلب أعضاء المجموعة من معرفاتهم المخزنة في مستند الدردشة
  Future<List<Map<String, dynamic>>> getGroupMembersFromIds(String groupId);
  // تقوم بمقارنة المعرفات الممررة مع الموجودة وإضافة الجديد
  Future<void> syncGroupMembers(String groupId, List<String> memberIds);
  Future<List<Map<String, dynamic>>> getDoctors();
  Future<Map<String, int>> getUserRoles();

  // === المجموعات ===
  Future<ChatRoomModel> createGroupChat({
    required String name,
    required List<String> memberIds,
    String? imageUrl,
  });
  Future<List<ChatRoomModel>> getUserGroups(String userId);
  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
  });
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String userId,
  });
  Future<ChatRoomModel> getGroupInfo(String groupId);
}