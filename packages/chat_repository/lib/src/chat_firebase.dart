// packages/chat_repository/lib/src/chat_firebase.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:semester_repository/semester_repository.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference _chatRoomsCollection;
  final UserRepository _userRepository;
  final SemesterRepository semesterRepo ; 

  FirebaseChatRepository(this._userRepository, this.semesterRepo)
      : _firestore = FirebaseFirestore.instance,
        _chatRoomsCollection = FirebaseFirestore.instance.collection('chat_rooms') {
    _configureOfflineSupport();
  }

  void _configureOfflineSupport() {
    _firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ✅ أنواع الدردشات
  static const String chatTypePrivate = 'private';
  static const String chatTypeEducationalGroup = 'educational_group';
  static const String chatTypeDoctorsGroup = 'doctors_group';

  // ✅ مجموعات فرعية
  static const String subCollectionGroupMessages = 'group_messages';
  static const String subCollectionPrivateMessages = 'private_messages';
  static const String subCollectionDoctorsMessages = 'doctors_messages';

  // ✅ توليد معرف فريد للرسالة
  String _generateMessageId(String chatType, {String? groupId}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${chatType}_msg_${timestamp}_${groupId ?? ''}';
  }

  // تحويل الوقت من أي نوع (Timestamp, String, etc) إلى DateTime بأمان
  DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// تحويل الوقت إلى نص String بأمان
  String _parseTimeString(dynamic value, DateTime defaultTime) {
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    return defaultTime.toIso8601String();
  }

  // ✅ دالة لإنشاء هيكل الدردشة بالكامل
  @override
  Future<void> initializeChatStructure() async {
    try {
      print('🏗️ بدء إنشاء هيكل الدردشة في Firestore...');
      
      // --- 1. إنشاء مجموعة الأطباء ---
      // جلب قائمة المستخدمين الصالحين للمجموعة (الأطباء، المسؤولين، المديرين)
    final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Doctor');
    final admins = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
    final managers = await _userRepository.getUsersByRoleOrIds(role: 'Manager');
    
    // دمج كل المعرفات في قائمة واحدة
    final allMemberIds = [
      ...doctors.map((doctor) => doctor.userID),
      ...admins.map((admin) => admin.userID),
      ...managers.map((manager) => manager.userID)
    ];
    
    // إزالة التكرارات
    final uniqueMemberIds = Set<String>.from(allMemberIds).toList();
    
    print('👥 تم العثور على ${uniqueMemberIds.length} عضو صالح لمجموعة التدريسين');
      
      // إنشاء مجموعة الأطباء
      final doctorsGroupRef = _chatRoomsCollection.doc('doctors_group');
      final doctorsDoc = await doctorsGroupRef.get();
      
      if (!doctorsDoc.exists) {
        await doctorsGroupRef.set({
          'id': 'doctors_group',
          'type': 'doctors_group',
          'name': 'مجموعة التدريسين',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': FieldValue.serverTimestamp(),
          'memberIds': allMemberIds, // ✅ إضافة أعضاء المجموعة
          'memberCount': allMemberIds.length,
        });
        print('✅ تم إنشاء مجموعة الأطباء مع ${allMemberIds.length} عضو');
      } else {
        // تحديث الأعضاء إذا كانت المجموعة موجودة
      final currentMemberIds = List<String>.from(doctorsDoc['memberIds'] ?? []);
      
      // التحقق من وجود أعضاء جدد وإضافتهم
      bool hasNewMembers = false;
      for (final memberId in uniqueMemberIds) {
        if (!currentMemberIds.contains(memberId)) {
          currentMemberIds.add(memberId);
          hasNewMembers = true;
        }
      }
      // التحقق من وجود أعضاء تمت إزالتهم
      bool hasRemovedMembers = false;
      final finalMemberIds = <String>[];
      for (final memberId in currentMemberIds) {
        if (uniqueMemberIds.contains(memberId)) {
          finalMemberIds.add(memberId);
        } else {
          hasRemovedMembers = true;
        }
      }
      
      // تحديث فقط إذا كان هناك تغيير في الأعضاء
      if (hasNewMembers || hasRemovedMembers) {
        await doctorsGroupRef.update({
          'memberIds': finalMemberIds, 
          'memberCount': finalMemberIds.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ تم تحديث مجموعة الأطباء مع ${finalMemberIds.length} عضو');
      } else {
        print('✅ قائمة أعضاء مجموعة الأطباء محدثة بالفعل');
      }
    }
      
      print('🏁 اكتمل إنشاء هيكل الدردشة');
      
    } catch (e, stackTrace) {
      print('❌ خطأ في إنشاء هيكل الدردشة: $e');
      print('📋 Stack trace: $stackTrace');
    }
  }

    // ✅ دالة مساعدة مبسطة: تضمن وجود مستند الدردشة (القشرة) فقط
  Future<void> _ensureGroupChatDocExists(String groupId, {String? groupName}) async {
    try {
      final docRef = _chatRoomsCollection.doc('educational_group_$groupId');
      final doc = await docRef.get();

      if (!doc.exists) {
        print('🏗️ [_ensureGroupChatDocExists] إنشاء قشرة المستند للمجموعة: $groupId');
        await docRef.set({
          'id': groupId,
          'type': chatTypeEducationalGroup,
          'name': groupName ?? 'مجموعة دراسية',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': FieldValue.serverTimestamp(),
          // ملاحظة: الأعضاء سيتم إضافتهم لاحقاً عبر ensureGroupChatDoc
        }, SetOptions(merge: true));
      } else {
        print('✅ [_ensureGroupChatDocExists] المستند موجود بالفعل');
      }
    } catch (e) {
      print('❌ خطأ في إنشاء قشرة المستند: $e');
    }
  }

  // ✅ دالة لتحديث أعضاء المجموعة
@override
Future<void> updateGroupMembers(String groupId) async {
  try {
    print('🔄 تحديث أعضاء المجموعة: $groupId');
    
    if (groupId == 'doctors_group') {
      // تحديث مجموعة الأطباء
      await initializeChatStructure();
    } 
    
    print('✅ تم تحديث أعضاء المجموعة بنجاح');
  } catch (e) {
    print('❌ خطأ في تحديث أعضاء المجموعة: $e');
    rethrow;
  }
}

  Future<DocumentReference> _getOrCreateGroupChatDoc(String groupId) async {
    final chatDocRef = _chatRoomsCollection.doc('educational_group_$groupId');

    try {
      print('🔍 التحقق من وجود مستند المجموعة: educational_group_$groupId');
      final doc = await chatDocRef.get();

      if (!doc.exists) {
        print('🏗️ إنشاء مستند جديد للمجموعة التعليمية: $groupId');
        // إذا لم يكن موجوداً، نستخدم دالة الضمان الجديدة
        print('📜 المستند غير موجود، استدعاء _ensureGroupChatDocExists');
        await _ensureGroupChatDocExists(groupId);
      }

      return chatDocRef;
    } catch (e, stackTrace) {
      print('❌ خطأ في إنشاء/جلب مستند المجموعة: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ✅ إرسال رسالة مع ضمان وجود الهيكل
  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    if (message.chatType == chatTypePrivate) {
      return await sendPrivateMessage(message);
    } else if (message.chatType == chatTypeDoctorsGroup) {
      return await sendDoctorsGroupMessage(message);
    } else {
      return await sendGroupMessage(message);
    }
  }

  /// 1. إرسال رسالة خاصة
  Future<MessageModel> sendPrivateMessage(MessageModel message) async {
    try {
      print('📤 [Private] بدء إرسال رسالة خاصة');
      if (message.receiverId == null || message.receiverId!.isEmpty) {
        throw Exception('receiverId مطلوب للمحادثات الخاصة');
      }

      // التحقق من أن senderId ليس فارغاً
      if (message.senderId.isEmpty) {
        print('❌ خطأ: senderId فارغ في sendPrivateMessage');
        throw Exception('senderId مطلوب للمحادثات الخاصة');
      }

      final chatId = _getPrivateChatId(message.senderId, message.receiverId!);
      final chatDocRef = _chatRoomsCollection.doc(chatId);
      final messageId = _generateMessageId(message.chatType);
      final now = DateTime.now();

      // 1. التأكد من وجود مستند المحادثة وإنشاؤه إذا لم يكن موجوداً
      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists) {
        print('🏗️ [Private] إنشاء محادثة جديدة: $chatId');
        await chatDocRef.set({
          'id': chatId,
          'type': chatTypePrivate,
          'participants': [message.senderId, message.receiverId],
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': now, // استخدام DateTime local للعرض السريع
          'lastActivityServer': FieldValue.serverTimestamp(), // للترتيب في المستقبل
        });
      }

      // 2. إضافة الرسالة للمجموعة الفرعية
      final messageData = {
        'id': messageId,
        'message': message.message,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'receiverId': message.receiverId,
        'messageAttachment': message.messageAttachment,
        'timeMessage': now.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'chatType': chatTypePrivate,
        'isDeleted': false,
      };

      await chatDocRef.collection(subCollectionPrivateMessages).doc(messageId).set(messageData);

      // 3. تحديث البيانات الوصفية للمحادثة
      await chatDocRef.update({
        'lastActivityServer': FieldValue.serverTimestamp(),
        'lastActivity': now,
        'lastMessage': message.message.length > 50 ? '${message.message.substring(0, 50)}...' : message.message,
        'lastSenderId': message.senderId,
      });

      print('✅ [Private] تم الإرسال بنجاح');
      // إرجاع الرسالة المحدثة مع المعرف الصحيح
      return message.copyWith(id: messageId, timestamp: now, timeMessage: now.toIso8601String(), chatType: chatTypePrivate);

    } catch (e, stackTrace) {
      print('❌ [Private] خطأ في الإرسال: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 2. إرسال رسالة لمجموعة تعليمية
  Future<MessageModel> sendGroupMessage(MessageModel message) async {
    try {
      print('📤 [Group] بدء إرسال رسالة لمجموعة تعليمية');

      // التحقق من البيانات الأساسية
      if (message.groupId == null || message.groupId!.isEmpty) {
        throw Exception('groupId مطلوب لإرسال رسالة جماعية');
      }

      final groupId = message.groupId!;
      String messageId;
      String chatType;

      // تحديد نوع الدردشة
      if (groupId == 'doctors_group') {
        chatType = chatTypeDoctorsGroup;
      } else {
        chatType = chatTypeEducationalGroup;
      }

      messageId = _generateMessageId(chatType, groupId: groupId);
      
      // ✅ إنشاء timestamp جديد
      final timestamp = DateTime.now();

    // 1. ضمان وجود مستند المجموعة أولاً وتحديث الأعضاء
      DocumentReference groupDocRef;
      if (chatType == chatTypeEducationalGroup) {
        groupDocRef = await _getOrCreateGroupChatDoc(groupId);
      } else {
        groupDocRef = _chatRoomsCollection.doc('doctors_group');
        // التحقق من وجود مجموعة الأطباء
        final doc = await groupDocRef.get();
        if (!doc.exists) {
          print('🏗️ إنشاء مجموعة الأطباء');
          await groupDocRef.set({
            'id': 'doctors_group',
            'type': 'doctors_group',
            'name': 'مجموعة التدريسين',
            'createdAt': timestamp,
            'lastActivity': timestamp,
          });
        } else {
         // تحديث الأعضاء في مجموعة الأطباء
          //await updateGroupMembers('doctors_group');
          await _updateDoctorsGroupMembers();
        }
      }

      // 2. تحديد المجموعة الفرعية المناسبة
      CollectionReference targetCollection;
      if (chatType == chatTypeEducationalGroup) {
        targetCollection = groupDocRef.collection(subCollectionGroupMessages);
      } else {
        targetCollection = groupDocRef.collection(subCollectionDoctorsMessages);
      }

      // 3. تحضير بيانات الرسالة
      final messageData = {
        'id': messageId,
        'message': message.message,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'groupId': groupId,
        'messageAttachment': message.messageAttachment,
        'timeMessage': timestamp.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'chatType': chatType,
        'isDeleted': false,
        'status': 'sent',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 4. حفظ الرسالة
      await targetCollection.doc(messageId).set(messageData);
      print('✅ تم إرسال الرسالة بنجاح: $messageId');

      // 5. تحديث آخر نشاط في مستند المجموعة
      await _updateLastActivity(chatType, groupId, message, timestamp);

      // ✅ إرجاع MessageModel مع البيانات المحدثة
      return MessageModel(
        id: messageId,
        message: message.message,
        senderId: message.senderId,
        senderName: message.senderName,
        receiverId: message.receiverId,
        groupId: message.groupId,
        messageAttachment: message.messageAttachment,
        timeMessage: timestamp.toIso8601String(),
        timestamp: timestamp,
        isDeleted: false,
        chatType: chatType,
      );

    } catch (e, stackTrace) {
      print('❌ خطأ في إرسال الرسالة: $e');
      print('📋 Stack trace: $stackTrace');
      throw Exception('فشل في إرسال الرسالة: ${e.toString()}');
    }
  }

  /// 3. إرسال رسالة لمجموعة الأطباء
  Future<MessageModel> sendDoctorsGroupMessage(MessageModel message) async {
    try {
      print('📤 [Doctors] بدء إرسال رسالة لمجموعة الأطباء');
      
      final chatId = 'doctors_group';
      final chatDocRef = _chatRoomsCollection.doc(chatId);
      final messageId = _generateMessageId(message.chatType);
      final now = DateTime.now();

      // 1. التأكد من وجود المجموعة
      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists) {
        print('🏗️ [Doctors] إنشاء مجموعة الأطباء');
        await chatDocRef.set({
          'id': 'doctors_group',
          'type': chatTypeDoctorsGroup,
          'name': 'مجموعة التدريسين',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': now,
          'lastActivityServer': FieldValue.serverTimestamp(),
          'memberIds': [], // سيتم تحديثها لاحقاً
        });
      } else {
        // ✅ تحديث: إضافة المرسل إلى memberIds إذا لم يكن موجوداً
        final data = chatDoc.data() as Map<String, dynamic>;
        final currentMemberIds = List<String>.from(data['memberIds'] ?? []);
        if (!currentMemberIds.contains(message.senderId)) {
          currentMemberIds.add(message.senderId);
          await chatDocRef.update({'memberIds': currentMemberIds, 'memberCount': currentMemberIds.length});
        }
      }

      // 2. حفظ الرسالة
      final messageData = {
        'id': messageId,
        'message': message.message,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'groupId': 'doctors_group',
        'messageAttachment': message.messageAttachment,
        'timeMessage': now.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'chatType': chatTypeDoctorsGroup,
        'isDeleted': false,
      };
      await chatDocRef.collection(subCollectionDoctorsMessages).doc(messageId).set(messageData);

      // 3. تحديث النشاط
      await chatDocRef.update({
        'lastActivityServer': FieldValue.serverTimestamp(),
        'lastActivity': now,
        'lastMessage': message.message.length > 50 ? '${message.message.substring(0, 50)}...' : message.message,
        'lastSenderId': message.senderId,
      });

      print('✅ [Doctors] تم الإرسال بنجاح');
      return message.copyWith(id: messageId, timestamp: now, timeMessage: now.toIso8601String(), chatType: chatTypeDoctorsGroup);

    } catch (e, stackTrace) {
      print('❌ [Doctors] خطأ في الإرسال: $e');
      rethrow;
    }
  }

  // دالة مساعدة لتحديث أعضاء مجموعة الأطباء
Future<void> _updateDoctorsGroupMembers() async {
  try {
    print('🔄 تحديث أعضاء مجموعة الأطباء');
    
    // جلب المستخدمين صاحبي الصلاحيات (Doctor, Admin, Manager)
    final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Doctor');
    final admins = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
    final managers = await _userRepository.getUsersByRoleOrIds(role: 'Manager');
    
    // دمج كل المعرفات في قائمة واحدة
    final allMemberIds = [
      ...doctors.map((doctor) => doctor.userID),
      ...admins.map((admin) => admin.userID),
      ...managers.map((manager) => manager.userID)
    ];
    // إزالة التكرارات
    final uniqueMemberIds = Set<String>.from(allMemberIds).toList();
    
    final doctorsGroupRef = _chatRoomsCollection.doc('doctors_group');
    final doctorsDoc = await doctorsGroupRef.get();
    
    if (doctorsDoc.exists) {
      final currentMemberIds = List<String>.from(doctorsDoc['memberIds'] ?? []);
      
      // التحقق من وجود أعضاء جدد
      bool hasChanges = false;
      final finalMemberIds = <String>[];
      // إضافة الأعضاء الحاليين الذين لا يزالون صالحين
      for (final memberId in currentMemberIds) {
        if (uniqueMemberIds.contains(memberId)) {
          finalMemberIds.add(memberId);
        } else {
          hasChanges = true; // عضو تمت إزالته
        }
      }
      
      // إضافة الأعضاء الجدد
      for (final memberId in uniqueMemberIds) {
        if (!currentMemberIds.contains(memberId)) {
          finalMemberIds.add(memberId);
          hasChanges = true; // عضو جديد
        }
      }
       // تحديث فقط إذا كان هناك تغيير
      if (hasChanges) {
        await doctorsGroupRef.update({
          'memberIds': finalMemberIds,
          'memberCount': finalMemberIds.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ تم تحديث مجموعة الأطباء مع ${finalMemberIds.length} عضو');
      } else {
        print('✅ قائمة أعضاء مجموعة الأطباء محدثة بالفعل');
      }
    }
  } catch (e) {
    print('❌ خطأ في تحديث أعضاء مجموعة الأطباء: $e');
  }
}

  // ✅ تحديث دالة _updateLastActivity لقبول timestamp
  Future<void> _updateLastActivity(String chatType, String groupId, MessageModel message, DateTime timestamp) async {
    try {
      String docId;
      if (chatType == chatTypeEducationalGroup) {
        docId = 'educational_group_$groupId';
      } else {
        docId = 'doctors_group';
      }

      final updateData = {
        'lastActivity': timestamp,
        'lastMessage': message.message.length > 50 
            ? '${message.message.substring(0, 50)}...' 
            : message.message,
        'lastSenderId': message.senderId,
      };

      await _chatRoomsCollection.doc(docId).update(updateData);
      print('🔄 تم تحديث آخر نشاط للمجموعة: $docId');
      
    } catch (e) {
      print('⚠️ خطأ في تحديث آخر نشاط: $e');
    }
  }

  // ✅ جلب قائمة المحادثات الخاصة للمستخدم
  @override
  Future<List<ChatRoomModel>> getMyPrivateChats(String userId) async {
    try {
      print('🔍 جلب المحادثات الخاصة للمستخدم: $userId');

      // استخدام استعلام بسيط بدون ترتيب لتجنب مشاكل الفهرسة
      final querySnapshot = await _chatRoomsCollection
          .where('type', isEqualTo: 'private')
          .where('participants', arrayContains: userId)
          .limit(50) // جلب آخر 50 محادثة خاصة
          .get();

      final chats = <ChatRoomModel>[];

      // نقوم بمعالجة كل محادثة
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('محادثة :$data');
        final participants = List<String>.from(data['participants'] ?? []);

        // تحديد هوية الطرف الآخر (المستلم)
        final otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');

        if (otherUserId.isNotEmpty) {
          // جلب بيانات المستخدم الآخر (الاسم والصورة)
          try {
          // نحتاج إلى حقن UserRepository في FirebaseChatRepository
          final otherUser = await _userRepository.getUserByUserID(otherUserId);

          if (otherUser.userID.isNotEmpty) {
            // تحويل الوقت
            DateTime lastActivity = DateTime.now();
            if (data['lastActivity'] is DateTime) {
              lastActivity = data['lastActivity'] as DateTime;
            } else if (data['lastActivity'] is Timestamp) {
              lastActivity = (data['lastActivity'] as Timestamp).toDate();
            } else if (data['lastActivityServer'] is Timestamp) {
              lastActivity = (data['lastActivityServer'] as Timestamp).toDate();
            }
            
            // بناء ChatRoomModel للمحادثة الخاصة
            chats.add(ChatRoomModel(
              id: doc.id, // مثال: private_chat_A_B
              name:  otherUser.name,
              type: 'private',
              memberIds: participants,
              imageUrl:  otherUser.urlImg,
              lastMessage: data['lastMessage'] as String?,
              lastSenderId: data['lastSenderId'] as String?,
              createdAt: (data['createdAt'] as Timestamp).toDate().toIso8601String(),
              lastActivity: lastActivity.toIso8601String(),
            ));
          }
          } catch (e) {
          print('❌ خطأ في جلب بيانات المستخدم الآخر: $e');
          // استخدام قيم افتراضية في حالة فشل جلب المستخدم
          chats.add(ChatRoomModel(
            id: doc.id,
            name: 'مستخدم',
            type: 'private',
            memberIds: participants,
            lastMessage: data['lastMessage'] as String?,
            lastSenderId: data['lastSenderId'] as String?,
            createdAt: (data['createdAt'] as Timestamp).toDate().toIso8601String(),
            lastActivity: DateTime.now().toIso8601String(),
          ));
        }
        }
      }

      // ✅ الترتيب محلياً (Client-side Sorting) بدلاً من orderBy في Query
      chats.sort((a, b) {
        final timeA = DateTime.tryParse(a.lastActivity) ?? DateTime(0);
        final timeB = DateTime.tryParse(b.lastActivity) ?? DateTime(0);
        return timeB.compareTo(timeA); // تنازلي
      });

      print('✅ تم جلب ${chats.length} محادثة خاصة');
      return chats;

    } catch (e) {
      print('❌ خطأ في جلب المحادثات الخاصة: $e');
      return [];
    }
  }

  /// جلب مجموعات المستخدم
@override
Future<List<ChatRoomModel>> getUserGroups(String userId) async {
  try {
    print('🔍 جلب مجموعات المستخدم: $userId');

    // ✅ إزالة orderBy لتجنب خطأ الفهرسة المركبة
    final querySnapshot = await _chatRoomsCollection
        .where('memberIds', arrayContains: userId)
        .where('type', whereIn: ['educational_group'])
        .limit(50)
        .get();

    final groups = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // تحويل الوقت بأمان
      DateTime lastActivity = DateTime.now();
      if (data['lastActivity'] is DateTime) {
        lastActivity = data['lastActivity'] as DateTime;
      } else if (data['lastActivity'] is Timestamp) {
        lastActivity = (data['lastActivity'] as Timestamp).toDate();
      } else if (data['lastActivityServer'] is Timestamp) {
        lastActivity = (data['lastActivityServer'] as Timestamp).toDate();
      } else if (data['lastActivity'] is String) {
        lastActivity = DateTime.parse(data['lastActivity']);
      }
      
      final group = ChatRoomModel(
        id: doc.id,
        name: data['name'] as String? ?? 'مجموعة تعليمية',
        type: data['type'] as String,
        memberIds: List<String>.from(data['memberIds'] ?? []),
        imageUrl: data['imageUrl'] as String?,
        lastMessage: data['lastMessage'] as String?,
        lastSenderId: data['lastSenderId'] as String?,
        createdAt: (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        updatedAt: data['updatedAt'] != null 
            ? (data['updatedAt'] as Timestamp).toDate().toIso8601String() 
            : null,
        lastActivity: lastActivity.toIso8601String(),
      );
      
      print('📋 تم جلب مجموعة: ${group.name} (${group.type})');
      return group;
    }).toList();
    
    // ✅ الترتيب محلياً
    groups.sort((a, b) {
      final timeA = DateTime.tryParse(a.lastActivity) ?? DateTime(0);
      final timeB = DateTime.tryParse(b.lastActivity) ?? DateTime(0);
      return timeB.compareTo(timeA);
    });

    print('✅ تم جلب ${groups.length} مجموعة');
    if(groups.isEmpty){
      print('📭 لا توجد مجموعات للمستخدم');
    }
    return groups;

  } catch (e) {
    print('❌ خطأ في جلب المجموعات: $e');
    return [];
  }
}

  // ✅ جلب رسائل المجموعة التعليمية (الهيكل الجديد فقط)
  @override
  Future<List<MessageModel>> getGroupMessages(String groupId) async {
    try {
      print('🔍 جلب رسائل المجموعة التعليمية: $groupId');

      final groupDocRef = _chatRoomsCollection.doc('educational_group_$groupId');
      
      // التحقق من وجود المجموعة أولاً
      final groupDoc = await groupDocRef.get();
      
      if (!groupDoc.exists) {
        print('⚠️ المجموعة غير موجودة، جاري الإنشاء التلقائي...');
        await _ensureGroupChatDocExists(groupId);
        print('✅ تم الإنشاء التلقائي للمجموعة');
      }
      
      print('✅ المجموعة موجودة في Firestore');
      
      // جلب الرسائل من المجموعة الفرعية الصحيحة
      final messagesCollection = groupDocRef.collection(subCollectionGroupMessages);
      print('📄 مسار المجموعة الفرعية: ${messagesCollection.path}');
      
      final querySnapshot = await messagesCollection
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      print('📊 عدد الوثائق المسترجعة: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('📭 المجموعة موجودة ولكن لا تحتوي على رسائل');
        return [];
      }

      // تحويل البيانات إلى MessageModel بطريقة آمنة
      final messages = <MessageModel>[];
      
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('📝 معالجة الرسالة: ${doc.id} - ${data.containsKey('timestamp') ? 'has timestamp' : 'no timestamp'}');
          
          // ✅ استخدام الدوال المساعدة الآمنة
          final timestamp = _parseTimestamp(data['timestamp'] ?? data['createdAt']);
          final timeMessageStr = _parseTimeString(data['timeMessage'], timestamp);
        
          // ✅ إنشاء MessageModel مع بيانات آمنة
          final message = MessageModel(
            id: data['id'] as String? ?? doc.id,
            message: data['message'] as String? ?? '',
            senderId: data['senderId'] as String? ?? data['sendMessageID'] as String? ?? '',
            senderName: data['senderName'] as String? ?? data['sender_name'] as String? ?? 'مستخدم',
            groupId: data['groupId'] as String? ?? data['groupID'] as String? ?? groupId,
            messageAttachment: data['messageAttachment'] as String? ?? '',
            timeMessage: timeMessageStr,
            timestamp: timestamp,
            isDeleted: data['isDeleted'] as bool? ?? false,
            chatType: data['chatType'] as String? ?? 'educational_group',
          );
          
          messages.add(message);
          print('✅ تمت معالجة الرسالة: ${message.id} - ${message.message.substring(0, min(20, message.message.length))}');
          
        } catch (e, stackTrace) {
          print('⚠️ خطأ في معالجة الرسالة ${doc.id}: $e');
          print('📋 Stack trace: $stackTrace');
          print('📊 بيانات الرسالة: ${doc.data()}');
        }
      }

      print('✅ تم جلب ${messages.length} رسالة من الهيكل الجديد');
      return messages;

    } catch (e, stackTrace) {
      print('❌ خطأ في جلب رسائل المجموعة: $e');
      print('📋 Stack trace: $stackTrace');
      // العودة بقائمة فارغة بدلاً من رمي استثناء
      return [];
    }
  }

  // جلب رسائل مجموعة الأطباء
  @override
  Future<List<MessageModel>> getDoctorsGroupMessages() async {
    try {
      print('🔍 جلب رسائل مجموعة الأطباء');

      final doctorsGroupDoc = _chatRoomsCollection.doc('doctors_group');
      
      // التحقق من وجود المجموعة
      final doc = await doctorsGroupDoc.get();
      if (!doc.exists) {
        print('📭 مجموعة الأطباء غير موجودة، إنشاء جديدة');
        print('📭 مجموعة الأطباء غير موجودة، جاري إنشاء جديدة مع الأعضاء...');

         // جلب المستخدمين صاحبي الصلاحيات (Doctor, Admin, Manager)
      final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Doctor');
      final admins = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
      final managers = await _userRepository.getUsersByRoleOrIds(role: 'Manager');
        // دمج كل المعرفات في قائمة واحدة
      final allMemberIds = [
        ...doctors.map((doctor) => doctor.userID),
        ...admins.map((admin) => admin.userID),
        ...managers.map((manager) => manager.userID)
      ];
      
      // إزالة التكرارات
      final uniqueMemberIds = Set<String>.from(allMemberIds).toList();
      
      print('👥 تم العثور على ${uniqueMemberIds.length} عضو في مجموعة التدريسين');

        // ✅  إنشاء مستند المجموعة مع البيانات الكاملة
        await doctorsGroupDoc.set({
          'id': 'doctors_group',
          'type': 'doctors_group',
          'name': 'مجموعة التدريسين',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActivity': FieldValue.serverTimestamp(),
          'memberIds': uniqueMemberIds,      // ✅ إضافة الأعضاء
          'memberCount': uniqueMemberIds.length, // ✅ إضافة العدد
        });
        
        return [];
      }

      // إذا كانت المجموعة موجودة ولكن memberIds فارغة، يمكن تحديثها هنا أيضاً
      final data = doc.data() as Map<String, dynamic>;
      final currentMembers = List<String>.from(data['memberIds'] ?? []);
      // جلب الأعضاء الصالحين الحاليين
    final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Doctor');
    final admins = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
    final managers = await _userRepository.getUsersByRoleOrIds(role: 'Manager');
    
    // دمج كل المعرفات في قائمة واحدة
    final allMemberIds = [
      ...doctors.map((doctor) => doctor.userID),
      ...admins.map((admin) => admin.userID),
      ...managers.map((manager) => manager.userID)
    ];
    
    // إزالة التكرارات
    final uniqueMemberIds = Set<String>.from(allMemberIds).toList();
      // التحقق من وجود أعضاء جدد
    bool hasNewMembers = false;
    for (final memberId in uniqueMemberIds) {
      if (!currentMembers.contains(memberId)) {
        currentMembers.add(memberId);
        hasNewMembers = true;
      }
    }
    
    // إذا كان هناك أعضاء جدد، قم بتحديث المجموعة
    if (hasNewMembers) {
      print('👥 تم العثور على أعضاء جدد، تحديث مجموعة التدريسين');
      await doctorsGroupDoc.update({
        'memberIds': currentMembers,
        'memberCount': currentMembers.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

      final messagesCollection = doctorsGroupDoc.collection(subCollectionDoctorsMessages);

      final querySnapshot = await messagesCollection
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final messages = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
      
        // ✅ استخدام الدوال المساعدة الآمنة
        final timestamp = _parseTimestamp(data['timestamp'] ?? data['createdAt']);
        final timeMessageStr = _parseTimeString(data['timeMessage'], timestamp);
      
        return MessageModel(
          id: data['id'] as String? ?? doc.id,
          message: data['message'] as String? ?? '',
          senderId: data['senderId'] as String? ?? '',
          senderName: data['senderName'] as String? ?? 'مستخدم',
          groupId: 'doctors_group',
          messageAttachment: data['messageAttachment'] as String? ?? '',
          timeMessage: timeMessageStr,
          timestamp: timestamp,
          isDeleted: data['isDeleted'] as bool? ?? false,
          chatType: data['chatType'] as String? ?? 'doctors_group',
        );
      }).toList();

      print('✅ تم جلب ${messages.length} رسالة لمجموعة الأطباء');
      return messages;

    } catch (e) {
      print('❌ خطأ في جلب رسائل مجموعة الأطباء: $e');
      return [];
    }
  }

  // جلب الرسائل الخاصة
  @override
  Future<List<MessageModel>> getPrivateMessages({
    required String userId,
    required String receiverId,
  }) async {
    try {
      print('🔍 جلب الرسائل الخاصة بين $userId و $receiverId');

      final chatId = _getPrivateChatId(userId, receiverId);
      final chatDoc = _chatRoomsCollection.doc(chatId);
      
      // التحقق من وجود المحادثة
      final doc = await chatDoc.get();
      if (!doc.exists) {
        print('📭 المحادثة الخاصة غير موجودة');
        return [];
      }

      final messagesCollection = chatDoc.collection(subCollectionPrivateMessages);

      final querySnapshot = await messagesCollection
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final messages = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime timestamp = _parseTimestamp(data['timestamp'] ?? data['timeMessage']);
        String timeMessageStr = _parseTimeString(data['timeMessage'], timestamp);
        
        return MessageModel(
          id: data['id'] as String? ?? doc.id,
          message: data['message'] as String? ?? '',
          senderId: data['senderId'] as String? ?? '',
          senderName: data['senderName'] as String? ?? 'مستخدم',
          receiverId: data['receiverId'] as String?,
          groupId: null,
          messageAttachment: data['messageAttachment'] as String? ?? '',
          timeMessage: timeMessageStr,
          timestamp: timestamp,
          isDeleted: data['isDeleted'] as bool? ?? false,
          chatType: data['chatType'] as String? ?? 'private',
        );
      }).toList();

      print('✅ تم جلب ${messages.length} رسالة خاصة');
      return messages;

    } catch (e) {
      print('❌ خطأ في جلب الرسائل الخاصة: $e');
      return [];
    }
  }

    // ✅ دالة مسؤولة عن مزامنة الأعضاء داخل المستند
  @override
  Future<void> ensureGroupChatDoc(String groupId, {GroupModel? groupModel, String? courseName}) async {
    try {
      print('🔄 [ensureGroupChatDoc] بدء مزامنة الأعضاء للمجموعة: $groupId');

      // 1. الخطوة الأولى: ضمان وجود المستند (القشرة) بدون أعضاء
      await _ensureGroupChatDocExists(groupId, groupName: courseName);

      // 2. إذا لم يتم توفير groupModel، لا نستطيع إضافة أعضاء جدد، نكتفي بوجود المستند
      if (groupModel == null) {
        print('⚠️ [ensureGroupChatDoc] لا يوجد groupModel ممرر، لا يمكن تحديث الأعضاء.');
        return;
      }

      // 3. تجهيز قائمة المعرفات (IDs) من groupModel
      List<String> newModelIds = [];
      
      if (groupModel.idDoctor.isNotEmpty) {
        newModelIds.add(groupModel.idDoctor);
      }
      
      for (final student in groupModel.students) {
        if (student.studentId.isNotEmpty) {
          newModelIds.add(student.studentId);
        }
      }

      // 4. جلب المستند الحالي لدمج الأعضاء الجديدة مع القديمة
      final docRef = _chatRoomsCollection.doc('educational_group_$groupId');
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;

      final existingIds = List<String>.from(data['memberIds'] ?? []);
      final existingSet = existingIds.toSet();
      final newSet = newModelIds.toSet();

      // 5. دمج القوائم (لضمان إضافة الجديد فقط وعدم حذف الموجودين مسبقاً)
      final mergedSet = {...existingSet, ...newSet};
      final finalMemberIds = mergedSet.toList();

      // 6. تحديث المستند بالقائمة الكاملة
      await docRef.update({
        'memberIds': finalMemberIds,
        'memberCount': finalMemberIds.length,
        'name': courseName != null ? "$courseName-${groupModel.name}" : data['name'] , // تحديث الاسم إذا توفر
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ [ensureGroupChatDoc] تم تحديث الأعضاء بنجاح: ${finalMemberIds.length} عضو');

    } catch (e) {
      print('❌ خطأ في مزامنة الأعضاء: $e');
    }
  }
  
  // ✅ دالة مساعدة: توليد معرف محادثة خاصة فريد
  String _getPrivateChatId(String user1, String user2) {
    // التحقق من أن المعرفات ليست فارغة
    if (user1.isEmpty || user2.isEmpty) {
      print('❌ خطأ: معرف المستخدم فارغ في _getPrivateChatId');
      print('user1: "$user1"');
      print('user2: "$user2"');
      throw Exception('معرف المستخدم لا يمكن أن يكون فارغاً');
    }
    
    final sortedIds = [user1, user2]..sort();
    return 'private_chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  // ✅ جلب جميع رسائل المستخدم (من جميع المحادثات)
  @override
  Future<List<MessageModel>> getUserMessages(String userId) async {
    try {
      print('🔍 جلب جميع رسائل المستخدم المرسلة: $userId');
      final messages = <MessageModel>[];
      
      // 1. جلب دور المستخدم أولاً
      try {
        final userDoc =  await _userRepository.getUserByUserID(userId);
        if (userDoc.userID.isNotEmpty) {
          final userData = userDoc as UserModels;
          final role = userData.role;
          
          // 2. إذا كان المستخدم دكتور/مدير/أدمن، نحصل على رسائله من مجموعة الأطباء
          if (role == 'Doctor' || role == 'Admin' || role == 'Manager') {
            print('👨‍⚕️ المستخدم هو $role، جلب الرسائل من مجموعة الأطباء...');
            final doctorsGroupDoc = _chatRoomsCollection.doc('doctors_group');
            
            // جلب الرسائل التي أرسلها هذا المستخدم تحديداً (للتحسين)
            final doctorsMessages = await doctorsGroupDoc
                .collection(subCollectionDoctorsMessages)
                .where('senderId', isEqualTo: userId)
                .orderBy('timestamp', descending: true)
                .limit(50) // حد أقصى 50 رسالة من مجموعة الأطباء
                .get();

            for (final doc in doctorsMessages.docs) {
              final data = doc.data() as Map<String, dynamic>;
              messages.add(MessageModel(
                id: data['id'] as String? ?? doc.id,
                message: data['message'] as String? ?? '',
                senderId: data['senderId'] as String? ?? '',
                senderName: data['senderName'] as String? ?? 'مستخدم',
                groupId: 'doctors_group',
                messageAttachment: data['messageAttachment'] as String? ?? '',
                timeMessage: _parseTimeString(data['timeMessage'], _parseTimestamp(data['timestamp'])),
                timestamp: _parseTimestamp(data['timestamp']),
                isDeleted: data['isDeleted'] as bool? ?? false,
                chatType: chatTypeDoctorsGroup,
              ));
            }
          }
        }
      } catch (e) {
        print('⚠️ خطأ في جلب دور المستخدم: $e');
      }

      // 3. البحث في المحادثات الخاصة (التي يكون المستخدم مشاركاً فيها)
      final privateChatsQuery = await _chatRoomsCollection
          .where('type', isEqualTo: 'private')
          .where('participants', arrayContains: userId)
          .limit(20) // آخر 20 محادثة خاصة
          .get();

      for (final chatDoc in privateChatsQuery.docs) {
        final messagesCollection = chatDoc.reference.collection(subCollectionPrivateMessages);
        // جلب الرسائل التي أرسلها المستخدم فقط
        final chatMessages = await messagesCollection
            .where('senderId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(20) // آخر 20 رسالة لكل محادثة
            .get();

        for (final doc in chatMessages.docs) {
          final data = doc.data() as Map<String, dynamic>;
          messages.add(MessageModel(
            id: doc.id,
            message: data['message'] as String? ?? '',
            senderId: data['senderId'] as String? ?? '',
            senderName: data['senderName'] as String? ?? '',
            receiverId: data['receiverId'] as String?,
            messageAttachment: data['messageAttachment'] as String? ?? '',
            timeMessage: _parseTimeString(data['timeMessage'], _parseTimestamp(data['timestamp'])),
            timestamp: _parseTimestamp(data['timestamp']),
            isDeleted: data['isDeleted'] as bool? ?? false,
            chatType: chatTypePrivate,
          ));
        }
      }

      // 4. البحث في المجموعات التعليمية
      final educationalGroupsQuery = await _chatRoomsCollection
          .where('type', isEqualTo: 'educational_group')
          .where('memberIds', arrayContains: userId)
          .limit(20) // آخر 20 مجموعة تعليمية للمستخدم
          .get();

      for (final groupDoc in educationalGroupsQuery.docs) {
        final messagesCollection = groupDoc.reference.collection(subCollectionGroupMessages);
        final groupMessages = await messagesCollection
            .where('senderId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(20) // آخر 20 رسالة لكل مجموعة
            .get();

        for (final doc in groupMessages.docs) {
          final data = doc.data() as Map<String, dynamic>;
          messages.add(MessageModel(
            id: doc.id,
            message: data['message'] as String? ?? '',
            senderId: data['senderId'] as String? ?? '',
            senderName: data['senderName'] as String? ?? '',
            groupId: data['groupId'] as String?,
            messageAttachment: data['messageAttachment'] as String? ?? '',
            timeMessage: _parseTimeString(data['timeMessage'], _parseTimestamp(data['timestamp'])),
            timestamp: _parseTimestamp(data['timestamp']),
            isDeleted: data['isDeleted'] as bool? ?? false,
            chatType: chatTypeEducationalGroup,
          ));
        }
      }

      // 5. ترتيب جميع الرسائل حسب الوقت (الأحدث أولاً)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('✅ تم جلب ${messages.length} رسالة مرسلة للمستخدم');
      return messages;

    } catch (e) {
      print('❌ خطأ في جلب رسائل المستخدم: $e');
      return [];
    }
  }

  // ✅   دالة حذف الرسالة
  @override
  Future<void> deleteMessage(MessageModel message, {String? groupId}) async {
    try {
      print('🗑️ بدء عملية الحذف للرسالة: ${message.id} في المجموعة: $groupId');

      final docid;
      final subCollection;
      if(message.chatType == chatTypeEducationalGroup){
        if (groupId == null) {
        throw Exception('groupId مطلوب لحذف رسالة المجموعة التعليمية');
        }
        docid = 'educational_group_$groupId';
        subCollection = subCollectionGroupMessages;
      } else if(message.chatType == chatTypeDoctorsGroup){
        docid = 'doctors_group';
        subCollection = subCollectionDoctorsMessages;
      } else if(message.chatType == chatTypePrivate){
        // للرسائل الخاصة، نستخدم receiverId بدلاً من groupId
        if (message.receiverId == null) {
        throw Exception('receiverId مطلوب لحذف رسالة خاصة');
        }
        docid = _getPrivateChatId(message.senderId, message.receiverId!);
        subCollection = subCollectionPrivateMessages;
      } else{
        throw Exception('نوع الدردشة غير معروف للحذف');
      }

      // تحديد مسار الرسالة
      final docRef = _chatRoomsCollection
          .doc(docid)
          .collection(subCollection)
          .doc(message.id);

      // التحقق من وجود الرسالة
      final doc = await docRef.get();
      if (!doc.exists) {
        print('⚠️ الرسالة غير موجودة');
        return;
      }

      // ✅ تنفيذ الحذف النهائي (Hard Delete)
      await docRef.delete();

      print('✅ تم حذف الرسالة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الرسالة: $e');
      rethrow;
    }
  }

  // ✅ حذف جميع الرسائل (للتطوير فقط)
  @override
  Future<void> deleteAllMessages() async {
    try {
      print('🗑️ حذف جميع الرسائل');

      // حذف جميع مستندات chat_rooms والمجموعات الفرعية
      final chatRoomsQuery = await _chatRoomsCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final chatDoc in chatRoomsQuery.docs) {
        // حذف الرسائل في المجموعات الفرعية أولاً
        final subCollections = ['group_messages', 'private_messages', 'doctors_messages'];
        
        for (final subCollection in subCollections) {
          try {
            final messagesQuery = await chatDoc.reference.collection(subCollection).get();
            for (final messageDoc in messagesQuery.docs) {
              batch.delete(messageDoc.reference);
            }
          } catch (e) {
            print('⚠️ خطأ في حذف $subCollection: $e');
          }
        }

        // حذف مستند المحادثة
        batch.delete(chatDoc.reference);
      }

      await batch.commit();
      print('✅ تم حذف ${chatRoomsQuery.docs.length} محادثة ورسائلها');

    } catch (e) {
      print('❌ خطأ في حذف جميع الرسائل: $e');
      rethrow;
    }
  }

  // ✅ تعديل رسالة
  @override
  Future<void> updateMessage(MessageModel message, {String? groupId}) async {
    try {
      print('✏️ تعديل الرسالة: ${message.id} في المجموعة: $groupId');

      final docid;
      final subCollection;
      if(message.chatType == chatTypeEducationalGroup){
        if (groupId == null) {
        throw Exception('groupId مطلوب لتعديل رسالة المجموعة التعليمية');
        }
        docid = 'educational_group_$groupId';
        subCollection = subCollectionGroupMessages;
      } else if(message.chatType == chatTypeDoctorsGroup){
        docid = 'doctors_group';
        subCollection = subCollectionDoctorsMessages;
      } else if(message.chatType == chatTypePrivate){
        if (message.receiverId == null) {
        throw Exception('receiverId مطلوب لتعديل رسالة خاصة');
        }
        docid = _getPrivateChatId(message.senderId, message.receiverId!);
        subCollection = subCollectionPrivateMessages;
      } else{
        throw Exception('نوع الدردشة غير معروف للحذف');
      }
      
      
        await _chatRoomsCollection
            .doc(docid)
            .collection(subCollection)
            .doc(message.id)
            .update({
              'message': message.message,
              'timestamp': FieldValue.serverTimestamp(), // تحديث الوقت ليظهر أعلى القائمة
              'isEdited': true, // إضافة علامة للتعديل
            });
        print('✅ تم تعديل الرسالة بنجاح');
    } catch (e) {
      print('❌ خطأ في تعديل الرسالة: $e');
      rethrow;
    }
  }

  // ✅ جلب قائمة التدريسين
  @override
  Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      print('👨‍⚕️ جلب قائمة التدريسين');

        final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Doctor');
        final admins = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
        final managers = await _userRepository.getUsersByRoleOrIds(role: 'Manager');

        // دمج جميع المستخدمين في قائمة واحدة
    final allUsers = [...doctors, ...admins, ...managers];
    
    // تحويل إلى تنسيق المطلوب
    final usersList = allUsers.map((user) {
      return {
        'userID': user.userID,
        'id': user.userID,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'url_img': user.urlImg,
        'gender': user.gender,
        'Role': user.role, // للحفاظ على التوافق مع الكود الحالي
      };
    }).toList();

      // ترتيب حسب الدور
      usersList.sort((a, b) {
        final roleOrder = {'Admin': 0, 'Manager': 1, 'Doctor': 2};
        final roleA = roleOrder[a['Role']] ?? 3;
        final roleB = roleOrder[b['Role']] ?? 3;
        return roleA.compareTo(roleB);
      });

      print('✅ تم جلب ${usersList.length} عضو (دكاترة: ${doctors.length}, مشرفين: ${admins.length}, مديرين: ${managers.length})');
      return usersList;

    } catch (e) {
      print('❌ خطأ في جلب التدريسين: $e');
      rethrow;
    }
  }

  // ✅ إنشاء مجموعة دردشة
  @override
  Future<ChatRoomModel> createGroupChat({
    required String name,
    required List<String> memberIds,
    String? imageUrl,
  }) async {
    try {
      print('🚀 إنشاء مجموعة دردشة جديدة: $name');

      final groupId = _generateGroupId();
      final now = DateTime.now().toIso8601String();

      final group = ChatRoomModel(
        id: groupId,
        name: name,
        type: 'group',
        memberIds: memberIds,
        createdAt: now,
        lastActivity: now,
        imageUrl: imageUrl,
      );

      await _chatRoomsCollection.doc(groupId).set({
        'id': groupId,
        'name': name,
        'type': 'group',
        'memberIds': memberIds,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      print('✅ تم إنشاء المجموعة بنجاح: $groupId');
      return group;

    } catch (e) {
      print('❌ خطأ في إنشاء المجموعة: $e');
      rethrow;
    }
  }

  // ✅ إضافة عضو للمجموعة
  @override
  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      print('➕ إضافة عضو $userId للمجموعة $groupId');

      await _chatRoomsCollection.doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إضافة العضو بنجاح');

    } catch (e) {
      print('❌ خطأ في إضافة العضو: $e');
      rethrow;
    }
  }

  // ✅ إزالة عضو من المجموعة
  @override
  Future<void> removeMemberFromGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      print('➖ إزالة عضو $userId من المجموعة $groupId');

      await _chatRoomsCollection.doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ تم إزالة العضو بنجاح');

    } catch (e) {
      print('❌ خطأ في إزالة العضو: $e');
      rethrow;
    }
  }

  // ✅ جلب معلومات المجموعة
  @override
  Future<ChatRoomModel> getGroupInfo(String groupId) async {
    try {
      print('🔍 جلب معلومات المجموعة: $groupId');

      final doc = await _chatRoomsCollection.doc(groupId).get();

      if (!doc.exists) {
      print('⚠️ المجموعة غير موجودة: $groupId');
      return ChatRoomModel.empty;
      }

      final data = doc.data() as Map<String, dynamic>;
      // تحويل الوقت بأمان
    DateTime lastActivity = DateTime.now();
    if (data['lastActivity'] is DateTime) {
      lastActivity = data['lastActivity'] as DateTime;
    } else if (data['lastActivity'] is Timestamp) {
      lastActivity = (data['lastActivity'] as Timestamp).toDate();
    } else if (data['lastActivityServer'] is Timestamp) {
      lastActivity = (data['lastActivityServer'] as Timestamp).toDate();
    } else if (data['lastActivity'] is String) {
      lastActivity = DateTime.parse(data['lastActivity']);
    }
      
      final group = ChatRoomModel(
        id: doc.id,
        name: data['name'] as String? ?? 'مجموعة',
        type: data['type'] as String,
        memberIds: List<String>.from(data['memberIds'] ?? []),
        imageUrl: data['imageUrl'] as String?,
        lastMessage: data['lastMessage'] as String?,
        lastSenderId: data['lastSenderId'] as String?,
        createdAt: (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        updatedAt: data['updatedAt'] != null 
            ? (data['updatedAt'] as Timestamp).toDate().toIso8601String() 
            : null,
        lastActivity: lastActivity.toIso8601String(),
      );

      print('✅ تم جلب معلومات المجموعة: ${group.name} (${group.type})');
      return group;

    } catch (e) {
      print('❌ خطأ في جلب معلومات المجموعة: $e');
      return ChatRoomModel.empty;
    }
  }

  // ✅ توليد معرف مجموعة
  String _generateGroupId() {
    return 'group_${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // ✅ جلب أدوار المستخدمين
  @override
  Future<Map<String, int>> getUserRoles() async {
    try {
      print('🎭 جلب أدوار المستخدمين');

      final doctors = await _userRepository.getUsersByRoleOrIds(role: 'Admin');
  final admins = doctors.where((doctor) => doctor.role == 'Admin').toList();
  final managers = doctors.where((doctor) => doctor.role == 'Manager').toList();

      final roles = <String, int>{};

      for (final admin in admins) {
        roles['admin'] = int.tryParse(admin.userID) ?? 0;
      }

      for (final manager in managers) {
        roles['manager'] = int.tryParse(manager.userID) ?? 0;
      }

      print('✅ تم جلب الأدوار: $roles');
      return roles;

    } catch (e) {
      print('❌ خطأ في جلب الأدوار: $e');
      return {};
    }
  }

  // ✅ جلب أعضاء المجموعة التعليمية 
  @override
  Future<List<Map<String, dynamic>>> getGroupMembersFromIds(String groupId) async {
    try {
      print('🔍 [getGroupMembersFromIds] جلب أعضاء المجموعة من : $groupId');

      final docRef = _chatRoomsCollection.doc('educational_group_$groupId');
      final doc = await docRef.get();

      if (!doc.exists) {
        print('⚠️ مستند الدردشة غير موجود');
        return [];
      }

      final data = doc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(data['memberIds'] ?? []);
      
      print('👥 عدد المعرفات في المستند: ${memberIds.length}');

      final membersList = <Map<String, dynamic>>[];

      // جلب بيانات المستخدمين واحداً تلو الآخر
      for (final id in memberIds) {
        try {
          final user = await _userRepository.getUserByUserID(id);
          if (user.userID.isNotEmpty) {
            membersList.add({
              'Name': user.name,
              'userID': user.userID,
              'Role': user.role, // Doctor, Student, etc.
              'url_img': user.urlImg,
              'gender': user.gender,
              'studentId': user.role == 'Student' ? user.userID : null,
            });
          }
        } catch (e) {
          print('⚠️ خطأ في جلب بيانات المستخدم $id: $e');
        }
      }

      // ترتيب الأعضاء (الدكاترة أولاً)
      membersList.sort((a, b) {
        if (a['Role'] == 'Doctor' && b['Role'] != 'Doctor') return -1;
        if (a['Role'] != 'Doctor' && b['Role'] == 'Doctor') return 1;
        return 0;
      });

      print('✅ تم جلب ${membersList.length} عضو بنجاح');
      return membersList;

    } catch (e) {
      print('❌ خطأ في جلب الأعضاء من المعرفات: $e');
      return [];
    }
  }

  // ✅ تطبيق دالة مزامنة الأعضاء
  @override
  Future<void> syncGroupMembers(String groupId, List<String> newMemberIds) async {
    try {
      print('🔄 [syncGroupMembers] بدء مزامنة الأعضاء للمجموعة: $groupId');

      if (newMemberIds.isEmpty) return;

      final docRef = _chatRoomsCollection.doc('educational_group_$groupId');
      final doc = await docRef.get();

      List<String> finalMemberIds = [];

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currentIds = List<String>.from(data['memberIds'] ?? []);
        final currentSet = currentIds.toSet();
        final newSet = newMemberIds.toSet();

        // دمج القوائم (القديمة + الجديدة)
        final mergedSet = {...currentSet, ...newSet};
        finalMemberIds = mergedSet.toList();
        
        print('📊 الحالية: ${currentIds.length}, الجديدة: ${newMemberIds.length}, المجموع: ${finalMemberIds.length}');
      } else {
        // إذا لم يكن المستند موجوداً، ننشئه بالقائمة الجديدة
        finalMemberIds = newMemberIds;
        print('🏗️ إنشاء مستند جديد بقائمة الأعضاء');
      }

      // التحديث في Firestore
      await docRef.set({
        'memberIds': finalMemberIds,
        'memberCount': finalMemberIds.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ تم تحديث قائمة الأعضاء في بنجاح');

    } catch (e) {
      print('❌ خطأ في مزامنة الأعضاء: $e');
    }
  }

  // ✅ البحث في رسائل المجموعة
  Future<List<MessageModel>> searchGroupMessages({
    required String groupId,
    required String query,
  }) async {
    try {
      print('🔍 البحث في رسائل المجموعة: $query');

      final allMessages = await getGroupMessages(groupId);

      // فلترة الرسائل محلياً (مناسبة للكميات الصغيرة والمتوسطة)
      final results = allMessages.where((message) {
        return message.message.toLowerCase().contains(query.toLowerCase());
      }).toList();

      print('✅ تم العثور على ${results.length} نتيجة');
      return results;

    } catch (e) {
      print('❌ خطأ في البحث: $e');
      rethrow;
    }
  }

  // ✅ جلب آخر رسالة في المجموعة
  Future<MessageModel?> getLastGroupMessage(String groupId) async {
    try {
      final groupChatDoc = _chatRoomsCollection.doc('educational_group_$groupId');
      final messagesCollection = groupChatDoc.collection(subCollectionGroupMessages);

      final querySnapshot = await messagesCollection
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        DateTime timestamp = _parseTimestamp(data['timestamp'] ?? data['timeMessage']);
        String timeMessageStr = _parseTimeString(data['timeMessage'], timestamp);
        
        return MessageModel(
          id: doc.id,
          message: data['message'] as String? ?? '',
          senderId: data['senderId'] as String? ?? '',
          senderName: data['senderName'] as String? ?? 'مستخدم',
          groupId: data['groupId'] as String? ?? groupId,
          messageAttachment: data['messageAttachment'] as String? ?? '',
          timeMessage: timeMessageStr,
          timestamp: timestamp,
          isDeleted: data['isDeleted'] as bool? ?? false,
          chatType: data['chatType'] as String? ?? 'educational_group',
        );
      }
      return null;

    } catch (e) {
      print('❌ خطأ في جلب آخر رسالة: $e');
      return null;
    }
  }
}