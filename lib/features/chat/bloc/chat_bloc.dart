import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:flutter/services.dart';
import 'package:myproject/components/themeData/connenct.dart';
import 'package:semester_repository/semester_repository.dart';
import "package:shared_preferences/shared_preferences.dart";

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final Map<String, List<MessageModel>> _memoryCache = {};
  final Map<String, DateTime> _lastSyncTimes = {};
  final List<MessageModel> _pendingMessages = [];
  bool _isConnected = true;
  Timer? _connectionTimer;
  SharedPreferences? _prefs;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<LoadPrivateMessages>(_onLoadPrivateMessages);
    on<LoadGroupMessages>(_onLoadGroupMessages);
    on<LoadDoctorsMessages>(_onLoadDoctorsMessages);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<UpdateMessage>(_onUpdateMessage);
    on<LoadUserRoles>(_onLoadUserRoles);
    on<CheckConnection>(_onCheckConnection);
    on<RetrySendMessage>(_onRetrySendMessage);
    on<ClearCache>(_onClearCache);
    on<SyncMessages>(_onSyncMessages);
    on<SearchMessages>(_onSearchMessages);
    on<LoadMyChats>(_onLoadMyChats);
    on<CheckDoctorsGroup>(_onCheckDoctorsGroup);
    on<CreateDoctorsGroup>(_onCreateDoctorsGroup);
    on<EnsureGroupData>(_onEnsureGroupData);
        on<LoadGroupMembersFallback>(_onLoadGroupMembersFallback);

    _initializeBloc();
  }

  Future<void> _initializeBloc() async {
    _prefs = await SharedPreferences.getInstance();
    _startConnectionMonitoring();
  }

  void _startConnectionMonitoring() {
    _checkInitialConnection();
    _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkInitialConnection() async {
    final isConnected = await checkInternetconnection();
    if (isConnected != _isConnected) {
      _isConnected = isConnected;
      add(CheckConnection(isConnected: _isConnected));
    }
  }

  Future<void> _checkConnectionStatus() async {
    final isConnected = await checkInternetconnection();
    if (isConnected != _isConnected) {
      _isConnected = isConnected;
      add(CheckConnection(isConnected: _isConnected));
      if (_isConnected) {
        add(const SyncMessages());
      }
    }
  }

  // --- Cache Logic ---
  
  // ✅ دالة جديدة لتنظيف ذاكرة مفتاح معين فقط (Memory Cache)
  void _clearMemoryCacheKey(String cacheKey) {
    _memoryCache.remove(cacheKey);
    _lastSyncTimes.remove(cacheKey);
    print('🧹 تم تنظيف ذاكرة الكاش للمفتاح: $cacheKey');
  }

  Future<List<MessageModel>> _getCachedMessages(String cacheKey) async {
    // ✅ تحسين: سنرجع الرسائل من الذاكرة فقط إذا لم يتم طلب التنظيف (في حالة الإرسال مثلاً)
    // ولكن في التحميل العادي، نفضل جلب البيانات من السيرفر كما هو الحال في الحل السابق
    
    if (_memoryCache.containsKey(cacheKey) && _memoryCache[cacheKey]!.isNotEmpty) {
      print('📦 استخدام الرسائل من الذاكرة المؤقتة: ${_memoryCache[cacheKey]!.length} رسالة');
      return _memoryCache[cacheKey]!;
    }
    if (_prefs != null && _prefs!.containsKey(cacheKey)) {
      try {
        final cachedData = _prefs!.getString(cacheKey);
        if (cachedData != null && cachedData.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(cachedData);
          final messages = jsonList.map((json) => MessageModel.fromJson(json)).toList();
          print('💾 استخدام الرسائل المخزنة محلياً: ${messages.length} رسالة');
          _memoryCache[cacheKey] = messages;
          return messages;
        }
      } catch (e) {
        print('⚠️ خطأ في قراءة التخزين المؤقت: $e');
        await _clearCacheForKey(cacheKey);
      }
    }
    return [];
  }

  Future<void> _saveToCache(String cacheKey, List<MessageModel> messages) async {
    try {
      // إزالة الرسائل المكررة قبل الحفظ
      final uniqueMessages = <MessageModel>[];
      final seenIds = <String>{};
      
      for (final message in messages) {
        if (!seenIds.contains(message.id)) {
          seenIds.add(message.id);
          uniqueMessages.add(message);
        }
      }
      
      _memoryCache[cacheKey] = uniqueMessages;
      _lastSyncTimes[cacheKey] = DateTime.now();

      // فقط الحفظ إذا كانت هناك رسائل
      if (_prefs != null && uniqueMessages.isNotEmpty) {
        final jsonList = uniqueMessages.map((msg) => msg.toJson()).toList();
        await _prefs!.setString(cacheKey, json.encode(jsonList));
        await _prefs!.setString('${cacheKey}_last_sync', DateTime.now().toIso8601String());
        print('💾 تم حفظ ${uniqueMessages.length} رسالة فريدة في التخزين المؤقت: $cacheKey');
      }
    } catch (e) {
      print('⚠️ خطأ في حفظ التخزين المؤقت: $e');
    }
  }

  Future<void> _clearCacheForKey(String cacheKey) async {
    // تنظيف كل شيء (ذاكرة + تخزين دائم)
    _clearMemoryCacheKey(cacheKey);
    
    if (_prefs != null) {
      await _prefs!.remove(cacheKey);
      await _prefs!.remove('${cacheKey}_last_sync');
    }
  }


  // --- Event Handlers ---

  Future<void> _onLoadGroupMessages(
    LoadGroupMessages event,
    Emitter<ChatState> emit,
  ) async {
    print('🔍 تحميل رسائل المجموعة: ${event.groupId}');
    emit(ChatLoading());

    try {
      print('🌐 جلب الرسائل من Firestore...');
      final messages = await chatRepository.getGroupMessages(event.groupId);
      print('✅ تم جلب ${messages.length} رسالة من Firestore');

      final cacheKey = 'group_${event.groupId}';
      await _saveToCache(cacheKey, messages);

      emit(GroupMessagesLoaded(messages: messages));
    } catch (e, stackTrace) {
      print('❌ خطأ في تحميل رسائل المجموعة: $e');
      print('📋 Stack trace: $stackTrace');
      
      // في حالة الخطأ، نعيد قائمة فارغة لتجنب توقف التطبيق
      emit(GroupMessagesLoaded(messages: []));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final isConnected = await checkInternetconnection();
      if (!isConnected) {
        _storePendingMessage(event.message);
        emit(ChatConnectionLost(
          message: 'فقدان الاتصال. سيتم إرسال الرسالة عند إعادة الاتصال.',
          canRetry: true,
        ));
        return;
      }

      if (event.message.message.trim().isEmpty && event.message.messageAttachment.isEmpty) {
        emit(ChatError(message: 'الرسالة لا يمكن أن تكون فارغة'));
        return;
      }

      emit(ChatSending());
      final sentMessage = await chatRepository.sendMessage(event.message);

      // ✅ تحسين: تحديد مفتاح الكاش الصحيح
      String cacheKey;
      if (sentMessage.groupId != null && sentMessage.groupId!.isNotEmpty) {
        cacheKey = 'group_${sentMessage.groupId}';
      } else if (sentMessage.receiverId != null && sentMessage.receiverId!.isNotEmpty) {
        final sortedIds = [sentMessage.senderId, sentMessage.receiverId!]..sort();
        cacheKey = 'private_${sortedIds[0]}_${sortedIds[1]}';
      } else {
        return; // لا يمكن تحديد الكاش
      }

      // ✅ الحل الجوهري: تنظيف ذاكرة هذا المفتاح بالكامل قبل الإضافة
      // هذا سيمنع ظهور الرسائل المحذوفة القديمة
      _clearMemoryCacheKey(cacheKey);
      print('🧹 تم تنظيف ذاكرة الكاش للتحضير للرسالة الجديدة: $cacheKey');

      // جلب الرسائل الحالية من الذاكرة (التي أصبحت فارغة أو سنتجاهلها)
      // أو ببساطة سنقوم بإنشاء قائمة جديدة تحتوي فقط على الرسالة الجديدة
      // ثم سيتم تحميل القائمة الكاملة في الخطوة التالية
      
      // لإرسال الحالة فوراً بالرسالة الجديدة (تحسين تجربة المستخدم):
      List<MessageModel> tempMessages = [sentMessage];
      
      if (sentMessage.chatType == "private") {
        emit(PrivateMessagesLoaded(messages: tempMessages));
      } else if (sentMessage.groupId == "doctors_group") {
        emit(DoctorsMessagesLoaded(messages: tempMessages));
      } else {
        emit(GroupMessagesLoaded(messages: tempMessages));
      }
      
      // تحديث الكاش (الآن الكاش يحتوي فقط على الرسالة الجديدة)
      await _saveToCache(cacheKey, tempMessages);

      // ✅ أخيراً: قم بتحميل الرسائل الكاملة من السيرفر لتصحيح الحالة فوراً
      // هذا سيقوم باستدعاء _onLoadDoctorsMessages أو غيره وسيملأ الكاش بالبيانات الكاملة الصحيحة
      if (sentMessage.chatType == 'doctors_group') {
        add(const LoadDoctorsMessages());
      } else if (sentMessage.chatType == 'private') {
        add(LoadPrivateMessages(userId: sentMessage.senderId, receiverId: sentMessage.receiverId!));
      } else {
        add(LoadGroupMessages(sentMessage.groupId!));
      }

    } catch (e) {
      emit(ChatError(
        message: 'فشل في إرسال الرسالة: $e',
        canRetry: true,
        retryAction: () => add(SendMessage(event.message)),
      ));
    }
  }

  void _storePendingMessage(MessageModel message) {
    _pendingMessages.add(message);
    print('💾 تم تخزين رسالة معلقة: ${message.message}');
  }

  Future<void> _onSyncMessages(SyncMessages event, Emitter<ChatState> emit) async {
    if (_pendingMessages.isEmpty) return;
    emit(ChatReconnecting());
    
    for (final message in List.from(_pendingMessages)) {
      try {
        await chatRepository.sendMessage(message);
        _pendingMessages.remove(message);
        print('✅ تم مزامنة الرسالة: ${message.message}');
      } catch (e) {
        print('❌ فشل في مزامنة الرسالة: $e');
      }
    }
    if (state is ChatConnectionLost) emit(ChatMessageRetried());
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.deleteMessage(event.message, groupId: event.groupId);
      
      // تحديث الحالة فوراً
      if (state is PrivateMessagesLoaded) {
      final currentState = state as PrivateMessagesLoaded;
      final updatedMessages = currentState.messages.where((msg) => msg.id != event.message.id).toList();
      emit(PrivateMessagesLoaded(messages: updatedMessages));
      
      if (event.message.receiverId != null) {
        final cacheKey = 'private_${event.message.senderId}_${event.message.receiverId}';
        if (_memoryCache.containsKey(cacheKey)) {
          final cachedList = _memoryCache[cacheKey]!;
          cachedList.removeWhere((msg) => msg.id == event.message.id);
          await _saveToCache(cacheKey, cachedList);
        }
      }
    } else if (state is DoctorsMessagesLoaded || state is GroupMessagesLoaded) {
        final currentList = (state is DoctorsMessagesLoaded) 
            ? (state as DoctorsMessagesLoaded).messages
            : (state as GroupMessagesLoaded).messages;
            
        final updatedMessages = currentList.where((msg) => msg.id != event.message.id).toList();
        
        if (state is DoctorsMessagesLoaded) {
          emit(DoctorsMessagesLoaded(messages: updatedMessages));
        } else {
          emit((state as GroupMessagesLoaded).copyWith(messages: updatedMessages));
        }
        
        if (event.groupId != null) {
          final cacheKey = 'group_${event.groupId}';
          if (_memoryCache.containsKey(cacheKey)) {
            final cachedList = _memoryCache[cacheKey]!;
            cachedList.removeWhere((msg) => msg.id == event.message.id);
            await _saveToCache(cacheKey, cachedList);
          }
        }
      }
    } catch (e) {
      emit(ChatError(message: 'فشل في حذف الرسالة: $e'));
    }
  }

  Future<void> _onUpdateMessage(UpdateMessage event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.updateMessage(event.message, groupId: event.groupId);
      _updateMessageInCache(event.message);
      
      if (state is DoctorsMessagesLoaded) {
        final currentState = state as DoctorsMessagesLoaded;
        final updatedList = currentState.messages.map((msg) {
          return msg.id == event.message.id ? event.message : msg;
        }).toList();
        emit(DoctorsMessagesLoaded(messages: updatedList));
      } else if (state is GroupMessagesLoaded) {
        final currentState = state as GroupMessagesLoaded;
        final updatedList = currentState.messages.map((msg) {
          return msg.id == event.message.id ? event.message : msg;
        }).toList();
        emit(currentState.copyWith(messages: updatedList));
      }
    } catch (e) {
      emit(ChatError(message: 'فشل في تعديل الرسالة: $e'));
    }
  }

  void _updateMessageInCache(MessageModel updatedMessage) {
    for (final entry in _memoryCache.entries) {
      final index = entry.value.indexWhere((msg) => msg.id == updatedMessage.id);
      if (index != -1) {
        entry.value[index] = updatedMessage;
        _saveToCache(entry.key, entry.value);
        break;
      }
    }
  }

  Future<void> _onLoadMyChats(LoadMyChats event, Emitter<ChatState> emit) async {
  emit(ChatLoading());
  try {
    // جلب المجموعات حسب دور المستخدم
    List<ChatRoomModel> groups = [];
    
    if (event.userRole == 'Admin' || 
        event.userRole == 'Manager' || 
        event.userRole == 'Doctor') {
      
      // جلب مجموعة الأطباء مرة واحدة فقط
      try {
        final doctorsGroup = await chatRepository.getGroupInfo('doctors_group');
        if (doctorsGroup.isNotEmpty) {
          groups.add(doctorsGroup);
          print('✅ تمت إضافة مجموعة الأطباء إلى القائمة: ${doctorsGroup.name}');
        } else {
          print('⚠️ مجموعة الأطباء فارغة أو غير موجودة، سيتم إنشاؤها');
          // إنشاء المجموعة فقط إذا لم تكن موجودة
          await chatRepository.initializeChatStructure();
          final newDoctorsGroup = await chatRepository.getGroupInfo('doctors_group');
          if (newDoctorsGroup.isNotEmpty) {
            groups.add(newDoctorsGroup);
            print('✅ تمت إضافة مجموعة الأطباء الجديدة إلى القائمة: ${newDoctorsGroup.name}');
          }
        }
      } catch (e) {
        print('⚠️ خطأ في جلب مجموعة الأطباء: $e');
      }
      
      // جلب المجموعات التعليمية
      try {
        print('جلب المجموعات التعليمية');
        final educationalGroups = await chatRepository.getUserGroups(event.userId);
        groups.addAll(educationalGroups);
        print('✅ تم جلب ${educationalGroups.length} مجموعة تعليمية');
      } catch (e) {
        print('⚠️ خطأ في جلب المجموعات التعليمية: $e');
      }
    }
    
    // جلب المحادثات الخاصة للجميع
    List<ChatRoomModel> privateChats = [];
    try {
      privateChats = await chatRepository.getMyPrivateChats(event.userId);
      print('✅ تم جلب ${privateChats.length} محادثة خاصة');
    } catch (e) {
      print('⚠️ خطأ في جلب المحادثات الخاصة: $e');
    }
    
    // إزالة التكرارات بناءً على المعرف
    final uniqueGroups = <String, ChatRoomModel>{};
    for (final group in groups) {
      uniqueGroups[group.id] = group;
    }
    final deduplicatedGroups = uniqueGroups.values.toList();
    
    final allChats = [...deduplicatedGroups, ...privateChats];
    
    allChats.sort((a, b) {
      final dateA = DateTime.tryParse(a.lastActivity) ?? DateTime(0);
      final dateB = DateTime.tryParse(b.lastActivity) ?? DateTime(0);
      return dateB.compareTo(dateA);
    });

    print('✅ تم جلب ${allChats.length} محادثة إجمالية (مجموعات: ${deduplicatedGroups.length}, خاصة: ${privateChats.length})');
    for (final chat in allChats) {
      print('📋 المحادثة: ${chat.name} (${chat.type})');
    }
    
    emit(MyChatsLoaded(chats: allChats));
  } catch (e) {
    print('❌ خطأ في جلب المحادثات: $e');
    emit(ChatError(message: e.toString()));
  }
}

  Future<void> _onCheckDoctorsGroup(CheckDoctorsGroup event, Emitter<ChatState> emit) async {
    emit(DoctorsGroupChecking());
    
    try {
      // التحقق من وجود مجموعة الأطباء
      final doctorsGroup = await chatRepository.getGroupInfo('doctors_group');

      if (doctorsGroup.isEmpty) {
      // إذا لم تكن المجموعة موجودة، قم بإنشائها
      await chatRepository.initializeChatStructure();
      // بعد إنشاء المجموعة، قم بتحميل قائمة المحادثات مرة أخرى
      add(LoadMyChats(userId: event.userId, userRole: event.userRole));
      // إرسال حدث إنشاء المجموعة
      emit(DoctorsGroupCreated());
      
      } else {
      emit(DoctorsGroupChecked(exists: true));
    }
    } catch (e) {
      emit(ChatError(message: 'فشل في التحقق من مجموعة الأطباء: $e'));
    }
  }
  
  Future<void> _onCreateDoctorsGroup(CreateDoctorsGroup event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    
    try {
      // إنشاء مجموعة الأطباء
      await chatRepository.initializeChatStructure();
      
      emit(DoctorsGroupCreated());
    } catch (e) {
      emit(ChatError(message: 'فشل في إنشاء مجموعة الأطباء: $e'));
    }
  }

    Future<void> _onEnsureGroupData(
    EnsureGroupData event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // استدعاء الريبوستوري بأمان داخل Bloc
      await chatRepository.ensureGroupChatDoc(
        event.groupId,
        groupModel: event.groupModel,
        courseName: event.courseName,
      );
      print('✅ تمت مزامنة بيانات المجموعة بنجاح');
    } catch (e) {
      print('❌ فشلت المزامنة: $e');
      // يمكن إرسال حالة خطأ هنا إذا لزم الأمر
    }
  }

    Future<void> _onLoadGroupMembersFallback(
    LoadGroupMembersFallback event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('🔄 [_onLoadGroupMembersFallback] بدء جلب الأعضاء من الريبوستوري: ${event.groupId}');
      
      // استدعاء الدالة الموجودة في الريبوستوري (التي تستخدم getUsersByRoleOrIds أو getUserByUserID داخلياً)
      final members = await chatRepository.getGroupMembersFromIds(event.groupId);
      
      // إرسال الحالة بالأعضاء
      emit(GroupMembersLoaded(members));
      
      print('✅ تم جلب ${members.length} عضو من الريبوستوري');
    } catch (e) {
      print('❌ خطأ في جلب الأعضاء الاحتياطي: $e');
      // لا نرسل حالة خطأ لكي لا نعطل الواجهة، سنكتفي بالسجل
    }
  }
  
  Future<void> _onCheckConnection(CheckConnection event, Emitter<ChatState> emit) async {
    if (!event.isConnected) {
      emit(ChatConnectionLost(message: 'فقدان الاتصال بالإنترنت', canRetry: true));
    } else if (state is ChatConnectionLost) {
      emit(ChatReconnecting());
      add(const SyncMessages());
    }
  }
  
  Future<void> _onRetrySendMessage(RetrySendMessage event, Emitter<ChatState> emit) async {
    final isConnected = await checkInternetconnection();
    if (!isConnected) {
      emit(ChatConnectionLost(message: 'لا يزال الاتصال غير متاح', canRetry: true));
      return;
    }
    add(const SyncMessages());
    emit(ChatMessageRetried());
  }

  void _onClearCache(ClearCache event, Emitter<ChatState> emit) {
    _memoryCache.clear();
    _lastSyncTimes.clear();
    _pendingMessages.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('group_') || key.startsWith('private_') || key.startsWith('doctors_')) {
          _prefs!.remove(key);
        }
      }
    }
    emit(CacheCleared());
  }

  Future<void> _onSearchMessages(SearchMessages event, Emitter<ChatState> emit) async {
    if (state is ChatLoading) return;
    try {
      emit(ChatLoading());
      final results = await chatRepository.searchGroupMessages(
        groupId: event.groupId,
        query: event.query,
      );
      if (event.groupId == 'doctors_group') {
        emit(DoctorsMessagesLoaded(messages: results));
      } else {
        emit(GroupMessagesLoaded(messages: results));
      }
    } catch (e) {
      emit(ChatError(message: 'فشل البحث: $e'));
      add(LoadGroupMessages(event.groupId));
    }
  }

  Future<void> _onLoadPrivateMessages(LoadPrivateMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final cacheKey = 'private_${event.userId}_${event.receiverId}';
      
      // ✅ تنظيف الذاكرة أولاً لضمان عدم ظهور محذوفات (نفس منطق Doctors)
      _clearMemoryCacheKey(cacheKey);
      
      final messages = await chatRepository.getPrivateMessages(userId: event.userId, receiverId: event.receiverId);
      
      await _saveToCache(cacheKey, messages);
      emit(PrivateMessagesLoaded(messages: messages));
    } catch (e) {
      emit(ChatError(message: e.toString(), canRetry: true));
    }
  }

  Future<void> _onLoadDoctorsMessages(LoadDoctorsMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final cacheKey = 'doctors_group';
      
      // ✅ الخطوة 1: تنظيف الذاكرة المؤقتة لهذا المفتاح بالكامل
      // هذا يحل مشكلة "10 رسائل" لأنه يمسح الرسائل القديمة (المحذوفة) من الذاكرة
      _clearMemoryCacheKey(cacheKey);
      print('🧹 تم تنظيف الذاكرة المؤقتة لمجموعة الأطباء قبل الجلب الجديد');

      // ✅ الخطوة 2: جلب الرسائل الصافية من السيرفر مباشرة
      final messages = await chatRepository.getDoctorsGroupMessages();
      
      print('✅ تم جلب ${messages.length} رسالة نشطة من السيرفر (بعد استبعاد المحذوفة)');

      // ✅ الخطوة 3: حفظ القائمة الجديدة في الكاش
      // الآن الكاش فارغ، وسيمتلأ بالرسائل النشطة فقط
      await _saveToCache(cacheKey, messages);
      
      // ✅ الخطوة 4: إرسال الحالة
      emit(DoctorsMessagesLoaded(messages: messages));
      
    } catch (e) {
      print('❌ خطأ في تحميل رسائل مجموعة الأطباء: $e');
      // في حالة الخطأ، لا نرجع شيئاً أو نرجع خطأ، لأن الذاكرة الآن نظيفة/فارغة
      emit(ChatError(message: e.toString(), canRetry: true));
    }
  }

  Future<void> _onLoadUserRoles(LoadUserRoles event, Emitter<ChatState> emit) async {
    try {
      final roles = await chatRepository.getUserRoles();
      emit(UserRolesLoaded(roles: roles));
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _connectionTimer?.cancel();
    _memoryCache.clear();
    _pendingMessages.clear();
    return super.close();
  }
}